$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$dirConfig = @(
    @{ Dir = "prerequisites";       Name = "Prerequisites"; Desc = "Math, deep learning, and NLP prerequisites for understanding GenAI." },
    @{ Dir = "foundations";         Name = "Foundations"; Desc = "Transformer architectures, embeddings, tokenization, and representation fundamentals." },
    @{ Dir = "llms";               Name = "Large Language Models"; Desc = "Model behavior, selection, comparison, reasoning, and failure modes." },
    @{ Dir = "techniques";         Name = "Techniques"; Desc = "Prompting, RAG, fine-tuning, function calling, context engineering, and adaptation methods." },
    @{ Dir = "applications";       Name = "Applications"; Desc = "Applied AI product patterns, API design, conversational AI, and code generation." },
    @{ Dir = "tools-and-infra";    Name = "Tools & Infrastructure"; Desc = "Vector databases, distributed systems, cloud services, and data tooling." },
    @{ Dir = "production";         Name = "Production"; Desc = "Serving, LLMOps, CI/CD, monitoring, cost optimization, system design, and reliability." },
    @{ Dir = "evaluation";         Name = "Evaluation"; Desc = "Benchmarks, LLM evaluation deep dives, and system design interview preparation." },
    @{ Dir = "inference";          Name = "Inference"; Desc = "Inference optimization, GPU/CUDA programming, and distributed serving." },
    @{ Dir = "ethics-and-safety";  Name = "Ethics & Safety"; Desc = "AI governance, regulation, OWASP LLM Top 10, adversarial ML, and security." },
    @{ Dir = "multimodal";         Name = "Multimodal"; Desc = "Multimodal AI, computer vision fundamentals, and diffusion models." },
    @{ Dir = "research-frontiers"; Name = "Research Frontiers"; Desc = "Interpretability, scaling laws, research methodology, and paper reading." },
    @{ Dir = "agents";             Name = "AI Agents"; Desc = "Agent architectures, multi-agent systems, agentic protocols, and agent evaluation." },
    @{ Dir = "career";             Name = "Career Guidance"; Desc = "Universal role map, career roles reference, and grouped career guides." },
    @{ Dir = "career\roles";       Name = "Individual Role Guides"; Desc = "Dedicated career guides for 7 core AI/ML roles with learning paths and interview prep." }
)

foreach ($cfg in $dirConfig) {
    $dirPath = Join-Path $repoRoot $cfg.Dir
    if (-not (Test-Path $dirPath)) { continue }

    $notes = Get-ChildItem -Path $dirPath -Filter *.md -File |
        Where-Object { $_.Name -ne "README.md" } |
        Sort-Object Name

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# $($cfg.Name)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("> $($cfg.Desc)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Notes in This Directory")
    [void]$sb.AppendLine("")

    $header = "| Note | Difficulty | Description |"
    $sep = "|------|:----------:|-------------|"
    [void]$sb.AppendLine($header)
    [void]$sb.AppendLine($sep)

    foreach ($note in $notes) {
        $content = [System.IO.File]::ReadAllText($note.FullName, [System.Text.UTF8Encoding]::new($false))
        if (-not $content) { continue }

        $titleMatch = [regex]::Match($content, '(?m)^title:\s*"?(.+?)"?\s*$')
        $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim('"') } else { $note.BaseName }
        $title = $title.Replace([char]0x2014, '-').Replace([char]0x2013, '-').Replace([char]0x2018, "'").Replace([char]0x2019, "'")

        $diffMatch = [regex]::Match($content, '(?m)^difficulty:\s*(\w+)')
        $difficulty = if ($diffMatch.Success) { $diffMatch.Groups[1].Value } else { "" }

        $diffDisplay = "Reference"
        if (-not [string]::IsNullOrWhiteSpace($difficulty)) {
            $diffDisplay = $difficulty.Substring(0,1).ToUpper() + $difficulty.Substring(1)
        }

        $whatMatch = [regex]::Match($content, '(?m)^- \*\*What\*\*:\s*(.+?)$')
        $desc = if ($whatMatch.Success) { $whatMatch.Groups[1].Value.Trim() } else { $title }
        $desc = $desc.Replace("|", "/")
        # Sanitize Unicode chars that trigger mojibake detection
        $desc = $desc.Replace([char]0x2014, '-')   # em-dash
        $desc = $desc.Replace([char]0x2013, '-')   # en-dash
        $desc = $desc.Replace([char]0x2018, "'")   # left single quote
        $desc = $desc.Replace([char]0x2019, "'")   # right single quote
        $desc = $desc.Replace([char]0x201C, '"')   # left double quote
        $desc = $desc.Replace([char]0x201D, '"')   # right double quote
        $desc = $desc.Replace([string][char]0x2026, '...') # ellipsis

        $row = "| [$title]($($note.Name)) | $diffDisplay | $desc |"
        [void]$sb.AppendLine($row)
    }

    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")

    $upPath = if ($cfg.Dir -match '\\') { "../../" } else { "../" }
    [void]$sb.AppendLine("For the full curriculum, see [LEARNING_PATH.md](${upPath}LEARNING_PATH.md).")
    [void]$sb.AppendLine("")

    $readmePath = Join-Path $dirPath "README.md"
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($readmePath, $sb.ToString(), $utf8NoBom)
    Write-Host "Generated: $($cfg.Dir)/README.md ($($notes.Count) notes)"
}

Write-Host "`nAll directory READMEs generated."
