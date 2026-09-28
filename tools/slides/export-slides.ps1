<#
.SYNOPSIS
Exports a saved PowerPoint deck as an audience-facing slides-only PDF.

.DESCRIPTION
Uses native PowerPoint on Windows and a temporary copy, leaving the source
deck and other open presentations untouched. The script never syncs, commits,
or pushes. Review every exported page before external delivery.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,
    [string]$OutputPath,
    [switch]$IncludeHiddenSlides,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'This exporter requires Windows with desktop Microsoft PowerPoint installed.'
}

$inputFile = (Resolve-Path -LiteralPath $InputPath).Path
if ([IO.Path]::GetExtension($inputFile) -ine '.pptx' -or
    -not (Test-Path -LiteralPath $inputFile -PathType Leaf)) {
    throw 'InputPath must be an existing .pptx file.'
}
if (-not $OutputPath) {
    $OutputPath = [IO.Path]::ChangeExtension($inputFile, '.pdf')
}
$outputFile = [IO.Path]::GetFullPath($OutputPath)
if ([IO.Path]::GetExtension($outputFile) -ine '.pdf') {
    throw 'OutputPath must have a .pdf extension.'
}
if (-not (Test-Path -LiteralPath (Split-Path -Parent $outputFile) -PathType Container)) {
    throw 'The output directory must already exist.'
}
if ((Test-Path -LiteralPath $outputFile) -and -not $Force) {
    throw 'OutputPath already exists. Choose a new versioned path or pass -Force to replace it.'
}
if (-not $PSCmdlet.ShouldProcess($outputFile, "Export slides from $inputFile")) {
    return
}

$sourceHash = (Get-FileHash -LiteralPath $inputFile -Algorithm SHA256).Hash
$temporaryDirectory = Join-Path ([IO.Path]::GetTempPath()) ("slide-export-" + [guid]::NewGuid())
$snapshot = Join-Path $temporaryDirectory ([IO.Path]::GetFileName($inputFile))
$temporaryPdf = Join-Path $temporaryDirectory 'slides.pdf'
$application = $presentation = $null

try {
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    Copy-Item -LiteralPath $inputFile -Destination $snapshot
    if ((Get-FileHash -LiteralPath $snapshot -Algorithm SHA256).Hash -ne $sourceHash) {
        throw 'The deck changed while creating its export snapshot.'
    }

    $application = New-Object -ComObject PowerPoint.Application
    $presentation = $application.Presentations.Open($snapshot, -1, 0, 0)
    $slideCount = $presentation.Slides.Count
    if ($slideCount -lt 1) {
        throw 'The deck contains no slides.'
    }
    $presentation.PrintOptions.OutputType = 1 # ppPrintOutputSlides, never notes.
    $presentation.PrintOptions.PrintHiddenSlides = if ($IncludeHiddenSlides) { -1 } else { 0 }
    $presentation.SaveAs($temporaryPdf, 32) # ppSaveAsPDF
    $pdfBytes = [IO.File]::ReadAllBytes($temporaryPdf)
    if ($pdfBytes.Length -lt 5 -or [Text.Encoding]::ASCII.GetString($pdfBytes, 0, 5) -ne '%PDF-') {
        throw 'PowerPoint did not produce a valid PDF header.'
    }
    if ((Get-FileHash -LiteralPath $inputFile -Algorithm SHA256).Hash -ne $sourceHash) {
        throw 'The source deck changed during export. Export the final saved deck again.'
    }

    Copy-Item -LiteralPath $temporaryPdf -Destination $outputFile -Force
    [pscustomobject]@{
        InputPath = $inputFile
        OutputPath = $outputFile
        Slides = $slideCount
        SourceSha256 = $sourceHash
        PdfSha256 = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash
    }
}
finally {
    try {
        if ($null -ne $presentation) {
            $presentation.Close()
        }
    }
    finally {
        if ($null -ne $presentation) {
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($presentation)
        }
        # PowerPoint may also own the user's open decks; never call Quit().
        if ($null -ne $application) {
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($application)
        }
        foreach ($file in @($snapshot, $temporaryPdf)) {
            if (Test-Path -LiteralPath $file) {
                Remove-Item -LiteralPath $file
            }
        }
        if (Test-Path -LiteralPath $temporaryDirectory) {
            [IO.Directory]::Delete($temporaryDirectory)
        }
    }
}
