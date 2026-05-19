# Cross-Skill Principles

These practices are reusable across frameworks and should inform every agent role.

## From Superpowers

- Use exact-context delegation. Subagents receive the ticket, relevant files, constraints, and expected output instead of inheriting vague chat history.
- Keep tickets small, independently verifiable, and owned by one agent at a time.
- For behavior changes, prefer red/green TDD: failing test, expected failure, minimal implementation, passing verification.
- Debug systematically: reproduce, inspect errors, compare working examples, form a single hypothesis, test minimally, then fix root cause.
- Review after implementation, with spec compliance before code quality.
- Do not claim completion without fresh verification evidence.
- If an implementer reports `NEEDS_CONTEXT`, `DONE_WITH_CONCERNS`, or `BLOCKED`, change the context, model, ticket size, or plan before retrying.

## From PFW

- Prefer explicit dependencies over hidden globals, clocks, random IDs, network clients, or storage calls.
- Make dependencies controllable in tests, previews, and local development.
- Model domains with focused units and clear action names that describe user intent.
- Prefer deterministic tests with precise diffs over broad assertions that hide the meaningful change.
- Assert against complete relevant state where practical; avoid transforming away the signal under test.
- Use snapshot tests deliberately for stable rendered output, and record/update snapshots through the project-approved workflow rather than hand-editing them.
- Keep persistence and database access type-safe or schema-aware when the stack provides that option.

## From Axiom

- Use router-style skill selection: choose the specific skill for the symptom, framework, and task instead of applying an entire skill family by default.
- Fix environment and build problems before debugging application code.
- For UI work, decide design intent before implementation details.
- Include accessibility in UI tickets: labels, contrast, focus/keyboard behavior, dynamic or responsive text, and target sizing.
- Treat platform conventions as constraints, but only when the selected platform skill applies.

## From Agent Workflow Audit

- Prefer documented commands over discovery.
- Record inferred setup steps as workflow gaps.
- Make prerequisites, environment variables, and verification commands explicit in tickets.
- Avoid making future agents rediscover the same command, file, or convention.
