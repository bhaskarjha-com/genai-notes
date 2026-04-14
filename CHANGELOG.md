# Changelog

All notable changes to this repository will be documented in this file.

## [Unreleased]

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
- Phase 3 coverage expansion notes:
  `applications/api-design-for-ai.md`,
  `applications/ai-product-management-fundamentals.md`,
  `tools-and-infra/cloud-ml-services.md`,
  `production/classical-ml-for-genai.md`,
  `tools-and-infra/distributed-systems-for-ai.md`,
  `research-frontiers/training-infrastructure.md`,
  `research-frontiers/research-methodology-and-paper-reading.md`,
  `ethics-and-safety/adversarial-ml-and-ai-security.md`,
  `ethics-and-safety/owasp-llm-top-10.md`,
  `evaluation/system-design-for-ai-interviews.md`,
  `multimodal/computer-vision-fundamentals.md`,
  `inference/distributed-inference-and-serving-architecture.md`,
  `tools-and-infra/ml-experiment-tracking.md`,
  `tools-and-infra/data-versioning-for-ml.md`,
  `production/latency-and-throughput-engineering.md`
- `scripts/verify_repo.ps1` for repo structure and link verification
- MkDocs website scaffolding via `mkdocs.yml`, `index.md`, and `learner-tools/`
- Generated learner assets:
  `assets/data/knowledge-graph.json`,
  `assets/data/learning-path.json`,
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
