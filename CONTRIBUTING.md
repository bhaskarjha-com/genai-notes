# Contributing to GenAI Study Notes

Thank you for helping improve these study notes!

## How to Contribute

1. 🐛 **Error Reports** — Open an issue with the note name and the error
2. 📝 **Content Improvements** — Submit a PR following `_templates/notes_template.md`
3. 📚 **Better Resources** — Add curated items to the `★ Recommended Resources` section
4. 🆕 **New Topics** — Propose via issue (use "new-topic" label)
5. ✅ **Expert Review** — Review advanced notes in your domain of expertise

## What We Don't Accept

- Full rewrites that change the template structure
- Personal opinion pieces (notes should be factual and neutral)
- Promotional or affiliate content
- Notes that don't follow `_templates/notes_template.md`

## Note Quality Standards

### Mandatory Sections (★)

Every published note **must** have:

- **★ TL;DR** — 3-4 bullets (what, why, key point)
- **★ Overview** — Definition, scope, significance, prerequisites
- **★ Deep Dive** — Core knowledge (the main section)
- **★ Code & Implementation** — **Mandatory** for `type: procedure` or `type: tool`. Strongly encouraged for all others.
- **★ Connections** — Links to related notes in this repo
- **★ Recommended Resources** — 5-8 curated learning resources with specific "Why" for each
- **★ Sources** — Where the information came from

### Conditional Sections (◆)

Include when the topic calls for it — do **not** omit just because they take effort:

- **◆ Production Failure Modes** — Required for all production-track and intermediate+ notes
- **◆ Hands-On Exercises** — 2+ progressive exercises for intermediate+ notes
- **◆ Quick Reference** — Cheat sheet format
- **◆ Terminology** — Domain-specific terms
- **◆ Types & Classifications** — When applicable

### Depth Requirements

Every note must meet these quality signals (not arbitrary line counts):

| Difficulty | Code Examples | Production Failure Modes | Exercises |
|:----------:|:-------------:|:------------------------:|:---------:|
| Beginner   | ≥1            | ≥2 rows                  | ≥1        |
| Intermediate | ≥2          | ≥3 rows                  | ≥1        |
| Advanced   | ≥2            | ≥4 rows                  | ≥2        |
| Expert     | ≥3            | ≥4 rows                  | ≥2        |

## Section Markers

| Marker | Meaning |
|:------:|---------:|
| ★ | **Always include** — Core sections every note must have |
| ◆ | **Include when relevant** — Add when the topic calls for it |
| ○ | **Optional** — Nice to have, not required |

## Frontmatter

Every note starts with YAML frontmatter:

```yaml
---
title: "Topic Name"
aliases: ["Short Name", "Acronym"]
tags: [relevant, tags]
type: concept|tool|theory|procedure|entity|reference
difficulty: beginner|intermediate|advanced|expert
status: draft|published
last_verified: YYYY-MM
parent: "./parent-topic.md"
related: ["./related-topic.md"]
source: "URL or citation"
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

> **`aliases`**: Short names, acronyms, or alternative terms (e.g., `["RAG", "Retrieval-Augmented Generation"]`). Powers Obsidian Quick Open (`Ctrl+O`) search.

> **`last_verified`**: The month when time-sensitive content (model names, framework versions, benchmark scores) was last fact-checked.

## Code Standards

All code samples must follow these standards:

- **Every code block** must include: imports, setup, expected output indication
- **API-calling code** must include: `# ⚠️ Last tested: YYYY-MM | Requires: lib>=version`
- **Non-runnable code** must include: `# PSEUDOCODE — illustrative, not runnable as-is`
- **Pip install comment** before code blocks: `# pip install library>=version`

## Recommended Resources Format

```markdown
| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Paper Name](URL) | Specific reason for THIS topic |
| 📘 Book | Book Name, Chapter N | What this chapter uniquely covers |
| 🎓 Course | [Course Name](URL) | Why this course, which modules |
| 🎥 Video | [Video Title](URL) | What makes this explanation good |
| 🔧 Hands-on | [Repo/Tutorial](URL) | What you'll build or learn |
```

## Link Format

All links — frontmatter and body — use standard markdown format:

| Location | Format | Example |
|----------|--------|----------|
| Frontmatter (`parent`) | Relative path string | `parent: "../genai.md"` |
| Frontmatter (`related`) | YAML list of relative paths | `related: ["./related-topic.md"]` |
| Body text, Connections, Scope tables | Standard markdown link | `[display text](path.md)` |

> **Note**: Wiki-links (`[[...]]`) are **not used** anywhere in this repo. The CI pipeline (`check_links.ps1`) will reject them.

## Submitting Changes

1. Fork the repo
2. Create a branch (`feature/topic-name` or `fix/issue-description`)
3. Make your changes following the template and standards above
4. Regenerate learner assets: `pwsh scripts/generate_learning_assets.ps1`
5. Verify the repo: `pwsh scripts/verify_repo.ps1`
6. Submit a PR with a clear description of what changed and why

## Questions?

Open an issue with the "question" label. We're happy to help!

---

## For AI-Assisted Maintenance

A complete library of ready-to-use maintenance prompts is available in the repository at `_templates/MAINTENANCE_PROMPTS.md`.

It contains session-agnostic prompts for:
- Creating new notes from scratch
- Updating notes for frontier accuracy
- Fixing template compliance
- Adding code sections to existing notes
- CI/CD and structural fixes
- Full repository audits

Always include **Section 0 (Repository Context)** from that file when starting a fresh AI session on this repo.
