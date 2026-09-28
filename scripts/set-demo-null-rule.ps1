[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Workspace,
    [Parameter(Mandatory)][ValidateSet('Broken','Fixed')][string]$State
)
. "$PSScriptRoot/common.ps1"
$root = (Resolve-Path -LiteralPath $Workspace).Path
if (Test-IsWithin $root $RepoRoot) { throw 'Never inject a teaching regression into the source repository.' }
$marker = Get-Content -LiteralPath (Join-Path $root 'teaching-checkpoint.json') -Raw | ConvertFrom-Json
if ($marker.checkpoint -cne '05-null-regression' -or $marker.provenance -cne 'prepared-teaching-fixture') {
    throw 'Only the explicitly marked null-regression teaching checkpoint may be changed.'
}
$file = Join-Path $root 'src/Northwind.Quotes/QuoteJson.cs'
$cursor = $file
while (Test-IsWithin $cursor $root) {
    if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Linked teaching files or ancestors are not supported.'
    }
    if ($cursor -eq $root) { break }
    $cursor = Split-Path $cursor -Parent
}
$good = 'DefaultIgnoreCondition = JsonIgnoreCondition.Never'
$bad = 'DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull'
$text = [IO.File]::ReadAllText($file)
$goodCount = $text.Split($good).Count - 1
$badCount = $text.Split($bad).Count - 1
if ($goodCount + $badCount -ne 1) { throw 'Null-setting anchor changed; inspect manually instead of guessing.' }
$desired = if ($State -eq 'Fixed') { $good } else { $bad }
$old = if ($State -eq 'Fixed') { $bad } else { $good }
if ($PSCmdlet.ShouldProcess($file, "Set prepared teaching null rule to $State")) {
    [IO.File]::WriteAllText($file, $text.Replace($old, $desired))
    $marker.deliberatelyBroken = $State -eq 'Broken'
    $marker | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $root 'teaching-checkpoint.json') -Encoding utf8
    Write-Host "${State}: prepared teaching change only, not an agent result. Rebuild before testing."
}
