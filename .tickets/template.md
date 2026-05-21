# Ticket Template

## ID

`ARCH-000`

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
- Custom skill notes:

## Designer Review

- Required: `No`
- Reason:
- Preferred model: See `.agents/models.md`.
- Preferred effort: See `.agents/models.md`.
- Output needed:

## Design Brief

- UI goal:
- Target user and workflow:
- Layout and components:
- States and edge cases:
- Accessibility:
- Responsive or platform-specific behavior:
- Assets and icons:
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
- [ ] `Skill Context` is filled, including role-specific skills or `None`.
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
- [ ] Relevant files are listed.
- [ ] Relevant memory entries are listed.
- [ ] Acceptance criteria are restated or referenced.
- [ ] Expected executor output is stated.
- [ ] Verification command or manual check is stated.
- Waiver:

### In Progress -> Review

- [ ] Files changed are listed.
- [ ] Implementation notes are written.
- [ ] Red/green evidence is recorded, or TDD waiver is referenced.
- [ ] Commands run are recorded.
- [ ] Known gaps are recorded or explicitly marked `None`.
- Waiver:

### Review -> Test

- [ ] Spec compliance review is complete.
- [ ] Code quality review is complete.
- [ ] Open review issues are resolved, waived with reason, or ticket is blocked.
- [ ] Test scope is identified.
- Waiver:

### Test -> Done

- [ ] Fresh verification evidence is recorded.
- [ ] Failures or coverage gaps are recorded or explicitly marked `None`.
- [ ] Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- [ ] Follow-up tickets are created or explicitly marked `None`.
- [ ] Final ticket state matches `.tickets/queue.md`.
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
