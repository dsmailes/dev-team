#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT HUP INT TERM
PROJECT=$TMPDIR/project

hash_file() {
  cksum "$1" | awk '{print $1 ":" $2}'
}

"$ROOT/install.sh" --project "$PROJECT" --no-import-skills --no-model-prompt

GENERATED=$TMPDIR/generated-models
"$ROOT/install.sh" --project "$GENERATED" --models-provider codex --no-import-skills --no-model-prompt
grep -Fq '## Runtime Provider Boundary' "$GENERATED/.agents/models.md"
grep -Fq '| Reviewer | `anthropic-sonnet-5` | `medium` | `anthropic` | `codex` | `terra` |' "$GENERATED/.agents/models.md"

grep -Fq '## Agent Run Summary' "$PROJECT/.tickets/template.md"
grep -Fq '## Role Handoff Evidence' "$PROJECT/.tickets/template.md"
grep -Fq 'runner completion operation' "$PROJECT/.tickets/template.md"
grep -Fq 'handoff-evidence.md' "$PROJECT/.agents/handoff.md"
test -f "$PROJECT/.agents/handoff-evidence.md"
grep -Fq 'orchestration-only' "$PROJECT/.agents/architect.md"
grep -Fq 'only authoritative live board' "$PROJECT/.agents/architect.md"
grep -Fq 'only authoritative live board' "$PROJECT/.agents/runbook.md"
grep -Fq 'authoritative live board' "$PROJECT/.tickets/README.md"
grep -Fq 'one exact lifecycle token' "$PROJECT/.tickets/README.md"
grep -Fq 'Token usage' "$PROJECT/.tickets/template.md"
# Fresh installs must include the portable workspace and immutable-verification contract.
grep -Fq 'Execution mode: `isolated` or `serialized`' "$PROJECT/AGENTS.md"
grep -Fq 'only authoritative live board' "$PROJECT/AGENTS.md"
grep -Fq 'concurrent mutation or build work begins' "$PROJECT/.agents/runbook.md"
grep -Fq 'scoped ticket commit' "$PROJECT/.agents/executor.md"
grep -Fq 'exact ticket commit in a clean ticket verification worktree' "$PROJECT/.agents/reviewer.md"
grep -Fq 'exact ticket commit in a clean ticket verification worktree' "$PROJECT/.agents/tester.md"
grep -Fq -- '-derivedDataPath' "$PROJECT/.skills/principles.md"
grep -Fq 'one repository-external artifact root per project/ticket' "$PROJECT/.skills/principles.md"
grep -Fq 'never allocate one root per attempt' "$PROJECT/.skills/principles.md"
grep -Fq 'Every role and retry reuses the same ticket root' "$PROJECT/.tickets/template.md"
grep -Fq 'ownership-verified ticket artifact root' "$PROJECT/.agents/runbook.md"
grep -Fq 'failed or blocked artifacts for diagnosis' "$PROJECT/.agents/tester.md"
grep -Fq 'integration batch' "$PROJECT/.agents/runbook.md"
grep -Fq 'one full integration matrix' "$PROJECT/.agents/runbook.md"
grep -Fq 'After acceptance and concise evidence capture' "$PROJECT/.agents/handoff.md"
grep -Fq '## Workspace And Integration Contract' "$PROJECT/.tickets/template.md"
grep -Fq 'Ticket commit:' "$PROJECT/.tickets/template.md"
grep -Fq 'Verification worktree:' "$PROJECT/.tickets/template.md"
grep -Fq 'Integration commit:' "$PROJECT/.tickets/template.md"
grep -Fq '## Optional Host Resource Coordination' "$PROJECT/.tickets/template.md"
grep -Fq '### Apple Platforms' "$PROJECT/.skills/registry.md"
grep -Fq 'DEV_TEAM_BUILD_ROOT' "$PROJECT/.skills/registry.md"
! grep -Fq 'DEV_TEAM_BUILD_ROOT' "$PROJECT/.agents/runbook.md"
! grep -Fq 'DEV_TEAM_BUILD_ROOT' "$PROJECT/.tickets/template.md"
test -x "$PROJECT/scripts/with-host-resource-lease.sh"
grep -Fq '| Role | Model | Effort | Provider | Fallback Provider | Fallback Model |' "$PROJECT/.agents/models.md"
grep -Fq '## Availability And Usage Checks' "$PROJECT/.agents/models.md"
grep -Fq '## Runtime Provider Boundary' "$PROJECT/.agents/models.md"
grep -Fq 'official-chatgpt' "$PROJECT/.agents/models.md"
grep -Fq 'usage-exhausted' "$PROJECT/.agents/models.md"
grep -Fq '| Architect | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |' "$PROJECT/.agents/models.md"
grep -Fq '| Designer | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |' "$PROJECT/.agents/models.md"
grep -Fq '| Executor | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |' "$PROJECT/.agents/models.md"
grep -Fq '| Reviewer | `anthropic-sonnet-5` | `medium` | `anthropic` | `codex` | `terra` |' "$PROJECT/.agents/models.md"
grep -Fq '| Second Reviewer | `gpt-5.5` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` |' "$PROJECT/.agents/models.md"
grep -Fq '| Tester | `terra` | `high` | `codex` | `anthropic` | `anthropic-sonnet-5` |' "$PROJECT/.agents/models.md"
grep -Fq '## Second Review' "$PROJECT/.tickets/template.md"
grep -Fq '## Optional Host Resource Coordination' "$PROJECT/.tickets/template.md"
test -x "$PROJECT/scripts/with-host-resource-lease.sh"

