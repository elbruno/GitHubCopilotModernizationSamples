# Demo 4: Break a rule, catch it, fix it

**Folder:** `05-null-regression` | **Prompt:** [`demos/v03/prompts/04-repair.txt`](../v03/prompts/04-repair.txt)

## What you'll learn

Skills explain the rules. Tests catch it when a rule breaks. You need both.

## Steps

1. Open `$demo\05-null-regression`. This copy was broken **on purpose**: the
   serializer options use `WhenWritingNull`, which drops null fields.
2. Run the contract test and read the failure:

   ```powershell
   Set-Location (Join-Path $demo '05-null-regression')
   dotnet test .\tests\Northwind.UnitTests --no-restore `
     --filter 'FullyQualifiedName~SerializationTests.PreservesExplicitNull'
   ```

   Expected message: *R2: review_note must exist even when its value is null.*

3. Start a fresh Copilot conversation and paste the contents of
   `demos/v03/prompts/04-repair.txt`.
4. Run the same test again, then the full suite:

   ```powershell
   dotnet test .\Northwind.slnx --no-restore
   ```

## What to look for

- Copilot runs the test **before** changing code.
- The fix is in the serializer options, not in the test.
- The test file is unchanged in the diff.
- Nothing else changed: no new logs, packages or pricing changes.

## Reset and try again

```powershell
pwsh -NoProfile -File (Join-Path $kit 'scripts\set-demo-null-rule.ps1') `
  -Workspace (Join-Path $demo '05-null-regression') -State Broken
```

Use `-State Fixed` to apply the prepared fix without Copilot. If Copilot
fixed it in a different way, the script stops without changing anything. In
that case, run the set-up again with a new `$demo` folder.

## What it means

Deleting or weakening a failing assertion makes the test green but hides the
bug. The skill explains *why* the field exists, and the test proves it's back.
