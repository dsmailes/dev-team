# Role Handoff Evidence Contract

This is the portable contract for runner-generated evidence. The runner may
store records in a ticket section or in an external ledger, but it is the
authoritative writer and validator. Agent-authored Markdown, including an
`Agent Run Summary` or a statement of the model used, is status context only
and never proves a handoff.

## Record Schema

Each record is immutable and contains these fields:

```json
{
  "run_id": "runner-generated unique ID",
  "ticket_id": "APP-123",
  "role": "executor | reviewer | tester",
  "provider": "provider ID",
  "model": "model ID",
  "effort": "low | medium | high",
  "session_id": "runner session ID",
  "commit_sha": "immutable commit SHA",
  "outcome": "pass | fail | blocked",
  "started_at": "RFC 3339 timestamp",
  "completed_at": "RFC 3339 timestamp"
}
```

The runner records the selected assignment against `.agents/models.md`; a
preferred or fallback assignment may be used only when its provider, model, and
effort match that machine-readable configuration.

## Protected Transitions

- `In Progress -> Review` requires one passing `executor` record.
- `Review -> Test` requires one passing `reviewer` record that references the
  executor record's `commit_sha` and uses an independent session ID.
- `Test -> Done` requires one passing `tester` record that references the
  executor record's `commit_sha` and uses an independent session ID from both
  Executor and Reviewer.

The Architect cannot supply Executor, Reviewer, or Tester evidence. Protected
evidence requirements are not waivable in normal mode. A runner may offer an
explicit exceptional policy only when the project has opted into it and records
the policy decision outside agent-authored ticket prose.

`Test -> Done` is a completion operation, not a generic state edit. The runner
must reject a direct `Done` move that did not evaluate the passing Tester
record and the protected-transition chain.
