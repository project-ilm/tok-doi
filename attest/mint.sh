#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
#
# mint.sh — mint this repo's Zenodo DOI with ONE command. No file arguments, no
# path juggling. Files + metadata come from doi/misty-doi.yaml. You authorize with
# a git-style short digest + reason (Parwana v1); the intent is OTS-attested; then
# misty mints. Nothing is minted without your --confirm.
#
#   ./attest/mint.sh                          # preview: prints the digest to confirm
#   ./attest/mint.sh --confirm <shortsha> --reason "why"   # authorize + mint
#   ./attest/mint.sh --confirm <shortsha> --reason "why" --rehearse   # dry-run mint
set -euo pipefail
cd "$(dirname "$0")/.."                        # repo root
HERE="attest"; YAML="doi/misty-doi.yaml"
CONFIRM="" REASON="" REHEARSE=0
while [ $# -gt 0 ]; do case "$1" in
  --confirm) CONFIRM="$2";shift;; --reason) REASON="$2";shift;; --rehearse) REHEARSE=1;; esac; shift; done
command -v python3 >/dev/null || { echo "python3 required"; exit 3; }

# read metadata path + files from the yaml (no external deps)
read_meta(){ python3 - "$YAML" <<'PY'
import sys,re
y=open(sys.argv[1]).read().splitlines(); meta=""; files=[]; infiles=False
for ln in y:
  if ln.strip().startswith("metadata:"): meta=ln.split(":",1)[1].strip()
  if ln.strip()=="files:": infiles=True; continue
  if infiles:
    m=re.match(r"\s*-\s*(.+)$",ln)
    if m: files.append(m.group(1).strip())
    elif ln and not ln.startswith(" "): infiles=False
print(meta); print("\n".join(files))
PY
}
MAP="$(read_meta)"; META="$(echo "$MAP"|head -1)"; FILES="$(echo "$MAP"|tail -n +2)"
TITLE="$(python3 -c "import json;print(json.load(open('$META')).get('title','(untitled)'))")"

# subject digest = SHA-256 over the sorted manifest of (filesha  name) — identifies the exact deposit
MANIFEST="$(for f in $FILES; do printf '%s  %s\n' "$(sha256sum "$f"|cut -d' ' -f1)" "$f"; done | sort)"
DIGEST="$(printf '%s\n' "$MANIFEST" | sha256sum | cut -d' ' -f1)"

if [ -z "$CONFIRM" ]; then
  echo "MINT preview — $TITLE"; echo "  files:"; echo "$FILES" | sed 's/^/    /'
  bash "$HERE/parwana.sh" --subject "$TITLE" --digest "$DIGEST" --action mint \
    --target "Zenodo (misty publish)" || true
  exit 0
fi

# authorize (writes OTS-attested intent receipt) — aborts non-zero on mismatch
ARGS=(--subject "$TITLE" --digest "$DIGEST" --action mint --target "Zenodo" \
      --reason "$REASON" --confirm "$CONFIRM")
[ "$REHEARSE" = 1 ] && ARGS+=(--dry-run)
bash "$HERE/parwana.sh" "${ARGS[@]}"

# token via the established method (env, or central ops path) — never inlined
if [ -z "${ZENODO_TOKEN:-}" ]; then
  TP="${ZENODO_TOKEN_PATH:-ops/.zenodo_token}"; [ -f "$TP" ] && ZENODO_TOKEN="$(cat "$TP")" && export ZENODO_TOKEN
fi
export ORCID="${ORCID:-0009-0002-0684-8320}"
FLAGS="--output doi/result.json"; [ "$REHEARSE" = 1 ] && FLAGS="--dry-run"
echo "→ misty publish ($([ "$REHEARSE" = 1 ] && echo rehearse || echo MINT))"
# shellcheck disable=SC2086
misty publish -m "$META" -f $FILES $FLAGS
