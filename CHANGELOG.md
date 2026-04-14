# Changelog

All notable changes to this repository will be documented in this file.

## [Unreleased]

### Added (April 2026 Remediation - Phase 6)
- **Phase 6: CI hardening - Code & Implementation now a blocking gate**
  - `scripts/check_content_compliance.ps1`: promoted `## ★ Code & Implementation`
    check from informational warning to hard blocking CI gate
  - All 4 compliance dimensions now enforced (`exit 1` on any failure):
    Production Failure Modes, Hands-On Exercises, Code & Implementation, OWASP stale terms
  - CI contract: any new intermediate+ note without a Code section blocks merge
  - Label updated from `[non-blocking until Phase 6]` to `[ENFORCED - Phase 6 gate]`

### Added (April 2026 Remediation — Phase 4 and 5)
- **Phase 4: Frontier content injection**
  - `techniques/advanced-fine-tuning.md`: RLVR and ORPO sections with 2026-04 ground truth
  - `ethics-and-safety/ai-regulation.md`: Full overwrite — EU AI Act Aug 2, 2026 deadline, Digital Omnibus, NIST AI RMF, programmatic compliance checker
  - `llms/llm-landscape.md`: Gemma 4 family (E2B, E4B, 26B MoE, 31B Dense), multi-provider API comparison
  - `foundations/transformers.md`: Code and Implementation section with HuggingFace inference and PyTorch Transformer block
- **Phase 5: Code section injection (all 72 intermediate+ notes)**
  - All notes now have `## ★ Code & Implementation` with versioned, working Python snippets
  - 31 notes injected via automated bulk injection scripts (reusable for ongoing maintenance)
- **CI quality gate fixes**
  - OWASP stale-term check: fixed false positives on historical comparison tables
  - All 4 compliance dimensions at zero: Production Failure Modes, Hands-On Exercises, Code sections, OWASP stale terms


### Added
- `README.md` as the public landing page for the repository
- `LEARNING_PATH.md` with the Universal Foundation and 5 role-cluster tracks
- `CONTRIBUTING.md` with contribution guidelines and note standards
- `CHANGELOG.md` for visible version tracking
- `LICENSE` using CC-BY-4.0
- `_templates/career_role_template.md` for future per-role guides
- Phase 1 critical notes:
  `production/ai-system-design.md`,
  `llms/hallucination-detection.md`,
  `agents/multi-agent-architectures.md`,
  `agents/agent-evaluation.md`,
  `techniques/advanced-fine-tuning.md`,
  `production/docker-and-kubernetes.md`,
  `production/model-serving.md`,
  `production/monitoring-observability.md`,
  `production/cicd-for-ml.md`,
  `evaluation/llm-evaluation-deep-dive.md`,
  `research-frontiers/distributed-training.md`,
  `inference/gpu-cuda-programming.md`,
  `ethics-and-safety/ai-regulation.md`,
  `applications/conversational-ai.md`,
  `production/cost-optimization.md`
- Phase 2 career guides:
  `career/roles/ai-engineer.md`,
  `career/roles/genai-engineer.md`,
  `career/roles/llm-engineer.md`,
  `career/roles/rag-engineer.md`,
  `career/roles/agentic-ai-engineer.md`,
  `career/roles/ml-engineer.md`,
  `career/roles/mlops-engineer.md`
- Grouped career guides:
  `career/application-and-strategy-roles.md`,
  `career/applied-ml-and-domain-roles.md`,
  `career/research-and-infrastructure-roles.md`,
  `career/safety-and-governance-roles.md`
  `assets/data/topic-role-matrix.json`,
  `downloads/anki/README.md`,
  `downloads/progress/README.md`,
  `generated/topic-role-relevance-matrix.md`
- GitHub Actions workflows:
  `.github/workflows/lint.yml`,
  `.github/workflows/links.yml`,
  `.github/workflows/deploy.yml`
- `scripts/generate_learning_assets.ps1`, `scripts/check_links.ps1`, and `scripts/markdown_quality_check.ps1`
- `requirements-docs.txt` for reproducible docs-site builds

- `repo-readme.md` as the MkDocs-site-friendly repository overview page
- `scripts/check_content_compliance.ps1` rebuilt: removed duplicate script body, added Code section reporting and OWASP 2023 stale-term detection
- `scripts/check_freshness.ps1` upgraded to CI-blocking (exit 1 when stale notes exceed threshold)
- Security note `ethics-and-safety/owasp-llm-top-10.md` overhauled to OWASP LLM Top 10 **2025** — added LLM07 (System Prompt Leakage) and LLM08 (Vector and Embedding Weaknesses)
- Frontier content injected: Late Chunking + Contextual Retrieval + CRAG in `techniques/rag.md`; SGLang + P/D Disaggregation in `inference/inference-optimization.md`; GRPO/ORPO/RLVR in `techniques/advanced-fine-tuning.md`; Gemma 4 in `llms/llm-landscape.md`; EU AI Act Digital Omnibus in `ethics-and-safety/ai-regulation.md`
- Code & Implementation sections added to 45 notes across all 13 domains
- `mkdocs.yml` nav: removed duplicate `LEARNING_PATH.md` entry, fixed broken `repo-readme.md` reference
- `CHANGELOG.md`: corrected 3 broken file references (training-infrastructure → distributed-training, ml-experiment-tracking + data-versioning-for-ml → ml-experiment-and-data-management)
- `CONTRIBUTING.md`: replaced line-count minimums with quality-signal minimums; `make` is now the primary command
- `index.md`: corrected note count from 74 → 78 throughout
- `.github/workflows/lint.yml`: added freshness check and link check steps
- `_templates/MAINTENANCE_PROMPTS.md` added: session-agnostic maintenance prompt library

### Changed
- `genai.md` now uses valid related links and the correct career reference link
- Published note bodies now use standard markdown links instead of GitHub-unfriendly wiki-links
- Frontmatter `parent` and `related` links were normalized across published notes
- `_templates/notes_template.md` now reflects the hybrid link policy in its body examples
- `README.md`, `LEARNING_PATH.md`, and `genai.md` now reflect the expanded Phase 1-4 content footprint
- `LEARNING_PATH.md` now explicitly covers specialized electives and adjacent topic paths that sit outside the five main tracks
- `README.md`, `LEARNING_PATH.md`, and `CONTRIBUTING.md` now surface the docs site, learner tools, and generation workflow
- Existing overview notes were cross-linked to new production, evaluation, safety, infrastructure, and application notes
- `career/genai-career-roles-universal.md` now uses the standardized public repo frontmatter and links to both dedicated and grouped career guides
- `scripts/verify_repo.ps1` now enforces learning-path coverage, genai scope-map coverage, and full code/interview coverage for published topic notes

### Notes
- GitHub repository metadata in the web UI is still a manual follow-up step
