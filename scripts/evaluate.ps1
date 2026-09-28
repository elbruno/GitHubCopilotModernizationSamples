[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$CandidateRoot,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [ValidateSet('reference','candidate','legacy')][string]$Kind = 'candidate'
)
. "$PSScriptRoot/common.ps1"
$root = (Resolve-Path -LiteralPath $CandidateRoot).Path
$output = [IO.Path]::GetFullPath($OutputDirectory)
if ((Test-IsWithin $output $root) -and $Kind -ne 'reference') { throw 'Keep evaluator output outside the candidate.' }
if (Test-Path -LiteralPath $output) { throw 'Evaluation output exists; use a new directory to preserve evidence.' }
[void][IO.Directory]::CreateDirectory($output)
$checks = [Collections.Generic.List[object]]::new()
$commands = [Collections.Generic.List[object]]::new()
$originalDll = $env:QUOTE_APP_DLL

function Run-Recorded([string]$Name, [string[]]$Arguments, [string]$WorkingDirectory) {
    $start = [Diagnostics.ProcessStartInfo]::new('dotnet')
    $start.WorkingDirectory = $WorkingDirectory
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $start.ArgumentList.Add($argument) }
    $watch = [Diagnostics.Stopwatch]::StartNew()
    $process = [Diagnostics.Process]::Start($start)
    try {
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $finished = $process.WaitForExit(180000)
        if (-not $finished) { $process.Kill($true); $process.WaitForExit() }
        $text = $stdout.GetAwaiter().GetResult() + "`n" + $stderr.GetAwaiter().GetResult()
        [IO.File]::WriteAllText((Join-Path $output "$Name.log"), $text)
        $code = if ($finished) { $process.ExitCode } else { -1 }
        $commands.Add([ordered]@{ name = $Name; executable = 'dotnet'; arguments = $Arguments
            exitCode = $code; elapsedMilliseconds = $watch.ElapsedMilliseconds; log = "$Name.log" })
        [pscustomobject]@{ Code = $code; Text = $text }
    }
    finally { $process.Dispose() }
}

function Add-Check([string]$Name, [string]$Status, [string]$Detail) {
    $checks.Add([pscustomobject][ordered]@{ name = $Name; status = $Status; detail = $Detail })
}

