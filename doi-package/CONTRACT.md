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
