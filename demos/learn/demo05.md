# Demo 5: Reuse the skill

**Folder:** `06-reuse-start` | **Prompt:** [`demos/v03/prompts/05-reuse.txt`](../v03/prompts/05-reuse.txt)

## What you'll learn

A skill isn't a one-time prompt. The same team knowledge helps with a new,
different task.

## Open and inspect the demo

First complete [setup](README.md). In the **same PowerShell window**:

```powershell
. (Join-Path $kit 'scripts\open-demo.ps1') -Demo 5
```

This opens VS Code, selects the demo directory and sets `$demo` and `$prompt`.
Keep using this PowerShell window for commands; use VS Code for code and Chat.
In a new terminal, first set `$kit` to the full path of your cloned repository.
No prompts or answer files are copied into the isolated demo input.

Press **Ctrl+P** in VS Code to inspect:

| File | Current state |
| --- | --- |
| `src\Northwind.Quotes\QuoteJson.cs` | System.Text.Json is already in place; Write exists, WriteBatch does not |
| `src\Northwind.Quotes\Northwind.Quotes.csproj` | No Newtonsoft.Json dependency |
| `.github\skills\northwind-modernization\SKILL.md` | Reuse the same rules for a new task |

When the steps below ask for the prompt, run this **immediately before pasting**,
then paste into a fresh Copilot Chat in Agent mode:

```powershell
Get-Content -LiteralPath $prompt -Raw | Set-Clipboard
```

## Steps

1. Open `$demo\06-reuse-start`. The app is already on System.Text.Json and
   has the skill.
2. Start a fresh Copilot conversation and paste the contents of
   `demos/v03/prompts/05-reuse.txt`. It asks for a new
   `QuoteJson.WriteBatch` method that writes several quotes as one JSON array.
3. Run the new tests, then the full suite:

   ```powershell
   Set-Location (Join-Path $demo '06-reuse-start')
   dotnet test .\tests\Northwind.UnitTests --no-restore --filter 'FullyQualifiedName~Batch'
   dotnet test .\Northwind.slnx --no-restore
   ```

   If Copilot used a different test class name, change the filter to match.

## What to look for

- `WriteBatch` reuses the same serializer options as `Write`.
- Items stay in their original order.
- Each item keeps `review_note: null` and lowercase enums.
- Empty input returns `[]`; a null list throws `ArgumentNullException`.
- Pricing, audit and the command-line app are unchanged.
- **The test count is above zero.** A filter that matches no tests isn't a pass.

## What it means

You didn't repeat the rules in the prompt. The skill carried them. That's the
payoff of writing tribal knowledge down once.

Compare with the prepared version in `07-reuse-complete`, which has three
focused tests:

```powershell
Set-Location (Join-Path $demo '07-reuse-complete')
dotnet test .\tests\Northwind.UnitTests --no-restore --filter 'FullyQualifiedName~BatchSerializationTests'
```

## Next step

Pick one rule your team keeps explaining. Write it as a small skill with an
example and a test. Keep the skill in the repo and review changes to it like
code.
