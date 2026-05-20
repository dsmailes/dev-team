# Agent Workflow

This directory defines reusable role prompts for coordinating subagents on larger tasks.

## Roles

- `architect.md`: plans work, interrogates requirements, and maintains tickets.
- `designer.md`: optionally shapes UI/UX tickets before implementation.
- `executor.md`: implements one ready ticket at a time.
- `reviewer.md`: reviews executor changes against the ticket.
- `tester.md`: verifies behavior and reports coverage gaps.
- `models.md`: project-local model/provider choices for each role.
- `prompts.md`: spawn prompts for each role.
- `runbook.md`: orchestration flow for the full loop.
- `handoff.md`: required gates for moving tickets between roles and states.
- `../.skills/registry.md`: skill routing by language, framework, platform, and task type.
- `../.skills/principles.md`: reusable engineering and handoff practices.
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

## Model Configuration

Use `.agents/models.md` as the source of truth for model names, effort levels, and provider-specific mappings.

The packaged default is a Codex profile that uses Spark for routine execution and stronger reasoning models for architecture, review, and high-risk work. Project installs may replace this with exact local model IDs or inferred provider-class placeholders.

## Coordination Rules

- Only the orchestrator assigns tickets.
- The orchestrator may not move a ticket to the next state until the relevant handoff gate in `.agents/handoff.md` is complete or explicitly waived in the ticket.
- Agents should not edit the same files in parallel unless the orchestrator explicitly coordinates the overlap.
- Agents should use only the role-relevant skills assigned in the ticket's `Skill Context`.
- Ticket updates should preserve previous notes instead of replacing them.
- Durable verified learnings should be promoted to `.memory/`; active task notes stay in `.tickets/`.
- A ticket is not `Done` until review and verification have both been handled or intentionally waived.
