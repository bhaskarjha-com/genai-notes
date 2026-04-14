$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$markdownFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Filter *.md |
    Where-Object {
        $_.FullName -notmatch '\\.git\\' -and
        $_.FullName -notmatch '\\.venv\\' -and
        $_.FullName -notmatch '[/\\]drafts[/\\]' -and
        $_.FullName -notmatch '[/\\]_templates[/\\]' -and
        $_.FullName -notmatch '[/\\]docs[/\\]' -and
        $_.FullName -notmatch '[/\\]site[/\\]'
    }

$trailingWhitespace = New-Object System.Collections.Generic.List[string]
$tabCharacters = New-Object System.Collections.Generic.List[string]
$h1Issues = New-Object System.Collections.Generic.List[string]
$codeFenceIssues = New-Object System.Collections.Generic.List[string]
$mojibakeIssues = New-Object System.Collections.Generic.List[string]
$mojibakeMarkers = @(
    [char]0x00C3,
    [char]0x00C2,
    [char]0x00E2,
    [char]0x00F0,
    [char]0x00C5,
    [char]0x00CB,
    [char]0x017D,
    [char]0x00CF
)

foreach ($file in $markdownFiles) {
    $relativePath = $file.FullName.Substring($repoRoot.Length + 1)
    $lines = Get-Content -LiteralPath $file.FullName -Encoding utf8

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '\s+$' -and $line.Trim().Length -gt 0) {
            $trailingWhitespace.Add("${relativePath}:$($i + 1)")
        }

        if ($line.Contains("`t")) {
            $tabCharacters.Add("${relativePath}:$($i + 1)")
        }
    }

    $rawText = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    if ($mojibakeMarkers | Where-Object { $rawText.Contains($_) }) {
        $mojibakeIssues.Add($relativePath)
    }

    $textWithoutFrontmatter = [regex]::Replace($rawText, '^(?s)---\r?\n.*?\r?\n---\r?\n', '')
    $textWithoutCode = [regex]::Replace($textWithoutFrontmatter, '(?ms)```.*?```', '')
    $h1Count = ([regex]::Matches($textWithoutCode, '(?m)^#\s+')).Count
    if ($h1Count -gt 1) {
        $h1Issues.Add("$relativePath -> $h1Count H1 headings")
    }

    $codeFenceCount = ([regex]::Matches($rawText, '(?m)^```')).Count
    if (($codeFenceCount % 2) -ne 0) {
        $codeFenceIssues.Add("$relativePath -> unbalanced code fences")
    }
}

Write-Host "Markdown quality summary"
Write-Host "------------------------"
Write-Host ("Trailing whitespace lines: {0}" -f $trailingWhitespace.Count)
Write-Host ("Tab character lines: {0}" -f $tabCharacters.Count)
Write-Host ("Multiple H1 issues: {0}" -f $h1Issues.Count)
Write-Host ("Code fence issues: {0}" -f $codeFenceIssues.Count)
Write-Host ("Mojibake indicator files: {0}" -f $mojibakeIssues.Count)

if ($trailingWhitespace.Count -gt 0) {
    Write-Host ""
    Write-Host "Trailing whitespace:"
    $trailingWhitespace | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($tabCharacters.Count -gt 0) {
    Write-Host ""
    Write-Host "Tab characters:"
    $tabCharacters | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($h1Issues.Count -gt 0) {
    Write-Host ""
    Write-Host "Multiple H1 issues:"
    $h1Issues | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($codeFenceIssues.Count -gt 0) {
    Write-Host ""
    Write-Host "Code fence issues:"
    $codeFenceIssues | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($mojibakeIssues.Count -gt 0) {
    Write-Host ""
    Write-Host "Mojibake indicator files:"
    $mojibakeIssues | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

# Check for broken version markers (# ?? instead of # ⚠️)
$brokenVersionMarkers = New-Object System.Collections.Generic.List[string]
foreach ($file in $markdownFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    if ($content -and $content -match '# \?\? Last tested') {
        $brokenVersionMarkers.Add($file.FullName.Substring($repoRoot.Length + 1))
    }
}

Write-Host ("Broken version markers (# ??): {0}" -f $brokenVersionMarkers.Count)
if ($brokenVersionMarkers.Count -gt 0) {
    Write-Host ""
    Write-Host "Files with broken version markers:"
    $brokenVersionMarkers | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if (
    $trailingWhitespace.Count -gt 0 -or
    $tabCharacters.Count -gt 0 -or
    $h1Issues.Count -gt 0 -or
    $codeFenceIssues.Count -gt 0 -or
    $mojibakeIssues.Count -gt 0 -or
    $brokenVersionMarkers.Count -gt 0
) {
    exit 1
}

exit 0
