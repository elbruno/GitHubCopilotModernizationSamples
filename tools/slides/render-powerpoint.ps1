<#
.SYNOPSIS
Renders a saved PPTX through native PowerPoint and records hash-bound QA evidence.

.DESCRIPTION
Creates a fresh, immutable render-pass directory with one PNG per slide, a
slides-only PDF, and a JSON receipt. Opens a temporary deck snapshot read-only
and never quits PowerPoint. Optional notes-manifest parity is checked against
the generated slide contract.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$InputPath,
    [Parameter(Mandatory)]
    [string]$OutputDirectory,
    [int]$ExpectedSlideCount = 0,
    [string]$NotesManifestPath,
    [ValidateRange(320, 7680)]
    [int]$Width = 1920,
    [ValidateRange(180, 4320)]
    [int]$Height = 1080
)

$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Native rendering requires Windows with desktop Microsoft PowerPoint installed.'
}
if ($ExpectedSlideCount -lt 0) {
    throw 'ExpectedSlideCount must be zero (unspecified) or positive.'
}

$inputFile = (Resolve-Path -LiteralPath $InputPath).Path
if ([IO.Path]::GetExtension($inputFile) -ine '.pptx' -or
    -not (Test-Path -LiteralPath $inputFile -PathType Leaf)) {
    throw 'InputPath must be an existing .pptx file.'
}
$output = [IO.Path]::GetFullPath($OutputDirectory)
if (Test-Path -LiteralPath $output) {
    throw 'OutputDirectory already exists. Choose a new render-pass directory to preserve evidence.'
}
$outputParent = Split-Path -Parent $output
if (-not (Test-Path -LiteralPath $outputParent -PathType Container)) {
    throw 'The parent of OutputDirectory must already exist.'
}

$notesManifest = $null
if ($NotesManifestPath) {
    $notesPath = (Resolve-Path -LiteralPath $NotesManifestPath).Path
    $notesManifest = Get-Content -LiteralPath $notesPath -Raw | ConvertFrom-Json
    if (-not $notesManifest.slides -or $notesManifest.slides.Count -lt 1) {
        throw 'NotesManifestPath must contain a JSON object with a non-empty slides array.'
    }
}
if (-not $PSCmdlet.ShouldProcess($output, "Render $inputFile with native PowerPoint")) {
    return
}

$sourceHash = (Get-FileHash -LiteralPath $inputFile -Algorithm SHA256).Hash.ToLowerInvariant()
$scratch = Join-Path ([IO.Path]::GetTempPath()) ("slide-render-" + [guid]::NewGuid())
$snapshot = Join-Path $scratch 'candidate.pptx'
$exporter = Join-Path $PSScriptRoot 'export-slides.ps1'
$pdfPath = Join-Path $output 'slides-only.pdf'
$application = $presentation = $slide = $shape = $frame = $range = $null
$overflows = [Collections.Generic.List[object]]::new()
$renders = [Collections.Generic.List[object]]::new()
$textCount = 0
$notesCount = 0
$started = [DateTime]::UtcNow.ToString('o')

