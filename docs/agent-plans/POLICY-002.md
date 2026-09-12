# POLICY-002 Implementation Plan

## Goal

Make the audited workflow usable in official Codex/ChatGPT and custom runners
without confusing portable review reports with runtime-authenticated evidence.
Keep default models unchanged and do not modify the adjacent Pi working tree.

## Execution

One serialized mutator owns this repository at a time. Architect coordinates;
independent Reviewer and Tester inspect the final implementation. Adjacent Pi
inspection is read-only. Each worker reports files, commands, outcomes and gaps;
no worker writes ticket state or runtime evidence.

1. Installer Executor: fix interactive initialization; separate clean starter state
   from repository development state; verify fresh installs and preserved updates.
2. Contract Executor: add executable reference checks and real fixtures; reconcile
   model candidates with handoff assignments; define explicit portable/enforced
   modes; shorten entry points and template; bound retries; order integration
   before completion. Add installed/update-synced helpers and docs as needed.
3. Independent review: check invalid/stale evidence rejection, authority claims,
   preserved state, provider boundaries, default model parity, and Pi compatibility.
4. Independent testing: run conformance, installer, interactive, fresh-target,
   dashboard, and optional adjacent Pi parser checks against a stable final diff.

## Contract Decisions

- The reference checker validates caller-supplied data. It does not attest that
  agents ran, protect a writable ledger, create sessions, or complete tickets.
- Runtime-enforced mode requires declared capabilities and trusted records.
  Portable mode must be selected explicitly when those capabilities are absent;
  it uses independent reports and a recorded stable verification target, with
  limitations visible. An enforced runner must never silently downgrade.
- Keep legacy model table columns and role labels readable by Pi. Add versioned,
  explicit candidate efforts and authorized routes. Legacy consumers cannot be
  assumed to enforce extensions; their required adapter work is documented.
- Snapshot the authorized role assignment and selected run IDs for each attempt.
  Validate the selected chain, not any historical pass. Reject mismatched tickets,
  commits, models, roles, sessions, timestamps, failed attempts and direct Done.
- Default paths stay cost-conscious. Economy/escalation need explicit routing;
  cross-provider selection requires a custom runtime's provider declaration.
- No fabricated token counts or claimed model activation. Unknown telemetry is
  Unavailable. Capture elapsed time, correction rounds and findings when exposed.
- Integration verification precedes completion when integration is required.
  Single serialized changes record why a separate integration batch is not needed.
- Bounded correction loops stop after two correction rounds, repeated unchanged
  failure, or a real blocker; limits may be explicitly overridden before work.

## Verification And Rollback

Run project tests plus new regression cases. Compare retained model fields with
the actual Pi parser without changing Pi, which has unrelated local changes.
Run fresh --project and --here installs and validate the clean dashboards.
Existing update hash checks remain mandatory. Roll back only scoped workflow
changes; preserve all user-owned state and unrelated tickets.
