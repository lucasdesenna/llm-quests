#!/usr/bin/env bash
# Lists quests from YAML frontmatter in <quests-dir>/*/quest.md.
# Output is CSV, sorted by `updated` descending.
# Usage: quest-list.sh <quests-dir> [--active]
#   --active  filter out completed quests (phase=complete|completed|done)
set -euo pipefail

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  sed -n '2,5p' "$0" | sed 's/^# \?//'
  exit 0
fi

quests_dir="${1:-}"
if [ -z "$quests_dir" ]; then
  echo "usage: quest-list.sh <quests-dir> [--active]" >&2
  exit 2
fi
shift

case "$quests_dir" in
  /*) ;;
  *) echo "quests-dir must be an absolute path: $quests_dir" >&2; exit 2 ;;
esac
if [ ! -d "$quests_dir" ]; then
  echo "quests-dir does not exist or is not a directory: $quests_dir" >&2
  exit 2
fi

active_only=0

for arg in "$@"; do
  case "$arg" in
    --active) active_only=1 ;;
    -h|--help) echo "--help must be the first argument" >&2; exit 2 ;;
    *) echo "unknown flag: $arg" >&2; exit 2 ;;
  esac
done

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
for qf in "$quests_dir"/*/quest.md; do
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
