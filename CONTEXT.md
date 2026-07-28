# CONTEXT — project-ilm/tok-doi (cold-start map)
© 1993–2026 Abhishek Choudhary. All rights reserved. · AyeAI · synced 2026-07-16 · model: Claude Opus 4.8

See the master map at `zistgah/governance/CONTEXT.md`. This repo:

- **Is** the complete Tok DOI atomic-provenance layer: register proof of any
  artifact under any registry (general) at arbitrary granularity; PIE endorsement
  is one registry (docs/sign-pie.html).
- **Registrar:** `docs/index.html` (general); **signing:** `docs/sign-pie.html` (+ `tok.js`, `ayesha.js`) — hashes an
  endorsement statement, timestamps it via OpenTimestamps in the browser, AyeSHA-
  encodes the proof, and hands back a registry record plus keyless submission links.
- **Verify:** `docs/verify.html` and `scripts/verify.sh` — decode AyeSHA, verify
  the OTS proof, confirm it references the PIE base.
- **Registries:** `registries/index.json` (catalog) → `general`, `pie`. Records
  append-only under `registry/<id>/`. Collections curate sub-DOIs for Misty.
- **Ingest:** `scripts/ingest.sh` (Google-Sheet CSV → append; dry-run default).
- **Naming:** Tok DOI ("Tok Doi" — token / timestamp / talk; atomic). Signature:
  «No Added Sugar.» Sibling: Misty DOI ("Mishti Doi"; rich publication layer).
- **Intent & disclaimers:** `MANIFESTO.md` — preservation of individuality in the
  AGI era; **not** anti-institution.

<!-- BEGIN repo-specific (preserved across sync) -->
<!-- END repo-specific (preserved across sync) -->

## MASI surface (28 Jul 2026)

`docs/masi.html` + `docs/masi.js` — seven-track scholarly workflow, entirely client-side.
Workspace in localStorage, exportable as JSON. Ledger digests stamped via OpenTimestamps
from the browser; records submitted keylessly through `composeUrl` into
`registry/masi/inbox/`, folded in by `scripts/ingest.sh` like every other registry.

Tracks: ethics · prereg · paper · journal · conference · chapter · patent.
Gates: G1 ethics-before-collection · G2 stamp-before-collection · G3 file-before-publish
· G4 no-accept-without-review · G5 prereg advisory.

The same definitions live in `misty/masi.py` (project-ilm/misty-doi, from 1.1.2+). Misty
mints; Tok proves. A researcher with no account uses Tok and loses nothing but the DOI.
