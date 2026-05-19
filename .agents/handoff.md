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
- Likely files or modules are listed.
- Risks are listed.
- `Skill Context` is filled, including role-specific skills or `None`.
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
- Relevant files are listed.
- Relevant memory entries are listed.
- Acceptance criteria are restated or referenced.
- Expected executor output is stated.
- Verification command or manual check is stated.

### In Progress -> Review

Required before Reviewer starts:

- Files changed are listed.
- Implementation notes are written.
- Red/green evidence is recorded, or TDD waiver is referenced.
- Commands run are recorded.
- Known gaps are recorded or explicitly marked `None`.

### Review -> Test

Required before Tester starts:

- Spec compliance review is complete.
- Code quality review is complete.
- Open review issues are resolved, waived with reason, or ticket is blocked.
- Test scope is identified.

### Test -> Done

Required before completion:

- Fresh verification evidence is recorded.
- Failures or coverage gaps are recorded or explicitly marked `None`.
- Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- Follow-up tickets are created or explicitly marked `None`.
- Final ticket state matches `.tickets/queue.md`.

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
Acceptance criteria:
Known risks:
Expected output:
Gate being satisfied:
Waivers:
```
