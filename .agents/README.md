# Agent Workflow

Portable role prompts and contracts, not a runtime implementation.

## Start Here

Read runtime-modes.md and explicitly select enforced or portable mode before
dispatch. Official Codex/ChatGPT can use portable independent reports when
authenticated runner records are unavailable. Never silently downgrade a failed
enforced gate or call portable reports runtime proof. Architect is orchestration-
only; Executor self-review never replaces independent Reviewer and Tester.

## Sources

- architect.md: inspect, plan, manage tickets and delegate.
- designer.md: optional UI/UX guidance.
- executor.md: implement one assigned Ready ticket.
- reviewer.md: independent spec compliance then quality review.
- tester.md: independent fresh verification.
- models.md: sole machine-readable role assignment table and provider boundary.
- prompts.md: compact dispatch prompts and optional read-only advisory roles.
- runbook.md: ownership, bounded corrections, integration and completion order.
- handoff.md: process gates; handoff-evidence.md: supplied-record policy schema.
- runtime-modes.md: capabilities, portable frozen targets, Pi adapter gaps.
- ../.skills/registry.md and principles.md: role-specific skill routing/practices.
- ../.memory/: durable verified knowledge, not active task state.

## Flow

Architect plans -> optional Designer -> Executor -> independent Reviewer ->
optional Second Reviewer -> independent Tester -> required integration ->
mode-specific acceptance/completion. Keep handoffs continuous within the ticket,
bounded by two correction rounds, repeated unchanged failure, or a real blocker.
Completion does not automatically start another ticket.

Classify read-only versus mutating/building. Use isolated worktrees and one
repository-external artifact root per ticket where available; otherwise grant
one serialized mutable owner. All roles and retries reuse that root. Review a
real immutable commit, or explicitly portable frozen content-sha256 target when
committing is not authorized. Include untracked files and pre/post fingerprints.
Never review a moving shared tree or invent a commit SHA.

The runner alone creates evidence and completes enforced tickets. Portable mode
uses disclosed independent reports and authorized manual acceptance. Missing
independent sessions blocks both modes. Required integration precedes completion
and cleanup; retain failed/blocked artifacts.

## Coordination

- Use the model table; new optional fields require model-routing-v2. Old Pi
  ignores these fields and is not claimed to enforce v2.
- Record configured versus observed actual model/effort, selection reasons,
  elapsed time, rounds, findings and tokens; unknown telemetry is Unavailable.
- Workers do not edit active tickets or runner evidence. The board owner keeps
  tickets/queue authoritative and regenerates projections after mutations.
- Use only assigned skills. Host-wide leases apply only when a selected platform
  skill requires one, and only around its contended command.
- Prefer fresh subagent context, live supervisor contact, background dispatch,
  allowed-agent restrictions and disjoint parallel read-only work when exposed.
  Missing context/capability is NEEDS_CONTEXT or BLOCKED, never guessed proof.
