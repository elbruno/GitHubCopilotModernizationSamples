# Synthetic rules catalog

| Rule | Why | Source location | Required behavior | Evidence | Context provenance |
| --- | --- | --- | --- | --- | --- |
| R1 | Finance consistency | `Northwind.Domain/Quotation.cs` | Decimal money; partner discount at quantity >= 3; round discount once away from zero; shipping after discount | `PricingTests`; acceptance `R1_R2_R3_R4_PricingContractAndAudit` | Visible in legacy source; one standard smoke case; expanded examples supplied by skill |
| R2 | Existing consumers | `Northwind.Quotes/QuoteJson.cs`, `Program.cs` | Snake case, lowercase enum, explicit null, numeric money, bounded validation and stable exits | Acceptance success, missing/null/type/range/duplicate/case/file/stdin tests | Legacy serializer settings and validation visible; full rationale and checklist added by skill |
| R3 | Consistent fictional audit path | `Northwind.Audit/AuditTrail.cs`; domain constructor | `IAuditTrail.QuoteCalculated` only, safe correlation and total, stderr | Unit spy asserts invocation; process tests inspect structured stderr; candidate structural checks plus human review | Existing source abstraction, not a new proprietary library; skill makes adoption intentional |
| R4 | Minimize customer exposure | CLI error handlers and audit component | No ID/email, raw request, customer object or exception message in diagnostics | Success, invalid-input, file-error and usage-error sentinel checks | Safe source behavior visible; negative testing and rationale supplied by skill |

All paths refer to both `src` and the self-contained legacy `src` tree unless
specified. External acceptance tests stay in the authoring repository.
Passing finite tests is not a privacy proof or a production-readiness claim.

## Supported input policy

Exactly seven case-sensitive, snake-case fields are required. Unknown and
duplicate fields fail. Strings must be nonblank; order ID <= 64 characters,
customer ID <= 128, email <= 256, and correlation input <= 128. The sample does
not verify email ownership or syntax. Correlation output keeps only ASCII
letters, digits, `-` and `_`, takes 32 characters, and uses `UNSPECIFIED` if
empty after normalization. It is a convenience, not a complete privacy system.

Price is a JSON number in [0, 1,000,000], in increments of 0.01; quantity is a
JSON integer in [1, 10,000]. Decimal arithmetic stays far below overflow.
No taxes, currency conversion, or final currency-string formatting.

One JSON object per invocation, <= 16,384 decoded characters, depth <= 8.
Comments and trailing commas are retained legacy conveniences. Other
Newtonsoft-specific non-JSON syntaxes are outside the supported contract.
Money is compared numerically: `270` and `270.00` are equivalent.

Exit codes: 0 success/help, 2 invalid request, 3 file/stream access failure,
64 incorrect command usage. Failures produce no response on stdout and
fixed, data-free diagnostics on stderr.
