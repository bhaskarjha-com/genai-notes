---
title: "Research And Infrastructure Roles"
tags: [career, research, infrastructure, foundation-models, distributed-training, inference]
type: reference
difficulty: advanced
status: published
parent: "[[./genai-career-roles-universal]]"
related: ["[[./roles/llm-engineer]]", "[[./roles/ml-engineer]]", "[[./roles/mlops-engineer]]"]
source: "Repo synthesis from the universal career reference and linked notes"
created: 2026-04-12
updated: 2026-04-12
---

# Research And Infrastructure Roles

> Use this guide if you want to build the deepest layers of AI systems: training stacks, inference engines, research experiments, and high-performance infrastructure.

---

## Included Roles

| Role | Layer | Best Fit | What Differentiates It |
|---|---|---|---|
| Inference Optimization Engineer | Layer 3 | systems-minded performance work | latency, throughput, kernels, batching, memory |
| Foundation Model Engineer | Layer 2 | pretraining and adaptation at scale | training data, scaling, alignment, long-run experiments |
| AI Research Scientist | Layer 2 | frontier experimentation and novel methods | hypothesis design and paper-grade rigor |
| Applied AI Scientist | Layer 2 | research translated into practical model gains | strong experimentation plus delivery sense |
| AI Infra / Platform Engineer | Layer 1 | clusters, serving platforms, and reliability | platform abstractions, fleet operation, GPU orchestration |
| AI Compiler / Kernel Engineer | Layer 1 | deepest performance stack | compilers, kernels, hardware-near optimization |

---

## Learning Path

### Phase 1: Foundation

Complete [Part 1 of the Learning Path](../LEARNING_PATH.md#part-1-universal-foundation-60-hours) first, then commit to the deeper systems and research path.

### Phase 2: Shared Core

| # | Topic | Note | Priority | Est. Time |
|---|---|---|:---:|:---:|
| 1 | Scaling laws and pretraining | [scaling-laws-and-pretraining](../foundations/scaling-laws-and-pretraining.md) | Must | 4h |
| 2 | Distributed training | [distributed-training](../research-frontiers/distributed-training.md) | Must | 4h |
| 3 | Training infrastructure | [training-infrastructure](../research-frontiers/training-infrastructure.md) | Must | 3h |
| 4 | GPU and CUDA programming | [gpu-cuda-programming](../inference/gpu-cuda-programming.md) | Must | 4h |
| 5 | Distributed inference and serving architecture | [distributed-inference-and-serving-architecture](../inference/distributed-inference-and-serving-architecture.md) | Must | 3h |
| 6 | Mechanistic interpretability | [interpretability](../research-frontiers/interpretability.md) | Must | 2h |

### Phase 3: Role-Specific Emphasis

| Role | High-Leverage Notes | Why |
|---|---|---|
| Inference Optimization Engineer | [inference-optimization](../inference/inference-optimization.md), [latency-and-throughput-engineering](../production/latency-and-throughput-engineering.md), [model-serving](../production/model-serving.md) | performance and serving-path control |
| Foundation Model Engineer | [advanced-fine-tuning](../techniques/advanced-fine-tuning.md), [continual-learning](../techniques/continual-learning.md), [synthetic-data-and-data-engineering](../techniques/synthetic-data-and-data-engineering.md) | adaptation after pretraining |
| AI Research Scientist | [research-methodology-and-paper-reading](../research-frontiers/research-methodology-and-paper-reading.md), [reasoning-models](../llms/reasoning-models.md), [multimodal-ai](../multimodal/multimodal-ai.md) | frontier hypothesis generation and transfer |
| Applied AI Scientist | [llm-evaluation-deep-dive](../evaluation/llm-evaluation-deep-dive.md), [advanced-fine-tuning](../techniques/advanced-fine-tuning.md), [hallucination-detection](../llms/hallucination-detection.md) | rigorous iteration on practical model behavior |
| AI Infra / Platform Engineer | [docker-and-kubernetes](../production/docker-and-kubernetes.md), [distributed-systems-for-ai](../tools-and-infra/distributed-systems-for-ai.md), [cost-optimization](../production/cost-optimization.md) | fleet and platform operation at scale |
| AI Compiler / Kernel Engineer | [gpu-cuda-programming](../inference/gpu-cuda-programming.md), [inference-optimization](../inference/inference-optimization.md), [distributed-training](../research-frontiers/distributed-training.md) | hardware-near performance work |

### Phase 4: External Skills

| # | Skill | Recommended Focus | Priority |
|---|---|---|:---:|
| 1 | C++, CUDA, and systems profiling | especially for infrastructure and optimization roles | Must |
| 2 | Reproducibility discipline | experiment tracking, benchmark hygiene, ablation thinking | Must |
| 3 | Distributed-compute literacy | networking, memory hierarchy, cluster scheduling | Must |

---

## Skills Breakdown

### Common Technical Skills

- performance intuition around memory, batching, and distributed work
- experiment rigor and baseline comparison
- ability to reason about trade-offs across training and serving systems

### Differentiators By Role

- research roles need stronger hypothesis formation and literature fluency
- infrastructure roles need stronger operational and systems depth
- optimization roles sit closest to performance bottlenecks and tooling

### Soft Skills

- patience with ambiguity
- disciplined measurement over intuition-only claims
- precise communication of limits, assumptions, and regressions

---

## Portfolio Project Ideas

| Project | Description | Skills Demonstrated | Difficulty |
|---|---|---|:---:|
| Serving benchmark harness | compare latency and throughput across two serving setups with clear metrics | inference systems, profiling, experiment rigor | Hard |
| Mini research replication | reproduce a paper result on smaller hardware and document what transfers | research methodology, critical reading, adaptation | Hard |

---

## Interview Preparation

Review [distributed-training](../research-frontiers/distributed-training.md#interview-angles), [gpu-cuda-programming](../inference/gpu-cuda-programming.md#interview-angles), [inference-optimization](../inference/inference-optimization.md#interview-angles), and [research-methodology-and-paper-reading](../research-frontiers/research-methodology-and-paper-reading.md#interview-angles).

Common themes:

- Where is the true bottleneck: compute, memory, bandwidth, or orchestration?
- How do you verify that a claimed gain survives a real baseline comparison?
- When do you choose architectural change versus systems optimization?

---

## Sources

- [GenAI Career Roles - Complete Reference (2026)](./genai-career-roles-universal.md)
- Repo notes linked above
