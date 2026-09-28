# Learn by running the five demos

This guide walks you through the five demos from the session **From Tribal
Knowledge to Code: Custom Skills for GitHub Copilot Modernization**. Each demo
has its own page with the steps, what to look for, and what you should learn.

The app is a tiny synthetic .NET quote service. Every customer, rule and team
member is made up. The modernization task is a library migration: from
**Newtonsoft.Json** to **System.Text.Json**.

| # | Demo | Folder | What you'll learn |
| --- | --- | --- | --- |
| 1 | [The task without the skill](demo01.md) | `01-baseline` | What Copilot can and can't know about your team |
| 2 | [Turn team knowledge into a skill](demo02.md) | `02-author-skill` | How to write and review a custom skill |
| 3 | [Apply the skill](demo03.md) | `03-guided` | How to run the same task with team context and check it |
| 4 | [Break a rule, catch it, fix it](demo04.md) | `05-null-regression` | Why skills and tests work together |
| 5 | [Reuse the skill](demo05.md) | `06-reuse-start` | How one skill helps with a different task |

Folders `04-reference` and `07-reuse-complete` are prepared answers you can
compare with your own results.

## What you need

- .NET SDK **10.0.401** or a later 10.0 patch
- PowerShell 7
- GitHub Copilot with agent mode, signed in (only for the Copilot steps)
- Network access for the first package restore

No cloud resources, databases or credentials are needed.

## Set up (once)

From the root of this repository:

```powershell
$kit  = (Get-Location).Path
New-Item -ItemType Directory -Path C:\NorthwindDemos -Force | Out-Null
$demo = Join-Path C:\NorthwindDemos ('run-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
pwsh -NoProfile -File .\scripts\prepare-v03.ps1 -Destination $demo
pwsh -NoProfile -File .\scripts\test-v03.ps1 -Workspace $demo `
  -OutputDirectory (Join-Path $kit ('artifacts\check-' + [guid]::NewGuid()))
```

This creates seven separate demo folders under `$demo` and checks them. The
check expects one failing test in `05-null-regression`. That bug is there on
purpose for Demo 4.

Use a folder that isn't inside your user profile or another repository. The
script stops if a parent folder has its own Copilot instructions or skills
(for example `~\.agents\skills`), because those would leak into the demos.

Keep this terminal open. The demo pages use `$kit` and `$demo`.

## Three rules for good results

1. **Open one demo folder at a time** in your editor, not the parent folder
   and not this repository. This repository contains the answers.
2. **Start a fresh Copilot conversation** for each demo.
3. **Paste the prompt files exactly.** They're in `prompts/` and
   `demos/v03/prompts/`.

Copilot's output changes from run to run. You may get a perfect result in
Demo 1 or a mistake in Demo 3. Both are useful. The goal is to learn how to
check the work, not to get the same answer as someone else.

## Start over

Run the set-up block again with a new `$demo` folder. The script never
overwrites an existing folder.
