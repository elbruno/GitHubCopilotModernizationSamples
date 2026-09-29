---
name: dotnet-brand-visuals
description: Choose, size, label and check images for .NET talks, slides, demo pages and storytelling art, including dotnet-bot and the .NET purple. Use when adding a .NET illustration, writing an image prompt for .NET content or reviewing generated images for a .NET deck.
---

# .NET brand visuals

The core code in this kit is .NET, so its visuals follow the .NET brand. This
skill turns a brand guide that lives in a PDF into rules an agent applies every
time. It keeps two kinds of rule apart on purpose:

- **From the .NET brand**: what the official guide says, with its source.
- **Our team decisions**: how this team applies it. Not official .NET policy.

Never present a team decision as a .NET brand rule.

## From the .NET brand

Sources: the [dotnet/brand README](https://github.com/dotnet/brand/blob/91845f6ddf2123b3bb1bfd1b6a386d9ce02b43aa/README.md)
and the .NET Style Guide, November 2024 (`dotnet-styleGuide-2024.pdf`), both at
commit `91845f6d`. Short quotes and page numbers are in
[brand rules](references/brand-rules.md).

| # | Rule | Source |
| --- | --- | --- |
| B1 | dotnet-bot is the .NET mascot and now uses a 3D style. | Guide, dotnet-bot page (PDF p. 22) |
| B2 | Don't overdo it. The bot is preferred for community events, swag and collectables. Refrain from over-using it in presentations not related to the .NET community or events. | Guide, p. 22 |
| B3 | Don't reuse old 2D bot artwork in new communications. | Guide, p. 22 |
| B4 | Spot illustrations are best used small, up to 200 pixels, next to text. | Guide, spot illustrations (p. 18) |
| B5 | The .NET logo purple is `#512BD4`. | README, Logo; guide, color (p. 10) |
| B6 | Headlines use Space Grotesk; body copy uses Open Sans. | Guide, type (p. 12) |
| B7 | Illustrations in dotnet/brand are CC0 1.0 Universal. The brand guidelines and the .NET logo are copyright of the .NET authors. | README, License |

## Our team decisions

| # | Decision | Why |
| --- | --- | --- |
| T1 | Use only official dotnet-bot files from dotnet/brand, pinned to a commit and unmodified. Never generate, trace or redraw a look-alike, and never ask a text-to-image tool for dotnet-bot. | A generated bot is not the mascot and could be mistaken for official art. |
| T2 | At most one or two slides per talk, only where the content is about .NET or the .NET community. | Applies B2. |
| T3 | Show spot art small: about 200 px at 1080p, which is about 1.4 in on a 13.33 in wide slide. | Applies B4. The source files are 250 px, so they stay sharp. |
| T4 | Put a visible label next to it: official dotnet-bot, from dotnet/brand, CC0. | Credits the source and separates it from generated art. |
| T5 | Record provenance beside every official file: source URL with commit, license, sha256, alt text and where it is used. The build checks the hash. | A reviewer can prove where the image came from. |
| T6 | Generated scene art uses our own original helper robot. Each prompt says "original friendly helper robot, no resemblance to any branded mascot" and "no text, logos or watermarks". Reject any image that looks like dotnet-bot. | Keeps generated art clearly ours. |
| T7 | No .NET logo in our deck. Use `#512BD4` as an accent. Keep the deck's own typeface. | This is a community talk, not an official .NET-branded deck. |

## Before you ship

- [ ] Every dotnet-bot image is an official file with provenance and a matching hash.
- [ ] It appears on one or two .NET-related slides only.
- [ ] No old 2D bot art and no generated look-alike.
- [ ] It is shown small and labeled as official, with source and license.
- [ ] Every generated image was reviewed for mascot resemblance, text and logos.
- [ ] No .NET logo, unless a human checked the guidelines and approved it.

If the guide changes, update the pinned commit, re-read the cited pages and
update both tables. If a rule is unclear, ask; do not guess brand policy.
