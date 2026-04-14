<#
.SYNOPSIS
    Checks code depth quality for intermediate+ notes.
    Ensures substantive code examples exist, not just trivial API calls.

.DESCRIPTION
    For each published note with difficulty intermediate/advanced/expert:
    - Extracts all fenced code blocks
    - Counts "substantive" lines (non-blank, non-comment, non-boilerplate)
    - Validates minimum depth thresholds per difficulty level
    - Reports violations as warnings (or blocking with -BlockOnFailure)

.NOTES
    Run from repo root: pwsh scripts/check_depth.ps1
    Promote to blocking gate: pwsh scripts/check_depth.ps1 -BlockOnFailure
#>

param([switch]$BlockOnFailure)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$standardNoteDirs = @(
    "agents", "applications", "ethics-and-safety", "evaluation",
    "foundations", "inference", "llms", "multimodal",
    "prerequisites", "production", "research-frontiers",
    "techniques", "tools-and-infra"
)

# Minimum thresholds per difficulty level
$thresholds = @{
    "intermediate" = @{ MinBlocks = 2; MinDepth = 15 }
    "advanced"     = @{ MinBlocks = 2; MinDepth = 20 }
    "expert"       = @{ MinBlocks = 3; MinDepth = 20 }
}

$thinCode = New-Object System.Collections.Generic.List[string]
$fewExamples = New-Object System.Collections.Generic.List[string]
$totalChecked = 0

foreach ($dir in $standardNoteDirs) {
    $path = Join-Path $repoRoot $dir
    if (-not (Test-Path $path)) { continue }

    Get-ChildItem -Path $path -Filter "*.md" -Recurse | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $relPath = $_.FullName.Substring($repoRoot.Length + 1)

        # Extract difficulty
        $diffMatch = [regex]::Match($content, 'difficulty:\s*(\w+)')
        if (-not $diffMatch.Success) { return }
        $difficulty = $diffMatch.Groups[1].Value
        if (-not $thresholds.ContainsKey($difficulty)) { return }

        # Skip drafts
        $statusMatch = [regex]::Match($content, 'status:\s*(\w+)')
        if ($statusMatch.Success -and $statusMatch.Groups[1].Value -ne "published") { return }

        $totalChecked++
        $threshold = $thresholds[$difficulty]

        # Extract code blocks (```lang\n...\n```)
        $codeBlocks = [regex]::Matches($content, '(?ms)```\w*\r?\n(.*?)```')
        $blockCount = $codeBlocks.Count
        $maxDepth = 0

        foreach ($block in $codeBlocks) {
            $lines = $block.Groups[1].Value -split '\r?\n'
            $substantive = @($lines | Where-Object {
                $_.Trim().Length -gt 0 -and
                $_ -notmatch '^\s*#\s' -and
                $_ -notmatch '^\s*//\s' -and
                $_ -notmatch '^\s*#!/' -and
                $_ -notmatch 'pip install' -and
                $_ -notmatch 'Last tested' -and
                $_ -notmatch 'Expected output' -and
                $_ -notmatch '^\s*"""' -and
                $_ -notmatch "^\s*'''"
            })
            $depth = $substantive.Count
            if ($depth -gt $maxDepth) { $maxDepth = $depth }
        }

        if ($maxDepth -lt $threshold.MinDepth) {
            $thinCode.Add("$relPath ($difficulty): max_depth=$maxDepth < required=$($threshold.MinDepth)")
        }
        if ($blockCount -lt $threshold.MinBlocks) {
            $fewExamples.Add("$relPath ($difficulty): blocks=$blockCount < required=$($threshold.MinBlocks)")
        }
    }
}

# Report
Write-Host "Code depth summary"
Write-Host "------------------"
Write-Host "Intermediate+ notes checked:     $totalChecked"
Write-Host ("Notes with thin code (< min):    {0}" -f $thinCode.Count)
Write-Host ("Notes with too few code blocks:  {0}" -f $fewExamples.Count)

if ($thinCode.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes with thin code:"
    $thinCode | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}

if ($fewExamples.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes with too few code blocks:"
    $fewExamples | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}

if ($BlockOnFailure -and ($thinCode.Count -gt 0 -or $fewExamples.Count -gt 0)) {
    Write-Host ""
    Write-Host "CI FAILURE: Code depth requirements not met." -ForegroundColor Red
    exit 1
}
exit 0
