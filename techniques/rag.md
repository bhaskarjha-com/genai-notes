---
title: "Retrieval-Augmented Generation (RAG)"
aliases: ["RAG", "Retrieval-Augmented Generation"]
tags: [rag, retrieval, embeddings, vector-db, genai-techniques]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["fine-tuning.md", "../llms/llms-overview.md", "../agents/ai-agents.md"]
source: "Lewis et al., 2020 + latest hybrid RAG techniques"
created: 2026-03-18
updated: 2026-04-15
---

# Retrieval-Augmented Generation (RAG)

> ✨ **Bit**: RAG is like giving the LLM an open-book exam instead of asking it to recall everything from memory. Turns out, even AI does better with notes.

---

## ★ TL;DR

- **What**: A pattern that retrieves relevant external documents and feeds them to an LLM as context before generation
- **Why**: Fixes hallucination, enables up-to-date answers, works with private data — WITHOUT retraining the model
- **Key point**: The dominant technique for enterprise GenAI. If you're building GenAI products, you ARE building RAG pipelines.

---

## ★ Overview

### Definition

**RAG (Retrieval-Augmented Generation)** is an architecture that combines information retrieval with text generation. Instead of relying solely on the LLM's parametric knowledge (what it memorized during training), RAG retrieves relevant documents from an external knowledge base at query time and includes them in the prompt.

### Scope

This document covers RAG architecture, pipeline components, and advanced patterns. For embedding models and vector databases, see [Vector Databases](../tools-and-infra/vector-databases.md). For combining RAG with fine-tuning, see [Fine Tuning](./fine-tuning.md).

### Significance

- **Most deployed GenAI pattern in production** (2024-2026)
- Solves: Hallucination, knowledge cutoff, private data access
- Doesn't require: Retraining or fine-tuning the LLM
- Industry standard for: Enterprise Q&A, customer support, document intelligence

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) — what LLMs are and how they work
- Basic understanding of embeddings (vector representations of text)

---

## ★ Deep Dive

### The Basic RAG Pipeline

```
┌──────────────────────────────────────────────────────────────┐
│                      RAG PIPELINE                            │
│                                                              │
│  INDEXING (one-time / periodic)                              │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌─────────┐  │
│  │ Documents│ → │ Chunking │ → │ Embedding│ → │ Vector  │  │
│  │ (raw)    │   │ (split)  │   │ (encode) │   │ DB      │  │
│  └──────────┘   └──────────┘   └──────────┘   └─────────┘  │
│                                                              │
│  RETRIEVAL + GENERATION (per query)                          │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌─────────┐  │
│  │ User     │ → │ Embed    │ → │ Search   │ → │ Top-K   │  │
│  │ Query    │   │ Query    │   │ Vector DB│   │ Chunks  │  │
│  └──────────┘   └──────────┘   └──────────┘   └────┬────┘  │
│                                                      │       │
│  ┌──────────────────────────────────────────────────┐│       │
│  │ PROMPT = System Instructions + Retrieved Chunks + Query  ││
│  └──────────────────────────────────────┬───────────┘│       │
│                                         ↓            │       │
│                                    ┌─────────┐               │
│                                    │  LLM    │               │
│                                    │ Generate│               │
│                                    └────┬────┘               │
│                                         ↓                    │
│                                    ┌─────────┐               │
│                                    │ Answer  │               │
│                                    │ + Cited │               │
│                                    │ Sources │               │
│                                    └─────────┘               │
└──────────────────────────────────────────────────────────────┘
```

### Pipeline Components Deep Dive

#### 1. Document Loading & Processing
```python
# Common formats: PDF, DOCX, HTML, Markdown, CSV, code files
# Key challenge: Preserving structure (tables, headers, lists)

# Tools: LangChain loaders, Unstructured.io, LlamaIndex readers
```

#### 2. Chunking (CRITICAL — where most pipelines fail)

```
Strategy           | Chunk Size | Overlap | When to Use
────────────────────────────────────────────────────────
Fixed size          | 500-1000   | 100-200 | Quick start, general docs
Recursive splitting | 500-1000   | 100-200 | Text with natural hierarchy
Semantic            | Variable   | N/A     | When meaning boundaries matter
Document-based      | Full doc   | N/A     | Short docs (emails, tickets)
Sentence-level      | 1-3 sents  | N/A     | Q&A, precise retrieval

⚠️ GOTCHA: Bad chunking = bad retrieval = bad answers.
   If your RAG sucks, fix chunking FIRST.
```

