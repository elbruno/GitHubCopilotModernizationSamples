# From Tribal Knowledge to Code: Custom Skills for GitHub Copilot Modernization

**Copilot knows the technology. Your team knows the exceptions. Custom skills
connect the two.**

Bruno Capuano | September 29, 2026 | Microsoft Reactor

This learning sample demonstrates a small **Newtonsoft.Json to System.Text.Json**
dependency/API migration on .NET 10. All people, orders, organizational rules,
and the audit component are **synthetic**. It is not an Azure migration,
a framework upgrade, or a production-ready service. No taxes or currency
conversion are modeled.

## Start here: v03, five demos

- [Five-demo setup](demos/v03/README.md) and [presenter runbook](demos/v03/runbook.md)
- [Demo script: say/show/type/verify](demos/v03/demo-script.md)
- [Run of show](demos/v03/run-of-show.md): 42 demo minutes and 10 minutes of Q&A
- [Speaker notes](slides/v03/speaker-notes.md) and [slide outline](slides/v03/outline.md)
- [Editable v03 PowerPoint](slides/v03/tribal-knowledge-to-code-v03.pptx)
- [Slides-only v03 PDF](slides/v03/tribal-knowledge-to-code-v03.pdf)
- [Reusable modernization skill](.github/skills/northwind-modernization/SKILL.md)
- [Synthetic team notes](knowledge/team-notes.md) and [rules/contract](knowledge/rules-catalog.md)
- [Product notes](docs/product-notes.md), [official resources](docs/resources.md),
  [troubleshooting](demos/troubleshooting.md)

**The five demos:** try the task without the skill; author and review the skill;
apply it to modernization; reproduce and repair a deliberate contract bug;
reuse the skill for batch serialization. Seven local checkpoints provide
honestly labeled fallbacks. The slides are transition markers, not a lecture.

```powershell
$demo = Join-Path ([IO.Path]::GetTempPath()) ('northwind-v03-' + [guid]::NewGuid())
pwsh -NoProfile -File .\scripts\prepare-v03.ps1 -Destination $demo
pwsh -NoProfile -File .\scripts\test-v03.ps1 -Workspace $demo `
  -OutputDirectory (Join-Path $PWD ('artifacts\v03-' + [guid]::NewGuid()))
