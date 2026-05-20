#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage:
  ./install.sh --project /path/to/project [--force]
  ./install.sh --project /path/to/project --update
  ./install.sh --project /path/to/project --import-skills /path/to/skills.md
  ./install.sh --project /path/to/project --models-provider codex
  ./install.sh --project /path/to/project --models-file /path/to/models.md
  ./install.sh --global [--force]

Options:
  --project PATH   Install .agents, .skills, .tickets, and .memory into PATH.
  --update         Update reusable workflow files while preserving project tickets, memory, README.md, and AGENTS.md.
  --import-skills PATH
                   Import a local skill registry into .skills/imported.md.
  --no-import-skills
                   Do not prompt for skill import during interactive project installs.
  --models-provider PROVIDER
                   Generate .agents/models.md for a provider. Defaults to codex.
                   Known exact profile: codex. Other providers use inferred role-class placeholders.
  --models-file PATH
                   Import an exact model configuration into .agents/models.md.
  --no-model-prompt
                   Do not prompt for model choices during interactive project installs.
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
IMPORT_SKILLS_PATH=""
NO_IMPORT_SKILLS=0
MODELS_PROVIDER=""
MODELS_FILE=""
NO_MODEL_PROMPT=0
MODEL_CONFIG_REQUESTED=0

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
    --import-skills)
      if [ "$#" -lt 2 ]; then
        echo "error: --import-skills requires a path" >&2
        exit 2
      fi
      IMPORT_SKILLS_PATH=$2
      shift 2
      ;;
    --no-import-skills)
      NO_IMPORT_SKILLS=1
      shift
      ;;
    --models-provider)
      if [ "$#" -lt 2 ]; then
        echo "error: --models-provider requires a provider name" >&2
        exit 2
      fi
      MODELS_PROVIDER=$2
      MODEL_CONFIG_REQUESTED=1
      shift 2
      ;;
    --models-file)
      if [ "$#" -lt 2 ]; then
        echo "error: --models-file requires a path" >&2
        exit 2
      fi
      MODELS_FILE=$2
      MODEL_CONFIG_REQUESTED=1
      shift 2
      ;;
    --no-model-prompt)
      NO_MODEL_PROMPT=1
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

if [ "$NO_IMPORT_SKILLS" -eq 1 ] && [ -n "$IMPORT_SKILLS_PATH" ]; then
  echo "error: choose either --import-skills PATH or --no-import-skills, not both" >&2
  exit 2
fi

if [ -n "$MODELS_PROVIDER" ] && [ -n "$MODELS_FILE" ]; then
  echo "error: choose either --models-provider PROVIDER or --models-file PATH, not both" >&2
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

maybe_prompt_for_skill_import() {
  if [ "$TARGET_KIND" != project ]; then
    return
  fi

  if [ "$NO_IMPORT_SKILLS" -eq 1 ] || [ -n "$IMPORT_SKILLS_PATH" ]; then
    return
  fi

  if [ ! -t 0 ]; then
    return
  fi

  printf "Import a local skill registry into .skills/imported.md? [y/N] "
  read answer
  case "$answer" in
    y|Y|yes|YES)
      printf "Path to skill registry markdown file: "
      read IMPORT_SKILLS_PATH
      ;;
    *)
      NO_IMPORT_SKILLS=1
      ;;
  esac
}

import_skills() {
  if [ -z "$IMPORT_SKILLS_PATH" ]; then
    return
  fi

  if [ ! -f "$IMPORT_SKILLS_PATH" ]; then
    echo "error: skill registry import file does not exist: $IMPORT_SKILLS_PATH" >&2
    exit 1
  fi

  mkdir -p "$TARGET_DIR/.skills"
  cp "$IMPORT_SKILLS_PATH" "$TARGET_DIR/.skills/imported.md"
  echo "Imported local skill registry to $TARGET_DIR/.skills/imported.md"
}