#### 3. Embedding Models

Convert text chunks and queries into high-dimensional vectors for similarity search.

| Model                           | Dimensions | Strengths                            |
| ------------------------------- | ---------- | ------------------------------------ |
| OpenAI `text-embedding-3-large` | 3072       | Best quality, API, Matryoshka dims   |
| **Gemini text-embedding-004**          | Flexible   | Multimodal! (text+image+video+audio) |
| Cohere `embed-v4`               | 1024       | Best multilingual (100+ languages)   |
| Voyage AI `voyage-3-large`      | —          | Best for code & technical docs       |
| `bge-m3` (BAAI)                 | 1024       | Best open-source, hybrid retrieval   |
| `nomic-embed-v2`                | 768        | Best for local/edge deployment       |

#### 4. Vector Database

| Database     | Type               | Key Feature                      |
| ------------ | ------------------ | -------------------------------- |
| **Pinecone** | Managed            | Serverless, easiest to start     |
| **Weaviate** | Self-host/Managed  | Hybrid search (vector + keyword) |
| **Qdrant**   | Self-host/Managed  | Best Rust performance            |
| **Chroma**   | Embedded           | Simplest for prototyping         |
| **pgvector** | Postgres extension | Use existing Postgres            |
| **FAISS**    | Library (Meta)     | Fast local search, no server     |

#### 5. Retrieval Strategies

| Strategy            | How                                               | When                     |
| ------------------- | ------------------------------------------------- | ------------------------ |
| **Semantic search** | Cosine similarity on embeddings                   | Default                  |
| **Keyword (BM25)**  | Traditional text matching                         | Technical terms, names   |
| **Hybrid**          | Combine semantic + keyword                        | Best overall performance |
| **Re-ranking**      | Retrieve broadly, then re-rank with cross-encoder | Quality-critical apps    |
| **HyDE**            | Generate hypothetical answer, search with that    | Vague queries            |
| **Multi-query**     | Generate multiple query variants, merge results   | Complex questions        |

### Advanced RAG Patterns (2025-2026)

```
Basic RAG
  └→ Advanced RAG
       ├── Hybrid Search (semantic + BM25)
       ├── Re-ranking (Cohere Rerank, cross-encoders)
       ├── Query Transformation (HyDE, multi-query, step-back)
       ├── Self-RAG (model decides when to retrieve)
       ├── Late Chunking (embed full doc, pool after)           ← 2025-2026 standard
       ├── Contextual Retrieval (LLM-enrich each chunk)        ← Anthropic 2024→standard
       ├── Corrective RAG / CRAG (grade + re-retrieve/search)  ← 2026 agentic pattern
       └→ Agentic RAG
            ├── Tool-calling RAG (agent decides what to search)
            ├── Multi-source RAG (different DBs, APIs, web)
            └── Multi-step RAG (iterative retrieval-reasoning loops)
```

### Late Chunking (2025-2026 Standard for Long-Doc Retrieval)

**Problem with traditional chunking**: Splitting first loses cross-chunk context. A chunk about "the CEO's decision" has no embedding signal about *which company* or *which decision* if those appear in earlier paragraphs.

**Late Chunking** reverses the order:

```
Traditional:  Document → Chunk → Embed each chunk → Store
Late:         Document → Embed FULL document (token-level) → Pool tokens per logical chunk → Store

Result: Each chunk's embedding retains context from the surrounding document.
```

