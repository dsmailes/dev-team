# SAFE-001

## ID

`SAFE-001`

## Title

Harden installer updates and reset behavior.

## State

`Done`

## Problem

The installer previously directed existing installations toward `--force`, even though that path could delete user-owned tickets, memory, and model configuration.

## Scope

- Make `--update` the safe refresh path for detected installations.
- Require an explicit, confirmed, backed-up reset command for destructive state replacement.
- Add a dry-run plan and update-preservation regression coverage.
- Restore the `Design` lifecycle state in ticket dashboard materials.

## Out Of Scope

- Automatically migrating custom model configurations.
- Changing the ticket file format beyond lifecycle documentation.

## Acceptance Criteria

- Existing installations direct users to `--update` rather than `--force`.
- Reset requires `--reset-project-state --force`, prints affected paths, confirms interactively, and backs up project state.
- `--dry-run` reports the selected operation without writing files.
- A regression test proves plain `--update` preserves custom tickets, queue, memory, and model configuration.
- `Design` is recognized by dashboard validation and documented in the lifecycle.

## Questioning Notes

- Context inspected: installer, update documentation, ticket dashboard parser, and local ticket workflow.
- Decision tree: preserve project state for ordinary refreshes; isolate destructive replacement behind an unmistakable command; use an executable regression test for the preservation contract.
- Blocking questions: None.
- Assumptions: interactive confirmation is preferable to permitting non-interactive destructive reset.
- Deferred questions: Automatic migration of old packaged model defaults can be considered in a future ticket.
- Approaches considered: keep `--force` as broad overwrite; make `--force` safe but ambiguous; reserve it as a required reset interlock.
- Chosen approach: reserve `--force` for the explicit reset command and document intentional model replacement via `--update --models-provider codex`.
- Rejected alternatives: broad `--force` remains too easy to invoke accidentally.

## Likely Files

- `install.sh`
- `README.md`
- `.tickets/README.md`
- `scripts/render-ticket-dashboard.py`
- `tests/test-install.sh`

## Risks

- Reset confirmation must not permit non-interactive state deletion.
- Update behavior must keep custom project files untouched.

## Rollback And Persistence

- Persistent changes: installer command contract and workflow documentation.
- User-owned configuration touched: only explicit reset removes it after backup and confirmation.
- Idempotency expectation: repeated `--update` runs preserve project-owned state.
- Rollback or undo path: use the timestamped reset backup or revert the installer commit.

## Skill Context

- Language: POSIX shell, Python, Markdown.
- Framework: None.
- Platform: Local workflow pack.
- Project type: Installer and workflow tooling.
- Task type: Safety hardening and regression testing.
- Required skills:
  - Architect: `None`
  - Designer: `None`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`
- Optional skills: `None`
- Design tooling:
  - Required: `No`
  - Capabilities: `None`
  - Source: `None`
  - Notes: `None`
- Custom skill notes: `None`

## Execution Model

- Executor model: `terra`
- Executor effort: `high`
- Escalation needed: `No`
- Escalation model: None.
- Escalation reason: None.
- Terra unavailable fallback: Use the nearest available balanced coding model.
- Model actually used: `terra`

## Designer Review

- Required: `No`
- Reason: Installer and documentation workflow only.
- Preferred model: See `.agents/models.md`.
- Preferred effort: See `.agents/models.md`.
- Design tooling needed: None.
- Output needed: None.

## TDD Plan

- Failing test: An update-preservation test would fail against the destructive `--force` guidance and missing Design state.
- Expected failure: Custom project state changes or dashboard validation rejects `Design`.
- Minimal implementation: Add safe installer branches and lifecycle state support.
- Passing verification: Run the installer regression test and fresh installer checks.
- TDD waiver, if any: None.

## Verification Plan

- Run `sh tests/test-install.sh`.
- Run fresh explicit-path and `--here` installs, then validate their dashboards.
- Run the dashboard validation in this repository.

## Handoff Gates

### Backlog -> Ready

- [x] Problem is clear.
- [x] Scope and out-of-scope are written.
- [x] Acceptance criteria are written.
- [x] `Questioning Notes` is filled.
- [x] Blocking questions are answered, waived with a reason, or moved to `Blocked`.
- [x] Likely files or modules are listed.
- [x] Risks are listed.
- [x] Rollback and persistence impact is documented.
- [x] `Skill Context` is filled.
- [x] `Execution Model` is filled.
- [x] Verification plan exists.
- [x] `Designer Review` is marked `No`.
- [x] TDD plan exists.
- Waiver: None.

### Ready -> In Progress

- [x] Executor owner is assigned.
- [x] Executor model and effort are stated.
- [x] Executor escalation reason is stated.
- [x] Relevant files are listed.
- [x] Relevant memory entries are listed or marked `None`.
- [x] Acceptance criteria are referenced.
- [x] Expected executor output is stated: safe installer behavior and regression coverage.
- [x] Verification command is stated.
- Waiver: None.

### In Progress -> Review

- [x] Files changed are listed in `Likely Files` and implementation notes.
- [x] Implementation notes are written.
- [x] Model actually used is recorded.
- [x] Red/green evidence is recorded.
- [x] Commands run are recorded.
- [x] Known gaps are recorded: None.
- Waiver: None.

### Review -> Test

- [x] Spec compliance review is complete.
- [x] Code quality review is complete.
- [x] Open review issues are resolved.
- [x] Test scope is identified.
- Waiver: None.

### Test -> Done

- [x] Fresh verification evidence is recorded.
- [x] Failures or coverage gaps are recorded: None.
- [x] Durable memory updates are marked `None`; no project-specific knowledge was discovered.
- [x] Follow-up tickets are marked `None`.
- [x] Final ticket state matches `.tickets/queue.md`.
- Waiver: None.

## Implementation Notes

- Replaced broad overwrite guidance with explicit update, dry-run, and reset paths.
- Added timestamped reset backup and interactive confirmation.
- Added `Design` as a dashboard lifecycle state and documented it consistently.
- Added an update-preservation regression test.

## Review Notes

- Spec compliance: Existing installs now point to `--update`; reset is explicit, previewed, confirmed, and backed up.
- Code quality: Standard installs never overwrite existing files; model replacement remains explicit through `--models-provider` or `--models-file`.

## Test Notes

- `sh tests/test-install.sh`
- Fresh `--project` install and dashboard validation.
- Fresh `--here` install and dashboard validation.
- Existing-install guidance and reset dry-run checks.
- Non-mutating fresh-install dry-run check.
- Confirmed reset backup smoke test through a pseudo-terminal.
- `python3 scripts/render-ticket-dashboard.py --validate`
