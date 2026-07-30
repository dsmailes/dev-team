# Handoff Protocol

The orchestrator is responsible for moving tickets between roles. Agents do not call each other directly.

Read `.agents/handoff-evidence.md` before a protected transition. Role handoff
evidence is generated and validated by the runner, not entered by an agent as
ticket prose. `Agent Run Summary` is informative telemetry only.

## Rule

Do not move a ticket to the next state until that transition's handoff gate is complete or explicitly waived with a reason.

Waivers must be written in the ticket under the relevant gate.

The Executor, Reviewer, Tester, and completion gates below are protected in
normal mode and cannot be waived by an agent or generic ticket-state edit.

## Transition Gates

### Backlog -> Ready

Required before implementation can be assigned:

- Problem is clear.
- Scope and out-of-scope are written.
- Acceptance criteria are written.
- `Questioning Notes` is filled.
- The decision tree is documented for ambiguous or high-impact work.
- Blocking questions are answered, waived with a reason, or moved to `Blocked`.
- Likely files or modules are listed.
- Risks are listed.
- Rollback and persistence impact is documented, or explicitly marked `None`.
- `Skill Context` is filled, including role-specific skills or `None`.
- `Execution Model` is filled, defaulting Executor to `terra` unless escalation is justified.
- Verification plan exists.
- `Designer Review` is marked `Yes` or `No`.
- `Second Review` is marked `Required` or `Not required`.
- TDD plan exists for behavior changes, or a waiver explains why it does not apply.

### Ready -> Design

Required only when `Designer Review` is required:

- Designer owner is assigned.
- Relevant UI files, design-system notes, and memory entries are listed.
- Output needed from Designer is stated.
- Open design/product questions are listed or explicitly marked `None`.

### Design -> Ready

Required before implementation:

- Design brief is complete.
- UI acceptance criteria are concrete enough for Executor.
- Accessibility, responsive/platform behavior, states, and edge cases are documented.
- Assets/icons/copy needs are documented or explicitly marked `None`.

### Ready -> In Progress

Required before Executor starts:

- Executor owner is assigned.
- Executor model and effort are stated.
- Executor escalation reason is stated, or escalation is marked `No`.
- Relevant files are listed.
- Relevant memory entries are listed.
- Acceptance criteria are restated or referenced.
- Expected executor output is stated.
- Verification command or manual check is stated.
- Runtime support for live supervisor contact is noted, or fallback status reporting is required.
- Ticket classification, execution mode, base commit, workspace ownership, and one repository-external project/ticket artifact root are recorded; all roles and retries reused it.
- Optional Host Resource Coordination is complete when an applicable platform or framework skill requires it: resource, lease command scope, and platform-specific build-root checks are recorded.

### In Progress -> Review

Required before Reviewer starts:

- Files changed are listed.
- Implementation notes are written.
- Runner has recorded one passing Executor evidence record for this ticket.
- Executor record provider, model, and effort match a preferred or fallback assignment in `.agents/models.md`.
- Red/green evidence is recorded, or TDD waiver is referenced.
- Commands run are recorded.
- Executor verification is focused on the ticket change. Any full repository,
  release, device, or application UI matrix is required only when this ticket
  owns the recorded integration/release gate.
- `git status --short --untracked-files=all` or equivalent artifact check is recorded when relevant.
- Known gaps are recorded or explicitly marked `None`.
- Scoped ticket commit and clean executor status are recorded.
- Verification worktree and exact verification commit are recorded.

### Review -> Test

Required before Tester starts:

- Spec compliance review is complete.
- Code quality review is complete.
- Runner has recorded one passing Reviewer evidence record for this ticket that references the Executor commit and has an independent session ID.
- Reviewer record provider, model, and effort match a preferred or fallback assignment in `.agents/models.md`.
- Open review issues are resolved, waived with reason, or ticket is blocked.
- `Second Review` is marked `Required` or `Not required`. When required, its independent review is complete against the same ticket commit SHA and its outcome is recorded.
- Test scope is identified.
- Missing context is resolved through supervisor contact, or reported as `NEEDS_CONTEXT` / `BLOCKED`.
- Reviewer clean-worktree and commit-identity checks are recorded.
- Reviewer inspected the exact diff and retained evidence; any repeated build or
  test has a concrete finding or missing-evidence reason.

### Test -> Done

Required before completion:

- Fresh verification evidence is recorded.
- Tester verification is the smallest fresh risk-linked matrix that covers the
  change. A full matrix is linked once from the integration/release gate rather
  than repeated by Executor, Reviewer, and Tester.
- The runner completion operation has recorded one passing Tester evidence record that references the Executor commit and has a session ID independent of Executor and Reviewer.
- Tester record provider, model, and effort match a preferred or fallback assignment in `.agents/models.md`.
- Tester clean-worktree, commit-identity, and artifact-root checks are recorded.
- Host-resource lease evidence is recorded when applicable. Any lease timeout identifies the owner and is handled as a blocker.
- Integration batch membership and resulting integration commit are recorded.
- One post-merge integration matrix result is linked for the batch.
- Merge conflicts and affected focused reruns are recorded or explicitly marked `None`.
- After acceptance and concise evidence capture, clean disposable contents only from the named ownership-verified ticket artifact root, then clean ticket worktrees and branches; blocked or failed workspaces and artifacts remain preserved for diagnosis.
- Failures or coverage gaps are recorded or explicitly marked `None`.
- Durable memory updates are promoted to `.memory/` or explicitly marked `None`.
- Follow-up tickets are created or explicitly marked `None`.
- Final ticket state matches `.tickets/queue.md`.
- `Agent Run Summary` lists every role that ran, its model and effort, and token usage or `Unavailable`.

Generic ticket-state editing must reject `Test -> Done`. Only the runner's
completion operation may evaluate the evidence chain and mark the ticket done.

## Handoff Summary

Every handoff should include:

```text
Ticket:
State:
Path:
Owner role:
Relevant files:
Relevant memory entries:
Skill Context:
Execution Model:
Questioning Notes:
Acceptance criteria:
Known risks:
Expected output:
Gate being satisfied:
Waivers:
Runtime capabilities:
Workspace and integration contract:
Host resource coordination:
Runner handoff evidence IDs:
Agent Run Summary:
```
