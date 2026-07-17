#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
# Record the minted DOI across the repo in one command, then re-derive metadata.
#   ./scripts/record-doi.sh 10.5281/zenodo.NNNNNNNN
set -euo pipefail
cd "$(dirname "$0")/.."
DOI="${1:?usage: record-doi.sh <doi e.g. 10.5281/zenodo.NNNN>}"
case "$DOI" in 10.5281/zenodo.*) : ;; *) echo "not a zenodo DOI: $DOI" >&2; exit 3;; esac
python3 - "$DOI" <<'PY'
import json,sys
doi=sys.argv[1]
m=json.load(open("metadata/misty.json")); m["doi"]=doi
json.dump(m,open("metadata/misty.json","w"),indent=2,ensure_ascii=False)
print("recorded doi:",doi)
PY
if command -v misty >/dev/null 2>&1; then
  misty transform -m metadata/misty.json -o metadata/derived
  [ -f metadata/derived/CITATION.cff ] && cp metadata/derived/CITATION.cff CITATION.cff
  echo "re-derived metadata."
else echo "NOTE: install misty-doi to re-derive metadata." >&2; fi
# refresh deposit manifest since metadata changed
if [ -f doi/misty-doi.yaml ]; then
  FILES=$(python3 - <<'PY'
import re
inf=False
for ln in open("doi/misty-doi.yaml"):
  if ln.strip()=="files:": inf=True; continue
  if inf:
    m=re.match(r"\s*-\s*(.+)$",ln)
    if m: print(m.group(1).strip())
    elif ln.strip() and not ln.startswith(" "): break
PY
)
  : > doi/DEPOSIT.sha256; for f in $FILES; do sha256sum "$f" >> doi/DEPOSIT.sha256; done
  echo "refreshed doi/DEPOSIT.sha256"
fi
echo "Done. Review 'git diff', commit, and push yourself."