function Test-Trx([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    [xml]$xml = Get-Content -LiteralPath $Path -Raw
    $counter = $xml.SelectSingleNode("//*[local-name()='Counters']")
    if ($null -eq $counter) { return $null }
    [pscustomobject]@{ Total = [int]$counter.total; Passed = [int]$counter.passed; Failed = [int]$counter.failed }
}

try {
    $solution = Join-Path $root 'Northwind.slnx'
    $appProject = Join-Path $root 'src/Northwind.Quotes/Northwind.Quotes.csproj'
    if (-not (Test-Path -LiteralPath $solution) -or -not (Test-Path -LiteralPath $appProject)) {
        Add-Check 'harness' 'blocked' 'Expected solution/app project layout is missing; inspect candidate manually.'
    }
    else {
        $restore = Run-Recorded 'restore' @('restore', $solution, '--locked-mode') $root
        if ($restore.Code -ne 0) {
            $status = if ($restore.Text -match 'NU1004') { 'fail' } else { 'blocked' }
            Add-Check 'restore' $status 'See restore.log; network/SDK/feed failures are infrastructure blockers, stale locks fail.'
        }
        else {
            Add-Check 'restore' 'pass' 'Locked restore succeeded.'
            $build = Run-Recorded 'build' @('build', $solution, '--no-restore') $root
            if ($build.Code -ne 0) {
                Add-Check 'build' $(if ($build.Code -eq -1) { 'blocked' } else { 'fail' }) 'See build.log.'
            }
            else {
                Add-Check 'build' 'pass' 'Candidate solution built.'
                $visible = Run-Recorded 'visible-tests' @('test', $solution, '--no-build', '--no-restore',
                    '--logger', 'trx', '--results-directory', (Join-Path $output 'visible-tests')) $root
                $visibleTrx = @(Get-ChildItem -LiteralPath (Join-Path $output 'visible-tests') -Filter '*.trx' -ErrorAction SilentlyContinue)
                $visibleCounts = @($visibleTrx | ForEach-Object { Test-Trx $_.FullName })
                $visibleTotal = ($visibleCounts | Measure-Object -Property Total -Sum).Sum
                $visibleFailed = ($visibleCounts | Measure-Object -Property Failed -Sum).Sum
                $visibleStatus = if ($visibleFailed -gt 0) { 'fail' } elseif ($visible.Code -eq 0 -and $visibleTotal -gt 0) { 'pass' } else { 'blocked' }
                Add-Check 'visible-tests' $visibleStatus "Executed $visibleTotal visible tests; failed $visibleFailed. See visible-tests.log."
                $dll = Join-Path $root 'src/Northwind.Quotes/bin/Debug/net10.0/Northwind.Quotes.dll'
                $deps = Join-Path $root 'src/Northwind.Quotes/bin/Debug/net10.0/Northwind.Quotes.deps.json'
                if (-not (Test-Path -LiteralPath $dll) -or -not (Test-Path -LiteralPath $deps)) {
                    Add-Check 'harness' 'blocked' 'Expected Debug/net10.0 output unavailable; do not infer behavior.'
                }
                else {
                    $graph = Get-Content -LiteralPath $deps -Raw | ConvertFrom-Json -AsHashtable
                    $oldDependency = @($graph.libraries.Keys | Where-Object { $_ -match '^Newtonsoft\.Json/' })
                    $oldReference = @(Get-ChildItem -LiteralPath (Join-Path $root 'src') -Filter '*.csproj' -Recurse |
                        Select-String -Pattern 'Newtonsoft\.Json')
                    if ($Kind -eq 'legacy') {
                        Add-Check 'migration' 'not-run' 'Legacy input intentionally retains Newtonsoft.Json; not an agent migration.'
                    }
                    else {
                        Add-Check 'migration' $(if ($oldDependency.Count -or $oldReference.Count) { 'fail' } else { 'pass' }) 'Checked built dependency graph and source project references.'
                    }
                    $env:QUOTE_APP_DLL = $dll
                    $testProject = Join-Path $RepoRoot 'tests/Northwind.AcceptanceTests/Northwind.AcceptanceTests.csproj'
                    $harness = Run-Recorded 'evaluator-build' @('build', $testProject, '--no-restore') $RepoRoot
                    if ($harness.Code -ne 0) {
                        Add-Check 'acceptance' 'blocked' 'External evaluator could not build; restore authoring solution first.'
                    }
                    else {
                        $testDll = Join-Path $RepoRoot 'tests/Northwind.AcceptanceTests/bin/Debug/net10.0/Northwind.AcceptanceTests.dll'
                        $acceptance = Run-Recorded 'acceptance' @('vstest', $testDll, '/Logger:trx;LogFileName=acceptance.trx',
                            "/ResultsDirectory:$output") $RepoRoot
                        $counts = Test-Trx (Join-Path $output 'acceptance.trx')
                        if ($null -eq $counts -or $counts.Total -eq 0) {
                            Add-Check 'acceptance' 'blocked' 'No test results; inspect evaluator infrastructure.'
                        }
                        else {
                            $status = if ($counts.Failed -gt 0) { 'fail' } elseif ($acceptance.Code -eq 0 -and $counts.Passed -eq $counts.Total) { 'pass' } else { 'blocked' }
                            Add-Check 'acceptance' $status "R1-R4 process checks: $($counts.Passed)/$($counts.Total) passed; see acceptance.trx."
                        }
                    }
                    $domainFiles = @(Get-ChildItem -LiteralPath (Join-Path $root 'src/Northwind.Domain') -Filter '*.cs' |
                        ForEach-Object { Get-Content -LiteralPath $_.FullName -Raw })
                    $domain = $domainFiles -join "`n"
                    $structuralPass = $domain -match 'IAuditTrail' -and $domain -match '\.QuoteCalculated\s*\(' -and
                        $domain -notmatch 'Console\s*\.\s*(Write|Error|Out)'
                    Add-Check 'audit-structure' $(if ($structuralPass) { 'pass' } else { 'fail' }) 'Source heuristic: interface + call present; no domain Console logging. Human review still required.'
                }
            }
        }
    }
}
catch {
    Add-Check 'infrastructure' 'blocked' "Evaluator could not finish: $($_.Exception.Message)"
}
finally {
    $env:QUOTE_APP_DLL = $originalDll
}
$status = if (@($checks | Where-Object status -eq 'fail').Count) { 'fail' }
    elseif (@($checks | Where-Object status -eq 'blocked').Count) { 'blocked' } else { 'pass' }
$criteria = @('scripts/evaluate.ps1','tests/Northwind.AcceptanceTests/ContractTests.cs',
    'tests/Northwind.AcceptanceTests/Northwind.AcceptanceTests.csproj') | ForEach-Object {
    [ordered]@{ path = $_; sha256 = Get-Sha256 (Join-Path $RepoRoot $_) }
}
$report = [ordered]@{
    schemaVersion = 1; kind = $Kind; status = $status; evaluatedUtc = [DateTime]::UtcNow.ToString('o')
    criteria = @($criteria); checks = @($checks.ToArray()); commands = @($commands.ToArray())
    sourceReview = 'not-run; structural heuristics are not full architecture/privacy review'
    agentGeneration = 'not asserted by evaluator'
}
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $output 'evaluation.json') -Encoding utf8
$checks | Format-Table name,status,detail -Wrap | Out-Host
if ($status -eq 'fail') { exit 1 }
if ($status -eq 'blocked') { exit 2 }
