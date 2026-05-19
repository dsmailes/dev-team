# ARCH-001

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

## Skill Context

- Language: Markdown
- Framework: None
- Platform: Local workflow
- Project type: Agent workflow documentation
- Task type: Workflow setup
- Required skills:
  - Architect: `superpowers:writing-plans`, `superpowers:subagent-driven-development`
  - Designer: `None`
  - Executor: `None`
  - Reviewer: `superpowers:requesting-code-review`
  - Tester: `superpowers:verification-before-completion`
- Optional skills:
  - `agent-workflow-audit`
- Custom skill notes:
  - Use `.skills/registry.md` for future framework and language routing.

## Designer Review

- Required: `No`
- Reason: This ticket defines workflow documentation and does not change user-facing UI.
- Preferred model: `gpt-5.4`
- Preferred effort: `high`
- Output needed: None.

## Design Brief

- UI goal: Not applicable.
- Target user and workflow: Not applicable.
- Layout and components: Not applicable.
- States and edge cases: Not applicable.
- Accessibility: Not applicable.
- Responsive or platform-specific behavior: Not applicable.
- Assets and icons: Not applicable.
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

## Review Plan

- Spec compliance: Confirm generated tickets match the user request.
- Code quality: Confirm tickets are small, executable, memory-aware, and free of placeholders.

## Decisions

- Use local Markdown tickets as the initial system.
- External issue trackers can be added later if the workflow grows.
- Use `.memory/` for durable project knowledge, separate from active ticket notes.

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
