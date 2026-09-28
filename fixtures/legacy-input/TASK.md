# Quote application

Synthetic local command-line sample. From this root:

```powershell
dotnet restore .\Northwind.slnx --locked-mode
dotnet build .\Northwind.slnx --no-restore
dotnet test .\Northwind.slnx --no-build --no-restore
dotnet run --no-build --project .\src\Northwind.Quotes -- --help
```

No argument reads stdin; a single argument reads a request file.

```json
{"order_id":"ORDER-001","customer_id":"SYNTH-CUSTOMER-001","customer_email":"demo@example.invalid","customer_type":"partner","unit_price":100,"quantity":3,"correlation_id":"DEMO-001"}
```

## Task

Modernize this quote application by replacing Newtonsoft.Json with
System.Text.Json. Preserve existing observable behavior and the public JSON
contract. Remove the Newtonsoft.Json dependency. Keep the solution small,
run the existing tests, and explain the changes and remaining risks.
Do not introduce external services or deploy anything.
