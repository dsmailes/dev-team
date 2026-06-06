# Multi-Agent Runbook

This runbook describes how to run the architect, executor, reviewer, and tester loop.

Read `.agents/handoff.md` before moving any ticket between states.

The orchestrator may not move a ticket to the next state until that transition's handoff gate is complete or explicitly waived with a reason in the ticket.

Use `.agents/models.md` as the source of truth for model names and effort levels when spawning each role.

Use runtime capabilities opportunistically. When available, prefer fresh-context subagents, live supervisor contact for blocking questions, background execution for long-running tasks, and an allowed-agent list that matches this workflow. When unavailable, use ticket status and explicit handoff reports instead.

## Read Project Memory

Before planning or execution, read `.memory/` when present:

- `project.md` for orientation.
- `commands.md` before running setup, build, lint, test, or run commands.
- `decisions.md` before proposing architecture changes.
- `pitfalls.md` before debugging or changing fragile areas.

Only write durable verified knowledge to `.memory/`. Keep active task notes in `.tickets/`.

## Start A Task

1. Send the user request to the architect.
2. Ask the architect to inspect project context before asking the user anything.
3. Ask the architect to sketch the decision tree and identify upstream decisions that change downstream scope.
4. Ask the architect to classify unknowns as `Blocking`, `Assumable`, or `Deferred`.
5. Review the highest-leverage upstream blocking question with the user before implementation. The architect should ask one focused question at a time and include a recommended answer.
6. Ask the architect to create or update tickets only after blocking questions are resolved or explicitly waived.
7. Complete the `Backlog -> Ready` handoff gate before marking a ticket `Ready`.
8. If a ticket includes UI/UX work, complete `Ready -> Design`, route it through the designer, then complete `Design -> Ready`.
9. Select one `Ready` ticket for execution.

For multi-step implementation work, the architect should also create or link an implementation plan under `docs/agent-plans/`. Tickets can represent the executable slices of that plan.

The architect must fill in `Skill Context` before execution starts, including role-specific skills or `None` where no skill applies. External skill families are optional unless the ticket, user, imported registry, or project instructions require them.

The architect must fill in `Execution Model` before execution starts. Executor defaults to `gpt-5.3-codex-spark` with `high` effort. Escalation requires a specific recorded reason.

The architect must also fill in `Questioning Notes` before execution starts, including the decision tree. A ticket with unresolved `Blocking` questions cannot move to `Ready` unless the gate includes an explicit waiver and reason.

Skill selection comes from `.skills/registry.md`, `.skills/principles.md`, project instructions, and user-provided custom skills. Assign skills per role so each subagent reads only what it needs.

## Design A UI Ticket

Use the designer only when a ticket changes screens, flows, visual hierarchy, interaction design, accessibility, or frontend polish.

1. Spawn the designer with the Designer model and effort from `.agents/models.md`.
2. Escalate according to `.agents/models.md` when the ticket involves important product decisions, broad workflow design, brand-sensitive UI, or major design-system changes.
3. Give the designer the ticket, relevant existing UI files, design-system context, target platform, and constraints.
4. Ask the designer to update the ticket's `Designer Review` and `Design Brief` sections.
5. Move the ticket to execution only after the `Design -> Ready` handoff gate is complete.

## Execute A Ticket

1. Spawn the executor with `gpt-5.3-codex-spark` and `high` effort by default.
2. Escalate Executor only when a recorded trigger applies: Spark is unavailable, the ticket crosses architecture boundaries, the work is high-risk data/security/concurrency/migration logic, debugging remains blocked after reproduction, or Spark reports `NEEDS_CONTEXT` / `BLOCKED` and more reasoning is required.
3. Do not escalate only because a ticket touches multiple files or ordinary integration code.
4. If Spark is unavailable, use the nearest available fast coding model and record the fallback in `Execution Model`.
5. Assign exactly one ticket unless the tickets share the same files and scope.
6. Tell the executor which files or modules it owns.
7. Provide exact context in the prompt: ticket text, relevant files, relevant memory entries, `Skill Context`, `Execution Model`, acceptance criteria, and expected verification.
8. If the runtime supports fresh subagent context, use it. Do not rely on inherited conversation history.
9. If the runtime supports live supervisor contact, allow Executor to ask the orchestrator blocking questions. Otherwise require `NEEDS_CONTEXT` or `BLOCKED` in the completion report.
10. For behavior changes, require red/green TDD evidence unless TDD is explicitly waived in the ticket.
11. Complete the `Ready -> In Progress` handoff gate before Executor starts.
12. When implementation returns, inspect the changed files and complete `In Progress -> Review` before review.

## Review A Ticket

1. Spawn or assign the reviewer with the Reviewer model and effort from `.agents/models.md` after implementation.
2. Give the reviewer the ticket path and the diff context.
3. If the runtime supports live supervisor contact, allow Reviewer to ask for missing ticket or diff context. Otherwise require `NEEDS_CONTEXT` or `BLOCKED`.
4. Run spec compliance review first.
5. Run code quality review only after spec compliance is satisfied.
6. If the reviewer recommends `Needs Changes`, create a fix ticket or return the same ticket to the executor.
7. If the reviewer recommends `Ready For Test`, complete `Review -> Test` before moving the ticket to `Test`.

## Test A Ticket

1. Spawn or assign the tester with the Tester model and effort from `.agents/models.md` after review.
2. Give the tester the ticket path and expected verification scope.
3. If the runtime supports live supervisor contact, allow Tester to ask for missing environment, command, or verification scope decisions. Otherwise require `NEEDS_CONTEXT` or `BLOCKED`.
4. Require fresh command output or documented manual-check evidence before accepting a pass.
5. If verification passes, complete `Test -> Done` before moving the ticket to `Done`.
6. If verification fails, move it back to `In Progress` or create a follow-up ticket.

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
- After ticket creation or queue changes, offer to run `python3 scripts/render-ticket-dashboard.py` and display or link `docs/tickets.html` when local display is available. In Codex remote or ChatGPT surfaces, display or summarize `docs/tickets.md`.
- Once the user accepts, requests, or appears to be using the dashboard, refresh both generated files after every later ticket or queue update in that workflow before reporting status.
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
