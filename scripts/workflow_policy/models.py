"""Read the single model table and validate explicit, provider-local routing."""
from pathlib import Path


# Identity aliases only, not extra candidates or compatible-endpoint authorization.
MODEL_ALIASES = {
    "codex": {"luna": "gpt-5.6-luna", "terra": "gpt-5.6-terra", "sol": "gpt-5.6-sol"},
    "anthropic": {"anthropic-sonnet-4-6": "claude-sonnet-4-6",
                  "anthropic-sonnet-5": "claude-sonnet-5", "anthropic-opus-4-8": "claude-opus-4-8"},
}


def provider_id(value):
    return "codex" if value == "openai-codex" else value


def model_key(provider, model):
    provider = provider_id(provider)
    return provider, MODEL_ALIASES.get(provider, {}).get(model, model)


class PolicyError(ValueError):
    def __init__(self, code):
        self.code = code
        super().__init__(code)


def require(condition, code):
    if not condition:
        raise PolicyError(code)


def nonempty(value):
    return isinstance(value, str) and bool(value.strip())


def read_models(path):
    rows = []
    header = None
    for line in Path(path).read_text().splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip().strip("`") for cell in line.split("|")[1:-1]]
        if cells and cells[0] == "Role":
            require(header is None, "duplicate-model-table")
            header = cells
            require(len(set(header)) == len(header), "invalid-model-table")
        elif header and cells and not all(set(cell) <= set("-: ") for cell in cells):
            require(len(cells) == len(header), "invalid-model-table")
            rows.append(dict(zip(header, cells)))
    required = {"Role", "Model", "Effort", "Provider", "Fallback Provider", "Fallback Model",
                "Economy Provider", "Economy Model", "Economy Effort"}
    require(header is not None and required <= set(header), "invalid-model-table")
    result = {row["Role"].lower().replace(" ", "-"): row for row in rows}
    require(len(result) == len(rows) and len(result) == 6, "invalid-model-table")
    return result


def providers(runtime):
    allowed = runtime.get("allowed_providers")
    require(isinstance(allowed, list) and allowed and all(nonempty(p) for p in allowed), "provider-boundary")
    require(nonempty(runtime.get("native_provider")), "provider-boundary")
    native = provider_id(runtime["native_provider"])
    allowed = {provider_id(value) for value in allowed}
    harness = runtime.get("harness")
    single = {"official-codex": "codex", "official-chatgpt": "codex", "official-claude": "anthropic"}
    if harness in single:
        require(allowed == {single[harness]} and native == single[harness], "provider-boundary")
    elif harness == "unknown":
        require(allowed == {native}, "provider-boundary")
    else:
        require(harness == "custom" and native in allowed, "provider-boundary")
    return allowed


def candidate(row, name, v2):
    prefix = {"preferred": "", "fallback": "Fallback ", "native-fallback": "Native Fallback ",
              "economy": "Economy ", "escalation": "Escalation "}[name]
    effort = row.get(prefix + "Effort", "-")
    if name == "fallback" and (not v2 or effort == "-"):
        effort = row["Effort"]
    values = {"provider": row.get(prefix + "Provider", "-"),
              "model": row.get(prefix + "Model", "-"), "effort": effort}
    if any(value == "-" or not nonempty(value) for value in values.values()):
        return None
    return dict(values, candidate=name)


def select_model(table, role, request, runtime):
    require(role in table and isinstance(request, dict), "invalid-routing")
    allowed = providers(runtime)
    capabilities = runtime.get("capabilities", [])
    require(isinstance(capabilities, list), "invalid-input")
    v2 = "model-routing-v2" in capabilities
    routing = request.get("routing", "routine")
    require(routing in {"routine", "economy", "escalation"}, "invalid-routing")
    order = ["preferred"] + (["native-fallback"] if v2 else []) + ["fallback"]
    if routing == "economy":
        require(role in {"executor", "tester"} and nonempty(request.get("reason"))
                and request.get("deterministic") is True and request.get("requires_judgment", False) is False
                and isinstance(request.get("commands"), list) and request["commands"]
                and all(nonempty(command) for command in request["commands"]), "invalid-economy")
        if role == "executor":
            require(request.get("low_risk") is True and request.get("task") in
                    {"documentation", "ticket", "formatting", "version", "mechanical"}, "invalid-economy")
        order.insert(0, "economy")
    if routing == "escalation":
        require(v2, "routing-capability-required")
        require(request.get("authorized") is True and nonempty(request.get("reason")) and
                request.get("trigger") in {"focused-difficult", "multi-phase"}, "invalid-escalation")
        order = ["escalation"]
    inventory = runtime.get("models")
    require(isinstance(inventory, list) and all(isinstance(item, dict) for item in inventory), "invalid-input")
    require(all(nonempty(item.get("provider")) and nonempty(item.get("model")) for item in inventory), "invalid-input")
    keys = [model_key(item["provider"], item["model"]) for item in inventory]
    require(len(keys) == len(set(keys)), "invalid-input")
    for name in order:
        item = candidate(table[role], name, v2)
        if item is None or provider_id(item["provider"]) not in allowed:
            continue
        if name == "native-fallback" and provider_id(item["provider"]) != provider_id(runtime["native_provider"]):
            continue
        exposed = next((entry for entry in inventory if model_key(entry["provider"], entry["model"]) ==
                        model_key(item["provider"], item["model"])), None)
        if exposed is None:
            continue
        availability, quota = exposed.get("availability"), exposed.get("quota")
        require(availability in {"available", "unavailable", "transient"} and
                quota in {"available", "unknown", "exhausted"}, "invalid-input")
        require(isinstance(exposed.get("efforts"), list), "invalid-input")
        if quota == "exhausted" or availability == "unavailable":
            continue
        require(availability != "transient", "transient-retry-required")
        if item["effort"] in exposed["efforts"]:
            return dict(item, provider=exposed["provider"], model=exposed["model"])
    raise PolicyError("routing-blocked")
