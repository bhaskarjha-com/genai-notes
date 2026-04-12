$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

function Resolve-DocTarget {
    param(
        [string]$SourcePath,
        [string]$Target
    )

    if ([string]::IsNullOrWhiteSpace($Target)) {
        return $null
    }

    $clean = ($Target -split "#")[0].Trim()
    if ([string]::IsNullOrWhiteSpace($clean)) {
        return $null
    }

    if ($clean -match '^(https?|mailto|tel):') {
        return $null
    }

    $baseDir = Split-Path -Parent $SourcePath
    $rawCombined = [System.IO.Path]::GetFullPath((Join-Path $baseDir $clean))
    if (Test-Path -LiteralPath $rawCombined) {
        return $rawCombined
    }

    if (-not [System.IO.Path]::HasExtension($clean)) {
        $clean = "$clean.md"
    }

    return [System.IO.Path]::GetFullPath((Join-Path $baseDir $clean))
}

function Get-FrontmatterParts {
    param([string]$Text)

    $match = [regex]::Match($Text, '^(?s)---\r?\n(.*?)\r?\n---\r?\n')
    if ($match.Success) {
        return @{
            Raw = $match.Groups[1].Value
            Body = $Text.Substring($match.Length)
        }
    }

    return @{
        Raw = ""
        Body = $Text
    }
}

function Get-RepoRelativePath {
    param(
        [string]$RootPath,
        [string]$TargetPath
    )

    $rootUri = New-Object System.Uri(($RootPath.TrimEnd('\') + '\'))
    $targetUri = New-Object System.Uri($TargetPath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($targetUri).ToString()).Replace('/', '\')
}

$allMarkdownFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Filter *.md |
    Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\drafts\\' -and
        $_.FullName -notmatch '\\_templates\\' -and
        $_.FullName -notmatch '\\site\\'
    }

$brokenFrontmatterLinks = New-Object System.Collections.Generic.List[string]
$brokenBodyLinks = New-Object System.Collections.Generic.List[string]
$bodyWikiLinks = New-Object System.Collections.Generic.List[string]

foreach ($file in $allMarkdownFiles) {
    $rawText = Get-Content -LiteralPath $file.FullName -Raw
    $parts = Get-FrontmatterParts -Text $rawText
    $frontmatter = $parts.Raw
    $body = $parts.Body
    $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $file.FullName

    if ($frontmatter) {
        $wikiMatches = [regex]::Matches($frontmatter, '\[\[([^\]]+)\]\]')
        foreach ($match in $wikiMatches) {
            $resolved = Resolve-DocTarget -SourcePath $file.FullName -Target $match.Groups[1].Value
            if ($resolved -and -not (Test-Path -LiteralPath $resolved)) {
                $brokenFrontmatterLinks.Add("$relativePath -> $($match.Groups[1].Value)")
            }
        }
    }

    if ($relativePath -eq "CONTRIBUTING.md") {
        continue
    }

    $bodyWithoutCode = [regex]::Replace($body, '(?ms)```.*?```', '')
    $markdownMatches = [regex]::Matches($bodyWithoutCode, '(?<!\!)\[[^\]]+\]\(([^)]+)\)')
    foreach ($match in $markdownMatches) {
        $resolved = Resolve-DocTarget -SourcePath $file.FullName -Target $match.Groups[1].Value.Trim()
        if ($resolved -and -not (Test-Path -LiteralPath $resolved)) {
            $brokenBodyLinks.Add("$relativePath -> $($match.Groups[1].Value.Trim())")
        }
    }

    $wikiInBody = [regex]::Matches($bodyWithoutCode, '\[\[([^\]]+)\]\]')
    foreach ($match in $wikiInBody) {
        $bodyWikiLinks.Add("$relativePath -> $($match.Groups[1].Value)")
    }
}

Write-Host "Link verification summary"
Write-Host "------------------------"
Write-Host ("Broken frontmatter links: {0}" -f $brokenFrontmatterLinks.Count)
Write-Host ("Broken body links: {0}" -f $brokenBodyLinks.Count)
Write-Host ("Body wiki-links outside templates/drafts: {0}" -f $bodyWikiLinks.Count)

if ($brokenFrontmatterLinks.Count -gt 0) {
    Write-Host ""
    Write-Host "Broken frontmatter links:"
    $brokenFrontmatterLinks | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($brokenBodyLinks.Count -gt 0) {
    Write-Host ""
    Write-Host "Broken body links:"
    $brokenBodyLinks | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($bodyWikiLinks.Count -gt 0) {
    Write-Host ""
    Write-Host "Body wiki-links:"
    $bodyWikiLinks | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($brokenFrontmatterLinks.Count -gt 0 -or $brokenBodyLinks.Count -gt 0 -or $bodyWikiLinks.Count -gt 0) {
    exit 1
}

exit 0
