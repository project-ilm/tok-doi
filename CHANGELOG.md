# Changelog — project-ilm/tok-doi

## [unreleased] — complete version (2026-07-17)
### Generalized
- Tok DOI is now the **complete** atomic-provenance layer, not a PIE-only seed:
  general registrar (`docs/index.html`) registers any artifact (text/file/hash) at
  arbitrary granularity under any registry; registry **catalog** (`registries/index.json`)
  with `general` + `pie`; registry-agnostic `ingest.sh`.
- Added **collections** (sub-DOI → curated set → Misty → Zenodo) with `collect.sh`.
- PIE signing preserved as `docs/sign-pie.html` (one registry among many).

## [unreleased] — correction pass (2026-07-17)
### Renamed
- **Parwana → Candor.** The authorization/attestation protocol is renamed to
  Candor (frank, verifiable intent; a universal rather than region-specific name).
  Files: `attest/parwana.sh` → `attest/candor.sh`,
  `attest/metadata/parwana.misty.json` → `attest/metadata/candor.misty.json`;
  predicate type `…/attestations/parwana/v1` → `…/attestations/candor/v1`.
  The initial Zenodo deposit (v0.1) predates this rename and refers to Parwana;
  a new Zenodo version may be minted to reflect Candor if desired.
### Added
- `doi/DEPOSIT.sha256` and an integrity gate in `attest/mint.sh` (deposit files
  are verified before minting).
- Self-verifying seed script; `attest/receipts/`, `registry/pie/inbox/` placeholders;
  Pages workflow.
- `scripts/record-doi.sh` to record the minted DOI in one command.

## [0.1-pie-campaign] — seeded & minted
- Seed sized for the PIE signatory campaign. Minted on Zenodo (DOI to be recorded
  via `scripts/record-doi.sh`).

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