set_model_defaults() {
  provider=$1
  provider_lc=$(printf '%s' "$provider" | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz')

  case "$provider_lc" in
    ""|codex|openai)
      MODELS_PROVIDER=codex
      MODEL_PROFILE=codex-defaults
      ARCHITECT_MODEL=gpt-5.5
      ARCHITECT_EFFORT=high
      DESIGNER_MODEL=gpt-5.4
      DESIGNER_EFFORT=high
      DESIGNER_ESCALATION="gpt-5.5 with high effort for important product decisions, broad workflow design, brand-sensitive UI, or major design-system changes."
      EXECUTOR_MODEL=gpt-5.3-codex-spark
      EXECUTOR_EFFORT=high
      EXECUTOR_ESCALATION="gpt-5.3-codex for ordinary multi-file work, gpt-5.4 for complex cross-module work, and gpt-5.5 for the most complex implementation work."
      REVIEWER_MODEL=gpt-5.5
      REVIEWER_EFFORT=high
      TESTER_MODEL=gpt-5.4
      TESTER_EFFORT=medium
      ;;
    *)
      MODELS_PROVIDER=$provider_lc
      MODEL_PROFILE=inferred-provider-classes
      ARCHITECT_MODEL="${provider_lc}-best-reasoning"
      ARCHITECT_EFFORT=high
      DESIGNER_MODEL="${provider_lc}-balanced-reasoning"
      DESIGNER_EFFORT=high
      DESIGNER_ESCALATION="${provider_lc}-best-reasoning with high effort for important product decisions, broad workflow design, brand-sensitive UI, or major design-system changes."
      EXECUTOR_MODEL="${provider_lc}-fast-coding"
      EXECUTOR_EFFORT=high
      EXECUTOR_ESCALATION="${provider_lc}-coding for ordinary multi-file work, ${provider_lc}-balanced-reasoning for complex cross-module work, and ${provider_lc}-best-reasoning for the most complex implementation work."
      REVIEWER_MODEL="${provider_lc}-best-reasoning"
      REVIEWER_EFFORT=high
      TESTER_MODEL="${provider_lc}-balanced-reasoning"
      TESTER_EFFORT=medium
      ;;
  esac
}

prompt_value() {
  label=$1
  default_value=$2
  printf "%s [%s]: " "$label" "$default_value" >&2
  read answer
  if [ -n "$answer" ]; then
    printf '%s' "$answer"
  else
    printf '%s' "$default_value"
  fi
}

maybe_prompt_for_models() {
  if [ "$TARGET_KIND" != project ]; then
    return
  fi

  if [ "$NO_MODEL_PROMPT" -eq 1 ] || [ "$MODEL_CONFIG_REQUESTED" -eq 1 ]; then
    return
  fi

  if [ "$UPDATE" -eq 1 ] && [ -f "$TARGET_DIR/.agents/models.md" ]; then
    return
  fi

  if [ ! -t 0 ]; then
    return
  fi

  printf "Model provider for agents [codex]: "
  read MODELS_PROVIDER
  if [ -z "$MODELS_PROVIDER" ]; then
    MODELS_PROVIDER=codex
  fi
  MODEL_CONFIG_REQUESTED=1

  set_model_defaults "$MODELS_PROVIDER"

  printf "Customize per-agent model choices? [y/N] "
  read answer
  case "$answer" in
    y|Y|yes|YES)
      ARCHITECT_MODEL=$(prompt_value "Architect model" "$ARCHITECT_MODEL")
      ARCHITECT_EFFORT=$(prompt_value "Architect effort" "$ARCHITECT_EFFORT")
      DESIGNER_MODEL=$(prompt_value "Designer model" "$DESIGNER_MODEL")
      DESIGNER_EFFORT=$(prompt_value "Designer effort" "$DESIGNER_EFFORT")
      EXECUTOR_MODEL=$(prompt_value "Executor model" "$EXECUTOR_MODEL")
      EXECUTOR_EFFORT=$(prompt_value "Executor effort" "$EXECUTOR_EFFORT")
      REVIEWER_MODEL=$(prompt_value "Reviewer model" "$REVIEWER_MODEL")
      REVIEWER_EFFORT=$(prompt_value "Reviewer effort" "$REVIEWER_EFFORT")
      TESTER_MODEL=$(prompt_value "Tester model" "$TESTER_MODEL")
      TESTER_EFFORT=$(prompt_value "Tester effort" "$TESTER_EFFORT")
      ;;
  esac
}

