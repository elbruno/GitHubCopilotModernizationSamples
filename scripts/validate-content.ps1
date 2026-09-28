[CmdletBinding()]
param([switch]$IncludeSlides)
. "$PSScriptRoot/common.ps1"
$skillRoot = Join-Path $RepoRoot '.github/skills/northwind-modernization'
$skill = Get-Content -LiteralPath (Join-Path $skillRoot 'SKILL.md') -Raw
if ($skill -notmatch '\A---\r?\nname: northwind-modernization\r?\ndescription: [^\r\n]+\r?\n---') {
    throw 'Skill must use the documented minimal frontmatter.'
}
if ($skill -match 'allowed-tools:') { throw 'Broad tool preapproval is not part of this demo.' }
foreach ($file in Get-ChildItem -LiteralPath $skillRoot -Recurse -Filter '*.md') {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')) {
        $target = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $match.Groups[1].Value))
        if (-not (Test-IsWithin $target $skillRoot) -or -not (Test-Path -LiteralPath $target)) {
            throw "Skill reference is missing or escapes its package: $target"
        }
    }
}
foreach ($file in Get-DemoAllowlist) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot "fixtures/legacy-input/$file"))) {
        throw "Missing allowlisted fixture: $file"
    }
}
$baseline = (Get-Content -LiteralPath (Join-Path $RepoRoot 'prompts/01-baseline.txt') -Raw).Trim()
$guided = (Get-Content -LiteralPath (Join-Path $RepoRoot 'prompts/02-guided.txt') -Raw).Trim()
if (-not $guided.StartsWith($baseline, [StringComparison]::Ordinal)) { throw 'Shared prompts diverged.' }
if ($IncludeSlides) {
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v03/generate.mjs'), '--check')
}
Write-Host 'Skill frontmatter, self-contained links, allowlist and shared prompts: pass.'
