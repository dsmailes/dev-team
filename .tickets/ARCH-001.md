# ARCH-001

## ID

`ARCH-001`

## Title

Define first project task from user request.

## State

`Backlog`

## Problem

The agent workflow exists, but no project-specific implementation task has been selected yet.

## Scope

- Capture the next user-requested project task.
- Ask only the questions needed to make the task executable.
- Break the task into one or more ready tickets.
- Update `.tickets/queue.md`.
- Maintain project memory templates for durable knowledge.

## Out Of Scope

- Implementing the project task before the user request is captured.
- Creating external issues in Linear, GitHub Issues, or Jira.

## Acceptance Criteria

- The user request is represented as one or more tickets.
- Each implementation ticket has scope, acceptance criteria, likely files, risks, and verification plan.
- Each implementation ticket records `Questioning Notes`, including blocking questions, assumptions, and deferred questions.
- At least one ticket is moved to `Ready` if enough information is available.
- Blockers are explicit if no ticket can be made ready.
- Durable project knowledge is recorded in `.memory/` rather than active ticket notes.

## Likely Files

- `.tickets/queue.md`
- `.tickets/ARCH-*.md`
- `.memory/*.md`

## Risks

- Creating tickets that are too broad for a single executor.
- Missing repository-specific conventions if local shell inspection is unavailable.
- Letting `.memory/` become a transcript instead of durable verified knowledge.

## Rollback And Persistence

- Persistent changes: Future tickets may update workflow docs, installer files, project memory, or ticket state.
- User-owned configuration touched: None for this starter ticket.
- Idempotency expectation: Installer and workflow setup tickets should be rerunnable without duplicating entries or clobbering project-local state.
- Rollback or undo path: Future persistent-change tickets must document how to undo the change or restore prior project state.

## Questioning Notes

- Context inspected: Workflow pack docs, ticket template, and memory templates.
- Decision tree: First identify the user's project task, then determine whether it needs design, implementation, review, verification, or memory updates before creating executable tickets.
- Blocking questions: The next user-requested project task is not known yet.
- Assumptions: Future project tasks should be interrogated before execution tickets are marked `Ready`.
- Deferred questions: Exact language, framework, platform, and verification commands depend on the future project.
- Approaches considered: Create one broad starter ticket; create no starter ticket; create a starter ticket that captures the next request and forces questioning before execution.
- Chosen approach: Keep a starter ticket, but require future implementation tickets to include `Questioning Notes`.
- Rejected alternatives: No starter ticket would leave the first workflow step unclear; a broad starter ticket could encourage premature execution.

## Skill Context

- Language: Markdown
- Framework: None
- Platform: Local workflow
- Project type: Agent workflow documentation
- Task type: Workflow setup
- Required skills:
  - Architect: Planning and delegation skills if imported; otherwise `None`
  - Designer: `None`
  - Executor: `None`
  - Reviewer: Review skills if imported; otherwise `None`
  - Tester: Verification skills if imported; otherwise `None`
- Optional skills:
  - Local workflow-audit skill if imported; otherwise `None`
- Design tooling:
  - Required: `No`
  - Capabilities: `None`
  - Source: `None`
  - Notes: Add product-neutral capability names when UI tickets need design artifact inspection.
- Custom skill notes:
  - Use `.skills/registry.md` for future framework and language routing.

## Execution Model

- Executor model: `gpt-5.3-codex-spark`
- Executor effort: `high`
- Escalation needed: `No`
- Escalation model: None.
- Escalation reason: None; this starter ticket is documentation/workflow setup.
- Spark unavailable fallback: Use the nearest available fast coding model and record the fallback reason.
- Model actually used: Not applicable for starter ticket.

## Designer Review

- Required: `No`
- Reason: This ticket defines workflow documentation and does not change user-facing UI.
- Preferred model: See `.agents/models.md`.
- Preferred effort: See `.agents/models.md`.
- Design tooling needed: None.
- Output needed: None.

## Design Brief

- UI goal: Not applicable.
- Target user and workflow: Not applicable.
- Layout and components: Not applicable.
- States and edge cases: Not applicable.
- Accessibility: Not applicable.
- Responsive or platform-specific behavior: Not applicable.
- Assets and icons: Not applicable.
- Design tooling used: None.
- Executor notes: Not applicable.

## TDD Plan

