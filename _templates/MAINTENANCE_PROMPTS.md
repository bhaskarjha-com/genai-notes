# genai-notes: Master Maintenance Prompt Library

> **HOW TO USE**: Copy any prompt section below. For a fresh AI session, always include **Section 0 (Repository Context)** plus the relevant task-specific section. Each prompt is self-contained and tested to produce 10/10 quality output.

---

## Section 0: Universal Repository Context (ALWAYS INCLUDE)

```
=== REPOSITORY CONTEXT ===

You are maintaining the `genai-notes` repository — a production-grade GenAI engineering manual.

### Repository Fundamentals
- **78 topic notes** across 13 domains: foundations, llms, techniques, agents, applications, tools-and-infra, production, evaluation, inference, ethics-and-safety, multimodal, research-frontiers, prerequisites
- **GitHub**: github.com/bhaskarjha-com/genai-notes
- **CI/CD**: GitHub Actions with mandatory quality gates (verify_repo.ps1, check_freshness.ps1, check_content_compliance.ps1, markdown_quality_check.ps1, check_links.ps1)
- **Deploy**: MkDocs Material theme → GitHub Pages
- **Template**: _templates/notes_template.md is the ground truth for note structure
- **Makefile**: Exists at repo root. `make verify`, `make generate`, `make check-links`, `make check-freshness`, `make build` are all valid commands. Use `pwsh scripts/...` as fallback for Windows without make.
- **Maintenance prompts**: `_templates/MAINTENANCE_PROMPTS.md` — use for any AI-assisted maintenance session

### Mandatory Note Structure (from _templates/notes_template.md)

Every topic note MUST have these sections in this order:
1. YAML frontmatter (title, tags, type, difficulty, status, last_verified, parent, related, source, created, updated)
2. `## ★ TL;DR` — 3 bullet points: What, Why, Key point
3. `## ★ Overview` — Definition, Scope, Significance, Prerequisites subsections
4. `## ★ Deep Dive` — Substantive technical content with ASCII diagrams, tables, math where relevant
5. `## ★ Code & Implementation` — Minimum 1 working Python code example with `# ⚠️ Last tested: YYYY-MM` annotation
6. `## ◆ Formulas & Equations` (if applicable) — LaTeX-formatted formulas in table
7. `## ◆ Quick Reference` — Summary ASCII block or table for at-a-glance use
8. `## ◆ Production Failure Modes` — Table with columns: Failure | Symptoms | Root Cause | Mitigation (minimum 4 rows)
9. `## ○ Gotchas & Common Mistakes` — Bulleted list with ⚠️ prefix
10. `## ○ Interview Angles` — Minimum 2 Q&A pairs with substantive answers (3-5 sentences each)
11. `## ★ Connections` — Table: Relationship | Topics (Builds on, Leads to, Compare with, Cross-domain)
12. `## ★ Recommended Resources` — Table: Type | Resource | Why (minimum 4 resources)
13. `## ★ Sources` — Bulleted citations with URLs

### Quality Standards
- **Code examples**: MANDATORY for all notes, not just procedure type. Must have `# ⚠️ Last tested: YYYY-MM` and pip install comment.
- **Depth minimums (quality signals, not line counts)**:
  - Beginner: ≥1 code example, ≥2 failure mode rows, ≥1 exercise
  - Intermediate: ≥2 code examples, ≥3 failure mode rows, ≥1 exercise
  - Advanced: ≥2 code examples, ≥4 failure mode rows, ≥2 exercises
  - Expert: ≥3 code examples, ≥4 failure mode rows, ≥2 exercises
