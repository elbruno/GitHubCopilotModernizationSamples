# v02 visual draft

This is a separate redesign for presenter review. The original v01 deck and
notes are unchanged. Nothing in this folder has been publicly published.

## Open and rehearse

- Editable deck: `tribal-knowledge-to-code-v02-draft.pptx`
- Slide-by-slide notes with timing, show cues and fallbacks: `speaker-notes.md`
- Narrative and layout map: `outline.md`
- Demo sequence and exact commands: [presenter runbook](../../demos/runbook.md)

The deck keeps the twelve-slide narrative and designed timing from v01. The
title slide now includes Bruno's supplied photograph. Text, diagrams, workflow
arrows and callout bands remain editable; the photograph and illustrations
are embedded images.

## Visual direction and provenance

The user requested the purple/lilac editorial treatment of MafClaw Session 4
v04 as a fallback. Organizer-template research did not surface a template in
the available indexed results; attachment and direct-message retrieval were
incomplete, so this is not a claim that no template exists. No organizer
messages, meeting links or private artwork are included.

This deck adapts the visual language, not another session's slide content,
branding or assets. Its generator has no dependency on the MafClaw checkout.
The four original conceptual illustrations were generated using
`foundry-gpt-image-25-flare`, as requested. They are metaphors, not product
screenshots or evidence of agent behavior. Prompts, real generation receipts
and producer selection records are stored alongside the images.

The headshot was supplied locally for this introduction. It was not uploaded
to the image-generation service. Sunburst generation is deferred until the
presenter reviews the design direction.

## Rebuild without image-generation charges

From the repository root:

```powershell
npm run slides:v02:check
npm run slides:v02:build
npm run slides:v02:package-check
```

Use the existing local Node dependencies. On a fresh machine, restore with
`npm ci --ignore-scripts --no-audit` first. Building consumes existing image
files and checks their hashes; it never calls an image service. Prior deck
bytes are preserved under the ignored `history` folder when rebuilding.
Close the v02 deck before rebuilding it.

To render with desktop PowerPoint on Windows, choose a **new** output folder:

```powershell
New-Item -ItemType Directory -Force .\slides\v02\renders | Out-Null
.\tools\slides\render-powerpoint.ps1 `
  -InputPath .\slides\v02\tribal-knowledge-to-code-v02-draft.pptx `
  -OutputDirectory .\slides\v02\renders\review-next `
  -ExpectedSlideCount 12 `
  -NotesManifestPath .\slides\v02\build-manifest.json `
  -Confirm:$false
```

The renderer retains native PNGs, an internal slides-only PDF and a hash-bound
receipt. These are QA outputs, not presenter-approved publication artifacts.
Any edit or rebuild requires fresh rendering/review against the new deck hash.

## Before presenting

Review the draft visually and rehearse the actual demo transitions. Baseline
and guided independent Copilot captures remain **not-run**, and the deck says
so. The runnable reference is a fallback, not an agent capture. The public
sample URL remains pending verification.

Presenter approval, a timed human rehearsal, final-art generation and public
publication are separate pending decisions. A native bounds pass or an agent
visual review does not substitute for presenter approval.
