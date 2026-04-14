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

# Byte-level UTF-8 validation: detects actual encoding corruption
# instead of heuristic single-character matching (which false-positives
# on em-dashes, degree signs, arrows, and box-drawing characters).
function Test-ValidUtf8 {
    param([byte[]]$Bytes)
    $i = 0
    while ($i -lt $Bytes.Length) {
        $b = $Bytes[$i]
        if ($b -le 0x7F) { $i++; continue }                        # ASCII
        elseif (($b -band 0xE0) -eq 0xC0) {                         # 2-byte: 110xxxxx
            if ($b -lt 0xC2) { return $false }                       # overlong
            if ($i + 1 -ge $Bytes.Length) { return $false }
            if (($Bytes[$i+1] -band 0xC0) -ne 0x80) { return $false }
            $i += 2
        }
        elseif (($b -band 0xF0) -eq 0xE0) {                         # 3-byte: 1110xxxx
            if ($i + 2 -ge $Bytes.Length) { return $false }
            if (($Bytes[$i+1] -band 0xC0) -ne 0x80) { return $false }
            if (($Bytes[$i+2] -band 0xC0) -ne 0x80) { return $false }
            $i += 3
        }
        elseif (($b -band 0xF8) -eq 0xF0) {                         # 4-byte: 11110xxx
            if ($i + 3 -ge $Bytes.Length) { return $false }
            if (($Bytes[$i+1] -band 0xC0) -ne 0x80) { return $false }
            if (($Bytes[$i+2] -band 0xC0) -ne 0x80) { return $false }
            if (($Bytes[$i+3] -band 0xC0) -ne 0x80) { return $false }
            $i += 4
        }
        else { return $false }                                       # invalid lead byte
    }
    return $true
}

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

    $rawBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    # Strip UTF-8 BOM if present
    if ($rawBytes.Length -ge 3 -and $rawBytes[0] -eq 0xEF -and $rawBytes[1] -eq 0xBB -and $rawBytes[2] -eq 0xBF) {
        $rawBytes = $rawBytes[3..($rawBytes.Length - 1)]
    }
    if (-not (Test-ValidUtf8 -Bytes $rawBytes)) {
        $mojibakeIssues.Add($relativePath)
    }

    $rawText = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8

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
