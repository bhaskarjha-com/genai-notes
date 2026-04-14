---
title: "Hallucination Detection & Mitigation"
tags: [hallucination, groundedness, factuality, reliability, llm]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "llms-overview.md"
related: ["../techniques/rag.md", "../evaluation/evaluation-and-benchmarks.md", "../ethics-and-safety/ethics-safety-alignment.md"]
source: "Multiple sources - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Hallucination Detection & Mitigation

> Hallucination is not a side bug. It is what happens when a probabilistic generator sounds certain without being sufficiently grounded.

---

## TL;DR

- **What**: Methods to detect and reduce unsupported, fabricated, or overconfident model outputs
- **Why**: Hallucination is one of the main blockers to production trust in GenAI systems
- **Key point**: The best fix is usually system-level grounding and verification, not just a better prompt

---

## Overview

### Definition

A **hallucination** is an output that is fluent and plausible but unsupported by the available evidence, tool results, or real-world facts.

### Scope

This note covers hallucination types, detection methods, mitigation strategies, and production patterns. For broader safety context, see [Ethics, Safety & Alignment](../ethics-and-safety/ethics-safety-alignment.md). For retrieval-based grounding, see [Retrieval-Augmented Generation (RAG)](../techniques/rag.md).

### Why It Happens

- Next-token prediction optimizes plausibility, not truth
- The model may be missing the needed knowledge
- Prompts can force answers even when the model should abstain
- Tool or retrieval context may be incomplete or noisy

### Prerequisites

- [Large Language Models (LLMs)](./llms-overview.md)
- [Retrieval-Augmented Generation (RAG)](../techniques/rag.md)
- [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md)

---

## Deep Dive

### Useful Taxonomy

| Type | Description | Example |
|---|---|---|
| **Intrinsic** | Contradicts provided context | Model cites a value not present in the retrieved chunk |
| **Extrinsic** | Sounds factual but is false outside the context | Fake company, paper, package, or legal clause |
| **Fabricated citation** | Invented source or quote | Nonexistent article or benchmark |
| **Reasoning drift** | Early steps are plausible, final conclusion is unsupported | Tool traces do not justify the final recommendation |

### Detection Strategies

#### 1. Reference-based checks

Use when you have ground truth, citations, or authoritative context.

- exact match or overlap for structured answers
- contradiction / entailment checks
- citation coverage checks
- groundedness scores against retrieved passages

#### 2. Reference-free checks

Use when no gold answer exists.

- self-consistency across repeated generations
- verifier model or judge model
- uncertainty estimation or abstention scoring
- anomaly detection on tool trajectories

#### 3. Production heuristics

- response contains named entities not present in context
- output references tools that were never called
- answer format is valid but evidence fields are empty
- confidence tone is high while retrieval confidence is low

### Practical Detection Stack

```text
User request
-> retrieve / call tools
-> generate answer with citations
-> groundedness check
-> format + policy validation
-> optional verifier model
-> answer / abstain / escalate
```

### Mitigation Strategies

| Strategy | Best For | Limitation |
|---|---|---|
| **RAG with citations** | Knowledge assistants | Depends on retrieval quality |
| **Tool use** | Dynamic facts and calculations | Tool outputs can still be misused |
| **Structured output** | Workflows and APIs | Does not guarantee truthfulness |
| **Abstain / say "I do not know"** | High-risk domains | Can reduce answer coverage |
| **Fine-tuning on domain style** | Format and task consistency | Does not guarantee current facts |
| **Verifier pass** | Expensive or high-stakes requests | Adds latency and cost |

### What Works Best In Practice

1. Ground with retrieval or tools
2. Ask for citations or evidence fields
3. Add a post-generation groundedness check
4. Route uncertain or unsafe answers to abstention or human review

### Simple Groundedness Pattern

```python
# ?? Last tested: 2026-04
def answer_with_check(query, context_chunks, llm, verifier):
    draft = llm.generate(query=query, context=context_chunks)
    verdict = verifier.score(answer=draft, evidence=context_chunks)
    if verdict["grounded"] < 0.7:
        return {
            "status": "abstain",
            "message": "I do not have enough grounded evidence to answer reliably."
        }
    return {"status": "ok", "answer": draft}
```

### Design Guidance

- If the answer must be up to date, use tools or retrieval
- If the answer must be auditable, require citations
- If the domain is high risk, allow abstention and human escalation
- If the task is repetitive and format-heavy, add structured outputs and regression tests

---

## Quick Reference

| Signal | Interpretation |
|---|---|
| High fluency + low evidence coverage | Likely hallucination risk |
| Wrong citations | Retrieval or citation assembly bug |
| Repeated invented entities | Model prior overpowering context |
| Strong answer on empty retrieval | Missing abstention policy |

---

## Gotchas

- "Lower temperature" is not a full hallucination strategy
- Fine-tuning can improve style while still preserving factual failure modes
- A judge model can also hallucinate if it is not grounded on evidence
- Hallucination should be measured per use case, not only as a generic score

---

## Interview Angles

- **Q**: What is the most effective way to reduce hallucination in enterprise assistants?
- **A**: Ground the answer on retrieval or tool outputs, require evidence in the response path, and add a post-generation verification step with abstention when confidence is low.

- **Q**: How do detection and mitigation differ?
- **A**: Detection estimates whether an answer is unsupported. Mitigation changes the system so unsupported answers happen less often or are blocked before the user sees them.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Large Language Models (LLMs)](./llms-overview.md), [Retrieval-Augmented Generation (RAG)](../techniques/rag.md), [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md) |
| Leads to | [Ethics, Safety & Alignment](../ethics-and-safety/ethics-safety-alignment.md), [Advanced Fine-Tuning for LLM Adaptation](../techniques/advanced-fine-tuning.md), [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md) |
| Compare with | Generic model quality issues, prompt injection, data leakage |
| Cross-domain | Information retrieval, fact checking, uncertainty estimation |


---

## ◆ Hands-On Exercises

### Exercise 1: Build a Hallucination Detection Pipeline

**Goal**: Create a multi-method hallucination detection system
**Time**: 45 minutes
**Steps**:
1. Generate 20 LLM responses on factual questions
2. Implement 3 detection methods: self-consistency, retrieval-grounding, NLI
3. Label each response as factual/hallucinated using all 3 methods
4. Compare detection accuracy against human annotations
**Expected Output**: Detection method comparison table with precision/recall

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **False positive refusals** | System flags accurate responses as hallucinations | Detection threshold too aggressive | Calibrate thresholds on domain data, multi-method consensus |
| **Confident hallucinations** | Model hallucinates with high confidence scores | Confidence ≠ correctness for LLMs | Retrieval grounding, self-consistency checks, citation verification |
| **Detection latency** | Real-time hallucination check adds 2-5s per response | Detection method too compute-intensive | Lightweight pre-filter, async verification, batch checking |
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Min et al. "FActScore" (2023)](https://arxiv.org/abs/2305.14251) | Fine-grained factuality scoring for LLM outputs |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 4 | Hallucination detection as part of evaluation strategy |
| 🔧 Hands-on | [Vectara HHEM](https://huggingface.co/vectara/hallucination_evaluation_model) | Open-source hallucination evaluation model |

## Sources

- SelfCheckGPT paper
- RAGAS documentation
- NLI / entailment literature for factual verification
- [Ethics, Safety & Alignment](../ethics-and-safety/ethics-safety-alignment.md)
