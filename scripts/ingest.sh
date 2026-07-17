#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
# Fold pending records for a registry into its append-only file, assigning tok ids.
#   ./ingest.sh <registry-id> [--apply]     (dry-run by default; you commit)
set -euo pipefail
cd "$(dirname "$0")/.."
REG="${1:?usage: ingest.sh <registry-id> [--apply]}"; APPLY=0
[ "${2:-}" = "--apply" ] && APPLY=1
command -v jq >/dev/null || { echo "jq required"; exit 3; }
DEF="registries/${REG}.json"; [ -f "$DEF" ] || { echo "unknown registry: $REG"; exit 3; }
JL=$(jq -r '.records' "$DEF"); INBOX="registry/${REG}/inbox"
next_n(){ local last; last=$(grep -oE "\"tok:${REG}:[0-9]{4}\"" "$JL" 2>/dev/null | grep -oE '[0-9]{4}' | sort -n | tail -1); echo $(( 10#${last:-0} + 1 )); }
n=$(next_n)
shopt -s nullglob; pending=("$INBOX"/*.json)
[ ${#pending[@]} -gt 0 ] || { echo "nothing pending in $INBOX"; exit 0; }
tmp="$(mktemp -u ./.ingest.XXXX)"; trap 'rm -f "$tmp"' EXIT
for f in "${pending[@]}"; do
  id=$(printf 'tok:%s:%04d' "$REG" "$n"); jq -c --arg t "$id" '.tok=$t' "$f" >> "$tmp"; n=$((n+1))
done
echo "== would append $(wc -l < "$tmp") record(s) to $JL =="; cat "$tmp"
if [ "$APPLY" = 1 ]; then cat "$tmp" >> "$JL"; rm -f "${pending[@]}"
  echo "✓ appended and cleared inbox. Review 'git diff', then commit."
else echo "(dry run — re-run with --apply)"; fi
