# PIE Signatory Registry — records

**Append-only. Public. Version-controlled.** One JSON object per line in
`signatures.jsonl`, each conforming to [`SCHEMA.json`](SCHEMA.json).

Rules:
- Never edit or delete an existing line. Corrections are new lines that reference
  the superseded `tok` id in their `statement`.
- `tok` ids are assigned in order: `tok:pie:0001`, `tok:pie:0002`, …
- The raw `.ots` proof is **never** committed. Only its AyeSHA encoding
  (`ots_ayesha`) is stored, per the Tok DOI design.
- Signatories may be pseudonymous or anonymous. No personal data beyond what the
  signatory chooses to submit is collected.

Ingest path (keyless, no backend): browser → Google Form → Google Sheet →
periodic commit (see `../../scripts/ingest.sh`), or direct GitHub compose-URL.

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
