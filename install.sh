#!/bin/sh
set -eu

usage() {
  cat <<'USAGE'
Usage:
  curl -fsSL https://raw.githubusercontent.com/dsmailes/dev-team/main/install.sh | sh -s -- --here
  ./install.sh --project /path/to/project
  ./install.sh --project /path/to/project --update
  ./install.sh --project /path/to/project --reset-project-state --force
  ./install.sh --project /path/to/project --import-skills /path/to/skills.md
  ./install.sh --project /path/to/project --models-provider codex
  ./install.sh --project /path/to/project --models-file /path/to/models.md
  /path/to/dev-team/install.sh --here
  ./install.sh --global

Options:
  --project PATH   Install workflow files, scripts, and README image assets into PATH.
  --here           Install workflow files, scripts, and README image assets into the current directory.
  --update         Update reusable workflow files while preserving project tickets, memory, README.md, and AGENTS.md.
  --reset-project-state
                   Delete all installed workflow state and reinstall it. Requires --force, prints every
                   affected path, requires confirmation, and creates a timestamped backup first.
  --dry-run        Print the planned preserve, replace, and delete operations without changing files.
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
  --force          Required with --reset-project-state. It never resets project state by itself.
  --help           Show this help.
USAGE
}

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

bootstrap_from_archive() {
  archive_url=${DEV_TEAM_WORKFLOW_PACK_TARBALL_URL:-https://github.com/dsmailes/dev-team/archive/refs/heads/main.tar.gz}
  tmpdir=$(mktemp -d)
  archive=$tmpdir/dev-team.tar.gz

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$archive_url" -o "$archive"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$archive" "$archive_url"
  else
    echo "error: one-line install requires curl or wget" >&2
    exit 1
  fi

  if ! command -v tar >/dev/null 2>&1; then
    echo "error: one-line install requires tar" >&2
    exit 1
  fi

  tar -xzf "$archive" -C "$tmpdir"
  for candidate in "$tmpdir"/dev-team "$tmpdir"/dev-team-*; do
    if [ -f "$candidate/install.sh" ]; then
      DEV_TEAM_WORKFLOW_BOOTSTRAPPED=1 exec sh "$candidate/install.sh" "$@"
    fi
  done

  echo "error: downloaded archive did not contain dev-team install.sh" >&2
  exit 1
}

case "$(basename -- "$0")" in
  install.sh) ;;
  *)
    if [ -z "${DEV_TEAM_WORKFLOW_BOOTSTRAPPED:-}" ]; then
      bootstrap_from_archive "$@"
    fi
    ;;
esac

if [ ! -d "$SOURCE_DIR/.agents" ] || [ ! -d "$SOURCE_DIR/.tickets" ] || [ ! -f "$SOURCE_DIR/scripts/render-ticket-dashboard.py" ]; then
  if [ -z "${DEV_TEAM_WORKFLOW_BOOTSTRAPPED:-}" ]; then
    bootstrap_from_archive "$@"
  fi
fi

TARGET_DIR=""
TARGET_KIND=""
FORCE=0
UPDATE=0
RESET_PROJECT_STATE=0
DRY_RUN=0
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
        echo "error: choose only one target: --project PATH, --here, or --global" >&2
        exit 2
      fi
      TARGET_DIR=$2
      TARGET_KIND=project
      shift 2
      ;;
    --here)
      if [ -n "$TARGET_DIR" ]; then
        echo "error: choose only one target: --project PATH, --here, or --global" >&2
        exit 2
      fi
      TARGET_DIR=.
      TARGET_KIND=project
      shift
      ;;
    --global)
      if [ -n "$TARGET_DIR" ]; then
        echo "error: choose only one target: --project PATH, --here, or --global" >&2
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
    --reset-project-state)
      RESET_PROJECT_STATE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
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
  echo "error: choose --project PATH, --here, or --global" >&2
  usage >&2
  exit 2
fi

if [ "$UPDATE" -eq 1 ] && [ "$FORCE" -eq 1 ]; then
  echo "error: choose either --update or --force, not both" >&2
  exit 2
fi

if [ "$UPDATE" -eq 1 ] && [ "$RESET_PROJECT_STATE" -eq 1 ]; then
  echo "error: choose either --update or --reset-project-state, not both" >&2
  exit 2
fi

if [ "$RESET_PROJECT_STATE" -eq 1 ] && [ "$FORCE" -ne 1 ]; then
  echo "error: --reset-project-state requires --force" >&2
  exit 2
fi

