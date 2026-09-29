# Demo 1: The task without the skill

**Folder:** `01-baseline` | **Prompt:** [`prompts/01-baseline.txt`](../../prompts/01-baseline.txt)

## What you'll learn

Copilot knows the technology. It doesn't know your team's unwritten rules.
In this demo you ask for the migration with no extra context, then check
what happened.

## Open the demo

First complete [setup](README.md). In the **same PowerShell window**:

```powershell
. (Join-Path $kit 'scripts\open-demo.ps1') -Demo 1
```

This opens VS Code, changes to the demo directory and sets `$demo` and `$prompt`.
Keep using this PowerShell window for commands; use VS Code for code and Chat.
In a new terminal, first set `$kit` to the full path of your cloned repository.
No prompts or answer files are copied into the isolated demo input.

## Steps

1. Check that the legacy app works:

   ```powershell
   dotnet test .\Northwind.slnx --no-restore
   dotnet run --no-build --project .\src\Northwind.Quotes -- (Join-Path $kit 'fixtures\requests\partner.json')
   ```

   You should see `"total":270.00`, `"customer_type":"partner"` and
   `"review_note":null`. The audit event goes to stderr, separately.

2. Inspect the current code. In VS Code press **Ctrl+P**, paste the `file:line`
   value and press Enter (or open the file and press **Ctrl+G** for the line):

   | Ctrl+P (file:line) | Current state |
   | --- | --- |
   | `src\Northwind.Quotes\Northwind.Quotes.csproj:7` | Line 7: the Newtonsoft.Json package reference |
   | `src\Northwind.Quotes\QuoteJson.cs:18` | Lines 18-23: `OutputSettings`: snake case, lowercase string enums, nulls included |
   | `src\Northwind.Quotes\QuoteJson.cs:75` | Line 75: `Write` serializes every response with those settings |
   | `src\Northwind.Quotes\Program.cs:36` | Lines 36-38: read the request, calculate, write the JSON |
   | `src\Northwind.Domain\Quotation.cs:39` | Lines 39-43: partner discount, rounding and shipping must not change |

   Those serializer details are the public contract.

3. Start a **fresh** Copilot Chat in Agent mode in that VS Code window.
4. Copy this prompt (use the copy button on the block) and paste it into Copilot Chat:

   ```text
   Modernize this quote application by replacing Newtonsoft.Json with
   System.Text.Json. Preserve existing observable behavior and the public JSON
   contract. Remove the Newtonsoft.Json dependency. Keep the solution small,
   run the existing tests, and explain the changes and remaining risks.
   Do not introduce external services or deploy anything.
   ```

   Prompt file: `prompts\01-baseline.txt` in your clone (the full path is
   printed by `open-demo.ps1` and stored in `$prompt`).
5. When Copilot finishes, review the diff and run the tests again. Line numbers
   change after edits, so use **Ctrl+F** for `review_note` and the enum converter.

## What to look for

- Is `review_note` still written when it's null?
- Is `customer_type` still a lowercase string?
- Did the pricing code change?
- Does audit still go through `IAuditTrail`, not stdout?

## What it means

If everything is right, that's a good result. But ask yourself: how did you
know what "right" means? You had to know the team's rules. The next demos
write those rules down so Copilot and the next developer can use them.

Compare with the prepared migration in `04-reference`
(`src\Northwind.Quotes\QuoteJson.cs`, lines 15-20).

**Next: [Demo 2](demo02.md).** Do not run setup again.
