#!/usr/bin/env python3
"""Run executable reference cases; optionally smoke the actual Pi parser."""
import argparse
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pi-project", type=Path)
    args = parser.parse_args()
    subprocess.run([sys.executable, "-B", str(ROOT / "tests/test-policy-reference.py")], check=True)
    if args.pi_project:
        subprocess.run([sys.executable, "-B", str(ROOT / "tests/pi-parser-smoke.py"),
                        str(args.pi_project), str(ROOT)], check=True)


if __name__ == "__main__":
    main()
