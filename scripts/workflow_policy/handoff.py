"""Validate supplied attempt snapshots and selected records; never write state."""
from datetime import datetime
import re

from .models import PolicyError, nonempty, require, select_model


def timestamp(value):
    require(isinstance(value, str) and re.fullmatch(
        r"\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d+)?(?:Z|[+-](?:[01]\d|2[0-3]):[0-5]\d)", value), "bad-timestamp")
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise PolicyError("bad-timestamp") from error


def commit(value):
    return isinstance(value, str) and re.fullmatch(r"(?:[0-9a-f]{40}|[0-9a-f]{64})", value)


def interval(record, earliest, latest):
    started = timestamp(record.get("started_at"))
    completed = timestamp(record.get("completed_at"))
    require(earliest <= started <= completed <= latest, "bad-timestamp")
    return completed


def validate_handoff(payload, table):
    require(isinstance(payload, dict) and isinstance(payload.get("snapshot"), dict), "invalid-input")
    snapshot = payload["snapshot"]
    require(snapshot.get("mode") == "enforced", "enforced-snapshot-required")
    runtime = snapshot.get("runtime")
    require(isinstance(runtime, dict), "invalid-input")
    require("handoff-evidence-v2" in runtime.get("capabilities", []), "enforcement-capability-required")
    for key in ("ticket_id", "attempt_id", "orchestrator_session_id"):
        require(nonempty(snapshot.get(key)), "invalid-input")
    require(commit(snapshot.get("commit_sha")), "invalid-commit")
    source, target = snapshot.get("from_state"), snapshot.get("to_state")
    transitions = {("In Progress", "Review"): ["executor"],
                   ("Review", "Test"): ["executor", "reviewer"],
                   ("Test", "Done"): ["executor", "reviewer", "tester"]}
    require((source, target) in transitions, "invalid-transition")
    if target == "Done":
        require(snapshot.get("operation") == "complete", "completion-operation-required")
    else:
        require(snapshot.get("operation") == "transition", "invalid-transition")
    require(isinstance(snapshot.get("second_review_required"), bool), "invalid-input")
    roles = list(transitions[source, target])
    if snapshot["second_review_required"] and target != "Review":
        roles.insert(2, "second-reviewer")
    for key in ("assignments", "sessions", "selected_runs"):
        require(isinstance(snapshot.get(key), dict), "invalid-input")
    records = payload.get("records")
    require(isinstance(records, list) and all(isinstance(record, dict) for record in records), "invalid-input")
    require(all(nonempty(record.get("run_id")) for record in records), "invalid-input")
    by_id = {record["run_id"]: record for record in records}
    require(len(by_id) == len(records), "duplicate-run-id")
    earliest, latest = timestamp(snapshot.get("started_at")), timestamp(snapshot.get("observed_at"))
    require(earliest <= latest, "bad-timestamp")
    sessions = {snapshot["orchestrator_session_id"]}
    previous = earliest
    for role in roles:
        record = by_id.get(snapshot["selected_runs"].get(role))
        require(record is not None, "missing-" + role + "-evidence")
        require(record.get("role") == role, "wrong-role")
        require(record.get("ticket_id") == snapshot["ticket_id"], "ticket-mismatch")
        require(record.get("attempt_id") == snapshot["attempt_id"], "stale-attempt")
        require(record.get("commit_sha") == snapshot["commit_sha"], "commit-mismatch")
        session = record.get("session_id")
        require(nonempty(session) and session == snapshot["sessions"].get(role), "session-mismatch")
        require(session != snapshot["orchestrator_session_id"], "self-review")
        require(session not in sessions, "reused-session")
        sessions.add(session)
        assignment = snapshot["assignments"].get(role)
        require(isinstance(assignment, dict), "assignment-mismatch")
        selected = select_model(table, role, assignment.get("request", {}), runtime)
        for field in ("provider", "model", "effort"):
            require(assignment.get(field) == selected[field], "assignment-mismatch")
            require(record.get(field) == assignment[field], "model-mismatch")
        require(record.get("outcome") == "pass", "nonpassing-record")
        previous = interval(record, previous, latest)
        for other in records:
            if other is record or (other.get("ticket_id"), other.get("attempt_id"), other.get("role")) != (
                    snapshot["ticket_id"], snapshot["attempt_id"], role):
                continue
            completed = interval(other, earliest, latest)
            require(completed < previous, "stale-selected-run")
    if target == "Done":
        integration = snapshot.get("integration")
        require(isinstance(integration, dict) and isinstance(integration.get("required"), bool), "integration-required")
        if integration["required"]:
            record = payload.get("integration_record", {})
            require(isinstance(record, dict) and commit(integration.get("commit_sha")) and
                    record.get("commit_sha") == integration["commit_sha"] and record.get("outcome") == "pass" and
                    isinstance(record.get("ticket_commits"), list) and snapshot["commit_sha"] in record["ticket_commits"],
                    "integration-required")
            interval(record, previous, latest)
        else:
            require(nonempty(integration.get("reason")), "integration-required")
    return {"valid": True, "authenticated": False, "scope": "supplied-policy-data-only"}
