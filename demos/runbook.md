# Presenter runbook

**Historical v01 route.** The current demo-heavy session uses the
[v03 five-demo runbook](v03/runbook.md) and [spoken demo script](v03/demo-script.md).
The capture/evaluation details below remain useful for optional independent comparisons.

**Session:** From Tribal Knowledge to Code: Custom Skills for GitHub Copilot Modernization

**Presenter:** Bruno Capuano

**Public slot:** September 29, 2026, 13:00-14:00 America/New_York

**Status:** working local reference; independent baseline/guided generation not-run

All people, orders, policies, and the audit library are synthetic.
This is a dependency/API migration, not an Azure migration or framework upgrade.
The designed timings below are not a measured human rehearsal.

## Choose the honest delivery path

**Path A: fresh independent runs.** Use the standalone exports in separate
fresh conversations. Match host, mode, model and settings. Inventory inherited
context first. Do not give the authoring conversation either task.

**Path B: reliable reference walkthrough.** Available now without Copilot.
Say: "This is the prepared reference implementation, not a captured independent
Copilot result. We are walking through how the rules guide the migration and
how to review it." Show legacy/source differences and run real tests.

Do not wait silently on a live agent for more than 60-90 seconds. Switch to
Path B or a genuine saved capture, and name what you are showing.

## Before screen sharing

1. Restore packages and run `pwsh -File .\scripts\verify.ps1`.
2. Run `pwsh -File .\scripts\rehearsal.ps1`; it creates real sample-output
   evidence under a unique `artifacts/rehearsal-*` folder, not agent captures.
3. Open `slides/dist/tribal-knowledge-to-code.pptx` and
   `slides/speaker-notes.md`. Use Presenter View on the private display.
4. Open the reference editor, a readable terminal, and separate fresh demo
   sessions. Disable unrelated notifications; test actual shared screen at
   1920x1080 and suitable scaling. Hide account details and private paths.
5. Confirm the attendee repository URL from its actual remote and test access
   signed out. It is not configured in the initial public local checkout.
6. Check that the final deck is the hash that was rendered; no last-minute
   regeneration without reinspection.

## Local commands, no agent required

Run from the sample repository root:

```powershell
dotnet run --no-build --project .\src\Northwind.Quotes -- .\fixtures\requests\partner.json
dotnet run --no-build --project .\src\Northwind.Quotes -- .\fixtures\requests\invalid.json
# Previous command intentionally exits 2
dotnet test .\tests\Northwind.UnitTests --no-build --no-restore
dotnet test .\tests\Northwind.AcceptanceTests --no-build --no-restore
```

Success: stdout contains total 270 and `review_note: null`; stderr contains
exactly the audit event with correlation DEMO-001 and total 270. Invalid input:
empty stdout, fixed message on stderr, no sentinel ID/email.

For a clean stream split without `dotnet run` build chatter:

```powershell
dotnet .\src\Northwind.Quotes\bin\Debug\net10.0\Northwind.Quotes.dll .\fixtures\requests\partner.json
```

## Export and context preflight

Choose an existing neutral parent **outside** the sample and internal repos,
with no ancestor instruction/skill folders. The exporter refuses existing
targets; do not erase one to rerun it.

```powershell
$demoParent = 'D:\CopilotModernizationDemo-20260928'
# These exports have already been prepared on the presenting machine.
# For a new attempt choose a new parent or unused destination names.
pwsh -File .\scripts\export-demo.ps1 -RunType baseline -Destination "$demoParent\baseline"
pwsh -File .\scripts\export-demo.ps1 -RunType guided -Destination "$demoParent\guided"
```

Existing prepared paths: `D:\CopilotModernizationDemo-20260928\baseline` and
`D:\CopilotModernizationDemo-20260928\guided`. Both have already restored,
built, and passed their two smoke tests. Those builds are not agent runs.

The shared manifest covers 18 identical files, including source, projects,
lockfiles and smoke tests. Guided adds only the four skill-package files.
The manifest does not attest to global/app instructions or personal skills.

The installed CLI supports these read-only inventories:

```powershell
copilot --no-auto-update -C "$demoParent\baseline" instruction list --json
copilot --no-auto-update -C "$demoParent\baseline" skill list --json
copilot --no-auto-update -C "$demoParent\guided" instruction list --json
copilot --no-auto-update -C "$demoParent\guided" skill list --json
```

Inspect locally; inventories can contain personal paths/descriptions. CLI
instruction inspection explicitly excludes host-projected instructions.
Also inspect app Settings > Sessions > App instructions, project instructions,
and Customize > Skills/installed plugins. Do not modify personal settings
silently. There is no verified temporary neutral-profile route in this kit.
If neutral context cannot be established, call this a **contextual walkthrough**.
Do not claim `--no-custom-instructions` removes all skill or app context.

In the app, open each export as its own folder/project and start a new
conversation with no copied authoring history or added authoring directories.
Use the same general agent mode and visible model for both. Do not select a
dedicated Upgrade agent for only one run. Its use of this skill is unverified.

## Act 1: baseline (slides 1-5, elapsed 0-19)

1. Opening: "Every team has someone who says, yes, that code works, but we do
   not do it that way here."
2. Show the decimal midpoint test early on slide 2. Technical correctness is
   not the same thing as business and organizational correctness.
