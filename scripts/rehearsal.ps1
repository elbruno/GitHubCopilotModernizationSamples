[CmdletBinding()]
param()
. "$PSScriptRoot/common.ps1"
$watch = [Diagnostics.Stopwatch]::StartNew()
$required = @('demos/runbook.md','demos/troubleshooting.md','slides/speaker-notes.md',
    'slides/dist/tribal-knowledge-to-code.pptx','prompts/01-baseline.txt','prompts/02-guided.txt',
    'demos/captures/baseline.json','demos/captures/guided.json')
foreach ($file in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $file))) { throw "Missing fallback/presenter file: $file" }
}
$dll = Join-Path $RepoRoot 'src/Northwind.Quotes/bin/Debug/net10.0/Northwind.Quotes.dll'
if (-not (Test-Path -LiteralPath $dll)) { throw 'Build the reference first using verify.ps1.' }
$output = Join-Path $RepoRoot ('artifacts/rehearsal-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff'))
[void][IO.Directory]::CreateDirectory($output)
foreach ($case in @(@{ file = 'partner'; expected = 0 }, @{ file = 'invalid'; expected = 2 })) {
    $stdout = Join-Path $output "$($case.file).stdout.json"
    $stderr = Join-Path $output "$($case.file).stderr.txt"
    & dotnet $dll (Join-Path $RepoRoot "fixtures/requests/$($case.file).json") 1> $stdout 2> $stderr
    if ($LASTEXITCODE -ne $case.expected) { throw "Unexpected exit for $($case.file): $LASTEXITCODE" }
    $diagnostics = Get-Content -LiteralPath $stderr -Raw
    if ($diagnostics -match 'customer_id|customer_email|SYNTH-PRIVATE|leak-sentinel') { throw 'Diagnostic sentinel leak.' }
    if ($case.expected -eq 0) {
        $quote = Get-Content -LiteralPath $stdout -Raw | ConvertFrom-Json
        if ($quote.total -ne 270 -or $null -ne $quote.review_note) { throw 'Unexpected reference result.' }
    }
    elseif ((Get-Item -LiteralPath $stdout).Length -gt 0) { throw 'Invalid input corrupted stdout.' }
}
$receipt = [ordered]@{ status = 'pass'; type = 'scripted local preflight, NOT human delivery'
    elapsedMilliseconds = $watch.ElapsedMilliseconds; agentRuns = 'not-run'; humanRehearsal = 'not-run' }
$receipt | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'receipt.json') -Encoding utf8
Write-Host "Local smoke preflight passed in $($watch.Elapsed.TotalSeconds.ToString('F1')) seconds. Evidence: $output"
Write-Host 'Sequence: slides 1-4 > isolated baseline > synthetic team note/skill > isolated guided > external comparison > closing/Q&A.'
Write-Host 'Fallback: legacy/reference source + real local tests. Say explicitly that no independent run was captured.'
