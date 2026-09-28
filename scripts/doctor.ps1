[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$missing = @()
foreach ($tool in @('dotnet','node','npm','pwsh')) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        $version = if ($tool -eq 'pwsh') { & $tool -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' } else { & $tool --version }
        Write-Host "${tool}: $version"
    }
    else { $missing += $tool; Write-Warning "$tool is missing; install it yourself before rehearsal." }
}
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Write-Host 'Installed SDKs:'
    dotnet --list-sdks
}
Write-Host 'Required: SDK pinned in global.json, Node 24 LTS, PowerShell 7 for scripts.'
if ($IsWindows) {
    $office = Join-Path ${env:ProgramFiles} 'Microsoft Office/root/Office16/POWERPNT.EXE'
    Write-Host "Optional native PowerPoint executable found: $(Test-Path -LiteralPath $office)"
}
Write-Host "Optional LibreOffice on PATH: $([bool](Get-Command soffice -ErrorAction SilentlyContinue))"
Write-Host "Copilot command found: $([bool](Get-Command copilot -ErrorAction SilentlyContinue))"
Write-Host 'Copilot authentication, app model, skill activation, and neutral context are NOT verified by doctor.'
Write-Host 'No software installed or configuration changed.'
if ($missing.Count) { exit 1 }
