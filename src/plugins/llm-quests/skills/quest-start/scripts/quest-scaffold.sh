#!/usr/bin/env bash
# Create a quest directory from quest-start reference templates.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="${CLAUDE_SKILL_DIR:-${CODEX_SKILL_DIR:-${SKILL_DIR:-$(cd "$script_dir/.." && pwd)}}}"

quest_id="${1:-}"
title="${2:-}"
problem_definition="${3:-}"
today="$(date +%Y-%m-%d)"

if [ -z "$quest_id" ] || [ -z "$title" ] || [ -z "$problem_definition" ]; then
  echo "usage: quest-scaffold.sh <quest-id> <title> <problem-definition>" >&2
  exit 2
fi

quest_dir="quests/$quest_id"
quest_file="$quest_dir/quest.md"

if [ -e "$quest_dir" ]; then
  echo "quest already exists: $quest_dir" >&2
  exit 1
fi

if ! command -v envsubst >/dev/null 2>&1; then
  echo "envsubst is required to render quest templates" >&2
  exit 1
fi

knowledge_dirs=(sources findings decisions patterns summaries)
mkdir -p "$quest_dir/agent-tasks" "$quest_dir/knowledge"
for dir in "${knowledge_dirs[@]}"; do
  mkdir -p "$quest_dir/knowledge/$dir"
  touch "$quest_dir/knowledge/$dir/.gitkeep"
done
touch "$quest_dir/agent-tasks/.gitkeep"

title_yaml="${title//\"/\\\"}"
render_vars='$QUEST_ID $QUEST_TITLE $QUEST_TITLE_YAML $TODAY $QUEST_PROBLEM_DEFINITION'

env QUEST_ID="$quest_id" QUEST_TITLE="$title" QUEST_TITLE_YAML="$title_yaml" TODAY="$today" QUEST_PROBLEM_DEFINITION="$problem_definition" \
  envsubst "$render_vars" < "$skill_dir/references/quest-template.md" > "$quest_file"
env QUEST_ID="$quest_id" QUEST_TITLE="$title" QUEST_TITLE_YAML="$title_yaml" TODAY="$today" QUEST_PROBLEM_DEFINITION="$problem_definition" \
  envsubst "$render_vars" < "$skill_dir/references/knowledge-index-template.md" > "$quest_dir/knowledge/index.md"

init_quest_repo() {
  [ "${QUEST_INIT_GIT:-1}" = "0" ] && return 0
  if ! command -v git >/dev/null 2>&1; then
    echo "note: git not found; skipping quest repo init" >&2
    return 0
  fi
  [ -d "$quest_dir/.git" ] && return 0

  if ! git init -q "$quest_dir" >&2; then
    echo "warning: git init failed; quest scaffolded without a repo" >&2
    return 0
  fi
  git -C "$quest_dir" add -A >&2 || true
  if ! git -C "$quest_dir" commit -q -m "chore: scaffold quest $quest_id" >&2; then
    echo "warning: no initial commit (set git user.name/user.email); files are staged" >&2
  fi
}

init_quest_repo

echo "$quest_file"
