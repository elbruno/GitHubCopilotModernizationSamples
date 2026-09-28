# Presenter runbook: v03

**Skills first, five demos, one app.** Designed 60-minute slot: demos 3-45,
recap 45-50, Q&A 50-60. Use the slides as bookmarks, not a second lecture.
[Run of show](run-of-show.md) is generated from `session.json`.

## Preflight

1. Run the root quick-start restore/build/tests and `scripts/verify.ps1`.
2. Prepare a new neutral teaching parent with `scripts/prepare-v03.ps1`.
   Set `$demo` to the printed path. Run `scripts/test-v03.ps1` with a fresh
   evidence directory. Its expected red test is checked, not ignored.
3. Keep the package repository open in a private editor for prompts and this
   script. Open each numbered checkpoint as its own project/folder in a fresh
   Copilot conversation. Do not add the parent as another workspace directory.
4. Use the same visible model and general agent mode for baseline/guided.
   Review personal/app instructions, plugins and skills. If neutrality cannot
   be established, describe a contextual walkthrough, not a controlled study.
5. Open `slides/v03/tribal-knowledge-to-code-v03.pptx`. Check actual Presenter
   View, screen sharing and text scaling. Mute unrelated notifications.
6. Check the public repository URL signed out before sharing. Native deck QA,
   public availability and timed human rehearsal are separate checks.
7. Rehearse each switch and fallback once. Do not run live demos in the source
   checkout, and do not reuse a mutated workspace as a pristine comparison input.

On the production machine the initially prepared path is
`D:\CopilotModernizationDemo-20260928\v03`. Attendees should create their own
fresh path using the portable commands in [README](README.md).

## Terminal setup

Run these assignments in the presenter terminal, with the first line pointing
to the package checkout and the second to your freshly prepared teaching root:

```powershell
$kit = (Get-Location).Path
$demo = 'D:\CopilotModernizationDemo-20260928\v03' # Replace on another machine
```

Keep `$kit` outside agent-visible contexts. It contains prepared answers.
The following commands work without running any Copilot generation.

## Demo 1: task without the skill (3-8)

Show the working legacy app, then paste the unchanged
[baseline prompt](../../prompts/01-baseline.txt) in `01-baseline`.

```powershell
Set-Location (Join-Path $demo '01-baseline')
dotnet test .\Northwind.slnx --no-restore
dotnet run --no-build --project .\src\Northwind.Quotes -- `
  (Join-Path $kit 'fixtures\requests\partner.json')
```

Expected output: total 270, lowercase partner, explicit `review_note: null`;
separate safe audit event. The source is already correct. Inspect any real
agent diff fairly; the baseline may preserve all rules.

**Hard stop:** after 60-90 seconds of unproductive waiting, stop waiting and
show the prepared `04-reference` serializer with explicit disclosure. Preserve
actual output before manual intervention if collecting evidence. At minute 8,
move on even if migration is unfinished.

## Demo 2: create and review the skill (8-18)

Switch to `02-author-skill`. Show only `knowledge/team-notes.md`, source and
the [authoring prompt](prompts/02-author-skill.txt). Ask Copilot to create the
skill, not migrate code. Inspect:

- A focused `description` saying when to apply it
- The four rules and concrete good/bad examples
- References stored inside the skill package
- Migration, repair and reuse branches with observable verification

Use the actual generated files if available. Do not copy unreviewed text into
the guided checkpoint silently. The prepared guided checkpoint already has a
reviewed version; announce that handoff to keep the live session predictable.
Using a live-authored variant is a teaching variation and must be disclosed,
not treated as the predefined comparison input.

**Fallback:** open `03-guided/.github/skills/northwind-modernization/SKILL.md`.
Say it is the prepared skill and edit/explain one rule live. No need for a
successful agent call to teach structure. **Hard stop: minute 18.**

## Demo 3: apply the skill (18-30)

Fresh conversation in `03-guided`; paste the unchanged
[guided prompt](../../prompts/02-guided.txt). Show the skill before submission.
The prompt explicitly asks to use it. Explain relevance-based selection
without promising automatic activation or adherence.

After a genuine change, rebuild and run the visible tests. From the package
terminal, evaluate externally with the same criteria:

```powershell
Set-Location $kit
pwsh -NoProfile -File .\scripts\evaluate.ps1 `
  -CandidateRoot (Join-Path $demo '03-guided') `
  -OutputDirectory (Join-Path $kit ('artifacts\guided-v03-' + [guid]::NewGuid()))
