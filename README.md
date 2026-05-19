# Dev Team Agent Workflow Pack

Portable role prompts, ticket templates, and skill-routing guidance for running a multi-agent Codex workflow across projects.

## What It Installs

- `.agents/`: role definitions, model defaults, prompts, and runbook.
- `.skills/`: skill registry and cross-skill principles.
- `.tickets/`: local ticket queue, ticket template, and starter ticket.

## Agent Roles

- Architect: plans, interrogates requirements, creates tickets, and assigns role-specific skills.
- Designer: optional UI/UX specialist for screens, flows, visual hierarchy, accessibility, and frontend polish.
- Executor: implements one scoped ticket at a time.
- Reviewer: checks spec compliance first, then code quality.
- Tester: verifies behavior with fresh evidence.

## Model Defaults

```text
Architect: gpt-5.5, high
Designer: gpt-5.4, high
Designer for major product/UI decisions: gpt-5.5, high
Executor: gpt-5.3-codex, medium
Reviewer: gpt-5.5, high
Tester: gpt-5.4, medium
```

## Install Into A Project

```sh
./install.sh --project /path/to/project
```

This copies `.agents`, `.skills`, and `.tickets` into the target project.

By default, the installer refuses to overwrite existing directories. To replace them:

```sh
./install.sh --project /path/to/project --force
```

## Install As A Global Template

```sh
./install.sh --global
```

This installs the pack to:

```text
~/.codex/agent-workflows/dev-team
```

You can then copy it into projects later.

## Use In A Project

1. Ask the Architect to create tickets from the request.
2. Route UI tickets through Designer when `Designer Review` is required.
3. Assign one `Ready` ticket to Executor.
4. Run Reviewer after implementation.
5. Run Tester before marking the ticket `Done`.

The key field is `Skill Context` in each ticket. It records language, framework, platform, project type, task type, and which skills each role should use.
