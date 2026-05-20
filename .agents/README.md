# Agent Workflow

This directory defines reusable role prompts for coordinating subagents on larger tasks.

## Roles

- `architect.md`: plans work, interrogates requirements, and maintains tickets.
- `designer.md`: optionally shapes UI/UX tickets before implementation.
- `executor.md`: implements one ready ticket at a time.
- `reviewer.md`: reviews executor changes against the ticket.
- `tester.md`: verifies behavior and reports coverage gaps.
- `prompts.md`: spawn prompts for each role.
- `runbook.md`: orchestration flow for the full loop.
- `handoff.md`: required gates for moving tickets between roles and states.
- `../.skills/registry.md`: skill routing by language, framework, platform, and task type.
- `../.skills/principles.md`: reusable practices borrowed from Axiom, PFW, Superpowers, and workflow audit guidance.
- `../.memory/`: durable project knowledge such as verified commands, decisions, and pitfalls.

## Default Flow

1. The orchestrator gives the user request to the architect.
2. The architect writes or updates tickets in `.tickets/`.
3. The designer shapes UI/UX tickets when `Designer Review` is required.
4. The orchestrator selects a `Ready` ticket.
5. The executor implements the ticket.
6. The reviewer checks the diff and recommends `Ready For Test` or `Needs Changes`.
7. The tester verifies the ticket.
8. The orchestrator moves the ticket to `Done` or creates follow-up tickets.

## Handoff Contract

Each handoff should include:

- Ticket ID
- Current state
- Relevant files
- Relevant memory entries
- Skill Context
- Acceptance criteria
- Known risks
- Expected output from the receiving role

## Model Defaults

- Architect: `gpt-5.5`, `high`.
- Designer: `gpt-5.4`, `high`; use `gpt-5.5`, `high` for important product/UI decisions.
- Executor: `gpt-5.3-codex-spark`, `high` by default; escalate to `gpt-5.3-codex`, `gpt-5.4`, or `gpt-5.5` as complexity and risk increase.
- Reviewer: `gpt-5.5`, `high`.
- Tester: `gpt-5.4`, `medium`; raise to `high` for flaky tests or complex async/UI issues.

## Coordination Rules

- Only the orchestrator assigns tickets.
- The orchestrator may not move a ticket to the next state until the relevant handoff gate in `.agents/handoff.md` is complete or explicitly waived in the ticket.
- Agents should not edit the same files in parallel unless the orchestrator explicitly coordinates the overlap.
- Agents should use only the role-relevant skills assigned in the ticket's `Skill Context`.
- Ticket updates should preserve previous notes instead of replacing them.
- Durable verified learnings should be promoted to `.memory/`; active task notes stay in `.tickets/`.
- A ticket is not `Done` until review and verification have both been handled or intentionally waived.
