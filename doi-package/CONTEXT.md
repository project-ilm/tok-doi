# CONTEXT — project-ilm/tok-doi (cold-start map)
© 1993–2026 Abhishek Choudhary. All rights reserved. · AyeAI · synced 2026-07-16 · model: Claude Opus 4.8

See the master map at `zistgah/governance/CONTEXT.md`. This repo:

- **Is** the atomic-provenance seed for the Proclamation of Individual Equity
  (PIE, DOI 10.5281/zenodo.21397274) signatory campaign — the first, scoped slice of Tok DOI.
- **Signing tool:** `docs/index.html` (+ `tok.js`, `ayesha.js`) — hashes an
  endorsement statement, timestamps it via OpenTimestamps in the browser, AyeSHA-
  encodes the proof, and hands back a registry record plus keyless submission links.
- **Verify:** `docs/verify.html` and `scripts/verify.sh` — decode AyeSHA, verify
  the OTS proof, confirm it references the PIE base.
- **Registry base:** `registries/pie.json`. **Records:** `registry/pie/signatures.jsonl`
  (append-only), schema at `registry/pie/SCHEMA.json`.
- **Ingest:** `scripts/ingest.sh` (Google-Sheet CSV → append; dry-run default).
- **Naming:** Tok DOI ("Tok Doi" — token / timestamp / talk; atomic). Signature:
  «No Added Sugar.» Sibling: Misty DOI ("Mishti Doi"; rich publication layer).
- **Intent & disclaimers:** `MANIFESTO.md` — preservation of individuality in the
  AGI era; **not** anti-institution.

<!-- BEGIN repo-specific (preserved across sync) -->
<!-- END repo-specific (preserved across sync) -->
