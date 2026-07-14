# Handoff Protocol

The orchestrator is responsible for moving tickets between roles. Agents do not call each other directly.

## Rule

Do not move a ticket to the next state until that transition's handoff gate is complete or explicitly waived with a reason.

Waivers must be written in the ticket under the relevant gate.

## Transition Gates

### Backlog -> Ready

Required before implementation can be assigned:

- Problem is clear.
- Scope and out-of-scope are written.
- Acceptance criteria are written.
- `Questioning Notes` is filled.
- The decision tree is documented for ambiguous or high-impact work.
- Blocking questions are answered, waived with a reason, or moved to `Blocked`.
- Likely files or modules are listed.
- Risks are listed.
- Rollback and persistence impact is documented, or explicitly marked `None`.
- `Skill Context` is filled, including role-specific skills or `None`.
- `Execution Model` is filled, defaulting Executor to `terra` unless escalation is justified.
- `Source Isolation` selects `isolated` or `serialized`. Isolated tickets have a dedicated branch/worktree; serialized tickets have exclusive shared-worktree ownership.
- Verification plan exists.
- `Designer Review` is marked `Yes` or `No`.
- TDD plan exists for behavior changes, or a waiver explains why it does not apply.

### Ready -> Design

Required only when `Designer Review` is required:

- Designer owner is assigned.
- Relevant UI files, design-system notes, and memory entries are listed.
- Output needed from Designer is stated.
- Open design/product questions are listed or explicitly marked `None`.

### Design -> Ready

Required before implementation:

- Design brief is complete.
- UI acceptance criteria are concrete enough for Executor.
- Accessibility, responsive/platform behavior, states, and edge cases are documented.
- Assets/icons/copy needs are documented or explicitly marked `None`.

### Ready -> In Progress

Required before Executor starts:

- Executor owner is assigned.
- Executor model and effort are stated.
- Executor escalation reason is stated, or escalation is marked `No`.
- Relevant files are listed.
- Relevant memory entries are listed.
- Acceptance criteria are restated or referenced.
- Expected executor output is stated.
- Verification command or manual check is stated.
- Runtime support for live supervisor contact is noted, or fallback status reporting is required.
- Base commit, executor workspace, and ticket-scoped artifact root are recorded. Isolated tickets also have a dedicated branch/worktree.

### In Progress -> Review

Required before Reviewer starts:

- Files changed are listed.
- Implementation notes are written.
- Model actually used is recorded.
- Ticket commit SHA and clean executor status are recorded.
- Clean verification worktree and exact verification commit are recorded.
- Red/green evidence is recorded, or TDD waiver is referenced.
- Commands run are recorded.
- `git status --short --untracked-files=all` or equivalent artifact check is recorded when relevant.
- Known gaps are recorded or explicitly marked `None`.

### Review -> Test

Required before Tester starts:

- Spec compliance review is complete.
- Code quality review is complete.
- Open review issues are resolved, waived with reason, or ticket is blocked.
- Test scope is identified.
- Reviewer verified the ticket commit SHA in a clean verification worktree.
- Missing context is resolved through supervisor contact, or reported as `NEEDS_CONTEXT` / `BLOCKED`.

### Test -> Done

Required before completion:

- Fresh verification evidence is recorded.
- Failures or coverage gaps are recorded or explicitly marked `None`.
- Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- Follow-up tickets are created or explicitly marked `None`.
- Final ticket state matches `.tickets/queue.md`.
- Tester verified the same commit SHA reviewed by Reviewer, or recorded why a newer commit required re-review.
- Integration batch membership, integration commit, and one post-merge matrix result are recorded when this ticket joins a concurrent batch, or explicitly marked `Not applicable`.
- Cleanup status for ticket worktrees, branches, and artifacts is recorded; unmerged or blocked work is preserved.
- `Agent Run Summary` lists every role that ran, its model and effort, and token usage or `Unavailable`.

## Handoff Summary

Every handoff should include:

```text
Ticket:
State:
Path:
Owner role:
Relevant files:
Relevant memory entries:
Skill Context:
Execution Model:
Source Isolation:
Questioning Notes:
Acceptance criteria:
Known risks:
Expected output:
Gate being satisfied:
Waivers:
Runtime capabilities:
Agent Run Summary:
```
