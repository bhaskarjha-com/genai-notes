# GenAI Engineering Manual — Full Repository Audit Prompt

> **Purpose**: Copy-paste this prompt into a new AI session to get a production-grade audit of this repository. It encodes all the structural knowledge, quality gates, and template compliance requirements so the auditor doesn't waste time rediscovering them.
>
> **Last updated**: 2026-04-15
> **Last audit**: 2026-04-15 (all 5 CI gates clean)

---

## The Prompt

```
# Repository Audit: Structural + Content + Freshness

## Context You Must Know First

This is a **GenAI engineering manual** — 82+ topic notes covering prerequisites
through frontier research, organized for career-track learning. It is NOT a blog,
NOT a tutorial collection. It is a structured reference with automated quality
enforcement.

Before evaluating content, you MUST understand the enforcement layer:

### CI Quality Gates (run these FIRST)
1. `scripts/verify_repo.ps1` — Master gate: link integrity, template compliance,
   code/interview coverage, LEARNING_PATH numbering, scope map completeness
2. `scripts/check_links.ps1` — All markdown links resolve, no wiki-links
3. `scripts/check_depth.ps1` — Minimum substantive code lines per difficulty level
4. `scripts/check_content_compliance.ps1` — Mandatory sections present in all
   intermediate+ notes
5. `scripts/markdown_quality_check.ps1` — Trailing whitespace, tabs, fence issues,
   mojibake

**Run all 5 scripts and report results before any subjective scoring.**

### Note Template (every intermediate+ note MUST have):
- Frontmatter: title, tags, type, difficulty, status, last_verified, parent,
  related, source, created, updated
- ## ★ TL;DR (What/Why/Key point)
- ## ★ Overview (Definition/Scope/Significance/Prerequisites)
- ## ★ Deep Dive (the core content)
- ## ◆ Production Failure Modes (table: Failure|Symptoms|Root Cause|Mitigation)
- ## ○ Interview Angles (Q/A pairs)
- ## ★ Code & Implementation (working, versioned Python with pip install + ⚠️ markers)
- ## ◆ Hands-On Exercises (Goal/Time/Steps/Expected Output)
- ## ★ Connections (table: Builds on|Leads to|Compare with|Cross-domain)
- ## ★ Recommended Resources
- ## ★ Sources

### Registration Checklist (every published note must appear in ALL THREE):
1. `mkdocs.yml` nav section
2. `genai.md` scope map table
3. `LEARNING_PATH.md` (appropriate track + sequential numbering)

---

## Your Role

Independent technical auditor. Deep GenAI expertise. You are being paid to find
problems, not give compliments.

## Evaluation Dimensions (score 1-10 each, with evidence)

### 1. Structural Integrity
- Do all 5 CI scripts pass clean? (If not, list every failure)
- Are all notes registered in all 3 locations?
- Are frontmatter fields complete and consistent?
- Is LEARNING_PATH numbering sequential per track?

### 2. Template Compliance
- Does every intermediate+ note have ALL mandatory sections?
- Are Production Failure Modes tables populated (not generic)?
- Are Interview Q&As substantive (not yes/no trivia)?
- Do Code sections have versioned, runnable examples?

### 3. Technical Accuracy (REQUIRES WEB SEARCH)
- For each note, verify 3 key claims against current documentation:
  - Are API versions current? (OpenAI, Anthropic, Google, HuggingFace)
  - Are framework versions pinned correctly? (vLLM, transformers, etc.)
  - Are architectural claims still accurate? (model sizes, capabilities)
- Flag any claim that contradicts current official documentation
- Check for outdated model names, deprecated APIs, wrong parameter names

### 4. Content Depth & Substance
- Run check_depth.ps1 — are code blocks substantive or boilerplate?
- Are Deep Dive sections genuinely deep or surface-level summaries?
- Do notes cover failure modes from real production experience?
- Is there intellectual honesty about limitations and unknowns?

### 5. Frontier Coverage (2026 gaps)
- Are these topics covered? If not, flag as gaps:
  [ ] AI coding agents (Cursor, Devin, Codex CLI, Claude Code)
  [ ] Structured outputs & constrained generation
  [ ] MCP security & tool trust
  [ ] Test-time compute & inference scaling
  [ ] Reasoning model architectures (o-series, DeepSeek-R1)
  [ ] Context engineering (beyond prompt engineering)
  [ ] Agentic protocols (MCP, A2A, ADK)
  [ ] P/D disaggregation for inference
  [ ] AI regulation (EU AI Act Aug 2026 enforcement)

### 6. Learner Experience
- Can someone navigate from README → LEARNING_PATH → first note smoothly?
- Are difficulty levels accurate? (beginner actually beginner?)
- Do prerequisite chains make sense?
- Are the Anki decks and progress trackers generated and current?

### 7. Code Quality
- Do code examples actually run? (check imports, API patterns)
- Are error handling patterns included?
- Are ⚠️ version markers present on every code block?
- Is there a mix of API-calling code AND pure-logic code?

### 8. Documentation & DevOps
- Is README.md useful for a first-time visitor?
- Is CHANGELOG.md maintained?
- Does the CI pipeline (lint.yml, deploy.yml) cover all quality gates?
- Are historical scripts marked as such?

---

## Output Format

1. **CI Script Results** — Run all 5, report exact output
2. **Dimension Scores** — 1-10 each with 3-5 sentence justification + evidence
3. **Factual Errors Found** — List with note path, claim, correction, source URL
4. **Structural Violations** — Anything not caught by CI
5. **Missing Topics** — Prioritized by importance to the target audience
6. **Top 10 Actions** — Ordered by impact, with specific file paths and changes
7. **Summary Scorecard Table**

## Anti-Sycophancy Rules
- Do NOT begin with compliments
- If a score wants to be above 8, triple-check with evidence
- "Works for me" is not evidence — verify against official docs
- If you can't verify a claim, say "UNVERIFIED" not "looks correct"
```

---

## Why This Prompt Is Better

| Original Prompt Problem | This Prompt's Fix |
|---|---|
| No awareness of CI scripts | Auditor runs all 5 gates first — finds real issues, not imagined ones |
| No template specification | Auditor knows exact sections to check — no guessing |
| No registration checklist | Catches notes missing from mkdocs.yml/genai.md/LEARNING_PATH |
| "Be brutal" without structure | 8 specific dimensions with evidence requirements |
| No web search directive | Dimension 3 explicitly requires verification against current docs |
| Vague "find problems" | Specific: frontmatter fields, API versions, numbering, depth |
| One-shot output | Structured output: CI results → scores → errors → actions |
| No frontier topic checklist | Dimension 5 has explicit gap checklist |
