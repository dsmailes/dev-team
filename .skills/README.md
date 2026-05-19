# Skill Extensibility

This directory lets the agent workflow use framework, language, and project-specific skills without hardcoding every stack into the role prompts.

## Files

- `registry.md`: local skill routing table.
- `principles.md`: cross-skill practices borrowed from Axiom, PFW, Superpowers, and agent workflow guidance.

## How It Works

1. The architect identifies the language, framework, platform, project type, and task type.
2. The architect checks `registry.md` and project instructions for matching skills.
3. The architect records selected skills in the ticket's `Skill Context`.
4. Each downstream agent reads the ticket and uses only the skills assigned to its role.
5. If no skill applies, the architect writes `None`.

## Custom Skills

Users can provide a skill by name, local path, or short instruction note. The architect records it in the ticket and assigns it to one or more roles.

Example:

```md
## Skill Context

- Language: TypeScript
- Framework: Next.js
- Platform: Web
- Project type: Frontend app
- Required skills:
  - Architect: `build-web-apps:react-best-practices`
  - Designer: `frontend-skill`
  - Executor: `build-web-apps:react-best-practices`
  - Reviewer: `build-web-apps:react-best-practices`
  - Tester: `build-web-apps:frontend-testing-debugging`
- Optional skills:
  - `build-web-apps:shadcn`
- Custom skill notes:
  - Use the app's existing component system before introducing new primitives.
```