- **No wiki-links**: ALL links must be standard markdown `[text](path.md)` format — NEVER `[[wiki-link]]`
- **ASCII diagrams**: Use box-drawing characters (┌─┐│└─┘├┤┬┴┼) for all architecture diagrams
- **last_verified frontmatter**: Format is `YYYY-MM` (not full date). Required in ALL published notes.
- **updated frontmatter**: Format is `YYYY-MM-DD` (full date). Update every time you edit a note.
- **Section markers**: ★ for primary sections (TL;DR, Overview, Deep Dive), ◆ for reference sections, ○ for supplementary
- **Heading anchors**: Add `{ #anchor }` to major H2 sections for deep linking

### Style Guide
- Opening ✨ **Bit**: Single memorable insight as blockquote after H1
- Tables preferred for comparisons, failure modes, resource lists
- Bullet points for gotchas and quick references
- No sycophantic language — direct, opinionated, practitioner-focused
- Code blocks: always specify language (`python`, `bash`, `yaml`, etc.)

### Frontmatter Template
---
title: "Topic Title"
tags: [tag1, tag2, tag3]
type: concept|procedure|reference|tutorial
difficulty: beginner|intermediate|advanced|expert
status: draft|published
last_verified: YYYY-MM
parent: "../genai.md"  # or appropriate parent
related: ["note1.md", "note2.md"]
source: "Primary source description"
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

=== END REPOSITORY CONTEXT ===
```

---

## Section 1: Note Creation Prompts

### 1.1: Create a New Topic Note (Full Prompt)

```
=== TASK: CREATE NEW TOPIC NOTE ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Create a new topic note for: **[TOPIC NAME]**

Target file: `[directory]/[filename].md`
Target difficulty: [beginner|intermediate|advanced|expert]
Target length: [150|250|320|420] lines minimum

### Content Requirements

**This note must cover**:
1. [Core concept 1]
2. [Core concept 2]  
3. [Core concept 3]

**The note must include**:
- At minimum 2 working code examples (Python preferred, TypeScript for frontend topics)
- At minimum 1 ASCII architecture diagram
- At minimum 4 Production Failure Modes
- At minimum 2 Interview Angles Q&A pairs (3-5 sentence answers)
- At minimum 4 Recommended Resources (books, papers, tools)
- Last verified: [YYYY-MM]

**Technical accuracy requirements**:
- All model names must reference April 2026 frontier: GPT-5.4, Gemini 3.1 Pro, Claude 4.6 Sonnet, Gemma 4
- All inference tools: vLLM (v2.x), SGLang (v0.4.x), TensorRT-LLM, Triton Inference Server
- All fine-tuning: reference TRL library for GRPO/DPO/ORPO, Unsloth for LoRA efficiency
- OWASP references must use 2025 version (LLM07=System Prompt Leakage, LLM08=Vector/Embedding Weaknesses)
- EU AI Act references must acknowledge Aug 2, 2026 compliance deadline

**Connections to make**:
- parent: [closest parent note]
- related: [3-5 most related existing notes]
- Builds on: [prerequisites]
- Leads to: [what to study next]

### Output Format
Output the complete note as a single markdown code block. No commentary before or after. The YAML frontmatter must be the very first thing in the file.

### Quality Check Before Outputting
Ask yourself:
- [ ] Does every section use the correct marker (★/◆/○)?
- [ ] Are there 0 wiki-links?
- [ ] Is `last_verified` in YYYY-MM format?
- [ ] Do all internal links use standard markdown format with correct relative paths?
- [ ] Is the note self-contained (readable without other notes)?
- [ ] Do code examples include `# ⚠️ Last tested: YYYY-MM`?
- [ ] Are all model names current (April 2026)?

=== END TASK ===
```

### 1.2: Create a Career Role Guide (Full Prompt)

```
=== TASK: CREATE CAREER ROLE GUIDE ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Create a career role guide for: **[ROLE NAME]**

Target file: `career/roles/[role-filename].md`

