---
title: "Embedding Fine-Tuning"
aliases: ["Embedding Training", "Contrastive Learning"]
tags: [embeddings, fine-tuning, retrieval, rag, contrastive-learning, production]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../foundations/embeddings.md"
related: ["../techniques/rag.md", "../evaluation/retrieval-evaluation.md", "../tools-and-infra/vector-databases.md", "../techniques/fine-tuning.md"]
source: "Multiple â€” see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# Embedding Fine-Tuning

> ✨ **Bit**: General-purpose embeddings work well for general-purpose tasks. But if your RAG system struggles with domain-specific queries (legal, medical, code), fine-tuning embeddings on your data can improve retrieval by 10-30% â€” often more impactful than changing the LLM.

---

## ★ TL;DR

- **What**: Training or adapting embedding models on domain-specific data to improve retrieval quality for RAG and search systems
- **Why**: Off-the-shelf embeddings (OpenAI, Cohere) are trained on general web data. Domain-specific terminology, jargon, and relationships aren't well captured.
- **Key point**: Fine-tuning embeddings is often the highest-ROI improvement for RAG systems â€” 10-30% retrieval quality improvement with relatively small training sets (1K-10K examples).

---

## ★ Overview

### Definition

**Embedding fine-tuning** adapts a pretrained embedding model to a specific domain or task by training on labeled pairs (query, relevant_document) or triplets (query, positive, negative) using contrastive learning objectives.

### Scope

Covers: When to fine-tune vs use off-the-shelf, training data generation, contrastive learning, practical fine-tuning with Sentence Transformers, evaluation. For embedding fundamentals, see [Embeddings](../foundations/embeddings.md). For retrieval evaluation, see [Retrieval Evaluation](../evaluation/retrieval-evaluation.md).

### Prerequisites

- [Embeddings](../foundations/embeddings.md) â€” vector representation fundamentals
- [RAG](../techniques/rag.md) â€” retrieval architecture
- [Fine-Tuning](../techniques/fine-tuning.md) â€” general fine-tuning concepts

---

## ★ Deep Dive

### When to Fine-Tune Embeddings

```
DECISION TREE:

  Is your retrieval quality good enough (Recall@5 > 0.8)?
  â”œâ”€â”€ YES → Don't fine-tune. Focus on LLM/prompt improvements.
  â””â”€â”€ NO  → Is the problem domain-specific vocabulary?
             â”œâ”€â”€ YES → Fine-tune embeddings (highest ROI)
             â””â”€â”€ NO  → Check chunking, reranking, hybrid search first
                        â””â”€â”€ Still bad? → Fine-tune embeddings

SIGNS YOU NEED EMBEDDING FINE-TUNING:
  âœ— Medical queries: "dyspnea" doesn't match "shortness of breath"
  âœ— Legal queries: "force majeure" doesn't find relevant contract clauses
  âœ— Code queries: "implement retry logic" doesn't find error handling code
  âœ— Internal jargon: Company-specific terms have no good embedding
```

### Training Data for Embedding Fine-Tuning

| Data Type | Format | How to Generate | Volume Needed |
|-----------|--------|----------------|:-------------:|
| **Positive pairs** | (query, relevant_doc) | From search logs, user clicks, manual labeling | 1K-10K pairs |
| **Triplets** | (query, positive_doc, negative_doc) | Positive from logs + hard negatives from retrieval | 5K-50K triplets |
| **LLM-generated** | Synthetic queries from documents | Use LLM to generate questions that each document answers | 1K-10K |

### Contrastive Learning Objective

```
TRAINING OBJECTIVE: Pull matching pairs together, push non-matching apart

  Query: "What causes high blood pressure?"

  Positive doc: "Hypertension is caused by..."     → PULL CLOSER
  Negative doc: "Stock market trends in 2024..."    → PUSH APART
  Hard negative: "Blood pressure measurement..."    → PUSH APART (harder!)

  Loss function: InfoNCE / Multiple Negatives Ranking Loss

  L = -log( exp(sim(q, d+)/Ï„) / Î£ exp(sim(q, di)/Ï„) )

  Where:
    q = query embedding
    d+ = positive document embedding
    di = all documents in batch (positives + negatives)
    Ï„ = temperature (default 0.05)
    sim = cosine similarity
```

---

## ★ Code & Implementation

### Fine-Tune Embeddings with Sentence Transformers

```python
# pip install sentence-transformers>=3.0 datasets>=2.0
# âš ï¸ Last tested: 2026-04 | Requires: sentence-transformers>=3.0

from sentence_transformers import SentenceTransformer, InputExample, losses
from sentence_transformers.evaluation import InformationRetrievalEvaluator
from torch.utils.data import DataLoader

# 1. Load base model
model = SentenceTransformer("BAAI/bge-small-en-v1.5")

# 2. Prepare training data (query, positive_doc pairs)
train_examples = [
    InputExample(texts=["What causes hypertension?",
                        "Hypertension is primarily caused by arterial stiffening..."]),
    InputExample(texts=["Treatment for type 2 diabetes",
                        "First-line treatment for T2DM includes metformin..."]),
    InputExample(texts=["Side effects of statins",
                        "Common statin side effects include myalgia..."]),
    # ... add 1K-10K pairs for production quality
]

# 3. Create dataloader
train_dataloader = DataLoader(train_examples, shuffle=True, batch_size=32)

# 4. Use Multiple Negatives Ranking Loss (best for retrieval)
train_loss = losses.MultipleNegativesRankingLoss(model=model)

# 5. Fine-tune
model.fit(
    train_objectives=[(train_dataloader, train_loss)],
    epochs=3,
    warmup_steps=100,
    output_path="./models/medical-embeddings",
    show_progress_bar=True,
)

# 6. Use fine-tuned model
model = SentenceTransformer("./models/medical-embeddings")
query_emb = model.encode("shortness of breath treatment")
doc_emb = model.encode("Dyspnea management includes bronchodilators...")
similarity = query_emb @ doc_emb / (
    (query_emb @ query_emb) ** 0.5 * (doc_emb @ doc_emb) ** 0.5
)
print(f"Similarity: {similarity:.3f}")
# Expected: Higher similarity than base model (domain terms aligned)
```

