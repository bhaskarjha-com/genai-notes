# GenAI Study Notes

> Comprehensive, structured study notes for Generative AI - from prerequisites to frontier research. Curriculum-ordered. Career-mapped to 31 AI/ML roles. AI-generated, human-reviewed.

[![Repo Quality](https://github.com/bhaskarjha-com/genai-notes/actions/workflows/lint.yml/badge.svg?branch=master)](https://github.com/bhaskarjha-com/genai-notes/actions/workflows/lint.yml)
[![Docs Site](https://github.com/bhaskarjha-com/genai-notes/actions/workflows/deploy.yml/badge.svg?branch=master)](https://github.com/bhaskarjha-com/genai-notes/actions/workflows/deploy.yml)

## What This Is

This repository is a public collection of structured GenAI study notes in plain markdown. Each topic is designed as a self-contained 30-60 minute study session that combines theory, code, terminology, comparisons, gotchas, and interview angles.

The repo is organized by learning sequence rather than alphabetically. You can study linearly, jump in by role, or use individual notes as a portable reference in GitHub, Obsidian, or any markdown editor.

The same content now also supports a docs site at `https://bhaskarjha-com.github.io/genai-notes/` after GitHub Pages deployment.

## Who It's For

- Students entering AI, ML, or GenAI
- Engineers transitioning into AI roles
- Job seekers preparing for AI interviews
- Anyone who wants structured GenAI knowledge in portable markdown

## How to Use

### Path 1: Linear Study

Start with [LEARNING_PATH.md](LEARNING_PATH.md). It contains the universal foundation plus 5 role-cluster tracks.

### Path 2: Role-Based Study

Read [career/genai-career-roles-universal.md](career/genai-career-roles-universal.md), then either use the matching track in [LEARNING_PATH.md](LEARNING_PATH.md) or jump straight into one of the dedicated role guides:

- [AI Engineer](career/roles/ai-engineer.md)
- [Generative AI Engineer](career/roles/genai-engineer.md)
- [LLM Engineer](career/roles/llm-engineer.md)
- [RAG Engineer](career/roles/rag-engineer.md)
- [Agentic AI Engineer](career/roles/agentic-ai-engineer.md)
- [ML Engineer](career/roles/ml-engineer.md)
- [MLOps / LLMOps Engineer](career/roles/mlops-engineer.md)

If your target role is more specialized or niche, use the grouped guides linked from [career/genai-career-roles-universal.md](career/genai-career-roles-universal.md) alongside the universal role reference.

### Path 3: Topic Reference

Use [genai.md](genai.md) as the root GenAI overview note, then browse the folders below for deeper dives.

## Study Tools

- [Anki-friendly interview decks](downloads/anki/README.md)
- [Progress tracker downloads](downloads/progress/README.md)
- [Topic x role relevance matrix](generated/topic-role-relevance-matrix.md)
- [Interactive docs-site tooling](learner-tools/knowledge-graph.md), including the knowledge graph, role matrix, and browser-based progress tracker

## What's Covered

Current snapshot: a growing library of curriculum-ordered topic notes, a root [genai.md](genai.md) overview, dedicated and grouped career guidance, generated learner tooling, and reusable templates. Use [LEARNING_PATH.md](LEARNING_PATH.md) for the current curriculum and [genai.md](genai.md) for the living scope map.

```text
genai-notes/
|- prerequisites/           math, deep learning, and NLP prerequisites
|- foundations/             transformer and representation fundamentals
|- llms/                    model behavior, selection, and failure modes
|- techniques/              prompting, RAG, fine-tuning, agents, and adaptation
|- applications/            applied product and interface patterns
|- tools-and-infra/         tooling, data, cloud, and systems foundations
|- production/              serving, ops, CI/CD, reliability, and system design
|- evaluation/              benchmarks, deep-dive evaluation, interview prep
|- inference/               optimization, GPUs, and distributed serving
|- ethics-and-safety/       governance, regulation, and security
|- multimodal/              multimodal and computer-vision fundamentals
|- image-generation/        diffusion-model coverage
|- research-frontiers/      interpretability, training, and research practice
|- career/                  universal role map, dedicated guides, grouped guides
|- learner-tools/           docs-site learner tooling pages
|- downloads/               generated decks and progress checklists
|- generated/               generated markdown reference outputs
|- assets/                  site CSS, JS, and generated JSON data
|- _templates/              note and career-guide templates
|- genai.md                 root GenAI overview note
`- root docs                README, LEARNING_PATH, CONTRIBUTING, CHANGELOG, LICENSE
```

## Note Format

Notes follow a consistent template so the structure stays predictable.

- `TL;DR` gives the fast overview.
- `Overview` and `Deep Dive` cover the core knowledge.
- `Connections` links the note to the rest of the repo.
- `Sources` keeps the trail back to original material.

The template also uses section markers:

- ★ sections are the core sections every note must have.
- ◆ sections are included when the topic calls for them.
- ○ sections are optional but useful when relevant.

## Quality Notice

These notes are AI-generated and human-reviewed. We aim for accuracy, but advanced topics can still benefit from expert review. If you spot an issue, please open an issue or pull request.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This repository is licensed under [CC-BY-4.0](LICENSE).
