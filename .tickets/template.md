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
- Artifact ownership marker:
- Artifact reuse: `Executor`, `Reviewer`, `Tester`, and retries use the same root.
- Cleanup status:
- Integration batch:
- Included ticket commits:
- Integration commit:
- Merge/conflict notes:
- Focused verification evidence:
- Post-merge integration matrix command/result:

In `isolated` mode, each concurrent mutating/building ticket owns a unique branch, worktree, and one repository-external artifact root keyed by project/ticket. In `serialized` mode, only one mutating/building ticket owns the shared worktree at a time. Every role and retry reuses the same ticket root. Reviewer and Tester verify the immutable ticket commit from a clean verification worktree. The orchestrator runs one full integration matrix for each merged integration batch. Preserve failed workspaces and artifacts until diagnosis evidence is captured. After acceptance, retain concise evidence and intentional source assets, then remove disposable contents only from the ownership-verified ticket root.

## Optional Host Resource Coordination

- Required: `No`
- Platform or framework skill:
- Lease resource:
- Lease root:
- Lease command/evidence: Not applicable.
- Platform-specific build-root configuration: Not applicable.
- Platform-specific artifact path and checks: Not applicable.

Add this section only when a selected platform or framework skill identifies a host-wide resource. Hold the lease only for its contended command with `scripts/with-host-resource-lease.sh RESOURCE -- COMMAND`, and run unrelated work outside it. Follow the selected skill's build-root rules rather than importing another platform's conventions.

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

## Role Handoff Evidence

This section is runtime-managed. The runner writes immutable records here or
links the authoritative external evidence ledger. Agents must not add, alter,
or claim these records in prose. `Agent Run Summary` below is not proof.

| Run ID | Ticket ID | Role | Provider | Model | Session ID | Commit SHA | Outcome | Started At | Completed At |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Runner-managed | `ARCH-000` | Not run | Not run | Not run | Not run | Not run | Not run | Not run | Not run |

Protected transitions require runner-validated `pass` records: Executor for
`In Progress -> Review`, independent Reviewer for `Review -> Test`, and
independent Tester for the runner completion operation `Test -> Done`. Reviewer
and Tester must use the Executor commit SHA. Generic state edits cannot mark a
ticket `Done`.

## Agent Run Summary

Record every role that actually ran for this ticket. Do not estimate token usage: write `Unavailable` when the runtime does not expose it. This is status context, not handoff evidence.

| Role | Agent or task | Model | Effort | Token usage |
| --- | --- | --- | --- | --- |
| Architect | Not run | Not run | Not run | Not run |
| Designer | Not run | Not run | Not run | Not run |
| Executor | Not run | Not run | Not run | Not run |
| Reviewer | Not run | Not run | Not run | Not run |
| Second Reviewer | Not run | Not run | Not run | Not run |
| Tester | Not run | Not run | Not run | Not run |

## Designer Review

- Required: `No`
- Reason:
- Preferred model: See `.agents/models.md`.
- Preferred effort: See `.agents/models.md`.
- Design tooling needed:
- Output needed:

## Second Review

- Required: `Not required`
- Trigger:
- Model:
- Effort:
- Commit SHA:
- Focus:
- Outcome:

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
- [ ] Verification plan exists.
- [ ] `Designer Review` is marked `Yes` or `No`.
- [ ] `Second Review` is marked `Required` or `Not required`.
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
- [ ] Ticket classification, execution mode, base commit, workspace ownership, repository-external ticket artifact root, ownership marker, and cross-role reuse are recorded.
- [ ] Optional Host Resource Coordination is complete when an applicable platform or framework skill requires it.
- Waiver:

### In Progress -> Review

- [ ] Files changed are listed.
- [ ] Implementation notes are written.
- [ ] Runner-generated passing Executor evidence record is attached or linked.
- [ ] Executor provider, model, and effort match `.agents/models.md`.
- [ ] Red/green evidence is recorded, or TDD waiver is referenced.
- [ ] Commands run are recorded.
- [ ] Known gaps are recorded or explicitly marked `None`.
- [ ] Scoped ticket commit, clean executor status, and artifact locations are recorded.
- [ ] Verification worktree and exact verification commit are recorded.
- Waiver: Not permitted in normal mode; the runner must validate Executor evidence.

### Review -> Test

- [ ] Spec compliance review is complete.
- [ ] Code quality review is complete.
- [ ] Runner-generated passing Reviewer record references the Executor commit and an independent session.
- [ ] Reviewer provider, model, and effort match `.agents/models.md`.
- [ ] Open review issues are resolved, waived with reason, or ticket is blocked.
- [ ] `Second Review` is marked `Required` or `Not required`. When required, the independent reviewer verified the same ticket commit SHA and its outcome is recorded.
- [ ] Test scope is identified.
- [ ] Reviewer clean-worktree and commit-identity checks are recorded.
- Waiver: Not permitted in normal mode; the runner must validate independent Reviewer evidence.

### Test -> Done

- [ ] Fresh verification evidence is recorded.
- [ ] Runner completion operation recorded a passing Tester record for the Executor commit with an independent session.
- [ ] Tester provider, model, and effort match `.agents/models.md`.
- [ ] Tester clean-worktree, commit-identity, and artifact-root checks are recorded.
- [ ] Host-resource lease evidence is recorded when applicable.
- [ ] Integration batch membership, integration commit, and one post-merge integration matrix result are recorded.
- [ ] Merge conflicts and affected focused reruns are recorded or explicitly marked `None`.
- [ ] Cleanup status confirms disposable ticket artifacts were removed after acceptance, or records why failed/blocked artifacts were retained.
- [ ] Failures or coverage gaps are recorded or explicitly marked `None`.
- [ ] Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- [ ] Follow-up tickets are created or explicitly marked `None`.
- [ ] Final ticket state matches `.tickets/queue.md`.
- [ ] `Agent Run Summary` lists every role that ran, its model and effort, and token usage or `Unavailable`.
- Waiver: Not permitted in normal mode; the runner completion operation must validate independent Tester evidence.

`Test -> Done` is unavailable through generic state editing. The runner completion operation must validate this section and the protected evidence chain.

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
