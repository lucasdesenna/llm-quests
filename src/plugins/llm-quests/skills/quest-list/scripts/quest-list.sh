#!/usr/bin/env bash
# Lists quests from YAML frontmatter in quests/*/quest.md.
# Output is CSV, sorted by `updated` descending.
# Usage: quest-list.sh [--active]
#   --active  filter out completed quests (phase=complete|completed|done)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="${CLAUDE_SKILL_DIR:-${CODEX_SKILL_DIR:-${SKILL_DIR:-$(cd "$script_dir/.." && pwd)}}}"

active_only=0

for arg in "$@"; do
  case "$arg" in
    --active) active_only=1 ;;
    -h|--help)
      sed -n '2,5p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

# Locate the quests directory. The current shell directory is unreliable (the
# caller may have cd'd into a service repo or the skill dir), so try, in order:
#   1. an explicit QUESTS_DIR override
#   2. the nearest `quests/` directory walking up from $PWD
#   3. a launch-directory hint from the harness
# Fail loudly if none is found rather than silently printing an empty list.
resolve_quests_dir() {
  if [ -n "${QUESTS_DIR:-}" ]; then
    printf '%s\n' "$QUESTS_DIR"
    return 0
  fi

  local dir="$PWD"
  while :; do
    if [ -d "$dir/quests" ]; then
      printf '%s\n' "$dir/quests"
      return 0
    fi
    [ "$dir" = "/" ] && break
    dir="$(dirname "$dir")"
  done

  local hint
  for hint in "${CLAUDE_PROJECT_DIR:-}" "${CMUX_AGENT_LAUNCH_CWD:-}"; do
    if [ -n "$hint" ] && [ -d "$hint/quests" ]; then
      printf '%s\n' "$hint/quests"
      return 0
    fi
  done

  return 1
}

if ! QUESTS_DIR="$(resolve_quests_dir)"; then
  echo "error: could not locate a 'quests/' directory." >&2
  echo "  Run from your quests project (or a subdirectory), or set QUESTS_DIR=/path/to/quests." >&2
  exit 1
fi

# Read a scalar from the first YAML frontmatter block.
# Strips surrounding double quotes if present.
yaml_get() {
  local file="$1" key="$2"
  awk -v k="$key" '
    /^---$/ { blocks++; if (blocks == 2) exit; next }
    blocks == 1 && $0 ~ "^"k": " {
      sub("^"k": *", "")
      if (substr($0,1,1) == "\"" && substr($0,length($0),1) == "\"") {
        $0 = substr($0, 2, length($0)-2)
      }
      print
      exit
    }
  ' "$file"
}

rows=()
for qf in "$QUESTS_DIR"/*/quest.md; do
  [ -f "$qf" ] || continue
  dir="$(basename "$(dirname "$qf")")"

  if [ "$(head -1 "$qf")" != "---" ]; then
    echo "warning: skipping $qf (no frontmatter)" >&2
    continue
  fi

  id="$(yaml_get "$qf" id)"
  title="$(yaml_get "$qf" title)"
  phase="$(yaml_get "$qf" phase)"
  complexity="$(yaml_get "$qf" complexity)"
  created="$(yaml_get "$qf" created)"
  updated="$(yaml_get "$qf" updated)"

  if [ "$id" != "$dir" ]; then
    echo "warning: id/dir mismatch in $qf (id=$id, dir=$dir)" >&2
  fi

  if [ "$active_only" -eq 1 ]; then
    case "$phase" in
      complete|completed|done) continue ;;
    esac
  fi

  # CSV-escape title: wrap in quotes, double any embedded quotes.
  title_csv="\"${title//\"/\"\"}\""
  # Prefix with updated for sorting, then strip before printing.
  rows+=("$updated|$id,$title_csv,$phase,$complexity,$created,$updated,$qf")
done

printf 'id,title,phase,complexity,created,updated,path\n'
if [ "${#rows[@]}" -gt 0 ]; then
  printf '%s\n' "${rows[@]}" | sort -t'|' -k1,1r | cut -d'|' -f2-
fi
