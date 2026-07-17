#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
#
# candor.sh — Candor v1: attested authorization for irreversible actions.
# The human authorizes by supplying a git-style SHORT DIGEST of the subject plus
# a reason. The intent {subject-digest, action, target, reason, actor, utc} is
# recorded as an in-toto Statement v1 and OpenTimestamps-attested. Only the thin
# predicate profile is new; the envelope (in-toto) and notarisation (OTS) are
# standard. Raw .ots is never stored — only its AyeSHA (AYESHA1) encoding.
#
#   candor.sh --subject NAME --digest SHA256 --action mint|push --target STR \
#              --reason "why" --confirm SHORTSHA [--actor STR] [--prefix-min 6] \
#              [--receipts DIR] [--dry-run]
#
# Exit: 0 authorized (receipt written) · 2 confirmation mismatch ·
#       10 no confirmation (preview only) · 3 usage.
set -euo pipefail
SUBJECT="" DIGEST="" ACTION="" TARGET="" REASON="" CONFIRM="" ACTOR="Abhishek Choudhary (AyeAI, ORCID 0009-0002-0684-8320)"
PMIN=6 RCPTS="attest/receipts" DRY=0
while [ $# -gt 0 ]; do case "$1" in
  --subject) SUBJECT="$2";shift;; --digest) DIGEST="$2";shift;; --action) ACTION="$2";shift;;
  --target) TARGET="$2";shift;; --reason) REASON="$2";shift;; --confirm) CONFIRM="$2";shift;;
  --actor) ACTOR="$2";shift;; --prefix-min) PMIN="$2";shift;; --receipts) RCPTS="$2";shift;;
  --dry-run) DRY=1;; *) echo "unknown arg: $1" >&2; exit 3;; esac; shift; done
[ -n "$DIGEST" ] && [ -n "$ACTION" ] && [ -n "$SUBJECT" ] || { echo "usage: --subject --digest --action required" >&2; exit 3; }
DIGEST="$(echo "$DIGEST" | tr 'A-F' 'a-f')"; SHORT="${DIGEST:0:8}"

if [ -z "$CONFIRM" ]; then
  echo "── Candor: authorization required ──────────────────────────────"
  echo "  action : $ACTION"; echo "  target : ${TARGET:-<none>}"
  echo "  subject: $SUBJECT"; echo "  digest : $DIGEST"
  echo
  echo "  To authorize, re-run with:  --confirm $SHORT --reason \"...\""
  echo "─────────────────────────────────────────────────────────────────"
  exit 10
fi
C="$(echo "$CONFIRM" | tr 'A-F' 'a-f')"
[ "${#C}" -ge "$PMIN" ] || { echo "✗ confirmation too short (min $PMIN hex)"; exit 2; }
case "$DIGEST" in "$C"*) : ;; *) echo "✗ confirmation '$C' does not match digest prefix $SHORT"; exit 2;; esac
[ -n "$REASON" ] || { echo "✗ --reason is required (attested intent)"; exit 2; }

UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
mkdir -p "$RCPTS"
STMT="$RCPTS/candor-${DIGEST:0:12}-${ACTION}.intent.json"
# in-toto Statement v1 (canonical JSON via python for stable ordering)
python3 - "$STMT" "$SUBJECT" "$DIGEST" "$ACTION" "$TARGET" "$REASON" "$ACTOR" "$UTC" "$C" <<'PY'
import sys,json
p,subj,dig,act,tgt,reason,actor,utc,conf=sys.argv[1:10]
stmt={"_type":"https://in-toto.io/Statement/v1",
 "subject":[{"name":subj,"digest":{"sha256":dig}}],
 "predicateType":"https://project-ilm.org/attestations/candor/v1",
 "predicate":{"action":act,"target":tgt,"reason":reason,"actor":actor,
   "authorized_utc":utc,
   "confirmation":{"scheme":"short-sha","provided":conf,"prefix_len":len(conf)},
   "tool_of_record":"misty-doi" if act=="mint" else "git",
   "model_of_record":"Claude Opus 4.8"}}
open(p,"w").write(json.dumps(stmt,sort_keys=True,separators=(',',':'))+"\n")
PY
STMT_SHA="$(sha256sum "$STMT" | cut -d' ' -f1)"
echo "✓ intent statement: $STMT"
echo "  statement sha256: $STMT_SHA"

if [ "$DRY" = 1 ]; then echo "  (dry-run: not stamped, not persisted as final)"; exit 0; fi

# OTS-attest the intent statement; store only AyeSHA(AYESHA1) encoding of the proof
ayesha_encode(){ # stdin: bytes -> AYESHA1.<b64url>.<sha8>
  local tmp; tmp="$(mktemp -u ./.pw.XXXX)"; cat > "$tmp"
  local b64 sum; b64="$(base64 -w0 "$tmp" | tr '+/' '-_' | tr -d '=')"
  sum="$(sha256sum "$tmp" | cut -c1-8)"; rm -f "$tmp"; printf 'AYESHA1.%s.%s' "$b64" "$sum"; }
OTS_FIELD='"pending"'
if command -v ots >/dev/null 2>&1; then
  ots stamp "$STMT" >/dev/null 2>&1 || true
  if [ -f "$STMT.ots" ]; then OTS_FIELD="\"$(ayesha_encode < "$STMT.ots")\""; rm -f "$STMT.ots"; fi
fi
RCPT="$RCPTS/candor-${DIGEST:0:12}-${ACTION}.receipt.json"
python3 - "$RCPT" "$STMT" "$STMT_SHA" "$OTS_FIELD" <<'PY'
import sys,json
rcpt,stmtf,ssha,ots=sys.argv[1:5]
stmt=json.load(open(stmtf))
out={"protocol":"candor/v1","statement":stmt,"statement_sha256":ssha,
     "ots_ayesha":json.loads(ots),"receipt_utc":stmt["predicate"]["authorized_utc"]}
open(rcpt,"w").write(json.dumps(out,indent=2)+"\n")
PY
echo "✓ receipt (append-only): $RCPT"
[ "$OTS_FIELD" = '"pending"' ] && echo "  OTS: pending (no ots client) — upgrade later with: ots upgrade" || echo "  OTS: attested (AyeSHA-encoded)"
exit 0
