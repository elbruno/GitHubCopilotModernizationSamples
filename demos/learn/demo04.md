# Demo 4: Break a rule, catch it, fix it

**Folder:** `05-null-regression` | **Prompt:** [`demos/v03/prompts/04-repair.txt`](../v03/prompts/04-repair.txt)

## What you'll learn

Skills explain the rules. Tests catch it when a rule breaks. You need both.

## Open the demo

First complete [setup](README.md). In the **same PowerShell window**:

```powershell
. (Join-Path $kit 'scripts\open-demo.ps1') -Demo 4
```

This opens VS Code, changes to the demo directory and sets `$demo` and `$prompt`.
Keep using this PowerShell window for commands; use VS Code for code and Chat.
In a new terminal, first set `$kit` to the full path of your cloned repository.
No prompts or answer files are copied into the isolated demo input.

## Steps

1. Inspect the deliberate bug. This copy was broken **on purpose**. In VS Code
   press **Ctrl+P**, paste the `file:line` value and press Enter (or use
   **Ctrl+G** for the line):

   | Ctrl+P (file:line) | Current state |
   | --- | --- |
   | `src\Northwind.Quotes\QuoteJson.cs:18` | Line 18: `JsonIgnoreCondition.WhenWritingNull` drops null fields |
   | `tests\Northwind.UnitTests\SerializationTests.cs:11` | Lines 11-17: `PreservesExplicitNull` protects `review_note` (message on line 16) |
   | `.github\skills\northwind-modernization\SKILL.md:25` | Lines 25-26: rule R2 explains why the null field is required |
   | `.github\skills\northwind-modernization\SKILL.md:38` | Line 38: the bad example names `WhenWritingNull` |

2. Run the contract test and read the failure:

   ```powershell
   dotnet test .\tests\Northwind.UnitTests --no-restore `
     --filter 'FullyQualifiedName~SerializationTests.PreservesExplicitNull'
   ```

   Expected message: *R2: review_note must exist even when its value is null.*

3. Start a **fresh** Copilot Chat in Agent mode. Copy this prompt (use the copy
   button on the block) and paste it into Copilot Chat:

   ```text
   Use the northwind-modernization skill to diagnose the failing
   SerializationTests.PreservesExplicitNull test in this disposable teaching copy.
   This regression was deliberately introduced by the presenter; it is not an
   observed Copilot failure. Run the test first and report the actual assertion.
   Make the smallest implementation repair that preserves R2. Do not weaken the
   test, change pricing, add logs or touch dependencies. Run the unchanged test,
   then the full solution tests, and report real results and remaining risks.
   ```

   Prompt file: `demos\v03\prompts\04-repair.txt` in your clone (also in `$prompt`).
4. Run the same test again, then the full suite:

   ```powershell
   dotnet test .\tests\Northwind.UnitTests --no-restore `
     --filter 'FullyQualifiedName~SerializationTests.PreservesExplicitNull'
   dotnet test .\Northwind.slnx --no-restore
   ```

## What to look for

- Copilot runs the test **before** changing code.
- The fix is in the serializer options (line 18 of `QuoteJson.cs`), not in the test.
- The test file is unchanged in the diff.
- Nothing else changed: no new logs, packages or pricing changes.

## Reset and try again

```powershell
pwsh -NoProfile -File (Join-Path $kit 'scripts\set-demo-null-rule.ps1') -Workspace . -State Broken
```

Use `-State Fixed` to apply the prepared fix without Copilot. If Copilot
fixed it in a different way, the script stops without changing anything. In
that case, run the setup again to get fresh folders.

## What it means

Deleting or weakening a failing assertion makes the test green but hides the
bug. The skill explains *why* the field exists, and the test proves it's back.

**Next: [Demo 5](demo05.md).** Do not run setup again.
