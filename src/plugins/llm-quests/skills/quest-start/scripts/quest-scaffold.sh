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

is_git_available() {
  command -v git >/dev/null 2>&1
}

init_quest_repo() {
  git init -q "$quest_dir" && \
  git -C "$quest_dir" add -A && \
  git -C "$quest_dir" commit -q -m "setup quest: $quest_id" || true
}

if is_git_available; then
  init_quest_repo
fi

echo "$quest_file"
