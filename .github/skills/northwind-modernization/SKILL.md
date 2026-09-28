---
name: northwind-modernization
description: Modernize the synthetic Northwind quote application while preserving pricing and JSON compatibility, using the approved audit abstraction, and preventing customer data in logs. Use when migrating its serialization library, repairing JSON-contract regressions, or adding a small response-serialization helper.
---

# Northwind modernization

Apply to this small quote application, not arbitrary production systems.
All examples, policies, and the shared audit library are fictional.
Guidance is not a security boundary, tool permission, or compliance guarantee.

## Inspect before changing

Read the solution/project and lockfiles, `src/Northwind.Quotes/QuoteJson.cs`,
`Program.cs`, domain calculation/output records, existing tests, and
`src/Northwind.Audit/AuditTrail.cs`. Identify applicable requirements and
the exact files you will inspect before editing. Do not assume serializer
defaults match existing behavior.

## Requirements

- **R1:** Decimal money; partner 10% discount only for quantity >= 3.
  Round the total discount once to 2 places, away from zero. Shipping is
  free at discounted net >= 250, otherwise 12. No taxes or currency conversion.
- **R2:** Preserve snake case, lowercase string enums, explicit `review_note`
  null, numeric money, bounded validation and error exits.
  See [pricing and contract](references/pricing-and-contract.md).
- **R3:** All quote events use `IAuditTrail.QuoteCalculated` with a normalized
  correlation ID and total. Keep diagnostics off stdout.
- **R4:** Never log customer ID/email, raw request bodies, serialized customer
  objects, or exception messages containing input, including on failure.
  See [audit and privacy](references/audit-and-privacy.md).

## Concrete traps

Good: `JsonStringEnumConverter<CustomerType>(JsonNamingPolicy.CamelCase, false)`
and `DefaultIgnoreCondition = JsonIgnoreCondition.Never`.
Bad: default numeric enum output or `WhenWritingNull` dropping `review_note`.

Good: `audit.QuoteCalculated(CorrelationId.Normalize(request.CorrelationId), total)`.
Bad: `Console.Error.WriteLine(JsonSerializer.Serialize(request))`.
Moving a raw customer object from stdout to stderr does not make it safe.

## Workflow

1. Assess source, observable behavior, dependencies and visible tests.
2. Map applicable R1-R4 requirements to files and gaps in coverage.
3. Identify the task: library migration, contract regression repair, or small
   serialization reuse. Plan only that change and necessary compatibility
   adjustments. Do not migrate dependencies during an unrelated repair.
4. Implement the selected task:
   - Migration: remove Newtonsoft.Json references and regenerate lockfiles.
   - Repair: reproduce the failing contract test; fix the implementation,
     not the expected contract. Show the same test passing afterward.
   - Reuse: serialize existing response objects with the same output options.
     Keep each item's fields, enum strings, numeric money and explicit null.
     Preserve item order; empty input produces `[]`; reject a null collection.
     Do not recalculate prices, emit new audit events or change the CLI.
5. Run from the exported root:
   ```powershell
   dotnet restore .\Northwind.slnx
   dotnet build .\Northwind.slnx --no-restore
   dotnet test .\Northwind.slnx --no-build --no-restore
   dotnet run --no-build --project .\src\Northwind.Quotes -- --help
   ```
   Add focused regression tests for rules the visible smoke tests miss.
   Follow the [review checklist](references/review-checklist.md).
6. Report changed files, commands and real results, R1-R4 evidence, and
   unresolved risks. Distinguish observed output from suggested checks.

Stop and report contradictions in requirements or inaccessible dependencies.
Do not change business rules to make tests pass, invent results, add services,
deploy, loosen permissions, or claim that skill discovery proves adherence.
