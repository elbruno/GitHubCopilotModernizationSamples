#Requires -Version 7
<#
.SYNOPSIS
  Opens one demo: editor window, demo directory and the prompt file path.
  Dot-source it so $kit, $demo and $prompt stay set in this terminal.
.EXAMPLE
  . .\scripts\open-demo.ps1 -Demo 1
#>
param(
    [Parameter(Mandatory)][Alias('Demo')][ValidateRange(1, 5)][int]$DemoNumber,
    [string]$Workspace,
    [ValidateSet('code', 'code-insiders', 'none')][string]$Editor = 'code',
    [switch]$CopyPrompt
)
$ErrorActionPreference = 'Stop'
$kit = Split-Path $PSScriptRoot -Parent
if (-not $Workspace) {
    $state = Join-Path $kit 'artifacts\current-demo.json'
    if (-not (Test-Path -LiteralPath $state)) {
        throw 'Run the setup command on the Start here page first (scripts/start-demos.ps1).'
    }
    $Workspace = (Get-Content -LiteralPath $state -Raw | ConvertFrom-Json).workspace
    if ([string]::IsNullOrWhiteSpace($Workspace)) { throw "Invalid workspace selection: $state" }
}

$map = @{
    1 = @{ Folder = '01-baseline';        Prompt = 'prompts\01-baseline.txt';               Fallback = '04-reference' }
    2 = @{ Folder = '02-author-skill';    Prompt = 'demos\v03\prompts\02-author-skill.txt'; Fallback = $null }
    3 = @{ Folder = '03-guided';          Prompt = 'prompts\02-guided.txt';                 Fallback = '04-reference' }
    4 = @{ Folder = '05-null-regression'; Prompt = 'demos\v03\prompts\04-repair.txt';       Fallback = $null }
    5 = @{ Folder = '06-reuse-start';     Prompt = 'demos\v03\prompts\05-reuse.txt';        Fallback = '07-reuse-complete' }
}[$DemoNumber]

$folder = Join-Path $Workspace $map.Folder
$prompt = Join-Path $kit $map.Prompt
if (-not (Test-Path $folder)) { throw "Missing demo folder: $folder" }
if (-not (Test-Path $prompt)) { throw "Missing prompt: $prompt" }

$Workspace = (Resolve-Path -LiteralPath $Workspace).Path
$demo = $Workspace
if ($Editor -ne 'none') {
    $editorCommand = Get-Command $Editor -ErrorAction Stop
    & $editorCommand --new-window $folder
    if ($LASTEXITCODE -ne 0) { throw "Editor failed to open $folder (exit $LASTEXITCODE)" }
}
if ($CopyPrompt) { Get-Content -LiteralPath $prompt -Raw | Set-Clipboard }
Set-Location -LiteralPath $folder

Write-Host ""
Write-Host "Demo $DemoNumber is ready" -ForegroundColor Green
Write-Host "  Editor window : $folder"
Write-Host "  Prompt file   : $prompt"
if ($CopyPrompt) {
    Write-Host '  Prompt copied to clipboard. Paste it into Copilot Chat before copying anything else.'
} else {
    Write-Host '  Copy the prompt from the demo page (copy button) or open the prompt file above.'
}
if ($map.Fallback) { Write-Host "  Fallback      : $(Join-Path $Workspace $map.Fallback)" }
Write-Host ""
Write-Host "Next:" -ForegroundColor Cyan
$guide = if (Test-Path -LiteralPath (Join-Path $kit "demos\demo0$DemoNumber.md")) {
    "demos\demo0$DemoNumber.md"
} else {
    "demos\learn\demo0$DemoNumber.md"
}
Write-Host "  Follow $guide from top to bottom."
Write-Host '  Run commands in THIS PowerShell window. Use VS Code only for code and Copilot Chat.'
Write-Host '  The page uses dot-sourcing (. before the script path) to set $kit and $demo here.'
