#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --project /path/to/project [--force]
  ./install.sh --global [--force]

Options:
  --project PATH   Install .agents, .skills, .tickets, and .memory into PATH.
  --global         Install this pack to ~/.codex/agent-workflows/dev-team.
  --force          Replace existing installed workflow directories and workflow docs.
  --help           Show this help.
USAGE
}

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_DIR=""
FORCE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      if [ "$#" -lt 2 ]; then
        echo "error: --project requires a path" >&2
        exit 2
      fi
      TARGET_DIR=$2
      shift 2
      ;;
    --global)
      TARGET_DIR=${HOME}/.codex/agent-workflows/dev-team
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "$TARGET_DIR" ]; then
  echo "error: choose --project PATH or --global" >&2
  usage >&2
  exit 2
fi

TARGET_DIR=$(mkdir -p "$TARGET_DIR" && CDPATH= cd -- "$TARGET_DIR" && pwd)

copy_dir() {
  name=$1
  source=$SOURCE_DIR/$name
  target=$TARGET_DIR/$name

  if [ ! -d "$source" ]; then
    echo "error: missing source directory: $source" >&2
    exit 1
  fi

  if [ -e "$target" ]; then
    if [ "$FORCE" -ne 1 ]; then
      echo "error: $target already exists. Re-run with --force to replace it." >&2
      exit 1
    fi
    rm -rf "$target"
  fi

  cp -R "$source" "$target"
}

copy_file() {
  source_name=$1
  target_name=${2:-$1}
  source=$SOURCE_DIR/$source_name
  target=$TARGET_DIR/$target_name

  if [ ! -f "$source" ]; then
    echo "error: missing source file: $source" >&2
    exit 1
  fi

  if [ -e "$target" ]; then
    if [ "$FORCE" -ne 1 ]; then
      echo "error: $target already exists. Re-run with --force to replace it." >&2
      exit 1
    fi
    rm -f "$target"
  fi

  cp "$source" "$target"
}

copy_dir .agents
copy_dir .skills
copy_dir .tickets
copy_dir .memory
copy_file README.md DEV-TEAM-WORKFLOW.md
copy_file AGENTS.md

echo "Installed dev-team agent workflow pack to $TARGET_DIR"
