# HOST-001

## ID

`HOST-001`

## Title

Coordinate shared host resources and route Apple guidance.

## State

`In Progress`

## Problem

Several projects can run dev-team work on one machine at once. Simulator-backed tests contend for shared CoreSimulator services, while a shared external DerivedData folder can corrupt or cross-contaminate build outputs.

## Scope

- Add a portable host-resource lease helper for exclusive simulator/device phases.
- Define optional ticket metadata and handoff rules for shared host resources.
- Require unique project/ticket artifact paths beneath an explicitly configured build root.
- Document mount, permission, cleanup, and stale-lease safety checks.
- Install and regression-test the helper with the workflow pack.

## Out Of Scope

- Managing simulator devices, booting a device, or choosing an Xcode scheme.
- Requiring Xcode, a simulator, a particular external volume, or a specific agent runtime.
- Automatically removing a lease that may belong to another active process.

## Acceptance Criteria

- Simulator/device verification can run through an installed host-resource lease helper that serializes one named resource across projects on the same machine.
- The helper supports bounded waiting, records lease ownership, cleans up its own lease on normal exit or signals, and never automatically removes a possibly live stale lease.
- Only a selected platform or framework skill can require host-resource coordination; generic tickets do not receive Apple-specific fields or gates.
- Apple Xcode/CoreSimulator guidance uses `DEV_TEAM_BUILD_ROOT` as an optional user-owned root and derives a unique project/ticket artifact root without hard-coding a volume path or silently falling back when the configured root is unavailable.
- Tester guidance runs work that does not need a shared resource in parallel and holds the lease only around the platform-identified contended command.
- Fresh install and update-preservation regression coverage confirms the helper and workflow guidance are installed.

## Questioning Notes

- Context inspected: workflow docs, ticket template, installer script, installer regression, workspace/integration contract, and platform skill registry.
- Decision tree: A host-wide resource needs real coordination rather than per-worktree metadata. Use an atomic directory lease because POSIX `flock` is not portable to macOS. Build outputs need separation but must remain user-configurable, so use an environment root and per-project/ticket descendants.
- Blocking questions: None. The workflow remains framework-neutral and uses Xcode/DerivedData only as an example.
- Assumptions: Projects can run shell commands; `mkdir` is atomic on the local filesystem that holds the lease root; a host-wide temporary directory is shared by concurrent local runs.
- Deferred questions: A runtime adapter may later auto-select simulator UDIDs or expose lease status in the ticket dashboard.
- Approaches considered: Documentation-only advisory lock; a platform-specific `flock`; a portable `mkdir` lease helper.
- Chosen approach: Install a portable `mkdir` lease helper with explicit ownership and bounded waiting, then route Apple-specific CoreSimulator/DerivedData guidance through the Apple platform skill.
- Rejected alternatives: Documentation alone cannot coordinate independent apps. `flock` is unavailable by default on macOS. Automatic stale-lock deletion risks interrupting another active process.

## Likely Files

- `scripts/with-host-resource-lease.sh`
- `install.sh`
- `tests/test-install.sh`
- `AGENTS.md`
- `README.md`
- `.agents/README.md`
- `.agents/architect.md`
- `.agents/executor.md`
- `.agents/tester.md`
- `.agents/runbook.md`
- `.agents/prompts.md`
- `.agents/handoff.md`
- `.skills/principles.md`
- `.memory/commands.md`
- `.tickets/README.md`
- `.tickets/template.md`

## Risks

- A killed process can leave a lease directory behind.
- A configured external volume can be unavailable, slow, or writable by only one user.
- Holding the simulator lease for an entire build would unnecessarily serialize work.

## Rollback And Persistence

- Persistent changes: reusable workflow guidance and one installed helper script.
- User-owned configuration touched: `DEV_TEAM_BUILD_ROOT` and `DEV_TEAM_HOST_RESOURCE_ROOT` remain optional environment settings; the installer does not set them.
- Idempotency expectation: rerunning the helper only creates/removes its named lease. Installer updates replace reusable helper/docs but preserve tickets, memory, imported skills, and custom model configuration.
- Rollback or undo path: revert the workflow commit. Remove only a verified inactive lease directory after inspecting its owner record; never delete an unknown active lease.

## Workspace And Integration Contract

- Ticket classification: `mutating/building`.
- Runtime capability: Isolated ticket worktrees available: `No`.
- Execution mode: `serialized`.
- Base commit: `8d1a1f170728deecc07ff7738c547e0427fe6930`.
- Ticket branch: Shared worktree.
- Executor worktree: Repository root.
- Ticket commit: Pending the requested commit step.
- Verification worktree: Pending the scoped commit.
- Verification commit: Pending the scoped commit.
- Ticket-scoped artifact root: `/tmp/dev-team-host-001-artifacts`.
- Cleanup status: Temporary fresh-install targets and lease roots are removed after evidence capture; the source worktree remains active pending the scoped commit.
- Integration batch: Not applicable.
- Included ticket commits: Not applicable.
- Integration commit: Not applicable.
- Merge/conflict notes: None.
- Focused verification evidence: Run installer regression and helper contention test.
- Post-merge integration matrix command/result: Not applicable; single serialized ticket.

