# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-sol-terra-luna-gpt-5.5-review`
- Notes: Codex defaults use Sol for architecture and product/design shaping, Terra for implementation, GPT-5.5 for independent review, and Luna with high effort for testing.

## Role Assignments

| Role | Default model | Effort | Escalation |
| --- | --- | --- | --- |
| Architect | `sol` | `high` | Use Sol for ambiguous architecture, migrations, high-risk planning, and cross-ticket decomposition. |
| Designer | `sol` | `high` | Use Sol for important product decisions, broad workflow design, brand-sensitive UI, major design-system changes, and frontend polish. |
| Executor | `terra` | `high` | Escalate to Sol only when a listed trigger applies: Terra is unavailable, the ticket crosses architecture boundaries, the work is high-risk data/security/concurrency/migration logic, debugging remains blocked after reproduction, or Terra reports `NEEDS_CONTEXT` / `BLOCKED` and more reasoning is required. Use Luna only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work. Do not escalate only because a ticket touches multiple files or ordinary integration code. |
| Reviewer | `gpt-5.5` | `high` | Use GPT-5.5 for independent security, data-loss, concurrency, migration, public API risk, and spec compliance review. |
| Tester | `luna` | `high` | Use Luna with high effort for verification; escalate to Sol for flaky tests, complex async behavior, UI automation, or difficult failure triage. |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: best reasoning model.
- Designer: best design/reasoning model for major product or UI decisions.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: best reasoning model.
- Tester: balanced reasoning model; raise effort for flaky, async, UI, or failure-triage work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
