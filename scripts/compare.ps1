[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$BaselineRoot,
    [Parameter(Mandatory)][string]$GuidedRoot,
    [string]$BaselineCapture = (Join-Path $PSScriptRoot '../demos/captures/baseline.json'),
    [string]$GuidedCapture = (Join-Path $PSScriptRoot '../demos/captures/guided.json'),
    [Parameter(Mandatory)][string]$OutputDirectory
)
. "$PSScriptRoot/common.ps1"
$output = [IO.Path]::GetFullPath($OutputDirectory)
if ((Test-IsWithin $output $BaselineRoot) -or (Test-IsWithin $output $GuidedRoot)) {
    throw 'Keep comparison output outside both candidate roots.'
}
if ((Test-IsWithin $BaselineRoot $GuidedRoot) -or (Test-IsWithin $GuidedRoot $BaselineRoot)) {
    throw 'Candidate roots must be distinct and non-nested.'
}
if (Test-Path -LiteralPath $output) { throw 'Report directory exists; preserve it and choose another.' }
[void][IO.Directory]::CreateDirectory($output)
$results = [Collections.Generic.List[object]]::new()
$expected = @(Get-SharedManifest)

foreach ($run in @(
    @{ type = 'baseline'; root = $BaselineRoot; capture = $BaselineCapture; prompt = '01-baseline.txt' },
    @{ type = 'guided'; root = $GuidedRoot; capture = $GuidedCapture; prompt = '02-guided.txt' }
)) {
    $result = [pscustomobject][ordered]@{ run = $run.type; status = 'not-run'; detail = ''; checks = @(); changedFiles = @(); metadata = $null }
    try {
        if (-not (Test-Path -LiteralPath $run.capture)) {
            $result.detail = 'No capture supplied; no observed generation.'
        }
        else {
            $capture = Get-Content -LiteralPath $run.capture -Raw | ConvertFrom-Json
            if ($capture.status -eq 'not-run') { $result.detail = $capture.reason }
            elseif ($capture.status -eq 'blocked') { $result.status = 'blocked'; $result.detail = $capture.reason }
            elseif ($capture.status -ne 'completed') { throw 'Capture status must be completed, not-run or blocked.' }
            else {
                foreach ($field in @('runId','startedUtc','endedUtc','host','hostVersion','agentMode','model',
                    'configuration','isolation','prompt','inputManifestSha256','skillAvailability','skillUseEvidence','provenance')) {
                    if (-not $capture.$field) { throw "Capture metadata missing: $field. Use 'not exposed' when appropriate." }
                }
                if ($capture.runType -ne $run.type -or $capture.provenance -ne 'untouched-agent-output') {
                    throw 'Use matching, untouched agent captures for this comparison; preserve corrections separately.'
                }
                $prompt = (Get-Content -LiteralPath (Join-Path $RepoRoot "prompts/$($run.prompt)") -Raw).Trim()
                if ($capture.prompt.Trim() -cne $prompt) { throw 'Capture prompt differs from the prepared exact prompt.' }
                $manifestPath = Join-Path $run.root 'input-manifest.json'
                if ((Get-Sha256 $manifestPath) -cne $capture.inputManifestSha256) { throw 'Input manifest changed after capture.' }
                $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
                if ($manifest.runType -ne $run.type) { throw 'Wrong input run type.' }
                if (($manifest.sharedFiles | ConvertTo-Json -Compress) -cne ($expected | ConvertTo-Json -Compress)) {
                    throw 'Starting source/test manifest does not match the current immutable legacy fixture.'
                }
                $actual = @(Get-CandidateFiles ([IO.Path]::GetFullPath($run.root)))
                if (-not $capture.outputFiles.Count -or
                    ($actual | ConvertTo-Json -Compress) -cne ($capture.outputFiles | ConvertTo-Json -Compress)) {
                    throw 'Candidate changed since capture or output hashes are incomplete; seal a new labeled capture.'
                }
                $result.changedFiles = @($actual | Where-Object {
                    $entry = $_
                    -not @($manifest.files | Where-Object { $_.path -ceq $entry.path -and $_.sha256 -ceq $entry.sha256 }).Count
                } | ForEach-Object { $_.path })
                $result.changedFiles += @($manifest.files | Where-Object {
                    $entry = $_
                    -not @($actual | Where-Object { $_.path -ceq $entry.path }).Count
                } | ForEach-Object { "deleted: $($_.path)" })
                $evaluationOutput = Join-Path $output $run.type
                & pwsh -NoProfile -File (Join-Path $PSScriptRoot 'evaluate.ps1') -CandidateRoot $run.root -OutputDirectory $evaluationOutput
                $evaluation = Get-Content -LiteralPath (Join-Path $evaluationOutput 'evaluation.json') -Raw | ConvertFrom-Json
                $result.status = $evaluation.status
                $result.checks = @($evaluation.checks)
                $review = $capture.review
                if ($review.status -notin @('pass','fail') -or -not $review.reviewer -or -not $review.notes) {
                    $result.checks += [pscustomobject]@{ name = 'scope-and-source-review'; status = 'blocked'; detail = 'Human architecture/privacy/diff review not recorded.' }
                    if ($result.status -ne 'fail') { $result.status = 'blocked' }
                }
                else {
                    $result.checks += [pscustomobject]@{ name = 'scope-and-source-review'; status = $review.status; detail = $review.notes }
                    if ($review.status -eq 'fail') { $result.status = 'fail' }
                }
                $result.metadata = @{ host = $capture.host; version = $capture.hostVersion; agentMode = $capture.agentMode
                    model = $capture.model; configuration = $capture.configuration; isolation = $capture.isolation
                    interventionCount = @($capture.humanIntervention).Count }
                $result.detail = 'Observed output hashes matched capture; same external evaluator applied. See logs and review.'
            }
        }
    }
    catch {
        $result.status = 'blocked'
        $result.detail = "Capture or evaluator infrastructure blocked: $($_.Exception.Message)"
    }
    $results.Add($result)
}
$comparable = $results.Count -eq 2 -and $null -ne $results[0].metadata -and $null -ne $results[1].metadata
if ($comparable) {
    $a = $results[0].metadata; $b = $results[1].metadata
    $comparable = $a.host -ceq $b.host -and $a.version -ceq $b.version -and
        $a.agentMode -ceq $b.agentMode -and $a.model -ceq $b.model -and
        $a.configuration -ceq $b.configuration -and $a.isolation -eq 'verified-neutral' -and
        $b.isolation -eq 'verified-neutral' -and $a.interventionCount -eq 0 -and $b.interventionCount -eq 0
}
$comparison = [ordered]@{
    schemaVersion = 1; createdUtc = [DateTime]::UtcNow.ToString('o')
    framing = $(if ($comparable) { 'matched-context comparison; not a scientific proof of skill loading' } else { 'contextual walkthrough or not-run; controlled comparison not established' })
    runs = @($results.ToArray())
}
$comparison | ConvertTo-Json -Depth 14 | Set-Content -LiteralPath (Join-Path $output 'comparison.json') -Encoding utf8
$markdown = @('# Candidate comparison', '', $comparison.framing, '', '| Run | Status | Detail |', '| --- | --- | --- |')
foreach ($result in $results) {
    $detail = $result.detail.Replace('|','/').Replace("`n",' ')
    $markdown += "| $($result.run) | $($result.status) | $detail |"
    foreach ($check in $result.checks) { $markdown += "| $($result.run): $($check.name) | $($check.status) | $($check.detail.Replace('|','/')) |" }
}
$markdown -join "`n" | Set-Content -LiteralPath (Join-Path $output 'comparison.md') -Encoding utf8
$results | Select-Object run,status,detail | Format-Table -Wrap | Out-Host
if (@($results | Where-Object status -eq 'fail').Count) { exit 1 }
if (@($results | Where-Object status -ne 'pass').Count) { exit 2 }
