#!/usr/bin/env python3
"""Exercise the installer's real terminal prompts using only the standard library."""

import errno
import os
from pathlib import Path
import pty
import select
import subprocess
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]


class InteractiveInstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="install-interactive-")
        self.addCleanup(self.temp.cleanup)
        self.project = Path(self.temp.name) / "project"

    def install(self, *args, dialogue=(), expected_code=0):
        master, slave = pty.openpty()
        process = subprocess.Popen(
            ["sh", str(ROOT / "install.sh"), "--project", str(self.project),
             "--no-import-skills", *args],
            stdin=slave, stdout=slave, stderr=slave,
        )
        os.close(slave)
        output = bytearray()
        step = 0
        consumed = 0
        deadline = time.monotonic() + 30
        try:
            while True:
                if time.monotonic() >= deadline:
                    self.fail(f"Installer timed out at dialogue step {step}:\n"
                              + output.decode(errors="replace"))
                if not select.select([master], [], [], 0.1)[0]:
                    continue
                try:
                    chunk = os.read(master, 65536)
                except OSError as error:
                    if error.errno != errno.EIO:
                        raise
                    break
                if not chunk:
                    break
                output.extend(chunk)
                if step < len(dialogue):
                    prompt, answer = dialogue[step]
                    index = output.find(prompt.encode(), consumed)
                    if index >= 0:
                        consumed = index + len(prompt.encode())
                        os.write(master, (answer + "\n").encode())
                        step += 1
            code = process.wait(timeout=5)
        finally:
            if process.poll() is None:
                process.kill()
                process.wait()
            os.close(master)
        transcript = output.decode(errors="replace")
        self.assertEqual(code, expected_code, transcript)
        self.assertEqual(step, len(dialogue), transcript)
        return transcript

    def test_custom_models_and_efforts_survive_generation(self):
        for provider, normalized in [("", "codex"), ("OpenAI", "codex"),
                                     ("Example", "example")]:
            with self.subTest(provider=provider):
                self.project = Path(self.temp.name) / (provider or "default")
                dialogue = [("Model provider for agents [codex]: ", provider),
                            ("Customize per-agent model choices? [y/N] ", "y")]
                roles = [("Architect", "low"), ("Designer", "high"),
                         ("Executor", "xhigh"), ("Reviewer", "low"),
                         ("Second reviewer", "medium"), ("Tester", "high")]
                for role, effort in roles:
                    model = "custom-" + role.lower().replace(" ", "-")
                    dialogue.extend([(role + " model [", model),
                                     (role + " effort [", effort)])
                    if role == "Reviewer":
                        dialogue.append(("Reviewer fallback model [", "custom-fallback"))
                self.install(dialogue=dialogue)
                models = (self.project / ".agents/models.md").read_text()
                self.assertIn(f"- Provider: `{normalized}`", models)
                for role, effort in roles:
                    model = "custom-" + role.lower().replace(" ", "-")
                    self.assertIn(f"| {role.title()} | `{model}` | `{effort}` |", models)
                reviewer = next(line for line in models.splitlines()
                                if line.startswith("| Reviewer |"))
                self.assertIn("`custom-fallback`", reviewer)

    def test_blank_answers_keep_defaults(self):
        dialogue = [("Model provider for agents [codex]: ", ""),
                    ("Customize per-agent model choices? [y/N] ", "yes")]
        for role in ["Architect", "Designer", "Executor", "Reviewer",
                     "Second reviewer", "Tester"]:
            dialogue.extend([(role + " model [", ""), (role + " effort [", "")])
            if role == "Reviewer":
                dialogue.append(("Reviewer fallback model [", ""))
        self.install(dialogue=dialogue)
        models = (self.project / ".agents/models.md").read_bytes()
        self.install("--update", "--models-provider", "codex", "--no-model-prompt")
        self.assertEqual(models, (self.project / ".agents/models.md").read_bytes())

    def test_update_preserves_models_without_prompting(self):
        self.install("--no-model-prompt")
        path = self.project / ".agents/models.md"
        path.write_text("# User model configuration\n")
        self.install("--update")
        self.assertEqual(path.read_text(), "# User model configuration\n")

    def test_confirmed_reset_backs_up_state_and_installs_clean_board(self):
        self.install("--no-model-prompt")
        files = [".tickets/USER-001.md", ".tickets/queue.md", ".memory/project.md",
                 ".agents/models.md", "AGENTS.md"]
        for name in files:
            (self.project / name).write_text(f"user state: {name}\n")
        self.install("--reset-project-state", "--force", "--no-model-prompt",
                     dialogue=[("Type RESET to continue: ", "RESET")])
        backups = list(self.project.glob(".dev-team-backup-*"))
        self.assertEqual(len(backups), 1)
        for name in files:
            self.assertEqual((backups[0] / name).read_text(), f"user state: {name}\n")
        self.assertEqual(sorted(p.name for p in (self.project / ".tickets").iterdir()),
                         ["README.md", "queue.md", "template.md"])
        self.assertNotIn("user state", (self.project / ".memory/project.md").read_text())

    def test_cancelled_reset_preserves_state(self):
        self.install("--no-model-prompt")
        before = {p.relative_to(self.project): p.read_bytes()
                  for p in self.project.rglob("*") if p.is_file()}
        self.install("--reset-project-state", "--force", "--no-model-prompt",
                     dialogue=[("Type RESET to continue: ", "no")], expected_code=1)
        after = {p.relative_to(self.project): p.read_bytes()
                 for p in self.project.rglob("*") if p.is_file()}
        self.assertEqual(before, after)


if __name__ == "__main__":
    unittest.main()
