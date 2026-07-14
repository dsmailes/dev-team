# ARCH-002

## ID

`ARCH-002`

## Title

Isolate concurrent ticket execution and verification.

## State

`Done`

## Problem

Concurrent agents can currently mutate or build from one shared worktree. Review and test commands may then observe a moving tree, overwrite shared build products, and trigger repeated isolated reruns whose evidence no longer identifies the source that was verified.

## Scope

- Define a portable orchestration rule for tickets that mutate files or produce build artifacts.
- Use a separate ticket branch and worktree for each concurrent mutating or building ticket when the runtime and repository support isolated worktrees.
- Serialize mutating and building tickets when isolated worktrees are unavailable; read-only investigations may remain parallel when they cannot alter shared state.
- Require Executor to produce a scoped ticket commit and record its immutable commit ID before review.
- Require Reviewer and Tester to verify the same exact commit from a clean ticket verification worktree rather than a moving shared tree.
- Require ticket-scoped build and artifact roots, including ticket-scoped Xcode `DerivedData` when applicable.
- Preserve focused per-ticket verification, then merge scoped ticket commits and run one full integration matrix on the resulting integration commit for the batch.
- Add metadata, handoff gates, role prompts, cleanup/rollback guidance, runtime fallback behavior, and installer regression coverage for the contract.

## Out Of Scope

- Implementing worktree creation in a specific agent runtime or requiring one vendor's subagent API.
- Building a branch manager, merge queue, CI service, or new dashboard UI.
- Changing model assignments.
- Requiring Git worktrees for read-only tickets or repositories/runtimes that cannot support them.
- Running a full repository matrix independently for every concurrent ticket.

## Acceptance Criteria

- Core workflow docs define `isolated` and `serialized` execution modes and require the orchestrator to record the selected mode before concurrent mutation or build work begins.
- In `isolated` mode, each concurrent mutating/building ticket has a unique branch, worktree, ticket commit, and ticket-scoped build/artifact roots; no two active tickets share mutable source or build output paths.
- In `serialized` fallback mode, only one mutating/building ticket owns the shared worktree at a time, and review/test wait until mutation stops and a stable commit is recorded.
- Executor handoff records the base commit, ticket branch/worktree, scoped ticket commit, files changed, focused verification, and artifact locations.
- Reviewer and Tester prompts and gates require an exact verification commit, a clean ticket verification worktree, and a recorded cleanliness check; they reject a moving shared tree or commit mismatch.
- Build guidance uses project-native ticket-scoped artifact paths and names Xcode `-derivedDataPath` only as a platform-specific example, keeping the pack framework-neutral.
- Concurrent ticket commits are merged by the orchestrator into one integration commit/batch, with conflict resolution recorded as a new commit and affected focused checks rerun.
- One full integration matrix runs after merge for the batch. Each included ticket retains focused pre-merge evidence and records the integration commit, matrix command/result, and batch membership before `Done`.
- Cleanup guidance removes ticket worktrees and branches only after merge, verification, and artifact capture; blocked/failed work is preserved for diagnosis; cleanup is non-destructive by default.
- Rollback guidance covers removing an unmerged ticket workspace and reverting an integrated scoped commit without discarding unrelated ticket work.
- Fresh install and update-preservation regression coverage proves the reusable docs/template are installed while project queues, tickets, memory, imported skills, and custom models remain preserved.
- README and installed root guidance summarize the same contract without making an external skill family or runtime mandatory.

## Questioning Notes

