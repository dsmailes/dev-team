# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `gpt-5.6-sol-terra-luna-gpt-5.5-second-review`
- Notes: Codex defaults use Sol for architecture and product/design shaping, and Terra with high effort for implementation, primary review, and primary testing. GPT-5.5 is an optional independent second review; Luna is reserved for narrow, deterministic, low-context verification.

## Role Assignments

| Role | Default model | Effort | Escalation |
| --- | --- | --- | --- |
| Architect | `sol` | `high` | Use Sol for ambiguous architecture, migrations, high-risk planning, and cross-ticket decomposition. |
| Designer | `sol` | `high` | Use Sol for important product decisions, broad workflow design, brand-sensitive UI, major design-system changes, and frontend polish. |
| Executor | `terra` | `high` | Escalate to Sol only when a listed trigger applies: Terra is unavailable, the ticket crosses architecture boundaries, the work is high-risk data/security/concurrency/migration logic, debugging remains blocked after reproduction, or Terra reports `NEEDS_CONTEXT` / `BLOCKED` and more reasoning is required. Use Luna only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work. Do not escalate only because a ticket touches multiple files or ordinary integration code. |
| Reviewer | `terra` | `high` | Primary review. Escalate to Sol for security, data-loss, concurrency, migration, public API risk, difficult regressions, or large-context debugging. |
| Second Reviewer | `gpt-5.5` | `high` | Run only when `Second Review` is required: use an independent, adversarial review of the same recorded ticket commit SHA. |
| Tester | `terra` | `high` | Primary verification. Use Luna only for narrow, deterministic, low-context checks. Escalate to Sol for flaky tests, complex async behavior, UI automation, difficult failure triage, or large-context debugging. |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: best reasoning model.
- Designer: best design/reasoning model for major product or UI decisions.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: balanced reasoning model with high effort by default; escalate to the best reasoning model for high-risk or difficult review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with high effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-balanced-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
