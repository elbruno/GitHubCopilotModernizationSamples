# Evaluating a skill: a simple benchmark setup

A question from the livestream chat: *"Any benchmarking evals setup suggestion per skill?"*

Short answer: **treat a skill like code and test it.** Run the same task with and
without the skill, score each result with checks that give the same answer every
time, and repeat. This repository already has the pieces; this page shows how to
use them.

## The five steps

1. **Fix the task.** Keep a small set of tasks and use the exact same prompt each
   time. Here: [`prompts/01-baseline.txt`](../prompts/01-baseline.txt) (no skill)
   and [`prompts/02-guided.txt`](../prompts/02-guided.txt) (with the skill).
2. **Run A/B.** Run each task once without the skill and once with it. Use a fresh
   Copilot conversation, the same model and the same settings for both.
3. **Score with automated checks, not opinions.** Does it build? Do the tests
   pass? Did it follow each rule the skill teaches? Write one check per rule.
4. **Repeat.** AI output varies between runs. Run each side several times and
   track the pass rate per rule, not a single result.
5. **Rerun when something changes.** A new skill version, a new model or a new
   Copilot release is a reason to run the benchmark again.

## How this repository does it

| Step | Tool | What it checks |
| --- | --- | --- |
| Clean inputs | [`scripts/export-demo.ps1`](../scripts/export-demo.ps1) | Copies only the app, and for `guided` also the skill, to a folder outside the repo, so Copilot can't see the answers |
| Score one run | [`scripts/evaluate.ps1`](../scripts/evaluate.ps1) | restore, build, visible tests, Newtonsoft.Json removed, hidden acceptance tests for rules R1-R4, audit structure |
| Compare runs | [`scripts/compare.ps1`](../scripts/compare.ps1) | Baseline versus guided, using recorded run details (model, prompt, settings) |
| Record a run | [`demos/captures/capture-template.json`](../demos/captures/capture-template.json) | What you ran, so the comparison is fair |

The rules the checks enforce are listed in
[`knowledge/rules-catalog.md`](../knowledge/rules-catalog.md). The skill being
tested is [`northwind-modernization`](../.github/skills/northwind-modernization/SKILL.md).

## Try it: three runs per side

From the root of this repository, in PowerShell 7:

```powershell
$parent = 'D:\SkillBenchmark'
New-Item -ItemType Directory -Path $parent
foreach ($run in 1..3) {
  pwsh -File .\scripts\export-demo.ps1 -RunType baseline -Destination "$parent\baseline-$run"
  pwsh -File .\scripts\export-demo.ps1 -RunType guided -Destination "$parent\guided-$run"
}
```

Open each folder in VS Code, start a **new** Copilot Chat conversation and paste the
matching prompt (`01-baseline.txt` for `baseline-*`, `02-guided.txt` for
`guided-*`). Then score every run:

```powershell
foreach ($side in 'baseline','guided') {
  foreach ($run in 1..3) {
    pwsh -File .\scripts\evaluate.ps1 -CandidateRoot "$parent\$side-$run" -OutputDirectory ".\artifacts\eval-$side-$run"
  }
}
```

Summarize the results in one table:

```powershell
Get-ChildItem .\artifacts -Directory -Filter 'eval-*' | ForEach-Object {
  $report = Get-Content (Join-Path $_.FullName 'evaluation.json') -Raw | ConvertFrom-Json
  [pscustomobject]@{
    Run        = $_.Name
    Status     = $report.status
    Acceptance = ($report.checks | Where-Object name -eq 'acceptance').detail
  }
} | Format-Table -AutoSize -Wrap
```

`evaluate.ps1` exit codes: 0 all checks passed, 1 a check failed, 2 incomplete or
blocked. Each run writes `evaluation.json` with every check and command, so you
can keep the evidence.

## Tips

- **Keep the checks deterministic.** Tests and rule checks give the same answer
  every time; asking another model "is this good?" does not.
- **One check per rule.** When a rule fails, you know which instruction in the
  skill to improve.
- **Hide the answers.** Keep acceptance tests and reference solutions outside the
  folder Copilot works in.
- **Record the setup.** Model, prompt, date and skill version belong with each
  result, or the comparison isn't fair.
- **Be honest about results.** This repository ships no sample Copilot results;
  the captures in `demos/captures` are marked not-run until you record real runs.