- Context inspected: `AGENTS.md`; all files in `.agents/`, `.skills/`, `.tickets/`, and `.memory/`; `README.md`; `install.sh`; `scripts/render-ticket-dashboard.py`; `tests/test-install.sh`; repository file inventory; complete commit history; current status, branches, remotes, and worktree list; and representative workflow/installer commits `0e0e8d3`, `5d517e6`, `b7374e0`, and `4407480`.
- Decision tree: First classify each ticket as read-only or mutating/building. For mutating/building work, detect isolated ticket worktree support. If supported, assign unique ticket workspaces; otherwise serialize. After a scoped ticket commit exists, verify that immutable commit in a clean ticket worktree. Merge reviewed commits into one integration commit, run the full matrix once, attach that evidence to every included ticket, then clean up.
- Blocking questions: None. The user selected separate ticket branches/worktrees with serialization fallback, immutable commit verification, ticket-scoped artifacts, and one post-merge matrix.
- Assumptions: The orchestrator owns workspace assignment, integration, and cleanup; Git-backed projects can expose immutable commit IDs; project-native commands can redirect build products or document unavoidable outputs; generated local dashboards remain ignored artifacts.
- Deferred questions: A future runtime adapter may automate worktree provisioning and cleanup, and a future dashboard enhancement may surface workspace metadata if users need it. Neither is required to establish the source workflow contract.
- Approaches considered: Continue disjoint file ownership in one tree; require isolated worktrees unconditionally; define capability-based isolation with serialization fallback and a single integration batch.
- Chosen approach: Capability-based isolation plus serialized fallback. This is portable across runtimes, prevents moving-tree review, and avoids multiplying expensive full matrices.
- Rejected alternatives: File ownership alone does not isolate build products or source snapshots. Unconditional worktrees would make the pack unusable in runtimes without worktree support. Per-ticket full matrices preserve isolation but repeat expensive coverage without testing the merged result.

## Likely Files

- `AGENTS.md`
- `README.md`
- `.agents/README.md`
- `.agents/architect.md`
- `.agents/executor.md`
- `.agents/reviewer.md`
- `.agents/tester.md`
- `.agents/runbook.md`
- `.agents/prompts.md`
- `.agents/handoff.md`
- `.skills/principles.md`
- `.tickets/README.md`
- `.tickets/template.md`
- `tests/test-install.sh`
- `install.sh` only if implementation discovers that existing copy/update behavior cannot propagate the reusable files without changing its contract.
- `scripts/render-ticket-dashboard.py` only if validation must enforce newly required metadata; no dashboard UI change is currently required.

## Risks

- A reviewer may accidentally verify the integration branch or shared checkout instead of the recorded ticket commit.
- Build tools may still write caches outside the configured ticket artifact root.
- Merge conflict resolution can invalidate reviewed code if the new integration commit is not linked back to affected tickets.
- Overly Git-specific wording could weaken portability to constrained runtimes.
- Cleanup commands can destroy unmerged work if ownership and merge state are not checked first.
- A single integration matrix can obscure which ticket caused a failure unless batch membership and focused evidence remain explicit.
- Installer update tests could accidentally assert replacement of project-owned state that `--update` must preserve.

## Rollback And Persistence

- Persistent changes: Reusable workflow instructions, role prompts, ticket metadata/gates, root documentation, and installer regression expectations.
- User-owned configuration touched: None. Plain installer update must continue preserving project tickets, queue, memory, imported skills, and custom model configuration.
- Idempotency expectation: Reapplying the workflow update or running installer `--update` repeatedly must not duplicate metadata, overwrite live ticket state, or create worktrees/branches as an installer side effect.
- Rollback or undo path: Revert the scoped workflow commit. For runtime workspaces, first preserve any unmerged commit, remove only the named ticket worktree after a clean/merged check, prune stale worktree metadata, and delete only the ticket branch confirmed merged or intentionally abandoned. Revert an integrated ticket with a new scoped revert commit rather than resetting shared history.

## Workspace And Integration Contract

