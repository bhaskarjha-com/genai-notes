$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$dirs = @("foundations","techniques","llms","agents","production","inference","evaluation",
          "multimodal","applications","ethics-and-safety","tools-and-infra",
          "research-frontiers","prerequisites")

$missingFM = New-Object System.Collections.Generic.List[string]
$missingEx = New-Object System.Collections.Generic.List[string]
$totalChecked = 0

foreach ($dir in $dirs) {
    $path = Join-Path $repoRoot $dir
    if (-not (Test-Path $path)) { continue }

    Get-ChildItem -Path $path -Filter "*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $diffMatch = [regex]::Match($content, 'difficulty:\s*(\w+)')
        if (-not $diffMatch.Success) { return }
        $difficulty = $diffMatch.Groups[1].Value

        if ($difficulty -notin @("intermediate","advanced","expert")) { return }

        $totalChecked++
        $relPath = $ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$dirs = @("foundations","techniques","llms","agents","production","inference","evaluation",
          "multimodal","applications","ethics-and-safety","tools-and-infra",
          "research-frontiers","prerequisites")

$missingFM = New-Object System.Collections.Generic.List[string]
$missingEx = New-Object System.Collections.Generic.List[string]
$totalChecked = 0

foreach ($dir in $dirs) {
    $path = Join-Path $repoRoot $dir
    if (-not (Test-Path $path)) { continue }

    Get-ChildItem -Path $path -Filter "*.md" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $diffMatch = [regex]::Match($content, 'difficulty:\s*(\w+)')
        if (-not $diffMatch.Success) { return }
        $difficulty = $diffMatch.Groups[1].Value

        if ($difficulty -notin @("intermediate","advanced","expert")) { return }

        $totalChecked++
        $relPath = $_.FullName.Replace("$repoRoot\", "")

        $hasFailureModes = $content -match "Production Failure Modes|## ◆ Production Failure Modes"
        $hasExercises = $content -match "Hands-On Exercises|## ◆ Hands-On Exercises"

        if (-not $hasFailureModes) {
            $missingFM.Add("$relPath ($difficulty)")
        }
        if (-not $hasExercises) {
            $missingEx.Add("$relPath ($difficulty)")
        }
    }
}

Write-Host "Content compliance summary"
Write-Host "--------------------------"
Write-Host "Intermediate+ notes checked: $totalChecked"
Write-Host ("Missing Production Failure Modes: {0}" -f $missingFM.Count)
Write-Host ("Missing Hands-On Exercises: {0}" -f $missingEx.Count)

if ($missingFM.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing Production Failure Modes:"
    $missingFM | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($missingEx.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing Hands-On Exercises:"
    $missingEx | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($missingFM.Count -gt 0 -or $missingEx.Count -gt 0) {
    exit 1
}

exit 0
.FullName.Substring($repoRoot.Length + 1)

        $hasFailureModes = $content -match "Production Failure Modes|## ◆ Production Failure Modes"
        $hasExercises = $content -match "Hands-On Exercises|## ◆ Hands-On Exercises"

        if (-not $hasFailureModes) {
            $missingFM.Add("$relPath ($difficulty)")
        }
        if (-not $hasExercises) {
            $missingEx.Add("$relPath ($difficulty)")
        }
    }
}

Write-Host "Content compliance summary"
Write-Host "--------------------------"
Write-Host "Intermediate+ notes checked: $totalChecked"
Write-Host ("Missing Production Failure Modes: {0}" -f $missingFM.Count)
Write-Host ("Missing Hands-On Exercises: {0}" -f $missingEx.Count)

if ($missingFM.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing Production Failure Modes:"
    $missingFM | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($missingEx.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing Hands-On Exercises:"
    $missingEx | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($missingFM.Count -gt 0 -or $missingEx.Count -gt 0) {
    exit 1
}

exit 0
