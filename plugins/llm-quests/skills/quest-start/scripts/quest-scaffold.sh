#!/usr/bin/env bash
# Create a quest directory from quest-start reference templates.
# Usage: quest-scaffold.sh <quests-dir> <quest-id> <title> <problem-definition>
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="${CLAUDE_SKILL_DIR:-${CODEX_SKILL_DIR:-${SKILL_DIR:-$(cd "$script_dir/.." && pwd)}}}"

quests_dir="${1:-}"
quest_id="${2:-}"
title="${3:-}"
problem_definition="${4:-}"

if [ -z "$quests_dir" ] || [ -z "$quest_id" ] || [ -z "$title" ] || [ -z "$problem_definition" ]; then
  echo "usage: quest-scaffold.sh <quests-dir> <quest-id> <title> <problem-definition>" >&2
  exit 2
fi
case "$quests_dir" in
  /*) ;;
  *) echo "quests-dir must be an absolute path: $quests_dir" >&2; exit 2 ;;
esac
if [ ! -d "$quests_dir" ]; then
  echo "quests-dir does not exist or is not a directory: $quests_dir" >&2
  exit 2
fi
today="$(date +%Y-%m-%d)"

quest_dir="$quests_dir/$quest_id"
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

echo "$quest_file"
