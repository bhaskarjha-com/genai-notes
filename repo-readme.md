# GenAI Study Notes

> Comprehensive, structured study notes for Generative AI — from prerequisites to frontier research. **78 curriculum-ordered notes.** Career-mapped to 31 AI/ML roles.

📖 **[Browse the full interactive docs site →](https://bhaskarjha-com.github.io/genai-notes/)**

---

## What This Is

This repository is a public collection of structured GenAI study notes in plain markdown. Each topic is designed as a self-contained 30–60 minute study session that combines theory, code, terminology, comparisons, gotchas, and interview angles.

The repo is organized by learning sequence rather than alphabetically. You can study linearly, jump in by role, or use individual notes as a portable reference in GitHub, Obsidian, or any markdown editor.

---

## Quick Start

```bash
git clone https://github.com/bhaskarjha-com/genai-notes.git
cd genai-notes
```

Then pick your path:

| Path | Start Here | Best For |
|------|-----------|----------|
| **Linear study** | [LEARNING_PATH.md](LEARNING_PATH.html) | Systematic coverage, universal foundation + role tracks |
| **Role-based study** | [career/roles/](career/roles/README.md) | Jump to your target role's curated learning path |
| **Topic reference** | [genai.md](genai.html) | Browse the full scope map and dive into any topic |

---

## How to Use

### Path 1: Linear Study

Start with [LEARNING_PATH.md](LEARNING_PATH.html). It contains the universal foundation plus 5 role-cluster tracks.

### Path 2: Role-Based Study

Read [career/genai-career-roles-universal.md](career/genai-career-roles-universal.html), then jump into one of the dedicated role guides:

- [AI Engineer](career/roles/ai-engineer.html)
- [Generative AI Engineer](career/roles/genai-engineer.html)
- [LLM Engineer](career/roles/llm-engineer.html)
- [RAG Engineer](career/roles/rag-engineer.html)
- [Agentic AI Engineer](career/roles/agentic-ai-engineer.html)
- [ML Engineer](career/roles/ml-engineer.html)
- [MLOps / LLMOps Engineer](career/roles/mlops-engineer.html)

### Path 3: Topic Reference

Use [genai.md](genai.html) as the root GenAI overview, then browse the folders below for deeper dives.

---

## What's Covered

Current snapshot: **78 topic notes** across 13 knowledge directories, a root [genai.md](genai.html) overview, dedicated and grouped career guidance, generated learner tooling, and reusable templates.

```text
genai-notes/
├── prerequisites/        (6 notes)   math, deep learning, and NLP prerequisites
├── foundations/          (8 notes)   transformer and representation fundamentals
├── llms/                 (4 notes)   model behavior, selection, and failure modes
├── techniques/           (13 notes)  prompting, RAG, fine-tuning, agents, and adaptation
├── applications/         (6 notes)   applied product and interface patterns
├── tools-and-infra/      (5 notes)   tooling, data, cloud, and systems foundations
├── production/           (13 notes)  serving, ops, CI/CD, reliability, and system design
├── evaluation/           (4 notes)   benchmarks, deep-dive evaluation, interview prep
├── inference/            (3 notes)   optimization, GPUs, and distributed serving
├── ethics-and-safety/    (5 notes)   governance, regulation, and security
├── multimodal/           (3 notes)   multimodal and computer-vision fundamentals
├── research-frontiers/   (3 notes)   interpretability, training, and research practice
├── agents/               (5 notes)   AI agents, multi-agent, protocols, and evaluation
├── career/                           universal role map, dedicated + grouped guides
├── learner-tools/                    docs-site learner tooling pages
├── downloads/                        generated decks and progress checklists
├── generated/                        generated markdown reference outputs
├── assets/                           site CSS, JS, and generated JSON data
├── _templates/                       note and career-guide templates
├── genai.md                          root GenAI overview note
└── root docs                         README, LEARNING_PATH, CONTRIBUTING, CHANGELOG, LICENSE
```

---

## Study Tools

- [Anki-friendly interview decks](downloads/anki/README.html)
- [Progress tracker downloads](downloads/progress/README.html)
- [Topic × role relevance matrix](generated/topic-role-relevance-matrix.html)
- [Interactive docs-site tooling](learner-tools/knowledge-graph.html) — knowledge graph, role matrix, browser-based progress tracker

---

## Note Format

Notes follow a consistent template so the structure stays predictable.

- `TL;DR` gives the fast overview.
- `Overview` and `Deep Dive` cover the core knowledge.
- `Code & Implementation` shows working code examples.
- `Production Failure Modes` documents real failure patterns.
- `Connections` links the note to the rest of the repo.
- `Sources` keeps the trail back to original material.

Section markers:

- **★ sections** — core sections every note must have
- **◆ sections** — included when the topic calls for them
- **○ sections** — optional but useful when relevant

---

## Quality Notice

These notes are AI-assisted and human-reviewed. We aim for accuracy, but advanced topics can still benefit from expert review. If you spot an issue, please open an issue or pull request.

CI quality gates run on every commit: zero broken links, zero wiki-links, 100% template compliance, content freshness checks.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.html).

---

## License

This repository is licensed under [CC-BY-4.0](LICENSE).
