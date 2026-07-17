# Collections — from atomic sub-DOIs to a citable Zenodo DOI

Each Tok DOI record is an atomic **sub-DOI**: a cryptographic proof, not a
publication. To publish, curate many records into a **collection**, then hand the
collection to **Misty DOI**, which mints one Zenodo DOI for the set.

```
many Tok DOI records  →  curated collection (collections/*.json)
                      →  Misty DOI  →  one Zenodo DOI
```

- A collection (see [`SCHEMA.json`](SCHEMA.json)) lists the `tok` ids it includes
  and is itself append-only history.
- The Zenodo DOI dereferences the collection; the registry preserves references to
  each atomic registration. "Sub-DOI" is an application-level concept here, not a
  DOI Foundation standard.
- Build one with [`../scripts/collect.sh`](../scripts/collect.sh), then publish via
  Misty (`misty publish`) — the human mints (Candor authorization).

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
