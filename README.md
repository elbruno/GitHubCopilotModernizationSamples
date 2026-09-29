# From Tribal Knowledge to Code: Custom Skills for GitHub Copilot Modernization

**Copilot knows the technology. Your team knows the exceptions. Custom skills
connect the two.**

Sample code for Bruno Capuano's session on September 29, 2026 (Microsoft Reactor).

This repository has a tiny .NET 10 quote service, a reusable GitHub Copilot
skill, and five hands-on demos. The modernization task is a library migration:
**Newtonsoft.Json to System.Text.Json**. All people, orders, rules and the
audit component are **synthetic**. It isn't an Azure migration, a framework
upgrade, or a production service.

## Start here: the five demos

Follow the **[demo guide](demos/learn/README.md)**. It sets up seven local demo
folders and walks you through each demo:

1. [The task without the skill](demos/learn/demo01.md)
2. [Turn team knowledge into a skill](demos/learn/demo02.md)
3. [Apply the skill](demos/learn/demo03.md)
4. [Break a rule, catch it, fix it](demos/learn/demo04.md)
5. [Reuse the skill](demos/learn/demo05.md)

## What's in the repository

| Path | What it is |
| --- | --- |
| [`.github/skills/northwind-modernization`](.github/skills/northwind-modernization/SKILL.md) | The reviewed custom skill: rules, examples and review checklist |
| [`knowledge/team-notes.md`](knowledge/team-notes.md) | The fictional team's tribal knowledge |
| [`knowledge/rules-catalog.md`](knowledge/rules-catalog.md) | The four rules (R1-R4) and the JSON contract |
| `fixtures/legacy-input` | The working legacy app on Newtonsoft.Json |
| `src`, `tests` | The authored System.Text.Json reference and its tests |
| `prompts`, `demos/v03/prompts` | The exact prompts used in the demos |
| `scripts` | Set-up, checks, export and evaluation scripts |

## Quick start

You need the .NET SDK **10.0.401** (or a later 10.0 patch) and PowerShell 7.
The first restore needs network access. After that, everything runs locally
with no cloud, containers, database or credentials. The Copilot steps need a
signed-in GitHub Copilot account.

```powershell
dotnet restore .\Northwind.slnx --locked-mode
dotnet build .\Northwind.slnx --no-restore
dotnet test .\Northwind.slnx --no-build --no-restore
dotnet run --no-build --project .\src\Northwind.Quotes -- .\fixtures\requests\partner.json
```

Expected output (stdout):

```json
{"order_id":"ORDER-001","customer_type":"partner","subtotal":300.00,"discount":30.00,"shipping":0.0,"total":270.00,"review_note":null}
```

A separate audit event goes to stderr:

```json
{"event_name":"quote_calculated","correlation_id":"DEMO-001","total":270.00}
```

Run everything the CI runs:

```powershell
pwsh -File .\scripts\verify.ps1
```

The legacy app works the same way:

```powershell
dotnet restore .\fixtures\legacy-input\Northwind.slnx --locked-mode
dotnet build .\fixtures\legacy-input\Northwind.slnx --no-restore
dotnet test .\fixtures\legacy-input\Northwind.slnx --no-build --no-restore
```

## Optional: compare runs with and without the skill

Don't use this whole repository as Copilot's workspace. It contains the rules
and the answers. Export clean copies to a new folder outside the repository:

```powershell
$parent = 'D:\NorthwindFreshDemo'
New-Item -ItemType Directory -Path $parent
pwsh -File .\scripts\export-demo.ps1 -RunType baseline -Destination "$parent\baseline"
pwsh -File .\scripts\export-demo.ps1 -RunType guided -Destination "$parent\guided"
```

Open each folder in a **fresh** Copilot conversation with the same model and
settings. Use [`prompts/01-baseline.txt`](prompts/01-baseline.txt) and
[`prompts/02-guided.txt`](prompts/02-guided.txt). Then check each result:

```powershell
pwsh -File .\scripts\evaluate.ps1 -CandidateRoot "$parent\baseline" -OutputDirectory .\artifacts\baseline-eval
pwsh -File .\scripts\evaluate.ps1 -CandidateRoot "$parent\guided" -OutputDirectory .\artifacts\guided-eval
```

`compare.ps1` reports **not-run** until you record real runs with
[`demos/captures/capture-template.json`](demos/captures/capture-template.json).
Exit codes: 0 all checks passed, 1 a check failed, 2 incomplete or not run.
No sample Copilot results are included; the captures in `demos/captures` are
intentionally marked not-run.

## Learn more

- [Awesome Copilot](https://awesome-copilot.github.com/): community library of skills, agents, instructions and hooks for GitHub Copilot
- [About agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
- [Session resources and official docs](docs/resources.md)
- [Maintaining the sample and skill](docs/maintenance.md)

Bruno's main link: [aka.ms/elbruno](https://aka.ms/elbruno).