3. In the baseline root, show `src/Northwind.Quotes/QuoteJson.cs`, the domain
   calculation and `TASK.md`. Do not open the external evaluation answers there.
4. Run its help and smoke tests. Paste **exactly** `prompts/01-baseline.txt`
   into the fresh conversation; paste text, do not attach the full authoring repo.
5. Inspect genuine changes and test output. A correct baseline is a success,
   not an inconvenience to explain away.
6. Save prompt, host/mode/model, timestamps, commands, output/patch and
   interventions outside the candidate. Do not repair it before capturing.

## Act 2: make knowledge reusable (slides 6-7, elapsed 19-27)

1. Switch to the learning/reference repository, not the baseline session.
2. Show `knowledge/team-notes.md`, Alex's explicit-null requirement.
3. Show `.github/skills/northwind-modernization/SKILL.md`: minimal frontmatter,
   activation description, inspect-first workflow and R1-R4.
4. Open `references/pricing-and-contract.md` and the completion checklist.
5. Show the actual `JsonIgnoreCondition.Never` setting and null assertion.
6. Say: "The old source already contains clues. We are packaging intent and
   evidence, not hiding a deliberately broken implementation."

## Act 3: guided (slide 8, elapsed 27-41)

1. Open the distinct guided root and a fresh conversation.
2. Compare `sharedFiles` in the two input manifests. Show the added skill.
3. Paste **exactly** `prompts/02-guided.txt`.
4. Ask no extra leading questions without recording the intervention.
   Skill availability is not proof of use. Record what the host actually exposes.
5. Inspect the diff and real outputs. Preserve any failure before correction.
6. If blocked or slow, use the reference: serializer options, decimal
   calculation, narrow audit API, safe CLI handlers and real acceptance tests.

## External evaluation and capture

Evaluate one candidate without claiming generation:

```powershell
$stamp = Get-Date -Format yyyyMMdd-HHmmss
pwsh -File .\scripts\evaluate.ps1 -CandidateRoot "$demoParent\baseline" -OutputDirectory ".\artifacts\baseline-$stamp"
```

The unmodified legacy export intentionally fails only the migration criterion:
Newtonsoft.Json is still present. Do not call that an agent failure.
Use `-Kind legacy` when demonstrating legacy behavior preservation, or
`-Kind reference -CandidateRoot .` when evaluating the authored reference.

For a genuine run, copy `demos/captures/capture-template.json` into a new
local artifact file and fill its metadata. Set `status: completed` only after
a real run; `provenance: untouched-agent-output`. Record model as `not exposed`
if it is unavailable. `commands` should contain actual command, exit, result
and elapsed time only when measured. Record every human intervention.

Record human `review.status` as pass/fail with reviewer and notes covering
diff scope, audit call path, new diagnostics and pricing behavior. Leaving it
not-run blocks a complete comparison, even if automated checks pass.

```powershell
pwsh -File .\scripts\seal-capture.ps1 -CandidateRoot "$demoParent\baseline" -MetadataPath .\artifacts\baseline-metadata.json -OutputPath .\artifacts\baseline-capture.json
pwsh -File .\scripts\seal-capture.ps1 -CandidateRoot "$demoParent\guided" -MetadataPath .\artifacts\guided-metadata.json -OutputPath .\artifacts\guided-capture.json
pwsh -File .\scripts\compare.ps1 -BaselineRoot "$demoParent\baseline" -GuidedRoot "$demoParent\guided" -BaselineCapture .\artifacts\baseline-capture.json -GuidedCapture .\artifacts\guided-capture.json -OutputDirectory ".\artifacts\comparison-$stamp"
```

Without capture arguments the checked-in `not-run` manifests are used:
reports are written and exit **2**, not success. Exit **1** indicates applicable
failed checks; **2** incomplete/blocked/not-run; **0** all required evaluated
checks and recorded reviews pass. Source heuristics are not a proof of architecture.
The report labels unmatched/uncertain host settings as contextual, not controlled.
Reports never assume a winner. Do not put raw transcripts in the public repo.

## Closing and Q&A (slides 9-12, elapsed 41-60)

Show actual comparison statuses or slide 9's honest checklist. Then say:
"Pick one modernization task. Capture one rule your team keeps explaining.
Encode it in a skill. Review the result. Reuse it."

Keep slide 12 visible for the last eight minutes.

| Question | Short answer |
| --- | --- |
| Skill versus repository instructions? | Instructions cover broadly applicable conventions; a skill packages a relevant specialized workflow, examples and resources |
| Does it guarantee company rules are followed? | No. It supplies context; executable checks and human review remain necessary |
| Skill versus test? | Skill explains intent, workflow and review; tests assert defined observable cases. Use both |
| How do skills stay current? | Assign an owner, version with related code, review rule changes, and update examples/tests together |
| What if baseline is already correct? | Show that honestly. Discuss repeatability and discoverable intent, not a forced failure narrative |

## 45-minute core delivery path

If running short: host/opening 0-3; problem/context 3-8; baseline 8-15;
rule/skill 15-22; guided or reference 22-35; evidence 35-40; closing/resources
40-45. Protect Q&A; drop the optional reuse exercise and extra product tour.
Do not drop the honest comparison or label reference output as a live run.
