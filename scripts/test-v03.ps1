[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][string]$OutputDirectory
)
. "$PSScriptRoot/common.ps1"
$workspacePath = (Resolve-Path -LiteralPath $Workspace).Path
$output = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $output) { throw 'Choose a new evidence directory; prior rehearsal evidence is immutable.' }
if (Test-IsWithin $output $workspacePath) { throw 'Keep rehearsal logs outside the teaching workspace.' }
$manifest = Get-Content -LiteralPath (Join-Path $workspacePath 'teaching-manifest.json') -Raw | ConvertFrom-Json
if ($manifest.checkpoints.Count -ne 7 -or $manifest.agentRuns -cne 'not-run') { throw 'Unexpected teaching manifest.' }
foreach ($checkpoint in $manifest.checkpoints) {
    if ($checkpoint.name -notmatch '^0[1-7]-[a-z-]+$') { throw 'Invalid checkpoint name.' }
    $root = Join-Path $workspacePath $checkpoint.name
    foreach ($entry in $checkpoint.files) {
        $file = Join-Path $root $entry.path
        if (-not (Test-IsWithin $file $root) -or (Get-Sha256 $file) -cne $entry.sha256) {
            throw "Teaching input changed: $($checkpoint.name)/$($entry.path). Prepare fresh inputs for scripted rehearsal."
        }
    }
    if (@(Get-CandidateFiles $root).Count -ne $checkpoint.files.Count) { throw "Unexpected teaching files: $($checkpoint.name)" }
}
[void][IO.Directory]::CreateDirectory($output)
$steps = [Collections.Generic.List[object]]::new()
$oldDll = $env:QUOTE_APP_DLL
$env:QUOTE_APP_DLL = $null
function Run-Step([string]$Name, [string]$Root, [string[]]$Arguments, [int]$ExpectedExit = 0) {
    $log = Join-Path $output "$Name.log"
    $watch = [Diagnostics.Stopwatch]::StartNew()
    Push-Location $Root
    try {
        & dotnet @Arguments *> $log
        $code = $LASTEXITCODE
    }
    finally { Pop-Location }
    $watch.Stop()
    $steps.Add([pscustomobject]@{
        name = $Name; command = 'dotnet ' + ($Arguments -join ' ')
        exitCode = $code; expectedExit = $ExpectedExit; seconds = [math]::Round($watch.Elapsed.TotalSeconds, 2)
    })
    if ($code -ne $ExpectedExit) {
        Get-Content -LiteralPath $log -Tail 25 | Write-Host
        throw "$Name expected exit $ExpectedExit, got $code. See $log"
    }
    Write-Host "$Name : exit $code (expected $ExpectedExit)"
}
$regression = Join-Path $workspacePath '05-null-regression'
$repairApplied = $false
$status = 'blocked'
try {
    foreach ($checkpoint in $manifest.checkpoints) {
        $name = $checkpoint.name
        $root = Join-Path $workspacePath $name
        Run-Step "$name-restore" $root @('restore','Northwind.slnx','--locked-mode')
        Run-Step "$name-build" $root @('build','Northwind.slnx','--no-restore','--verbosity','quiet')
        if ($name -eq '05-null-regression') { continue }
        Run-Step "$name-tests" $root @('test','Northwind.slnx','--no-build','--no-restore',
            '--logger','trx','--results-directory',(Join-Path $output "$name-tests"))
    }
    $test = 'FullyQualifiedName~SerializationTests.PreservesExplicitNull'
    $before = Join-Path $output 'null-before'
    Run-Step 'null-before' $regression @('test','tests/Northwind.UnitTests','--no-build','--no-restore',
        '--filter',$test,'--logger','trx;LogFileName=null.trx','--results-directory',$before) 1
    [xml]$trx = Get-Content -LiteralPath (Join-Path $before 'null.trx') -Raw
    $counts = $trx.TestRun.ResultSummary.Counters
    if ([int]$counts.total -ne 1 -or [int]$counts.failed -ne 1 -or [int]$counts.executed -ne 1 -or
        $trx.TestRun.Results.UnitTestResult.testName -notlike '*PreservesExplicitNull' -or
        $trx.TestRun.Results.UnitTestResult.Output.ErrorInfo.Message -notlike '*R2: review_note must exist*') {
        throw 'Expected the exact null-contract assertion failure, not a build, discovery or infrastructure failure.'
    }
    & "$PSScriptRoot/set-demo-null-rule.ps1" -Workspace $regression -State Fixed -Confirm:$false
    $repairApplied = $true
    Run-Step 'null-fixed-build' $regression @('build','Northwind.slnx','--no-restore','--verbosity','quiet')
    Run-Step 'null-after' $regression @('test','tests/Northwind.UnitTests','--no-build','--no-restore',
        '--filter',$test,'--logger','trx;LogFileName=null.trx','--results-directory',(Join-Path $output 'null-after'))
    Run-Step 'null-fixed-full-tests' $regression @('test','Northwind.slnx','--no-build','--no-restore',
        '--logger','trx','--results-directory',(Join-Path $output 'null-fixed-full-tests'))
    $unchangedPaths = @('src/Northwind.Quotes/Program.cs','src/Northwind.Domain/Quotation.cs','src/Northwind.Audit/AuditTrail.cs')
    foreach ($relative in $unchangedPaths) {
        if ((Get-Sha256 (Join-Path $workspacePath "06-reuse-start/$relative")) -cne
            (Get-Sha256 (Join-Path $workspacePath "07-reuse-complete/$relative"))) {
            throw "Reuse unexpectedly changed CLI, pricing or audit: $relative"
        }
    }
    $rejected = $false
    try { & "$PSScriptRoot/prepare-v03.ps1" -Destination $workspacePath }
    catch { if ($_.Exception.Message -like 'Destination exists*') { $rejected = $true } else { throw } }
    if (-not $rejected) { throw 'Existing teaching destination was not rejected.' }
    $status = 'pass'
}
finally {
    try {
        if ($repairApplied) {
            & "$PSScriptRoot/set-demo-null-rule.ps1" -Workspace $regression -State Broken -Confirm:$false
            Run-Step 'null-restored-build' $regression @('build','Northwind.slnx','--no-restore','--verbosity','quiet')
        }
    }
    catch { $status = 'blocked'; throw }
    finally {
        $env:QUOTE_APP_DLL = $oldDll
        [ordered]@{
            schemaVersion = 1; status = $status; kind = 'scripted-teaching-rehearsal'
            agentRuns = 'not-run'; humanTimedRehearsal = 'not-run'
            recordedUtc = [DateTime]::UtcNow.ToString('o'); steps = @($steps)
            nullRegression = 'deliberately introduced; exact failing assertion checked before repair'
            nullCheckpointAtEnd = if ($repairApplied -and $status -eq 'pass') { 'restored to deliberately broken source and rebuilt' } else { 'inspect checkpoint state before using' }
        } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $output 'rehearsal.json') -Encoding utf8
    }
}
Write-Host 'Seven teaching checkpoints verified; real red/green checks, reuse tests and unchanged CLI/pricing/audit. Agent runs: not-run.'
