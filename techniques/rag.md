---
title: "Retrieval-Augmented Generation (RAG)"
tags: [rag, retrieval, embeddings, vector-db, genai-techniques]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "[[../genai]]"
related: ["[[fine-tuning]]", "[[../llms/llms-overview]]", "[[../agents/ai-agents]]"]
source: "Lewis et al., 2020 + latest hybrid RAG techniques"
created: 2026-03-18
updated: 2026-04-11
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
       ├── CRAG (Corrective RAG — verify retrieval quality)
       └→ Agentic RAG
            ├── Tool-calling RAG (agent decides what to search)
            ├── Multi-source RAG (different DBs, APIs, web)
            └── Multi-step RAG (iterative retrieval-reasoning loops)
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
