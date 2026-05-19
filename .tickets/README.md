# Local Ticketing

This directory is a lightweight local ticketing system for agent-coordinated work.

## Files

- `queue.md`: status board for all active tickets.
- `template.md`: template for new tickets.
- `ARCH-001.md`: example ticket showing the expected level of detail.

## State Definitions

- `Backlog`: captured but not ready.
- `Ready`: clear enough for implementation.
- `In Progress`: currently assigned.
- `Review`: implementation is complete and awaiting review.
- `Test`: reviewed and ready for verification.
- `Done`: accepted and verified.
- `Blocked`: waiting on a decision, dependency, or unavailable environment.

## Ticket Rules

- One ticket should describe one coherent outcome.
- Each ticket needs acceptance criteria before execution.
- Each implementation ticket should include a verification plan.
- Each implementation ticket should include `Skill Context` before execution, with role-specific skills or `None` when no skill applies.
- Axiom is optional unless the ticket, user, or project instructions explicitly require it.
- Tickets that change UI, UX, visual hierarchy, interaction patterns, accessibility, or frontend polish should set `Designer Review` to `Required: Yes`.
- Behavior changes should include a TDD plan with red/green verification, unless explicitly waived.
- Review should include spec compliance first, then code quality.
- Completion requires fresh verification evidence, not assumed success.
- Follow-up work should become new tickets rather than expanding active scope.
- Durable verified knowledge should be promoted to `.memory/`; active task notes should stay in tickets.

## Example Lifecycle

```text
Backlog -> Ready -> In Progress -> Review -> Test -> Done
```

Blocked tickets return to `Ready` once the blocker is resolved.
