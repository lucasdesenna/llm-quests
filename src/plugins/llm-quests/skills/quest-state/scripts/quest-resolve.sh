#!/usr/bin/env bash
# Resolve a quest identifier to a single quest row from quest-list.sh.
# Output is the CSV row without the header: id,title,phase,complexity,created,updated,path
# Usage: quest-resolve.sh <quests-dir> <id-or-query>
set -euo pipefail

quests_dir="${1:-}"
query="${2:-}"

if [ -z "$quests_dir" ] || [ -z "$query" ]; then
  echo "usage: quest-resolve.sh <quests-dir> <id-or-query>" >&2
  exit 2
fi
case "$quests_dir" in
  /*) ;;
  *) echo "quests-dir must be an absolute path: $quests_dir" >&2; exit 2 ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="${CLAUDE_SKILL_DIR:-${CODEX_SKILL_DIR:-${SKILL_DIR:-$(cd "$script_dir/.." && pwd)}}}"
skills_dir="$(cd "$skill_dir/.." && pwd)"
quest_list_script="$skills_dir/quest-list/scripts/quest-list.sh"

rows="$(bash "$quest_list_script" "$quests_dir" | tail -n +2)"
if [ -z "$rows" ]; then
  echo "no quests found" >&2
  exit 1
fi

match_rows() {
  local mode="$1"
  awk -F',' -v q="$query" -v mode="$mode" '
    BEGIN { ql=tolower(q) }
    {
      id=tolower($1)
      if ((mode == "exact" && id == ql) ||
          (mode == "prefix" && index(id, ql) == 1) ||
          (mode == "substring" && index(id, ql) > 0)) {
        print
      }
    }
  ' <<< "$rows"
}

for mode in exact prefix substring; do
  matches="$(match_rows "$mode")"
  count="$(grep -c . <<< "$matches" || true)"
  if [ "$count" -eq 1 ]; then
    printf '%s\n' "$matches"
    exit 0
  fi
  if [ "$count" -gt 1 ]; then
    echo "ambiguous quest identifier: $query" >&2
    printf '%s\n' "$matches" >&2
    exit 3
  fi
done

echo "no quest matched: $query" >&2
exit 1
