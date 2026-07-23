# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-sol-terra-anthropic-sonnet-5-review`
- Notes: Codex defaults use Sol for architecture and product/design shaping, Terra with high effort for implementation and primary testing, and Anthropic Sonnet 5 for primary review only when the active runtime exposes it. Terra is the primary-review fallback. GPT-5.5 is an optional independent second review; Luna is reserved for narrow, deterministic, low-context verification. Every fallback in the table below intentionally uses a different provider than its preferred assignment, so a provider-wide outage or quota exhaustion cannot take out both.

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
| Architect | `sol` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` |
| Designer | `sol` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` |
| Executor | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |
| Reviewer | `anthropic-sonnet-5` | `high` | `anthropic` | `codex` | `terra` |
| Second Reviewer | `gpt-5.5` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` |
| Tester | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: best reasoning model.
- Designer: best design/reasoning model for major product or UI decisions.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: use Anthropic Sonnet 5 with high effort only when the active runtime exposes it and has not exhausted its usage; otherwise use the configured balanced-review fallback with high effort. Record the actual model selected and escalate to the best reasoning model for high-risk or difficult review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with high effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

Choose each role's fallback from a different provider than its preferred
assignment whenever more than one provider is configured or known to the
runtime, so the fallback survives a preferred-provider outage or quota
exhaustion. Fall back within the same provider only when no other configured
provider offers a comparable capability class.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
