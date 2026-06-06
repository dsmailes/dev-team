# Dev Team Agent Workflow Pack Instructions

This project is a portable agent workflow pack. It is not an application.

## Source Of Truth

- `.agents/README.md`: role overview and coordination rules.
- `.agents/models.md`: project-local model/provider choices for each role.
- `.agents/runbook.md`: orchestration workflow.
- `.agents/prompts.md`: spawn prompts for each role.
- `.agents/handoff.md`: required gates for moving tickets between roles and states.
- `.skills/registry.md`: language, framework, platform, and task skill routing.
- `.skills/principles.md`: reusable engineering and handoff practices.
- `.tickets/template.md`: ticket shape.
- `.memory/README.md`: project memory read/write rules.

## Operating Rules

- For non-trivial implementation work, use the ticket workflow by default: inspect context, route planning through the Architect, create or update `.tickets/`, and execute only tickets that are `Ready`.
- Do not ask the user for permission to create tickets when the workflow applies. Ask only for blocking product, scope, risk, or environment decisions that cannot be resolved from repository context.
- Skip ticket creation only for trivial requests: simple questions, one-command lookups, tiny typo fixes, or when the user explicitly asks not to use tickets.
- Allocate ticket IDs by scanning existing `.tickets/*.md` files and choosing the next unused numeric suffix for the appropriate prefix.
- Keep this pack framework-neutral.
- Do not make any external skill family mandatory unless the user or project instructions explicitly require it.
- Use `Skill Context` as the single source of truth for role-specific skill assignment.
- Use `.memory/` for durable project knowledge only. Keep active task notes in `.tickets/`.
- Do not move a ticket between states unless the relevant handoff gate is complete or explicitly waived with a reason.
- Keep installer behavior conservative: no overwrites unless `--force` is explicitly passed.
- Prefer Markdown instructions that are easy to copy into project-local workflows.

## Verification

For installer changes, verify with a temporary target:

```sh
tmpdir="$(mktemp -d)"
./install.sh --project "$tmpdir" --no-import-skills --no-model-prompt
find "$tmpdir" -maxdepth 2 -type f | sort
python3 "$tmpdir/scripts/render-ticket-dashboard.py" --project "$tmpdir" --validate
```

Do not claim installer success without running a fresh verification command.
