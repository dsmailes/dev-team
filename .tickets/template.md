# Ticket Template

## ID

`ARCH-000`

Must match the ticket filename and H1.

## Title

Short imperative title.

## State

`Backlog`

## Problem

What user or system problem is being solved?

## Scope

What is included?

## Out Of Scope

What should not be changed?

## Acceptance Criteria

- Criterion 1
- Criterion 2

## Questioning Notes

- Context inspected:
- Decision tree:
- Blocking questions:
- Assumptions:
- Deferred questions:
- Approaches considered:
- Chosen approach:
- Rejected alternatives:

## Likely Files

- `path/to/file`

## Risks

- Risk 1

## Rollback And Persistence

- Persistent changes:
- User-owned configuration touched:
- Idempotency expectation:
- Rollback or undo path:

## Workspace And Integration Contract

- Ticket classification: `read-only` or `mutating/building`.
- Runtime capability: Isolated ticket worktrees available: `Yes`, `No`, or `Unknown`.
- Execution mode: `isolated` or `serialized`.
- Base commit:
- Ticket branch:
- Executor worktree:
- Ticket commit:
- Verification worktree:
- Verification commit:
- Ticket-scoped artifact root:
- Cleanup status:
- Integration batch:
- Included ticket commits:
- Integration commit:
- Merge/conflict notes:
- Focused verification evidence:
- Post-merge integration matrix command/result:

In `isolated` mode, each concurrent mutating/building ticket owns a unique branch, worktree, and artifact root. In `serialized` mode, only one mutating/building ticket owns the shared worktree at a time. Reviewer and Tester verify the immutable ticket commit from a clean verification worktree. The orchestrator runs one full integration matrix for each merged integration batch. Preserve failed workspaces until diagnosis evidence is captured; clean up only after merge, verification, and artifact capture.

## Skill Context

- Language:
- Framework:
- Platform:
- Project type:
- Task type:
- Required skills:
  - Architect:
  - Designer:
  - Executor:
  - Reviewer:
  - Tester:
- Optional skills:
- Design tooling:
  - Required: `No`
  - Capabilities:
  - Source:
  - Notes:
- Custom skill notes:

## Execution Model

- Executor model: `terra`
- Executor effort: `high`
- Escalation needed: `No`
- Escalation model:
- Escalation reason:
- Terra unavailable fallback:
- Model actually used:

## Source Isolation

- Concurrent execution: `No`
- Worktree path: Not applicable.
- Branch: Not applicable.
- Implementation commit SHA: Not applicable.
- Review commit SHA: Not applicable.
- Test commit SHA: Not applicable.
- Isolated build/cache path: Not applicable.
- Integration branch and matrix: Not applicable.

## Agent Run Summary

Record every role that actually ran for this ticket. Do not estimate token usage: write `Unavailable` when the runtime does not expose it.

| Role | Agent or task | Model | Effort | Token usage |
| --- | --- | --- | --- | --- |
| Architect | Not run | Not run | Not run | Not run |
| Designer | Not run | Not run | Not run | Not run |
| Executor | Not run | Not run | Not run | Not run |
| Reviewer | Not run | Not run | Not run | Not run |
| Tester | Not run | Not run | Not run | Not run |

## Designer Review

- Required: `No`
- Reason:
- Preferred model: See `.agents/models.md`.
- Preferred effort: See `.agents/models.md`.
- Design tooling needed:
- Output needed:

## Design Brief

- UI goal:
- Target user and workflow:
- Layout and components:
- States and edge cases:
- Accessibility:
- Responsive or platform-specific behavior:
- Assets and icons:
- Design tooling used:
- Executor notes:

## TDD Plan

- Failing test:
- Expected failure:
- Minimal implementation:
- Passing verification:
- TDD waiver, if any:

## Verification Plan

- Command or manual check

## Handoff Gates

### Backlog -> Ready

