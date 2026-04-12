---
title: "Embeddings"
tags: [embeddings, vectors, representation, similarity, genai-foundations]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[transformers]]", "[[../techniques/rag]]", "[[../tools-and-infra/vector-databases]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Embeddings

> ✨ **Bit**: Embeddings are how machines "understand" meaning — by turning everything (words, images, code) into lists of numbers where similar things are close together. "King - Man + Woman = Queen" is the most famous proof it works.

---

## ★ TL;DR

- **What**: Dense vector representations that encode the meaning/semantics of data (text, images, audio) into fixed-size arrays of numbers
- **Why**: THE bridge between human-readable content and machine computation. Without embeddings, there's no RAG, no semantic search, no modern AI
- **Key point**: Similar meanings → nearby vectors. "Dog" and "puppy" are close. "Dog" and "cryptocurrency" are far apart.

---

## ★ Overview

### Definition

An **embedding** is a mapping from high-dimensional, sparse data (like words, sentences, or images) to a dense, lower-dimensional vector space where semantic relationships are preserved as geometric relationships (distance, direction).

### Scope

Covers: What embeddings are, how they work, types, models, and practical usage. For how embeddings power RAG, see [Retrieval-Augmented Generation (RAG)](../techniques/rag.md). For databases that store them, see [Vector Databases](../tools-and-infra/vector-databases.md).

### Significance

- Foundation of RAG (embedding queries + documents for retrieval)
- Foundation of semantic search (replace keyword matching with meaning matching)
- Used in recommendation systems, anomaly detection, clustering
- Every LLM internally uses embeddings as the first processing step

### Prerequisites

- Basic [Linear Algebra For Ai](../prerequisites/linear-algebra-for-ai.md) — vectors, dot products
- Understanding of what [Large Language Models (LLMs)](../llms/llms-overview.md) do

---

## ★ Deep Dive

### The Core Idea

```
TRADITIONAL REPRESENTATION (sparse, no meaning):
  "cat"  → [0, 0, 0, 1, 0, 0, 0, ..., 0]  (one-hot, 50K+ dimensions)
  "dog"  → [0, 0, 1, 0, 0, 0, 0, ..., 0]
  Problem: "cat" and "dog" are equidistant from each other AND from "quantum"

EMBEDDING REPRESENTATION (dense, captures meaning):
  "cat"  → [0.21, -0.55, 0.89, 0.12, ..., 0.45]  (768-3072 dimensions)
  "dog"  → [0.23, -0.51, 0.85, 0.15, ..., 0.43]  ← CLOSE to cat!
  "quantum" → [-0.67, 0.33, -0.12, 0.91, ..., -0.28]  ← FAR from both
```

### How Embeddings Are Created

```
┌──────────────────────────────────────────────────────────┐
│                  EMBEDDING PIPELINE                       │
│                                                          │
│  Text: "Transformers revolutionized NLP"                 │
│                    │                                     │
│                    ▼                                     │
│  ┌──────────────────────────────────┐                    │
│  │     EMBEDDING MODEL              │                    │
│  │  (trained on massive text pairs) │                    │
│  │                                  │                    │
│  │  "This sentence" ↔ "That sentence"                   │
│  │  Similar? → Vectors close                             │
│  │  Different? → Vectors far                             │
│  └──────────────────┬───────────────┘                    │
│                     ▼                                    │
│  Vector: [0.12, -0.45, 0.89, ..., 0.33]                │
│           └──────── 768-3072 numbers ─────┘              │
└──────────────────────────────────────────────────────────┘
```

### Types of Embeddings

| Type                  | What It Embeds                  | Dimension       | Use Case                   |
| --------------------- | ------------------------------- | --------------- | -------------------------- |
| **Word embeddings**   | Individual words                | 100-300         | Legacy (Word2Vec, GloVe)   |
| **Sentence/Document** | Entire text chunks              | 768-3072        | RAG, semantic search       |
| **Code embeddings**   | Source code                     | 768-1536        | Code search, deduplication |
| **Image embeddings**  | Images                          | 512-2048        | Image search, CLIP         |
| **Multimodal**        | Text AND images in same space   | 512-1024        | Cross-modal search (CLIP)  |
| **Token embeddings**  | Individual tokens (inside LLMs) | Model-dependent | Internal LLM processing    |

### Evolution of Text Embeddings

| Era   | Method                | Key Model                     | How It Works                                                    |
| ----- | --------------------- | ----------------------------- | --------------------------------------------------------------- |
| 2013  | Word2Vec              | Word2Vec                      | Predict context words (skip-gram) or target from context (CBOW) |
| 2014  | GloVe                 | GloVe                         | Global word co-occurrence statistics                            |
| 2018  | Contextual            | ELMo, BERT                    | Same word gets different embeddings based on context            |
| 2020+ | Sentence Transformers | SBERT                         | Fine-tuned BERT for sentence-level similarity                   |
| 2024+ | Instruction-tuned     | text-embedding-3, e5-instruct | Follow instructions like "Represent this for retrieval"         |

**Key breakthrough**: Contextual embeddings. "Bank" in "river bank" vs "bank account" gets DIFFERENT vectors. Pre-contextual embeddings gave it the same vector.

### Current Best Embedding Models (March 2026)

| Model                    | Provider  | Dimensions | Best For                       |
| ------------------------ | --------- | ---------- | ------------------------------ |
| `text-embedding-3-large` | OpenAI    | 3072       | Highest quality (API)          |
| `text-embedding-3-small` | OpenAI    | 1536       | Best budget option (API)       |
| `embed-v4`               | Cohere    | 1024       | Multilingual                   |
| `bge-m3`                 | BAAI      | 1024       | Best open-source, multilingual |
| `e5-mistral-7b-instruct` | Microsoft | 4096       | Highest quality open-source    |
| `nomic-embed-text-v1.5`  | Nomic     | 768        | Good small open-source         |
| `jina-embeddings-v3`     | Jina AI   | 1024       | Task-specific dimensions       |

### Similarity Measurement

```python
import numpy as np

def cosine_similarity(a, b):
    """Most common metric for text embeddings"""
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

# Example:
embed_cat = [0.21, -0.55, 0.89]
embed_dog = [0.23, -0.51, 0.85]
embed_car = [-0.67, 0.33, -0.12]

cosine_similarity(embed_cat, embed_dog)  # → 0.99 (very similar!)
cosine_similarity(embed_cat, embed_car)  # → 0.12 (very different)
```

| Metric                 | When to Use                              | Range   |
| ---------------------- | ---------------------------------------- | ------- |
| **Cosine Similarity**  | Normalized text embeddings (most common) | -1 to 1 |
| **Euclidean Distance** | When magnitude matters                   | 0 to ∞  |
| **Dot Product**        | Already-normalized vectors, fast         | -∞ to ∞ |

---

## ◆ Code & Implementation

```python
# ═══ OPENAI EMBEDDINGS ═══
from openai import OpenAI
client = OpenAI()

response = client.embeddings.create(
    model="text-embedding-3-small",
    input="Transformers use self-attention"
)
vector = response.data[0].embedding  # List of 1536 floats
print(f"Dimensions: {len(vector)}")  # 1536

# ═══ OPEN-SOURCE (Sentence Transformers) ═══
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("BAAI/bge-m3")
texts = ["How does RAG work?", "Retrieval augmented generation explained", "Best pizza in NYC"]
embeddings = model.encode(texts)

# Check similarity
from sklearn.metrics.pairwise import cosine_similarity
sims = cosine_similarity(embeddings)
# texts[0] vs texts[1]: ~0.92 (semantically similar!)
# texts[0] vs texts[2]: ~0.15 (unrelated)

# ═══ LOCAL WITH OLLAMA ═══
import ollama
response = ollama.embeddings(model="nomic-embed-text", prompt="Hello, world!")
vector = response["embedding"]  # 768 dimensions
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                   | ❌ Limitations                                                     |
| --------------------------------------------- | ----------------------------------------------------------------- |
| Capture semantic meaning (synonyms, concepts) | Fixed-size: long documents squeezed into same dimensions as short |
| Enable similarity search at scale             | Black box: hard to interpret what each dimension means            |
| Work across languages (multilingual models)   | Quality depends heavily on model choice                           |
| Cheap to compute and store                    | Domain-specific text may need fine-tuned embeddings               |
| Foundation for RAG, search, recommendations   | Can encode biases from training data                              |

---

## ◆ Quick Reference

```
CHOOSING AN EMBEDDING MODEL:
  Best quality (API): text-embedding-3-large (OpenAI)
  Best budget (API): text-embedding-3-small (OpenAI)
  Best open-source: bge-m3 or e5-mistral-7b
  Multilingual: bge-m3 or Cohere embed-v4
  Local/offline: nomic-embed-text via Ollama

KEY NUMBERS:
  Dimensions: 768-3072 (typical)
  Storage: ~6KB per embedding (1536 dims × 4 bytes)
  1M documents × 1536 dims = ~6 GB storage

SIMILARITY THRESHOLDS (cosine, rough guide):
  > 0.9  = Very similar / near-duplicate
  0.7-0.9 = Related / relevant
  0.4-0.7 = Loosely related
  < 0.4  = Probably unrelated
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Embedding model for index ≠ query model = disaster**: ALWAYS use the same model for embedding documents and queries.
- ⚠️ **Long text ≠ good embedding**: Most models have a max input (~8K tokens). Longer text gets truncated, losing info. Chunk first.
- ⚠️ **Dimensions aren't free**: 3072-dim vectors cost 2x storage/compute vs 1536-dim. Use the smallest that gives acceptable quality.
- ⚠️ **Cosine similarity isn't everything**: Two documents about different aspects of the same topic might have high similarity but not answer the same question. Task-specific fine-tuning helps.
- ⚠️ **Don't ignore the MTEB leaderboard**: The Massive Text Embedding Benchmark ranks models. Check it before choosing.

---

## ○ Interview Angles

- **Q**: What are embeddings and why do they matter for GenAI?
- **A**: Embeddings map data to dense vectors where semantic similarity becomes geometric distance. They're the foundation of RAG (find relevant documents), semantic search (find by meaning), and even the first layer of every LLM. Without embeddings, modern AI can't represent or compare meaning.

- **Q**: What's the difference between word embeddings and sentence embeddings?
- **A**: Word embeddings (Word2Vec, GloVe) encode individual words — "bank" always gets the same vector. Sentence embeddings (SBERT, text-embedding-3) encode entire sentences with context — "river bank" and "bank robbery" get very different vectors. Modern systems use sentence/paragraph embeddings.

---

## ★ Connections

| Relationship | Topics                                                                                |
| ------------ | ------------------------------------------------------------------------------------- |
| Builds on    | [Linear Algebra For Ai](../prerequisites/linear-algebra-for-ai.md), Neural network representations            |
| Leads to     | [Retrieval-Augmented Generation (RAG)](../techniques/rag.md), [Vector Databases](../tools-and-infra/vector-databases.md), Semantic search |
| Compare with | One-hot encoding (sparse), TF-IDF (sparse, frequency-based), Knowledge graphs         |
| Cross-domain | Recommendation systems, Computer vision (image embeddings), Bioinformatics            |

---

## ★ Sources

- Mikolov et al., "Efficient Estimation of Word Representations" (Word2Vec, 2013)
- Reimers & Gurevych, "Sentence-BERT" (2019)
- OpenAI Embeddings documentation — https://platform.openai.com/docs/guides/embeddings
- MTEB Leaderboard — https://huggingface.co/spaces/mteb/leaderboard