```

An untouched legacy checkpoint fails the migration criterion; that is not an
agent failure. If no finished candidate is available, show `04-reference`,
run its real tests, and label it authored reference output. Never overwrite
guided output with the reference and then call it a successful guided run.

**Fallback:** `dotnet test` in `04-reference`; show null handling, enum
conversion, decimal pricing and the audit interface. **Hard stop: minute 30.**

## Demo 4: deliberately break, observe, repair (30-37)

Say before showing red output: "I introduced this teaching bug. It is not a
recorded Copilot mistake." `05-null-regression` starts in that broken state.

```powershell
Set-Location (Join-Path $demo '05-null-regression')
dotnet test .\tests\Northwind.UnitTests --no-restore `
  --filter 'FullyQualifiedName~SerializationTests.PreservesExplicitNull'
# Expected exit 1: R2: review_note must exist even when its value is null
```

Paste the [repair prompt](prompts/04-repair.txt). Require the same assertion
before and after the fix; do not accept a weakened test. `dotnet test` here
builds current code, avoiding stale binaries.

Fallback repair, explicitly announced as scripted:

```powershell
pwsh -NoProfile -File (Join-Path $kit 'scripts\set-demo-null-rule.ps1') `
  -Workspace (Join-Path $demo '05-null-regression') -State Fixed
dotnet test .\tests\Northwind.UnitTests --no-restore `
  --filter 'FullyQualifiedName~SerializationTests.PreservesExplicitNull'
dotnet test .\Northwind.slnx --no-restore
```

To rehearse again, use `-State Broken` and rerun the test so current source is
rebuilt. The helper accepts only the explicitly marked disposable checkpoint.
**Hard stop: minute 37.**

## Demo 5: reuse on a different task (37-45)

Fresh conversation in `06-reuse-start`; paste the
[reuse prompt](prompts/05-reuse.txt). This is already modernized, so dependency
migration is not applicable. Look for:

- `QuoteJson.WriteBatch` sharing the existing output options
- Ordered per-item JSON equivalence, explicit nulls and string enums
- Empty input `[]`, null collection rejection, no CLI/pricing/audit changes

```powershell
Set-Location (Join-Path $demo '06-reuse-start')
# Run after Copilot has actually implemented the method and tests
dotnet test .\tests\Northwind.UnitTests --no-restore --filter 'FullyQualifiedName~BatchSerializationTests'
dotnet test .\Northwind.slnx --no-restore
```

**Do not treat "no matching tests" as success.** Check that the focused tests
actually exist and execute. The prepared checkpoint has three such tests.
Other valid live implementations may use different names; run their real tests.

**Fallback:** switch to `07-reuse-complete`; announce "prepared implementation"
and run the same focused and full commands there. Compare its app source with
`06-reuse-start`: only the serializer method is added. **Hard stop: minute 45.**

## Close, Q&A and cuts

At 45: use slide 10 to name what attendees just saw: prompt, instructions,
skill, test. At 47: skill ownership/versioning and one small next task.
At 50: resources and Q&A. Protect those ten minutes.

If five minutes behind, shorten agent waiting and code tours, not disclosure:
use the prepared migration at 28, demonstrate only one red/green assertion,
and show the prepared batch helper with its three real tests. If ten minutes
behind, make reuse a two-minute walkthrough, skip extra architecture discussion
and reach resources at 50.

Q&A: [existing question bank](../runbook.md#closing-and-qa-slides-9-12-elapsed-41-60).
Skill availability does not prove use; use does not guarantee correctness;
finite tests do not establish universal compliance.

## Evidence boundaries

The seven snapshots, scripted red/green rehearsal and reference tests are real
prepared materials. Independent agent captures remain not-run unless genuine
sessions are recorded separately. Keep raw prompts, outputs, interventions and
host metadata local; use the original [capture procedure](../runbook.md#external-evaluation-and-capture)
for any formal comparison. Do not publish private transcripts or account settings.
