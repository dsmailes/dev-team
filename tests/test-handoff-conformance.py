#!/usr/bin/env python3
"""Validate portable role-handoff conformance fixtures and source contract."""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
FIXTURES = ROOT / "tests/conformance/handoff-evidence-fixtures.json"
REQUIRED_FIELDS = {
    "run_id", "ticket_id", "role", "provider", "model", "effort", "session_id",
    "commit_sha", "outcome", "started_at", "completed_at",
}


def main():
    data = json.loads(FIXTURES.read_text())
    assert set(data["schema_fields"]) == REQUIRED_FIELDS

    fixtures = {fixture["name"]: fixture for fixture in data["fixtures"]}
    expected_rejections = {
        "rejects-architect-self-review": "reject:self-review",
        "rejects-missing-executor-evidence": "reject:missing-executor-evidence",
        "rejects-model-mismatch": "reject:model-mismatch",
        "rejects-reused-session": "reject:reused-session",
        "rejects-commit-mismatch": "reject:commit-mismatch",
        "rejects-direct-done-move": "reject:completion-operation-required",
    }
    for name, expected in expected_rejections.items():
        assert fixtures[name]["expected"] == expected

    accepted = fixtures["accepts-independent-passing-chain"]
    records = accepted["records"]
    assert all(set(record) == REQUIRED_FIELDS for record in records)
    assert [record["role"] for record in records] == ["executor", "reviewer", "tester"]
    assert all(record["outcome"] == "pass" for record in records)
    assert len({record["session_id"] for record in records}) == 3
    assert len({record["commit_sha"] for record in records}) == 1

    evidence = (ROOT / ".agents/handoff-evidence.md").read_text()
    handoff = (ROOT / ".agents/handoff.md").read_text()
    template = (ROOT / ".tickets/template.md").read_text()
    prompts = (ROOT / ".agents/prompts.md").read_text()
    models = (ROOT / ".agents/models.md").read_text()

    for field in REQUIRED_FIELDS:
        assert field in evidence
    assert "independent session ID" in evidence
    assert "completion operation" in evidence
    assert "Runner-managed" in template
    assert "generic ticket-state editing" in handoff.lower()
    assert "Do not edit `.tickets/` or runner evidence files directly." in prompts
    assert "| Role | Model | Effort | Provider | Fallback Provider | Fallback Model |" in models

    print("Handoff evidence conformance fixtures passed.")


if __name__ == "__main__":
    main()
