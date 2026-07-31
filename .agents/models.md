# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-terra-medium-sonnet-review`
- Notes: Terra with medium effort is the normal default for architecture, design, implementation, and testing. Reviewer uses medium effort and prefers Anthropic Sonnet 5 only when the active harness permits and exposes it, otherwise it uses Terra in Codex contexts. Sol is reserved for an explicitly recorded difficult or multi-phase escalation, never routine work or quota recovery. GPT-5.5 is an optional independent second review; Luna is reserved for narrow, deterministic, low-context verification.

## Runtime Provider Boundary

The runner, not an agent, supplies this context before model selection:

```yaml
runtime:
  harness: official-chatgpt | official-claude | custom | unknown
  allowed_providers: [codex]
```

- `official-chatgpt` permits only `codex` models.
- `official-claude` permits only `anthropic` models.
- `custom` may use every provider explicitly listed in `allowed_providers`.
- `unknown` must not attempt a cross-provider model; use only the runner's
  declared native provider or report that model routing is blocked.

Do not infer `harness` or allowed providers from model names, tools, file paths,
or conversation content. A preferred or fallback model is eligible only when
its provider is in `allowed_providers` and the runtime exposes it.

## Availability And Usage Checks

Before spawning a role, check both of the following. Either failing means the
model is not usable and the runner must select the fallback:

1. **Availability**: the active runtime's model list exposes the preferred model.
2. **Usage**: the preferred model has remaining usage/quota. Treat an exhausted
   quota, rate-limit rejection, billing/credit failure, or any runtime signal
   that further calls to that model will be rejected the same as unavailable.

Record which condition failed (`unavailable` or `usage-exhausted`) and the
actual model selected in the ticket's `Agent Run Summary` and `Execution Model`
fallback reason. Do not retry the same exhausted model; move directly to the
fallback in the table below.

## Role Assignments

The table below is machine-readable. Runners select exactly one preferred or
fallback assignment; prose in this file does not override its fields.

| Role | Model | Effort | Provider | Fallback Provider | Fallback Model |
| --- | --- | --- | --- | --- | --- |
| Architect | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Designer | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Executor | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Reviewer | `anthropic-sonnet-5` | `medium` | `anthropic` | `codex` | `terra` |
| Second Reviewer | `gpt-5.5` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` |
| Tester | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: balanced reasoning model with medium effort by default. Escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase decision.
- Designer: balanced design/reasoning model with medium effort by default. Escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase product or UI decision.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: use Anthropic Sonnet 5 with medium effort only when the runner permits Anthropic and the model is exposed. Otherwise use the configured permitted fallback, which is Terra with medium effort in a Codex harness. Escalate to the best reasoning model only for an explicitly recorded difficult or high-risk review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with medium effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

## Escalation Economy

Use Terra Medium for the normal loop, including ordinary implementation,
debugging, refactors, tests, reviews, and routine architecture/design planning.
Use a higher tier only when the ticket records why Terra is insufficient:

- A focused difficult problem with a clear bounded question may use the runtime's
  higher reasoning tier (for example, Sol at the highest non-parallel effort).
- Use the runtime's ultra tier only when multiple phases or parallel agents
  genuinely need the extra reasoning budget.
- Do not use Sol or an ultra tier merely because the task is serious, spans
  several files, or a preferred model's quota is exhausted. Use the configured
  fallback first.

Use a cross-provider fallback only when the runner explicitly permits both
providers. Official single-provider harnesses remain provider-local even if
the table names another provider. Custom runners may choose cross-provider
fallbacks to survive quota exhaustion or provider outages.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
