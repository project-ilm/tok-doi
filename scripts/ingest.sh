#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
# Fold pending signatures into the append-only registry, assigning tok ids in order.
# Sources: registry/pie/inbox/*.json (from GitHub compose-URL) and/or an exported
# Google-Sheet CSV. DRY-RUN by default; --apply writes. The human commits.
#   ./ingest.sh                 # dry run (inbox)
#   ./ingest.sh --csv form.csv  # dry run (csv)
#   ./ingest.sh --apply         # append inbox records, then delete them
set -euo pipefail
cd "$(dirname "$0")/.."
JL=registry/pie/signatures.jsonl
APPLY=0; CSV=""
while [ $# -gt 0 ]; do case "$1" in --apply)APPLY=1;; --csv)CSV="$2";shift;; esac; shift; done
command -v jq >/dev/null || { echo "jq required"; exit 3; }

next_n(){ local last; last=$(grep -oE '"tok:pie:[0-9]{4}"' "$JL" 2>/dev/null | grep -oE '[0-9]{4}' | sort -n | tail -1); echo $(( 10#${last:-0} + 1 )); }
n=$(next_n)
pending=(registry/pie/inbox/tok-pie-*.json)
[ -e "${pending[0]:-}" ] || { [ -z "$CSV" ] && { echo "nothing pending in inbox/"; exit 0; }; pending=(); }

emit(){ # $1 = record json (string)
  local id; id=$(printf 'tok:pie:%04d' "$n")
  echo "$1" | jq -c --arg t "$id" '.tok=$t'
  n=$((n+1))
}
tmp="$(mktemp -u ./.ingest.XXXX)"   # in-folder (no /tmp), removed on exit
trap 'rm -f "$tmp"' EXIT
for f in "${pending[@]}"; do emit "$(cat "$f")" >> "$tmp"; done
[ -n "$CSV" ] && echo "note: CSV path is a stub — map columns to SCHEMA.json fields before enabling."

echo "== would append $(wc -l < "$tmp" 2>/dev/null || echo 0) record(s), ids from tok:pie:$(printf '%04d' "$((n-${#pending[@]}))") =="
cat "$tmp" 2>/dev/null || true
if [ "$APPLY" = 1 ]; then
  cat "$tmp" >> "$JL"; rm -f "${pending[@]}"
  echo "✓ appended to $JL and cleared inbox. Review 'git diff', then commit yourself."
else
  echo "(dry run — nothing written. Re-run with --apply.)"
fi