- [ ] Problem is clear.
- [ ] Scope and out-of-scope are written.
- [ ] Acceptance criteria are written.
- [ ] `Questioning Notes` is filled.
- [ ] Blocking questions are answered, waived with a reason, or moved to `Blocked`.
- [ ] Likely files or modules are listed.
- [ ] Risks are listed.
- [ ] Rollback and persistence impact is documented, or explicitly marked `None`.
- [ ] `Skill Context` is filled, including role-specific skills or `None`.
- [ ] `Execution Model` is filled, defaulting Executor to `terra` unless escalation is justified.
- [ ] `Source Isolation` says whether this ticket runs concurrently; concurrent tickets have a dedicated branch and worktree.
- [ ] Verification plan exists.
- [ ] `Designer Review` is marked `Yes` or `No`.
- [ ] TDD plan exists for behavior changes, or a waiver explains why it does not apply.
- Waiver:

### Ready -> Design

- [ ] Designer owner is assigned.
- [ ] Relevant UI files, design-system notes, and memory entries are listed.
- [ ] Output needed from Designer is stated.
- [ ] Open design/product questions are listed or explicitly marked `None`.
- Waiver:

### Design -> Ready

- [ ] Design brief is complete.
- [ ] UI acceptance criteria are concrete enough for Executor.
- [ ] Accessibility, responsive/platform behavior, states, and edge cases are documented.
- [ ] Assets/icons/copy needs are documented or explicitly marked `None`.
- Waiver:

### Ready -> In Progress

- [ ] Executor owner is assigned.
- [ ] Executor model and effort are stated.
- [ ] Executor escalation reason is stated, or escalation is marked `No`.
- [ ] Relevant files are listed.
- [ ] Relevant memory entries are listed.
- [ ] Acceptance criteria are restated or referenced.
- [ ] Expected executor output is stated.
- [ ] Verification command or manual check is stated.
- [ ] Ticket classification, execution mode, base commit, workspace ownership, and ticket-scoped artifact root are recorded.
- Waiver:

### In Progress -> Review

- [ ] Files changed are listed.
- [ ] Implementation notes are written.
- [ ] Model actually used is recorded.
- [ ] Implementation commit SHA is recorded.
- [ ] Red/green evidence is recorded, or TDD waiver is referenced.
- [ ] Commands run are recorded.
- [ ] Known gaps are recorded or explicitly marked `None`.
- [ ] Scoped ticket commit, clean executor status, and artifact locations are recorded.
- [ ] Verification worktree and exact verification commit are recorded.
- Waiver:

### Review -> Test

- [ ] Spec compliance review is complete.
- [ ] Code quality review is complete.
- [ ] Open review issues are resolved, waived with reason, or ticket is blocked.
- [ ] Test scope is identified.
- [ ] Reviewer clean-worktree and commit-identity checks are recorded.
- Waiver:

### Test -> Done

- [ ] Fresh verification evidence is recorded.
- [ ] Tester clean-worktree, commit-identity, and artifact-root checks are recorded.
- [ ] Integration batch membership, integration commit, and one post-merge integration matrix result are recorded.
- [ ] Merge conflicts and affected focused reruns are recorded or explicitly marked `None`.
- [ ] Cleanup status for ticket worktrees, branches, and artifacts is recorded.
- [ ] Failures or coverage gaps are recorded or explicitly marked `None`.
- [ ] Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- [ ] Follow-up tickets are created or explicitly marked `None`.
- [ ] Final ticket state matches `.tickets/queue.md`.
- [ ] Tester verified the same commit SHA reviewed by Reviewer, or recorded why a newer commit required re-review.
- [ ] Concurrent-ticket integration matrix is recorded after merge, or explicitly marked `Not applicable`.
- [ ] `Agent Run Summary` lists every role that ran, its model and effort, and token usage or `Unavailable`.
- Waiver:

## Review Plan

- Spec compliance:
- Code quality:

## Decisions

- Decision log entry

## Memory Updates

- Project:
- Commands:
- Decisions:
- Pitfalls:

## Implementation Notes

- Executor notes
- Red/green evidence:
- Commands run:

## Review Notes

- Spec compliance notes:
- Code quality notes:

## Test Notes

- Tester notes
- Fresh verification evidence:
