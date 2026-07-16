# Keyless ingest runbook — Google Form → Sheet → commit

No backend is required. Two keyless submission paths feed the same append-only
registry; enable either or both.

## Path A — GitHub compose-URL (works today, zero setup)
The signing page builds a pre-filled "new file" URL. The signatory clicks
**Commit** on GitHub; the record lands in `registry/pie/inbox/`. You then run
`scripts/ingest.sh --apply` and commit. Requires the signatory to have a GitHub
account.

## Path B — Google Form (no account needed by signatory)
1. Create a Google Form with fields matching `registry/pie/SCHEMA.json`:
   signatory, affiliation, capacity, statement, statement_sha256, ots_ayesha,
   artifact_url (optional), signed_utc.
2. Link responses to a Google Sheet; **File → Share → Publish to web** (CSV).
3. Paste the Form URL into `CFG.googleFormUrl` in `docs/index.html`.
4. Periodically export the Sheet as CSV and run
   `scripts/ingest.sh --csv responses.csv` (map columns first), then `--apply`,
   then commit. A scheduled Action can automate the export→commit later; keep the
   **human-commit** rule until you decide otherwise.

Rule in force: the raw `.ots` is never stored — only its AyeSHA encoding. The
registry stays public, append-only, and version-controlled.

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
