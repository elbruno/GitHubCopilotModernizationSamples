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

# Demo pages print short prompts inline and cite code as `file:line`; keep both in sync with the sources.
$demoSources = @{
    1 = @{ Prompt = 'prompts/01-baseline.txt';               Src = 'fixtures/legacy-input' }
    2 = @{ Prompt = 'demos/v03/prompts/02-author-skill.txt'; Src = 'fixtures/legacy-input' }
    3 = @{ Prompt = 'prompts/02-guided.txt';                 Src = 'fixtures/legacy-input' }
    4 = @{ Prompt = 'demos/v03/prompts/04-repair.txt';       Src = '.' }
    5 = @{ Prompt = 'demos/v03/prompts/05-reuse.txt';        Src = '.' }
}
$pageCount = 0
foreach ($n in 1..5) {
    foreach ($page in @("demos/demo0$n.md", "demos/learn/demo0$n.md")) {
        $pagePath = Join-Path $RepoRoot $page
        if (-not (Test-Path -LiteralPath $pagePath)) { continue }
        $pageCount++
        $text = (Get-Content -LiteralPath $pagePath -Raw) -replace "`r`n", "`n"
        $promptText = ((Get-Content -LiteralPath (Join-Path $RepoRoot $demoSources[$n].Prompt) -Raw) -replace "`r`n", "`n").Trim()
        foreach ($block in [regex]::Matches($text, '(?ms)^([ \t]*)```text\n(.*?)^[ \t]*```')) {
            $indent = $block.Groups[1].Value
            $body = (($block.Groups[2].Value -split "`n" | ForEach-Object {
                if ($indent -and $_.StartsWith($indent)) { $_.Substring($indent.Length) } else { $_ }
            }) -join "`n").Trim()
            if ($body -cne $promptText) { throw "Inline prompt in $page differs from $($demoSources[$n].Prompt)" }
        }
        foreach ($ref in [regex]::Matches($text, '`([\w.\\/-]+\.(?:cs|csproj|md)):(\d+)`')) {
            $relative = $ref.Groups[1].Value -replace '\\', '/'
            $root = if ($relative -match '^(src|tests)/') { $demoSources[$n].Src } else { '.' }
            $source = Join-Path (Join-Path $RepoRoot $root) $relative
            if (-not (Test-Path -LiteralPath $source)) { throw "$page cites missing file $relative" }
            $lines = Get-Content -LiteralPath $source
            $line = [int]$ref.Groups[2].Value
            if ($line -lt 1 -or $line -gt $lines.Count -or [string]::IsNullOrWhiteSpace($lines[$line - 1])) {
                throw "$page cites $relative`:$line, which is blank or past the end of the file"
            }
        }
    }
}
if ($pageCount -eq 0) { throw 'No demo pages found to validate.' }
if ($IncludeSlides) {
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v03/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v04/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v05/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v06/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v07/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/sync-latest-deck.mjs'), '--check')
}
Write-Host 'Skill frontmatter, self-contained links, allowlist, shared prompts, inline demo prompts and code line references: pass.'