try {
    New-Item -ItemType Directory -Path $output | Out-Null
    New-Item -ItemType Directory -Path $scratch | Out-Null
    Copy-Item -LiteralPath $inputFile -Destination $snapshot
    if ((Get-FileHash -LiteralPath $snapshot -Algorithm SHA256).Hash.ToLowerInvariant() -cne $sourceHash) {
        throw 'The deck changed while creating its render snapshot.'
    }

    $application = New-Object -ComObject PowerPoint.Application
    $powerPointVersion = $application.Version
    $presentation = $application.Presentations.Open($snapshot, -1, 0, 0)
    $slideCount = $presentation.Slides.Count
    if ($slideCount -lt 1) {
        throw 'The deck contains no slides.'
    }
    if ($ExpectedSlideCount -gt 0 -and $slideCount -ne $ExpectedSlideCount) {
        throw "Native slide count mismatch: expected $ExpectedSlideCount, found $slideCount."
    }
    if ($null -ne $notesManifest -and $slideCount -ne $notesManifest.slides.Count) {
        throw 'Native slide count does not match the notes manifest.'
    }

    for ($i = 1; $i -le $slideCount; $i++) {
        $slide = $presentation.Slides.Item($i)
        if ($null -ne $notesManifest) {
            $page = $slide.NotesPage
            try {
                $nativeNotes = $null
                for ($j = 1; $j -le $page.Shapes.Count; $j++) {
                    $note = $page.Shapes.Item($j)
                    try {
                        if ($note.Type -eq 14 -and $note.PlaceholderFormat.Type -eq 2) {
                            $nativeNotes = $note.TextFrame.TextRange.Text
                        }
                    }
                    finally {
                        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($note)
                    }
                }
            }
            finally {
                [void][Runtime.InteropServices.Marshal]::ReleaseComObject($page)
            }
            if ($null -eq $nativeNotes -or
                ($nativeNotes -replace '\s+', ' ').Trim() -cne
                ($notesManifest.slides[$i - 1].notes -replace '\s+', ' ').Trim()) {
                throw "Native notes differ from the manifest on slide $i."
            }
            $notesCount++
        }

        for ($j = 1; $j -le $slide.Shapes.Count; $j++) {
            $shape = $slide.Shapes.Item($j)
            try {
                if ($shape.HasTextFrame -eq -1 -and $shape.TextFrame2.HasText -eq -1) {
                    $textCount++
                    $frame = $shape.TextFrame2
                    $range = $frame.TextRange
                    $availableWidth = $shape.Width - $frame.MarginLeft - $frame.MarginRight
                    $availableHeight = $shape.Height - $frame.MarginTop - $frame.MarginBottom
                    if ($range.BoundWidth -gt ($availableWidth + 1.5) -or
                        $range.BoundHeight -gt ($availableHeight + 1.5)) {
                        $overflows.Add([ordered]@{
                            slide = $i
                            shapeId = $shape.Id
                            text = $range.Text
                            availableWidth = [Math]::Round($availableWidth, 2)
                            availableHeight = [Math]::Round($availableHeight, 2)
                            boundWidth = [Math]::Round($range.BoundWidth, 2)
                            boundHeight = [Math]::Round($range.BoundHeight, 2)
                        })
                    }
                    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($range)
                    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($frame)
                    $range = $frame = $null
                }
            }
            finally {
                [void][Runtime.InteropServices.Marshal]::ReleaseComObject($shape)
                $shape = $null
            }
        }

        $png = Join-Path $output ('slide-{0:D2}.png' -f $i)
        $slide.Export($png, 'PNG', $Width, $Height)
        $renders.Add([ordered]@{
            slide = $i
            path = [IO.Path]::GetFileName($png)
            sha256 = (Get-FileHash -LiteralPath $png -Algorithm SHA256).Hash.ToLowerInvariant()
        })
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($slide)
        $slide = $null
    }

    $presentation.Close()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($presentation)
    $presentation = $null
    $pdfReceipt = & $exporter -InputPath $inputFile -OutputPath $pdfPath -Confirm:$false
    if ((Get-FileHash -LiteralPath $inputFile -Algorithm SHA256).Hash.ToLowerInvariant() -cne $sourceHash) {
        throw 'Source deck changed during native render/export.'
    }

    $receipt = [ordered]@{
        status = if ($overflows.Count) { 'failed-text-bounds' } else { 'rendered-needs-visual-review' }
        renderer = 'Microsoft PowerPoint COM'
        version = $powerPointVersion
        startedUtc = $started
        endedUtc = [DateTime]::UtcNow.ToString('o')
        pptxSha256 = $sourceHash
        nativeOpenSucceeded = $true
        repairAttempted = $false
        slideCount = $slideCount
        textBoundsChecked = $true
        textShapesChecked = $textCount
        notesManifestChecked = ($null -ne $notesManifest)
        notesMatched = $notesCount
        tolerancePoints = 1.5
        overflows = @($overflows.ToArray())
        renders = @($renders.ToArray())
        pdf = [ordered]@{
            path = [IO.Path]::GetFileName($pdfPath)
            sha256 = $pdfReceipt.PdfSha256.ToLowerInvariant()
            pageCountVerified = $false
        }
        visualReview = 'pending'
        presenterApproval = 'pending'
        humanRehearsal = 'not performed'
        externalDelivery = 'not authorized'
    }
    $receipt | ConvertTo-Json -Depth 10 |
        Set-Content -LiteralPath (Join-Path $output 'native-receipt.json') -Encoding utf8

    "Native PowerPoint ${powerPointVersion}: $slideCount slides, $textCount text shapes, $($overflows.Count) overflows."
    if ($overflows.Count) {
        $overflows | ConvertTo-Json -Depth 5 | Write-Output
        throw 'Native text overflow found; fix the deck and render a new pass.'
    }
}
finally {
    foreach ($item in @($range, $frame, $shape, $slide)) {
        if ($null -ne $item) {
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($item)
        }
    }
    if ($null -ne $presentation) {
        $presentation.Close()
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($presentation)
    }
    if ($null -ne $application) {
        # PowerPoint may also own the user's open decks; never call Quit().
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($application)
    }
    if (Test-Path -LiteralPath $snapshot) {
        Remove-Item -LiteralPath $snapshot
    }
    if (Test-Path -LiteralPath $scratch) {
        [IO.Directory]::Delete($scratch)
    }
}
