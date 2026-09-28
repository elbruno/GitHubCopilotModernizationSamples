# v03: five-demo teaching deck

- `tribal-knowledge-to-code-v03.pptx`: 12 editable slides with speaker notes
- `tribal-knowledge-to-code-v03.pdf`: reviewed slides-only export
- `content.mjs`: slide narrative, transitions, evidence and fallbacks
- `generate.mjs`: reproducible local PptxGenJS source
- `speaker-notes.md` / `outline.md`: generated from the content source
- `build-manifest.json` / `visual-review.json`: hash-bound build and review evidence
- [Demo script](../../demos/v03/demo-script.md) and [runbook](../../demos/v03/runbook.md)

The hour is designed for 42 demo minutes and ten minutes of Q&A. It is not
a measured human rehearsal. Only the named regression checkpoint is
intentionally broken. Independent Copilot captures remain not-run.

The visual direction preserves v02's purple/lilac editorial design and local
presenter photograph. Existing reviewed Flare illustrations are reused from
`../v02/images`; no new billable generation or Sunburst pass was made. Artwork
is conceptual, not product UI or run evidence. The headshot was supplied
locally and was not uploaded to an image service.

From the repository root:

```powershell
npm run slides:v03:check
npm run slides:v03:build
npm run slides:v03:package-check
```

Building never calls an image service. Previous deck bytes are archived under
ignored `history`. Close the v03 file before rebuilding. A different PPTX
hash requires fresh native rendering, visual review and PDF export; do not
reuse an old PDF or review receipt after edits.

The original v01 and v02 decks remain separate. `slides:build` now targets v03;
the explicit `slides:v01:*` and `slides:v02:*` commands retain earlier builders.
