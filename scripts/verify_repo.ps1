$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$contentDirs = @(
    "applications",
    "career",
    "ethics-and-safety",
    "evaluation",
    "foundations",
    "inference",
    "llms",
    "multimodal",
    "prerequisites",
    "production",
    "research-frontiers",
    "techniques",
    "tools-and-infra"
)

$standardNoteDirs = @(
    "applications",
    "ethics-and-safety",
    "evaluation",
    "foundations",
    "inference",
    "llms",
    "multimodal",
    "prerequisites",
    "production",
    "research-frontiers",
    "techniques",
    "tools-and-infra"
)

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

    $combined = Join-Path $baseDir $clean
    return [System.IO.Path]::GetFullPath($combined)
}

function Get-Frontmatter {
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

function Get-HeadingMatch {
    param(
        [string]$Text,
        [string]$Heading
    )

    $escaped = [regex]::Escape($Heading)
    return [regex]::IsMatch($Text, "(?im)^##\s+.*$escaped.*$")
}

function Get-MarkdownTargets {
    param([string]$Text)

    $matches = [regex]::Matches($Text, '(?<!\!)\[[^\]]+\]\(([^)]+)\)')
    return $matches | ForEach-Object { $_.Groups[1].Value.Trim() }
}

function Get-RepoRelativePath {
    param(
        [string]$RootPath,
        [string]$TargetPath
    )

    $rootUri = New-Object System.Uri(($RootPath.TrimEnd('\') + '\'))
    $targetUri = New-Object System.Uri($TargetPath)
    $relativeUri = $rootUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', '\')
}

$allMarkdownFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Filter *.md |
    Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\\.venv\\' -and
        $_.FullName -notmatch '[/\\]drafts[/\\]' -and
        $_.FullName -notmatch '[/\\]_templates[/\\]' -and
        $_.FullName -notmatch '[/\\]docs[/\\]' -and
        $_.FullName -notmatch '[/\\]site[/\\]'
    }

$brokenFrontmatterLinks = New-Object System.Collections.Generic.List[string]
$brokenBodyLinks = New-Object System.Collections.Generic.List[string]
$bodyWikiLinks = New-Object System.Collections.Generic.List[string]
$complianceIssues = New-Object System.Collections.Generic.List[string]
$notesMissingCode = New-Object System.Collections.Generic.List[string]
$notesMissingInterviewAngles = New-Object System.Collections.Generic.List[string]
$publishedTopicPaths = New-Object System.Collections.Generic.List[string]
$topicPublishedCount = 0
$topicCodeCount = 0
$topicInterviewCount = 0

foreach ($file in $allMarkdownFiles) {
    $rawText = Get-Content -LiteralPath $file.FullName -Raw
    $parts = Get-Frontmatter -Text $rawText
    $frontmatter = $parts.Raw
    $body = $parts.Body

    if ($frontmatter) {
        $wikiMatches = [regex]::Matches($frontmatter, '\[\[([^\]]+)\]\]')
        foreach ($match in $wikiMatches) {
            $resolved = Resolve-DocTarget -SourcePath $file.FullName -Target $match.Groups[1].Value
            if ($resolved -and -not (Test-Path -LiteralPath $resolved)) {
                $relative = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $file.FullName
                $brokenFrontmatterLinks.Add("$relative -> $($match.Groups[1].Value)")
            }
        }
    }

    $bodyWithoutCode = [regex]::Replace($body, '(?ms)```.*?```', '')
    $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $file.FullName

    if ($relativePath -notlike "*CONTRIBUTING.md") {
        $markdownMatches = [regex]::Matches($bodyWithoutCode, '(?<!\!)\[[^\]]+\]\(([^)]+)\)')
        foreach ($match in $markdownMatches) {
            $target = $match.Groups[1].Value.Trim()
            $resolved = Resolve-DocTarget -SourcePath $file.FullName -Target $target
            if ($resolved -and -not (Test-Path -LiteralPath $resolved)) {
                $relative = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $file.FullName
                $brokenBodyLinks.Add("$relative -> $target")
            }
        }

        $wikiInBody = [regex]::Matches($bodyWithoutCode, '\[\[([^\]]+)\]\]')
        foreach ($match in $wikiInBody) {
            $relative = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $file.FullName
            $bodyWikiLinks.Add("$relative -> $($match.Groups[1].Value)")
        }
    }

    $statusMatch = [regex]::Match($frontmatter, '(?m)^status:\s*(.+?)\s*$')
    $status = if ($statusMatch.Success) { $statusMatch.Groups[1].Value.Trim() } else { "" }

    if ($status -and $status -notin @("draft", "published")) {
        $complianceIssues.Add("$relativePath -> unsupported status '$status'")
    }

    if ($status -eq "published") {
        $topDir = ($relativePath -split '[\\/]', 2)[0]
        if ($topDir -in $standardNoteDirs -or $relativePath -eq "genai.md") {
            $publishedTopicPaths.Add($relativePath)
            $topicPublishedCount++
            if ($rawText -match '(?ms)```.+?```') {
                $topicCodeCount++
            }
            else {
                $notesMissingCode.Add($relativePath)
            }
            if ($bodyWithoutCode -match '(?im)^##\s+.*Interview Angles.*$') {
                $topicInterviewCount++
            }
            else {
                $notesMissingInterviewAngles.Add($relativePath)
            }
        }

        if ($relativePath -eq "career\genai-career-roles-universal.md") {
            continue
        }

        if ($relativePath -like "career\roles\*.md" -or $relativePath -like "career/roles/*.md") {
            foreach ($requiredHeading in @("Role Overview", "Learning Path", "Skills Breakdown", "Interview Preparation", "Sources")) {
                if (-not (Get-HeadingMatch -Text $bodyWithoutCode -Heading $requiredHeading)) {
                    $complianceIssues.Add("$relativePath -> missing section '$requiredHeading'")
                }
            }
            # Enforce enriched career template sections
            foreach ($enrichedSection in @("A Day in the Life", "Resume Bullet", "Take-Home Project", "Onboarding")) {
                if (-not (Get-HeadingMatch -Text $bodyWithoutCode -Heading $enrichedSection)) {
                    $complianceIssues.Add("$relativePath -> missing enriched section '$enrichedSection'")
                }
            }
        }
        else {
            if ($topDir -in $standardNoteDirs -or $relativePath -eq "genai.md") {
                foreach ($requiredHeading in @("TL;DR", "Overview", "Deep Dive", "Connections", "Sources")) {
                    if (-not (Get-HeadingMatch -Text $bodyWithoutCode -Heading $requiredHeading)) {
                        $complianceIssues.Add("$relativePath -> missing section '$requiredHeading'")
                    }
                }
                # Enforce heading markers (must have ★/◆/○ prefix)
                foreach ($markerHeading in @("TL;DR", "Overview", "Deep Dive", "Connections", "Sources")) {
                    $barePattern = "(?im)^##\s+$([regex]::Escape($markerHeading))\s*$"
                    if ([regex]::IsMatch($bodyWithoutCode, $barePattern)) {
                        $complianceIssues.Add("$relativePath -> bare heading '## $markerHeading' missing marker (expected ★/◆/○)")
                    }
                }
            }
        }
    }
}

$learningPathLinks = New-Object System.Collections.Generic.HashSet[string]
$learningPathPath = Join-Path $repoRoot "LEARNING_PATH.md"
$learningPathText = Get-Content -LiteralPath $learningPathPath -Raw
$learningPathBody = [regex]::Replace($learningPathText, '(?ms)```.*?```', '')
foreach ($target in (Get-MarkdownTargets -Text $learningPathBody)) {
    $resolved = Resolve-DocTarget -SourcePath $learningPathPath -Target $target
    if ($resolved -and (Test-Path -LiteralPath $resolved)) {
        [void]$learningPathLinks.Add((Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved))
    }
}

$genaiScopeLinks = New-Object System.Collections.Generic.HashSet[string]
$genaiPath = Join-Path $repoRoot "genai.md"
$genaiText = Get-Content -LiteralPath $genaiPath -Raw
$genaiBody = [regex]::Replace($genaiText, '(?ms)```.*?```', '')
foreach ($target in (Get-MarkdownTargets -Text $genaiBody)) {
    $resolved = Resolve-DocTarget -SourcePath $genaiPath -Target $target
    if ($resolved -and (Test-Path -LiteralPath $resolved)) {
        [void]$genaiScopeLinks.Add((Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved))
    }
}

$missingFromLearningPath = @(
    $publishedTopicPaths |
    Sort-Object -Unique |
    Where-Object { -not $learningPathLinks.Contains($_) }
)

$missingFromGenaiScope = @(
    $publishedTopicPaths |
    Sort-Object -Unique |
    Where-Object { $_ -ne "genai.md" -and -not $genaiScopeLinks.Contains($_) }
)

$topicCount = 0
$folderSummaries = New-Object System.Collections.Generic.List[string]
foreach ($dir in $contentDirs) {
    $path = Join-Path $repoRoot $dir
    if (Test-Path -LiteralPath $path) {
        $count = (Get-ChildItem -Path $path -File -Filter *.md -Recurse | Measure-Object).Count
        if ($dir -eq "career") {
            $topicCount += 0
        }
        else {
            $topicCount += $count
        }
        $folderSummaries.Add(("{0}: {1}" -f $dir, $count))
    }
}

Write-Host "Repo verification summary"
Write-Host "-------------------------"
Write-Host ("Topic-note count (excluding career docs): {0}" -f $topicCount)
Write-Host ("Broken frontmatter links: {0}" -f $brokenFrontmatterLinks.Count)
Write-Host ("Broken body links: {0}" -f $brokenBodyLinks.Count)
Write-Host ("Body wiki-links outside templates/drafts: {0}" -f $bodyWikiLinks.Count)
Write-Host ("Compliance issues: {0}" -f $complianceIssues.Count)
Write-Host ("Notes missing code examples: {0}" -f $notesMissingCode.Count)
Write-Host ("Notes missing interview angles: {0}" -f $notesMissingInterviewAngles.Count)
Write-Host ("Published notes missing from LEARNING_PATH.md: {0}" -f $missingFromLearningPath.Count)
Write-Host ("Published notes missing from genai.md scope map: {0}" -f $missingFromGenaiScope.Count)
if ($topicPublishedCount -gt 0) {
    $topicCodePct = [math]::Round(($topicCodeCount / [double]$topicPublishedCount) * 100, 1)
    $topicInterviewPct = [math]::Round(($topicInterviewCount / [double]$topicPublishedCount) * 100, 1)
    Write-Host ("Topic-note code coverage: {0}/{1} ({2}%)" -f $topicCodeCount, $topicPublishedCount, $topicCodePct)
    Write-Host ("Topic-note interview-angle coverage: {0}/{1} ({2}%)" -f $topicInterviewCount, $topicPublishedCount, $topicInterviewPct)
}
Write-Host ""
Write-Host "Folder counts:"
$folderSummaries | ForEach-Object { Write-Host ("- {0}" -f $_) }

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

if ($complianceIssues.Count -gt 0) {
    Write-Host ""
    Write-Host "Compliance issues:"
    $complianceIssues | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($notesMissingCode.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing code examples:"
    $notesMissingCode | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($notesMissingInterviewAngles.Count -gt 0) {
    Write-Host ""
    Write-Host "Notes missing interview angles:"
    $notesMissingInterviewAngles | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($missingFromLearningPath.Count -gt 0) {
    Write-Host ""
    Write-Host "Published notes missing from LEARNING_PATH.md:"
    $missingFromLearningPath | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if ($missingFromGenaiScope.Count -gt 0) {
    Write-Host ""
    Write-Host "Published notes missing from genai.md scope map:"
    $missingFromGenaiScope | Sort-Object | ForEach-Object { Write-Host ("- {0}" -f $_) }
}

if (
    $brokenFrontmatterLinks.Count -gt 0 -or
    $brokenBodyLinks.Count -gt 0 -or
    $bodyWikiLinks.Count -gt 0 -or
    $complianceIssues.Count -gt 0 -or
    $notesMissingCode.Count -gt 0 -or
    $notesMissingInterviewAngles.Count -gt 0 -or
    $missingFromLearningPath.Count -gt 0 -or
    $missingFromGenaiScope.Count -gt 0
) {
    exit 1
}

exit 0
