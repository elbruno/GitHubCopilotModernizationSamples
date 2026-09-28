# Demo entry point

Start with the [presenter runbook](runbook.md), then the
[troubleshooting guide](troubleshooting.md).

| State | Location | What it is |
| --- | --- | --- |
| Legacy input | `fixtures/legacy-input` | Working Newtonsoft.Json app; two visible smoke tests |
| Baseline | Exported `baseline` root | Same source without new skill; generation **not-run** |
| Guided | Exported `guided` root | Same source plus four skill files; generation **not-run** |
| Reference | `src` | Tested authored System.Text.Json implementation; not independent agent evidence |

The full repository is a learning/reference package, **not** a neutral baseline
workspace. Use `scripts/export-demo.ps1` for independent generation.

The app runs offline after package restore. Actual Copilot generation requires
an enabled account and network. No cloud provisioning or credentials belong
in this sample.

## First local rehearsal

```powershell
pwsh -File .\scripts\doctor.ps1
npm ci --ignore-scripts
npm run slides:build
pwsh -File .\scripts\verify.ps1
pwsh -File .\scripts\rehearsal.ps1
```

Do not rebuild a visually approved deck immediately before presenting: a new
PPTX hash requires a fresh render/review. `verify.ps1` validates the saved deck
without regenerating it.
