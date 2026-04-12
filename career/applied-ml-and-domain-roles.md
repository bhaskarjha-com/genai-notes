---
title: "Applied ML And Domain Roles"
tags: [career, applied-ml, data-engineering, nlp, computer-vision, conversational-ai]
type: reference
difficulty: intermediate
status: published
parent: "[[./genai-career-roles-universal]]"
related: ["[[./roles/llm-engineer]]", "[[./roles/ml-engineer]]", "[[./roles/rag-engineer]]"]
source: "Repo synthesis from the universal career reference and linked notes"
created: 2026-04-12
updated: 2026-04-12
---

# Applied ML And Domain Roles

> Use this guide if you want hands-on model adaptation and domain specialization without going all the way into frontier-model research.

---

## Included Roles

| Role | Layer | Best Fit | What Differentiates It |
|---|---|---|---|
| AI Data Engineer | Layer 4 | learners who like pipelines, datasets, and feature flow | data movement and quality around AI systems |
| NLP Engineer | Layer 4 | text-heavy modeling and adaptation | language-task depth beyond prompt-only systems |
| Computer Vision Engineer | Layer 4 | image and video understanding roles | visual representations and multimodal design |
| Data Scientist (GenAI) | Layer 4 | experimentation and metric-driven iteration | evaluation, analysis, and model/business trade-offs |
| Conversational AI Engineer | Layer 6 | assistants, voice systems, and multi-turn interaction | dialogue state, context, and speech interfaces |
| AI Trainer / RLHF Annotator | Layer 4 | human-feedback and alignment workflows | annotation quality, preference data, rubric discipline |

---

## Learning Path

### Phase 1: Foundation

Complete [Part 1 of the Learning Path](../LEARNING_PATH.md#part-1-universal-foundation-60-hours) first.

### Phase 2: Shared Core

| # | Topic | Note | Priority | Est. Time |
|---|---|---|:---:|:---:|
| 1 | Advanced fine-tuning | [advanced-fine-tuning](../techniques/advanced-fine-tuning.md) | Must | 4h |
| 2 | LLM evaluation deep dive | [llm-evaluation-deep-dive](../evaluation/llm-evaluation-deep-dive.md) | Must | 3h |
| 3 | Hallucination detection | [hallucination-detection](../llms/hallucination-detection.md) | Must | 3h |
| 4 | Synthetic data and data engineering | [synthetic-data-and-data-engineering](../techniques/synthetic-data-and-data-engineering.md) | Must | 3h |
| 5 | ML experiment tracking | [ml-experiment-tracking](../tools-and-infra/ml-experiment-tracking.md) | Must | 2h |
| 6 | Data versioning for ML | [data-versioning-for-ml](../tools-and-infra/data-versioning-for-ml.md) | Must | 2h |

### Phase 3: Role-Specific Emphasis

| Role | High-Leverage Notes | Why |
|---|---|---|
| AI Data Engineer | [cloud-ml-services](../tools-and-infra/cloud-ml-services.md), [distributed-systems-for-ai](../tools-and-infra/distributed-systems-for-ai.md), [llmops](../production/llmops.md) | pipeline reliability and operational ownership |
| NLP Engineer | [rl-alignment](../techniques/rl-alignment.md), [continual-learning](../techniques/continual-learning.md), [reasoning-models](../llms/reasoning-models.md) | deeper model-adaptation and behavior work |
| Computer Vision Engineer | [multimodal-ai](../multimodal/multimodal-ai.md), [computer-vision-fundamentals](../multimodal/computer-vision-fundamentals.md), [diffusion-models](../image-generation/diffusion-models.md) | visual understanding and generation depth |
| Data Scientist (GenAI) | [evaluation-and-benchmarks](../evaluation/evaluation-and-benchmarks.md), [classical-ml-for-genai](../production/classical-ml-for-genai.md), [llm-landscape](../llms/llm-landscape.md) | experiment design and decision support |
| Conversational AI Engineer | [conversational-ai](../applications/conversational-ai.md), [voice-ai](../applications/voice-ai.md), [context-engineering](../techniques/context-engineering.md) | multi-turn behavior and speech interactions |
| AI Trainer / RLHF Annotator | [rl-alignment](../techniques/rl-alignment.md), [ethics-safety-alignment](../ethics-and-safety/ethics-safety-alignment.md), [evaluation-and-benchmarks](../evaluation/evaluation-and-benchmarks.md) | feedback quality and alignment judgment |

### Phase 4: External Skills

| # | Skill | Recommended Focus | Priority |
|---|---|---|:---:|
| 1 | Dataset and labeling discipline | schema design, annotation QA, leakage control | Must |
| 2 | Experiment analysis | confusion analysis, ablations, error slicing | Must |
| 3 | Domain literacy | product, support, healthcare, finance, or visual domain depending on target role | Good |

---

## Skills Breakdown

### Common Technical Skills

- evaluation design and error analysis
- model adaptation and data quality discipline
- reproducibility across experiments and datasets

### Differentiators By Role

- NLP and conversational roles need stronger language-behavior depth
- computer-vision roles need multimodal and image understanding fluency
- data-oriented roles need pipeline and instrumentation reliability

### Soft Skills

- careful labeling and review habits
- pattern recognition in failures
- clear communication of uncertainty and experimental limits

---

## Portfolio Project Ideas

| Project | Description | Skills Demonstrated | Difficulty |
|---|---|---|:---:|
| Domain adaptation benchmark | compare prompt-only, RAG, and fine-tuned variants on one domain task | evaluation, data discipline, adaptation trade-offs | Medium |
| Multimodal assistant | build a document or screenshot-aware assistant with measurable quality metrics | CV basics, multimodal design, evaluation | Medium |

---

## Interview Preparation

Review [advanced-fine-tuning](../techniques/advanced-fine-tuning.md#interview-angles), [llm-evaluation-deep-dive](../evaluation/llm-evaluation-deep-dive.md#interview-angles), [computer-vision-fundamentals](../multimodal/computer-vision-fundamentals.md#interview-angles), and [conversational-ai](../applications/conversational-ai.md#interview-angles).

Common themes:

- How do you know whether an improvement is real or noise?
- When should you use fine-tuning versus retrieval, rules, or human review?
- What failure patterns matter most in your chosen modality or domain?

---

## Sources

- [GenAI Career Roles - Complete Reference (2026)](./genai-career-roles-universal.md)
- Repo notes linked above
