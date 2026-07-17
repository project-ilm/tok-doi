# Registries

A **registry** is a public, append-only namespace for Tok DOI records. Registries
are **pre-defined and retrieved**, never generated at submission time. The catalog
is [`index.json`](index.json); each entry points to a definition file.

Two kinds ship:
- **artifact** (e.g. `general`) — registers proof of any digital artifact at
  arbitrary granularity (byte, token, sentence, message, chat, image, file, …).
- **endorsement** (e.g. `pie`) — records a signed endorsement bound to a base
  artifact (the Proclamation of Individual Equity, DOI 10.5281/zenodo.21397274).

## Add a registry
1. Commit `registries/<id>.json` (copy `general.json` or `pie.json`).
2. Add it to `index.json`.
3. Create `registry/<id>/` with `SCHEMA.json`, an empty records file, and `inbox/`.

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
