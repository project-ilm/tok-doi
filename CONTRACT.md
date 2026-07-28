<!-- THIN OVERLAY — the MASTER CONTRACT at zistgah/governance/CONTRACT.md governs.
     This file only ADDS repo-specific constraints. It may never relax the master. -->
# CONTRACT — project-ilm/tok-doi
© 1993–2026 Abhishek Choudhary. All rights reserved. · synced 2026-07-16 · model: Claude Opus 4.8

Any session — human or AI — **maintains contract and context**. The master governs;
see `zistgah/governance/CONTRACT.md`. This overlay adds only what is specific to
this repository.

## Repo-specific
- **Scope (seed).** This is the *just-enough* seed of Tok DOI, sized for the PIE
  signatory campaign. The full Tok DOI system (arbitrary granularity, multi-registry,
  Misty integration, sub-DOI publication) is **deferred** and not built here.
- **Independence.** Tok DOI is a standalone project. It is **not** integrated into
  misty-doi. Shared code is refactored out only later, once both designs stabilise.
- **Atomic provenance.** Artifact → SHA-256 → OpenTimestamps → AyeSHA encoding →
  selected registry → Tok DOI record. Browser-first, **no backend**.
- **Raw .ots is never stored.** Only its AyeSHA encoding is committed. AyeSHA is a
  stable interface with a **swappable** codec; the bundled default is a documented
  placeholder to be replaced by the canonical AyeSHA — never silently reinvented.
- **Registries are retrieved, not generated dynamically.** `registries/pie.json`
  is the pre-existing base for this campaign.
- **Registry discipline.** Public, append-only, version-controlled. Never edit or
  delete a record line.
- **Keyless & keyless-by-default.** Submission via GitHub compose-URL or Google
  Form → Sheet → periodic commit. No secrets in the repo. The **human commits**;
  the AI never pushes.
- **No fabrication.** No invented metadata, hashes, counts, or signatory metrics.

<!-- BEGIN repo-specific (preserved across sync) -->
<!-- END repo-specific (preserved across sync) -->

## MASI in the browser (added 28 Jul 2026)

**T-MASI-1 — one definition, two runtimes.** `docs/masi.js` and `misty/masi.py` carry
the same seven tracks and the same five gates. Neither is a summary of the other. A
change to one is a change to both, and the seed script fails if they drift.

**T-MASI-2 — no tokens, ever.** Misty needs a Zenodo token; Tok needs nothing. Anything
added here that requires an account or a key belongs in Misty instead. «No Added Sugar.»

**T-MASI-3 — the ledger body is never submitted.** A registry record carries the digest
and the proof. What the researcher was working on stays on their device.

**T-MASI-4 — AI is asked, never obeyed.** Every assistant seed states that the human is
responsible for the scholarly and legal decisions. The provider is the reader's choice
(AAB AI-source invariance); providers with no documented URL parameter get the prompt on
the clipboard rather than an invented one.

**T-MASI-5 — the gates protect what cannot be repaired.** Ethics approval cannot be
applied backwards. A pre-registration is only worth its date. A DOI is a dated public
disclosure and can end a patent's novelty. These are refusals, not warnings.