```python
# pip install transformers>=4.45 torch>=2.3
# ⚠️ Last tested: 2026-04 | Requires: jina-embeddings-v3 or nomic-embed-text-v2
# PSEUDOCODE — illustrative of the late chunking concept

from transformers import AutoTokenizer, AutoModel
import torch

def late_chunking_embed(document: str, chunk_boundaries: list[tuple[int,int]], model_name: str = "jinaai/jina-embeddings-v3"):
    """Embed at token level, then pool into chunk-level embeddings."""
    tokenizer = AutoTokenizer.from_pretrained(model_name, trust_remote_code=True)
    model = AutoModel.from_pretrained(model_name, trust_remote_code=True)

    # 1. Tokenize the FULL document (not individual chunks)
    inputs = tokenizer(document, return_tensors="pt", truncation=True, max_length=8192)

    with torch.no_grad():
        # 2. Get token-level embeddings (contextually aware of full document)
        outputs = model(**inputs)
        token_embeddings = outputs.last_hidden_state[0]  # shape: [n_tokens, hidden_dim]

    # 3. Pool token embeddings per logical chunk boundary
    chunk_embeddings = []
    tokens = tokenizer.convert_ids_to_tokens(inputs["input_ids"][0])
    for char_start, char_end in chunk_boundaries:
        # Find token indices corresponding to this char range
        token_start, token_end = char_to_token_range(inputs, char_start, char_end)
        chunk_vec = token_embeddings[token_start:token_end].mean(dim=0)  # mean pool
        chunk_embeddings.append(chunk_vec)
    return chunk_embeddings

# Supported models: jinaai/jina-embeddings-v3, nomic-ai/nomic-embed-text-v2-moe
```

**When to use**: Long documents (reports, legal docs, books) where a chunk's meaning depends on earlier context. Outperforms standard chunking by 10-20% on multi-hop retrieval benchmarks.

### Contextual Retrieval (Anthropic, 2024 → 2026 Production Standard)

**Problem**: BM25 and semantic search fail when chunks use pronouns or references ("the approach," "this method") without repeating the noun.

**Solution**: Use an LLM to prepend a *context string* to each chunk before embedding.

```python
# pip install anthropic>=0.34
# ⚠️ Last tested: 2026-04 | Requires: anthropic>=0.34, ANTHROPIC_API_KEY
# Cost note: use prompt caching — cache the full document, vary only per chunk

import anthropic

client = anthropic.Anthropic()

CONTEXT_PROMPT = """<document>
{full_document}
</document>
Here is the chunk we want to situate within the whole document:
<chunk>
{chunk_content}
</chunk>
Please give a short succinct context (1-2 sentences) to situate this chunk within the overall document
for the purpose of improving search retrieval. Answer only with the succinct context."""

def add_chunk_context(full_document: str, chunk: str) -> str:
    """Prepend LLM-generated context to a chunk before embedding."""
    response = client.messages.create(
        model="claude-3-5-haiku-20241022",  # cheapest Haiku for speed
        max_tokens=150,
        messages=[{"role": "user", "content": CONTEXT_PROMPT.format(
            full_document=full_document,
            chunk_content=chunk
        )}]
    )
    context = response.content[0].text.strip()
    return f"{context}\n\n{chunk}"  # prepend context, embed the combined string

# Cost optimization: use prompt caching on the document prefix
# Anthropic claims 49% retrieval improvement + 67% with hybrid (BM25 + semantic)
enriched_chunk = add_chunk_context(full_document="...", chunk="This approach...")
```

### Corrective RAG / CRAG — Grade → Decide → Act

When retrieved chunks are irrelevant, CRAG falls back to web search or query reformulation:

```
Query
  ↓
[Retrieve] → chunks
  ↓
[Grade each chunk: RELEVANT / IRRELEVANT / AMBIGUOUS]
  ↓
If ALL irrelevant → [Web Search] or [Reformulate Query] → [Re-retrieve]
If SOME relevant → [Filter to relevant chunks only]
  ↓
[Generate answer from filtered/searched context]
```

