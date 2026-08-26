#!/usr/bin/env bash
# Validate whether a quest phase transition is allowed.
set -euo pipefail

from="${1:-}"
to="${2:-}"

if [ -z "$from" ] || [ -z "$to" ]; then
  echo "usage: quest-transition.sh <from-phase> <to-phase>" >&2
  exit 2
fi

order="scouting discovery planning formalization execution documentation improvement complete"

phase_index() {
  local phase="$1" i=0 p
  for p in $order; do
    if [ "$p" = "$phase" ]; then
      echo "$i"
      return 0
    fi
    i=$((i + 1))
  done
  return 1
}

from_i="$(phase_index "$from" || true)"
to_i="$(phase_index "$to" || true)"

if [ -z "$from_i" ] || [ -z "$to_i" ]; then
  echo "unknown phase: $from -> $to" >&2
  exit 1
fi

if [ "$to_i" -le "$from_i" ]; then
  echo "transition must move forward: $from -> $to" >&2
  exit 1
fi

echo "valid transition: $from -> $to"
