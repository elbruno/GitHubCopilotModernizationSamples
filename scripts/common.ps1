Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path $PSScriptRoot -Parent

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed with exit code $LASTEXITCODE" }
}

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Test-IsWithin([string]$Path, [string]$Parent) {
    $p = [IO.Path]::GetFullPath($Path).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $r = [IO.Path]::GetFullPath($Parent).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $comparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
    $p.Equals($r, $comparison) -or $p.StartsWith($r + [IO.Path]::DirectorySeparatorChar, $comparison)
}

function Get-DemoAllowlist {
    Get-Content -LiteralPath (Join-Path $PSScriptRoot 'demo-allowlist.json') -Raw | ConvertFrom-Json
}

function Get-SharedManifest {
    $fixture = Join-Path $RepoRoot 'fixtures/legacy-input'
    @((Get-DemoAllowlist) | ForEach-Object {
        [ordered]@{ path = $_; sha256 = Get-Sha256 (Join-Path $fixture $_) }
    })
}

function Get-CandidateFiles([string]$Root) {
    @(Get-ChildItem -LiteralPath $Root -File -Recurse -Force | Where-Object {
        $relative = [IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')
        $relative -notmatch '(^|/)(bin|obj|\.git|TestResults|node_modules)(/|$)' -and
        $relative -ne 'input-manifest.json'
    } | ForEach-Object {
        [ordered]@{
            path = [IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')
            sha256 = Get-Sha256 $_.FullName
        }
    } | Sort-Object { $_.path })
}
