[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputParent)
. "$PSScriptRoot/common.ps1"
$parent = [IO.Path]::GetFullPath($OutputParent)
if (Test-IsWithin $parent $RepoRoot) { throw 'Use an external parent for isolation validation.' }
[void][IO.Directory]::CreateDirectory($parent)
$baseline = Join-Path $parent 'baseline'
$guided = Join-Path $parent 'guided'
Invoke-Checked pwsh @('-NoProfile','-File',(Join-Path $PSScriptRoot 'export-demo.ps1'),'-RunType','baseline','-Destination',$baseline)
Invoke-Checked pwsh @('-NoProfile','-File',(Join-Path $PSScriptRoot 'export-demo.ps1'),'-RunType','guided','-Destination',$guided)
$a = Get-Content -LiteralPath (Join-Path $baseline 'input-manifest.json') -Raw | ConvertFrom-Json
$b = Get-Content -LiteralPath (Join-Path $guided 'input-manifest.json') -Raw | ConvertFrom-Json
if (($a.sharedFiles | ConvertTo-Json -Compress) -cne ($b.sharedFiles | ConvertTo-Json -Compress)) {
    throw 'Shared source/test hashes differ.'
}
foreach ($root in @($baseline,$guided)) {
    $manifest = Get-Content -LiteralPath (Join-Path $root 'input-manifest.json') -Raw | ConvertFrom-Json
    $actual = @(Get-ChildItem -LiteralPath $root -File -Recurse -Force)
    if ($actual.Count -ne $manifest.files.Count + 1) { throw 'Unexpected files leaked into export.' }
    foreach ($file in $manifest.files) {
        if ((Get-Sha256 (Join-Path $root $file.path)) -cne $file.sha256) { throw 'Export hash mismatch.' }
    }
    Push-Location $root
    try {
        Invoke-Checked dotnet @('restore','Northwind.slnx','--locked-mode')
        Invoke-Checked dotnet @('build','Northwind.slnx','--no-restore')
        Invoke-Checked dotnet @('test','Northwind.slnx','--no-build','--no-restore')
    }
    finally { Pop-Location }
}
$rejected = $false
try { & (Join-Path $PSScriptRoot 'export-demo.ps1') -RunType baseline -Destination $baseline }
catch { $rejected = $_.Exception.Message -like 'Destination exists*' }
if (-not $rejected) { throw 'Existing destination was not rejected.' }
[ordered]@{ status = 'pass'; sharedFileCount = $a.sharedFiles.Count; guidedAdditionalFiles = $b.files.Count - $a.files.Count
    independentBuilds = 2; overwriteRejected = $rejected; agentRuns = 'not-run'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $parent 'export-verification.json') -Encoding utf8
Write-Host 'Both standalone roots restore/build/test; matching source manifests; overwrite rejected. No agent runs.'