if [ "$UPDATE" -eq 1 ] && [ "$TARGET_KIND" != project ]; then
  echo "error: --update is only supported with --project PATH or --here" >&2
  exit 2
fi

if [ "$RESET_PROJECT_STATE" -eq 1 ] && [ "$TARGET_KIND" != project ]; then
  echo "error: --reset-project-state is only supported with --project PATH or --here" >&2
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

if [ "$DRY_RUN" -eq 1 ]; then
  if [ -d "$TARGET_DIR" ]; then
    TARGET_DIR=$(CDPATH= cd -- "$TARGET_DIR" && pwd)
  else
    target_parent=$(dirname -- "$TARGET_DIR")
    target_name=$(basename -- "$TARGET_DIR")
    if [ ! -d "$target_parent" ]; then
      echo "error: target parent does not exist for --dry-run: $target_parent" >&2
      exit 1
    fi
    TARGET_DIR=$(CDPATH= cd -- "$target_parent" && pwd)/$target_name
  fi
else
  TARGET_DIR=$(mkdir -p "$TARGET_DIR" && CDPATH= cd -- "$TARGET_DIR" && pwd)
fi

if [ "$TARGET_DIR" = / ]; then
  echo "error: refusing to install into filesystem root" >&2
  exit 2
fi

if [ "$TARGET_DIR" = "$SOURCE_DIR" ]; then
  echo "error: refusing to install or update this pack into itself" >&2
  exit 2
fi

is_existing_install() {
  [ -f "$TARGET_DIR/.agents/README.md" ] && \
    [ -f "$TARGET_DIR/.tickets/template.md" ] && \
    [ -f "$TARGET_DIR/scripts/render-ticket-dashboard.py" ]
}

show_existing_install_guidance() {
  echo "Existing dev-team installation detected." >&2
  echo "Run with --update to refresh workflow files while preserving tickets and memory." >&2
}

print_reset_paths() {
  for path in \
    "$TARGET_DIR/.agents" \
    "$TARGET_DIR/.skills" \
    "$TARGET_DIR/.tickets" \
    "$TARGET_DIR/.memory" \
    "$TARGET_DIR/scripts" \
    "$TARGET_DIR/docs/workflow-diagram.png" \
    "$TARGET_DIR/docs/ticket-dashboard-example.svg" \
    "$TARGET_DIR/DEV-TEAM-WORKFLOW.md" \
    "$TARGET_DIR/AGENTS.md"; do
    if [ -e "$path" ]; then
      find "$path" -print
    fi
  done | sort
}

print_dry_run_plan() {
  if [ "$RESET_PROJECT_STATE" -eq 1 ]; then
    echo "Dry run: reset project state in $TARGET_DIR"
    echo "Delete and replace:"
    print_reset_paths
    echo "Back up before reset: .tickets/, .memory/, AGENTS.md, and .agents/models.md"
  elif [ "$UPDATE" -eq 1 ]; then
    echo "Dry run: update reusable workflow files in $TARGET_DIR"
    echo "Replace: .agents role docs, .skills registry docs, dashboard script, image assets, ticket README/template, and DEV-TEAM-WORKFLOW.md"
    echo "Preserve: README.md, AGENTS.md, .agents/models.md, .tickets/queue.md, project tickets, .memory/, and .skills/imported.md"
  else
    echo "Dry run: install workflow files into $TARGET_DIR"
    echo "Create only missing workflow files; existing files will not be replaced."
  fi
}

backup_project_state() {
  timestamp=$(date +%Y%m%d-%H%M%S)
  backup_dir="$TARGET_DIR/.dev-team-backup-$timestamp"
  mkdir -p "$backup_dir/.agents"

  for path in .tickets .memory AGENTS.md .agents/models.md; do
    if [ -e "$TARGET_DIR/$path" ]; then
      parent=$(dirname -- "$path")
      mkdir -p "$backup_dir/$parent"
      cp -R "$TARGET_DIR/$path" "$backup_dir/$path"
    fi
  done

  echo "Backed up project state to $backup_dir"
}

confirm_project_reset() {
  echo "The following paths will be deleted and replaced:" >&2
  print_reset_paths >&2
  if [ ! -t 0 ]; then
    echo "error: --reset-project-state requires an interactive confirmation; rerun from a terminal." >&2
    exit 1
  fi
  printf "Type RESET to continue: " >&2
  read answer
  if [ "$answer" != RESET ]; then
    echo "Reset cancelled." >&2
    exit 1
  fi
}

