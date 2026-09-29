#Requires -Version 7
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Parent)
$ErrorActionPreference = 'Stop'
$kit = Split-Path $PSScriptRoot -Parent
$parentPath = [IO.Path]::GetFullPath($Parent)
[void][IO.Directory]::CreateDirectory($parentPath)
$workspace = Join-Path $parentPath ("live-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 6))
$evidence = Join-Path $kit ('artifacts\preflight-' + [guid]::NewGuid())
& "$PSScriptRoot\prepare-v03.ps1" -Destination $workspace
& "$PSScriptRoot\test-v03.ps1" -Workspace $workspace -OutputDirectory $evidence
# Only select this workspace after every check passes; preserve the previous selection on failure.
[ordered]@{ workspace = $workspace; evidence = $evidence } |
    ConvertTo-Json | Set-Content -LiteralPath (Join-Path $kit 'artifacts\current-demo.json')
Write-Host "SETUP PASSED. Demo folders: $workspace" -ForegroundColor Green
$guide = if (Test-Path -LiteralPath (Join-Path $kit 'demos\demo01.md')) {
    'demos/demo01.md'
} else {
    'demos/learn/demo01.md'
}
Write-Host "Next: open $guide. Do not run setup again between demos."
