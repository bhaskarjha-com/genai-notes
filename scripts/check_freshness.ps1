<#
.SYNOPSIS
    Checks all published notes for content freshness based on the 'updated' frontmatter field.

.DESCRIPTION
    - Fast-moving topics (tags: genai, llm, agents, models, frameworks, tools) → flag if >6 months old
    - All other topics → flag if >12 months old
    - Notes missing 'last_verified' field are flagged separately
    - Outputs a summary table sorted by staleness

.NOTES
    Run from repo root: pwsh scripts/check_freshness.ps1
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$FastMovingTags = @("genai", "llm", "agents", "models", "frameworks", "tools", "mcp", "adk", "langraph", "crewai")
$FastMovingThresholdMonths = 6
$StableThresholdMonths = 12

$ContentDirs = @(
    "applications", "agents", "ethics-and-safety", "evaluation", "foundations",
    "inference", "llms", "multimodal", "prerequisites",
    "production", "research-frontiers", "techniques", "tools-and-infra"
)

$StaleNotes = @()
$MissingVerified = @()
$Now = Get-Date

foreach ($dir in $ContentDirs) {
    $fullDir = Join-Path $RepoRoot $dir
    if (-not (Test-Path $fullDir)) { continue }

    Get-ChildItem -Path $fullDir -Filter "*.md" -Recurse | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $relativePath = $_.FullName.Replace($RepoRoot, "").TrimStart("\", "/")

        # Extract frontmatter
        if ($content -match '(?s)^---\r?\n(.+?)\r?\n---') {
            $frontmatter = $Matches[1]

            # Get updated date
            $updatedDate = $null
            if ($frontmatter -match 'updated:\s*(\d{4}-\d{2}-\d{2})') {
                $updatedDate = [datetime]::Parse($Matches[1])
            }

            # Check for last_verified
            if ($frontmatter -notmatch 'last_verified:') {
                $MissingVerified += $relativePath
            }

            # Get tags
            $tags = @()
            if ($frontmatter -match 'tags:\s*\[([^\]]+)\]') {
                $tags = $Matches[1] -split ',' | ForEach-Object { $_.Trim() }
            }

            # Determine threshold
            $isFastMoving = ($tags | Where-Object { $FastMovingTags -contains $_ }).Count -gt 0
            $thresholdMonths = if ($isFastMoving) { $FastMovingThresholdMonths } else { $StableThresholdMonths }

            if ($updatedDate) {
                $ageMonths = [math]::Round(($Now - $updatedDate).TotalDays / 30, 1)
                if ($ageMonths -gt $thresholdMonths) {
                    $StaleNotes += [PSCustomObject]@{
                        Path        = $relativePath
                        Updated     = $updatedDate.ToString("yyyy-MM-dd")
                        AgeMonths   = $ageMonths
                        Threshold   = $thresholdMonths
                        Category    = if ($isFastMoving) { "FAST-MOVING" } else { "STABLE" }
                    }
                }
            }
        }
    }
}

# Output results
Write-Host "`n═══════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  FRESHNESS CHECK REPORT" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan

if ($StaleNotes.Count -gt 0) {
    Write-Host "⚠️  STALE NOTES ($($StaleNotes.Count) found):" -ForegroundColor Yellow
    Write-Host ""
    $StaleNotes | Sort-Object -Property AgeMonths -Descending | Format-Table -AutoSize
} else {
    Write-Host "✅ No stale notes found." -ForegroundColor Green
}

if ($MissingVerified.Count -gt 0) {
    Write-Host "`n📋 MISSING 'last_verified' FIELD ($($MissingVerified.Count) notes):" -ForegroundColor Yellow
    $MissingVerified | ForEach-Object { Write-Host "   $_" }
}

Write-Host "`n───────────────────────────────────────────────"
Write-Host "  Fast-moving threshold: $FastMovingThresholdMonths months"
Write-Host "  Stable threshold:      $StableThresholdMonths months"
Write-Host "  Total stale:           $($StaleNotes.Count)"
Write-Host "  Missing last_verified: $($MissingVerified.Count)"
Write-Host "───────────────────────────────────────────────`n"