```python
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60
# PSEUDOCODE — the grading + fallback pattern

from openai import OpenAI
import json

client = OpenAI()

def grade_chunk_relevance(question: str, chunk: str) -> str:
    """Grade retrieved chunk as relevant or not. Returns 'yes' or 'no'."""
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": (
                f"Is the following document relevant to answering the question?\n\n"
                f"Question: {question}\n\nDocument: {chunk[:500]}\n\n"
                f"Answer with JSON: {{\"relevant\": true/false}}"
            )
        }],
        temperature=0,
        response_format={"type": "json_object"},
    )
    result = json.loads(resp.choices[0].message.content)
    return "yes" if result.get("relevant") else "no"

def corrective_rag(question: str, retrieved_chunks: list[str], web_search_fn=None) -> str:
    """CRAG: filter irrelevant chunks, fall back to web search if needed."""
    relevant = [c for c in retrieved_chunks if grade_chunk_relevance(question, c) == "yes"]

    if not relevant:
        # Fall back to web search (tavily, serper, brave search APIs)
        if web_search_fn:
            relevant = web_search_fn(question)
        else:
            return "I don't have reliable information to answer this."

    context = "\n\n".join(relevant)
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "Answer based on context only. Be concise."},
            {"role": "user", "content": f"Context:\n{context}\n\nQuestion: {question}"}
        ]
    )
    return resp.choices[0].message.content
```

### Reciprocal Rank Fusion (RRF) — Combining Multiple Retrieval Lists

RRF merges ranked lists from multiple retrieval methods (semantic + BM25 + metadata) without needing score normalization:

```
RRF(document d) = Σ_i  1 / (k + rank_i(d))
  where: k = 60 (constant, empirically validated), rank_i = rank in list i
```

```python
# ⚠️ Last tested: 2026-04 | Requires: Python 3.10+ (stdlib only)
from collections import defaultdict

def reciprocal_rank_fusion(ranked_lists: list[list[str]], k: int = 60) -> list[tuple[str, float]]:
    """
    Combine multiple ranked retrieval lists using RRF.
    Input: list of lists, each sorted by relevance (best first).
    Output: combined list sorted by fused score (best first).
    """
    scores: dict[str, float] = defaultdict(float)
    for ranked_list in ranked_lists:
        for rank, doc_id in enumerate(ranked_list, start=1):
            scores[doc_id] += 1.0 / (k + rank)
    return sorted(scores.items(), key=lambda x: x[1], reverse=True)

# Example: combine semantic search + BM25 results
semantic_results = ["doc_3", "doc_1", "doc_7", "doc_2", "doc_5"]  # ordered by cosine sim
bm25_results     = ["doc_1", "doc_3", "doc_8", "doc_5", "doc_4"]  # ordered by BM25 score

fused = reciprocal_rank_fusion([semantic_results, bm25_results])
top_5 = [doc_id for doc_id, _ in fused[:5]]
print(f"Fused top-5: {top_5}")
# → doc_1 and doc_3 both appear in both lists at high ranks → RRF promotes them
```

### RAG vs Fine-tuning vs Long Context

| Aspect        | RAG                              | Fine-tuning                 | Long Context             |
| ------------- | -------------------------------- | --------------------------- | ------------------------ |
| **When**      | Need up-to-date/private data     | Need changed behavior/style | All info fits in context |
| **Cost**      | Low (retrieval infra)            | Medium (training compute)   | High (per-token cost)    |
| **Latency**   | +retrieval time                  | Same as base model          | Increases with context   |
| **Knowledge** | Dynamic, updatable               | Static (baked in)           | Dynamic (in prompt)      |
| **Best for**  | Enterprise docs, knowledge bases | Domain-specific models      | Small document sets      |

**2025-2026 consensus**: Hybrid RAG + LoRA fine-tuning is the gold standard. RAG for facts, fine-tuning for behavior.

---

## ◆ Code & Implementation

### Minimal RAG with LangChain (Python)

