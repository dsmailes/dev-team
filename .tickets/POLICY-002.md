# POLICY-002

## ID

`POLICY-002`

## Title

Make workflow gates executable and portable across Codex and Pi

## State

`Test`

## Problem

The audit found nominal conformance tests, unspecified runner dependencies,
inconsistent model routing, installer customization loss and seeded project state,
and completion ordered before integration.

## Scope

Fix installer regressions; define enforced and portable operation; validate real
handoff fixtures; make model candidates and efforts explicit; reduce redundant
context; bound correction loops and record available cost telemetry.

## Out Of Scope

Changing default role models to Astra, implementing Pi session enforcement here,
changing unrelated active tickets, or publishing a Pi release.

## Acceptance Criteria

- Fresh installs contain a clean board and memory; updates preserve user state.
- Interactive model customization survives generation and has a regression test.
- Positive and negative handoff fixtures execute against a reference validator.
- Official harnesses remain provider-local; custom runtimes may cross providers.
- Portable operation is explicit and never claims runner-authenticated evidence.
- Integration precedes completion; retry limits and unavailable telemetry are clear.
- Existing Pi model parser continues to read legacy columns; unsupported extensions
  are documented rather than claimed to be runtime-enforced.

## Questioning Notes

- Context inspected: audit, installer, role docs, tests, adjacent Pi model parser.
- Chosen approach: additive portable contract with executable reference checks.
- Blocking questions: None.
- Assumptions: keep Pi-owned enforcement in dev-team-pi; no silent mode downgrade.

## Likely Files

- install.sh, tests/, scripts/, .agents/, .tickets/template.md, README.md

## Risks

- Old adapters may ignore new model columns. Preserve legacy columns and document
  capability requirements. Never represent a reference checker as a trust boundary.

## Rollback And Persistence

- Workflow files only; installation tests use temporary targets.
- Existing project tickets, memory, and customized models stay untouched on update.
- Rollback: revert scoped changes after review.

## Workspace And Integration Contract

- Ticket classification: `mutating/building`.
- Execution mode: `serialized`.
- Executor worktree: /Volumes/512SSD/GitHub/dev-team
- Ticket-scoped artifact root: /tmp/dev-team-POLICY-002
- Integration batch: Not applicable; single serialized ticket.
- Verification target: final diff fingerprint until a scoped commit is authorized.

## Skill Context

- Task type: workflow policy, installer, conformance validation.
- Required skills: None.
- Optional skills: agent-workflow-audit (audit already completed).

## Execution Model

- Executor routing: `routine`.
- Tester routing: `routine`.
- Runtime: official Codex, provider-local; child model inherited from current session.
- Assignment deviation: user-requested Astra assessment; inherited tool default.

## Designer Review

- Required: `No`.

## Runtime Mode

- Mode: `portable`, explicitly selected for this session because authenticated
  role evidence and a runner completion operation are not exposed.
- Independent child sessions are available. Model choice is inherited; actual
  model, effort and token telemetry are Unavailable, not asserted from config.
- No enforced runtime gate is downgraded or represented as passed.
- Stable source target: `content-sha256`
  `8bcb2e74cbf8cba4289c0063398b449e91ccdc0c1ca97665c1d5b35a9422ed44`.
- Target command: `python3 -B scripts/check-workflow-policy.py --fingerprint /Volumes/512SSD/GitHub/dev-team --ticket-id POLICY-002`.
- Frozen scope: this ticket's original acceptance criteria and linked plan; source
  changes require a new target and review. Only live board/report metadata may
  change during review. No pre-commit fingerprint is described as a commit SHA.

## Second Review

- Required: `Not required`.

## TDD Plan

- Add regression inputs for observed installer failures and invalid evidence chains.
- Verify rejection conditions and fresh installation/update behavior.

## Verification Plan

- python3 tests/test-handoff-conformance.py
- sh tests/test-install.sh
- Fresh --project and --here installs plus dashboard validation.
- Read-only compatibility smoke using adjacent Pi model parser.
- Independent review and testing of the final diff.

## Role Handoff Evidence

Unavailable: this session exposes subagents but no authenticated handoff ledger or
completion operation. Do not fabricate records. Keep runtime evidence separate
from review reports and do not claim an enforced Done transition.

## Agent Run Summary

- Architect: current session; model/effort and tokens not independently exposed.
- Installer Executor: Plato (`01a09206-126a-7d30-a140-f92ecd536f0f`), inherited
  model/effort; actual model and tokens Unavailable. Completed and closed.
- Compatibility advisor: Kant (`01a09206-6ea3-7351-851b-0048295ab06e`), read-only
  Pi source inspection. Actual model/effort/tokens Unavailable. Completed and closed.
- Contract Executor: Hubble (`01a09208-b48d-7100-bc84-f6cd9f549709`), inherited
  model/effort; actual model and tokens Unavailable. Completed and closed.
