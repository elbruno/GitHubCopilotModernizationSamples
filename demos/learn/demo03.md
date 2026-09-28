# Demo 3: Apply the skill

**Folder:** `03-guided` | **Prompt:** [`prompts/02-guided.txt`](../../prompts/02-guided.txt)

## What you'll learn

How to run the same migration as Demo 1 with the team's knowledge available,
and how to check the result instead of assuming it's better.

## Steps

1. Open `$demo\03-guided`. It has the same code and tests as `01-baseline`,
   plus the reviewed skill in `.github/skills/northwind-modernization/`.
2. Start a **fresh** Copilot conversation.
3. Paste the contents of `prompts/02-guided.txt`. It's the Demo 1 prompt plus
   a request to use the skill.
4. When Copilot finishes, run the tests and the evaluator:

   ```powershell
   Set-Location (Join-Path $demo '03-guided')
   dotnet test .\Northwind.slnx
   Set-Location $kit
   pwsh -NoProfile -File .\scripts\evaluate.ps1 `
     -CandidateRoot (Join-Path $demo '03-guided') `
     -OutputDirectory (Join-Path $kit ('artifacts\guided-' + [guid]::NewGuid()))
   ```

## What to look for

- One shared set of serializer options
- Lowercase string enum values
- `review_note` written as `null`, not dropped
- Pricing code unchanged
- Audit still goes through `IAuditTrail`
- Error messages without customer data

The evaluator reports each check. If you run it before Copilot has made any
changes, it correctly reports that the migration isn't done.

## What it means

Having a skill doesn't prove Copilot used it, and using it doesn't prove the
result is correct. The tests and your review are the evidence.

To compare runs fairly, use the same model and settings for Demo 1 and
Demo 3. For a stricter comparison, see "Optional independent comparison" in
the main README.

Compare with the prepared answer in `04-reference`.
