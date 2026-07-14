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
3. The designer shapes UI/UX tickets in the `Design` state when `Designer Review` is required, then returns them to `Ready`.
4. The orchestrator selects a `Ready` ticket.
5. The executor implements the ticket.
6. The reviewer checks the diff and recommends `Ready For Test` or `Needs Changes`.
7. The tester verifies the ticket.
8. The orchestrator moves the ticket to `Done` or creates follow-up tickets.

For concurrent work, the orchestrator records `isolated` or `serialized` execution mode before mutation or builds begin. Isolated mutating/building tickets use separate branch/worktree and artifact roots; serialized mode grants the shared worktree to one mutable ticket at a time. Reviewer and Tester use a clean verification worktree at the executor's recorded ticket commit. The orchestrator runs the full integration matrix once per merged integration batch, then performs non-destructive workspace cleanup after evidence capture.

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

## Runtime Capabilities

This pack is portable and does not require a specific subagent runtime. If the active runtime provides these capabilities, the orchestrator may use them:

- `subagent-dispatch`: spawn role-specific agents from the current workflow.
- `fresh-subagent-context`: start each subagent with only the ticket and explicit context it needs.
- `supervisor-contact`: let a subagent ask the orchestrator a blocking question while work is in progress.
- `background-subagents`: run long subagent tasks while the orchestrator remains available for decisions.
- `allowed-agent-list`: restrict delegation to the roles defined by this workflow and project instructions.

If live supervisor contact is available, subagents should use it for blocking questions. If it is not available, they must stop and report `NEEDS_CONTEXT` or `BLOCKED` with the smallest missing decision.

## Model Configuration

Use `.agents/models.md` as the source of truth for model names, effort levels, and provider-specific mappings.

The packaged default is a Codex profile that uses Sol for architecture and product/design shaping, Terra for implementation, GPT-5.5 for independent review, and Luna with high effort for testing. Project installs may replace this with exact local model IDs or inferred provider-class placeholders.

## Coordination Rules

- Only the orchestrator assigns tickets.
- The orchestrator may not move a ticket to the next state until the relevant handoff gate in `.agents/handoff.md` is complete or explicitly waived in the ticket.
- Agents should not edit the same files in parallel unless the orchestrator explicitly coordinates the overlap.
- Concurrent implementation tickets must use dedicated branches and worktrees. Reviewer and Tester verify the ticket's recorded commit SHA in that worktree; merge ticket commits into an integration branch for the full integration matrix before main.
- Agents should use only the role-relevant skills assigned in the ticket's `Skill Context`.
- Ticket updates should preserve previous notes instead of replacing them.
- Completed tickets must include an `Agent Run Summary` for every role that ran: agent or task identity, actual model, effort, and token usage when available. Use `Unavailable` rather than estimating unavailable telemetry, and announce the summary in the final handoff.
- Durable verified learnings should be promoted to `.memory/`; active task notes stay in `.tickets/`.
- A ticket is not `Done` until review and verification have both been handled or intentionally waived.
- A concurrent ticket is not `Done` until its focused ticket-commit evidence and its integration-batch evidence are attached or explicitly waived with a risk-based reason.
