# MODEL-001

## ID

`MODEL-001`

## Title

Prefer Sonnet 5 for review when available.

## State

`In Progress`

## Problem

The primary Reviewer always uses Terra even when the active agent runtime exposes Anthropic Sonnet 5, which would provide an independent review model.

## Scope

- Prefer `anthropic-sonnet-5` with high effort for the primary Reviewer only when the active runtime exposes it.
- Fall back to the current reviewer model and effort when it is unavailable.
- Keep GPT-5.5 as the explicitly triggered second-review model.
- Update generated model configuration, reviewer instructions, prompts, runbook, README, and installer regression coverage.

## Out Of Scope

- Requiring Anthropic access or changing Executor, Tester, or Second Reviewer defaults.
- Probing, installing, or authenticating a provider during installation.

## Acceptance Criteria

- Reviewer instructions perform an availability check before selecting `anthropic-sonnet-5`.
- If the model is unavailable, Reviewer uses the configured fallback, which preserves the current Terra high default for Codex installs.
- Generated and packaged model configuration makes both the preferred model and fallback unambiguous.
- Fresh installer regression proves the generated Codex config contains the availability-gated Sonnet 5 preference and Terra fallback.

## Questioning Notes

- Context inspected: model config, installer defaults/generator, Reviewer role prompt, runbook, README, and installer regression.
- Decision tree: If the active runtime exposes Sonnet 5, use it for primary review; otherwise preserve the current configured Reviewer model. A second independent review remains separately gated.
- Blocking questions: None. The user specified the preference and fallback.
- Assumptions: `anthropic-sonnet-5` is the runtime model identifier to request when the runtime advertises Anthropic Sonnet 5. Runtimes that use another identifier can customize `.agents/models.md`.
- Deferred questions: Provider-specific automatic discovery belongs to a future runtime adapter, not this portable installer.
- Chosen approach: Record a preferred availability-gated model and an explicit fallback in the model configuration; require the orchestrator to record the actual model selected.

## Likely Files

- `.agents/models.md`
- `.agents/reviewer.md`
- `.agents/prompts.md`
- `.agents/runbook.md`
- `README.md`
- `install.sh`
- `tests/test-install.sh`
- `.tickets/queue.md`

## Risks

- A runtime may expose Sonnet 5 under a different identifier.
- A reviewer could claim Sonnet 5 was used without checking availability.

## Rollback And Persistence

- Persistent changes: reusable model-routing documentation and installer defaults.
- User-owned configuration touched: Existing project `.agents/models.md` remains preserved by `--update` unless the user requests a model migration.
- Idempotency expectation: Reinstalling emits the same defaults; update continues to preserve custom model files.
- Rollback or undo path: Revert the scoped workflow commit or set Reviewer back to `terra` in the project-local model config.

## Workspace And Integration Contract

- Ticket classification: `mutating/building`.
- Runtime capability: Isolated ticket worktrees available: `No`.
- Execution mode: `serialized`.
- Base commit: `23472b5204460e7015baeb288dabf32eaab33046`.
- Ticket branch: Shared worktree.
- Executor worktree: Repository root.
- Ticket commit: Pending the requested commit step.
- Verification worktree: Pending the scoped commit.
- Verification commit: Pending the scoped commit.
- Ticket-scoped artifact root: `/tmp/dev-team-model-001-artifacts`.
- Cleanup status: Temporary installer targets removed after verification.
- Integration batch: Not applicable.
- Included ticket commits: Not applicable.
- Integration commit: Not applicable.
- Merge/conflict notes: None.
- Focused verification evidence: Installer regression and fresh install validation.
- Post-merge integration matrix command/result: Not applicable.

## Optional Host Resource Coordination

- Required: `No`

## Skill Context

- Language: Markdown, POSIX shell.
- Framework: None.
- Platform: Portable agent workflow pack.
- Project type: Model routing and installer.
- Task type: Conditional model selection.
- Required skills:
  - Architect: `agent-workflow-audit`
  - Designer: `None`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`
- Optional skills: None.
- Design tooling:
  - Required: `No`
  - Capabilities: `None`
  - Source: `None`
  - Notes: No UI work.

## Execution Model

- Executor model: `terra`
- Executor effort: `high`
- Escalation needed: `No`
- Terra unavailable fallback: Use the nearest available balanced coding model.
- Model actually used: GPT-5.

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
- Reason: No UI work.

## Second Review

- Required: `Not required`

## TDD Plan

- Failing test: Add installer assertions for the preferred Sonnet 5 and Terra fallback configuration.
- Expected failure: Fresh installations only contain Terra as Reviewer.
- Minimal implementation: Update defaults and role routing guidance.
- Passing verification: Installer regression and fresh install validation pass.
- TDD waiver, if any: None.

## Verification Plan

- `sh tests/test-install.sh`
- `python3 scripts/render-ticket-dashboard.py --validate`
- Fresh explicit and `--here` installer smoke tests.
- `git diff --check`

## Handoff Gates

### Backlog -> Ready

- [x] Problem, scope, acceptance criteria, risks, rollback, skill context, execution model, and verification plan are recorded.
- [x] Optional Host Resource Coordination and Second Review are marked not required.
- [x] TDD plan exists.
- Waiver: None.

### Ready -> In Progress

- [x] Executor owner, expected output, and serialized workspace contract are recorded.
- Waiver: None.

### In Progress -> Review

- [ ] Scoped commit, clean status, and clean-worktree verification are pending the requested commit step.
- Waiver:

### Review -> Test

- [ ] Spec compliance and code quality review are complete.
- Waiver:

### Test -> Done

- [ ] Fresh installer verification is recorded.
- Waiver:

## Implementation Notes

- Updated packaged and generated model configuration to request `anthropic-sonnet-5` for primary review only when the active runtime exposes it, with Terra high retained as the Codex fallback.
- Added availability-check and actual-model-recording requirements to Reviewer instructions, spawn prompt, and runbook.
- Preserved GPT-5.5 for explicitly required independent Second Review.
- Implementation remains uncommitted pending the requested commit step.

## Review Notes

- Pending.

## Test Notes

- `sh -n install.sh`
- `sh -n tests/test-install.sh`
- `sh tests/test-install.sh` passed.
- Fresh explicit install generated Sonnet 5 preference plus Terra fallback and passed dashboard validation.
- Fresh `--here` install generated Sonnet 5 preference plus Terra fallback and passed dashboard validation.
