# Parwana v1 — attested authorization for irreversible actions

**پروانہ · "permit / warrant"** — the standing contract is *no donkey work for
humans*. A human authorizes an irreversible action (mint, push) by issuing **one
command** with a **git-style short digest** of the subject and a **reason**. That
intent is bound to the subject, timestamped, and notarised — so the *authorization
itself* is provable, not just the artifact.

## What is new, what is reused
This is not a new envelope. It composes established protocols and adds only a thin
predicate profile:
- **Envelope:** in-toto Statement v1 (`_type: https://in-toto.io/Statement/v1`).
  Subject = the artifact digest; predicate = the authorization.
- **Notarisation:** OpenTimestamps over the canonical statement — decentralised,
  verifiable without trusting the issuer. (RFC 3161 TSAs are the centralised
  analogue; Sigstore/Rekor is a natural future transparency-log interop.)
- **Confirmation:** git-style short digest. The human types enough leading hex of
  the subject digest to identify it uniquely (≥6), exactly as `git` accepts short
  commit ids. Typing it *is* the signature of intent.
- **New:** the `parwana/v1` predicate profile below, and the rule that the raw
  `.ots` is never stored — only its AyeSHA (AYESHA1) encoding.

## The attested statement
```json
{
  "_type": "https://in-toto.io/Statement/v1",
  "subject": [{"name": "<what>", "digest": {"sha256": "<D>"}}],
  "predicateType": "https://project-ilm.org/attestations/parwana/v1",
  "predicate": {
    "action": "mint | push",
    "target": "<Zenodo | remote ref>",
    "reason": "<human reason>",
    "actor":  "<name / ORCID>",
    "authorized_utc": "<ISO-8601 Z>",
    "confirmation": {"scheme": "short-sha", "provided": "<shortsha>", "prefix_len": N},
    "tool_of_record": "misty-doi | git",
    "model_of_record": "Claude Opus 4.8"
  }
}
```
The canonical (sorted, minified) statement is OTS-stamped; the receipt stores the
statement, its SHA-256, and the AyeSHA-encoded proof, append-only under
`attest/receipts/`.

## Subject digest
- **mint:** SHA-256 over the sorted manifest of `(file-sha256, name)` for the exact
  deposit set — one digest that pins the whole deposit.
- **push:** the commit SHA (git-native).

## Human action, in full
```
./attest/mint.sh --confirm <shortsha> --reason "founding mint of the campaign"
./attest/push.sh origin main --confirm <shortsha> --reason "publish signing site"
```
No file lists, no paths, no token typing. Run without `--confirm` to preview the
digest. Add `--rehearse` to mint in dry-run.

## Verify a receipt
Recompute the subject digest, recompute the statement SHA-256, decode the AyeSHA
proof, and `ots verify` it. The reason + UTC + digest are bound together and
attested; the authorization cannot be back-dated or repudiated.

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