- Ticket classification: `mutating/building`.
- Runtime capability: Safe local Git worktrees are available.
- Execution mode: `isolated`.
- Base commit: `06edf5e6a5365fbb2b8643391b7fc69a06c2c306`.
- Ticket branch: `codex/arch-002-isolation`.
- Executor worktree: `/tmp/dev-team-arch-002`.
- Verification worktree: `/tmp/dev-team-arch-002-verify` (detached, clean at the verification commit).
- Ticket commit: `83f9c5fd4c516d0e1cf243422fbf76aa9b46bf0c`.
- Verification commit: `83f9c5fd4c516d0e1cf243422fbf76aa9b46bf0c`.
- Ticket-scoped artifact root: `/tmp/dev-team-arch-002-artifacts/ARCH-002` (no persistent artifacts produced by this documentation/install regression work).
- Cleanup status: Complete. Both clean ticket worktrees were removed after evidence capture, the merged `codex/arch-002-isolation` branch was deleted, and ticket/fresh-install artifact roots were removed. No unmerged or failed work was discarded.
- Integration batch: `2026-07-14-ARCH-002`.
- Included ticket commits: `83f9c5fd4c516d0e1cf243422fbf76aa9b46bf0c`.
- Integration commit: `90c187309f2398cf282439b3c8a37339e28b6c80`.
- Stable verification target: Reviewer and Tester use the recorded ticket commit. A commit mismatch or dirty verification tree is `BLOCKED` until corrected.
- Focused evidence: Reviewer and Tester passed the exact ticket commit from clean detached verification worktree `/tmp/dev-team-arch-002-verify` before integration.
- Integration evidence: The ticket branch first fast-forwarded without conflict. Parallel remote implementations were merged without textual conflict; unconditional worktree wording overlapped the reviewed capability-based fallback, so scoped resolution commit `cfe9930428a7aea4bed8ea10b645905c7c106830` removed legacy duplicates, and `90c187309f2398cf282439b3c8a37339e28b6c80` removed the final queue/root-guidance duplicates after the second remote merge. At exact combined integration commit `90c187309f2398cf282439b3c8a37339e28b6c80`, `sh tests/test-install.sh`, source dashboard validation, a fresh `--here` install plus installed dashboard validation, `git diff --check`, commit identity, and clean-status checks all passed. Earlier exact-commit runs also passed the explicit fresh `--project` flow and consistency scan. Temporary artifact roots were removed after capture.
- Completion rule: A concurrent ticket is not `Done` until its focused evidence and the shared post-merge integration evidence are both attached or explicitly waived with a risk-based reason.
- Runtime fallback: Without isolated worktree support, the orchestrator queues mutating/building tickets serially in the shared worktree and permits Reviewer/Tester only after a stable commit and clean status exist.

## Skill Context