```python
# pip install langchain>=0.3 langchain-openai>=0.3 langchain-community>=0.3 chromadb>=0.5
# ⚠️ Last tested: 2026-04 | Requires: langchain>=0.3

from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings, ChatOpenAI
from langchain_community.vectorstores import Chroma
from langchain.chains import create_retrieval_chain
from langchain.chains.combine_documents import create_stuff_documents_chain
from langchain_core.prompts import ChatPromptTemplate

# 1. Load & Chunk
loader = PyPDFLoader("your_document.pdf")
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " "]
)
chunks = splitter.split_documents(docs)

# 2. Embed & Store
embeddings = OpenAIEmbeddings(model="text-embedding-3-small")
vectorstore = Chroma.from_documents(chunks, embeddings)

# 3. Build Retrieval Chain (modern LangChain pattern)
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 5}
)

llm = ChatOpenAI(model="gpt-4o", temperature=0)

prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer based only on the provided context. If unsure, say so.\n\nContext:\n{context}"),
    ("human", "{input}"),
])

question_answer_chain = create_stuff_documents_chain(llm, prompt)
rag_chain = create_retrieval_chain(retriever, question_answer_chain)

result = rag_chain.invoke({"input": "What are the key findings?"})
print(result["answer"])
# result["context"] contains the retrieved source documents
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                | ❌ Limitations                                         |
| ------------------------------------------ | ----------------------------------------------------- |
| No model retraining needed                 | Retrieval quality bottleneck                          |
| Always up-to-date (update docs, not model) | Chunking is hard to get right                         |
| Cites sources (traceable)                  | Adds latency (retrieval step)                         |
| Works with private/proprietary data        | Context window limits how much retrieved context fits |
| Cheaper than fine-tuning                   | Can't change model behavior, only provide info        |

---

## ◆ Quick Reference

```
RAG Pipeline:
  Documents → Chunk → Embed → Store in Vector DB
  Query → Embed → Search → Top-K Chunks → LLM → Answer

Key Params to Tune:
  - Chunk size: 500-1000 chars (start here)
  - Chunk overlap: ~20% of chunk size
  - Top-K: 3-10 chunks (more = more context, more noise)
  - Embedding model: text-embedding-3-small (budget) or large (quality)
  - Search type: Hybrid (semantic + BM25) when possible

Quick Debug:
  Bad answers? → Check retrieved chunks first
  Irrelevant chunks? → Fix chunking or embedding model
  Good chunks, bad answer? → Fix prompt or try better LLM
```

---

### RAG Evaluation Metrics (RAG Triad)

```
THE RAG TRIAD — 3 metrics that cover everything:

  1. CONTEXT RELEVANCE (retrieval quality)
     "Are the retrieved chunks actually relevant to the question?"
     Metric: What % of retrieved context is useful
     Low score → Fix: chunking strategy, embedding model, or retrieval method

  2. FAITHFULNESS / GROUNDEDNESS (hallucination check)
     "Is the answer supported by the retrieved context?"
     Metric: What % of claims in the answer can be traced to context
     Low score → Fix: LLM prompt (cite sources), temperature, or model choice

  3. ANSWER RELEVANCE (response quality)
     "Does the answer actually address the question?"
     Metric: How well does the answer match the user's intent
     Low score → Fix: prompt template, LLM model, or retrieval strategy

  ┌─────────────┐      ┌────────────┐      ┌─────────────┐
  │   Question  │──1──▶│  Context   │──2──▶│   Answer    │
  │             │      │ (retrieved)│      │ (generated) │
  └──────┬──────┘      └────────────┘      └──────┬──────┘
         │                                        │
         └──────────────3──────────────────────────┘

  1 = Context Relevance   2 = Faithfulness   3 = Answer Relevance

EVALUATION TOOLS:
  RAGAS          — most popular, uses LLM-as-judge, supports all 3 metrics
  DeepEval       — unit-test style, CI/CD friendly
  TruLens        — real-time monitoring, tracing
  LangSmith      — LangChain's eval + tracing platform
  Arize Phoenix  — open-source LLM observability
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **"Garbage in, garbage out"**: If your chunking splits a table across chunks, the answer will be wrong. Always inspect chunks.
- ⚠️ **Embedding model mismatch**: embedding model for indexing MUST match the one used for querying
- ⚠️ **Over-retrieving**: More chunks ≠ better. Too many chunks adds noise and can confuse the LLM.
- ⚠️ **Ignoring hybrid search**: Pure semantic search misses exact keywords, names, IDs. Always consider BM25 + semantic.
- ⚠️ **Not evaluating**: Most teams deploy RAG without measuring retrieval quality. Use RAGAS, DeepEval, or at minimum test manually.

---

## ○ Interview Angles

- **Q**: How would you improve a RAG pipeline that's giving wrong answers?
- **A**: Debug in order: (1) Check if correct chunks are retrieved (retrieval eval), (2) If not, fix chunking strategy or embedding model, (3) If chunks are good but answer is wrong, fix the prompt or use a better LLM. Also consider adding re-ranking.

