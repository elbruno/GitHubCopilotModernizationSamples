[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('baseline','guided')][string]$RunType,
    [Parameter(Mandatory)][string]$Destination
)
. "$PSScriptRoot/common.ps1"

$destinationPath = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationPath) { throw 'Destination exists; choose a new path. Nothing was overwritten.' }
if (Test-IsWithin $destinationPath $RepoRoot) { throw 'Export must be outside the authoring repository.' }
$parent = Split-Path $destinationPath -Parent
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw 'Create or choose an explicit existing output parent first.' }

# Ancestor instructions can contaminate a fresh directory before its first prompt.
$cursor = $parent
while ($cursor) {
    foreach ($name in @('AGENTS.md','CLAUDE.md','GEMINI.md','.github/copilot-instructions.md',
            '.github/skills','.agents/skills','.claude/skills','.github/instructions','.github/agents')) {
        if (Test-Path -LiteralPath (Join-Path $cursor $name)) {
            throw "Ancestor context found at $cursor ($name). Choose a neutral parent."
        }
    }
    if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'A linked output ancestor is not supported; choose a physical directory.'
    }
    $next = Split-Path $cursor -Parent
    if ($next -eq $cursor) { break }
    $cursor = $next
}
$shared = Get-SharedManifest
$skillFiles = @('SKILL.md','references/pricing-and-contract.md',
    'references/audit-and-privacy.md','references/review-checklist.md')
$skillRoot = Join-Path $RepoRoot '.github/skills/northwind-modernization'
$entries = @($shared | ForEach-Object {
    [pscustomobject]@{ source = Join-Path $RepoRoot "fixtures/legacy-input/$($_.path)"; path = $_.path; sha256 = $_.sha256 }
})
if ($RunType -eq 'guided') {
    $entries += @($skillFiles | ForEach-Object {
        [pscustomobject]@{ source = Join-Path $skillRoot $_; path = ".github/skills/northwind-modernization/$_"; sha256 = Get-Sha256 (Join-Path $skillRoot $_) }
    })
}
foreach ($entry in $entries) {
    if ((Get-Item -LiteralPath $entry.source).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Linked input is not allowed: $($entry.path)"
    }
}
[void](New-Item -ItemType Directory -Path $destinationPath)
foreach ($entry in $entries) {
    $target = Join-Path $destinationPath $entry.path
    [void][IO.Directory]::CreateDirectory((Split-Path $target -Parent))
    Copy-Item -LiteralPath $entry.source -Destination $target
    if ((Get-Sha256 $target) -cne $entry.sha256) { throw "Copy hash mismatch: $($entry.path)" }
}
$manifest = [ordered]@{
    schemaVersion = 1
    runType = $RunType
    createdUtc = [DateTime]::UtcNow.ToString('o')
    generationStatus = 'not-run'
    isolation = 'source-allowlist-only; personal/global and host context require operator review'
    sharedFiles = @($shared)
    files = @($entries | ForEach-Object { [ordered]@{ path = $_.path; sha256 = $_.sha256 } })
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $destinationPath 'input-manifest.json') -Encoding utf8
Write-Host "Exported $RunType to $destinationPath ($($entries.Count) files). Agent generation: not-run."