- Reviewer: Turing (`01a0921e-27e6-7653-aac5-4437d29a099f`), independent session;
  actual model, effort and tokens Unavailable. Passed re-review and closed.
- Tester: Pauli (`01a0922a-9a2b-7393-b364-e5579882530b`), independent session;
  configured Terra/medium, actual inherited model/effort/tokens Unavailable.
  Passed final verification and closed.

## Implementation Notes

- Plan: docs/agent-plans/POLICY-002.md.
- Executor Plato owns installer regression fixes; Architect remains read-only
  outside planning and ticket management. Read-only Pi compatibility inspection
  delegated to Kant. No runtime-authenticated evidence is available.
- Installer slice completed: preserved interactive choices, clean starter board
  and memory, PTY and isolation/update regression tests. Executor reports installer,
  interactive, shell syntax, and whitespace tests passing. Ownership transferred
  to Hubble for remaining contract/schema/documentation work.
- Pi source inspection confirmed legacy model columns remain readable, but new
  candidate efforts, provider boundaries, second review and integration-before-
  completion require adapter support. New upstream docs must state these limits.
- Hubble completed contract/schema/prompt changes and released mutation ownership.
  Reported passing conformance (13 tests and JSON vectors), actual Pi parser smoke,
  installer suite, five interactive tests, and whitespace checks. These are
  Executor reports, not authenticated handoff evidence. Source frozen for review.

## Review Notes

- Independent Reviewer Turing checked frozen target `1704c14d7407ee1a68c1d23f3b3eb78f4f55e9dc815fd466fd598a22488d5770` before/after and returned `NeedsChanges`.
- P1: canonical runtime model IDs fail literal alias matching.
- P2: malformed nonboolean judgment metadata permits economy routing.
- P2: unreadable source directories can be silently omitted from fingerprints.
- No other actionable findings in docs, handoff chain, complete JSON fixtures,
  installer preservation, or generated model parity. No broad suites rerun.
- Correction round: `1` of default maximum `2`. Hubble owns only these fixes;
  the previous source target is no longer accepted for final review.
- Hubble completed round 1 and released mutation ownership. Reported 18 passing
  conformance tests, real permission regressions without skips, corrected original
  reviewer probes, and a clean whitespace check. Updated source target above is
  frozen for independent re-review. No source changes are currently authorized.
- Turing independently re-reviewed target `8bcb2e74cbf8cba4289c0063398b449e91ccdc0c1ca97665c1d5b35a9422ed44` before/after. Verdict: `ReadyForTest`, no remaining findings.
- Original alias, malformed-boolean, and permission-error reproductions now pass
  their intended acceptance/rejection checks. Narrow provider/effort/duplicate-
  identity/capability bypass probes also reject. Prior unchanged-surface review
  remains applicable. This is portable independent review, not runtime evidence.

## Test Notes

- Pauli independently verified the final source target before and after testing:
  `8bcb2e74cbf8cba4289c0063398b449e91ccdc0c1ca97665c1d5b35a9422ed44`.
- `python3 -B tests/test-handoff-conformance.py --pi-project /Volumes/512SSD/GitHub/dev-team-pi`: 18 tests and 18 executable fixture vectors passed; actual Pi parser legacy parity passed.
- `sh tests/test-install.sh`: full preservation/clean-board/generator suite passed,
  including nested conformance and five PTY tests. No separate PTY rerun needed.
- Explicit fresh `--project` and `--here` installs with `--no-import-skills
  --no-model-prompt` passed; both installed dashboards validated. Each target had
  only three starter ticket files and five starter memory files, with no source
  development tickets or private memory. Installed checker/modules/mode docs
  matched source.
- Root dashboard validation, shell syntax for both shell files, and whitespace
  checks passed. No failures or skipped tests. Pi status was unchanged.
- Logs and smoke targets: `/tmp/dev-team-POLICY-002/tester-final.iMreFs`.
- Reported durations: conformance 2.154s; nested conformance 1.613s; PTY 0.850s.
  Whole-ticket elapsed time and tokens: Unavailable.

## Completion Status

Implementation, independent review and independent testing are complete. Retain
`Test` pending authorized completion; this session has no trusted completion
operation and does not fabricate an enforced `Done` transition. All acceptance
results above are explicitly portable reports, not authenticated runner evidence.

- Integration: Not applicable; one serialized ticket, no merged batch. Final
  package verification ran against the same source target as independent review.
- Memory updates: None; reusable verification guidance is in README and role docs.
- Cleanup: no ticket branches or worktrees created. Keep external review repros
  and final verification logs for audit; temporary test fixtures self-cleaned.
- Follow-up ownership: Pi adoption checklist is in `.agents/runtime-modes.md`.
  Pi code and vendored snapshot remain unchanged; parser parity is not v2 runtime
  conformance. No commits or pushes were performed.
