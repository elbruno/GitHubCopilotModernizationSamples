[CmdletBinding()]
param([switch]$IncludeSlides)
. "$PSScriptRoot/common.ps1"
$skillRoot = Join-Path $RepoRoot '.github/skills/northwind-modernization'
$skill = Get-Content -LiteralPath (Join-Path $skillRoot 'SKILL.md') -Raw
if ($skill -notmatch '\A---\r?\nname: northwind-modernization\r?\ndescription: [^\r\n]+\r?\n---') {
    throw 'Skill must use the documented minimal frontmatter.'
}
if ($skill -match 'allowed-tools:') { throw 'Broad tool preapproval is not part of this demo.' }
# Every skill must be discoverable: minimal frontmatter whose name matches its folder.
foreach ($dir in Get-ChildItem -LiteralPath (Join-Path $RepoRoot '.github/skills') -Directory) {
    $manifest = Join-Path $dir.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $manifest)) { throw "Skill folder without SKILL.md: $($dir.Name)" }
    $head = Get-Content -LiteralPath $manifest -Raw
    if ($head -notmatch "\A---\r?\n(?:[^\r\n]*\r?\n)*?name: $([regex]::Escape($dir.Name))\r?\n" -or
        $head -notmatch '\A---\r?\n(?:[^\r\n]*\r?\n)*?description: [^\r\n]{20,}\r?\n(?:[^\r\n]*\r?\n)*?---') {
        throw "Skill frontmatter must include name: $($dir.Name) and a description: .github/skills/$($dir.Name)/SKILL.md"
    }
}
$brandRoot = Join-Path $RepoRoot '.github/skills/dotnet-brand-visuals'
foreach ($file in @(Get-ChildItem -LiteralPath $brandRoot -Recurse -Filter '*.md' -ErrorAction SilentlyContinue)) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($text -match '[A-Z]:\\(events|elbruno|Users)') { throw "Private path in public skill: $($file.Name)" }
    foreach ($match in [regex]::Matches($text, '\]\((?!https?://)([^)#]+)\)')) {
        $target = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $match.Groups[1].Value))
        if (-not (Test-IsWithin $target $brandRoot) -or -not (Test-Path -LiteralPath $target)) {
            throw "Brand skill reference is missing or escapes its package: $target"
        }
    }
}
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
function Get-CheckpointLines([string]$Checkpoint, [string]$Relative) {
    # Mirrors scripts/prepare-v03.ps1 so cited lines match the prepared demo folders.
    if ($Checkpoint -eq '07-reuse-complete' -and $Relative -eq 'tests/Northwind.UnitTests/BatchSerializationTests.cs') {
        return Get-Content -LiteralPath (Join-Path $RepoRoot 'demos/v03/checkpoints/BatchSerializationTests.cs')
    }
    $base = if ($Checkpoint -in @('01-baseline','02-author-skill','03-guided') -and $Relative -match '^(src|tests)/') {
        'fixtures/legacy-input'
    } else { '.' }
    $source = Join-Path (Join-Path $RepoRoot $base) $Relative
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { return $null }
    $text = [IO.File]::ReadAllText($source)
    if ($Checkpoint -eq '07-reuse-complete' -and $Relative -eq 'src/Northwind.Quotes/QuoteJson.cs') {
        $anchor = '    public static string Write(QuoteResponse response) => JsonSerializer.Serialize(response, OutputOptions);'
        $method = [IO.File]::ReadAllText((Join-Path $RepoRoot 'demos/v03/checkpoints/WriteBatch.method.txt')).TrimEnd()
        $text = $text.Replace($anchor, $anchor + "`n`n" + $method)
    }
    return ($text -replace "`r`n", "`n") -split "`n"
}
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
        # `code -r -g` runs from the demo folder, often in a terminal without the helper variables.
        foreach ($goto in [regex]::Matches($text, '(?m)^[ \t>]*code -r -g (.+?)\s*$')) {
            $argument = $goto.Groups[1].Value.Trim()
            if ($argument -notmatch '^"\.\.\\(0[1-7]-[a-z-]+)\\([^":$]+):(\d+)"$') {
                throw "$page has a code -g argument that depends on variables or is not ..\checkpoint\file:line: $argument"
            }
            $checkpoint = $Matches[1]; $relative = $Matches[2] -replace '\\', '/'; $line = [int]$Matches[3]
            $lines = Get-CheckpointLines $checkpoint $relative
            if ($null -eq $lines) { throw "$page opens $checkpoint/$relative, which that checkpoint does not contain" }
            if ($line -lt 1 -or $line -gt $lines.Count -or [string]::IsNullOrWhiteSpace($lines[$line - 1])) {
                throw "$page opens $checkpoint/$relative`:$line, which is blank or past the end of the file"
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
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/v08/generate.mjs'), '--check')
    Invoke-Checked node @((Join-Path $RepoRoot 'slides/sync-latest-deck.mjs'), '--check')
}
Write-Host 'Skill frontmatter, self-contained links, allowlist, shared prompts, inline demo prompts and code line references: pass.'
