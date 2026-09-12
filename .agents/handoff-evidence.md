# Role Handoff Evidence Contract

This is a pure policy contract, not a runtime implementation. Read
`runtime-modes.md` first. The rules below apply to explicitly enforced mode.
Portable reports cannot substitute for trusted runtime records or authenticate
themselves. A caller must supply trusted data; the reference checker cannot
establish trust, create sessions, or complete a ticket.

## Reference CLI

`python3 -B scripts/check-workflow-policy.py --input /outside/project/attempt.json --models .agents/models.md`

Exit 0 means supplied data passes policy checks, not that agents ran. Exit 1
returns a rejection code. All JSON output has `authenticated: false`. The CLI
is read-only, uses Python standard library only, and suppresses bytecode writes.
Use the exact authorized model table snapshot for the attempt via `--models`;
do not revalidate an old attempt against silently changed assignments.

## Input Schema

Top-level JSON fields: `snapshot`, `records`, and, when required,
`integration_record`. Reject duplicate JSON keys. The runner supplies the
active snapshot, not a worker selecting a favorable historical attempt.

Snapshot fields:
- `mode`: `enforced`.
- `ticket_id`, `attempt_id`: nonempty IDs for the active ticket and attempt.
- `commit_sha`: real full 40- or 64-character lowercase hexadecimal Git object ID.
  The checker checks syntax/equality, not Git existence. A runtime verifies the
  actual immutable object and clean target. Never put a fingerprint here.
- `started_at`, `observed_at`: RFC 3339 instants bounding the attempt.
- `orchestrator_session_id`: trusted Architect/coordinator session identity.
- `from_state`, `to_state`, `operation`: protected transition requested.
- `second_review_required`: boolean.
- `runtime`: `harness`, `native_provider`, `allowed_providers`,
  `capabilities`, and exposed `models`. Each model has `provider`, `model`,
  `efforts` list, `availability` (available/unavailable/transient), and
  `quota` (available/unknown/exhausted). An absent model is unavailable.
  Inventory and authorization are frozen for this attempt; a changed selection
  requires a new snapshot/attempt, not retrospective rewriting.
- `assignments`: role-keyed objects containing `provider`, `model`, `effort`,
  and `request`. Role keys are executor/reviewer/second-reviewer/tester.
  Request `routing` defaults to routine. Economy requires reason, deterministic
  true, named commands, requires_judgment false (absent defaults to false; any
  present value must be boolean), and for Executor low_risk true plus
  task documentation/ticket/formatting/version/mechanical. Escalation requires
  authorized true, reason, and trigger focused-difficult or multi-phase.
  Assignment values must equal selection from the sole model table after its
  explicit provider-scoped alias matching. Retain actual inventory provider/model
  IDs in assignments and evidence, not substituted pack aliases.
- `sessions`: trusted role-to-session binding.
- `selected_runs`: exact run ID per required role for this attempt.
- `integration`: required boolean. If false, a nonempty reason is mandatory at
  completion. If true, record the expected integration `commit_sha`.

Every immutable record contains `run_id`, `attempt_id`, `ticket_id`, `role`,
`provider`, `model`, `effort`, `session_id`, `commit_sha`, `outcome`
(pass/fail/blocked), `started_at`, and `completed_at`. Role names match snapshot
keys. Effort must exactly match the selected candidate, not a hardcoded enum
excluding xhigh. Records may be held in a protected external ledger; agent-authored
Markdown and Agent Run Summary are status context only.

The integration record contains `commit_sha`, `ticket_commits` list,
`outcome`, `started_at`, and `completed_at`. It must pass on the expected
integration commit, include the executor commit, and follow focused testing
before completion. The runtime independently verifies batch membership and
command/result provenance; the reference checker only compares supplied fields.

## Protected Transitions

- `In Progress -> Review`, operation transition: selected passing Executor.
- `Review -> Test`, operation transition: selected passing Executor and Reviewer,
  plus Second Reviewer if required.
- `Test -> Done`, operation complete: the entire selected chain including Tester
  and required integration. Generic state editing must reject direct Done.

Each required role uses an independent session ID, different from Architect
and every other required role. The runner binds identities; changing a role
string cannot turn Architect or Executor into an independent Reviewer.

All selected records must match ticket, active attempt, executor commit,
authorized provider/model/effort, and session. IDs must be unique. Missing,
failed, blocked, stale or superseded selected records are rejected; do not search
history for any passing record. Selected-role intervals are ordered, timezone-
aware, non-reversed, and bounded by the attempt and observation. A later or tied
record for the same role/attempt makes an older selected pass stale.

A changed implementation target starts a new attempt and invalidates downstream
acceptance. Protected gates cannot be waived by agent prose. A failed enforced
gate blocks; it never triggers portable fallback. The runner alone owns actual
state transitions, ledger authenticity, lifecycle concurrency, and completion.

See tests/conformance/policy-chain.json for a complete synthetic input and
tests/conformance/handoff-evidence-fixtures.json for versioned runner-neutral
vectors (each has a complete payload and expected verdict). The Python suite
executes those vectors plus additional edge cases. Other adapters can consume
the same JSON. Fixtures are test data, never evidence for a live ticket.
