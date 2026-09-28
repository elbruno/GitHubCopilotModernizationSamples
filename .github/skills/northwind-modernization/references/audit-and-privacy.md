# Audit and privacy (synthetic)

The fictional approved abstraction is `IAuditTrail` in `Northwind.Audit`.
Do not replace it with raw object logging. The domain must call its
`QuoteCalculated(string correlationId, decimal total)` once on success.
Do not audit invalid quotes.

The structured stderr event has exactly `event_name: "quote_calculated"`,
`correlation_id`, and numeric `total`. The response alone goes to stdout.
Normalize correlations to ASCII letters/digits/hyphen/underscore, max 32
characters; use `UNSPECIFIED` for an empty normalized value. Bound raw input
to 128 characters. Normalize at the abstraction boundary as well as before
dispatch. This is a demo convenience, not protection against every covert
identifier or privacy risk.

Bad:
```csharp
Console.Error.WriteLine(JsonSerializer.Serialize(request));
Console.Error.WriteLine(exception.Message);
```

Good:
```csharp
audit.QuoteCalculated(CorrelationId.Normalize(request.CorrelationId), total);
// In the CLI's known invalid-input handler:
error.WriteLine("Invalid quote request.");
```

Create unique synthetic customer sentinels, not real people. Inspect complete
stdout and stderr for ID/email keys and values after success, malformed JSON,
missing required fields and invalid numeric ranges. Include I/O and usage
errors; never echo filenames or raw arguments in them.
Do not implement masking by replacing just the known test strings.
Tests cover supported paths; a code review must still inspect new diagnostics.
