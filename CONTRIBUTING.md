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

### Depth Minimums

| Difficulty | Minimum Length | Code Examples |
|:----------:|:--------------:|:-------------:|
| Beginner | 200 lines | ≥1 |
| Intermediate | 400 lines | ≥2 |
| Advanced | 500 lines | ≥2 |
| Expert | 500 lines | ≥3 |

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
tags: [relevant, tags]
type: concept|tool|theory|procedure|entity|reference
difficulty: beginner|intermediate|advanced|expert
status: draft|published
last_verified: YYYY-MM
parent: "[[./parent-topic]]"
related: ["[[./related-topic]]"]
source: "URL or citation"
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

> **`last_verified`** (new): The month when time-sensitive content (model names, framework versions, benchmark scores) was last fact-checked.

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

| Location | Format | Why |
|----------|--------|-----|
| Frontmatter (`parent`, `related`) | `[[wiki-link]]` | Metadata; benefits Obsidian graph view |
| Body text, Connections, Scope tables | `[text](path.md)` | Must render as clickable links on GitHub |

## Submitting Changes

1. Fork the repo
2. Create a branch (`feature/topic-name` or `fix/issue-description`)
3. Make your changes following the template and standards above
4. Regenerate learner assets: `make generate` (or `pwsh scripts/generate_learning_assets.ps1`)
5. Verify the repo: `make verify` (or `pwsh scripts/verify_repo.ps1`)
6. Submit a PR with a clear description of what changed and why

## Questions?

Open an issue with the "question" label. We're happy to help!
