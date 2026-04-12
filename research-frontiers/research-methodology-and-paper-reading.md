---
title: "Research Methodology & Paper Reading for AI"
tags: [research, papers, methodology, experiments, reproducibility]
type: reference
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[interpretability]]", "[[distributed-training]]", "[[../evaluation/llm-evaluation-deep-dive]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Research Methodology & Paper Reading for AI

> Reading papers is not about collecting PDFs. It is about extracting claims, assumptions, methods, and limits without getting hypnotized by the leaderboard.

---

## TL;DR

- **What**: A practical framework for reading AI papers and designing research-minded experiments.
- **Why**: Frontier work moves fast, and shallow paper consumption leads to weak understanding and cargo-cult implementation.
- **Key point**: Focus on claims, setup, evidence, limitations, and reproducibility.

---

## Overview

### Definition

This note covers how to read papers critically, evaluate evidence, and structure experiments so you can learn from research rather than merely quote it.

### Scope

It applies to engineers, researchers, and advanced learners. It is not limited to academic roles.

### Significance

- AI progress is paper-driven and benchmark-driven.
- Reading well helps you separate durable ideas from hype.
- Strong research method improves engineering decisions too.

### Prerequisites

- [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md)
- [Distributed Training for Large Models](./distributed-training.md)
- Curiosity and healthy skepticism

---

## Deep Dive

### The Five Questions To Ask Of Any Paper

1. What exact claim is being made?
2. What setting or assumptions does the claim depend on?
3. What evidence supports it?
4. What are the weak spots in that evidence?
5. What would reproduction or adaptation require?

### Paper Reading Passes

| Pass | Goal |
|---|---|
| **Pass 1** | skim title, abstract, intro, figures, conclusion |
| **Pass 2** | inspect method, data, evaluation, and baselines |
| **Pass 3** | analyze assumptions, implementation details, and limitations |

### What To Extract

Keep notes on:

- problem statement
- proposed method
- datasets and benchmarks
- baseline comparisons
- ablations
- limitations
- what is likely durable vs temporary

### Common Failure Modes When Reading AI Papers

| Failure | Why It Misleads |
|---|---|
| reading only abstract and charts | misses assumptions and setup |
| trusting one benchmark | ignores generalization |
| ignoring compute budget | hides practicality |
| skipping baselines | cannot judge improvement quality |
| missing ablations | unclear what truly mattered |

### Reproducibility Mindset

When trying an idea from a paper:

1. define the exact claim you want to test
2. choose a tractable local version
3. record configs and datasets
4. compare against a meaningful baseline
5. document failures as well as wins

### Engineering Value Of Research Reading

Paper reading improves:

- architecture judgment
- tool selection
- interview depth
- ability to detect hype
- communication with advanced teams

### Example: Experiment Card Template

```yaml
claim_under_test: "Retrieval reranking improves grounded answer quality."
baseline:
  system: "RAG without reranker"
  metric: "grounded_answer_rate"
change:
  system: "RAG plus cross-encoder reranker"
dataset:
  split: "200 held-out support questions"
success_criteria:
  grounded_answer_rate_delta: ">= 5%"
  latency_budget_ms: "<= 1200"
notes_to_capture:
  - prompt version
  - retriever config
  - failure examples
  - unexpected regressions
```

---

## Quick Reference

| If You Want To Know... | Read This Part First |
|---|---|
| what the paper claims | abstract and conclusion |
| whether the result is credible | evaluation and baselines |
| whether it will transfer to your work | assumptions, limitations, compute setup |
| what actually caused gains | ablation section |
| whether you can implement it | method + appendix/code |

---

## Gotchas

- Newer does not automatically mean better.
- A strong benchmark result can hide weak operational value.
- Reproducing only the headline number misses the real lesson.

---

## Interview Angles

- **Q**: How do you read an AI paper efficiently?
- **A**: I start by extracting the core claim and evaluation setup, then inspect baselines, ablations, and limitations. I try to determine what is durable knowledge versus benchmark-specific optimization.

- **Q**: Why do ablations matter?
- **A**: Because they test which parts of the method actually drive the gains. Without ablations, it is hard to know whether the headline method or some side choice caused the result.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md), [Mechanistic Interpretability](./interpretability.md) |
| Leads to | applied research, model experimentation, deeper technical interviews |
| Compare with | blog-post level understanding |
| Cross-domain | scientific method, experimentation |

---

## Sources

- S. Keshav, "How to Read a Paper"
- reproducibility guidance from major ML venues
- [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md)