### Required Sections (enforced by verify_repo.ps1)
1. `## Role Overview` — One-paragraph summary of what this person does day-to-day
2. `## A Day in the Life` — Realistic narrative of a typical workday
3. `## Skills Breakdown` — Table: Must-Have Skills | Nice-to-Have | Anti-Patterns
4. `## Resume Bullets` — 5 example achievement-oriented resume bullet points
5. `## Take-Home Project` — One realistic 1-week take-home project description
6. `## Interview Preparation` — Common question categories + 3 fully answered Q&A pairs
7. `## Learning Path` — Ordered list of notes from this repo to study, linked
8. `## Onboarding` — First 30/60/90 day plan for someone starting in this role
9. `## Sources` — 3-5 cited sources (job boards, salary surveys, industry reports)

### Data Requirements
- Salary data: US in USD range (e.g., $120K-$250K), India in LPA range (e.g., ₹15-35 LPA)
- Source: Levels.fyi, LinkedIn, Glassdoor, Indeed (March 2026 snapshot)
- Hiring companies: Name at least 5 real companies actively hiring for this role
- Entry requirements: Be specific about years of experience, must-have qualifications
- Career progression: Give 3-4 concrete next roles with timeframe

### Style
- Be specific, not generic. Avoid "strong communication skills" without context.
- Include realistic challenges (what makes this role HARD)
- Include at least one "Common Misconception" about this role

=== END TASK ===
```

### 1.3: Create a Learner Tool (Full Prompt)

```
=== TASK: CREATE LEARNER TOOL ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Create a learner tool: **[TOOL NAME]**
Target file: `learner-tools/[tool-filename].md`

