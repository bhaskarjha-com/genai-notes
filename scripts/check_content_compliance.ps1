$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$dirs = @("foundations","techniques","llms","agents","production","inference","evaluation",
          "multimodal","applications","ethics-and-safety","tools-and-infra",
          "research-frontiers","prerequisites")

$missingFM    = [System.Collections.Generic.List[string]]::new()
$missingEx    = [System.Collections.Generic.List[string]]::new()
$missingCode  = [System.Collections.Generic.List[string]]::new()
$staleOwasp   = [System.Collections.Generic.List[string]]::new()
$totalChecked = 0

# ── OWASP 2023 stale-category detection ──────────────────────────────────────
# Only flag lines that contain the stale term WITHOUT a contextual '2023' or
# 'outdated' marker on the same line (i.e., lines in the migration diff table
# or Gotchas that explicitly call them out as defunct are allowed).
$owaspNote = Join-Path $repoRoot "ethics-and-safety\owasp-llm-top-10.md"
if (Test-Path $owaspNote) {
    $owaspLines = Get-Content $owaspNote
    $staleTerms = @("Insecure Plugin Design", "Overreliance", "Model Theft", "Model Denial of Service")
    foreach ($term in $staleTerms) {
        $escaped = [regex]::Escape($term)
        # A line is a TRUE FALSE POSITIVE if it also contains '2023', 'Outdated', 'outdated',
        # 'stale', 'old', 'deprecated', 'renamed', 'removed', 'folded', or 'Merged'
        $contextWords = '2023|[Oo]utdated|[Ss]tale|[Rr]enamed|[Rr]emoved|[Ff]olded|[Mm]erged|[Dd]eprecated'
        $truePositiveLines = $owaspLines | Where-Object {
            $_ -match $escaped -and $_ -notmatch $contextWords
        }
        if ($truePositiveLines.Count -gt 0) {
            $staleOwasp.Add("ethics-and-safety\owasp-llm-top-10.md contains unreferenced stale 2023 OWASP term: '$term'")
        }
    }
}


# ── Per-file section checks ───────────────────────────────────────────────────
foreach ($dir in $dirs) {
    $path = Join-Path $repoRoot $dir
    if (-not (Test-Path $path)) { continue }

    Get-ChildItem -Path $path -Filter "*.md" | ForEach-Object {
        $content   = Get-Content $_.FullName -Raw
        $diffMatch = [regex]::Match($content, 'difficulty:\s*(\w+)')
        if (-not $diffMatch.Success) { return }
        $difficulty = $diffMatch.Groups[1].Value
        if ($difficulty -notin @("intermediate", "advanced", "expert")) { return }

        $totalChecked++
        $relPath = $_.FullName.Substring($repoRoot.Length + 1)

        if (-not ($content -match "Production Failure Modes|## ◆ Production Failure Modes")) {
            $missingFM.Add("$relPath ($difficulty)")
        }
        if (-not ($content -match "Hands-On Exercises|## ◆ Hands-On Exercises")) {
            $missingEx.Add("$relPath ($difficulty)")
        }
        # Code section: ENFORCED as of Phase 6 — all intermediate+ notes must have this section
        if (-not ($content -match "Code & Implementation|Code \u0026 Implementation")) {
            $missingCode.Add("$relPath ($difficulty)")
        }
    }
}

# ── Summary report ────────────────────────────────────────────────────────────
Write-Host "Content compliance summary"
Write-Host "--------------------------"
Write-Host "Intermediate+ notes checked:          $totalChecked"
Write-Host ("Missing Production Failure Modes:     {0}" -f $missingFM.Count)
Write-Host ("Missing Hands-On Exercises:           {0}" -f $missingEx.Count)
Write-Host ("Missing Code & Implementation:        {0}  [ENFORCED - Phase 6 gate]" -f $missingCode.Count)
Write-Host ("Stale OWASP 2023 terms:               {0}" -f $staleOwasp.Count)

if ($missingFM.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing Production Failure Modes:"
    $missingFM | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}
if ($missingEx.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing Hands-On Exercises:"
    $missingEx | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}
if ($missingCode.Count -gt 0) {
    Write-Host ""
    Write-Host "BLOCKING: Notes missing 'Code and Implementation' section:"
    $missingCode | Sort-Object | ForEach-Object { Write-Host "  - $_" }
}
if ($staleOwasp.Count -gt 0) {
    Write-Host ""
    Write-Host "Stale OWASP 2023 terms detected:"
    $staleOwasp | ForEach-Object { Write-Host "  - $_" }
}

# ── Exit logic ─────────────────────────────────────────────────────────────────
# Phase 6: All four dimensions are now enforced blocking gates.
if ($missingFM.Count -gt 0 -or $missingEx.Count -gt 0 -or $missingCode.Count -gt 0 -or $staleOwasp.Count -gt 0) {
    exit 1
}
exit 0
