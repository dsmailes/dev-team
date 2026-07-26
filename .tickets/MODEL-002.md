# MODEL-002

## ID

`MODEL-002`

## Title

Default the normal role loop to Terra High.

## State

`In Progress`

## Problem

The current workflow defaults Architect and Designer to Sol and primary review to Anthropic Sonnet 5. This consumes substantially more quota than the normal planning, implementation, review, and verification loop requires.

## Scope

- Make Terra with high effort the normal Codex default for Architect, Designer, Executor, Reviewer, and Tester.
- Keep cross-provider fallbacks and reserve Sol for explicit difficult or multi-phase escalation.
- Update generated configuration, role guidance, prompts, README, and installer regression coverage.

## Acceptance Criteria

- Fresh Codex configuration defaults the five normal roles to Terra High.
- Sol is not a normal default or quota-recovery fallback.
- Guidance reserves higher tiers for focused difficult work or genuinely multi-phase/parallel work.
- Installer regression passes.

## Verification Plan

- Run `sh tests/test-install.sh` and `python3 scripts/render-ticket-dashboard.py --validate`.

## Skill Context

- Language: Markdown, POSIX shell.
- Required skills:
  - Architect: `agent-workflow-audit`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`