write_models_config() {
  if [ -n "$MODELS_FILE" ]; then
    if [ ! -f "$MODELS_FILE" ]; then
      echo "error: model configuration file does not exist: $MODELS_FILE" >&2
      exit 1
    fi
    mkdir -p "$TARGET_DIR/.agents"
    cp "$MODELS_FILE" "$TARGET_DIR/.agents/models.md"
    echo "Imported model configuration to $TARGET_DIR/.agents/models.md"
    return
  fi

  if [ -z "$MODELS_PROVIDER" ]; then
    MODELS_PROVIDER=codex
  fi

  set_model_defaults "$MODELS_PROVIDER"
  mkdir -p "$TARGET_DIR/.agents"

  cat > "$TARGET_DIR/.agents/models.md" <<EOF
# Agent Model Configuration

This file is project-local. Keep it aligned with the provider and model names available in the environment where agents are spawned.

## Provider

- Provider: \`$MODELS_PROVIDER\`
- Profile: \`$MODEL_PROFILE\`
- Notes: Generated by install.sh. For non-Codex providers, inferred names are provider-class placeholders unless you customized them.

## Role Assignments

| Role | Default model | Effort | Escalation |
| --- | --- | --- | --- |
| Architect | \`$ARCHITECT_MODEL\` | \`$ARCHITECT_EFFORT\` | Use the strongest available reasoning model for ambiguous architecture, migrations, or high-risk planning. |
| Designer | \`$DESIGNER_MODEL\` | \`$DESIGNER_EFFORT\` | Use $DESIGNER_ESCALATION |
| Executor | \`$EXECUTOR_MODEL\` | \`$EXECUTOR_EFFORT\` | Use $EXECUTOR_ESCALATION |
| Reviewer | \`$REVIEWER_MODEL\` | \`$REVIEWER_EFFORT\` | Use the strongest available reasoning model for security, data-loss, concurrency, migration, or public API risk. |
| Tester | \`$TESTER_MODEL\` | \`$TESTER_EFFORT\` | Use high effort for flaky tests, complex async behavior, UI automation, or difficult failure triage. |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: best reasoning model.
- Designer: balanced reasoning model; escalate to best reasoning for major product or UI decisions.
- Executor: fast coding model by default; escalate to stronger coding or reasoning models as risk increases.
- Reviewer: best reasoning model.
- Tester: balanced reasoning model; raise effort for flaky, async, UI, or failure-triage work.

If exact provider model IDs are not known during installation, use provider-class placeholders such as \`anthropic-fast-coding\` or \`google-best-reasoning\`, then replace them with the exact IDs supported by your local agent runner.
EOF
  echo "Wrote model configuration to $TARGET_DIR/.agents/models.md"
}

sync_agents_for_update() {
  mkdir -p "$TARGET_DIR/.agents"
  replace_file .agents/README.md .agents/README.md
  replace_file .agents/architect.md .agents/architect.md
  replace_file .agents/designer.md .agents/designer.md
  replace_file .agents/executor.md .agents/executor.md
  replace_file .agents/handoff.md .agents/handoff.md
  replace_file .agents/prompts.md .agents/prompts.md
  replace_file .agents/reviewer.md .agents/reviewer.md
  replace_file .agents/runbook.md .agents/runbook.md
  replace_file .agents/tester.md .agents/tester.md
}

maybe_prompt_for_skill_import
maybe_prompt_for_models

if [ "$UPDATE" -eq 1 ]; then
  sync_agents_for_update
  if [ "$MODEL_CONFIG_REQUESTED" -eq 1 ] || [ ! -f "$TARGET_DIR/.agents/models.md" ]; then
    write_models_config
  fi
  mkdir -p "$TARGET_DIR/.skills"
  replace_file .skills/README.md .skills/README.md
  replace_file .skills/principles.md .skills/principles.md
  replace_file .skills/registry.md .skills/registry.md
  mkdir -p "$TARGET_DIR/.tickets"
  replace_file .tickets/README.md .tickets/README.md
  replace_file .tickets/template.md .tickets/template.md
  replace_file README.md DEV-TEAM-WORKFLOW.md
  import_skills
  echo "Updated reusable dev-team workflow files in $TARGET_DIR"
else
  copy_dir .agents
  copy_dir .skills
  copy_dir .tickets
  copy_dir .memory
  copy_file README.md DEV-TEAM-WORKFLOW.md
  copy_file AGENTS.md
  if [ "$MODEL_CONFIG_REQUESTED" -eq 1 ]; then
    write_models_config
  fi
  import_skills
  echo "Installed dev-team agent workflow pack to $TARGET_DIR"
fi
