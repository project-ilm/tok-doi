# Minting Tok DOI on Zenodo (standard process)

Canonical record: [`../metadata/misty.json`](../metadata/misty.json). Zenodo/DataCite/
codemeta/CFF are derived by `misty-doi`. **Dry-run is the default; you mint.**

```bash
# token by your standard method — env only, from your central ops/.zenodo_token
export ZENODO_TOKEN="$(cat /path/to/your/ops/.zenodo_token)"
export ORCID=0009-0002-0684-8320

misty validate  -m metadata/misty.json
misty transform -m metadata/misty.json -o metadata/derived      # derive metadata
misty publish   -m metadata/misty.json -f docs/index.html docs/verify.html \
  docs/tok.js docs/ayesha.js README.md MANIFESTO.md --dry-run    # rehearse
# then PUBLISH (mints the DOI) — you run this, not the AI:
misty publish   -m metadata/misty.json -f <files> --output doi/result.json
```

Record the returned DOI in `metadata/misty.json` (`"doi"`), re-derive, commit.
OTS stamping of the release archive is yours to run (`misty ots stamp`).

© 1993–2026 Abhishek Choudhary. All rights reserved. · model: Claude Opus 4.8