### Tool Requirements
- Must be a functional guide, not aspirational documentation
- If referencing Anki: provide actual CSV/TSV export format, not just "use Anki"
- If referencing graphs: provide the data structure a D3.js visualization would consume
- Include a "How to Use" section that's step-by-step (5+ steps)
- Include what success looks like (measurable outcomes)
- Connect to specific notes in the repo (don't reference generic "AI topics")

=== END TASK ===
```

---

## Section 2: Note Maintenance Prompts

### 2.1: Frontier Update — Update Existing Note for Latest Models/Techniques

```
=== TASK: FRONTIER UPDATE ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Update the following note to be current as of April 2026: **[NOTE PATH]**

Here is the current note content:
[PASTE CURRENT NOTE CONTENT]

### What "April 2026 Frontier" Means
- **Language models**: GPT-5.4 (March 2026), Gemini 3.1 Pro (Feb 2026), Claude 4.6 Sonnet, Gemma 4 (April 2, 2026)
- **Open weight**: Gemma 4 (26B MoE, 31B Dense, 256K context), Llama 3.2 variants, Qwen 3 series
- **Inference engines**: vLLM v2.x (PagedAttention standard), SGLang v0.4.x (RadixAttention for prefix workloads)
- **RAG techniques**: Late Chunking, Contextual Retrieval, CRAG, Adaptive RAG, Hybrid Search + RRF standard
- **Fine-tuning**: GRPO for reasoning tasks, DPO for alignment, ORPO for efficient unified, RLVR for verifiable rewards
- **Agentic protocols**: MCP v1.0 (Agent-to-Tool, Linux Foundation), A2A v1.0 (Agent-to-Agent), ADK (Google)
- **Security**: OWASP LLM Top 10 **2025** — LLM07=System Prompt Leakage, LLM08=Vector/Embedding Weaknesses
- **Regulation**: EU AI Act Aug 2, 2026 compliance deadline for Annex III (high-risk); Digital Omnibus in negotiations
- **Agent memory**: Episodic + Semantic + Procedural + Graph layers; Mem0, Letta frameworks
- **Benchmarks**: ARC-AGI-2, OSWorld (agentic), SWE-bench Verified (coding), LOCOMO (agent memory)
- **Inference optimization**: EAGLE-3/P-EAGLE (speculative decoding), P/D Disaggregation (Prefill-Decode separation)

### Update Protocol
1. Identify all model names and verify against April 2026 frontier above
2. Identify all technique claims and verify currency (3+ months = likely needs update for fast-moving topics)
3. Update code examples: ensure `# ⚠️ Last tested: 2026-04` annotations
4. Add any missing frontier techniques that belong in this note's scope
5. Update `updated:` frontmatter to `2026-04-15`
6. Update `last_verified:` to `2026-04`
7. Do NOT change the note's structural sections or teaching style — only update content

### What NOT to Change
- The section structure (preserve all ★/◆/○ sections)
- Working code examples that are still technically valid
- Historical context (the history of how a technique evolved is valuable)
- Internal links to other notes

### Output
Return the COMPLETE updated note. Highlight what you changed with a short comment block at the TOP of your response (before the note):
```
<!-- CHANGES MADE:
1. Updated model names in Quick Reference: GPT-5.4, Gemini 3.1 Pro
2. Added Late Chunking to RAG techniques
3. Updated OWASP references to 2025 list
4. Updated code example tested date to 2026-04
-->
```

Then paste the complete updated note.

=== END TASK ===
```

### 2.2: Depth Improvement — Expand a Thin Note

```
=== TASK: DEPTH IMPROVEMENT ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Expand the following note to meet "Advanced" quality standards: **[NOTE PATH]**

Current length: [X] lines (target: 280+ lines for advanced difficulty)

Here is the current note:
[PASTE CURRENT NOTE CONTENT]

### Expansion Requirements

**Add or expand**:
1. Deep Dive: Add at least 2 new substantive subsections with technical depth
2. Code examples: Add at minimum 1 more code example (prefer different pattern than existing)
3. Production Failure Modes: Expand to minimum 5 rows with specific symptoms/root causes
4. Hands-On Exercises: Add at minimum 2 exercises (30 min each) with clear steps and expected output
5. Interview Angles: Add at minimum 1 more Q&A pair
6. ASCII diagram: Add or improve visual representation of the key architecture/concept

**Maintain**:
- All existing content (add, don't replace)
- Existing code examples (they may be correct and tested)
- Existing internal links

**Style Guide for Expansion**:
- Each new section should follow the same opinionated, practitioner tone
- Add production nuance: "In practice..." "At scale..." "The gotcha here is..."
- New code examples should show the NEXT level of complexity beyond existing examples
- Failure modes should be specific enough that an on-call engineer would recognize the symptom

=== END TASK ===
```

### 2.3: Template Compliance Audit

```
=== TASK: TEMPLATE COMPLIANCE AUDIT ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Audit the following note for template compliance and fix ALL violations: **[NOTE PATH]**

Here is the current note:
[PASTE CURRENT NOTE CONTENT]

### Compliance Checklist

For each item below, state: ✅ PASS | ❌ FAIL | 🔧 FIXED

**Frontmatter**:
- [ ] Has all required fields: title, tags, type, difficulty, status, last_verified, parent, related, source, created, updated
- [ ] last_verified is YYYY-MM format
- [ ] updated is YYYY-MM-DD format
- [ ] status is "draft" or "published" (no other values)
- [ ] parent link resolves (is a real file in the repo)
- [ ] related links are standard markdown paths (not wiki-links, not broken)

**Structure**:
- [ ] ★ TL;DR section present
- [ ] ★ Overview section with Definition, Scope, Significance, Prerequisites subsections
- [ ] ★ Deep Dive section with substantive content
- [ ] ★ Code & Implementation section with at least 1 code block
- [ ] ◆ Quick Reference section
- [ ] ◆ Production Failure Modes table (min 4 rows, all 4 columns)
- [ ] ○ Gotchas & Common Mistakes (min 3 items with ⚠️)
- [ ] ○ Interview Angles (min 2 Q&A pairs with substantive answers)
- [ ] ★ Connections table (Builds on, Leads to, Compare with, Cross-domain)
- [ ] ★ Recommended Resources table (min 4 items with Type, Resource, Why)
- [ ] ★ Sources section

**Quality**:
- [ ] Zero wiki-links anywhere in the note
- [ ] All code examples have # ⚠️ Last tested: YYYY-MM comment
- [ ] Opening ✨ **Bit** blockquote present
- [ ] Section markers are correct (★/◆/○)

**Output**: Return the fixed note in full, with the compliance checklist above your response.

=== END TASK ===
```

### 2.4: Security Note Refresh

```
=== TASK: SECURITY NOTE REFRESH ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Refresh the security-related note to current standards: **[NOTE PATH]**

Here is the current note:
[PASTE CURRENT NOTE CONTENT]

### Security Current-State References (April 2026)

**OWASP LLM Top 10 (2025 — CURRENT)**:
- LLM01: Prompt Injection (expanded — now includes indirect/environmental injection)
- LLM02: Sensitive Information Disclosure
- LLM03: Supply Chain Vulnerabilities
- LLM04: Data and Model Poisoning (training data + embedding poisoning merged)
- LLM05: Improper Output Handling
- LLM06: Excessive Agency
- LLM07: System Prompt Leakage (NEW in 2025)
- LLM08: Vector and Embedding Weaknesses (NEW in 2025 — RAG-specific)
- LLM09: Misinformation (replaces "Overreliance")
- LLM10: Unbounded Consumption (replaces "Model Theft" + "Model DoS" merged)

**2023 Categories NO LONGER IN LIST**:
- "Insecure Plugin Design" — removed (merged into Supply Chain/Agency)
- "Overreliance" — renamed to "Misinformation"
- "Model Theft" — renamed to "Unbounded Consumption"
- "Model Denial of Service" — merged into "Unbounded Consumption"

**Correct Source URLs**:
- OWASP Top 10 for LLM Apps 2025: https://owasp.org/www-project-top-10-for-large-language-model-applications/
- OWASP GenAI Security Project: https://genai.owasp.org/

**EU AI Act (April 2026 Status)**:
- High-risk AI (Annex III): Aug 2, 2026 compliance deadline ← PRIMARY DATE
- Transition for pre-existing systems: Aug 2, 2027
- Digital Omnibus (potential timeline adjustments): still in trilogue negotiations as of April 2026
- NIST AI RMF 1.0: https://airc.nist.gov/AI_RMF_Playbook

### Specific Fix Instructions

1. Replace any 2023 OWASP category names with correct 2025 names
2. Add LLM07 (System Prompt Leakage) and LLM08 (Vector/Embedding Weaknesses) as detailed entries if missing
3. Update all OWASP source URLs to 2025 versions
4. Update EU AI Act section with Digital Omnibus nuance
5. Update `updated:` to `2026-04-15` and `last_verified:` to `2026-04`

=== END TASK ===
```

---

## Section 3: CI/CD Maintenance Prompts

### 3.1: Fix Broken Links

```
=== TASK: FIX BROKEN LINKS ===

[PASTE SECTION 0 FIRST]

### Context
The CI pipeline (`verify_repo.ps1`) reported these broken links:
[PASTE BROKEN LINK OUTPUT FROM verify_repo.ps1]

### Fix Protocol
1. For each broken link, determine the CORRECT target file path
2. The most common causes:
   - File renamed (use `git log --all --follow` to trace renames)
   - File moved to different directory
   - Link uses wrong relative path (count `../` levels incorrectly)
   - Anchor heading changed (the `#heading-anchor` part)
3. Fix the link in the source file
4. Do NOT rename files to fix links — always fix the link, not the target
5. After fixes, all links should resolve

### Output
For each broken link, provide:
- Original link text
- Correct replacement
- File where the change was made

=== END TASK ===
```

### 3.2: Add New Quality Gate to CI

```
=== TASK: ADD CI QUALITY GATE ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Add a new quality gate to enforce: **[RULE DESCRIPTION]**

### Integration Points
The CI pipeline has these files:
- `.github/workflows/lint.yml` — orchestrates all quality checks
- `scripts/verify_repo.ps1` — structural validation (links, sections, wiki-links)
- `scripts/check_content_compliance.ps1` — content rule validation
- `scripts/check_freshness.ps1` — date-based freshness checks
- `scripts/markdown_quality_check.ps1` — pure markdown formatting checks

### Implementation Requirements
1. Determine which script the new check belongs in
2. Write the PowerShell check logic
3. Add appropriate error message (describe the violation clearly)
4. Add the check to the failing condition (`$failures -gt 0 → exit 1`)
5. If adding a new script: add it as a step in lint.yml

### Testing
After implementing, test locally:
```powershell
cd d:\dev\pro\genai-notes
pwsh scripts/verify_repo.ps1  # Should still exit 0
pwsh scripts/[modified-script].ps1  # Should exit 0 with passing notes
# Intentionally break a rule and verify the script exits 1
```

=== END TASK ===
```

### 3.3: Cross-Platform Script Fix

```
=== TASK: CROSS-PLATFORM SCRIPT FIX ===

[PASTE SECTION 0 FIRST]

### Context
A CI script produces different output on Windows PowerShell 5.1 vs Linux PowerShell Core 7.x.

**The issue**:
[DESCRIBE THE SPECIFIC DISCREPANCY]

**Root cause patterns to check**:
1. JSON serialization order (use custom recursive serializer, not ConvertTo-Json which is non-deterministic)
2. Line ending differences (\r\n vs \n) — use explicit `-NoNewline` and `-Encoding UTF8NoBOM`
3. Sort order: PowerShell sort is locale-sensitive. Use `-CaseSensitive` or ordinal comparison
4. File path separators: can be `\` or `/` — normalize with `[System.IO.Path]::GetFullPath()`
5. Date parsing: use `[datetime]::ParseExact()` with explicit format, not `Get-Date` parsing

**The fix should**:
- Produce byte-identical output on both platforms
- Include a comment explaining WHY the fix is needed
- Be tested with: `pwsh -Command "& scripts/[script].ps1"` on both targets

=== END TASK ===
```

---

## Section 4: Repository-Level Operations

### 4.1: Add New Domain (New Directory + Notes)

```
=== TASK: ADD NEW DOMAIN ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Add a new topic domain to the repository: **[DOMAIN NAME]**

New directory: `[directory-name]/`
Expected notes: [list 3-5 planned notes]

### Required Actions
1. Create the directory
2. Create a `README.md` for the directory (see existing directory READMEs for format)
3. Create the first note (highest priority topic in the domain)
4. Add the directory to:
   - `mkdocs.yml` nav section (alphabetically)
   - `hooks/stage_docs.py` PUBLIC_DIRS list
   - `scripts/verify_repo.ps1` $standardNoteDirs list
   - `scripts/check_freshness.ps1` $ContentDirs list
   - `scripts/generate_learning_assets.ps1` if applicable
5. Add links from `genai.md` scope map to the new notes
6. Add entries in `LEARNING_PATH.md` for the appropriate tracks

### Quality Check
- [ ] All notes follow the template
- [ ] Directory added to all 4 required config locations
- [ ] genai.md updated
- [ ] LEARNING_PATH.md updated
- [ ] verify_repo.ps1 passes after additions

=== END TASK ===
```

### 4.2: Batch Audit (Audit Multiple Notes)

```
=== TASK: BATCH AUDIT ===

[PASTE SECTION 0 FIRST]

### Your Specific Task
Audit the following notes for accuracy, depth, and frontier alignment:

Notes to audit:
1. [note path 1]
2. [note path 2]
3. [note path 3]

[PASTE EACH NOTE CONTENT]

### Audit Criteria

For each note, score 1-10 on:
- **Accuracy**: Are all technical claims correct for April 2026?
- **Depth**: Is there enough content for the stated difficulty level?
- **Frontier alignment**: Does it cover 2026-standard techniques?
- **Template compliance**: All required sections present?
- **Code quality**: Examples tested and annotated?

### Output Format

For each note:
```
## Note: [path]
**Score**: Accuracy X/10 | Depth Y/10 | Frontier Z/10 | Template A/10 | Code B/10
**Overall**: X.X/10

**Critical issues** (must fix):
- [issue 1]

**Improvement opportunities** (should fix):
- [issue 1]

**What's excellent** (preserve):
- [strength 1]
```

Then provide a prioritized fix list across all notes.

=== END TASK ===
```

### 4.3: Full Repository Audit (The Session 1 Audit Prompt)

```
=== TASK: FULL REPOSITORY AUDIT ===

You are an independent technical auditor with deep expertise in GenAI engineering, AI/ML/DL, and software engineering best practices. You have NO relationship with the creator. Your reputation depends on finding problems others miss.

### Repository Overview
- `genai-notes` — a GenAI engineering manual with 78 topic notes, CI/CD quality gates, and career guidance
- GitHub: github.com/bhaskarjha-com/genai-notes
- Standards: OWASP LLM Top 10 (2025), EU AI Act (Aug 2026 compliance), April 2026 frontier models

### Audit Task
Read the provided notes and evaluate the repository on these 14 dimensions:

1. Structural Organization
2. Template Compliance (mandatory sections: ★ TL;DR, ★ Overview, ★ Deep Dive, ★ Connections, ★ Sources)
3. Technical Accuracy (claims, model names, version numbers)
4. Content Depth (line count vs. difficulty, exercise quality)
5. Frontier Relevance (April 2026 — GPT-5.4, Gemini 3.1 Pro, Claude 4.6, Gemma 4, SGLang, GRPO, CRAG)
6. Code Quality (tested, annotated, error handling, TypeScript coverage)
7. CI/CD Robustness (pipeline coverage, exit codes, cross-platform stability)
8. Cross-Referencing (link integrity, related: frontmatter validation)
9. docs/ Build Artifact Handling (correctly gitignored vs tracked)
10. Learner Tool Quality (functional vs aspirational)
11. Interview Preparedness (Q&A depth, production experience signal)
12. Career Guide Quality (accuracy, data freshness mechanism)
13. Writing Quality (clarity, opinionated teaching, good ratio of prose to tables)
14. Consistency (uniform depth across notes at same difficulty level)

### Anti-Sycophancy Rules
- Do NOT begin with "This is impressive..."
- Start with the HARSHEST truth first
- Score 1-10 with 3-5 sentences of rigorous justification per dimension
- Provide a weighted scorecard table
- End with "Top 5 Actions" in priority order

### Output Format
1. Harshest truth (no compliments)
2. 14 dimension scores with justification
3. Summary scorecard table
4. Top 5 Actions

=== END TASK ===
```

---

## Section 5: Research & Verification Prompts

### 5.1: Verify a Technical Claim

```
=== TASK: VERIFY TECHNICAL CLAIM ===

### Claim to Verify
"[EXACT QUOTE OR PARAPHRASE OF CLAIM]"

Found in: [note path], line [N]

### Verification Task
1. Search for authoritative sources confirming or contradicting this claim
2. Check if any relevant papers, documentation, or benchmarks provide more accurate numbers/dates
3. Identify if this claim was true at some point but has since been superseded

### Required Sources
- Minimum 2 authoritative sources (official docs, peer-reviewed papers, or reputable engineering blogs)
- Include publication date for each source (claim must be verified against April 2026 state)

### Output
- **Verdict**: Correct | Partially correct | Outdated | Incorrect
- **Current accurate statement**: [what the claim should say]
- **Sources**: [list with dates and URLs]
- **Suggested fix**: [exact edit to make in the note]

=== END TASK ===
```

### 5.2: Find Missing Frontier Topics

```
=== TASK: FIND MISSING FRONTIER TOPICS ===

[PASTE SECTION 0 FIRST]

### Context
The repository currently covers 78 topic notes across these domains:
[list domains]

### Your Task
Identify the **top 5 topics** that are:
1. Standard knowledge in the April 2026 GenAI engineering landscape
2. NOT currently covered by any note in the repository
3. Expected to be asked about in technical interviews for GenAI engineering roles

For each missing topic, provide:
- **Topic name**: Clear, searchable name
- **Why it belongs**: 2-3 sentences on why an April 2026 GenAI engineer should know this
- **Target domain**: Which existing directory it would go in
- **Target difficulty**: beginner|intermediate|advanced|expert
- **Target length**: estimated line count
- **Prerequisites**: existing notes that must be read first
- **Key concepts to cover**: 5-8 bullet points of essential content

### Domains to Research
Focus especially on: RAG techniques, inference optimization, multi-agent systems, evaluation, security, regulation

=== END TASK ===
```

### 5.3: Model Landscape Refresh

```
=== TASK: MODEL LANDSCAPE REFRESH ===

### Context
The repository contains references to specific models in several notes. These need periodic updates.

Current notes with model references (verify and update all):
- `llms/llm-landscape.md` — comprehensive model comparison
- `llms/reasoning-models.md` — reasoning model lineage
- `llms/llms-overview.md` — full LLM overview

### Verification Task
For each of the following models, confirm: release date, key capabilities, benchmark scores, and whether they're still frontier or superseded.

**Verify these models**:
- GPT-5.4 (OpenAI, March 2026)
- Gemini 3.1 Pro (Google, Feb 2026)
- Claude 4.6 Sonnet (Anthropic, ~March 2026)
- Gemma 4 (Google DeepMind, April 2, 2026)
- DeepSeek-V4 or latest DeepSeek model
- Qwen 3 series (Alibaba)
- Llama 3.2 or latest Meta model

### Output Format
For each model:
- **Status**: Frontier | Capable but mid-tier | Legacy
- **Key specs**: Context window, key benchmarks (ARC-AGI-2, SWE-bench, MMLU if still relevant)
- **Best use case**: When would you choose this model over alternatives?
- **Pricing** (if commercial): Input/output cost per million tokens

Then recommend which model table cells need updating in each affected note.

=== END TASK ===
```

---

## Section 6: Quick Reference — Prompt Assembly Guide

### How to Assemble a Complete Prompt

```
COMPLETE PROMPT = [Section 0: Repository Context] + [Task-Specific Section]

EXAMPLE:
"I need to update the RAG note for 2026 frontier techniques"
→ Paste Section 0 + Section 2.1 (Frontier Update)

"I need to create a new note on GraphRAG"
→ Paste Section 0 + Section 1.1 (Create New Topic Note)

"I need to fix the OWASP note which has 2023 categories"
→ Paste Section 0 + Section 2.4 (Security Note Refresh)

"I need to audit 3 notes before a PR"
→ Paste Section 0 + Section 4.2 (Batch Audit)

"Something wrong with CI on Linux vs Windows"
→ Paste Section 0 + Section 3.3 (Cross-Platform Fix)
```

### Token Budget Guide

| Prompt Type | Approximate Tokens | Notes |
|---|---|---|
| Section 0 only | ~800 tokens | Always include |
| Section 0 + Simple task | ~1,200 tokens | For targeted fixes |
| Section 0 + Medium task | ~1,500-2,000 tokens | Most maintenance tasks |  
| Section 0 + Full note content | ~3,000-8,000 tokens | For note updates |
| Section 0 + Batch audit (3 notes) | ~10,000+ tokens | Use sparingly |

---

*Last updated: 2026-04-15*  
*These prompts are calibrated for the genai-notes repository as of its April 2026 state.*  
*Update this file whenever the template, standards, or frontier changes significantly.*
