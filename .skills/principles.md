# Cross-Skill Principles

These practices are reusable across frameworks and should inform every agent role.

## Planning And Delegation

- Use exact-context delegation. Subagents receive the ticket, relevant files, constraints, and expected output instead of inheriting vague chat history.
- Prefer fresh subagent context when the runtime supports it.
- Use live supervisor contact for blocking subagent questions when available; otherwise require `NEEDS_CONTEXT` or `BLOCKED` reports.
- Keep delegation inside the allowed role list for the workflow and project.
- Keep tickets small, independently verifiable, and owned by one agent at a time.
- Review after implementation, with spec compliance before code quality.
- If an implementer reports `NEEDS_CONTEXT`, `DONE_WITH_CONCERNS`, or `BLOCKED`, change the context, model, ticket size, or plan before retrying.

## Testing And Verification

- For behavior changes, prefer red/green testing: failing test, expected failure, minimal implementation, passing verification.
- Do not claim completion without fresh verification evidence.
- Prefer deterministic tests with precise diffs over broad assertions that hide the meaningful change.
- Assert against complete relevant state where practical; avoid transforming away the signal under test.
- Use snapshot tests deliberately for stable rendered output, and record/update snapshots through the project-approved workflow rather than hand-editing them.

## Debugging

- Reproduce before fixing.
- Read errors and logs closely.
- Compare against working examples in the same codebase.
- Form one hypothesis at a time and test it minimally.
- Fix root causes rather than symptoms.

## Design And Platform Work

- Use router-style skill selection: choose the specific skill for the symptom, framework, and task instead of applying an entire skill family by default.
- Fix environment and build problems before debugging application code.
- For UI work, decide design intent before implementation details.
- Include accessibility in UI tickets: labels, contrast, focus/keyboard behavior, dynamic or responsive text, and target sizing.
- Treat platform conventions as constraints only when the selected platform skill applies.

## Dependencies And Data

- Prefer explicit dependencies over hidden globals, clocks, random IDs, network clients, or storage calls.
- Make dependencies controllable in tests, previews, and local development.
- Model domains with focused units and clear action names that describe user intent.
- Keep persistence and database access type-safe or schema-aware when the stack provides that option.

## Agent Workflow Hygiene

- Prefer documented commands over discovery.
- Record inferred setup steps as workflow gaps.
- Make prerequisites, environment variables, and verification commands explicit in tickets.
- Avoid making future agents rediscover the same command, file, or convention.
- Use the narrowest command or tool that answers the question or verifies the change.
- Explain high-impact actions before taking them, especially installer changes, persistent configuration changes, destructive operations, or writes outside the project.
- Preserve user-owned configuration and project state unless the user explicitly asks to replace it.
- Make installer and setup changes idempotent: reruns should not duplicate entries, clobber local state, or surprise the user.
- Document undo or rollback paths for persistent changes.
- Before handoff, inspect `git status --short --untracked-files=all`, confirm required new files are tracked, and check for accidental artifacts.
- For installer, packaging, or workflow-pack changes, run a fresh smoke test against a temporary target before claiming success.