### Generate Training Data with LLM

```python
# pip install openai>=1.0
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.0

from openai import OpenAI
import json

client = OpenAI()

def generate_training_pairs(documents: list[str], n_queries_per_doc: int = 3) -> list[dict]:
    """Generate synthetic (query, document) training pairs using an LLM."""
    pairs = []
    for doc in documents:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{
                "role": "user",
                "content": f"""Generate {n_queries_per_doc} diverse search queries that this document would answer.
Return JSON array of strings.

Document: {doc[:2000]}"""
            }],
            response_format={"type": "json_object"},
            temperature=0.7,
        )
        queries = json.loads(response.choices[0].message.content).get("queries", [])
        for query in queries:
            pairs.append({"query": query, "document": doc})
    return pairs

# Usage
docs = [
    "Metformin is the first-line treatment for type 2 diabetes mellitus...",
    "Hypertension management begins with lifestyle modifications...",
]
training_data = generate_training_pairs(docs)
print(f"Generated {len(training_data)} training pairs")
# Expected: 6 query-document pairs ready for embedding fine-tuning
```

---

## ◆ Quick Reference

```
EMBEDDING FINE-TUNING CHECKLIST:

  1. Baseline: Measure retrieval quality with off-the-shelf model
  2. Data: Collect/generate 1K-10K (query, relevant_doc) pairs
  3. Model: Start with a strong base (bge-small, e5-small, gte-base)
  4. Train: 3-5 epochs, MNR loss, batch size 32-64
  5. Evaluate: Compare Recall@5 and MRR before vs after
  6. Deploy: Replace embedding model in your RAG pipeline
  7. Monitor: Track retrieval quality in production

EXPECTED IMPROVEMENTS:
  General domain: 5-10% improvement in Recall@5
  Specialized domain: 10-30% improvement in Recall@5
  With hard negatives: Additional 5-10% boost
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Catastrophic forgetting** | Fine-tuned model worse on general queries | Overfitting to domain data, losing general knowledge | Use lower learning rate, fewer epochs, mix in general data |
| **Low-quality training data** | No improvement after fine-tuning | Training pairs are noisy, irrelevant, or too easy | Clean data, add hard negatives, use LLM-generated queries |
| **Embedding dimension mismatch** | Can't deploy â€” vector DB expects different dimensions | Changed model architecture during fine-tuning | Use same model family, or rebuild vector index |

---

## ○ Interview Angles

- **Q**: How would you improve retrieval quality in a RAG system?
- **A**: I'd follow a priority ladder. First, measure baseline retrieval quality (Precision@5, Recall@5) to quantify the gap. Second, check chunking â€” are chunks the right size (200-500 tokens) with enough context? Third, try hybrid search (semantic + keyword with BM25). Fourth, add a cross-encoder reranker on top-20 results. If the domain is specialized (medical, legal), I'd fine-tune the embedding model on 5K-10K domain-specific (query, document) pairs using contrastive learning â€” this typically gives 10-30% improvement on domain queries. I'd evaluate each change independently to measure its contribution.

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Embeddings](../foundations/embeddings.md), [Fine-Tuning](../techniques/fine-tuning.md), [RAG](../techniques/rag.md) |
| Leads to | Domain-specific RAG, improved retrieval quality, [Retrieval Evaluation](../evaluation/retrieval-evaluation.md) |
| Compare with | Off-the-shelf embeddings, reranking (no fine-tuning needed) |
| Cross-domain | Information retrieval, search engineering, NLP |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ”§ Hands-on | [Sentence Transformers Fine-Tuning Guide](https://www.sbert.net/docs/training/overview.html) | Official guide for embedding fine-tuning |
| ðŸ“„ Paper | [Xiao et al. "C-Pack: Packaged Resources for General Chinese Embeddings" (BGE, 2023)](https://arxiv.org/abs/2309.07597) | How BAAI/bge models are trained â€” informative for fine-tuning strategy |
| ðŸ“˜ Book | "AI Engineering" by Chip Huyen (2025), Ch 3 | Embedding selection and optimization in RAG |
| ðŸ”§ Hands-on | [MTEB Leaderboard](https://huggingface.co/spaces/mteb/leaderboard) | Compare embedding model quality before choosing a base |


---

## ◆ Hands-On Exercises

### Exercise 1: Fine-Tune an Embedding Model on Your Domain

**Goal**: Improve retrieval quality by fine-tuning embeddings on domain data
**Time**: 45 minutes
**Steps**:
1. Create 200 positive pairs (query, relevant document) from your domain
2. Generate hard negatives using BM25 retrieval
3. Fine-tune a sentence-transformers model with MultipleNegativesRankingLoss
4. Compare retrieval metrics before and after fine-tuning
**Expected Output**: MRR improvement table showing fine-tuned model outperforms base
---

## ★ Sources

- Sentence Transformers Documentation â€” https://www.sbert.net/
- MTEB Embedding Benchmark â€” https://huggingface.co/spaces/mteb/leaderboard
- Reimers & Gurevych "Sentence-BERT" (2019)
- [Embeddings](../foundations/embeddings.md)
- [RAG](../techniques/rag.md)
