$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$topicDirs = @(
    "applications",
    "ethics-and-safety",
    "evaluation",
    "foundations",
    "image-generation",
    "inference",
    "llms",
    "multimodal",
    "prerequisites",
    "production",
    "research-frontiers",
    "techniques",
    "tools-and-infra"
)

$roleToTrackMap = @{
    "ai-engineer" = "A"
    "genai-engineer" = "B"
    "llm-engineer" = "B"
    "rag-engineer" = "B"
    "agentic-ai-engineer" = "B"
    "ml-engineer" = "C"
    "mlops-engineer" = "C"
}

function Get-RepoRelativePath {
    param(
        [string]$RootPath,
        [string]$TargetPath
    )

    $rootUri = New-Object System.Uri(($RootPath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar))
    $targetUri = New-Object System.Uri($TargetPath)
    return [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($targetUri).ToString()).Replace('\', '/')
}

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
    $combined = Join-Path $baseDir $clean
    $rawFullPath = [System.IO.Path]::GetFullPath($combined)
    if (Test-Path -LiteralPath $rawFullPath) {
        return $rawFullPath
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

function Get-FrontmatterScalar {
    param(
        [string]$Frontmatter,
        [string]$Key
    )

    $match = [regex]::Match($Frontmatter, "(?m)^$([regex]::Escape($Key)):\s*(.+?)\s*$")
    if (-not $match.Success) {
        return ""
    }

    $value = $match.Groups[1].Value.Trim()
    if (
        ($value.StartsWith('"') -and $value.EndsWith('"')) -or
        ($value.StartsWith("'") -and $value.EndsWith("'"))
    ) {
        return $value.Substring(1, $value.Length - 2)
    }

    return $value
}

function Get-FrontmatterList {
    param(
        [string]$Frontmatter,
        [string]$Key
    )

    $value = Get-FrontmatterScalar -Frontmatter $Frontmatter -Key $Key
    if ([string]::IsNullOrWhiteSpace($value)) {
        return @()
    }

    if ($value.StartsWith("[") -and $value.EndsWith("]")) {
        $inner = $value.Substring(1, $value.Length - 2).Trim()
        if ([string]::IsNullOrWhiteSpace($inner)) {
            return @()
        }

        return $inner.Split(",") | ForEach-Object {
            $item = $_.Trim()
            if (
                ($item.StartsWith('"') -and $item.EndsWith('"')) -or
                ($item.StartsWith("'") -and $item.EndsWith("'"))
            ) {
                $item = $item.Substring(1, $item.Length - 2)
            }
            $item
        }
    }

    return @($value)
}

function Get-HeadingSection {
    param(
        [string]$Body,
        [string]$Heading
    )

    $escaped = [regex]::Escape($Heading)
    $headingMatch = [regex]::Match($Body, "(?im)^##[ \t]+[^\r\n]*$escaped[^\r\n]*\r?$")
    if ($headingMatch.Success) {
        $startIndex = $headingMatch.Index + $headingMatch.Length
        $remaining = $Body.Substring($startIndex)
        $nextHeadingMatch = [regex]::Match($remaining, "(?im)^##[ \t]+")
        if ($nextHeadingMatch.Success) {
            return $remaining.Substring(0, $nextHeadingMatch.Index).Trim()
        }

        return $remaining.Trim()
    }

    return ""
}

function Get-TopLevelSection {
    param(
        [string]$Text,
        [string]$HeadingPrefix
    )

    $match = [regex]::Match(
        $Text,
        "(?ms)^##\s+$([regex]::Escape($HeadingPrefix))[^\r\n]*\r?\n(?<content>.*?)(?=^##\s+|\z)"
    )

    if ($match.Success) {
        return $match.Groups["content"].Value.Trim()
    }

    return ""
}

function Get-MarkdownTableRows {
    param([string]$SectionText)

    if ([string]::IsNullOrWhiteSpace($SectionText)) {
        return @()
    }

    $lines = $SectionText -split "\r?\n"
    $tableLines = New-Object System.Collections.Generic.List[string]
    $seenTable = $false

    foreach ($line in $lines) {
        if ($line.Trim().StartsWith("|")) {
            $tableLines.Add($line)
            $seenTable = $true
            continue
        }

        if ($seenTable) {
            break
        }
    }

    if ($tableLines.Count -lt 3) {
        return @()
    }

    $headers = ($tableLines[0].Trim().Trim("|").Split("|") | ForEach-Object { $_.Trim() })
    $rows = New-Object System.Collections.Generic.List[object]

    for ($i = 2; $i -lt $tableLines.Count; $i++) {
        $line = $tableLines[$i]
        if (-not $line.Trim().StartsWith("|")) {
            continue
        }

        $cells = ($line.Trim().Trim("|").Split("|") | ForEach-Object { $_.Trim() })
        if ($cells.Count -lt $headers.Count) {
            continue
        }

        $row = [ordered]@{}
        for ($j = 0; $j -lt $headers.Count; $j++) {
            $row[$headers[$j]] = $cells[$j]
        }

        $rows.Add([pscustomobject]$row)
    }

    return $rows
}

function Get-MarkdownLinks {
    param([string]$Text)

    $matches = [regex]::Matches($Text, '(?<!\!)\[([^\]]+)\]\(([^)]+)\)')
    $results = New-Object System.Collections.Generic.List[object]
    foreach ($match in $matches) {
        $results.Add([pscustomobject]@{
            Label = $match.Groups[1].Value.Trim()
            Target = $match.Groups[2].Value.Trim()
        })
    }

    return $results
}

function Get-WikiLinks {
    param([string]$Text)

    $matches = [regex]::Matches($Text, '\[\[([^\]]+)\]\]')
    return $matches | ForEach-Object { $_.Groups[1].Value.Trim() }
}

function Get-InterviewPairs {
    param([string]$SectionText)

    if ([string]::IsNullOrWhiteSpace($SectionText)) {
        return @()
    }

    $matches = [regex]::Matches(
        $SectionText,
        '(?ms)-\s+\*\*Q\*\*:\s*(?<question>.+?)\r?\n-\s+\*\*A\*\*:\s*(?<answer>.+?)(?=(\r?\n\r?\n-\s+\*\*Q\*\*:)|(\r?\n\r?\n##\s+)|\z)'
    )

    $pairs = New-Object System.Collections.Generic.List[object]
    foreach ($match in $matches) {
        $answer = $match.Groups["answer"].Value.Trim()
        $answer = [regex]::Replace($answer, '(?ms)\r?\n---\s*$', '').Trim()
        $pairs.Add([pscustomobject]@{
            Question = $match.Groups["question"].Value.Trim()
            Answer = $answer
        })
    }

    return $pairs
}

function Get-NoteTitle {
    param(
        [string]$Frontmatter,
        [string]$Body
    )

    $title = Get-FrontmatterScalar -Frontmatter $Frontmatter -Key "title"
    if (-not [string]::IsNullOrWhiteSpace($title)) {
        return $title
    }

    $heading = [regex]::Match($Body, '(?m)^#\s+(.+?)\s*$')
    if ($heading.Success) {
        return $heading.Groups[1].Value.Trim()
    }

    return "Untitled"
}

function Get-SiteDocPath {
    param([string]$RepoRelativePath)

    return ($RepoRelativePath -replace '\.md$', '.html')
}

function Format-TrackSlug {
    param([string]$Title)

    $slug = $Title.ToLowerInvariant()
    $slug = [regex]::Replace($slug, '[^a-z0-9]+', '-')
    return $slug.Trim('-')
}

function Convert-TimeTextToHours {
    param([string]$Value)

    $match = [regex]::Match($Value, '([0-9]+(?:\.[0-9]+)?)')
    if ($match.Success) {
        return [double]$match.Groups[1].Value
    }

    return 0
}

function Normalize-DeckField {
    param([string]$Value)

    $clean = $Value -replace '\r?\n', '<br>'
    $clean = $clean -replace '\t', '    '
    return $clean.Trim()
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function New-MarkdownChecklist {
    param(
        [string]$Title,
        [string]$Summary,
        [object[]]$Sections
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# $Title")
    $lines.Add("")
    $lines.Add("> $Summary")
    $lines.Add("")

    foreach ($section in $Sections) {
        $lines.Add("## $($section.Title)")
        $lines.Add("")
        if ($section.Notes.Count -gt 0) {
            foreach ($note in $section.Notes) {
                $lines.Add("- [ ] [$($note.Label)]($($note.MarkdownLink)) - $($note.EstTime)")
            }
        }
        else {
            $lines.Add("_No notes in this section._")
        }
        $lines.Add("")
    }

    return ($lines -join "`n")
}

function Get-LearningPathData {
    param(
        [string]$Path,
        [hashtable]$NotesByPath
    )

    $foundationSections = New-Object System.Collections.Generic.List[object]
    $trackSections = New-Object System.Collections.Generic.List[object]
    $noteTrackMap = @{}

    $text = Get-Content -LiteralPath $Path -Raw
    $part1Text = Get-TopLevelSection -Text $text -HeadingPrefix "Part 1"
    $part2Text = Get-TopLevelSection -Text $text -HeadingPrefix "Part 2"

    $foundationMatches = [regex]::Matches($part1Text, '(?ms)^###\s+(?<heading>.+?)\r?\n(?<content>.*?)(?=^###\s+|\z)')
    foreach ($match in $foundationMatches) {
        $heading = $match.Groups["heading"].Value.Trim()
        $content = $match.Groups["content"].Value.Trim()
        $tableRows = Get-MarkdownTableRows -SectionText $content
        if ($tableRows.Count -eq 0) {
            continue
        }

        $notes = New-Object System.Collections.Generic.List[object]
        foreach ($row in $tableRows) {
            $link = Get-MarkdownLinks -Text $row.Note | Select-Object -First 1
            if (-not $link) {
                continue
            }

            $resolved = Resolve-DocTarget -SourcePath $Path -Target $link.Target
            if (-not $resolved) {
                continue
            }

            $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
            if (-not $NotesByPath.ContainsKey($relativePath)) {
                continue
            }

            $note = $NotesByPath[$relativePath]
            $notes.Add([pscustomobject]@{
                Path = $relativePath
                Title = $note.Title
                Label = $link.Label
                Folder = $note.Folder
                Difficulty = $note.Difficulty
                EstTime = $row.'Est. Time'
                SitePath = $note.SitePath
                MarkdownLink = "../$relativePath"
            })
        }

        $levelId = switch -Regex ($heading) {
            '^Level 1' { "foundation-level-1"; break }
            '^Level 2' { "foundation-level-2"; break }
            '^Level 3' { "foundation-level-3"; break }
            default { Format-TrackSlug -Title $heading }
        }

        $foundationSections.Add([pscustomobject]@{
            Id = $levelId
            Title = $heading
            Notes = @($notes | ForEach-Object { $_ })
        })

        foreach ($note in $notes) {
            if (-not $noteTrackMap.ContainsKey($note.Path)) {
                $noteTrackMap[$note.Path] = New-Object System.Collections.Generic.List[string]
            }
            if (-not $noteTrackMap[$note.Path].Contains("Foundation")) {
                $noteTrackMap[$note.Path].Add("Foundation")
            }
        }
    }

    $trackMatches = [regex]::Matches($part2Text, '(?ms)^###\s+(?<heading>Track\s+[A-Z].+?)\r?\n(?<content>.*?)(?=^###\s+|\z)')
    foreach ($match in $trackMatches) {
        $heading = $match.Groups["heading"].Value.Trim()
        $content = $match.Groups["content"].Value.Trim()
        $tableRows = Get-MarkdownTableRows -SectionText $content
        if ($tableRows.Count -eq 0) {
            continue
        }

        $targetRolesMatch = [regex]::Match($content, '(?m)^Target roles:\s*(.+)$')
        $targetRoles = @()
        if ($targetRolesMatch.Success) {
            $targetRoles = $targetRolesMatch.Groups[1].Value.Split(",") | ForEach-Object { $_.Trim() }
        }

        $notes = New-Object System.Collections.Generic.List[object]
        foreach ($row in $tableRows) {
            $link = Get-MarkdownLinks -Text $row.Note | Select-Object -First 1
            if (-not $link) {
                continue
            }

            $resolved = Resolve-DocTarget -SourcePath $Path -Target $link.Target
            if (-not $resolved) {
                continue
            }

            $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
            if (-not $NotesByPath.ContainsKey($relativePath)) {
                continue
            }

            $note = $NotesByPath[$relativePath]
            $notes.Add([pscustomobject]@{
                Path = $relativePath
                Title = $note.Title
                Label = $link.Label
                Folder = $note.Folder
                Difficulty = $note.Difficulty
                EstTime = $row.'Est. Time'
                SitePath = $note.SitePath
                MarkdownLink = "../$relativePath"
            })
        }

        $trackId = [regex]::Match($heading, '^Track\s+([A-Z])').Groups[1].Value
        $trackSections.Add([pscustomobject]@{
            Id = $trackId
            Title = $heading
            Slug = Format-TrackSlug -Title $heading
            TargetRoles = $targetRoles
            Notes = @($notes | ForEach-Object { $_ })
        })

        foreach ($note in $notes) {
            if (-not $noteTrackMap.ContainsKey($note.Path)) {
                $noteTrackMap[$note.Path] = New-Object System.Collections.Generic.List[string]
            }
            $noteTrackMap[$note.Path].Add($trackId)
        }
    }

    return [pscustomobject]@{
        Foundation = @($foundationSections | ForEach-Object { $_ })
        Tracks = @($trackSections | ForEach-Object { $_ })
        NoteTrackMap = $noteTrackMap
    }
}

function Get-RoleGuideData {
    param(
        [string]$RolesDirectory,
        [hashtable]$NotesByPath
    )

    $roles = New-Object System.Collections.Generic.List[object]
    $roleFiles = Get-ChildItem -LiteralPath $RolesDirectory -File -Filter *.md | Sort-Object Name

    foreach ($file in $roleFiles) {
        $rawText = Get-Content -LiteralPath $file.FullName -Raw
        $parts = Get-FrontmatterParts -Text $rawText
        $body = $parts.Body
        $title = Get-NoteTitle -Frontmatter $parts.Raw -Body $body
        $slug = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

        $phase2Section = [regex]::Match($body, '(?ims)^###\s+Phase 2:.*?\r?\n(?<content>.*?)(?=^###\s+Phase 3:|\z)')
        $phase3Section = [regex]::Match($body, '(?ims)^###\s+Phase 3:.*?\r?\n(?<content>.*?)(?=^###\s+Phase 4:|\z)')

        $mustNotes = New-Object System.Collections.Generic.List[string]
        $goodNotes = New-Object System.Collections.Generic.List[string]

        foreach ($row in (Get-MarkdownTableRows -SectionText $phase2Section.Groups["content"].Value)) {
            $link = Get-MarkdownLinks -Text $row.Note | Select-Object -First 1
            if (-not $link) {
                continue
            }

            $resolved = Resolve-DocTarget -SourcePath $file.FullName -Target $link.Target
            if (-not $resolved) {
                continue
            }

            $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
            if ($NotesByPath.ContainsKey($relativePath)) {
                $mustNotes.Add($relativePath)
            }
        }

        foreach ($row in (Get-MarkdownTableRows -SectionText $phase3Section.Groups["content"].Value)) {
            $link = Get-MarkdownLinks -Text $row.Note | Select-Object -First 1
            if (-not $link) {
                continue
            }

            $resolved = Resolve-DocTarget -SourcePath $file.FullName -Target $link.Target
            if (-not $resolved) {
                continue
            }

            $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
            if ($NotesByPath.ContainsKey($relativePath)) {
                $goodNotes.Add($relativePath)
            }
        }

        $roles.Add([pscustomobject]@{
            Id = $slug
            Title = ($title -replace '\s*-\s*Career Guide$', '')
            PrimaryTrack = $roleToTrackMap[$slug]
            MustNotes = @($mustNotes | Select-Object -Unique)
            GoodNotes = @($goodNotes | Select-Object -Unique)
        })
    }

    return $roles
}

$notesByPath = @{}
$publishedNotes = New-Object System.Collections.Generic.List[object]
$noteFiles = New-Object System.Collections.Generic.List[string]

foreach ($dir in $topicDirs) {
    $path = Join-Path $repoRoot $dir
    if (Test-Path -LiteralPath $path) {
        Get-ChildItem -LiteralPath $path -File -Filter *.md | ForEach-Object {
            $noteFiles.Add($_.FullName)
        }
    }
}

$noteFiles.Add((Join-Path $repoRoot "genai.md"))

foreach ($fullPath in ($noteFiles | Sort-Object -Unique)) {
    $rawText = Get-Content -LiteralPath $fullPath -Raw
    $parts = Get-FrontmatterParts -Text $rawText
    $status = Get-FrontmatterScalar -Frontmatter $parts.Raw -Key "status"
    if ($status -ne "published") {
        continue
    }

    $relativePath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $fullPath
    $title = Get-NoteTitle -Frontmatter $parts.Raw -Body $parts.Body
    $folder = if ($relativePath -match '/') { ($relativePath -split '/')[0] } else { "root" }
    $connectionsSection = Get-HeadingSection -Body $parts.Body -Heading "Connections"
    $interviewSection = Get-HeadingSection -Body $parts.Body -Heading "Interview Angles"
    $parentLinks = Get-WikiLinks -Text (Get-FrontmatterScalar -Frontmatter $parts.Raw -Key "parent")
    $relatedLinks = Get-WikiLinks -Text ((Get-FrontmatterList -Frontmatter $parts.Raw -Key "related") -join " ")

    $note = [pscustomobject]@{
        Path = $relativePath
        FullPath = $fullPath
        Title = $title
        Folder = $folder
        Difficulty = Get-FrontmatterScalar -Frontmatter $parts.Raw -Key "difficulty"
        Tags = @(Get-FrontmatterList -Frontmatter $parts.Raw -Key "tags")
        SitePath = Get-SiteDocPath -RepoRelativePath $relativePath
        ConnectionsSection = $connectionsSection
        InterviewPairs = @(Get-InterviewPairs -SectionText $interviewSection)
        ParentLinks = @($parentLinks)
        RelatedLinks = @($relatedLinks)
    }

    $notesByPath[$relativePath] = $note
    $publishedNotes.Add($note)
}

$learningPath = Get-LearningPathData -Path (Join-Path $repoRoot "LEARNING_PATH.md") -NotesByPath $notesByPath
$roles = Get-RoleGuideData -RolesDirectory (Join-Path $repoRoot "career/roles") -NotesByPath $notesByPath

foreach ($note in $publishedNotes) {
    $tracks = @()
    if ($learningPath.NoteTrackMap.ContainsKey($note.Path)) {
        $tracks = @($learningPath.NoteTrackMap[$note.Path] | Select-Object -Unique)
    }
    $note | Add-Member -NotePropertyName Tracks -NotePropertyValue $tracks
}

$edgeMap = @{}

foreach ($note in $publishedNotes) {
    foreach ($parentLink in $note.ParentLinks) {
        $resolved = Resolve-DocTarget -SourcePath $note.FullPath -Target $parentLink
        if (-not $resolved) {
            continue
        }

        $targetPath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
        if (-not $notesByPath.ContainsKey($targetPath)) {
            continue
        }

        $key = "$($note.Path)|$targetPath|parent"
        $edgeMap[$key] = [pscustomobject]@{
            Source = $note.Path
            Target = $targetPath
            Relation = "parent"
        }
    }

    foreach ($relatedLink in $note.RelatedLinks) {
        $resolved = Resolve-DocTarget -SourcePath $note.FullPath -Target $relatedLink
        if (-not $resolved) {
            continue
        }

        $targetPath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
        if (-not $notesByPath.ContainsKey($targetPath)) {
            continue
        }

        $key = "$($note.Path)|$targetPath|related"
        $edgeMap[$key] = [pscustomobject]@{
            Source = $note.Path
            Target = $targetPath
            Relation = "related"
        }
    }

    foreach ($row in (Get-MarkdownTableRows -SectionText $note.ConnectionsSection)) {
        $relation = [regex]::Replace($row.Relationship.ToLowerInvariant(), '[^a-z0-9]+', '-').Trim('-')
        foreach ($link in (Get-MarkdownLinks -Text $row.Topics)) {
            $resolved = Resolve-DocTarget -SourcePath $note.FullPath -Target $link.Target
            if (-not $resolved) {
                continue
            }

            $targetPath = Get-RepoRelativePath -RootPath $repoRoot -TargetPath $resolved
            if (-not $notesByPath.ContainsKey($targetPath)) {
                continue
            }

            $key = "$($note.Path)|$targetPath|$relation"
            $edgeMap[$key] = [pscustomobject]@{
                Source = $note.Path
                Target = $targetPath
                Relation = $relation
            }
        }
    }
}

$degreeMap = @{}
foreach ($note in $publishedNotes) {
    $degreeMap[$note.Path] = 0
}

foreach ($edge in $edgeMap.Values) {
    $degreeMap[$edge.Source]++
    $degreeMap[$edge.Target]++
}

$graphNodes = $publishedNotes | Sort-Object Folder, Title | ForEach-Object {
    [pscustomobject]@{
        Id = $_.Path
        Title = $_.Title
        Folder = $_.Folder
        Difficulty = $_.Difficulty
        Tags = $_.Tags
        Tracks = $_.Tracks
        SitePath = $_.SitePath
        Degree = $degreeMap[$_.Path]
    }
}

$graphData = [pscustomobject]@{
    GeneratedAt = (Get-Date).ToString("yyyy-MM-dd")
    NodeCount = $graphNodes.Count
    EdgeCount = $edgeMap.Count
    Folders = @($graphNodes.Folder | Sort-Object -Unique)
    Difficulties = @($graphNodes.Difficulty | Where-Object { $_ } | Sort-Object -Unique)
    Tracks = @(
        @("Foundation") +
        ($learningPath.Tracks | ForEach-Object { $_.Id } | Sort-Object -Unique)
    )
    Nodes = @($graphNodes | ForEach-Object { $_ })
    Links = @($edgeMap.Values | Sort-Object Source, Target, Relation)
}

$foundationNotePaths = @(
    $learningPath.Foundation |
    ForEach-Object { $_.Notes } |
    ForEach-Object { $_.Path }
)

$trackById = @{}
foreach ($track in $learningPath.Tracks) {
    $trackById[$track.Id] = $track
}

$matrixTopics = New-Object System.Collections.Generic.List[object]

foreach ($note in ($publishedNotes | Sort-Object Folder, Title)) {
    $statuses = [ordered]@{}
    foreach ($role in $roles) {
        $status = "Not Relevant"
        if ($foundationNotePaths -contains $note.Path) {
            $status = "Must"
        }
        elseif ($role.MustNotes -contains $note.Path) {
            $status = "Must"
        }
        elseif ($role.GoodNotes -contains $note.Path) {
            $status = "Good"
        }
        elseif (
            $role.PrimaryTrack -and
            $trackById.ContainsKey($role.PrimaryTrack) -and
            ($trackById[$role.PrimaryTrack].Notes.Path -contains $note.Path)
        ) {
            $status = "Optional"
        }

        $statuses[$role.Id] = $status
    }

    $matrixTopics.Add([pscustomobject]@{
        Path = $note.Path
        Title = $note.Title
        Folder = $note.Folder
        Difficulty = $note.Difficulty
        SitePath = $note.SitePath
        Statuses = [pscustomobject]$statuses
    })
}

$matrixRoles = New-Object System.Collections.Generic.List[object]
foreach ($role in $roles) {
    $mustCount = 0
    $goodCount = 0
    $optionalCount = 0
    $notRelevantCount = 0

    foreach ($topic in $matrixTopics) {
        switch ($topic.Statuses.$($role.Id)) {
            "Must" { $mustCount++ }
            "Good" { $goodCount++ }
            "Optional" { $optionalCount++ }
            default { $notRelevantCount++ }
        }
    }

    $matrixRoles.Add([pscustomobject]@{
        Id = $role.Id
        Title = $role.Title
        PrimaryTrack = $role.PrimaryTrack
        MustCount = $mustCount
        GoodCount = $goodCount
        OptionalCount = $optionalCount
        NotRelevantCount = $notRelevantCount
    })
}

$matrixData = [pscustomobject]@{
    GeneratedAt = (Get-Date).ToString("yyyy-MM-dd")
    Roles = @($matrixRoles | ForEach-Object { $_ })
    Topics = @($matrixTopics | ForEach-Object { $_ })
}

$matrixLines = New-Object System.Collections.Generic.List[string]
$matrixLines.Add("# Topic x Role Relevance Matrix")
$matrixLines.Add("")
$matrixLines.Add("> Auto-generated from `LEARNING_PATH.md` and the dedicated role guides in `career/roles/`.")
$matrixLines.Add("")
$matrixLines.Add("Legend: `Must`, `Good`, `Optional`, `Not Relevant`.")
$matrixLines.Add("")

$roleHeaders = $roles | ForEach-Object { $_.Title }
$headerLine = "| Topic | Folder | " + (($roleHeaders) -join " | ") + " |"
$separatorLine = "|---|---|" + ((1..$roleHeaders.Count | ForEach-Object { "---" }) -join "|") + "|"
$matrixLines.Add($headerLine)
$matrixLines.Add($separatorLine)

foreach ($topic in $matrixTopics) {
    $cells = New-Object System.Collections.Generic.List[string]
    $cells.Add(("[{0}](../{1})" -f $topic.Title, $topic.Path))
    $cells.Add($topic.Folder)
    foreach ($role in $roles) {
        $cells.Add($topic.Statuses.$($role.Id))
    }
    $matrixLines.Add("| " + ($cells -join " | ") + " |")
}

$ankiDeckDefinitions = New-Object System.Collections.Generic.List[object]
$ankiDeckDefinitions.Add([pscustomobject]@{
    FileName = "master-deck.tsv"
    Label = "Master Deck"
    NotePaths = @($publishedNotes | ForEach-Object { $_.Path })
    Description = "All interview-angle cards from all published topic notes."
})
$ankiDeckDefinitions.Add([pscustomobject]@{
    FileName = "universal-foundation.tsv"
    Label = "Universal Foundation"
    NotePaths = @($foundationNotePaths | Sort-Object -Unique)
    Description = "Interview-angle cards from the Part 1 universal foundation."
})

foreach ($track in $learningPath.Tracks) {
    $trackPaths = New-Object System.Collections.Generic.List[string]
    foreach ($foundationSection in $learningPath.Foundation) {
        foreach ($foundationNote in $foundationSection.Notes) {
            $trackPaths.Add($foundationNote.Path)
        }
    }
    foreach ($trackNote in $track.Notes) {
        $trackPaths.Add($trackNote.Path)
    }

    $ankiDeckDefinitions.Add([pscustomobject]@{
        FileName = "$($track.Slug).tsv"
        Label = $track.Title
        NotePaths = @($trackPaths | Sort-Object -Unique)
        Description = "Universal foundation plus the role-cluster notes from $($track.Title)."
    })
}

$ankiCatalogRows = New-Object System.Collections.Generic.List[object]
foreach ($deck in $ankiDeckDefinitions) {
    $deckNotes = @(
        $deck.NotePaths |
        Sort-Object -Unique |
        ForEach-Object {
            if ($notesByPath.ContainsKey($_)) {
                $notesByPath[$_]
            }
        }
    )

    $rows = New-Object System.Collections.Generic.List[string]
    foreach ($note in ($deckNotes | Sort-Object Title, Path)) {
        foreach ($pair in $note.InterviewPairs) {
            $front = Normalize-DeckField -Value $pair.Question
            $tagText = (($note.Tags + @($note.Folder) + $note.Tracks) | Where-Object { $_ } | ForEach-Object { $_.ToString() } | Sort-Object -Unique) -join ", "
            $back = Normalize-DeckField -Value (
                "{0}`n`nSource: {1}`nTags: {2}" -f
                $pair.Answer,
                $note.Path,
                $tagText
            )
            $rows.Add("$front`t$back")
        }
    }

    $outputPath = Join-Path $repoRoot ("downloads/anki/" + $deck.FileName)
    Write-Utf8File -Path $outputPath -Content (($rows -join "`n") + "`n")

    $ankiCatalogRows.Add([pscustomobject]@{
        Label = $deck.Label
        FileName = $deck.FileName
        Cards = $rows.Count
        Notes = ($deckNotes | Where-Object { $_.InterviewPairs.Count -gt 0 }).Count
        Description = $deck.Description
    })
}

$ankiReadmeLines = New-Object System.Collections.Generic.List[string]
$ankiReadmeLines.Add("# Anki-Friendly Interview Decks")
$ankiReadmeLines.Add("")
$ankiReadmeLines.Add("> These exports are tab-separated text decks that import directly into Anki without any extra packaging toolchain.")
$ankiReadmeLines.Add("")
$ankiReadmeLines.Add("## Import Steps")
$ankiReadmeLines.Add("")
$ankiReadmeLines.Add("1. Open Anki and choose `File -> Import`.")
$ankiReadmeLines.Add("2. Select one of the `.tsv` files in this folder.")
$ankiReadmeLines.Add("3. Map column 1 to the front field and column 2 to the back field.")
$ankiReadmeLines.Add("4. Use the filename as the deck name, or import into a custom deck.")
$ankiReadmeLines.Add("")
$ankiReadmeLines.Add("## Available Decks")
$ankiReadmeLines.Add("")
$ankiReadmeLines.Add("| Deck | Cards | Source Notes | Description |")
$ankiReadmeLines.Add("|---|---:|---:|---|")
foreach ($row in $ankiCatalogRows) {
    $ankiReadmeLines.Add("| [$($row.Label)](./$($row.FileName)) | $($row.Cards) | $($row.Notes) | $($row.Description) |")
}
$ankiReadmeLines.Add("")
$ankiReadmeLines.Add("These decks are generated from the `Interview Angles` sections in the published topic notes.")

$progressCatalogRows = New-Object System.Collections.Generic.List[object]

$foundationChecklistSections = $learningPath.Foundation | ForEach-Object {
    [pscustomobject]@{
        Title = $_.Title
        Notes = @(
            $_.Notes | ForEach-Object {
                [pscustomobject]@{
                    Label = $_.Title
                    MarkdownLink = "../../$($_.Path)"
                    EstTime = $_.EstTime
                }
            }
        )
    }
}

$foundationChecklistPath = Join-Path $repoRoot "downloads/progress/universal-foundation-checklist.md"
$foundationChecklist = New-MarkdownChecklist `
    -Title "Universal Foundation Progress Tracker" `
    -Summary "Work through Part 1 of `LEARNING_PATH.md`, checking each note as you complete it." `
    -Sections $foundationChecklistSections
Write-Utf8File -Path $foundationChecklistPath -Content $foundationChecklist
$progressCatalogRows.Add([pscustomobject]@{
    Label = "Universal Foundation"
    FileName = "universal-foundation-checklist.md"
    Notes = ($foundationChecklistSections | ForEach-Object { $_.Notes.Count } | Measure-Object -Sum).Sum
    Hours = [math]::Round(($learningPath.Foundation | ForEach-Object { $_.Notes | ForEach-Object { Convert-TimeTextToHours $_.EstTime } } | Measure-Object -Sum).Sum, 1)
})

foreach ($track in $learningPath.Tracks) {
    $sections = New-Object System.Collections.Generic.List[object]

    foreach ($foundationSection in $learningPath.Foundation) {
        $sections.Add([pscustomobject]@{
            Title = $foundationSection.Title
            Notes = @(
                $foundationSection.Notes | ForEach-Object {
                    [pscustomobject]@{
                        Label = $_.Title
                        MarkdownLink = "../../$($_.Path)"
                        EstTime = $_.EstTime
                    }
                }
            )
        })
    }

    $sections.Add([pscustomobject]@{
        Title = $track.Title
        Notes = @(
            $track.Notes | ForEach-Object {
                [pscustomobject]@{
                    Label = $_.Title
                    MarkdownLink = "../../$($_.Path)"
                    EstTime = $_.EstTime
                }
            }
        )
    })

    $checklistPath = Join-Path $repoRoot ("downloads/progress/{0}-checklist.md" -f $track.Slug)
    $checklist = New-MarkdownChecklist `
        -Title ("{0} Progress Tracker" -f $track.Title) `
        -Summary ("Track your progress through the universal foundation and {0}." -f $track.Title) `
        -Sections $sections
    Write-Utf8File -Path $checklistPath -Content $checklist

    $totalHours = 0
    foreach ($section in $sections) {
        foreach ($note in $section.Notes) {
            $totalHours += Convert-TimeTextToHours -Value $note.EstTime
        }
    }

    $progressCatalogRows.Add([pscustomobject]@{
        Label = $track.Title
        FileName = "$($track.Slug)-checklist.md"
        Notes = ($sections | ForEach-Object { $_.Notes.Count } | Measure-Object -Sum).Sum
        Hours = [math]::Round($totalHours, 1)
    })
}

$progressReadmeLines = New-Object System.Collections.Generic.List[string]
$progressReadmeLines.Add("# Progress Tracker Downloads")
$progressReadmeLines.Add("")
$progressReadmeLines.Add("> Generated markdown checklists for learners who want a GitHub-native or offline progress tracker.")
$progressReadmeLines.Add("")
$progressReadmeLines.Add("| Tracker | Notes | Estimated Hours |")
$progressReadmeLines.Add("|---|---:|---:|")
foreach ($row in $progressCatalogRows) {
    $progressReadmeLines.Add("| [$($row.Label)](./$($row.FileName)) | $($row.Notes) | $($row.Hours) |")
}

$learningPathData = [pscustomobject]@{
    GeneratedAt = (Get-Date).ToString("yyyy-MM-dd")
    Foundation = @($learningPath.Foundation | ForEach-Object { $_ })
    Tracks = @($learningPath.Tracks | ForEach-Object { $_ })
}

$assetsDataDir = Join-Path $repoRoot "assets/data"
if (-not (Test-Path -LiteralPath $assetsDataDir)) {
    New-Item -ItemType Directory -Path $assetsDataDir -Force | Out-Null
}

Write-Utf8File -Path (Join-Path $assetsDataDir "knowledge-graph.json") -Content ((ConvertTo-Json $graphData -Depth 8))
Write-Utf8File -Path (Join-Path $assetsDataDir "topic-role-matrix.json") -Content ((ConvertTo-Json $matrixData -Depth 8))
Write-Utf8File -Path (Join-Path $assetsDataDir "learning-path.json") -Content ((ConvertTo-Json $learningPathData -Depth 8))
Write-Utf8File -Path (Join-Path $repoRoot "generated/topic-role-relevance-matrix.md") -Content (($matrixLines -join "`n") + "`n")
Write-Utf8File -Path (Join-Path $repoRoot "downloads/anki/README.md") -Content (($ankiReadmeLines -join "`n") + "`n")
Write-Utf8File -Path (Join-Path $repoRoot "downloads/progress/README.md") -Content (($progressReadmeLines -join "`n") + "`n")

Write-Host "Generated learner assets"
Write-Host ("- Notes indexed: {0}" -f $publishedNotes.Count)
Write-Host ("- Knowledge graph nodes: {0}" -f $graphData.NodeCount)
Write-Host ("- Knowledge graph edges: {0}" -f $graphData.EdgeCount)
Write-Host ("- Role matrix topics: {0}" -f $matrixTopics.Count)
Write-Host ("- Anki exports: {0}" -f $ankiDeckDefinitions.Count)
Write-Host ("- Progress trackers: {0}" -f ($progressCatalogRows.Count))