## Host Resource Coordination

- Simulator/device required: `No` for this documentation/helper ticket.
- Resource name: `simulator`.
- Lease root: `${DEV_TEAM_HOST_RESOURCE_ROOT:-${TMPDIR:-/tmp}/dev-team-host-resources}`.
- Lease command/evidence: Helper functional contention test in `tests/test-install.sh`.
- Build root configuration: Not used by this ticket. Installed projects may set `DEV_TEAM_BUILD_ROOT` to a mounted, writable local volume.

## Skill Context

- Language: Markdown, POSIX shell.
- Framework: None.
- Platform: Portable workflow pack; simulator and DerivedData are optional Apple-platform examples.
- Project type: Agent orchestration and installer.
- Task type: Host resource coordination and build-artifact isolation.
- Required skills:
  - Architect: `agent-workflow-audit`
  - Designer: `None`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`
- Optional skills: Project-local Apple build/testing skills when the installed project uses Xcode.
- Design tooling:
  - Required: `No`
  - Capabilities: `None`
  - Source: `None`
  - Notes: No UI work.
- Custom skill notes: The installed workflow remains usable without Apple tooling.

## Execution Model

- Executor model: `terra`
- Executor effort: `high`
- Escalation needed: `No`
- Escalation model: None.
- Escalation reason: Scoped portable shell and documentation work.
- Terra unavailable fallback: Use the nearest available balanced coding model and record the fallback reason.
- Model actually used: To be recorded.

## Agent Run Summary

| Role | Agent or task | Model | Effort | Token usage |
| --- | --- | --- | --- | --- |
| Architect | Current task | GPT-5 | high | Unavailable |
| Designer | Not run | Not run | Not run | Not run |
| Executor | Current task | GPT-5 | high | Unavailable |
| Reviewer | Not run | Not run | Not run | Not run |
| Second Reviewer | Not run | Not run | Not run | Not run |
| Tester | Current task | GPT-5 | high | Unavailable |

## Designer Review

- Required: `No`
- Reason: No UI or UX scope.

## Second Review

- Required: `Not required`
- Trigger: None.

## TDD Plan

- Failing test: Assert a fresh install contains the lease helper and add a contention test that holds one lease while another bounded attempt fails.
- Expected failure: The helper and installed script are absent.
- Minimal implementation: Add the helper and the smallest cross-file contract required to use it safely.
- Passing verification: Installer regression, fresh explicit and `--here` installs, dashboard validation, and helper contention test pass.
- TDD waiver, if any: None.

## Verification Plan

- `sh tests/test-install.sh`
- `python3 scripts/render-ticket-dashboard.py --validate`
- Fresh explicit and `--here` installer smoke tests from `AGENTS.md`.
- `git diff --check`

## Handoff Gates

### Backlog -> Ready

- [x] Problem, scope, risks, rollback, skill context, execution model, and verification plan are recorded.
- [x] `Second Review` is marked `Not required`.
- [x] TDD plan exists.
- Waiver: None.

### Ready -> In Progress

- [x] Executor owner, expected output, relevant files, and serialized workspace contract are recorded.
- Waiver: None.

### In Progress -> Review

- [ ] Scoped commit, clean status, and clean-worktree verification are pending the requested commit step.
- Waiver:

### Review -> Test

- [ ] Spec compliance and code quality review are complete.
- Waiver:

### Test -> Done

- [ ] Fresh installer and helper verification evidence is recorded.
- [ ] Queue and dashboard validation pass.
- Waiver:

## Implementation Notes

- Added `scripts/with-host-resource-lease.sh`, a portable atomic-directory lease helper. It supports `--root`, bounded `--timeout`, an owner record, normal/signal cleanup, and refuses to delete an existing lease.
- Installed the helper on both fresh installs and `--update`.
- Added optional Host Resource Coordination to ticket metadata and workflow guidance; it now applies only when a selected platform/framework skill identifies a shared resource.
- Routed `DEV_TEAM_BUILD_ROOT`, CoreSimulator, and DerivedData guidance through the Apple platform section of `.skills/registry.md`.
- Updated Tester guidance to hold a lease only around a platform-identified contended command.
- Implementation remains uncommitted pending the requested commit step.

## Review Notes

- Pending.

## Test Notes

- `sh -n scripts/with-host-resource-lease.sh`
- `sh -n install.sh`
- `sh -n tests/test-install.sh`
- `sh tests/test-install.sh` passed, including installed-helper contention and stale-lease preservation checks.
- Fresh explicit install passed with executable helper and dashboard validation.
- Fresh `--here` install passed with executable helper and dashboard validation.
- Source dashboard validation passed.
