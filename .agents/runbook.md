# Multi-Agent Runbook

Read `runtime-modes.md`, `handoff.md`, and `handoff-evidence.md` before dispatch.
Select explicit enforced or portable mode. Never silently downgrade a failed
enforced gate. This pack supplies policy, not runtime session enforcement.

## Start A Task

1. Architect inspects instructions, relevant code and memory, then resolves
   blocking decisions before planning. Ask only the next upstream question that
   cannot be answered from the repository. Record assumptions/deferred questions.
2. Create/update scoped tickets for non-trivial work; no permission request is
   needed for ticket creation. Skip only trivial questions/typos or explicit
   user opt-out. Fill required headings, skills per role, risks, rollback,
   acceptance criteria, verification and TDD plan/waiver.
3. Select mode, runtime capabilities, provider boundary and authorized assignments
   using the sole table in models.md. Do not infer model activation. Record
   deviations between configured and observable inherited actual models.
4. Mark Designer Review for UI/UX work; mark Second Review only for explicit
   requests, security/data-loss/concurrency/migration/public-API risk, difficult
   regressions, or unresolved review uncertainty.
5. Complete Backlog -> Ready gates; dispatch only Ready tickets. Architect is
   orchestration-only and cannot implement, review, test, generate role evidence,
   or mark its own work Done.

Read .memory/project.md for orientation, commands.md before commands,
decisions.md before architecture changes, and pitfalls.md before debugging.
Use Skill Context for role-specific assignments; no external skill family is
mandatory without project/user instruction. Fresh installs have an empty board:
create the first real ticket, not a synthetic bootstrap completion.

## Workspace Ownership

Before concurrent mutation or build work begins, classify tickets as read-only
or mutating/building. Record isolated or serialized execution mode. Isolated
tickets use unique branches/worktrees and one repository-external artifact root
per project/ticket; serialized work has one exclusive mutable owner. Every role
and retry reuses the same ticket root. Keep read-only work parallel where safe.

Record the base and scoped ticket commit, verification worktree/commit, ownership,
artifact root, and integration plan. Reviewer and Tester verify the exact immutable
target, never a moving shared tree. In explicitly portable precommit work with
no commit authorization, use the frozen content-sha256 procedure in runtime-modes.md,
including untracked files and pre/post checks, without fabricating a Git SHA.

Use a named host-resource lease only when the selected platform skill requires
it, and only around the contended command. Record resource, command, and any
platform-specific prerequisites. A missing configured root or unavailable lease
is a blocker, not permission to silently substitute another path.

## Continuous Execution Within A Ticket

Drive Execute -> Review -> optional Second Review -> Test -> required Integration
-> acceptance/completion without routine user check-ins between roles. This is
bounded continuity, not an unlimited retry loop.

- Default: at most two correction rounds after the initial implementation.
- Stop earlier on repeated unchanged failure, a real blocker, unavailable
  independence/capability, or scope requiring replanning. Record findings and
  what changed; identical evidence is not progress.
- Only an explicit prior project/user decision may extend the bound to another
  finite limit with a reason. Record round, elapsed time, findings and available
  token telemetry. Unknown telemetry is Unavailable.
- Transient dispatch retries are separate: at most two bounded retries, honoring
  exposed Retry-After. Confirmed quota exhaustion selects a permitted fallback
  immediately; unknown quota is not exhausted. Never escalate for quota recovery.
- Answer live supervisor questions within the same run when possible; otherwise
  report NEEDS_CONTEXT/BLOCKED with the smallest missing decision.
- After completion, report the run summary and wait before starting another
  ticket unless project instructions explicitly enable queue auto-advance.

## Execute And Review

1. Assign one Ready ticket, exact ownership, acceptance criteria, Skill Context,
   permitted model assignment and expected output. Use compact prompts.md.
2. Assign verification proportionally: Executor performs focused red/green
   checks for changed behavior. Reserve full matrices for integration/release.
3. Executor returns changes, commands/results, target, remaining findings and
   actual telemetry. Workers never edit active ticket state or runner evidence.
   No unauthorized commit/push; portable mode records the frozen target instead.
4. Validate the Executor gate for the selected attempt. In enforced mode the
   runner creates immutable evidence; portable mode retains independent reports.
5. Independent Reviewer checks spec compliance, then quality, on the same target.
   Inspect diff and retained results; avoid repeating passing builds unless a
   concrete finding or missing evidence justifies a narrow reproduction.
6. If required, independent Second Reviewer assesses the same target before Test.
   Do not substitute Executor self-review or another role in the same session.
7. Return findings for bounded corrections. Changed targets invalidate downstream
   acceptance. Preserve failed/blocked workspaces and evidence for diagnosis.

## Test, Integrate, Complete

1. Independent Tester runs the smallest fresh risk-linked matrix against the
   recorded target and reports exact commands/results and coverage gaps.
2. A Tester pass is only a focused verification result, not automatic completion.
   Combine reviewed ticket commits into an integration batch when required.
   Record the integration commit, included ticket commits and conflict resolutions;
   rerun focused checks affected by conflicts.
3. Run one full integration matrix on the resulting integration target and link
   that result to each included ticket. For a single serialized change with no
   separate batch, record why integration is not applicable.
4. Only now submit the runner completion operation in enforced mode. It validates
   the selected passing Executor/Reviewer/Tester chain, independent sessions,
   required Second Review and integration before Test -> Done. Generic state
   editing cannot bypass this gate. Portable acceptance follows runtime-modes.md
   and is never represented as authenticated runtime completion.
5. After acceptance and concise evidence capture, remove disposable contents only
   from the named ownership-verified ticket artifact root, then clean named,
   clean worktrees/branches as authorized. Preserve failed or blocked artifacts
   for diagnosis. Never reset shared history; revert integrated work explicitly.

## Queue Hygiene

- .tickets/*.md and .tickets/queue.md are the only authoritative live board.
  .dev-team/ is runtime history; docs/tickets.* are generated projections.
- Scan ticket filenames for the next unused numeric suffix. Keep filename, H1,
  ID and queue entry aligned. State is one exact lifecycle token, not prose.
- Only the assigned board owner updates active tickets. Preserve old notes.
- After every board mutation validate then render both projections with
  `python3 scripts/render-ticket-dashboard.py --validate` and
  `python3 scripts/render-ticket-dashboard.py`. Read live state for status.
- Promote only durable verified knowledge to memory. Follow-up work gets separate
  tickets rather than unbounded active scope expansion.

## Completion Standard

Acceptance criteria, independent review, fresh focused verification, required
integration, risk/rollback notes, and mode-specific gates must all be satisfied.
Unavailable verification is a blocker, not a passing result. Announce every role
that ran, target, actual model/effort or Unavailable, deviations, tokens or
Unavailable, elapsed time, correction rounds, and remaining/follow-up findings.
