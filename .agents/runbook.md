# Multi-Agent Runbook

This runbook describes how to run the architect, executor, reviewer, and tester loop.

Read `.agents/handoff.md` before moving any ticket between states.

The orchestrator may not move a ticket to the next state until that transition's handoff gate is complete or explicitly waived with a reason in the ticket.

Use `.agents/models.md` as the source of truth for model names and effort levels when spawning each role.

## Read Project Memory

Before planning or execution, read `.memory/` when present:

- `project.md` for orientation.
- `commands.md` before running setup, build, lint, test, or run commands.
- `decisions.md` before proposing architecture changes.
- `pitfalls.md` before debugging or changing fragile areas.

Only write durable verified knowledge to `.memory/`. Keep active task notes in `.tickets/`.

## Start A Task

1. Send the user request to the architect.
2. Ask the architect to create or update tickets.
3. Complete the `Backlog -> Ready` handoff gate before marking a ticket `Ready`.
4. Review open questions with the user only when needed.
5. If a ticket includes UI/UX work, complete `Ready -> Design`, route it through the designer, then complete `Design -> Ready`.
6. Select one `Ready` ticket for execution.

For multi-step implementation work, the architect should also create or link an implementation plan under `docs/agent-plans/`. Tickets can represent the executable slices of that plan.

The architect must fill in `Skill Context` before execution starts, including role-specific skills or `None` where no skill applies. External skill families are optional unless the ticket, user, imported registry, or project instructions require them.

Skill selection comes from `.skills/registry.md`, `.skills/principles.md`, project instructions, and user-provided custom skills. Assign skills per role so each subagent reads only what it needs.

## Design A UI Ticket

Use the designer only when a ticket changes screens, flows, visual hierarchy, interaction design, accessibility, or frontend polish.

1. Spawn the designer with the Designer model and effort from `.agents/models.md`.
2. Escalate according to `.agents/models.md` when the ticket involves important product decisions, broad workflow design, brand-sensitive UI, or major design-system changes.
3. Give the designer the ticket, relevant existing UI files, design-system context, target platform, and constraints.
4. Ask the designer to update the ticket's `Designer Review` and `Design Brief` sections.
5. Move the ticket to execution only after the `Design -> Ready` handoff gate is complete.

## Execute A Ticket

1. Spawn the executor with the Executor model and effort from `.agents/models.md`.
2. Escalate Executor according to `.agents/models.md` when the ticket's complexity, ambiguity, or risk requires it.
3. Assign exactly one ticket unless the tickets share the same files and scope.
4. Tell the executor which files or modules it owns.
5. Provide exact context in the prompt: ticket text, relevant files, relevant memory entries, `Skill Context`, acceptance criteria, and expected verification.
6. For behavior changes, require red/green TDD evidence unless TDD is explicitly waived in the ticket.
7. Complete the `Ready -> In Progress` handoff gate before Executor starts.
8. When implementation returns, inspect the changed files and complete `In Progress -> Review` before review.

## Review A Ticket

1. Spawn or assign the reviewer with the Reviewer model and effort from `.agents/models.md` after implementation.
2. Give the reviewer the ticket path and the diff context.
3. Run spec compliance review first.
4. Run code quality review only after spec compliance is satisfied.
5. If the reviewer recommends `Needs Changes`, create a fix ticket or return the same ticket to the executor.
6. If the reviewer recommends `Ready For Test`, complete `Review -> Test` before moving the ticket to `Test`.

## Test A Ticket

1. Spawn or assign the tester with the Tester model and effort from `.agents/models.md` after review.
2. Give the tester the ticket path and expected verification scope.
3. Require fresh command output or documented manual-check evidence before accepting a pass.
4. If verification passes, complete `Test -> Done` before moving the ticket to `Done`.
5. If verification fails, move it back to `In Progress` or create a follow-up ticket.

## Parallel Work

Parallelize only when tickets have disjoint ownership.

Good parallel splits:

- Frontend component and backend endpoint in separate files.
- Documentation update and test harness work.
- Independent investigations into separate subsystems.

Avoid parallel splits when:

- Multiple agents need to edit the same file.
- The executor depends on the architect's unresolved decision.
- The tester needs implementation details that do not exist yet.
- Review has not completed for a ticket that the next ticket depends on.

## Queue Hygiene

- Keep `.tickets/queue.md` aligned with each ticket file's `State`.
- Keep old notes; append new dated or role-labeled entries.
- Move blocked work to `Blocked` with the exact blocker.
- Prefer creating follow-up tickets over expanding a ticket after execution starts.
- Promote only durable, verified project knowledge from tickets into `.memory/`.

## Completion Standard

A ticket is complete when:

- Acceptance criteria are met.
- Role-specific skills in `Skill Context` were used or explicitly waived.
- Spec compliance review is complete or intentionally waived.
- Code quality review is complete or intentionally waived.
- Verification is complete with fresh evidence, or the reason it cannot run is documented.
- Follow-up work is captured as separate tickets.
