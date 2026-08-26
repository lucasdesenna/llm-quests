#!/usr/bin/env bash
# Validate quest frontmatter and basic lifecycle fields.
# Usage: quest-validate.sh <quests-dir> <quest-id|/absolute/path/to/quest.md|all>
set -euo pipefail

quests_dir="${1:-}"
target="${2:-}"

if [ -z "$quests_dir" ] || [ -z "$target" ]; then
  echo "usage: quest-validate.sh <quests-dir> <quest-id|/absolute/path/to/quest.md|all>" >&2
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

valid_phases="scouting discovery planning formalization execution documentation improvement complete"
valid_complexities="tbd simple medium complex"

yaml_get() {
  local file="$1" key="$2"
  awk -v k="$key" '
    /^---$/ { blocks++; if (blocks == 2) exit; next }
    blocks == 1 && $0 ~ "^"k": " {
      sub("^"k": *", "")
      sub(" *#.*$", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$file"
}

validate_file() {
  local file="$1" dir id title phase complexity created updated failures=0
  dir="$(basename "$(dirname "$file")")"

  if [ ! -f "$file" ]; then
    echo "missing quest file: $file" >&2
    return 1
  fi
  if [ "$(head -1 "$file")" != "---" ]; then
    echo "$file: missing YAML frontmatter" >&2
    return 1
  fi

  id="$(yaml_get "$file" id)"
  title="$(yaml_get "$file" title)"
  phase="$(yaml_get "$file" phase)"
  complexity="$(yaml_get "$file" complexity)"
  created="$(yaml_get "$file" created)"
  updated="$(yaml_get "$file" updated)"

  for key in id title phase complexity created updated; do
    if [ -z "${!key}" ]; then
      echo "$file: missing frontmatter field '$key'" >&2
      failures=1
    fi
  done

  if [ "$id" != "$dir" ]; then
    echo "$file: id '$id' does not match directory '$dir'" >&2
    failures=1
  fi
  if ! grep -qw "$phase" <<< "$valid_phases"; then
    echo "$file: invalid phase '$phase'" >&2
    failures=1
  fi
  if ! grep -qw "$complexity" <<< "$valid_complexities"; then
    echo "$file: invalid complexity '$complexity'" >&2
    failures=1
  fi
  if ! [[ "$created" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "$file: created is not YYYY-MM-DD: '$created'" >&2
    failures=1
  fi
  if ! [[ "$updated" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "$file: updated is not YYYY-MM-DD: '$updated'" >&2
    failures=1
  fi

  return "$failures"
}

if [ "$target" = "all" ]; then
  failures=0
  for file in "$quests_dir"/*/quest.md; do
    [ -f "$file" ] || continue
    validate_file "$file" || failures=1
  done
  exit "$failures"
fi

case "$target" in
  /*) validate_file "$target" ;;
  *) validate_file "$quests_dir/$target/quest.md" ;;
esac
