# Contributing to GenAI Study Notes

Thank you for helping improve these study notes!

## How to Contribute

1. 🐛 **Error Reports** — Open an issue with the note name and the error
2. 📝 **Content Improvements** — Submit a PR following `_templates/notes_template.md`
3. 🔗 **Better Resources** — Suggest resources for the Sources section of any note
4. 🆕 **New Topics** — Propose via issue (use "new-topic" label)
5. ✅ **Expert Review** — Review advanced notes in your domain of expertise

## What We Don't Accept

- Full rewrites that change the template structure
- Personal opinion pieces (notes should be factual and neutral)
- Promotional or affiliate content
- Notes that don't follow `_templates/notes_template.md`

## Note Quality Standards

Every note should have at minimum:

- **★ TL;DR** — 3-4 bullets (what, why, key point)
- **★ Overview** — Definition, scope, significance, prerequisites
- **★ Deep Dive** — Core knowledge (the main section)
- **★ Connections** — Links to related notes in this repo
- **★ Sources** — Where the information came from

## Note Format

Notes use section markers to indicate priority:

| Marker | Meaning |
|:------:|---------|
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
parent: "[[./parent-topic]]"
related: ["[[./related-topic]]"]
source: "URL or citation"
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
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
4. Regenerate learner assets with `powershell -ExecutionPolicy Bypass -File scripts/generate_learning_assets.ps1`
5. Verify the repo with `powershell -ExecutionPolicy Bypass -File scripts/verify_repo.ps1`
6. Submit a PR with a clear description of what changed and why

## Questions?

Open an issue with the "question" label. We're happy to help!
