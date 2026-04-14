---
title: "Vector Databases"
tags: [vector-db, embeddings, similarity-search, pinecone, qdrant, chroma, genai-infra]
type: tool
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "tools-overview.md"
related: ["../techniques/rag.md", "../llms/llms-overview.md"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Vector Databases

> ✨ **Bit**: A vector database is just a database where you search by "vibes" instead of exact values. "Find me something similar to this" is literally the query.

---

## ★ TL;DR

- **What**: Databases optimized for storing and searching high-dimensional vectors (embeddings) using similarity metrics
- **Why**: The backbone of RAG, semantic search, recommendation systems — any time you need "find similar things"
- **Key point**: Traditional DBs search by exact match. Vector DBs search by meaning/similarity using distance metrics.

---

## ★ Overview

### Definition

A **Vector Database** stores data as high-dimensional vectors (embeddings) and enables fast approximate nearest-neighbor (ANN) search. When you embed text/images into vectors using an embedding model, a vector DB lets you find the most similar items efficiently.

### Scope

Covers vector DB concepts, comparison of major options, and when to use what. For how vector DBs fit into RAG pipelines, see [Rag](../techniques/rag.md).

### Significance

- Essential component of every RAG system
- Growing from "GenAI niche tool" to mainstream data infrastructure
- Understanding internals (indexing algorithms) = deep tech knowledge

### Prerequisites

- Understanding of embeddings (text → dense vector)
- Basic [Rag](../techniques/rag.md) concepts

---

## ★ Deep Dive

### How It Works

```
TRADITIONAL DATABASE:                    VECTOR DATABASE:
  SELECT * FROM docs                       "Find documents similar to
  WHERE title = 'attention'                 this query about attention"

  → Exact match                            → Semantic similarity
  → Returns: only docs titled              → Returns: docs ABOUT attention
    "attention"                              even if word isn't in title

HOW:
  1. Text → [Embedding Model] → Vector [0.12, -0.45, 0.89, ..., 0.33]
                                         (768-3072 dimensions)
  2. Store vector + metadata in Vector DB
  3. Query → Embed → Find nearest vectors → Return results
```

### Similarity Metrics

| Metric                | Formula Intuition                          | Best For                      |
| --------------------- | ------------------------------------------ | ----------------------------- |
| **Cosine Similarity** | Angle between vectors (ignoring magnitude) | Text embeddings (most common) |
| **Euclidean (L2)**    | Straight-line distance                     | Image embeddings              |
| **Dot Product**       | Magnitude-aware similarity                 | Normalized embeddings         |

```
Cosine Similarity:
  sim(A, B) = (A · B) / (||A|| × ||B||)

  Range: -1 (opposite) to 1 (identical)
  Typical threshold: > 0.7 = "similar"
```

### Indexing Algorithms (How Fast Search Works)

Brute-force search (compare query against ALL vectors) is O(n). At millions of vectors, this is too slow. ANN (Approximate Nearest Neighbor) algorithms trade tiny accuracy loss for massive speed gain.

| Algorithm | How It Works                             | Used By                    | Speed vs Accuracy               |
| --------- | ---------------------------------------- | -------------------------- | ------------------------------- |
| **HNSW**  | Hierarchical graph navigation            | Qdrant, Weaviate, pgvector | Best accuracy, more memory      |
| **IVF**   | Cluster vectors, search nearest clusters | FAISS, Pinecone            | Good balance                    |
| **ScaNN** | Quantize + search                        | Google                     | Very fast, slight accuracy loss |
| **Annoy** | Random projection trees                  | Spotify                    | Fast build, OK accuracy         |

**HNSW** (Hierarchical Navigable Small World) is the most popular — think of it as:

```
Layer 3: [  A  --------  B  ]           (few nodes, long-range links)
Layer 2: [  A  --  C  --  B  --  D  ]   (more nodes, medium links)
Layer 1: [  A - E - C - F - B - G - D ] (all nodes, short links)

Search: Start at top layer, navigate to approximate area,
        then refine at lower layers. O(log n) complexity.
```

### Major Vector Databases Compared

| Database     | Type                  | Strengths                             | Weaknesses                             | Best For                                   |
| ------------ | --------------------- | ------------------------------------- | -------------------------------------- | ------------------------------------------ |
| **Pinecone** | Managed (cloud)       | Serverless, zero ops, fast start      | Cost at scale, vendor lock-in          | Startups, prototypes, managed preference   |
| **Qdrant**   | Self-host + Cloud     | Fast (Rust), rich filtering, best API | Newer, smaller community               | Production self-host, performance-critical |
| **Weaviate** | Self-host + Cloud     | Hybrid search built-in, modules       | Heavier resource use                   | When you need keyword + vector search      |
| **Chroma**   | Embedded (in-process) | Simplest setup, great for dev         | Not for large-scale production         | Prototyping, small datasets, local dev     |
| **Milvus**   | Self-host             | Massive scale, battle-tested          | Complex to operate                     | Very large datasets (billions)             |
| **pgvector** | Postgres extension    | Use existing Postgres!                | Limited scale, basic features          | When you already have Postgres, < 1M docs  |
| **FAISS**    | Library (not DB)      | Fastest ANN, library-level control    | No persistence, no API, just a library | Research, custom pipelines                 |

### Decision Flowchart

```
Do you need a vector DB at all?
├── < 10K documents → Just use FAISS/numpy in memory
├── < 100K documents → pgvector (if you have Postgres) or Chroma
├── 100K - 10M documents → Qdrant, Weaviate, or Pinecone
└── > 10M documents → Milvus or Qdrant (clustered)

Do you want managed or self-hosted?
├── Managed (no ops): Pinecone, Qdrant Cloud, Weaviate Cloud
└── Self-hosted (control): Qdrant, Weaviate, Milvus (Docker)
```

---

## ◆ Code & Implementation

### Quick Start Examples

```python
# ⚠️ Last tested: 2026-04
# ═══ CHROMA (simplest - great for learning) ═══
import chromadb
from chromadb.utils import embedding_functions

# Create client and collection
client = chromadb.Client()  # In-memory, or PersistentClient("./db")
ef = embedding_functions.OpenAIEmbeddingFunction(model_name="text-embedding-3-small")
collection = client.create_collection("my_docs", embedding_function=ef)

# Add documents
collection.add(
    documents=["Transformers use attention", "RAG retrieves context", "LoRA is efficient"],
    ids=["doc1", "doc2", "doc3"],
    metadatas=[{"topic": "arch"}, {"topic": "technique"}, {"topic": "training"}]
)

# Query
results = collection.query(query_texts=["How do language models work?"], n_results=2)
print(results["documents"])  # → Most similar docs
```

```python
# ⚠️ Last tested: 2026-04
# ═══ QDRANT (production-ready) ═══
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance, PointStruct

client = QdrantClient("localhost", port=6333)  # or QdrantClient(":memory:")

# Create collection
client.create_collection(
    collection_name="genai_notes",
    vectors_config=VectorParams(size=1536, distance=Distance.COSINE)
)

# Upsert vectors (you'd get these from an embedding model)
client.upsert(
    collection_name="genai_notes",
    points=[
        PointStruct(id=1, vector=[0.1, 0.2, ...], payload={"text": "...", "topic": "rag"}),
        PointStruct(id=2, vector=[0.3, 0.4, ...], payload={"text": "...", "topic": "lora"}),
    ]
)

# Search
results = client.query_points(
    collection_name="genai_notes",
    query=[0.15, 0.25, ...],  # query embedding
    limit=5,
)
```

```bash
# ═══ DOCKER: Run Qdrant locally ═══
docker run -p 6333:6333 qdrant/qdrant

# ═══ DOCKER: Run Weaviate locally ═══
docker run -p 8080:8080 semitechnologies/weaviate
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                          | ❌ Limitations                               |
| ---------------------------------------------------- | ------------------------------------------- |
| Semantic search ("find similar" not "find exact")    | Approximate — may miss some results         |
| Sub-millisecond search at million-scale              | Embedding quality determines search quality |
| Rich metadata filtering + vector search              | Additional infra to manage                  |
| Growing ecosystem and tooling                        | Each DB has different APIs (no standard)    |
| Critical for RAG, recommendations, anomaly detection | Memory-intensive (vectors are large)        |

---

## ◆ Quick Reference

```
CHOOSING A VECTOR DB:
  Prototyping → Chroma (embedded, zero setup)
  Production (managed) → Pinecone or Qdrant Cloud
  Production (self-host) → Qdrant or Weaviate
  Already have Postgres → pgvector
  Massive scale (billions) → Milvus
  Just need a library → FAISS

KEY PARAMETERS:
  - Distance metric: Cosine (text), L2 (images)
  - Index type: HNSW (best accuracy), IVF (good balance)
  - EF (HNSW): Higher = more accurate, slower search
  - Segment size: Tune for memory vs speed

EMBEDDING DIMENSIONS:
  text-embedding-3-small: 1536
  text-embedding-3-large: 3072
  bge-m3: 1024
  nomic-embed-text: 768
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Embedding model matters more than the DB**: A bad embedding model with Pinecone will perform worse than a good one with Chroma.
- ⚠️ **Don't forget metadata filtering**: Most queries need both vector similarity AND metadata filters (e.g., "similar to X AND category = 'tutorials'").
- ⚠️ **pgvector is good enough for most**: Don't adopt a specialized vector DB if pgvector in your existing Postgres handles your scale.
- ⚠️ **Index before you search**: Without building an index (HNSW/IVF), searches fall back to brute-force and become slow.
- ⚠️ **Embedding mismatch**: The model that embeds documents MUST be the same model that embeds queries. Mixing models = garbage results.

---

## ○ Interview Angles

- **Q**: How does approximate nearest neighbor search work?
- **A**: ANN algorithms like HNSW build a graph structure where similar vectors are connected. Search starts from random entry points and greedily navigates toward the query vector through the graph. It's O(log n) vs O(n) for brute force, with ~95-99% recall.

- **Q**: How would you choose between Pinecone and self-hosting Qdrant?
- **A**: Pinecone: zero ops, serverless pricing, fast start. Qdrant self-host: lower cost at scale, data stays on your infra, more control over indexing. Decision factors: team size, data sensitivity, query volume, and operational expertise.

---

## ★ Connections

| Relationship | Topics                                                                        |
| ------------ | ----------------------------------------------------------------------------- |
| Builds on    | Embeddings, Similarity search, [Llms Overview](../llms/llms-overview.md)                      |
| Leads to     | [Rag](../techniques/rag.md), Semantic search engines, Recommendation systems        |
| Compare with | Traditional databases (SQL), Search engines (Elasticsearch), Knowledge graphs |
| Cross-domain | Information retrieval, Computational geometry (nearest neighbor)              |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Index staleness** | New documents not found in search | Ingestion pipeline lag, no real-time indexing | Streaming ingestion, write-ahead log, refresh intervals |
| **Recall vs latency tradeoff** | High recall requires seconds-long queries | Exact search too slow, ANN too lossy | Tune HNSW parameters (ef, M), benchmark your data distribution |
| **Embedding model lock-in** | Cannot switch embedding models without full re-index | Vectors are model-specific | Abstract embedding layer, plan for re-indexing, Matryoshka |
| **Metadata filter performance** | Filtered queries 10x slower than unfiltered | Poor metadata indexing, post-retrieval filtering | Pre-filtered ANN, composite indexes, partition by metadata |

---

## ◆ Hands-On Exercises

### Exercise 1: Benchmark Vector DB Performance

**Goal**: Compare retrieval quality and latency across vector databases
**Time**: 30 minutes
**Steps**:
1. Prepare 10K vectors from a real embedding model
2. Index in Chroma and a managed solution (Pinecone or Qdrant)
3. Run 100 queries, measure recall@10 and p95 latency
4. Test with metadata filters and measure impact
**Expected Output**: Performance comparison table with recall, latency, and filtered performance
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [Qdrant Documentation](https://qdrant.tech/documentation/) | Excellent open-source vector DB with filtering support |
| 🔧 Hands-on | [Pinecone Documentation](https://docs.pinecone.io/) | Managed vector DB — easiest to start with |
| 📄 Paper | [Johnson et al. "FAISS" (2017)](https://arxiv.org/abs/1702.08734) | Foundational nearest-neighbor search algorithms |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 3 | Vector search in the context of RAG systems |

## ★ Sources

- Pinecone Learning Center — https://www.pinecone.io/learn/
- Qdrant documentation — https://qdrant.tech/documentation/
- Weaviate documentation — https://weaviate.io/developers/weaviate
- Chroma documentation — https://docs.trychroma.com
- "HNSW algorithm explained" — https://www.pinecone.io/learn/series/faiss/hnsw/
