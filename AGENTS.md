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
```

Do not claim installer success without running a fresh verification command.