- Language: Markdown, POSIX shell, Python.
- Framework: None.
- Platform: Portable Git-based agent workflow pack; platform-specific build tools remain optional examples.
- Project type: Agent orchestration, installer, and workflow documentation.
- Task type: Concurrency isolation, immutable verification, integration orchestration, and regression testing.
- Required skills:
  - Architect: `agent-workflow-audit`
  - Designer: `None`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`
- Optional skills: Project-local Git/worktree, build, testing, or platform skills when imported and applicable; otherwise `None`.
- Design tooling:
  - Required: `No`
  - Capabilities: `None`
  - Source: `None`
  - Notes: No UI change is planned.
- Custom skill notes: Keep exact external skill names optional. The workflow contract must be understandable and executable from the installed Markdown alone.

## Execution Model

- Executor model: `terra`
- Executor effort: `high`
- Escalation needed: `No`
- Escalation model: None.
- Escalation reason: The architecture and acceptance contract are resolved; implementation is coordinated documentation and focused regression coverage.
- Terra unavailable fallback: Use the nearest available balanced coding model and record the fallback reason.
- Model actually used: `GPT-5` via Codex; the named `terra` profile was not exposed by this runtime, so the available coding model was used.

## Agent Run Summary

Record every role that actually ran for this ticket. Do not estimate token usage: write `Unavailable` when the runtime does not expose it.

| Role | Agent or task | Model | Effort | Token usage |
| --- | --- | --- | --- | --- |
| Architect | Planning task | Sol | high | Unavailable |
| Designer | Not run | Not run | Not run | Not run |
| Executor | Current Executor task | GPT-5 | high | Unavailable |
| Reviewer | Independent clean-commit review | GPT-5.5 | high | Unavailable |
| Tester | Focused clean-commit verification | Luna | high | Unavailable |

## Designer Review

- Required: `No`
- Reason: This changes workflow and verification contracts, not user-facing UI.
- Preferred model: See `.agents/models.md`.
- Preferred effort: See `.agents/models.md`.
- Design tooling needed: None.
- Output needed: None.

## Design Brief

- UI goal: Not applicable.
- Target user and workflow: Not applicable.
- Layout and components: Not applicable.
- States and edge cases: Not applicable.
- Accessibility: Not applicable.
- Responsive or platform-specific behavior: Not applicable.
- Assets and icons: Not applicable.
- Design tooling used: None.
- Executor notes: Not applicable.

## TDD Plan

- Failing test: Extend `tests/test-install.sh` first to assert that a fresh install contains the isolation modes, immutable verification metadata/gates, ticket-scoped artifact guidance, serialized fallback, and post-merge integration contract.
- Expected failure: The new assertions fail because current installed workflow files and ticket template contain none of the required worktree/commit/integration metadata.
- Minimal implementation: Update only the reusable source docs, prompts, principles, ticket template/README, root guidance, and any narrowly necessary installer/dashboard behavior.
- Passing verification: Run the focused installer regression, source dashboard validation, two fresh temporary-target install/validate flows, and consistency searches for contradictory shared-tree/full-matrix guidance.
- TDD waiver, if any: None for installer propagation behavior. Pure prose edits are verified through focused assertions and cross-file consistency review.

## Verification Plan

- `sh tests/test-install.sh`
- `python3 scripts/render-ticket-dashboard.py --validate`
- Fresh explicit target: `tmpdir="$(mktemp -d)"; ./install.sh --project "$tmpdir" --no-import-skills --no-model-prompt; find "$tmpdir" -maxdepth 2 -type f | sort; python3 "$tmpdir/scripts/render-ticket-dashboard.py" --project "$tmpdir" --validate`
- Fresh `--here` target: `tmpdir="$(mktemp -d)"; packdir="$(pwd)"; (cd "$tmpdir" && "$packdir/install.sh" --here --no-import-skills --no-model-prompt); python3 "$tmpdir/scripts/render-ticket-dashboard.py" --project "$tmpdir" --validate`
- Update preservation: Extend the existing regression to prove project tickets, queue, memory, imported skills, and custom models survive while reusable guidance/template files refresh.
- Consistency search: `rg -n -i 'worktree|ticket commit|verification commit|artifact root|deriveddata|serialized|integration matrix|integration commit' AGENTS.md README.md .agents .skills .tickets tests`
- Artifact check: `git status --short --untracked-files=all`

## Handoff Gates

### Backlog -> Ready

- [x] Problem is clear.
- [x] Scope and out-of-scope are written.
- [x] Acceptance criteria are written.
- [x] `Questioning Notes` is filled.
- [x] Blocking questions are answered, waived with a reason, or moved to `Blocked`.
- [x] Likely files or modules are listed.
- [x] Risks are listed.
- [x] Rollback and persistence impact is documented, or explicitly marked `None`.
- [x] `Skill Context` is filled, including role-specific skills or `None`.
- [x] `Execution Model` is filled, defaulting Executor to `terra` unless escalation is justified.
- [x] Verification plan exists.
- [x] `Designer Review` is marked `Yes` or `No`.
- [x] TDD plan exists for behavior changes, or a waiver explains why it does not apply.
- Waiver: None.

### Ready -> Design

- [x] Designer owner is assigned.
- [x] Relevant UI files, design-system notes, and memory entries are listed.
- [x] Output needed from Designer is stated.
- [x] Open design/product questions are listed or explicitly marked `None`.
- Waiver: Designer is not required because the ticket has no UI or UX scope.

### Design -> Ready

- [x] Design brief is complete.
- [x] UI acceptance criteria are concrete enough for Executor.
- [x] Accessibility, responsive/platform behavior, states, and edge cases are documented.
- [x] Assets/icons/copy needs are documented or explicitly marked `None`.
- Waiver: Designer is not required because the ticket has no UI or UX scope.

### Ready -> In Progress

- [x] Executor owner is assigned: Executor Agent, `gpt-5.6-terra`, `high`.
- [x] Executor model and effort are stated.
- [x] Executor escalation reason is stated as `No`.
- [x] Relevant files are listed.
- [x] Relevant memory entries are listed.
- [x] Acceptance criteria are restated or referenced.
- [x] Expected executor output is the complete portable workspace/integration contract and installer regression coverage.
- [x] Verification commands are stated in the Verification Plan.
- [x] Execution mode, base commit, ticket branch/worktree, and ticket-scoped artifact root are recorded.
- Waiver: None. Executor has a dedicated branch/worktree and live orchestrator contact.

### In Progress -> Review

- [x] Files changed are listed.
- [x] Implementation notes are written.
- [x] Model actually used is recorded.
- [x] Red/green evidence is recorded.
- [x] Commands run are recorded.
- [x] Known gaps are explicitly marked `None`.
- [x] Scoped ticket commit and clean executor status are recorded.
- [x] Verification worktree and exact verification commit are recorded.
- Waiver: None.

### Review -> Test

- [x] Spec compliance review is complete against the recorded ticket commit.
- [x] Code quality review is complete against the same ticket commit.
- [x] Reviewer clean-worktree and commit-identity checks are recorded.
- [x] Open review issues are resolved, waived with reason, or ticket is blocked.
- [x] Focused test scope and ticket-scoped artifact root are identified.
- Waiver: None.

### Test -> Done

- [x] Fresh focused verification evidence for the exact ticket commit is recorded.
- [x] Tester clean-worktree, commit-identity, and artifact-root checks are recorded.
- [x] Integration batch membership and resulting integration commit are recorded.
- [x] One post-merge integration matrix result is linked for the batch.
- [x] Merge conflicts and affected focused reruns are recorded or explicitly marked `None`.
- [x] Failures or coverage gaps are recorded or explicitly marked `None`.
- [x] Cleanup status for ticket worktrees, branches, and artifacts is recorded.
- [x] Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- [x] Follow-up tickets are created or explicitly marked `None`.
- [x] Final ticket state matches `.tickets/queue.md`.
- [x] `Agent Run Summary` lists every role that ran, its model and effort, and token usage or `Unavailable`.
- Waiver: None.

## Review Plan

- Spec compliance: Trace every user-selected rule through root guidance, orchestration docs, role prompts, handoff gates, ticket metadata, installer propagation, and regression assertions. Confirm no role is instructed to review a moving shared tree or run a redundant full matrix per concurrent ticket.
- Code quality: Check terminology is consistent, capability-based, framework-neutral, non-destructive, and specific enough to execute without chat context. Confirm examples do not make Xcode or a particular runtime mandatory.

## Decisions

- The orchestrator owns execution-mode selection, workspace assignment, integration, and cleanup.
- A ticket commit is the immutable unit of per-ticket review and focused verification.
- The integration commit is the immutable unit of the shared full matrix.
- Serialized execution is the mandatory fallback when isolated ticket worktrees are unavailable.
- Build and test outputs are ticket-scoped even when source files are disjoint.
- Merge conflict resolution creates a new integration commit and invalidates only the focused evidence affected by the resolution.

## Memory Updates

- Project: None; this repository's checked-in workflow docs are the durable source of truth.
- Commands: None; verification commands are already documented in `AGENTS.md` and the reusable workflow.
- Decisions: None; the accepted architecture is now implemented in the reusable source docs.
- Pitfalls: None; the moving-worktree rerun risk is now addressed by the reusable contract.

## Implementation Notes

- Implemented the portable contract in root guidance, README, orchestration and role docs, cross-skill principles, ticket rules/template, and the installer regression. No runtime-specific worktree automation or dashboard parser change was needed: the installer already copies the reusable source files and preserves project-owned state on plain updates.
- Files changed: `AGENTS.md`, `README.md`, `.agents/README.md`, `.agents/architect.md`, `.agents/executor.md`, `.agents/handoff.md`, `.agents/prompts.md`, `.agents/reviewer.md`, `.agents/runbook.md`, `.agents/tester.md`, `.skills/principles.md`, `.tickets/README.md`, `.tickets/template.md`, and `tests/test-install.sh`.
- Scoped ticket commit: `83f9c5fd4c516d0e1cf243422fbf76aa9b46bf0c` (`Define isolated ticket workspace contract`). `git diff --check` passed before committing; the detached verification worktree was clean at this exact commit.
- Red/green evidence: After extending `tests/test-install.sh`, `sh -x tests/test-install.sh` failed at the new fresh-install assertion for `Execution mode: \`isolated\` or \`serialized\`` in installed `AGENTS.md`. After the reusable guidance/template changes, `sh tests/test-install.sh` passed both in the executor worktree and in `/tmp/dev-team-arch-002-verify` at the recorded commit, including update preservation for ticket, queue, memory, imported skills, custom models, and refreshed reusable template metadata.
- Commands run: `sh tests/test-install.sh`; `python3 scripts/render-ticket-dashboard.py --validate`; fresh `./install.sh --project "$tmpdir" --no-import-skills --no-model-prompt` plus installed dashboard validation; fresh `(cd "$tmpdir" && "$packdir/install.sh" --here --no-import-skills --no-model-prompt)` plus installed dashboard validation; `git diff --check`; targeted consistency `rg` scans; clean-worktree `git status --short --untracked-files=all` and `git rev-parse HEAD`.
- Known gaps: None. The integration batch, integration commit, post-merge matrix, and final cleanup are intentionally orchestrator-owned future gates after Review/Test.

