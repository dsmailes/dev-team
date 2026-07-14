# ARCH-002 Implementation Plan

## Outcome

Make concurrent ticket work deterministic: isolate mutable source and build products when supported, serialize otherwise, verify immutable commits, and run one full matrix on the merged integration result.

## Phase 1: Define One Workspace Contract

- Add a compact contract shared by root guidance, `.agents/`, `.skills/principles.md`, and ticket docs.
- Define ticket classification (`read-only` or `mutating/building`) and execution mode (`isolated` or `serialized`).
- Define the required identifiers: base commit, ticket branch/worktree, ticket commit, verification worktree/commit, artifact root, integration batch, and integration commit.
- Keep runtime provisioning abstract: built-in runtime worktrees or safe Git tooling may satisfy isolation; unavailable support forces serialization.

## Phase 2: Make Handoffs Immutable

- Architect records execution mode and expected ownership before assignment.
- Executor works only in the assigned ticket workspace, redirects build products, commits scoped changes, and hands off a clean status plus commit ID.
- Reviewer checks out the exact ticket commit in a clean ticket verification worktree and refuses moving-tree review.
- Tester independently verifies that same commit with ticket-scoped artifacts and records focused evidence.
- Add these checks to `.agents/handoff.md`, `.tickets/template.md`, and role prompts rather than relying on prose alone.

## Phase 3: Integrate Once

- Orchestrator merges or cherry-picks reviewed ticket commits according to repository policy and records included commits in one integration batch.
- Conflict resolution produces a new integration commit; tickets touched by the resolution rerun focused checks.
- Run the repository's full integration matrix once against the clean integration commit with a batch-scoped artifact root.
- Link the same matrix evidence to every included ticket while retaining each ticket's focused evidence.

## Phase 4: Cleanup And Recovery

- Preserve blocked or failing workspaces until evidence is captured.
- After successful merge and verification, remove only clean named worktrees, prune stale metadata, and delete only branches confirmed merged or intentionally abandoned.
- Revert integrated changes with scoped revert commits. Never reset shared history or delete unrelated ticket work.
- In serialized mode, release shared-worktree ownership between tickets and require a clean stable commit before the next owner starts.

## Phase 5: Prove Portability

1. Extend `tests/test-install.sh` with failing assertions for the new installed contract.
2. Update the smallest coherent set of reusable workflow files.
3. Run the focused regression and dashboard validation.
4. Run both required fresh temporary-target install flows.
5. Confirm plain `--update` still preserves project tickets, queue, memory, imported skills, and custom models.
6. Search for contradictory guidance and inspect final git status for generated artifacts.

## Likely Change Groups

1. Orchestration and runtime behavior: `AGENTS.md`, `README.md`, `.agents/README.md`, `.agents/architect.md`, `.agents/runbook.md`, `.skills/principles.md`.
2. Role behavior and immutable handoff: `.agents/executor.md`, `.agents/reviewer.md`, `.agents/tester.md`, `.agents/prompts.md`, `.agents/handoff.md`.
3. Installed ticket contract: `.tickets/README.md`, `.tickets/template.md`.
4. Verification: `tests/test-install.sh`, with `install.sh` or dashboard parser changes only if a failing test proves they are necessary.

## Merge Order

Implement as one scoped ticket commit because the guidance is cross-referential and independent parallel edits would overlap the same source files. Review and focused verification target that commit. Merge it once, then run the full installer/integration matrix on the resulting integration commit.
