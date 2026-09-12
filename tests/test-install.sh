#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT HUP INT TERM
PROJECT=$TMPDIR/project

hash_file() {
  cksum "$1" | awk '{print $1 ":" $2}'
}

assert_clean_state() {
  clean_project=$1
  [ "$(find "$clean_project/.tickets" -type f | wc -l | tr -d ' ')" = 3 ]
  cmp "$ROOT/starter/.tickets/queue.md" "$clean_project/.tickets/queue.md"
  cmp "$ROOT/.tickets/template.md" "$clean_project/.tickets/template.md"
  [ "$(find "$clean_project/.memory" -type f | wc -l | tr -d ' ')" = 5 ]
  for memory in project commands decisions pitfalls; do
    cmp "$ROOT/starter/.memory/$memory.md" "$clean_project/.memory/$memory.md"
  done
  python3 "$clean_project/scripts/render-ticket-dashboard.py" --project "$clean_project" --validate
}

# A new project must not inherit this pack's development board or memory.
"$ROOT/install.sh" --project "$PROJECT" --no-import-skills --no-model-prompt
assert_clean_state "$PROJECT"

HERE=$TMPDIR/here
mkdir "$HERE"
(
  cd "$HERE"
  "$ROOT/install.sh" --here --no-import-skills --no-model-prompt
)
assert_clean_state "$HERE"

# Bootstrap from a local archive whose live board and memory contain private state.
# Only the reusable docs and starter assets should reach the target.
PACK=$TMPDIR/archive/dev-team
mkdir -p "$PACK"
for path in install.sh README.md AGENTS.md .agents .skills .tickets .memory scripts docs starter; do
  cp -R "$ROOT/$path" "$PACK/$path"
done
printf '%s\n' 'private source ticket' > "$PACK/.tickets/PRIVATE-999.md"
printf '%s\n' 'private source queue' > "$PACK/.tickets/queue.md"
for memory in project commands decisions pitfalls; do
  printf '%s\n' 'private source memory' > "$PACK/.memory/$memory.md"
done
printf '%s\n' 'private source notes' > "$PACK/.memory/private.md"
tar -czf "$TMPDIR/pack.tar.gz" -C "$TMPDIR/archive" dev-team
BOOTSTRAP=$TMPDIR/bootstrap
mkdir "$BOOTSTRAP"
(
  cd "$BOOTSTRAP"
  DEV_TEAM_WORKFLOW_PACK_TARBALL_URL="file://$TMPDIR/pack.tar.gz" \
    sh -s -- --here --no-import-skills --no-model-prompt < "$ROOT/install.sh"
)
assert_clean_state "$BOOTSTRAP"

"$ROOT/install.sh" --project "$TMPDIR/dry-fresh" --dry-run --no-import-skills --no-model-prompt
[ ! -e "$TMPDIR/dry-fresh" ]

cp -R "$PROJECT" "$TMPDIR/before-conservative-checks"
"$ROOT/install.sh" --project "$PROJECT" --update --dry-run
"$ROOT/install.sh" --project "$PROJECT" --reset-project-state --force --dry-run
if "$ROOT/install.sh" --project "$PROJECT" --force --no-import-skills --no-model-prompt; then
  echo "expected --force alone to refuse an existing installation" >&2
  exit 1
fi
if "$ROOT/install.sh" --project "$PROJECT" --reset-project-state --force </dev/null; then
  echo "expected noninteractive reset to fail" >&2
  exit 1
fi
diff -r "$TMPDIR/before-conservative-checks" "$PROJECT"

GENERATED=$TMPDIR/generated-models
"$ROOT/install.sh" --project "$GENERATED" --models-provider codex --no-import-skills --no-model-prompt
grep -Fq '## Runtime Provider Boundary' "$GENERATED/.agents/models.md"
grep -Fq '| Reviewer | `anthropic-sonnet-4-6` | `medium` | `anthropic` | `codex` | `terra` |' "$GENERATED/.agents/models.md"
grep -Fq 'Native Fallback Effort' "$GENERATED/.agents/models.md"
python3 -B "$GENERATED/scripts/check-workflow-policy.py" --input "$ROOT/tests/conformance/policy-chain.json"