- **Q**: When would you choose RAG over fine-tuning?
- **A**: RAG when: need up-to-date info, knowledge changes frequently, need source attribution. Fine-tuning when: need different output style/format, domain-specific reasoning, or model behavior changes. Best: combine both (Hybrid RAG).

- **Q**: Explain the difference between semantic and keyword search in RAG.
- **A**: Semantic (vector) search finds conceptually similar content even with different words ("car" matches "automobile"). Keyword (BM25) search finds exact term matches. Hybrid combines both — best overall because semantic misses exact terms and BM25 misses synonyms.

---

## ★ Connections

| Relationship | Topics                                                                         |
| ------------ | ------------------------------------------------------------------------------ |
| Builds on    | [Llms Overview](../llms/llms-overview.md), Embeddings, Vector Search                           |
| Leads to     | [Ai Agents](../agents/ai-agents.md) (Agentic RAG), [Vector Databases](../tools-and-infra/vector-databases.md)           |
| Compare with | [Fine Tuning](./fine-tuning.md) (changes model), Long-context (no retrieval), Knowledge graphs |
| Cross-domain | Information retrieval (IR), Search engines                                     |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Context poisoning** | LLM generates confidently wrong answers with citations | Irrelevant or contradictory chunks retrieved | Reranking layer (cross-encoder), relevance score thresholds |
| **Stale embeddings** | Correct docs exist but aren't retrieved | New docs added without re-embedding, index not refreshed | Incremental indexing pipeline, TTL on embeddings |
| **Chunk boundary loss** | Answers miss key information that spans two chunks | Important context split across chunk boundaries | Overlapping chunks, parent-document retrieval, Late Chunking |
| **Retrieval drift** | Quality degrades over weeks without code changes | User query distribution shifts away from test queries | Continuous retrieval eval (MRR/nDCG), query log monitoring |
| **Context window overflow** | Token limit errors or truncated context | Too many chunks retrieved, no length management | Dynamic k selection, token-budget-aware retrieval |
| **Chunk context loss** | Answers miss cross-chunk references ("this approach") | Chunks embedded without surrounding document context | Contextual Retrieval (LLM-enrich) or Late Chunking |
| **Retrieval grade blindness** | CRAG/Adaptive RAG degrades without grader feedback | No mechanism to detect and correct poor retrieval | Add relevance grader node; fall back to web search on low scores |

---

## ◆ Hands-On Exercises

### Exercise 1: Build and Break a RAG Pipeline

**Goal**: Build a minimal RAG pipeline, then systematically break it with adversarial queries
**Time**: 45 minutes
**Steps**:
1. Load a 10-page PDF with PyPDFLoader
2. Chunk with RecursiveCharacterTextSplitter (1000 chars, 200 overlap)
3. Embed with text-embedding-3-small, store in Chroma
4. Query with 5 normal questions — log retrieval scores
5. Query with 5 adversarial queries (ambiguous, multi-hop, out-of-scope) — document failures
**Expected Output**: Table comparing retrieval precision for normal vs adversarial queries

### Exercise 2: Add a Reranking Layer

**Goal**: Add a cross-encoder reranker and measure retrieval quality improvement
**Time**: 30 minutes
**Steps**:
1. Take the pipeline from Exercise 1
2. Add sentence-transformers cross-encoder reranking on top-20 results
3. Re-run the same 10 queries
4. Compare MRR@5 before and after reranking
**Expected Output**: MRR improvement of 15-30% on adversarial queries
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Lewis et al. "Retrieval-Augmented Generation" (2020)](https://arxiv.org/abs/2005.11401) | The original RAG paper |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 3-4 | Best practical treatment of RAG architecture and evaluation |
| 🎓 Course | [deeplearning.ai — "Building and Evaluating RAG"](https://www.deeplearning.ai/) | Hands-on RAG implementation course |
| 🔧 Hands-on | [LlamaIndex RAG Tutorial](https://docs.llamaindex.ai/) | Production RAG framework with excellent documentation |

## ★ Sources

- Lewis et al., "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks" (2020)
- LangChain documentation — https://docs.langchain.com
- LlamaIndex documentation — https://docs.llamaindex.ai
- RAGAS evaluation framework — https://docs.ragas.io
