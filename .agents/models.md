# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-luna-xhigh-architect-terra-medium-sonnet-4-6-review`
- Notes: Luna with extra-high (`xhigh`) effort is the default for architecture. Terra with medium effort remains the normal default for design, implementation, and testing. Reviewer uses medium effort and prefers Anthropic Sonnet 4.6 only when the active harness permits and exposes it, otherwise it uses Terra in Codex contexts. Sol is reserved for an explicitly recorded difficult or multi-phase escalation, never routine work or quota recovery. GPT-5.5 is an optional independent second review; Luna medium remains available for narrow, deterministic, low-context execution and verification.

## Runtime Provider Boundary

The runner, not an agent, supplies this context before model selection:

```yaml
runtime:
  harness: official-codex | official-chatgpt | official-claude | custom | unknown
  allowed_providers: [codex]
  native_provider: codex
```

- `official-codex` and `official-chatgpt` permit only `codex` models.
- `official-claude` permits only `anthropic` models.
- `custom` may use every provider explicitly listed in `allowed_providers`.
- `unknown` must not attempt a cross-provider model; use only the runner's
  declared native provider or report that model routing is blocked.

Do not infer `harness` or allowed providers from model names, tools, file paths,
or conversation content. A preferred or fallback model is eligible only when
its provider is in `allowed_providers` and the runtime exposes it.

Identity aliases are provider-scoped, not additional model choices. `codex` and
Pi's `openai-codex` name the same provider boundary; `openai` and arbitrary
OpenAI-compatible endpoints do not. Within that boundary, luna/terra/sol match
gpt-5.6-luna/terra/sol. Within `anthropic`, the packaged anthropic-sonnet-4-6,
anthropic-sonnet-5 and anthropic-opus-4-8 IDs match their claude- equivalents.
All other IDs match exactly. Selection returns the actual inventory provider
and model ID, which assignments and evidence must retain unchanged. Duplicate
inventory entries for one aliased identity are ambiguous and rejected.

## Availability And Usage Checks

The runner checks exposed models, supported efforts, and quota. Confirmed
unavailability or `usage-exhausted` permits fallback; unknown quota does not
mean exhausted. A transient rate limit or transport failure gets at most two
bounded retries of the same candidate, then blocks for diagnosis. Do not use
transient errors as proof of exhaustion or an excuse to escalate. Never retry
a confirmed exhausted candidate. Record the actual selection and reason;
unexposed actual model/effort or quota is `Unavailable`, not an estimate.

## Role Assignments

This is the sole authoritative assignment table. The first nine columns retain
legacy meanings and defaults. Optional extension columns require a declared
`model-routing-v2` capability; merely parsing this file does not activate them.
See `runtime-modes.md` for the Pi adapter migration checklist.

| Role | Model | Effort | Provider | Fallback Provider | Fallback Model | Economy Provider | Economy Model | Economy Effort | Fallback Effort | Native Fallback Provider | Native Fallback Model | Native Fallback Effort | Escalation Provider | Escalation Model | Escalation Effort |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Architect | `luna` | `xhigh` | `codex` | `anthropic` | `anthropic-sonnet-5` | - | - | - | `medium` | `codex` | `terra` | `high` | - | - | - |
| Designer | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` | - | - | - | `medium` | - | - | - | `codex` | `sol` | `high` |
| Executor | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` | `codex` | `luna` | `medium` | `medium` | - | - | - | `codex` | `sol` | `high` |
| Reviewer | `anthropic-sonnet-4-6` | `medium` | `anthropic` | `codex` | `terra` | - | - | - | `medium` | - | - | - | `codex` | `sol` | `high` |
| Second Reviewer | `gpt-5.5` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` | - | - | - | `high` | - | - | - | - | - | - |
| Tester | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` | `codex` | `luna` | `medium` | `medium` | - | - | - | `codex` | `sol` | `high` |

With v2, routine candidates are tried in order: preferred, native fallback,
provider fallback. Native fallback must match the declared native provider.
Every candidate must be provider-permitted, exposed, effort-supported, and not
confirmed exhausted. Economy tries its candidate then the routine chain.
Escalation selects only the explicitly authorized escalation entry, never as
quota recovery. Missing optional fields mean no candidate; omitted fallback
effort inherits primary effort for legacy configurations. Without v2, fallback
effort always inherits primary effort and native/escalation columns are ignored.
Legacy Pi does not implement the new routes or their enforcement.

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: Luna with extra-high (`xhigh`) effort by default. Use the recorded fallback only when Luna is unavailable or usage-exhausted.
- Designer: balanced design/reasoning model with medium effort by default. Escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase product or UI decision.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: use Anthropic Sonnet 4.6 with medium effort only when the runner permits Anthropic and the model is exposed. Otherwise use the configured permitted fallback, which is Terra with medium effort in a Codex harness. Escalate to the best reasoning model only for an explicitly recorded difficult or high-risk review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with medium effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

Economy routing is explicit ticket metadata, never a guess. `Executor routing:
economy` is valid only for low-risk documentation, ticket, formatting, version,
or mechanical edits with deterministic verification. `Tester routing: economy`
is valid only for one or more named, deterministic commands whose result needs
no diagnosis or UI judgment. Missing or ambiguous routing remains `routine`.
When Luna is unavailable or exhausted, the runner returns to the role's routine
Terra assignment before considering its provider fallback.

## Escalation Economy

Use Luna Extra High for architecture. Use Terra Medium for the rest of the
normal loop, including ordinary implementation, debugging, refactors, tests,
reviews, and routine design work.
Use a higher tier only when the ticket records why Terra is insufficient:

- A focused difficult problem or genuinely multi-phase work may use the table's
  explicit Sol `high` entry with a recorded authorization, trigger, and reason.
- Higher efforts require an explicit project configuration decision in this
  table before dispatch; task prose cannot silently select xhigh/max/ultra.
- Do not use Sol or an ultra tier merely because the task is serious, spans
  several files, or a preferred model's quota is exhausted. Use the configured
  fallback first.

Use a cross-provider fallback only when the runner explicitly permits both
providers. Official single-provider harnesses remain provider-local even if
the table names another provider. Custom runners may choose cross-provider
fallbacks to survive quota exhaustion or provider outages.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
