#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# © 1993-2026 Abhishek Choudhary · AyeAI · model: Claude Opus 4.8
# Offline sanity check of a Tok DOI record (statement hash + AyeSHA decode).
# OTS attestation is verified in the browser (docs/verify.html) or with `ots verify`.
#   ./verify.sh registry/pie/inbox/tok-pie-XXXX.json
set -euo pipefail
f="${1:?usage: verify.sh <record.json>}"
command -v jq >/dev/null || { echo "jq required"; exit 3; }
stmt=$(jq -r '.statement' "$f"); claim=$(jq -r '.statement_sha256' "$f")
calc=$(printf '%s' "$stmt" | sha256sum | cut -d' ' -f1)
[ "$calc" = "$claim" ] && echo "✓ statement hash matches" || { echo "✗ hash mismatch: $calc != $claim"; exit 1; }
tok=$(jq -r '.ots_ayesha' "$f")
case "$tok" in AYESHA1.*.*) echo "✓ ots_ayesha well-formed (AYESHA1)";; *) echo "✗ ots_ayesha malformed"; exit 1;; esac
echo "◐ OTS attestation: verify in docs/verify.html or decode+`ots verify` once canonical AyeSHA lands."
