# Runtime Modes

Select and record `enforced` or `portable` before dispatch. Mode is a project
decision, not something inferred from a product name or chosen after a failed
gate. Official Codex/ChatGPT can use portable mode when trusted runner records
and completion operations are unavailable. An enforced runner must block on a
failed or unsupported gate, never silently downgrade to portable reports.

## Enforced

The runtime owns session creation, role identity, actual model/effort capture,
immutable records, active-attempt snapshots, protected state transitions, and
completion. It must declare `handoff-evidence-v2` only after implementing those
responsibilities, including independent sessions and integration before Done.
`model-routing-v2` separately opts into extended table routing. Capability
strings in an agent-written file are not evidence of runtime support.

The reference CLI checks supplied trusted snapshots and records against the
model table. It does not verify their origin, inspect live sessions, prove that
commands ran, secure a ledger, activate models, or write completion/state.
Even an accepted result always says `authenticated: false`. The runtime must
obtain snapshots/records through its trusted interfaces and authenticate them
before calling this pure checker. See `handoff-evidence.md` for its input.

## Portable

1. Record explicit portable mode, runtime limitations, selected role assignments,
   and the available independent session/task identities. Where model selection
   is unavailable, distinguish configured/expected from observed actual model
   and effort. Disclose inherited-model deviations; use `Unavailable` when the
   runtime does not expose a value. Never invent runner evidence or session IDs.
2. Obtain independent Executor, Reviewer, and Tester sessions. Architect cannot
   fill those roles; Executor self-review is not independent review. If separate
   sessions cannot be obtained or independence cannot be established, keep the
   work blocked and request the missing independent review/testing.
3. Prefer an authorized real immutable commit. When commit creation is not
   authorized, freeze exclusive workspace ownership and compute a content target:

   `python3 -B scripts/check-workflow-policy.py --fingerprint /absolute/project --ticket-id APP-123`

   The result is `content-sha256`, not a commit SHA. Git mode uses tracked plus
   nonignored untracked paths, including content, file modes, deletions and
   symlink targets without following them. Ignored build caches are not scanned;
   tracked files remain included even when they match ignore rules. The target
   includes its manifest policy and explicit control-path exclusion list in the
   digest. With --ticket-id, only that active ticket, .tickets/queue.md and
   docs/tickets.md/html are excluded. There is no blanket .tickets/ exclusion:
   template.md and README.md always remain source policy. Other reports belong
   outside the source tree. Omit --ticket-id when those control files are source
   changes under review; never exclude implementation changes as report metadata.

   For non-Git work, prepare a separate immutable source directory and use
   `--snapshot`; do not hash a live non-Git root with changing board/build data.
   That mode includes all prepared files except root .git metadata and declared
   control exclusions. Record how the snapshot was prepared and verified complete.
   Ignored dependencies, external inputs, submodule contents and symlink
   destinations are not Git source coverage; pin/check them separately. Unsupported
   special files/submodule directories block the fingerprint instead of pretending
   to cover their content. Two reads must agree, but this is not a filesystem lock.
   Git diagnostics (even with exit status zero) and snapshot traversal errors
   reject the target as incomplete. Resolve unreadable paths or Git warnings
   before retrying; never accept a fingerprint of a silently partial manifest.
4. Keep reports, logs, generated outputs, and disposable verification artifacts
   outside the frozen tree. Reviewer and Tester record the same fingerprint
   before and after their work, plus exact commands/findings. Declared board-only
   updates do not change source identity; new nonignored untracked source does.
   Any changed fingerprint invalidates acceptance and starts
   a new attempt with fresh review/testing. Do not review a moving shared tree.
5. Complete required integration verification before acceptance, or record why a
   single serialized change needs no separate integration batch. A changed
   integration target requires its own recorded fingerprint/real commit and
   checks; do not label it as the Executor commit.
6. Submit independent reports to the designated coordinator for explicit portable
   acceptance. This is a disclosed manual workflow, not an enforced Done event.
   Only an authorized board owner may update state after all gates are met. The
   reference CLI never writes tickets, reports, runtime evidence, or completion.

`Role Handoff Evidence` remains `Unavailable` in portable mode. Independent
reports belong in review/test notes or external report paths, never fake ledger
rows. Record report IDs/paths, role/session identity, stable target, outcome,
configured versus observed model/effort, deviations, and available telemetry.

## Correction And Cost Bounds

- Default: initial implementation plus at most two correction rounds per ticket.
  A round means an Executor correction followed by fresh independent review/test
  appropriate to the change, not every tool call or transient retry.
- Stop sooner for repeated unchanged failure (same finding and target with no
  meaningful new corrective evidence), an unavailable required capability, a
  real blocker, or scope needing replanning. Do not loop on identical evidence.
- Override a bound only through an explicit project/user decision recorded before
  additional work, with reason and a new finite limit. Never self-renew a limit.
- Transient dispatch failures allow at most two bounded retries of the same
  candidate (honor Retry-After when exposed), then block. Confirmed exhausted
  quota moves directly to a permitted fallback; unknown quota is not exhaustion.
- Record elapsed time, correction round, findings addressed/remaining, transient
  retries, selected fallback/escalation reason, and token usage when exposed.
  Unknown values are `Unavailable`; do not fabricate cost or model activation.

## Pi Adapter Migration

Current Pi compatibility is structural only. No Pi code is changed by this pack.

- Preserve the first nine model columns and role names. The header-based parser
  ignores added columns and scans fenced table examples too, so models.md has
  exactly one assignment table. Current fallback resolution inherits
  `configured.effort`; it does not honor Fallback Effort, native, or escalation
  columns. Implement and declare `model-routing-v2` before using those fields.
- Pass explicit harness, native provider, and `allowed_providers` to selection.
  Current Pi does not pass allowed providers; capability fallback can choose
  outside configured candidates. Restrict every route to authorized table entries,
  supported efforts, and provider boundaries before claiming conformance.
- Bind role/session identities, selected run IDs, authorized assignments, active
  attempt, and immutable commit to trusted snapshots. Reject stale/failed chains,
  direct Done, and mismatches. Never downgrade a failed enforced handoff.
- Move required integration verification ahead of completion. Current Tester pass
  auto-completes and cleans artifacts before a separate integration gate. Retain
  failed/blocked artifacts, and postpone cleanup until integration/acceptance.
- Template missing-heading checks are warnings today. Preserve the required
  headings and exact unpunctuated routing lines. Completion still needs nonempty
  acceptance criteria, verification, risks, and rollback sections.
- Pi scaffolding copies memory directly. The pack installer's clean starter fix
  does not fix Pi initialization. Adapt it separately; no vendor sync here.

Optional smoke: `python3 -B tests/test-handoff-conformance.py --pi-project PATH`
loads the actual local parser read-only and checks legacy field parity. Standard
tests require no Pi checkout. Parser parity does not establish v2 enforcement.