```

Preparation refuses existing destinations. The scripted rehearsal deliberately
expects one specific failing assertion, repairs it, verifies real green tests,
then restores the teaching bug for the session. This is not a fabricated
Copilot run. Open only one numbered checkpoint at a time.

## Five-minute quick start

Prerequisites: .NET **10.0.401** SDK or a later patch in that feature band.
Node **24 LTS** is needed only to regenerate slides. PowerShell **7** runs
the convenience scripts. Initial dependency restore needs the network.
The restored app runs locally without credentials, cloud, containers or a
database. Actual Copilot generation separately requires an enabled account
and network access.

```powershell
dotnet restore .\Northwind.slnx --locked-mode
dotnet build .\Northwind.slnx --no-restore
dotnet test .\Northwind.slnx --no-build --no-restore
dotnet run --no-build --project .\src\Northwind.Quotes -- .\fixtures\requests\partner.json
```

Expected stdout, comparing JSON semantics rather than whitespace/trailing zeros:

```json
{"order_id":"ORDER-001","customer_type":"partner","subtotal":300,"discount":30,"shipping":0,"total":270,"review_note":null}
```

Stderr is a separate structured event:

```json
{"event_name":"quote_calculated","correlation_id":"DEMO-001","total":270}
```

Help: `dotnet run --no-build --project .\src\Northwind.Quotes -- --help`.
No argument or `-` reads stdin. The invalid fixture exits 2 with empty stdout
and `Invalid quote request.` on stderr. Other exits: 3 I/O error, 64 usage,
0 success/help. Customer ID/email are never returned.

The six required business examples, contract validation, audit events and
supported diagnostic paths are tested. Finite tests do not prove all possible
privacy properties or guarantee compliance.

## Legacy and reference, not fabricated agent results

| State | Path | Status |
| --- | --- | --- |
| Legacy | `fixtures/legacy-input` | Working Newtonsoft.Json 13.0.4 app, two visible smoke tests |
| Reference | `src` | Authored, tested System.Text.Json implementation |
| Baseline capture | `demos/captures/baseline.json` | **not-run** |
| Guided capture | `demos/captures/guided.json` | **not-run** |

```powershell
dotnet restore .\fixtures\legacy-input\Northwind.slnx --locked-mode
dotnet build .\fixtures\legacy-input\Northwind.slnx --no-restore
dotnet test .\fixtures\legacy-input\Northwind.slnx --no-build --no-restore
dotnet run --no-build --project .\fixtures\legacy-input\src\Northwind.Quotes -- .\fixtures\requests\partner.json
```

Do not use the whole repository as a baseline input: it contains the rules
and reference answers. Exports use an explicit allowlist, match source/test
hashes, and add only the self-contained skill to guided input.

## Optional independent comparison

Choose a new existing parent outside this repository and its instruction
scope. Destinations must not already exist. The following paths are examples:

```powershell
$parent = 'D:\NorthwindFreshDemo'
New-Item -ItemType Directory -Path $parent
pwsh -File .\scripts\export-demo.ps1 -RunType baseline -Destination "$parent\baseline"
pwsh -File .\scripts\export-demo.ps1 -RunType guided -Destination "$parent\guided"
```

Open each root in a **fresh** Copilot conversation, with the same host, mode,
model and settings. Use the exact [baseline prompt](prompts/01-baseline.txt)
and [guided prompt](prompts/02-guided.txt). Inventory personal/global/app
instructions, skills and plugins; no verified neutral profile is assumed.
If neutral context cannot be established, label it a contextual walkthrough.
Dedicated Upgrade-agent use of this skill is unverified; general app agent
mode is the prepared route.

Evaluate a candidate externally:

```powershell
pwsh -File .\scripts\evaluate.ps1 -CandidateRoot "$parent\baseline" -OutputDirectory .\artifacts\baseline-evaluation-01
pwsh -File .\scripts\compare.ps1 -BaselineRoot "$parent\baseline" -GuidedRoot "$parent\guided" -OutputDirectory .\artifacts\comparison-01
```

The comparison above deliberately reports **not-run** and exits 2 until real
capture files are supplied. Follow the [runbook](demos/runbook.md) to record
metadata, seal output hashes and pass `-BaselineCapture` / `-GuidedCapture`.
Exit 1 means failed applicable checks, 2 incomplete/blocked/not-run, and 0
all required evaluated checks/reviews passed. Missing evidence is not success.

## Presentation and verification

```powershell
npm ci --ignore-scripts
npm run slides:build
npm run slides:package-check
pwsh -File .\scripts\verify.ps1
pwsh -File .\scripts\rehearsal.ps1
```

The v03 deck is editable 16:9 with 12 slides and embedded speaker notes.
`slides/v03/content.mjs` and `demos/v03/session.json` drive the deck, timeline,
outline and standalone notes. Diagrams/text are native editable shapes; the
presenter photo and original conceptual Flare artwork are embedded images.
Rebuilding makes no image-service calls. Prior v01/v02 files are preserved;
the default build commands now target v03.
On Windows with desktop PowerPoint, render into a **new** directory:

```powershell
New-Item -ItemType Directory -Path .\slides\v03\renders -Force
pwsh -File .\tools\slides\render-powerpoint.ps1 -InputPath .\slides\v03\tribal-knowledge-to-code-v03.pptx -OutputDirectory .\slides\v03\renders\my-review-01 -ExpectedSlideCount 12 -NotesManifestPath .\slides\v03\build-manifest.json
```

Inspect all pages after regeneration. Prior render evidence is invalid when
the PPTX hash changes. Presenter approval, host-route rehearsal and human
timing are separate from generated artifacts and scripted preflight.

Without PowerShell, use the `dotnet` and `npm` commands above directly.
On macOS/Linux use `/` instead of `\` in terminal paths; native PowerPoint COM
rendering is Windows-only. CI validates code and generates PPTX but does not
publish, deploy, or run independent Copilot sessions.

Public sample: https://github.com/elbruno/GitHubCopilotModernizationSamples

See [maintenance](docs/maintenance.md) before updating dependencies, contracts
or skills. A scripted rehearsal is not a timed human rehearsal; independent
baseline/guided Copilot captures remain not-run until genuinely recorded.