reset_project_state() {
  backup_project_state
  rm -rf "$TARGET_DIR/.agents" "$TARGET_DIR/.skills" "$TARGET_DIR/.tickets" "$TARGET_DIR/.memory" "$TARGET_DIR/scripts"
  rm -f "$TARGET_DIR/docs/workflow-diagram.png" "$TARGET_DIR/docs/ticket-dashboard-example.svg"
  rm -f "$TARGET_DIR/DEV-TEAM-WORKFLOW.md" "$TARGET_DIR/AGENTS.md"
}

if [ "$DRY_RUN" -eq 1 ]; then
  print_dry_run_plan
  exit 0
fi

if is_existing_install && [ "$UPDATE" -ne 1 ] && [ "$RESET_PROJECT_STATE" -ne 1 ]; then
  show_existing_install_guidance
  exit 1
fi

if [ "$RESET_PROJECT_STATE" -eq 1 ]; then
  confirm_project_reset
  reset_project_state
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
    echo "error: $target already exists. Existing files are never replaced by a standard install." >&2
    echo "Use --update for an existing dev-team installation." >&2
    exit 1
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
    echo "error: $target already exists. Existing files are never replaced by a standard install." >&2
    echo "Use --update for an existing dev-team installation." >&2
    exit 1
  fi

  mkdir -p "$(dirname -- "$target")"
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
      MODEL_PROFILE=gpt-5.6-terra-high-sonnet-review
      ARCHITECT_MODEL=terra
      ARCHITECT_EFFORT=high
      ARCHITECT_PROVIDER=codex
      ARCHITECT_FALLBACK_MODEL=anthropic-sonnet-5
      ARCHITECT_FALLBACK_PROVIDER=anthropic
      DESIGNER_MODEL=terra
      DESIGNER_EFFORT=high
      DESIGNER_PROVIDER=codex
      DESIGNER_FALLBACK_MODEL=anthropic-sonnet-5
      DESIGNER_FALLBACK_PROVIDER=anthropic
      DESIGNER_ESCALATION="Escalate to sol only for an explicitly recorded difficult or multi-phase product/design decision. Do not escalate for ordinary UI work, routine polish, or quota recovery."
      EXECUTOR_MODEL=terra
      EXECUTOR_EFFORT=high
      EXECUTOR_PROVIDER=codex
      EXECUTOR_FALLBACK_MODEL=anthropic-sonnet-5
      EXECUTOR_FALLBACK_PROVIDER=anthropic
      EXECUTOR_ESCALATION="Escalate to sol only when a listed trigger applies: Terra is unavailable or has exhausted its usage, the ticket crosses architecture boundaries, the work is high-risk data/security/concurrency/migration logic, debugging remains blocked after reproduction, or Terra reports NEEDS_CONTEXT / BLOCKED and more reasoning is required. Use luna only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work. Do not escalate only because a ticket touches multiple files or ordinary integration code."
      REVIEWER_MODEL=anthropic-sonnet-5
      REVIEWER_EFFORT=medium
      REVIEWER_PROVIDER=anthropic
      REVIEWER_FALLBACK_MODEL=terra
      REVIEWER_FALLBACK_PROVIDER=codex
      SECOND_REVIEWER_MODEL=gpt-5.5
      SECOND_REVIEWER_EFFORT=high
      SECOND_REVIEWER_PROVIDER=codex
      SECOND_REVIEWER_FALLBACK_MODEL=anthropic-opus-4-8
      SECOND_REVIEWER_FALLBACK_PROVIDER=anthropic
      TESTER_MODEL=terra
      TESTER_EFFORT=high
      TESTER_PROVIDER=codex
      TESTER_FALLBACK_MODEL=anthropic-sonnet-5
      TESTER_FALLBACK_PROVIDER=anthropic
      ;;
    *)
      MODELS_PROVIDER=$provider_lc
      MODEL_PROFILE=inferred-provider-classes
      if [ "$provider_lc" = anthropic ]; then
        CROSS_PROVIDER=codex
        CROSS_REASONING=sol
        CROSS_CODING=terra
      else
        CROSS_PROVIDER=anthropic
        CROSS_REASONING=anthropic-opus-4-8
        CROSS_CODING=anthropic-sonnet-5
      fi
      ARCHITECT_MODEL="${provider_lc}-balanced-reasoning"
      ARCHITECT_EFFORT=high
      ARCHITECT_PROVIDER=$provider_lc
      ARCHITECT_FALLBACK_MODEL=$CROSS_REASONING
      ARCHITECT_FALLBACK_PROVIDER=$CROSS_PROVIDER
      DESIGNER_MODEL="${provider_lc}-balanced-design-reasoning"
      DESIGNER_EFFORT=high
      DESIGNER_PROVIDER=$provider_lc
      DESIGNER_FALLBACK_MODEL=$CROSS_REASONING
      DESIGNER_FALLBACK_PROVIDER=$CROSS_PROVIDER
      DESIGNER_ESCALATION="Escalate to ${provider_lc}-best-reasoning only for an explicitly recorded difficult or multi-phase product/design decision."
      EXECUTOR_MODEL="${provider_lc}-balanced-coding"
      EXECUTOR_EFFORT=high
      EXECUTOR_PROVIDER=$provider_lc
      EXECUTOR_FALLBACK_MODEL=$CROSS_CODING
      EXECUTOR_FALLBACK_PROVIDER=$CROSS_PROVIDER
      EXECUTOR_ESCALATION="Escalate only when a listed trigger applies: the balanced coding model is unavailable or has exhausted its usage, the ticket crosses architecture boundaries, the work is high-risk data/security/concurrency/migration logic, debugging remains blocked after reproduction, or the default model reports NEEDS_CONTEXT / BLOCKED and more reasoning is required. Use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work. Do not escalate only because a ticket touches multiple files or ordinary integration code."
      REVIEWER_MODEL="${provider_lc}-balanced-reasoning"
      REVIEWER_EFFORT=medium
      REVIEWER_PROVIDER=$provider_lc
      REVIEWER_FALLBACK_MODEL="${provider_lc}-balanced-reasoning"
      REVIEWER_FALLBACK_PROVIDER=$provider_lc
      SECOND_REVIEWER_MODEL="${provider_lc}-best-reasoning"
      SECOND_REVIEWER_EFFORT=high
      SECOND_REVIEWER_PROVIDER=$provider_lc
      SECOND_REVIEWER_FALLBACK_MODEL=$CROSS_REASONING
      SECOND_REVIEWER_FALLBACK_PROVIDER=$CROSS_PROVIDER
      TESTER_MODEL="${provider_lc}-balanced-reasoning"
      TESTER_EFFORT=high
      TESTER_PROVIDER=$provider_lc
      TESTER_FALLBACK_MODEL=$CROSS_CODING
      TESTER_FALLBACK_PROVIDER=$CROSS_PROVIDER
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
      REVIEWER_FALLBACK_MODEL=$(prompt_value "Reviewer fallback model" "$REVIEWER_FALLBACK_MODEL")
      SECOND_REVIEWER_MODEL=$(prompt_value "Second reviewer model" "$SECOND_REVIEWER_MODEL")
      SECOND_REVIEWER_EFFORT=$(prompt_value "Second reviewer effort" "$SECOND_REVIEWER_EFFORT")
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
- Notes: Generated by install.sh. For non-Codex providers, inferred names are provider-class placeholders unless you customized them. A fallback using another provider is eligible only when the runner explicitly permits that provider.

