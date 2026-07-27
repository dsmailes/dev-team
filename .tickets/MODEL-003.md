# MODEL-003

## ID

`MODEL-003`

## Title

Route role models within the active harness provider boundary.

## State

`In Progress`

## Problem

Cross-provider fallbacks are useful in custom multi-provider runners but are invalid in official ChatGPT/Codex and Claude harnesses. The reviewer should prefer Anthropic Sonnet 5 only when the active harness permits and exposes it, then use a GPT/Codex reviewer otherwise.

## Scope

- Define runner-declared harness/provider boundaries.
- Restrict official harnesses to their native provider and permit declared multi-provider custom runners.
- Prefer Sonnet 5 for Reviewer when allowed and available, with Terra as the Codex fallback.

## Acceptance Criteria

- Model routing does not infer harness identity or attempt a disallowed provider.
- Official ChatGPT/Codex and Claude harnesses remain provider-local.
- Custom runners can explicitly declare multiple allowed providers.
- Reviewer uses Sonnet 5 when allowed and exposed, otherwise Terra in Codex contexts.

## Verification Plan

- Run `sh tests/test-install.sh` and `python3 scripts/render-ticket-dashboard.py --validate`.

## Skill Context

- Language: Markdown, POSIX shell.
- Required skills:
  - Architect: `agent-workflow-audit`
  - Executor: `None`
  - Reviewer: `None`
  - Tester: `None`
