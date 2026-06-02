# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: `codex`
- Profile: `codex-defaults`
- Notes: Codex defaults prefer Spark for routine execution so higher-capability models can be reserved for architecture, review, and complex work.

## Role Assignments

| Role | Default model | Effort | Escalation |
| --- | --- | --- | --- |
| Architect | `gpt-5.5` | `high` | Use the strongest available reasoning model for ambiguous architecture, migrations, or high-risk planning. |
| Designer | `gpt-5.4` | `high` | Use `gpt-5.5` with `high` effort for important product decisions, broad workflow design, brand-sensitive UI, or major design-system changes. |
| Executor | `gpt-5.3-codex-spark` | `high` | Escalate only when a listed trigger applies: Spark is unavailable, the ticket crosses architecture boundaries, the work is high-risk data/security/concurrency/migration logic, debugging remains blocked after reproduction, or Spark reports `NEEDS_CONTEXT` / `BLOCKED` and more reasoning is required. Do not escalate only because a ticket touches multiple files or ordinary integration code. |
| Reviewer | `gpt-5.5` | `high` | Use the strongest available reasoning model for security, data-loss, concurrency, migration, or public API risk. |
| Tester | `gpt-5.4` | `medium` | Use `high` effort for flaky tests, complex async behavior, UI automation, or difficult failure triage. |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: best reasoning model.
- Designer: balanced reasoning model; escalate to best reasoning for major product or UI decisions.
- Executor: fast coding model by default; escalate to stronger coding or reasoning models as risk increases.
- Reviewer: best reasoning model.
- Tester: balanced reasoning model; raise effort for flaky, async, UI, or failure-triage work.

If exact provider model IDs are not known during installation, use provider-class placeholders such as `anthropic-fast-coding` or `google-best-reasoning`, then replace them with the exact IDs supported by your local agent runner.
