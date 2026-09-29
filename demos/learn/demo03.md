# Demo 3: Apply the skill

**Folder:** `03-guided` | **Prompt:** [`prompts/02-guided.txt`](../../prompts/02-guided.txt)

## What you'll learn

How to run the same migration as Demo 1 with the team's knowledge available,
and how to check the result instead of assuming it's better.

## Open the demo

First complete [setup](README.md). In the **same PowerShell window**:

```powershell
. (Join-Path $kit 'scripts\open-demo.ps1') -Demo 3
```

This opens VS Code, changes to the demo directory and sets `$demo` and `$prompt`.
Keep using this PowerShell window for commands; use VS Code for code and Chat.
In a new terminal, first set `$kit` to the full path of your cloned repository.
No prompts or answer files are copied into the isolated demo input.

## Steps

1. Inspect what's different. `03-guided` has the same code and tests as
   `01-baseline`, plus the reviewed skill. In VS Code press **Ctrl+P**, paste
   the `file:line` value and press Enter (or use **Ctrl+G** for the line):

   | Ctrl+P (file:line) | Current state |
   | --- | --- |
   | `.github\skills\northwind-modernization\SKILL.md:3` | Line 3: the description that tells Copilot when to use the skill |
   | `.github\skills\northwind-modernization\SKILL.md:22` | Lines 22-32: rules R1 to R4 |
   | `src\Northwind.Quotes\Northwind.Quotes.csproj:7` | Line 7: the same Newtonsoft.Json dependency |
   | `src\Northwind.Quotes\QuoteJson.cs:18` | Lines 18-23: the same serializer settings |

2. Start a **fresh** Copilot Chat in Agent mode.
3. Copy this prompt (use the copy button on the block) and paste it into
   Copilot Chat. It's the Demo 1 prompt plus a request to use the skill:

   ```text
   Modernize this quote application by replacing Newtonsoft.Json with
   System.Text.Json. Preserve existing observable behavior and the public JSON
   contract. Remove the Newtonsoft.Json dependency. Keep the solution small,
   run the existing tests, and explain the changes and remaining risks.
   Do not introduce external services or deploy anything.

   Use the northwind-modernization skill available in this project.
   First identify its applicable requirements and the files you will inspect.
   Use its supporting examples and acceptance criteria during the migration,
   and report the evidence for each relevant rule.
   ```

   Prompt file: `prompts\02-guided.txt` in your clone (also in `$prompt`).
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

Line numbers change after Copilot edits, so use **Ctrl+F** in `QuoteJson.cs`:

- One shared set of serializer options
- Lowercase string enum values (`JsonStringEnumConverter`)
- `review_note` written as `null`, not dropped (`JsonIgnoreCondition.Never`)
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

Compare with the prepared answer in `04-reference`
(`src\Northwind.Quotes\QuoteJson.cs`, lines 15-20).

**Next: [Demo 4](demo04.md).** Do not run setup again.
