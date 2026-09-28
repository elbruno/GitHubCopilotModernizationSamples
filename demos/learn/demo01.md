# Demo 1: The task without the skill

**Folder:** `01-baseline` | **Prompt:** [`prompts/01-baseline.txt`](../../prompts/01-baseline.txt)

## What you'll learn

Copilot knows the technology. It doesn't know your team's unwritten rules.
In this demo you ask for the migration with no extra context, then check
what happened.

## Steps

1. Check that the legacy app works:

   ```powershell
   Set-Location (Join-Path $demo '01-baseline')
   dotnet test .\Northwind.slnx --no-restore
   dotnet run --no-build --project .\src\Northwind.Quotes -- (Join-Path $kit 'fixtures\requests\partner.json')
   ```

   You should see `"total":270.00`, `"customer_type":"partner"` and
   `"review_note":null`. The audit event goes to stderr, separately.

2. Open `src\Northwind.Quotes\QuoteJson.cs`. Notice the settings: snake_case
   field names, lowercase enum values and nulls included. Those details are
   the public contract.
3. Open the folder in your editor and start a fresh Copilot conversation.
4. Paste the contents of `prompts/01-baseline.txt`.
5. When Copilot finishes, review the diff and run the tests again.

## What to look for

- Is `review_note` still written when it's null?
- Is `customer_type` still a lowercase string?
- Did the pricing code change?
- Does audit still go through `IAuditTrail`, not stdout?

## What it means

If everything is right, that's a good result. But ask yourself: how did you
know what "right" means? You had to know the team's rules. The next demos
write those rules down so Copilot and the next developer can use them.

Compare with the prepared migration in `04-reference`.