## Runtime Provider Boundary

The runner, not an agent, supplies this context before model selection:

\`\`\`yaml
runtime:
  harness: official-chatgpt | official-claude | custom | unknown
  allowed_providers: [$MODELS_PROVIDER]
\`\`\`

- \`official-chatgpt\` permits only \`codex\` models.
- \`official-claude\` permits only \`anthropic\` models.
- \`custom\` may use every provider explicitly listed in \`allowed_providers\`.
- \`unknown\` must not attempt a cross-provider model.

Do not infer the harness or allowed providers. A preferred or fallback model is
eligible only when its provider is allowed and the runtime exposes it.

## Availability And Usage Checks

Before spawning a role, check both of the following. Either failing means the
model is not usable and the runner must select the fallback:

1. **Availability**: the active runtime's model list exposes the preferred model.
2. **Usage**: the preferred model has remaining usage/quota. Treat an exhausted
   quota, rate-limit rejection, billing/credit failure, or any runtime signal
   that further calls to that model will be rejected the same as unavailable.

Record which condition failed (\`unavailable\` or \`usage-exhausted\`) and the
actual model selected in the ticket's \`Agent Run Summary\` and \`Execution Model\`
fallback reason. Do not retry the same exhausted model; move directly to the
fallback in the table below.

## Role Assignments

The table below is machine-readable. Runners select exactly one preferred or fallback assignment; prose in this file does not override its fields.

| Role | Model | Effort | Provider | Fallback Provider | Fallback Model |
| --- | --- | --- | --- | --- | --- |
| Architect | \`$ARCHITECT_MODEL\` | \`$ARCHITECT_EFFORT\` | \`$ARCHITECT_PROVIDER\` | \`$ARCHITECT_FALLBACK_PROVIDER\` | \`$ARCHITECT_FALLBACK_MODEL\` |
| Designer | \`$DESIGNER_MODEL\` | \`$DESIGNER_EFFORT\` | \`$DESIGNER_PROVIDER\` | \`$DESIGNER_FALLBACK_PROVIDER\` | \`$DESIGNER_FALLBACK_MODEL\` |
| Executor | \`$EXECUTOR_MODEL\` | \`$EXECUTOR_EFFORT\` | \`$EXECUTOR_PROVIDER\` | \`$EXECUTOR_FALLBACK_PROVIDER\` | \`$EXECUTOR_FALLBACK_MODEL\` |
| Reviewer | \`$REVIEWER_MODEL\` | \`$REVIEWER_EFFORT\` | \`$REVIEWER_PROVIDER\` | \`$REVIEWER_FALLBACK_PROVIDER\` | \`$REVIEWER_FALLBACK_MODEL\` |
| Second Reviewer | \`$SECOND_REVIEWER_MODEL\` | \`$SECOND_REVIEWER_EFFORT\` | \`$SECOND_REVIEWER_PROVIDER\` | \`$SECOND_REVIEWER_FALLBACK_PROVIDER\` | \`$SECOND_REVIEWER_FALLBACK_MODEL\` |
| Tester | \`$TESTER_MODEL\` | \`$TESTER_EFFORT\` | \`$TESTER_PROVIDER\` | \`$TESTER_FALLBACK_PROVIDER\` | \`$TESTER_FALLBACK_MODEL\` |

## Provider Mapping Guidance

For non-Codex providers, map roles by capability rather than by exact names:

- Architect: balanced reasoning model with high effort by default; escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase decision.
- Designer: balanced design/reasoning model with high effort by default; escalate to the best reasoning model only for an explicitly recorded difficult or multi-phase product or UI decision.
- Executor: balanced coding model by default; escalate to the best reasoning model as risk increases.
- Reviewer: balanced review/reasoning model with medium effort by default. Use the configured fallback only when required, and escalate to the best reasoning model only for an explicitly recorded difficult or high-risk review.
- Second Reviewer: an independent model used only for explicitly required adversarial review of the same commit.
- Tester: balanced reasoning model with high effort by default. Use a cost-efficient model only for narrow, deterministic, low-context checks; escalate to the best reasoning model for flaky, async, UI, failure-triage, or large-context work.
- Low-risk work: use the provider's most cost-efficient model only for explicitly low-risk documentation, ticket, formatting, or mechanical follow-up work.

Use a cross-provider fallback only when the runner explicitly permits both
providers. Official single-provider harnesses remain provider-local even if
the table names another provider. Custom runners may choose cross-provider
fallbacks to survive quota exhaustion or provider outages.

If exact provider model IDs are not known during installation, use provider-class placeholders such as \`anthropic-balanced-coding\` or \`google-best-reasoning\`, then replace them with the exact IDs supported by your local agent runner.
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
  replace_file .agents/handoff-evidence.md .agents/handoff-evidence.md
  replace_file .agents/prompts.md .agents/prompts.md
  replace_file .agents/reviewer.md .agents/reviewer.md
  replace_file .agents/runbook.md .agents/runbook.md
  replace_file .agents/tester.md .agents/tester.md
}

sync_scripts_for_update() {
  mkdir -p "$TARGET_DIR/scripts"
  replace_file scripts/render-ticket-dashboard.py scripts/render-ticket-dashboard.py
  replace_file scripts/with-host-resource-lease.sh scripts/with-host-resource-lease.sh
}

sync_docs_assets_for_update() {
  mkdir -p "$TARGET_DIR/docs"
  replace_file docs/workflow-diagram.png docs/workflow-diagram.png
  replace_file docs/ticket-dashboard-example.svg docs/ticket-dashboard-example.svg
}

maybe_prompt_for_skill_import
maybe_prompt_for_models

if [ "$UPDATE" -eq 1 ]; then
  sync_agents_for_update
  sync_scripts_for_update
  sync_docs_assets_for_update
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
  copy_dir scripts
  copy_file docs/workflow-diagram.png docs/workflow-diagram.png
  copy_file docs/ticket-dashboard-example.svg docs/ticket-dashboard-example.svg
  copy_file README.md DEV-TEAM-WORKFLOW.md
  copy_file AGENTS.md
  if [ "$MODEL_CONFIG_REQUESTED" -eq 1 ]; then
    write_models_config
  fi
  import_skills
  echo "Installed dev-team agent workflow pack to $TARGET_DIR"
fi
