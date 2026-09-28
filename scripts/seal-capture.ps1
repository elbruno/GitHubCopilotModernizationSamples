[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$CandidateRoot,
    [Parameter(Mandatory)][string]$MetadataPath,
    [Parameter(Mandatory)][string]$OutputPath
)
. "$PSScriptRoot/common.ps1"
$root = (Resolve-Path -LiteralPath $CandidateRoot).Path
if (Test-IsWithin $OutputPath $root) { throw 'Keep capture metadata outside the candidate.' }
if (Test-Path -LiteralPath $OutputPath) { throw 'Capture exists; preserve the original and choose a new file.' }
$metadata = Get-Content -LiteralPath $MetadataPath -Raw | ConvertFrom-Json
if ($metadata.status -ne 'completed' -or $metadata.provenance -ne 'untouched-agent-output') {
    throw 'Only seal a real completed, untouched agent output. This command does not perform generation.'
}
foreach ($field in @('runId','startedUtc','endedUtc','host','hostVersion','agentMode','model','configuration',
    'isolation','prompt','skillAvailability','skillUseEvidence')) {
    if (-not $metadata.$field) { throw "Fill metadata field $field with actual observations, or 'not exposed'." }
}
if (-not $metadata.commands.Count) { throw 'Record actual commands/results, including failures.' }
$metadata.inputManifestSha256 = Get-Sha256 (Join-Path $root 'input-manifest.json')
$metadata.outputFiles = @(Get-CandidateFiles $root)
$metadata | ConvertTo-Json -Depth 14 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Host 'Capture hashes sealed. Human metadata remains operator-attested, not independently proven.'