- Failing test: Not applicable; this ticket captures planning workflow only.
- Expected failure: Not applicable.
- Minimal implementation: Update ticket and agent workflow docs.
- Passing verification: Confirm tickets include `Skill Context`, review plan, and verification plan.
- TDD waiver, if any: Documentation-only workflow setup.

## Verification Plan

- Confirm every `Ready` ticket has acceptance criteria and a verification plan.
- Confirm the queue state matches each ticket's `State` field.
- Confirm every implementation ticket includes `Skill Context` and TDD expectations.
- Confirm memory templates are installed and instructions distinguish memory from tickets.
- Confirm handoff gates are present and state transitions require completion or waiver.

## Handoff Gates

### Backlog -> Ready

- [x] Problem is clear.
- [x] Scope and out-of-scope are written.
- [x] Acceptance criteria are written.
- [x] `Questioning Notes` is filled.
- [x] Blocking questions are answered, waived with a reason, or moved to `Blocked`.
- [x] Likely files or modules are listed.
- [x] Risks are listed.
- [x] Rollback and persistence impact is documented, or explicitly marked `None`.
- [x] `Skill Context` is filled, including role-specific skills or `None`.
- [x] `Execution Model` is filled, defaulting Executor to `gpt-5.3-codex-spark` unless escalation is justified.
- [x] Verification plan exists.
- [x] `Designer Review` is marked `Yes` or `No`.
- [x] TDD plan exists for behavior changes, or a waiver explains why it does not apply.
- Waiver: TDD waived because this is documentation/workflow setup.

### Ready -> Design

- [x] Designer owner is assigned.
- [x] Relevant UI files, design-system notes, and memory entries are listed.
- [x] Output needed from Designer is stated.
- [x] Open design/product questions are listed or explicitly marked `None`.
- Waiver: Designer not required because this ticket does not change UI.

### Design -> Ready

- [x] Design brief is complete.
- [x] UI acceptance criteria are concrete enough for Executor.
- [x] Accessibility, responsive/platform behavior, states, and edge cases are documented.
- [x] Assets/icons/copy needs are documented or explicitly marked `None`.
- Waiver: Designer not required because this ticket does not change UI.

### Ready -> In Progress

- [x] Executor owner is assigned.
- [x] Executor model and effort are stated.
- [x] Executor escalation reason is stated, or escalation is marked `No`.
- [x] Relevant files are listed.
- [x] Relevant memory entries are listed.
- [x] Acceptance criteria are restated or referenced.
- [x] Expected executor output is stated.
- [x] Verification command or manual check is stated.
- Waiver: None.

### In Progress -> Review

- [x] Files changed are listed.
- [x] Implementation notes are written.
- [x] Model actually used is recorded.
- [x] Red/green evidence is recorded, or TDD waiver is referenced.
- [x] Commands run are recorded.
- [x] Known gaps are recorded or explicitly marked `None`.
- Waiver: TDD waived because this is documentation/workflow setup.

### Review -> Test

- [x] Spec compliance review is complete.
- [x] Code quality review is complete.
- [x] Open review issues are resolved, waived with reason, or ticket is blocked.
- [x] Test scope is identified.
- Waiver: None.

### Test -> Done

- [ ] Fresh verification evidence is recorded.
- [ ] Failures or coverage gaps are recorded or explicitly marked `None`.
- [ ] Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- [ ] Follow-up tickets are created or explicitly marked `None`.
- [ ] Final ticket state matches `.tickets/queue.md`.
- Waiver:

## Review Plan

- Spec compliance: Confirm generated tickets match the user request.
- Code quality: Confirm tickets are small, executable, memory-aware, and free of placeholders.

## Decisions

- Use local Markdown tickets as the initial system.
- External issue trackers can be added later if the workflow grows.
- Use `.memory/` for durable project knowledge, separate from active ticket notes.
- Use handoff gates to make state transitions explicit.

## Implementation Notes

- Not started.
- Red/green evidence: Not applicable.
- Commands run: None.

## Review Notes

- Spec compliance notes: Not reviewed.
- Code quality notes: Not reviewed.

## Test Notes

- Not tested.
- Fresh verification evidence: None.

## Memory Updates

- Project: Add `.memory/project.md` template for orientation.
- Commands: Add `.memory/commands.md` template for verified commands.
- Decisions: Add `.memory/decisions.md` template for durable decisions.
- Pitfalls: Add `.memory/pitfalls.md` template for recurring traps.
