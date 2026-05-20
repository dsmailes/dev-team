#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --project /path/to/project [--force]
  ./install.sh --project /path/to/project --update
  ./install.sh --global [--force]

Options:
  --project PATH   Install .agents, .skills, .tickets, and .memory into PATH.
  --update         Update reusable workflow files while preserving project tickets, memory, README.md, and AGENTS.md.
  --global         Install this pack to ~/.codex/agent-workflows/dev-team.
  --force          Replace existing installed workflow directories and workflow docs.
  --help           Show this help.
USAGE
}

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_DIR=""
TARGET_KIND=""
FORCE=0
UPDATE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      if [ "$#" -lt 2 ]; then
        echo "error: --project requires a path" >&2
        exit 2
      fi
      if [ -n "$TARGET_DIR" ]; then
        echo "error: choose only one target: --project PATH or --global" >&2
        exit 2
      fi
      TARGET_DIR=$2
      TARGET_KIND=project
      shift 2
      ;;
    --global)
      if [ -n "$TARGET_DIR" ]; then
        echo "error: choose only one target: --project PATH or --global" >&2
        exit 2
      fi
      TARGET_DIR=${HOME}/.codex/agent-workflows/dev-team
      TARGET_KIND=global
      shift
      ;;
    --update)
      UPDATE=1
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

if [ "$UPDATE" -eq 1 ] && [ "$FORCE" -eq 1 ]; then
  echo "error: choose either --update or --force, not both" >&2
  exit 2
fi

if [ "$UPDATE" -eq 1 ] && [ "$TARGET_KIND" != project ]; then
  echo "error: --update is only supported with --project PATH" >&2
  exit 2
fi

TARGET_DIR=$(mkdir -p "$TARGET_DIR" && CDPATH= cd -- "$TARGET_DIR" && pwd)

if [ "$TARGET_DIR" = / ]; then
  echo "error: refusing to install into filesystem root" >&2
  exit 2
fi

if [ "$TARGET_DIR" = "$SOURCE_DIR" ]; then
  echo "error: refusing to install or update this pack into itself" >&2
  exit 2
fi

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

replace_dir() {
  name=$1
  source=$SOURCE_DIR/$name
  target=$TARGET_DIR/$name

  if [ ! -d "$source" ]; then
    echo "error: missing source directory: $source" >&2
    exit 1
  fi

  rm -rf "$target"
  cp -R "$source" "$target"
}

replace_file() {
  source_name=$1
  target_name=${2:-$1}
  source=$SOURCE_DIR/$source_name
  target=$TARGET_DIR/$target_name

  if [ ! -f "$source" ]; then
    echo "error: missing source file: $source" >&2
    exit 1
  fi

  mkdir -p "$(dirname -- "$target")"
  rm -f "$target"
  cp "$source" "$target"
}

if [ "$UPDATE" -eq 1 ]; then
  replace_dir .agents
  replace_dir .skills
  mkdir -p "$TARGET_DIR/.tickets"
  replace_file .tickets/README.md .tickets/README.md
  replace_file .tickets/template.md .tickets/template.md
  replace_file README.md DEV-TEAM-WORKFLOW.md
  echo "Updated reusable dev-team workflow files in $TARGET_DIR"
else
  copy_dir .agents
  copy_dir .skills
  copy_dir .tickets
  copy_dir .memory
  copy_file README.md DEV-TEAM-WORKFLOW.md
  copy_file AGENTS.md
  echo "Installed dev-team agent workflow pack to $TARGET_DIR"
fi
