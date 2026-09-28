[CmdletBinding()]
param()
. "$PSScriptRoot/common.ps1"
Push-Location $RepoRoot
$oldDll = $env:QUOTE_APP_DLL
try {
    $env:QUOTE_APP_DLL = $null
    foreach ($solution in @('Northwind.slnx','fixtures/legacy-input/Northwind.slnx')) {
        Invoke-Checked dotnet @('restore',$solution,'--locked-mode')
        Invoke-Checked dotnet @('build',$solution,'--no-restore')
        Invoke-Checked dotnet @('test',$solution,'--no-build','--no-restore')
    }
    $env:QUOTE_APP_DLL = Join-Path $RepoRoot 'fixtures/legacy-input/src/Northwind.Quotes/bin/Debug/net10.0/Northwind.Quotes.dll'
    Invoke-Checked dotnet @('test','tests/Northwind.AcceptanceTests','--no-build','--no-restore')
    $env:QUOTE_APP_DLL = $null
    if (Test-Path -LiteralPath (Join-Path $RepoRoot 'slides/generate.mjs')) {
        & (Join-Path $PSScriptRoot 'validate-content.ps1') -IncludeSlides
        Invoke-Checked npm @('run','slides:package-check')
    }
    else {
        & (Join-Path $PSScriptRoot 'validate-content.ps1')
        Write-Host 'No slide sources in this checkout; slide checks skipped.'
    }
    foreach ($kind in @('baseline','guided')) {
        $capture = Get-Content -LiteralPath "demos/captures/$kind.json" -Raw | ConvertFrom-Json
        Write-Host "Independent $kind capture: $($capture.status) (separate from code verification)."
    }
    Write-Host 'Required code/content/package checks passed. This is not a human rehearsal or agent-generation result.'
}
finally {
    $env:QUOTE_APP_DLL = $oldDll
    Pop-Location
}
