# Demo 5: Reuse the skill

**Folder:** `06-reuse-start` | **Prompt:** [`demos/v03/prompts/05-reuse.txt`](../v03/prompts/05-reuse.txt)

## What you'll learn

A skill isn't a one-time prompt. The same team knowledge helps with a new,
different task.

## Open the demo

First complete [setup](README.md). In the **same PowerShell window**:

```powershell
. (Join-Path $kit 'scripts\open-demo.ps1') -Demo 5
```

This opens VS Code, changes to the demo directory and sets `$demo` and `$prompt`.
Keep using this PowerShell window for commands; use VS Code for code and Chat.
In a new terminal, first set `$kit` to the full path of your cloned repository.
No prompts or answer files are copied into the isolated demo input.

## Steps

1. Inspect the starting code. The app is already on System.Text.Json and has
   the skill. In VS Code press **Ctrl+P**, paste the `file:line` value and press
   Enter (or use **Ctrl+G** for the line):

   | Ctrl+P (file:line) | Current state |
   | --- | --- |
   | `src\Northwind.Quotes\QuoteJson.cs:15` | Lines 15-20: `OutputOptions` with System.Text.Json |
   | `src\Northwind.Quotes\QuoteJson.cs:63` | Line 63: `Write` for one response; there is no `WriteBatch` yet |
   | `src\Northwind.Quotes\Northwind.Quotes.csproj:6` | Lines 6-7: no Newtonsoft.Json dependency |
   | `.github\skills\northwind-modernization\SKILL.md:55` | Lines 55-58: the skill's reuse branch |

2. Start a **fresh** Copilot Chat in Agent mode. Copy this prompt (use the copy
   button on the block) and paste it into Copilot Chat:

   ```text
   Use northwind-modernization for a small follow-up task in this already-modernized
   synthetic quote application. Add QuoteJson.WriteBatch(IReadOnlyList<QuoteResponse>)
   for existing responses, reusing the single-response serializer's output options.
   Preserve array order and each item's exact JSON field names, lowercase string
   enum, numeric money, and explicit review_note null. Empty input must produce [];
   a null collection must throw ArgumentNullException. Do not recalculate pricing,
   emit audit events, change the single-request CLI, migrate libraries or add packages.
   Add focused tests for two different responses, item equivalence with Write,
   empty input, and null input. Run the relevant and full existing tests. Identify
   applicable skill rules and report actual evidence, not assumed success.
   ```

   Prompt file: `demos\v03\prompts\05-reuse.txt` in your clone (also in `$prompt`).
3. Run the new tests, then the full suite:

   ```powershell
   dotnet test .\tests\Northwind.UnitTests --no-restore --filter 'FullyQualifiedName~Batch'
   dotnet test .\Northwind.slnx --no-restore
   ```

   If Copilot used a different test class name, change the filter to match.

## What to look for

Line numbers change after Copilot edits, so use **Ctrl+F** for `WriteBatch`:

- `WriteBatch` reuses the same serializer options as `Write`.
- Items stay in their original order.
- Each item keeps `review_note: null` and lowercase enums.
- Empty input returns `[]`; a null list throws `ArgumentNullException`.
- Pricing, audit and the command-line app are unchanged.
- **The test count is above zero.** A filter that matches no tests isn't a pass.

## What it means

You didn't repeat the rules in the prompt. The skill carried them. That's the
payoff of writing tribal knowledge down once.

Compare with the prepared version in `07-reuse-complete`: `WriteBatch` is at
line 65 of `src\Northwind.Quotes\QuoteJson.cs`, and
`tests\Northwind.UnitTests\BatchSerializationTests.cs` has three focused tests
(lines 11, 34 and 42):

```powershell
Set-Location ..\07-reuse-complete
dotnet test .\tests\Northwind.UnitTests --no-restore --filter 'FullyQualifiedName~BatchSerializationTests'
```

## Next step

Pick one rule your team keeps explaining. Write it as a small skill with an
example and a test. Keep the skill in the repo and review changes to it like
code.
