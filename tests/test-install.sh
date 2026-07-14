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

grep -Fq '## Agent Run Summary' "$PROJECT/.tickets/template.md"
grep -Fq 'Token usage' "$PROJECT/.tickets/template.md"
grep -Fq '## Source Isolation' "$PROJECT/.tickets/template.md"
grep -Fq 'Execution mode: `serialized`' "$PROJECT/.tickets/template.md"
grep -Fq 'Verification worktree' "$PROJECT/.tickets/template.md"
grep -Fq 'Ticket commit SHA' "$PROJECT/.tickets/template.md"

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
cat > "$PROJECT/.agents/models.md" <<'EOF'
# Custom project model configuration

This file must survive a plain update.
EOF

TICKET_HASH=$(hash_file "$PROJECT/.tickets/SAFE-900.md")
QUEUE_HASH=$(hash_file "$PROJECT/.tickets/queue.md")
MEMORY_HASH=$(hash_file "$PROJECT/.memory/project.md")
MODELS_HASH=$(hash_file "$PROJECT/.agents/models.md")

"$ROOT/install.sh" --project "$PROJECT" --update --no-import-skills --no-model-prompt

[ "$TICKET_HASH" = "$(hash_file "$PROJECT/.tickets/SAFE-900.md")" ]
[ "$QUEUE_HASH" = "$(hash_file "$PROJECT/.tickets/queue.md")" ]
[ "$MEMORY_HASH" = "$(hash_file "$PROJECT/.memory/project.md")" ]
[ "$MODELS_HASH" = "$(hash_file "$PROJECT/.agents/models.md")" ]
grep -Fq 'Execution mode: `serialized`' "$PROJECT/.tickets/template.md"
grep -Fq 'Verification worktree' "$PROJECT/.tickets/template.md"
grep -Fq 'Ticket commit SHA' "$PROJECT/.tickets/template.md"

python3 "$PROJECT/scripts/render-ticket-dashboard.py" --project "$PROJECT" --validate
python3 "$PROJECT/scripts/render-ticket-dashboard.py" --project "$PROJECT"
grep -Fq -- '**Design:** 1' "$PROJECT/docs/tickets.md"

echo "Installer update-preservation regression test passed."