grep -Fq '## Agent Run Summary' "$PROJECT/.tickets/template.md"
grep -Fq '## Role Handoff Evidence' "$PROJECT/.tickets/template.md"
grep -Fq 'runner completion operation' "$PROJECT/.tickets/template.md"
grep -Fq 'handoff-evidence.md' "$PROJECT/.agents/handoff.md"
test -f "$PROJECT/.agents/handoff-evidence.md"
test -f "$PROJECT/.agents/runtime-modes.md"
test -x "$PROJECT/scripts/check-workflow-policy.py"
python3 -B "$PROJECT/scripts/check-workflow-policy.py" --input "$ROOT/tests/conformance/policy-chain.json"
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
grep -Fq 'Assign verification proportionally' "$PROJECT/.agents/runbook.md"
grep -Fq 'evidence-only retry on an unchanged product tree' "$PROJECT/.agents/executor.md"
grep -Fq 'Do not rebuild the' "$PROJECT/.agents/reviewer.md"
grep -Fq 'smallest fresh risk-linked matrix' "$PROJECT/.agents/handoff.md"
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
grep -Fq '| Role | Model | Effort | Provider | Fallback Provider | Fallback Model | Economy Provider | Economy Model | Economy Effort |' "$PROJECT/.agents/models.md"
grep -Fq '## Availability And Usage Checks' "$PROJECT/.agents/models.md"
grep -Fq '## Runtime Provider Boundary' "$PROJECT/.agents/models.md"
grep -Fq 'official-chatgpt' "$PROJECT/.agents/models.md"
grep -Fq 'usage-exhausted' "$PROJECT/.agents/models.md"
grep -Fq '| Architect | `luna` | `xhigh` | `codex` | `anthropic` | `anthropic-sonnet-5` | - | - | - |' "$PROJECT/.agents/models.md"
grep -Fq '| Designer | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` | - | - | - |' "$PROJECT/.agents/models.md"
grep -Fq '| Executor | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` | `codex` | `luna` | `medium` |' "$PROJECT/.agents/models.md"
grep -Fq '| Reviewer | `anthropic-sonnet-4-6` | `medium` | `anthropic` | `codex` | `terra` | - | - | - |' "$PROJECT/.agents/models.md"
grep -Fq '| Second Reviewer | `gpt-5.5` | `high` | `codex` | `anthropic` | `anthropic-opus-4-8` | - | - | - |' "$PROJECT/.agents/models.md"
grep -Fq '| Tester | `terra` | `medium` | `codex` | `anthropic` | `anthropic-sonnet-5` | `codex` | `luna` | `medium` |' "$PROJECT/.agents/models.md"
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

mkdir "$LEASE_ROOT/dead.lease"
{
  printf '%s\n' 'resource=dead'
  printf '%s\n' 'pid=99999999'
  printf '%s\n' 'command=stale-test'
} > "$LEASE_ROOT/dead.lease/owner"
"$PROJECT/scripts/with-host-resource-lease.sh" --root "$LEASE_ROOT" --timeout 0 dead -- sh -c ':'
[ ! -e "$LEASE_ROOT/dead.lease" ]

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
mkdir "$PROJECT/.memory/custom"
printf '%s\n' 'custom nested memory' > "$PROJECT/.memory/custom/facts.md"
printf '%s\n' 'custom memory instructions' >> "$PROJECT/.memory/README.md"
cp -R "$PROJECT/.memory" "$TMPDIR/saved-memory"
printf '%s\n' 'custom project README' > "$PROJECT/README.md"
printf '%s\n' 'custom project instructions' >> "$PROJECT/AGENTS.md"
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
README_HASH=$(hash_file "$PROJECT/README.md")
AGENTS_HASH=$(hash_file "$PROJECT/AGENTS.md")

printf '%s\n' 'stale reusable ticket template' > "$PROJECT/.tickets/template.md"

"$ROOT/install.sh" --project "$PROJECT" --update --no-import-skills --no-model-prompt

[ "$TICKET_HASH" = "$(hash_file "$PROJECT/.tickets/SAFE-900.md")" ]
[ "$QUEUE_HASH" = "$(hash_file "$PROJECT/.tickets/queue.md")" ]
[ "$MEMORY_HASH" = "$(hash_file "$PROJECT/.memory/project.md")" ]
[ "$IMPORTED_SKILLS_HASH" = "$(hash_file "$PROJECT/.skills/imported.md")" ]
[ "$MODELS_HASH" = "$(hash_file "$PROJECT/.agents/models.md")" ]
[ "$README_HASH" = "$(hash_file "$PROJECT/README.md")" ]
[ "$AGENTS_HASH" = "$(hash_file "$PROJECT/AGENTS.md")" ]
diff -r "$TMPDIR/saved-memory" "$PROJECT/.memory"
grep -Fq '## Workspace And Integration Contract' "$PROJECT/.tickets/template.md"
! grep -Fq 'stale reusable ticket template' "$PROJECT/.tickets/template.md"
cmp "$ROOT/.agents/runtime-modes.md" "$PROJECT/.agents/runtime-modes.md"
cmp "$ROOT/scripts/check-workflow-policy.py" "$PROJECT/scripts/check-workflow-policy.py"
for module in __init__.py models.py handoff.py fingerprint.py; do
  cmp "$ROOT/scripts/workflow_policy/$module" "$PROJECT/scripts/workflow_policy/$module"
done
grep -Fq '## Second Review' "$PROJECT/.tickets/template.md"

python3 "$PROJECT/scripts/render-ticket-dashboard.py" --project "$PROJECT" --validate
python3 "$PROJECT/scripts/render-ticket-dashboard.py" --project "$PROJECT"
grep -Fq -- '**Design:** 1' "$PROJECT/docs/tickets.md"
grep -Fq 'Generated projection only' "$PROJECT/docs/tickets.md"
grep -Fq 'Generated projection only' "$PROJECT/docs/tickets.html"
python3 "$ROOT/tests/test-handoff-conformance.py"
python3 "$ROOT/tests/test-install-interactive.py"

echo "Installer update-preservation regression test passed."
