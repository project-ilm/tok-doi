# Tok DOI — atomic provenance layer

> Register **cryptographic proof**, not publications. Any digital artifact — a
> byte, character, token, word, sentence, message, chat, image, code fragment, or
> file — reduces to **SHA-256 → OpenTimestamps → AyeSHA → registry → Tok DOI record**.
> Sibling to **Misty DOI** (the rich publication layer, "Mishti Doi").
> Signature: **«No Added Sugar.»**

Tok DOI is **not** another DOI minting system. It is an atomic provenance and
registration layer that works at arbitrary granularity. It is **browser-first with
no backend**: GitHub Pages + public OpenTimestamps infrastructure is sufficient.
The raw `.ots` proof is never stored — only its AyeSHA encoding.

## Register (browser-first, keyless)
Open **`docs/index.html`** → pick a **registry** → provide the artifact (paste
text, upload a file, or paste a SHA-256) → it hashes, timestamps via OpenTimestamps,
AyeSHA-encodes, and returns a record you submit yourself (a pre-filled GitHub
commit into `registry/<id>/inbox/`, or a Google Form → Sheet → periodic commit).
The maintainer folds pending records into the append-only registry with
[`scripts/ingest.sh`](scripts/ingest.sh). Verify any record in
[`docs/verify.html`](docs/verify.html).

## Registries (retrieved, not generated)
Catalog: [`registries/index.json`](registries/index.json). Two kinds ship:
- **`general`** — artifact registry: proof of any artifact at any granularity.
- **`pie`** — endorsement registry: signed endorsements of the Proclamation of
  Individual Equity (DOI 10.5281/zenodo.21397274). Dedicated page:
  [`docs/sign-pie.html`](docs/sign-pie.html).

Add a registry by committing `registries/<id>.json` + a `registry/<id>/` folder
(see [`registries/README.md`](registries/README.md)).

## Sub-DOIs → collections → Misty → Zenodo
Each record is an atomic **sub-DOI**. Curate many into a **collection**
([`collections/`](collections/README.md)) and publish the set as one Zenodo DOI via
Misty. Tok DOI is the atomic layer; Misty is the publication layer.

## Authorization — Candor
Irreversible actions (mint, push) are authorized with **one command** + a
git-style short digest + a reason; the intent is OpenTimestamps-attested
(in-toto Statement v1). See [`attest/PROTOCOL.md`](attest/PROTOCOL.md). No donkey work.

## AyeSHA (read before shipping)
`docs/ayesha.js` ships a **reversible placeholder codec** (base64url + checksum),
not the canonical AyeSHA. The `encode/decode` interface is stable; swap the codec
and nothing else changes.

## Layout
```
docs/         index.html (registrar) · sign-pie.html · verify.html · tok.js · ayesha.js
registries/   index.json + per-registry definitions (general, pie)
registry/     general/ · pie/  — SCHEMA + append-only records + inbox/
collections/  curate sub-DOIs for Misty publication
attest/       Candor authorization (candor.sh, mint.sh, push.sh, PROTOCOL.md)
scripts/      ingest.sh · collect.sh · verify.sh · record-doi.sh
doi/          mint config (misty-doi.yaml, DEPOSIT.sha256)
```

## Licensing
Per-category (estate standard): software GPL-3.0-or-later; content CC-BY-SA-4.0;
registries & records CC0-1.0. See [`LICENSE`](LICENSE).

© 1993–2026 Abhishek Choudhary. All rights reserved. · AyeAI · ORCID 0009-0002-0684-8320 · model: Claude Opus 4.8
