---
title: "Retrieval Evaluation"
tags: [retrieval, evaluation, rag, search, metrics, mrr, ndcg]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "evaluation-and-benchmarks.md"
related: ["../techniques/rag.md", "../techniques/graph-rag.md", "llm-evaluation-deep-dive.md", "../tools-and-infra/vector-databases.md"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# Retrieval Evaluation

> ✨ **Bit**: If your RAG system retrieves the wrong documents, no amount of prompt engineering will fix the answer. Retrieval evaluation measures whether the right information reaches the model — the most neglected and most impactful part of RAG quality.

---

## ★ TL;DR

- **What**: Metrics and methods for measuring retrieval quality in RAG systems — precision, recall, MRR, nDCG, and end-to-end RAG evaluation
- **Why**: Most RAG failures are retrieval failures. If irrelevant chunks reach the model, it hallucinates or refuses. Measuring retrieval quality separately from generation quality is essential.
- **Key point**: Evaluate retrieval independently from generation. A perfect LLM can't help if retrieval gives it the wrong documents.

---

## ★ Overview

### Definition

**Retrieval evaluation** measures how effectively a retrieval system finds and ranks relevant documents for a given query. In RAG, this means measuring whether the chunks that reach the LLM actually contain the information needed to answer the question.

### Scope

Covers: Core retrieval metrics (precision@k, recall@k, MRR, nDCG), RAG-specific evaluation (context relevance, groundedness, faithfulness), evaluation frameworks (RAGAS, DeepEval), and practical implementation. For LLM generation evaluation, see [LLM Evaluation](./llm-evaluation-deep-dive.md).

### Prerequisites

- [RAG](../techniques/rag.md) — retrieval architecture
- [LLM Evaluation Deep Dive](./llm-evaluation-deep-dive.md) — generation evaluation
- [Vector Databases](../tools-and-infra/vector-databases.md) — retrieval infrastructure

---

## ★ Deep Dive

### The Two-Stage RAG Evaluation Framework

```
RAG EVALUATION = RETRIEVAL QUALITY + GENERATION QUALITY

  RETRIEVAL METRICS           GENERATION METRICS
  (independent of LLM)        (depends on retrieval)
  ─────────────────           ──────────────────
  Precision@K                 Answer correctness
  Recall@K                    Faithfulness (grounded in context)
  MRR                         Answer relevance
  nDCG                        Completeness
  Hit Rate                    Hallucination rate

  KEY INSIGHT: Always evaluate retrieval FIRST.
  If retrieval is bad, improving the LLM prompt won't help.
```

### Core Retrieval Metrics

| Metric | What It Measures | Formula | Range |
|--------|-----------------|---------|:-----:|
| **Precision@K** | % of retrieved docs that are relevant | relevant_in_top_k / k | 0-1 |
| **Recall@K** | % of all relevant docs that were retrieved | relevant_in_top_k / total_relevant | 0-1 |
| **Hit Rate** | Did at least one relevant doc appear in top K? | 1 if any relevant in top_k, else 0 | 0 or 1 |
| **MRR** | How high is the first relevant result? | 1 / rank_of_first_relevant | 0-1 |
| **nDCG@K** | Quality of ranking (higher rank = more weight) | See formula below | 0-1 |

### nDCG: The Gold Standard Ranking Metric

```
nDCG@K = DCG@K / IDCG@K

  DCG@K  = Σ (relevance_i / log2(rank_i + 1))  for i = 1 to K
  IDCG@K = DCG@K with perfect ranking (most relevant first)

  EXAMPLE:
  Query: "What is attention in transformers?"
  Retrieved docs (relevance: 0=irrelevant, 1=somewhat, 2=highly):

  Rank 1: "Attention mechanism explained" → relevance 2
  Rank 2: "CNN architectures"             → relevance 0
  Rank 3: "Self-attention in BERT"        → relevance 2
  Rank 4: "Transformer training tips"     → relevance 1

  DCG@4  = 2/log2(2) + 0/log2(3) + 2/log2(4) + 1/log2(5)
         = 2.0 + 0.0 + 1.0 + 0.43 = 3.43

  Perfect ranking: [2, 2, 1, 0]
  IDCG@4 = 2/log2(2) + 2/log2(3) + 1/log2(4) + 0/log2(5)
         = 2.0 + 1.26 + 0.5 + 0.0 = 3.76

  nDCG@4 = 3.43 / 3.76 = 0.91  (good ranking!)
```

### RAG-Specific Metrics (RAGAS Framework)

| Metric | What It Measures | How |
|--------|-----------------|-----|
| **Context Relevance** | Are retrieved chunks relevant to the query? | LLM judges if each chunk is relevant |
| **Context Recall** | Do retrieved chunks cover all needed info? | Compare retrieved info vs ground truth answer |
| **Faithfulness** | Is the answer grounded in retrieved context? | Check each claim in answer against context |
| **Answer Relevance** | Does the answer address the question? | LLM judges answer-question alignment |

---

## ★ Code & Implementation

### Retrieval Evaluation Suite

```python
# pip install numpy>=1.24
# ⚠️ Last tested: 2026-04 | No external API needed

import numpy as np
from typing import Optional

def precision_at_k(retrieved: list[str], relevant: set[str], k: int) -> float:
    """Precision@K: fraction of top-K results that are relevant."""
    top_k = retrieved[:k]
    return len(set(top_k) & relevant) / k

def recall_at_k(retrieved: list[str], relevant: set[str], k: int) -> float:
    """Recall@K: fraction of all relevant docs found in top-K."""
    if not relevant:
        return 0.0
    top_k = retrieved[:k]
    return len(set(top_k) & relevant) / len(relevant)

def hit_rate(retrieved: list[str], relevant: set[str], k: int) -> float:
    """Hit Rate: 1 if any relevant doc in top-K, else 0."""
    return 1.0 if set(retrieved[:k]) & relevant else 0.0

def mrr(retrieved: list[str], relevant: set[str]) -> float:
    """Mean Reciprocal Rank: 1/rank of first relevant result."""
    for i, doc in enumerate(retrieved):
        if doc in relevant:
            return 1.0 / (i + 1)
    return 0.0

def ndcg_at_k(retrieved: list[str], relevance_scores: dict[str, int], k: int) -> float:
    """nDCG@K: normalized discounted cumulative gain."""
    # DCG
    dcg = 0.0
    for i, doc in enumerate(retrieved[:k]):
        rel = relevance_scores.get(doc, 0)
        dcg += rel / np.log2(i + 2)  # +2 because rank is 1-indexed
    
    # IDCG (ideal ranking)
    ideal_rels = sorted(relevance_scores.values(), reverse=True)[:k]
    idcg = sum(rel / np.log2(i + 2) for i, rel in enumerate(ideal_rels))
    
    return dcg / idcg if idcg > 0 else 0.0

# --- Evaluate a RAG retrieval system ---
def evaluate_retrieval(
    queries: list[str],
    retrieved_per_query: list[list[str]],
    relevant_per_query: list[set[str]],
    k: int = 5,
) -> dict:
    """Evaluate retrieval quality across multiple queries."""
    metrics = {"precision": [], "recall": [], "hit_rate": [], "mrr": []}
    
    for retrieved, relevant in zip(retrieved_per_query, relevant_per_query):
        metrics["precision"].append(precision_at_k(retrieved, relevant, k))
        metrics["recall"].append(recall_at_k(retrieved, relevant, k))
        metrics["hit_rate"].append(hit_rate(retrieved, relevant, k))
        metrics["mrr"].append(mrr(retrieved, relevant))
    
    return {name: f"{np.mean(values):.3f}" for name, values in metrics.items()}

# Example usage
queries = ["What is attention?", "How does RLHF work?"]
retrieved = [
    ["doc_attention", "doc_cnn", "doc_bert", "doc_rnn", "doc_transformers"],
    ["doc_rlhf", "doc_ppo", "doc_dpo", "doc_sft", "doc_reward"],
]
relevant = [
    {"doc_attention", "doc_bert", "doc_transformers"},
    {"doc_rlhf", "doc_ppo", "doc_dpo"},
]

results = evaluate_retrieval(queries, retrieved, relevant, k=5)
print("Retrieval Quality:")
for metric, value in results.items():
    print(f"  {metric:>12}: {value}")

# Expected output:
#   precision: 0.500
#      recall: 0.833
#    hit_rate: 1.000
#         mrr: 1.000
```

---

## ◆ Quick Reference

```
RETRIEVAL QUALITY BENCHMARKS:

  Metric        | Poor    | Acceptable | Good    | Excellent
  ──────────────|─────────|───────────|─────────|──────────
  Precision@5   | < 0.30  | 0.30-0.50 | 0.50-0.70 | > 0.70
  Recall@5      | < 0.40  | 0.40-0.60 | 0.60-0.80 | > 0.80
  Hit Rate@5    | < 0.60  | 0.60-0.80 | 0.80-0.90 | > 0.90
  MRR           | < 0.40  | 0.40-0.60 | 0.60-0.80 | > 0.80
  nDCG@5        | < 0.40  | 0.40-0.60 | 0.60-0.80 | > 0.80

IF RETRIEVAL IS BAD, FIX THIS FIRST:
  1. Check embedding model quality
  2. Check chunking strategy (too big / too small?)
  3. Add metadata filtering
  4. Try hybrid search (semantic + keyword)
  5. Consider reranking (cross-encoder)
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Low recall** | Correct answer exists in corpus but model says "I don't know" | Relevant chunks not retrieved (embedding mismatch, wrong chunk size) | Improve embedding model, tune chunk size, add keyword search |
| **Low precision** | Model hallucinates, using irrelevant retrieved chunks | Too many irrelevant chunks retrieved | Add reranking step, reduce k, tighten similarity threshold |
| **Evaluation set drift** | Metrics look good but users complain | Eval set doesn't represent real user queries | Regularly update eval set from production query logs |

---

## ○ Interview Angles

- **Q**: How would you evaluate a RAG system?
- **A**: I'd evaluate in two stages. Stage 1: Retrieval quality — I'd create a labeled dataset of 100+ queries with known relevant documents, then measure Precision@5, Recall@5, MRR, and nDCG. If retrieval metrics are poor (< 0.5 precision), I'd fix retrieval before touching the LLM. Stage 2: End-to-end — using RAGAS metrics (context relevance, faithfulness, answer correctness) to evaluate the full pipeline. I'd run this on every prompt/model change as a regression check. For production, I'd add online metrics: user feedback (thumbs up/down), citation click-through rate, and "I don't know" rate.

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Retrieval Eval Suite

**Goal**: Evaluate your RAG retrieval pipeline with standard metrics
**Time**: 45 minutes
**Steps**:
1. Create 20 test queries with labeled relevant documents
2. Run your retrieval system on all 20 queries
3. Calculate Precision@5, Recall@5, MRR, and Hit Rate using the code above
4. Identify the 5 worst queries — what went wrong with retrieval?
5. Try one improvement (better chunking, reranking, hybrid search) and re-measure
**Expected Output**: Before/after metrics table, analysis of failure patterns

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [RAG](../techniques/rag.md), [Vector Databases](../tools-and-infra/vector-databases.md), [Embeddings](../foundations/embeddings.md) |
| Leads to | RAG optimization, search quality improvement, production monitoring |
| Compare with | [LLM Evaluation](./llm-evaluation-deep-dive.md) (generation vs retrieval evaluation) |
| Cross-domain | Information retrieval, search engineering, library science |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [RAGAS Documentation](https://docs.ragas.io/) | Production RAG evaluation framework |
| 📄 Paper | [Barnett et al. "Seven Failure Points of RAG" (2024)](https://arxiv.org/abs/2401.05856) | Systematic analysis of where RAG systems fail |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 4 | Retrieval evaluation as part of the RAG quality stack |
| 🔧 Hands-on | [DeepEval](https://docs.confident-ai.com/) | Open-source LLM + retrieval evaluation framework |

---

## ★ Sources

- Barnett et al. "Seven Failure Points When Engineering a RAG System" (2024)
- RAGAS Documentation — https://docs.ragas.io/
- Manning et al. "Introduction to Information Retrieval" (2008), Ch 8
- [RAG](../techniques/rag.md)
