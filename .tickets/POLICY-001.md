# POLICY-001

## ID

`POLICY-001`

## Title

Define portable runtime handoff evidence contract.

## State

`In Progress`

## Problem

The portable workflow describes role handoffs, but it permits agent-authored prose to stand in for runtime identity and verification evidence. Runners therefore cannot consistently reject self-review, stale commits, reused sessions, model mismatches, or direct completion moves.

## Scope

- Define the portable role boundary, evidence schema, model-assignment schema, transition gates, role prompts, and runner-neutral conformance fixtures.

## Acceptance Criteria

- The workflow satisfies all eight Dev Team Upstream Requirements supplied with this ticket.

## Risks

- Documentation could imply runner enforcement without identifying the runner-owned boundary.

## Verification Plan

- Run `sh tests/test-install.sh` and `python3 scripts/render-ticket-dashboard.py --validate`.

## Skill Context

- Language: Markdown, POSIX shell, Python.
- Required skills:
  - Architect: `agent-workflow-audit`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`

## Handoff Gates

### Ready -> In Progress

- [x] Executor owner and verification plan are recorded.
