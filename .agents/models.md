# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-sol-terra-anthropic-sonnet-5-review`
- Notes: Codex defaults use Sol for architecture and product/design shaping, Terra with high effort for implementation and primary testing, and Anthropic Sonnet 5 for primary review only when the active runtime exposes it. Terra is the primary-review fallback. GPT-5.5 is an optional independent second review; Luna is reserved for narrow, deterministic, low-context verification.

## Role Assignments

The table below is machine-readable. Runners select exactly one preferred or
fallback assignment; prose in this file does not override its fields.

| Role | Model | Effort | Provider | Fallback Provider | Fallback Model |
| --- | --- | --- | --- | --- | --- |
| Architect | `sol` | `high` | `codex` | `codex` | `sol` |
| Designer | `sol` | `high` | `codex` | `codex` | `sol` |
| Executor | `terra` | `high` | `codex` | `codex` | `terra` |
| Reviewer | `anthropic-sonnet-5` | `high` | `anthropic` | `codex` | `terra` |
| Second Reviewer | `gpt-5.5` | `high` | `codex` | `codex` | `gpt-5.5` |
| Tester | `terra` | `high` | `codex` | `codex` | `terra` |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: best reasoning model.
- Designer: best design/reasoning model for major product or UI decisions.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: use Anthropic Sonnet 5 with high effort only when the active runtime exposes it; otherwise use the configured balanced-review fallback with high effort. Record the actual model selected and escalate to the best reasoning model for high-risk or difficult review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with high effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
