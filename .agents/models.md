# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-terra-high-default`
- Notes: Terra with high effort is the normal default for architecture, design, implementation, review, and testing. Anthropic Sonnet 5 is the cross-provider fallback. Sol is reserved for an explicitly recorded difficult or multi-phase escalation, never routine work or quota recovery. GPT-5.5 is an optional independent second review; Luna is reserved for narrow, deterministic, low-context verification. Every fallback in the table below intentionally uses a different provider than its preferred assignment, so a provider-wide outage or quota exhaustion cannot take out both.

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
| Architect | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Designer | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Executor | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Reviewer | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Second Reviewer | `gpt-5.5` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` |
| Tester | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: balanced reasoning model with high effort by default. Escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase decision.
- Designer: balanced design/reasoning model with high effort by default. Escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase product or UI decision.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: balanced review/reasoning model with high effort by default. Use the configured cross-provider fallback only when required, and escalate to the best reasoning model only for an explicitly recorded difficult or high-risk review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with high effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

## Escalation Economy

Use Terra High for the normal loop, including ordinary implementation,
debugging, refactors, tests, reviews, and routine architecture/design planning.
Use a higher tier only when the ticket records why Terra is insufficient:

- A focused difficult problem with a clear bounded question may use the runtime's
  higher reasoning tier (for example, Sol at the highest non-parallel effort).
- Use the runtime's ultra tier only when multiple phases or parallel agents
  genuinely need the extra reasoning budget.
- Do not use Sol or an ultra tier merely because the task is serious, spans
  several files, or a preferred model's quota is exhausted. Use the configured
  fallback first.

Choose each role's fallback from a different provider than its preferred
assignment whenever more than one provider is configured or known to the
runtime, so the fallback survives a preferred-provider outage or quota
exhaustion. Fall back within the same provider only when no other configured
provider offers a comparable capability class.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
