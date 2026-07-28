# Dev Team Agent Workflow Pack Instructions

This project is a portable agent workflow pack. It is not an application.

## Source Of Truth

- `.agents/README.md`: role overview and coordination rules.
- `.agents/models.md`: project-local model/provider choices for each role.
- `.agents/runbook.md`: orchestration workflow.
- `.agents/prompts.md`: spawn prompts for each role.
- `.agents/handoff.md`: required gates for moving tickets between roles and states.
- `.agents/handoff-evidence.md`: runner-generated role evidence schema and protected transition rules.
- `.skills/registry.md`: language, framework, platform, and task skill routing.
- `.skills/principles.md`: reusable engineering and handoff practices.
- `.tickets/template.md`: ticket shape.
- `.memory/README.md`: project memory read/write rules.

## Operating Rules

- For non-trivial implementation work, use the ticket workflow by default: inspect context, route planning through the Architect, create or update `.tickets/`, and execute only tickets that are `Ready`.
- Do not ask the user for permission to create tickets when the workflow applies. Ask only for blocking product, scope, risk, or environment decisions that cannot be resolved from repository context.
- Skip ticket creation only for trivial requests: simple questions, one-command lookups, tiny typo fixes, or when the user explicitly asks not to use tickets.
- Allocate ticket IDs by scanning existing `.tickets/*.md` files and choosing the next unused numeric suffix for the appropriate prefix.
- Treat `.tickets/*.md` plus `.tickets/queue.md` as the only authoritative live board. `.dev-team/` records execution history/evidence, and `docs/tickets.*` files are generated projections that must be refreshed after every board mutation.
- Keep each `## State` value to one exact lifecycle token and put explanatory prose in a separate section.
- Keep this pack framework-neutral.
- Do not make any external skill family mandatory unless the user or project instructions explicitly require it.
- Use `Skill Context` as the single source of truth for role-specific skill assignment.
- Use `.memory/` for durable project knowledge only. Keep active task notes in `.tickets/`.
- Do not move a ticket between states unless the relevant handoff gate is complete or explicitly waived with a reason.
- In normal mode, the Architect is orchestration-only and may not implement, review, test, generate handoff evidence, or mark its own work `Done`. The runner alone validates protected handoffs and performs `Test -> Done` through its completion operation.
- Keep installer behavior conservative: no overwrites unless `--force` is explicitly passed.
- Prefer Markdown instructions that are easy to copy into project-local workflows.
- Before concurrent mutation or build work begins, classify tickets as `read-only` or `mutating/building`. Execution mode: `isolated` or `serialized`. Use isolated ticket branches/worktrees and one repository-external artifact root per project/ticket when the runtime supports them; otherwise serialize mutable work in one shared worktree. Executor, Reviewer, Tester, and every retry reuse that same ticket root.
- Treat a recorded scoped ticket commit as the immutable target for review and focused testing. Merge reviewed ticket commits into an integration batch, run one full integration matrix against its integration commit, and clean up named worktrees and disposable ticket artifacts only after evidence is captured. Preserve failed or blocked artifacts for diagnosis.
- Treat host-wide resources as optional platform-specific concerns. Use a named lease only when the selected platform or framework skill requires one, and hold it only around the contended command. Keep unrelated work parallel.

## Verification

For installer changes, verify with a temporary target:

```sh
tmpdir="$(mktemp -d)"
./install.sh --project "$tmpdir" --no-import-skills --no-model-prompt
find "$tmpdir" -maxdepth 2 -type f | sort
python3 "$tmpdir/scripts/render-ticket-dashboard.py" --project "$tmpdir" --validate

tmpdir="$(mktemp -d)"
packdir="$(pwd)"
(cd "$tmpdir" && "$packdir/install.sh" --here --no-import-skills --no-model-prompt)
python3 "$tmpdir/scripts/render-ticket-dashboard.py" --project "$tmpdir" --validate
```

Do not claim installer success without running a fresh verification command.
