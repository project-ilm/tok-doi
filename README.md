# Tok DOI — <span title="No Added Sugar.">atomic provenance</span>

> **Tok DOI** registers *cryptographic proof*, not scholarly publications. Every
> artifact — a byte, a token, a sentence, a chat, a signature — reduces to
> **SHA-256 → OpenTimestamps → AyeSHA → registry**. Sibling to **Misty DOI** (the
> rich publication layer, "Mishti Doi"). Signature: **«No Added Sugar.»**

This repository is the **seed** of Tok DOI, sized for one job: the **signatory
campaign for the Proclamation of Individual Equity** (PIE, DOI
[10.5281/zenodo.21397274](https://doi.org/10.5281/zenodo.21397274)). The full Tok DOI system — arbitrary
granularity, multiple registries, Misty integration, sub-DOI publication — is
deliberately **deferred**; see [`CONTRACT.md`](CONTRACT.md).

## Not an anti-institution campaign

Signing is an act of **preservation of identity and individuality in the AGI era**
— a decentralised, verifiable timestamp beside the canonical Proclamation. It
opposes no institution, harvests no data, and permits anonymity. Institutions are
welcome to sign as institutions. Full intent: [`MANIFESTO.md`](MANIFESTO.md).

## How signing works (browser-first, no backend)

1. A signatory opens **`docs/index.html`** (GitHub Pages).
2. Their endorsement statement is hashed (SHA-256, Web Crypto).
3. The hash is timestamped via **OpenTimestamps** public calendars, in-browser.
4. The `.ots` proof is **AyeSHA-encoded** — the raw `.ots` is never stored.
5. They submit **keyless-ly**: a pre-filled GitHub compose-URL writes one record to
   `registry/pie/inbox/`, or a Google Form feeds a Sheet the maintainer commits.
6. The maintainer folds pending records into the **append-only** registry with
   [`scripts/ingest.sh`](scripts/ingest.sh) (dry-run by default). The human commits.

Verify any record in **`docs/verify.html`** or with `scripts/verify.sh`.

## Layout

```
docs/           Signing + verify pages (GitHub Pages); tok.js, ayesha.js
registries/     Pre-existing registry bases — pie.json (retrieved, not generated)
registry/pie/   SCHEMA.json · signatures.jsonl (append-only) · inbox/ (pending)
scripts/        verify.sh · ingest.sh (dry-run default)
MANIFESTO.md    Intent + disclaimers
```

## AyeSHA (read before shipping)

`docs/ayesha.js` ships a **reversible placeholder codec** (base64url + checksum),
not the canonical AyeSHA. The interface (`encode/decode`) is stable; swap the codec
and nothing else changes. Do not treat the placeholder as final.

## Licensing

Per-category (estate standard): software GPL-3.0-or-later; content CC-BY-SA-4.0;
registry & metadata CC0-1.0. See [`LICENSE`](LICENSE).

© 1993–2026 Abhishek Choudhary. All rights reserved. · AyeAI · ORCID 0009-0002-0684-8320 · model: Claude Opus 4.8
