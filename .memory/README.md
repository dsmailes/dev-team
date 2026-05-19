# Project Memory

Project memory stores durable facts that future agents should not have to rediscover.

Use memory for stable project knowledge, not active task notes. Active work belongs in `.tickets/`.

## Files

- `project.md`: project purpose, stack, architecture, important directories.
- `commands.md`: setup, build, test, lint, run, release, and verification commands that actually work.
- `decisions.md`: durable decisions and the reasons behind them.
- `pitfalls.md`: repeated mistakes, environment traps, broken assumptions, and known sharp edges.

## Write Rules

- Add only durable, verified knowledge.
- Keep entries short and dated when useful.
- Prefer exact commands and file paths over prose.
- Do not store secrets, tokens, credentials, private keys, or sensitive personal data.
- Do not store raw logs unless they are short and directly explain a durable pitfall.
- If a fact is only relevant to the current task, keep it in the ticket.

## Read Rules

Agents should read memory before planning or executing work:

1. Read `project.md` for orientation.
2. Read `commands.md` before running setup, build, lint, test, or run commands.
3. Read `decisions.md` before proposing architecture changes.
4. Read `pitfalls.md` before debugging or changing fragile areas.