LEASE_ROOT=$TMPDIR/host-resource-leases
"$PROJECT/scripts/with-host-resource-lease.sh" --root "$LEASE_ROOT" --timeout 5 simulator -- sh -c 'sleep 1' &
LEASE_PID=$!
while [ ! -d "$LEASE_ROOT/simulator.lease" ]; do
  sleep 1
done
if "$PROJECT/scripts/with-host-resource-lease.sh" --root "$LEASE_ROOT" --timeout 0 simulator -- sh -c ':'; then
  echo "expected simulator lease contention to fail" >&2
  exit 1
fi
wait "$LEASE_PID"
[ ! -e "$LEASE_ROOT/simulator.lease" ]

mkdir "$LEASE_ROOT/stale.lease"
printf '%s\n' 'pid=unknown' > "$LEASE_ROOT/stale.lease/owner"
if "$PROJECT/scripts/with-host-resource-lease.sh" --root "$LEASE_ROOT" --timeout 0 stale -- sh -c ':'; then
  echo "expected existing lease to remain unavailable" >&2
  exit 1
fi
[ -d "$LEASE_ROOT/stale.lease" ]
rm -rf "$LEASE_ROOT/stale.lease"

cat > "$PROJECT/.tickets/SAFE-900.md" <<'EOF'
# SAFE-900

## ID

`SAFE-900`

## Title

Keep custom project state during update.

## State

`Design`

## Problem

Exercise the Design lifecycle state and custom project state preservation.

## Acceptance Criteria

- The update preserves this ticket.

## Risks

- State could be overwritten.

## Verification Plan

- Run the dashboard validator.

## Handoff Gates

- [ ] Example gate.
EOF

QUEUE=$PROJECT/.tickets/queue.md
{
  sed -n '1,/^## Design$/p' "$QUEUE"
  printf '\n- `SAFE-900`: Keep custom project state during update. See `SAFE-900.md`.\n\n'
  sed -n '/^## In Progress$/,$p' "$QUEUE"
} > "$QUEUE.tmp"
mv "$QUEUE.tmp" "$QUEUE"

printf '%s\n' 'custom memory must survive update' >> "$PROJECT/.memory/project.md"
cat > "$PROJECT/.skills/imported.md" <<'EOF'
# Imported project skills

This file must survive a plain update.
EOF
cat > "$PROJECT/.agents/models.md" <<'EOF'
# Custom project model configuration

This file must survive a plain update.
EOF

TICKET_HASH=$(hash_file "$PROJECT/.tickets/SAFE-900.md")
QUEUE_HASH=$(hash_file "$PROJECT/.tickets/queue.md")
MEMORY_HASH=$(hash_file "$PROJECT/.memory/project.md")
IMPORTED_SKILLS_HASH=$(hash_file "$PROJECT/.skills/imported.md")
MODELS_HASH=$(hash_file "$PROJECT/.agents/models.md")

printf '%s\n' 'stale reusable ticket template' > "$PROJECT/.tickets/template.md"

"$ROOT/install.sh" --project "$PROJECT" --update --no-import-skills --no-model-prompt

[ "$TICKET_HASH" = "$(hash_file "$PROJECT/.tickets/SAFE-900.md")" ]
[ "$QUEUE_HASH" = "$(hash_file "$PROJECT/.tickets/queue.md")" ]
[ "$MEMORY_HASH" = "$(hash_file "$PROJECT/.memory/project.md")" ]
[ "$IMPORTED_SKILLS_HASH" = "$(hash_file "$PROJECT/.skills/imported.md")" ]
[ "$MODELS_HASH" = "$(hash_file "$PROJECT/.agents/models.md")" ]
grep -Fq '## Workspace And Integration Contract' "$PROJECT/.tickets/template.md"
! grep -Fq 'stale reusable ticket template' "$PROJECT/.tickets/template.md"
grep -Fq '## Second Review' "$PROJECT/.tickets/template.md"

python3 "$PROJECT/scripts/render-ticket-dashboard.py" --project "$PROJECT" --validate
python3 "$PROJECT/scripts/render-ticket-dashboard.py" --project "$PROJECT"
grep -Fq -- '**Design:** 1' "$PROJECT/docs/tickets.md"
grep -Fq 'Generated projection only' "$PROJECT/docs/tickets.md"
grep -Fq 'Generated projection only' "$PROJECT/docs/tickets.html"
python3 "$ROOT/tests/test-handoff-conformance.py"

echo "Installer update-preservation regression test passed."
