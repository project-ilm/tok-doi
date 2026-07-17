#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
# Assemble a collection manifest from tok ids for Misty publication.
#   ./collect.sh <collection-id> "<title>" tok:general:0001 tok:pie:0002 ...
set -euo pipefail
cd "$(dirname "$0")/.."
CID="${1:?usage: collect.sh <id> <title> <tok...>}"; TITLE="${2:?title required}"; shift 2
[ $# -gt 0 ] || { echo "provide at least one tok id"; exit 3; }
OUT="collections/${CID}.json"
python3 - "$OUT" "$CID" "$TITLE" "$@" <<'PY'
import sys,json,datetime,re
out,cid,title,*toks=sys.argv[1:]
regs=sorted({t.split(':')[1] for t in toks if re.match(r'tok:[^:]+:',t)})
json.dump({"collection_id":cid,"title":title,"toks":toks,"registries":regs,
 "intended_publication":"misty-doi -> zenodo",
 "created_utc":datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
 "model_of_record":"Claude Opus 4.8"}, open(out,"w"), indent=2)
print("wrote",out)
PY
echo "Next: hand $OUT to Misty (misty publish) to mint one Zenodo DOI. You mint."
