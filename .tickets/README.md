# Local Ticketing

This directory is a lightweight local ticketing system for agent-coordinated work.

## Files

- `queue.md`: status board for all active tickets.
- `template.md`: template for new tickets.
- `ARCH-001.md`: example ticket showing the expected level of detail.
- `../scripts/render-ticket-dashboard.py`: generates `docs/tickets.html` and `docs/tickets.md` from the local ticket files.

## State Definitions

- `Backlog`: captured but not ready.
- `Ready`: clear enough for implementation.
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
- One ticket should describe one coherent outcome.
- Each ticket needs acceptance criteria before execution.
- Each implementation ticket should include a verification plan.
- Each implementation ticket should include `Skill Context` before execution, with role-specific skills or `None` when no skill applies.
- Each ticket should complete the relevant `Handoff Gates` checklist before moving state.
- External skill families are optional unless the ticket, user, imported registry, or project instructions explicitly require them.
- Tickets that change UI, UX, visual hierarchy, interaction patterns, accessibility, or frontend polish should set `Designer Review` to `Required: Yes`.
- Behavior changes should include a TDD plan with red/green verification, unless explicitly waived.
- Review should include spec compliance first, then code quality.
- Completion requires fresh verification evidence, not assumed success.
- Follow-up work should become new tickets rather than expanding active scope.
- Durable verified knowledge should be promoted to `.memory/`; active task notes should stay in tickets.

The packaged `ARCH-001` ticket is a bootstrap placeholder for capturing the first real project request. Once real project tickets exist, mark it `Done`, move it to `Blocked`, or replace it with project-specific planning work so it does not remain ambiguous backlog.

## Example Lifecycle

```text
Backlog -> Ready -> In Progress -> Review -> Test -> Done
```

Blocked tickets return to `Ready` once the blocker is resolved.

## Dashboard

Render a static webpage for the current ticket state:

```sh
python3 scripts/render-ticket-dashboard.py
```

The generated `docs/tickets.html` and `docs/tickets.md` highlight state counts, queue mismatches, handoff gate progress, risks, and verification notes. Use the Markdown file for Codex remote or ChatGPT surfaces that cannot display local HTML.

Validate ticket and queue consistency:

```sh
python3 scripts/render-ticket-dashboard.py --validate
```
