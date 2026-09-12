#!/usr/bin/env python3
"""Executable policy regressions, independent of any runtime checkout."""
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
from workflow_policy.models import PolicyError, read_models, select_model
from workflow_policy.handoff import validate_handoff
from workflow_policy.fingerprint import fingerprint


class PolicyTests(unittest.TestCase):
    def setUp(self):
        self.models = read_models(ROOT / ".agents/models.md")
        self.base = json.loads((ROOT / "tests/conformance/policy-chain.json").read_text())

    def rejects(self, payload, code):
        with self.assertRaises(PolicyError) as error:
            validate_handoff(payload, self.models)
        self.assertEqual(error.exception.code, code)

    def test_runner_neutral_vectors(self):
        suite = json.loads((ROOT / "tests/conformance/handoff-evidence-fixtures.json").read_text())
        self.assertEqual(suite["schema_version"], 2)
        for case in suite["fixtures"]:
            with self.subTest(case=case["name"]):
                if case["expected"] == "accept":
                    validate_handoff(case["payload"], self.models)
                else:
                    self.rejects(case["payload"], case["expected"])

    def test_legacy_default_parity(self):
        expected = {
            "architect": ["luna", "xhigh", "codex", "anthropic", "anthropic-sonnet-5", "-", "-", "-"],
            "designer": ["terra", "medium", "codex", "anthropic", "anthropic-sonnet-5", "-", "-", "-"],
            "executor": ["terra", "medium", "codex", "anthropic", "anthropic-sonnet-5", "codex", "luna", "medium"],
            "reviewer": ["anthropic-sonnet-4-6", "medium", "anthropic", "codex", "terra", "-", "-", "-"],
            "second-reviewer": ["gpt-5.5", "high", "codex", "anthropic", "anthropic-opus-4-8", "-", "-", "-"],
            "tester": ["terra", "medium", "codex", "anthropic", "anthropic-sonnet-5", "codex", "luna", "medium"],
        }
        columns = ["Model", "Effort", "Provider", "Fallback Provider", "Fallback Model",
                   "Economy Provider", "Economy Model", "Economy Effort"]
        for role, values in expected.items():
            self.assertEqual(list(self.models[role])[:9], ["Role", *columns])
            self.assertEqual([self.models[role][column] for column in columns], values)
        self.assertTrue(all(row["Escalation Effort"] in {"-", "high"} for row in self.models.values()))

    def test_positive_transitions(self):
        validate_handoff(self.base, self.models)
        for source, target in [("In Progress", "Review"), ("Review", "Test")]:
            payload = copy.deepcopy(self.base)
            payload["snapshot"].update(from_state=source, to_state=target, operation="transition")
            validate_handoff(payload, self.models)

    def test_negative_record_cases(self):
        cases = [
            (0, "run_id", "absent", "missing-executor-evidence"),
            (1, "run_id", "absent", "missing-reviewer-evidence"),
            (2, "run_id", "absent", "missing-tester-evidence"),
            (1, "role", "architect", "wrong-role"),
            (1, "model", "sol", "model-mismatch"),
            (1, "provider", "anthropic", "model-mismatch"),
            (1, "effort", "high", "model-mismatch"),
            (1, "session_id", "other", "session-mismatch"),
            (2, "commit_sha", "b" * 40, "commit-mismatch"),
            (2, "ticket_id", "OTHER-100", "ticket-mismatch"),
            (2, "attempt_id", "old-attempt", "stale-attempt"),
            (2, "outcome", "fail", "nonpassing-record"),
            (1, "outcome", "blocked", "nonpassing-record"),
            (1, "started_at", "yesterday", "bad-timestamp"),
            (1, "started_at", "2026-01-01T00:02:00", "bad-timestamp"),
            (1, "started_at", "2026-01-01T00:02:00+00:99", "bad-timestamp"),
            (1, "completed_at", "2026-01-01T00:01:00Z", "bad-timestamp"),
            (2, "completed_at", "2026-01-01T00:11:00Z", "bad-timestamp"),
            (1, "started_at", "2026-01-01T00:00:30Z", "bad-timestamp"),
        ]
        for index, field, value, code in cases:
            with self.subTest(field=field, value=value):
                payload = copy.deepcopy(self.base)
                payload["records"][index][field] = value
                self.rejects(payload, code)

    def test_negative_snapshot_cases(self):
        cases = [("operation", "transition", "completion-operation-required"),
                 ("from_state", "In Progress", "invalid-transition"),
                 ("mode", "portable", "enforced-snapshot-required"),
                 ("commit_sha", "abc123", "invalid-commit"),
                 ("second_review_required", True, "missing-second-reviewer-evidence"),
                 ("integration", {"required": True}, "integration-required"),
                 ("integration", {"required": False, "reason": ""}, "integration-required")]
        for field, value, code in cases:
            with self.subTest(field=field, value=value):
                payload = copy.deepcopy(self.base)
                payload["snapshot"][field] = value
                self.rejects(payload, code)

    def test_identity_and_capability(self):
        for session, code in [("architect-session", "self-review"), ("executor-session", "reused-session")]:
            payload = copy.deepcopy(self.base)
            payload["snapshot"]["sessions"]["reviewer"] = session
            payload["records"][1]["session_id"] = session
            self.rejects(payload, code)
        payload = copy.deepcopy(self.base)
        payload["snapshot"]["runtime"]["capabilities"] = ["model-routing-v2"]
        self.rejects(payload, "enforcement-capability-required")
        payload = copy.deepcopy(self.base)
        payload["snapshot"]["assignments"]["reviewer"]["model"] = "sol"
        payload["records"][1]["model"] = "sol"
        self.rejects(payload, "assignment-mismatch")

    def test_stale_selected_pass_and_duplicate_ids(self):
        later = dict(self.base["records"][2], run_id="later-test", outcome="fail",
                     started_at="2026-01-01T00:06:00Z", completed_at="2026-01-01T00:07:00Z")
        self.base["records"].append(later)
        self.rejects(self.base, "stale-selected-run")
        self.base["records"][-1] = dict(self.base["records"][2])
        self.rejects(self.base, "duplicate-run-id")

    def test_integration_before_completion(self):
        integration = {"required": True, "commit_sha": "b" * 40,
                       "ticket_commits": ["a" * 40], "outcome": "pass",
                       "started_at": "2026-01-01T00:06:00Z", "completed_at": "2026-01-01T00:07:00Z"}
        self.base["snapshot"]["integration"] = {"required": True, "commit_sha": "b" * 40}
        self.base["integration_record"] = integration
        validate_handoff(self.base, self.models)
        for field, value in [("outcome", "fail"), ("commit_sha", "c" * 40), ("ticket_commits", [])]:
            payload = copy.deepcopy(self.base)
            payload["integration_record"][field] = value
            self.rejects(payload, "integration-required")
        self.base["integration_record"]["started_at"] = "2026-01-01T00:04:00Z"
        self.rejects(self.base, "bad-timestamp")

    def test_model_routes(self):
        runtime = self.base["snapshot"]["runtime"]
        def choose(role="executor", request=None, **changes):
            return select_model(self.models, role, request or {}, dict(runtime, **changes))
        self.assertEqual(choose()["model"], "terra")
        self.assertEqual(choose("architect")["model"], "luna")  # Unknown quota is usable.
        self.assertEqual(choose("reviewer")["candidate"], "fallback")
        economy = {"routing": "economy", "reason": "Mechanical rename", "low_risk": True,
                   "deterministic": True, "task": "mechanical", "commands": ["python3 test.py"]}
        self.assertEqual(choose(request=economy)["model"], "luna")
        self.assertEqual(choose("tester", economy)["model"], "luna")
        escalation = {"routing": "escalation", "authorized": True, "reason": "Unresolved architecture risk",
                      "trigger": "focused-difficult"}
        self.assertEqual(choose(request=escalation)["model"], "sol")
        self.assertEqual(choose(request=escalation)["effort"], "high")
        terra = {"provider": "codex", "model": "terra", "efforts": ["medium", "high"],
                 "availability": "available", "quota": "available"}
        sonnet = dict(terra, provider="anthropic", model="anthropic-sonnet-5", efforts=["medium", "xhigh"])
        self.assertEqual(choose("architect", models=[terra]),
                         {"provider": "codex", "model": "terra", "effort": "high", "candidate": "native-fallback"})
        custom = dict(harness="custom", allowed_providers=["codex", "anthropic"], models=[sonnet])
        self.assertEqual(choose("architect", **custom)["effort"], "medium")
        self.assertEqual(choose("architect", capabilities=[], **custom)["effort"], "xhigh")
        self.assertEqual(choose("architect", harness="official-claude", native_provider="anthropic",
                                allowed_providers=["anthropic"], models=[sonnet])["provider"], "anthropic")
        exhausted = dict(terra, model="luna", quota="exhausted")
        self.assertEqual(choose("tester", economy, models=[exhausted, terra])["model"], "terra")
        negatives = [
            ("reviewer", economy, {}, "invalid-economy"),
            ("executor", {"routing": "economy"}, {}, "invalid-economy"),
            ("tester", dict(economy, requires_judgment=True), {}, "invalid-economy"),
            ("executor", dict(escalation, authorized=False), {}, "invalid-escalation"),
            ("executor", dict(escalation, trigger="usage-exhausted"), {}, "invalid-escalation"),
            ("executor", escalation, {"capabilities": []}, "routing-capability-required"),
            ("executor", escalation, {"models": [dict(terra, model="sol", efforts=["xhigh"])]}, "routing-blocked"),
            ("architect", {}, {"capabilities": [], "models": [terra]}, "routing-blocked"),
            ("executor", {}, {"allowed_providers": []}, "provider-boundary"),
            ("executor", {}, {"allowed_providers": ["codex", "anthropic"]}, "provider-boundary"),
            ("executor", {}, {"harness": "unknown", "allowed_providers": ["codex", "anthropic"]}, "provider-boundary"),
            ("architect", {}, {"models": [dict(exhausted, quota="unknown", availability="transient", efforts=["xhigh"]), terra]}, "transient-retry-required"),
        ]
        for role, request, changes, code in negatives:
            with self.subTest(role=role, code=code):
                with self.assertRaises(PolicyError) as caught:
                    choose(role, request, **changes)
                self.assertEqual(caught.exception.code, code)

    def test_template_compatibility(self):
        text = (ROOT / ".tickets/template.md").read_text()
        for heading in ["ID", "Title", "State", "Problem", "Scope", "Out Of Scope", "Acceptance Criteria",
                        "Questioning Notes", "Likely Files", "Risks", "Rollback And Persistence", "Skill Context",
                        "Execution Model", "Designer Review", "TDD Plan", "Verification Plan", "Handoff Gates"]:
            self.assertIn("## " + heading + "\n", text)
        self.assertIn('- Executor routing: `routine`\n', text)
        self.assertIn('- Tester routing: `routine`\n', text)

    def test_canonical_model_selection_and_handoff(self):
        for provider in ("codex", "openai-codex"):
            with self.subTest(provider=provider):
                payload = copy.deepcopy(self.base)
                runtime = payload["snapshot"]["runtime"]
                for item in runtime["models"]:
                    item.update(provider=provider, model="gpt-5.6-" + item["model"])
                for item in list(payload["snapshot"]["assignments"].values()) + payload["records"]:
                    item.update(provider=provider, model="gpt-5.6-" + item["model"])
                selected = select_model(self.models, "architect", {}, runtime)
                self.assertEqual((selected["provider"], selected["model"]), (provider, "gpt-5.6-luna"))
                escalation = {"routing": "escalation", "authorized": True,
                              "reason": "Difficult problem", "trigger": "focused-difficult"}
                self.assertEqual(select_model(self.models, "executor", escalation, runtime)["model"], "gpt-5.6-sol")
                validate_handoff(payload, self.models)
                runtime.update(native_provider=provider, allowed_providers=[provider])
                validate_handoff(payload, self.models)
                payload["records"][0]["model"] = "terra"
                self.rejects(payload, "model-mismatch")  # Evidence must retain the actual ID.
                payload["snapshot"]["assignments"]["executor"]["model"] = "terra"
                self.rejects(payload, "assignment-mismatch")

    def test_aliases_preserve_provider_boundary(self):
        runtime = copy.deepcopy(self.base["snapshot"]["runtime"])
        terra = dict(runtime["models"][1], model="gpt-5.6-terra")
        for provider in ("openai", "openai-compatible", "anthropic"):
            with self.subTest(provider=provider):
                runtime["models"] = [dict(terra, provider=provider)]
                with self.assertRaises(PolicyError) as error:
                    select_model(self.models, "executor", {}, runtime)
                self.assertEqual(error.exception.code, "routing-blocked")
        runtime.update(harness="custom", allowed_providers=["codex", "openai-compatible"])
        runtime["models"] = [dict(terra, provider="openai-compatible")]
        with self.assertRaises(PolicyError) as error:
            select_model(self.models, "executor", {}, runtime)
        self.assertEqual(error.exception.code, "routing-blocked")
        runtime.update(harness="official-claude", native_provider="anthropic", allowed_providers=["anthropic"])
        runtime["models"] = [dict(terra, provider="anthropic", model="claude-sonnet-4-6")]
        selected = select_model(self.models, "reviewer", {}, runtime)
        self.assertEqual((selected["provider"], selected["model"]), ("anthropic", "claude-sonnet-4-6"))
        runtime["models"].append(dict(runtime["models"][0], model="anthropic-sonnet-4-6"))
        with self.assertRaises(PolicyError) as error:
            select_model(self.models, "reviewer", {}, runtime)
        self.assertEqual(error.exception.code, "invalid-input")

    def test_requires_judgment_is_strict_boolean(self):
        request = {"routing": "economy", "reason": "Named command", "deterministic": True,
                   "commands": ["python3 test.py"]}
        runtime = self.base["snapshot"]["runtime"]
        for value in (None, [], {}, 0, "", 1, "false"):
            with self.subTest(value=value):
                with self.assertRaises(PolicyError) as error:
                    select_model(self.models, "tester", dict(request, requires_judgment=value), runtime)
                self.assertEqual(error.exception.code, "invalid-economy")
        self.assertEqual(select_model(self.models, "tester", request, runtime)["candidate"], "economy")
        self.assertEqual(select_model(self.models, "tester", dict(request, requires_judgment=False), runtime)["candidate"], "economy")

    def test_enumeration_errors_fail_closed(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp).resolve()
            results = [subprocess.CompletedProcess([], 0, stdout=os.fsencode(root) + b"\n", stderr=b""),
                       subprocess.CompletedProcess([], 0, stdout=b"", stderr=b""),
                       subprocess.CompletedProcess([], 0, stdout=b"", stderr=b"warning: could not open directory 'source/': Permission denied\n"),
                       subprocess.CompletedProcess([], 0, stdout=b"", stderr=b"")] * 2
            with patch("workflow_policy.fingerprint.subprocess.run", side_effect=results):
                with self.assertRaises(PolicyError) as error:
                    fingerprint(root)
                self.assertEqual(error.exception.code, "incomplete-source-manifest")
            def denied_walk(*args, **kwargs):
                if kwargs.get("onerror"):
                    kwargs["onerror"](PermissionError("unreadable source/"))
                return iter(())
            with patch("workflow_policy.fingerprint.os.walk", side_effect=denied_walk):
                with self.assertRaises(PolicyError) as error:
                    fingerprint(root, snapshot=True)
                self.assertEqual(error.exception.code, "incomplete-source-manifest")

    def test_unreadable_source_permissions(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            source = root / "source"
            source.mkdir()
            module = source / "module.py"
            module.write_text("first content")
            for snapshot in (False, True):
                fingerprint(root, snapshot=snapshot)
            try:
                source.chmod(0)
                try:
                    with os.scandir(source):
                        pass
                except PermissionError:
                    pass
                else:
                    self.skipTest("Host bypasses directory permissions; deterministic enumeration mocks cover errors")
                for content in ("first content", "changed content"):
                    source.chmod(0o700)
                    module.write_text(content)
                    source.chmod(0)
                    for snapshot in (False, True):
                        with self.subTest(snapshot=snapshot, content=content):
                            with self.assertRaises(PolicyError) as error:
                                fingerprint(root, snapshot=snapshot)
                            self.assertEqual(error.exception.code, "incomplete-source-manifest")
            finally:
                source.chmod(0o700)

    def test_fingerprint(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / "tracked").write_text("one")
            subprocess.run(["git", "-C", str(root), "add", "tracked"], check=True)
            first = fingerprint(root)
            (root / ".git/irrelevant-metadata").write_text("changed")
            self.assertEqual(first, fingerprint(root))
            (root / "untracked").write_text("new")
            self.assertNotEqual(first, fingerprint(root))
            (root / ".gitignore").write_text("ignored\n")
            (root / "ignored").write_text("included")
            first = fingerprint(root)
            (root / "ignored").write_text("changed")
            self.assertEqual(first, fingerprint(root))
            (root / "ignored").unlink()
            os.mkfifo(root / "ignored")
            self.assertEqual(first, fingerprint(root))  # Ignored artifacts are not opened/scanned.
            first = fingerprint(root)
            (root / "tracked").chmod(0o755)
            self.assertNotEqual(first, fingerprint(root))
            (root / "link").symlink_to("tracked")
            first = fingerprint(root)
            (root / "link").unlink()
            (root / "link").symlink_to("untracked")
            self.assertNotEqual(first, fingerprint(root))
            first = fingerprint(root)
            (root / "tracked").unlink()
            self.assertNotEqual(first, fingerprint(root))

    def test_control_exclusions_keep_source_policy(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / ".tickets").mkdir()
            (root / "docs").mkdir()
            for name in ["template.md", "README.md", "POLICY-002.md", "queue.md"]:
                (root / ".tickets" / name).write_text("initial")
            first = fingerprint(root, "POLICY-002")
            (root / ".tickets/POLICY-002.md").write_text("Review -> Test; report notes")
            (root / ".tickets/queue.md").write_text("Test")
            (root / "docs/tickets.md").write_text("new projection")
            self.assertEqual(first, fingerprint(root, "POLICY-002"))
            self.assertNotEqual(first, fingerprint(root))  # Declaration is in identity.
            for name in ["template.md", "README.md"]:
                before = fingerprint(root, "POLICY-002")
                (root / ".tickets" / name).write_text("source policy change")
                self.assertNotEqual(before, fingerprint(root, "POLICY-002"))
            before = fingerprint(root, "POLICY-002")
            (root / "new-source.py").write_text("new source")
            self.assertNotEqual(before, fingerprint(root, "POLICY-002"))

    def test_cli_read_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "input.json"
            path.write_text(json.dumps(self.base))
            before = fingerprint(Path(tmp), snapshot=True)
            command = [sys.executable, "-B", str(ROOT / "scripts/check-workflow-policy.py"),
                       "--models", str(ROOT / ".agents/models.md"), "--input", str(path)]
            result = subprocess.run(command, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
            self.assertFalse(json.loads(result.stdout)["authenticated"])
            self.assertEqual(before, fingerprint(Path(tmp), snapshot=True))
            for invalid in ['{"snapshot": null}', '{"snapshot": {}, "snapshot": {}}', 'not json']:
                path.write_text(invalid)
                result = subprocess.run(command, text=True, capture_output=True)
                self.assertEqual(result.returncode, 1)
                self.assertEqual(json.loads(result.stdout)["error"], "invalid-input")


if __name__ == "__main__":
    unittest.main()
