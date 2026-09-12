# Ticket Template

## ID

`ARCH-000`

## Title

Short imperative title; filename, H1, and ID must agree.

## State

`Backlog`

## Problem

Concrete user/system problem.

## Scope

Included behavior and ownership.

## Out Of Scope

Excluded behavior.

## Acceptance Criteria

- Concrete observable criterion.

## Questioning Notes

- Context inspected:
- Decision tree / approaches:
- Blocking questions:
- Assumptions / deferred decisions:
- Chosen approach and reason:

## Likely Files

- Owned paths:

## Risks

- Concrete risk or explicitly None.

## Rollback And Persistence

- Persistent changes / user configuration:
- Idempotency:
- Rollback or explicitly None:

## Skill Context

- Language / framework / platform:
- Project type / task type:
- Architect:
- Designer:
- Executor:
- Reviewer:
- Tester:
- Optional skills / custom notes:
- Design tooling capabilities: None.

## Execution Model

- Executor routing: `routine`
- Tester routing: `routine`
- Authorized assignments: See .agents/models.md.
- Economy reason / deterministic commands / low-risk scope:
- Escalation authorized: No
- Escalation trigger / reason:
- Actual model and effort / deviation: Unavailable

## Runtime Mode

- Mode: Select enforced or portable before dispatch.
- Declared capabilities / provider boundary:
- Independent role/session identities:
- Configured versus actual assignment deviations:
- Correction rounds: 0 of 2
- No-progress finding / blocker:
- Bound override decision: None.

Follow .agents/runtime-modes.md. No silent downgrade, fabricated evidence, or
self-review. Missing independent sessions keeps work blocked.

## Workspace And Integration Contract

- Ticket classification: read-only or mutating/building.
- Execution mode: isolated or serialized.
- Workspace ownership / base commit:
- Ticket branch / executor worktree:
- Ticket commit: Real immutable SHA, or Unavailable in portable precommit mode.
- Portable frozen content-sha256 target: Not applicable unless explicitly selected.
- Verification worktree:
- Verification commit / fingerprint before and after:
- Ticket-scoped artifact root / ownership marker:
- Integration batch / applicability reason:
- Included ticket commits or portable targets:
- Integration commit: Real SHA, or separately named portable target.
- Focused verification evidence:
- Post-merge integration matrix command/result:
- Merge/conflict notes:
- Cleanup status:

Every role and retry reuses the same ticket root. Required integration precedes
acceptance/completion and cleanup. Preserve failed/blocked artifacts.

## Optional Host Resource Coordination

- Required: No
- Selected platform skill / resource:
- Lease command and evidence:
- Platform-specific prerequisites:

## Designer Review

- Required: No
- Reason / output needed:

## Second Review

- Required: Not required
- Trigger / independent identity / exact target / outcome:

## Design Brief

- UI goal / target user:
- Layout / states / interaction:
- Accessibility / platform behavior:
- Assets / design tooling / guidance:

## TDD Plan

- Failing test / expected failure:
- Minimal implementation / passing verification:
- Waiver and reason: None.

## Verification Plan

- Exact risk-linked command or manual check:
- Integration scope or explicit non-applicability:

## Handoff Gates

Use the full gates in .agents/handoff.md; do not duplicate their checklists here.

- Backlog -> Ready: Criteria, questions, risks, rollback, skills and verification:
- Ready -> Design -> Ready (if required): Design brief and acceptance:
- Ready -> In Progress: Ownership, mode, assignments and independent roles:
- In Progress -> Review: Executor report/target and mode-specific gate:
- Review -> Test: Independent review and required Second Review:
- Test -> Done: Independent tests, required integration, mode-specific acceptance:
- Waivers: No agent waiver of enforced evidence gates.

## Role Handoff Evidence

Runner-managed in enforced mode only; use .agents/handoff-evidence.md.
Evidence IDs / protected ledger: Unavailable.
Portable mode leaves evidence Unavailable and links independent reports below.
Only the runner completion operation performs enforced Test -> Done; portable
acceptance follows .agents/runtime-modes.md and is never authenticated evidence.

## Agent Run Summary

| Role | Agent or task | Actual model | Effort | Token usage | Elapsed | Correction round | Findings / deviation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Role that ran | Unavailable | Unavailable | Unavailable | Unavailable | Unavailable | 0 | None |

Record every role that ran. No estimated usage or claimed model activation.
Report fallback/escalation reason and transient retries when applicable.

## Review Plan

- Spec compliance:
- Code quality:

## Decisions

- Decision / rationale:

## Memory Updates

- Durable verified update or None:

## Implementation Notes

- Changed files / exact target:
- Red/green commands and results:
- Remaining gaps:

## Review Notes

- Independent report path / identity / target:
- Findings / outcome:

## Test Notes

- Independent report path / identity / target:
- Fresh commands/results / integration:
- Remaining gaps / outcome:
