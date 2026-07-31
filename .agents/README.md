# Agent Workflow

This directory defines reusable role prompts for coordinating subagents on larger tasks.

## Roles

- `architect.md`: plans work, interrogates requirements, and maintains tickets.
- `designer.md`: optionally shapes UI/UX tickets before implementation.
- `executor.md`: implements one ready ticket at a time.
- `reviewer.md`: reviews executor changes against the ticket.
- `tester.md`: verifies behavior and reports coverage gaps.
- Optional advisory subagents (`librarian`, `oracle`, `contrarian`, `web-scout`): read-only research and second-opinion helpers the architect may use before ticket creation or the reviewer may use for high-risk findings. See "Optional Advisory Subagents" in `.agents/architect.md`.
- `models.md`: project-local model/provider choices for each role.
- `prompts.md`: spawn prompts for each role.
- `runbook.md`: orchestration flow for the full loop.
- `handoff.md`: required gates for moving tickets between roles and states.
- `handoff-evidence.md`: runner-generated evidence schema and protected transition rules.
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

Steps 5-8 run as one continuous loop for the selected ticket: the orchestrator does not stop to check in with the user between Executor, Reviewer, Second Reviewer, and Tester handoffs, and treats `Needs Changes` or a `Fail` verdict as an in-loop correction rather than a stopping point. See "Continuous Execution Within A Ticket" in `.agents/runbook.md` for the exact stop/continue rules. Ticket completion does not by itself trigger the next `Ready` ticket; the orchestrator reports completion and waits for direction unless project instructions say otherwise.

For concurrent work, the orchestrator records `isolated` or `serialized` execution mode before mutation or builds begin. Isolated mutating/building tickets use separate branch/worktree and artifact roots; serialized mode grants the shared worktree to one mutable ticket at a time. Reviewer and Tester use a clean verification worktree at the executor's recorded ticket commit. The orchestrator runs the full integration matrix once per merged integration batch, then performs non-destructive workspace cleanup after evidence capture.

Some selected platform skills may identify a host-wide resource even when source and artifact roots are isolated. In that case, use the installed `scripts/with-host-resource-lease.sh` helper only around the contended command, record the lease in the ticket, and leave unrelated work parallel. Apple Xcode/CoreSimulator guidance belongs to the Apple platform routing, not to every project.

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
- `concurrent-dispatch`: spawn multiple independent subagents from a single dispatch instead of one call per agent, when tickets have disjoint ownership (see "Parallel Work" in `.agents/runbook.md`).

If live supervisor contact is available, subagents should use it for blocking questions. If it is not available, they must stop and report `NEEDS_CONTEXT` or `BLOCKED` with the smallest missing decision. A blocking question answered through live supervisor contact is an escalation within the same run, not a terminal stop; resume the loop once it is answered.

## Model Configuration

Use `.agents/models.md` as the machine-readable source of truth for preferred and fallback provider, model, and effort assignments. Use `.agents/handoff-evidence.md` for runner-owned proof of the actual role run.

The packaged default uses Terra with medium effort for routine architecture,
product/design shaping, implementation, and testing. Primary review prefers
Anthropic Sonnet 4.6 at medium effort when permitted. Explicit economy routing
uses Luna medium for mechanical Executor work and deterministic Tester commands;
missing or ambiguous routing remains routine. Sol and the high-effort second
reviewer remain explicit exceptional paths.

## Coordination Rules

- Only the orchestrator assigns tickets. In normal mode, the Architect orchestrates only and cannot implement, review, test, or mark its own work `Done`.
- The orchestrator may not move a ticket to the next state until the relevant handoff gate in `.agents/handoff.md` is complete or explicitly waived in the ticket.
- Agents should not edit the same files in parallel unless the orchestrator explicitly coordinates the overlap.
- Agents should use only the role-relevant skills assigned in the ticket's `Skill Context`.
- Ticket updates should preserve previous notes instead of replacing them.
- Completed tickets must include an `Agent Run Summary` for every role that ran: agent or task identity, actual model, effort, and token usage when available. Use `Unavailable` rather than estimating unavailable telemetry, and announce the summary in the final handoff.
- Durable verified learnings should be promoted to `.memory/`; active task notes stay in `.tickets/`.
- A ticket is not `Done` until the runner completion operation validates passing Executor, independent Reviewer, and independent Tester evidence for the same executor commit. Generic state editing cannot bypass this gate.
- A concurrent ticket is not `Done` until its focused ticket-commit evidence and its integration-batch evidence are attached or explicitly waived with a risk-based reason.
