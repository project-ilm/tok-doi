#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
#
# push.sh — attested git push. Subject digest is the commit SHA (git-native).
#   ./attest/push.sh [remote] [ref]                       # preview
#   ./attest/push.sh [remote] [ref] --confirm <shortsha> --reason "why"
set -euo pipefail
cd "$(dirname "$0")/.."
REMOTE="origin" REF="HEAD" CONFIRM="" REASON=""
while [ $# -gt 0 ]; do case "$1" in
  --confirm) CONFIRM="$2";shift;; --reason) REASON="$2";shift;;
  *) if [ "$REMOTE" = origin ] && [ "$1" != HEAD ]; then REMOTE="$1"; else REF="$1"; fi;; esac; shift; done
COMMIT="$(git rev-parse HEAD)"
if [ -z "$CONFIRM" ]; then
  bash attest/candor.sh --subject "git commit" --digest "$COMMIT" --action push \
    --target "$REMOTE $REF" || true
  exit 0
fi
bash attest/candor.sh --subject "git commit" --digest "$COMMIT" --action push \
  --target "$REMOTE $REF" --reason "$REASON" --confirm "$CONFIRM"
echo "→ git push $REMOTE $REF"
git push "$REMOTE" "$REF"