## Review Notes

- Spec compliance notes: `READY_FOR_TEST` with no findings. Independent Reviewer GPT-5.5/high verified clean detached worktree `/tmp/dev-team-arch-002-verify` at exact ticket commit `83f9c5fd4c516d0e1cf243422fbf76aa9b46bf0c`. The isolation/serialization modes, immutable ticket verification, ticket-scoped artifacts, one post-merge integration matrix, cleanup/rollback rules, installer propagation, and preservation assertions all match the ticket contract.
- Code quality notes: No findings. Terminology is consistent and framework-neutral, Xcode remains an optional platform example, cleanup guidance is non-destructive, and no contradictory moving-tree or redundant per-ticket full-matrix guidance remains. Reviewer reran `sh tests/test-install.sh`, source dashboard validation, both fresh install flows, consistency searches, `git diff --check`, commit identity, and clean-status checks successfully.

## Test Notes

- Focused Tester result: `PASS` from Luna/high against clean detached worktree `/tmp/dev-team-arch-002-verify` at exact ticket commit `83f9c5fd4c516d0e1cf243422fbf76aa9b46bf0c`.
- Fresh focused verification evidence: `sh tests/test-install.sh` passed; all five update-preservation hash checks passed; source dashboard validation passed; fresh `--project` and `--here` installs each produced 29 expected files and passed installed dashboard validation; 98 cross-file consistency matches contained no contradiction; `git diff --check` and clean-status checks passed; no ticket artifacts were left behind.
- Post-merge integration result: `PASS` for batch `2026-07-14-ARCH-002` at exact combined integration commit `90c187309f2398cf282439b3c8a37339e28b6c80`. The ticket branch fast-forwarded without conflict; parallel remote commits were retained in history and their duplicate semantics were resolved in scoped commits. Installer regression, source validation, fresh install validation, diff hygiene, commit identity, and clean status all passed.
- Failures or coverage gaps: None. The harmless sandboxed `xcodebuild` cache warnings emitted by the installer regression did not change its exit status or assertions.
- Cleanup: Complete for both named worktrees, the merged ticket branch, and all named temporary artifact roots.
- Durable memory updates: None; checked-in workflow documentation is authoritative.
- Follow-up tickets: None.
