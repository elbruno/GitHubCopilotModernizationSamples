# Authoring repository

This is a synthetic, local livestream demo, not customer code.
Use the SDK pinned in `global.json` and preserve existing work.

- Build/test: `dotnet restore .\Northwind.slnx`, `dotnet build .\Northwind.slnx --no-restore`,
  `dotnet test .\Northwind.slnx --no-build --no-restore`.
- Also build/test `fixtures\legacy-input\Northwind.slnx`.
- Full verification: `pwsh -File .\scripts\verify.ps1`.
- Deck: `npm ci` then `npm run slides:build`. Source is `slides\content.mjs`.
- `src` is the reference; `fixtures\legacy-input` is the independent starting
  app. Neither baseline nor guided output exists until a genuine run is captured.
- Keep the acceptance evaluator, knowledge, and authoring instructions outside
  demo exports. Use only the allowlist exporter, never copy the whole repository.
- Report real evidence and distinguish failed, blocked, and not-run work.
  Domain guidance belongs in the northwind-modernization skill, not duplicated here.
- Do not install system-wide tools, publish, deploy, provision cloud services,
  push, send messages or change credentials/permissions without authorization.
