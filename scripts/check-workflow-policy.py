#!/usr/bin/env python3
"""Read-only reference checker. Does not attest sessions or complete tickets."""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
from workflow_policy.models import PolicyError, read_models
from workflow_policy.handoff import validate_handoff
from workflow_policy.fingerprint import fingerprint


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise PolicyError("invalid-input")
        result[key] = value
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--input", type=Path, help="Caller-supplied trusted snapshot and records JSON")
    source.add_argument("--fingerprint", type=Path, help="Frozen Git source tree; tracked and nonignored untracked files")
    parser.add_argument("--ticket-id", help="Exclude only this active ticket, queue and dashboard projections")
    parser.add_argument("--snapshot", action="store_true", help="Fingerprint a separately prepared immutable source directory, not a live non-Git root")
    parser.add_argument("--models", type=Path, default=Path(__file__).resolve().parent.parent / ".agents/models.md")
    args = parser.parse_args()
    try:
        if args.fingerprint:
            result = {"target": fingerprint(args.fingerprint, args.ticket_id, args.snapshot), "authenticated": False}
        else:
            payload = json.loads(args.input.read_text(), object_pairs_hook=unique_object)
            result = validate_handoff(payload, read_models(args.models))
    except PolicyError as error:
        result = {"valid": False, "authenticated": False, "error": error.code}
    except (OSError, ValueError, TypeError, KeyError, AttributeError, RecursionError):
        result = {"valid": False, "authenticated": False, "error": "invalid-input"}
    print(json.dumps(result, sort_keys=True))
    return 1 if result.get("valid") is False else 0


if __name__ == "__main__":
    raise SystemExit(main())
