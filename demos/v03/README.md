# v03: skills-first, five-demo session

The main story is **create a skill, apply it, test its limits, reuse it**.
The small .NET modernization task supplies the context. The designed hour
contains 42 live-demo minutes, 8 framing/recap minutes and 10 Q&A minutes.
This timing is a plan, not a measured human rehearsal.

- [Presenter runbook](runbook.md): setup, exact commands, cutoffs and fallbacks
- [Demo script](demo-script.md): what to say, show, type and verify
- [Run of show](run-of-show.md): generated timing map
- [Speaker notes](../../slides/v03/speaker-notes.md)
- [Editable v03 slides](../../slides/v03/tribal-knowledge-to-code-v03.pptx)
- [Slide source](../../slides/v03/content.mjs)
- [Exact prompts](prompts/): author, repair and reuse; original baseline/guided
  prompts remain in the root `prompts` directory

All domain data and policies are synthetic. Independent Copilot captures are
**not-run**; prepared teaching checkpoints are not agent results. Only the
explicitly named null-regression checkpoint is deliberately broken.

## Fresh local setup

Run from the sample repository root. Choose a new folder under an existing,
neutral parent outside the repository. The preparation script refuses
overwrites, linked ancestors and ancestor instruction/skill folders.

```powershell
$demo = Join-Path ([IO.Path]::GetTempPath()) ('northwind-v03-' + [guid]::NewGuid())
pwsh -NoProfile -File .\scripts\prepare-v03.ps1 -Destination $demo
pwsh -NoProfile -File .\scripts\test-v03.ps1 -Workspace $demo `
  -OutputDirectory (Join-Path $PWD ('artifacts\v03-' + [guid]::NewGuid()))
```

Prerequisites: .NET SDK 10.0.401 or a later patch in that feature band and
PowerShell 7. The initial restore needs network access. Rehearsed checkpoints
run locally without cloud resources or credentials. Copilot itself needs a
configured account and network access.

## Seven checkpoints, five demos

| Folder | Purpose | Prepared contents |
| --- | --- | --- |
| `01-baseline` | Demo 1 | Working legacy input; no project skill |
| `02-author-skill` | Demo 2 | Same legacy input plus synthetic team notes; no prewritten skill |
| `03-guided` | Demo 3 | Same legacy input plus the reviewed skill package |
| `04-reference` | Migration fallback | Authored modern app and real tests; not generated-agent output |
| `05-null-regression` | Demo 4 | Modern app with intentionally wrong null handling and unchanged tests |
| `06-reuse-start` | Demo 5 | Modern app and skill; no batch implementation |
| `07-reuse-complete` | Reuse fallback | Prepared batch helper and three focused tests |

Open **one checkpoint folder at a time**, not their parent and not the whole
sample repository. Fresh conversations still inherit personal/host settings;
these folders alone do not prove neutral agent context. They are teaching
workspaces, not an automatically controlled comparison experiment.

`test-v03.ps1` verifies every checkpoint, observes the exact intended failing
null assertion, performs a disclosed scripted repair, verifies the same test
and full suite passing, then restores/rebuilds the broken checkpoint for the
live lesson. It also verifies that reuse leaves CLI, pricing and audit source
unchanged. Logs and TRX files remain local; no agent run is manufactured.
