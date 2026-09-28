[CmdletBinding()]
param([Parameter(Mandatory)][string]$Destination)
. "$PSScriptRoot/common.ps1"
$destinationPath = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationPath) { throw 'Destination exists; choose a fresh v03 folder. Nothing was overwritten.' }
if (Test-IsWithin $destinationPath $RepoRoot) { throw 'Teaching workspaces must be outside the source repository.' }
$parent = Split-Path $destinationPath -Parent
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw 'Choose an explicit existing neutral parent first.' }
# The baseline exporter performs the same ancestor-context and link checks for all sibling checkpoints.
$probe = $parent
while ($probe) {
    if ((Get-Item -LiteralPath $probe -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Linked output ancestors are not supported.'
    }
    foreach ($name in @('AGENTS.md','CLAUDE.md','GEMINI.md','.github/copilot-instructions.md',
        '.github/skills','.agents/skills','.claude/skills','.github/instructions','.github/agents')) {
        if (Test-Path -LiteralPath (Join-Path $probe $name)) { throw "Ancestor context found: $probe ($name)" }
    }
    $next = Split-Path $probe -Parent
    if ($next -eq $probe) { break }
    $probe = $next
}

function Copy-TeachingFile([string]$Source, [string]$Target) {
    if ((Get-Item -LiteralPath $Source -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Linked teaching source is not supported: $Source"
    }
    [void][IO.Directory]::CreateDirectory((Split-Path $Target -Parent))
    Copy-Item -LiteralPath $Source -Destination $Target
    if ((Get-Sha256 $Source) -cne (Get-Sha256 $Target)) { throw "Copy mismatch: $Target" }
}

$referenceFiles = @('global.json','Directory.Build.props','NuGet.Config','Northwind.slnx')
foreach ($tree in @('src','tests','.github/skills/northwind-modernization')) {
    $referenceFiles += @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot $tree) -Recurse -File -Force |
        Where-Object {
            $relative = [IO.Path]::GetRelativePath($RepoRoot, $_.FullName).Replace('\','/')
            $relative -notmatch '(^|/)(bin|obj|TestResults|\.git)(/|$)' -and
                $_.Extension -in @('.cs','.csproj','.json','.md')
        } | ForEach-Object { [IO.Path]::GetRelativePath($RepoRoot, $_.FullName) })
}
$names = @('01-baseline','02-author-skill','03-guided','04-reference',
    '05-null-regression','06-reuse-start','07-reuse-complete')
[void][IO.Directory]::CreateDirectory($destinationPath)
foreach ($name in $names) {
    $target = Join-Path $destinationPath $name
    if ($name -in @('01-baseline','02-author-skill','03-guided')) {
        $kind = if ($name -eq '03-guided') { 'guided' } else { 'baseline' }
        & "$PSScriptRoot/export-demo.ps1" -RunType $kind -Destination $target
    }
    else {
        [void][IO.Directory]::CreateDirectory($target)
        foreach ($file in $referenceFiles) {
            Copy-TeachingFile (Join-Path $RepoRoot $file) (Join-Path $target $file)
        }
    }
    if ($name -eq '02-author-skill') {
        Copy-TeachingFile (Join-Path $RepoRoot 'knowledge/team-notes.md') (Join-Path $target 'knowledge/team-notes.md')
    }
    if ($name -eq '05-null-regression') {
        $file = Join-Path $target 'src/Northwind.Quotes/QuoteJson.cs'
        $text = [IO.File]::ReadAllText($file)
        $needle = 'DefaultIgnoreCondition = JsonIgnoreCondition.Never'
        if (($text.Split($needle).Count - 1) -ne 1) { throw 'Expected exactly one null-setting anchor.' }
        [IO.File]::WriteAllText($file, $text.Replace($needle, 'DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull'))
    }
    if ($name -eq '07-reuse-complete') {
        $file = Join-Path $target 'src/Northwind.Quotes/QuoteJson.cs'
        $text = [IO.File]::ReadAllText($file)
        $anchor = '    public static string Write(QuoteResponse response) => JsonSerializer.Serialize(response, OutputOptions);'
        if (($text.Split($anchor).Count - 1) -ne 1) { throw 'Expected exactly one single-response serializer anchor.' }
        $method = [IO.File]::ReadAllText((Join-Path $RepoRoot 'demos/v03/checkpoints/WriteBatch.method.txt')).TrimEnd()
        [IO.File]::WriteAllText($file, $text.Replace($anchor, $anchor + "`n`n" + $method))
        Copy-TeachingFile (Join-Path $RepoRoot 'demos/v03/checkpoints/BatchSerializationTests.cs') `
            (Join-Path $target 'tests/Northwind.UnitTests/BatchSerializationTests.cs')
    }
    [ordered]@{
        schemaVersion = 1; checkpoint = $name; provenance = 'prepared-teaching-fixture'
        agentRun = 'not-run'; deliberatelyBroken = ($name -eq '05-null-regression')
        warning = 'Open this folder alone in a fresh conversation, never the parent. Not a controlled agent experiment.'
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $target 'teaching-checkpoint.json') -Encoding utf8
}
$a = Get-Content (Join-Path $destinationPath '01-baseline/input-manifest.json') -Raw | ConvertFrom-Json
$b = Get-Content (Join-Path $destinationPath '03-guided/input-manifest.json') -Raw | ConvertFrom-Json
if (($a.sharedFiles | ConvertTo-Json -Compress) -cne ($b.sharedFiles | ConvertTo-Json -Compress)) {
    throw 'Baseline/guided source hashes differ.'
}
[ordered]@{
    schemaVersion = 1; status = 'prepared; rehearsal not-run'; agentRuns = 'not-run'
    sharedFiles = $a.sharedFiles.Count; guidedAdditionalFiles = $b.files.Count - $a.files.Count
    checkpoints = @($names | ForEach-Object {
        [ordered]@{ name = $_; files = @(Get-CandidateFiles (Join-Path $destinationPath $_)) }
    })
} | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $destinationPath 'teaching-manifest.json') -Encoding utf8
Write-Host "Prepared seven independent teaching checkpoints at $destinationPath. No agent runs."
