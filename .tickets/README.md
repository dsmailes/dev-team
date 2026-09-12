# Local Ticketing

This directory is a lightweight local ticketing system for agent-coordinated work.

## Files

- `queue.md` plus the individual ticket files are the authoritative live board.
- `template.md`: template for new tickets.
- `../scripts/render-ticket-dashboard.py`: generates non-authoritative `docs/tickets.html` and `docs/tickets.md` projections from the live board.

Runner records under `.dev-team/` are execution history and evidence, not a second ticket board. Generated dashboard files are snapshots and must be regenerated after every ticket or queue mutation before they are displayed or summarized.

## State Definitions

- `Backlog`: captured but not ready.
- `Ready`: clear enough for implementation.
- `Design`: UI/UX ticket is being shaped by the Designer before implementation.
- `In Progress`: currently assigned.
- `Review`: implementation is complete and awaiting review.
- `Test`: reviewed and ready for verification.
- `Done`: accepted and verified.
- `Blocked`: waiting on a decision, dependency, or unavailable environment.

## Ticket Rules

- Use tickets by default for non-trivial implementation work.
- Skip tickets only for simple explanations, one-command lookups, tiny typo fixes, or when the user explicitly asks not to use tickets.
- Create tickets for feature work, bug fixes, installer/setup changes, persistent configuration, UI or UX changes, test changes, multi-step debugging, data/security/concurrency/migration work, or anything that needs review and verification.
- Allocate ticket IDs by scanning `.tickets/*.md` and choosing the next unused numeric suffix for the selected prefix.
- Keep each ticket filename, H1, `## ID`, ticket `State`, and `.tickets/queue.md` entry aligned.
- Write only one exact lifecycle token under `## State`; put explanations in a separate `Closure Note`, `Blocker`, or `Notes` section.
- One ticket should describe one coherent outcome.
- Each ticket needs acceptance criteria before execution.
- Each implementation ticket should include a verification plan.
- Concurrent mutating/building tickets must include `Workspace And Integration Contract` metadata: execution mode, base commit, branch/worktree, immutable ticket commit, verification worktree, ticket-scoped artifact root, cleanup status, and later integration batch/commit evidence.
- A ticket includes optional `Host Resource Coordination` only when a selected platform or framework skill identifies a shared host resource. Record the named resource, narrow command scope, lease root, and evidence or blocker there.
- Each implementation ticket should include `Skill Context` before execution, with role-specific skills or `None` when no skill applies.
- Each ticket should complete the relevant `Handoff Gates` checklist before moving state.
- External skill families are optional unless the ticket, user, imported registry, or project instructions explicitly require them.
- Tickets that change UI, UX, visual hierarchy, interaction patterns, accessibility, or frontend polish should set `Designer Review` to `Required: Yes`.
- Tickets should set `Second Review` to `Required` only for security, data-loss, concurrency, migration, public API risk, difficult regressions, unresolved review uncertainty, or an explicit user request; otherwise set it to `Not required`.
- Behavior changes should include a TDD plan with red/green verification, unless explicitly waived.
- Review should include spec compliance first, then code quality.
- Completion requires fresh verification evidence, not assumed success.
- Follow-up work should become new tickets rather than expanding active scope.
- Durable verified knowledge should be promoted to `.memory/`; active task notes should stay in tickets.

Use `isolated` mode when safe ticket worktrees are available; otherwise use `serialized` mode and allow only one mutating/building ticket to own the shared worktree. Reviewer and Tester verify the recorded ticket commit from clean verification worktrees. The orchestrator merges reviewed commits into an integration batch, runs one full integration matrix on the resulting integration commit, and records the shared evidence on every included ticket before cleanup.

Fresh installs start with an empty board and clean memory. Create the first real ticket from template.md; there is no packaged bootstrap ticket to complete.

Select explicit enforced or portable mode using `.agents/runtime-modes.md`.
Portable precommit review uses a frozen fingerprint including untracked files,
not a fabricated SHA. Both modes require independent review/testing and required
integration before acceptance; unavailable independence keeps work blocked.

## Example Lifecycle

```text
Backlog -> Ready -> Design -> Ready -> In Progress -> Review -> Test -> Done
```

Blocked tickets return to `Ready` once the blocker is resolved.

## Dashboard

Render a static webpage for the current ticket state:

```sh
python3 scripts/render-ticket-dashboard.py
```

The generated `docs/tickets.html` and `docs/tickets.md` highlight state counts, queue mismatches, handoff gate progress, risks, and verification notes. They are snapshots, not authoritative state. Regenerate them after every mutation before using the Markdown file in Codex remote or ChatGPT surfaces.

Validate ticket and queue consistency:

```sh
python3 scripts/render-ticket-dashboard.py --validate
```
