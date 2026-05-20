# Skill Extensibility

This directory lets the agent workflow use framework, language, and project-specific skills without hardcoding every stack into the role prompts.

## Files

- `registry.md`: generic skill routing table.
- `principles.md`: cross-skill engineering and handoff practices.
- `imported.md`: optional local file created during install when the user imports exact skill names.

## How It Works

1. The architect identifies the language, framework, platform, project type, and task type.
2. The architect checks `registry.md`, optional `imported.md`, and project instructions for matching skills.
3. The architect records selected skills in the ticket's `Skill Context`.
4. Each downstream agent reads the ticket and uses only the skills assigned to its role.
5. If no skill applies, the architect writes `None`.

## Custom Skills

Users can provide a skill by name, local path, or short instruction note. The architect records it in the ticket and assigns it to one or more roles.

Example:

```md
## Skill Context

- Language: Project language
- Framework: Project framework
- Platform: Project platform
- Project type: Project type
- Required skills:
  - Architect: Imported planning or architecture skill, or `None`
  - Designer: Imported design or UI skill, or `None`
  - Executor: Imported implementation skill, or `None`
  - Reviewer: Imported review skill, or `None`
  - Tester: Imported testing skill, or `None`
- Optional skills:
  - Optional imported skill, or `None`
- Custom skill notes:
  - Use the project's existing conventions before introducing new primitives.
```
