---
title: "Graph RAG & Advanced Retrieval"
tags: [graph-rag, knowledge-graph, multi-hop-reasoning, graphrag, agentic-rag, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[rag]]", "[[ai-agents]]", "[[context-engineering]]", "[[../tools-and-infra/vector-databases]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Graph RAG & Advanced Retrieval

> ✨ **Bit**: Standard RAG is like searching a library by keyword — you find relevant pages but miss the connections. Graph RAG is like having a librarian who understands that "Einstein worked at Princeton, Princeton is in New Jersey, New Jersey passed X law" — it reasons across RELATIONSHIPS, not just similarity.

---

## ★ TL;DR

- **What**: RAG enhanced with knowledge graphs for structured reasoning and multi-hop retrieval
- **Why**: Vector RAG fails at complex questions requiring relationship traversal, aggregation, or multi-step reasoning. Graph RAG fills this gap.
- **Key point**: Microsoft open-sourced GraphRAG in 2024, sparking massive adoption. By 2026, Graph RAG + Agentic RAG = the production standard for complex enterprise AI.

---

## ★ Overview

### Definition

**Graph RAG** augments retrieval with entities and relationships so the system can reason over structure, not only semantic similarity.

### Scope

This note focuses on why graph-based retrieval helps, how it differs from vector-only RAG, and where it fits in advanced enterprise knowledge systems.

### Significance

- It addresses multi-hop and aggregation-heavy questions that standard vector retrieval often handles poorly.
- It is especially relevant for complex enterprise assistants, document intelligence, and agentic reasoning workflows.

---

## ★ Deep Dive

### Why Vector RAG Fails

```
QUESTION: "Which departments had the highest attrition
           among employees hired in the last 2 years?"

VECTOR RAG:
  1. Embed question → search vector DB
  2. Get chunks about "attrition" and "hiring"
  3. Chunks are from DIFFERENT docs, no connection
  4. LLM tries to combine → often wrong or hallucinated
  ❌ Can't aggregate across entities
  ❌ Can't traverse relationships

GRAPH RAG:
  1. Knowledge graph has: Employee → Department → HireDate → Status
  2. Query traverses: Employees(hired < 2 years) → filter(left) → group(department)
  3. Structured, verified answer with exact numbers
  ✅ Aggregation across entities
  ✅ Multi-hop reasoning via graph traversal
```

### Vector RAG vs Graph RAG

```
VECTOR RAG                           GRAPH RAG
(similarity search)                  (relationship traversal)

  Docs → Chunks → Embeddings         Docs → Entities → Relationships
     ↓                                   ↓
  Query → Similar chunks              Query → Graph traversal
     ↓                                   ↓
  "Find texts about X"               "Find entities connected to X
                                       via relationship Y"

  ✅ Simple to set up                ✅ Multi-hop reasoning
  ✅ Works for direct Q&A            ✅ Aggregation queries
  ✅ Fast retrieval                  ✅ Structured/verified answers
  ❌ No relationship awareness       ❌ Expensive graph construction
  ❌ Fails at aggregation            ❌ More complex pipeline
  ❌ Multi-hop failures              ❌ Needs entity extraction
```

### How Graph RAG Works (Microsoft GraphRAG)

```
INDEXING PHASE:
  ┌──────────────────────────────────────────────┐
  │  1. ENTITY EXTRACTION                        │
  │     LLM reads documents, extracts:            │
  │     - Entities: "Albert Einstein", "Princeton"│
  │     - Relationships: "worked at", "located in"│
  │                                              │
  │  2. BUILD KNOWLEDGE GRAPH                     │
  │     Entities = nodes, Relationships = edges   │
  │     [Einstein]──works_at──▶[Princeton]        │
  │     [Princeton]──located_in──▶[New Jersey]    │
  │                                              │
  │  3. COMMUNITY DETECTION                       │
  │     Cluster related entities into communities │
  │     Community: "Princeton Academic Network"   │
  │                                              │
  │  4. COMMUNITY SUMMARIES                       │
  │     LLM summarizes each community             │
  │     "Princeton University, founded in 1746,   │
  │      notable faculty include Einstein..."     │
  └──────────────────────────────────────────────┘

QUERY PHASE:
  ┌──────────────────────────────────────────────┐
  │  LOCAL SEARCH (specific questions):           │
  │    Entity lookup → traverse related entities  │
  │    → gather context → LLM generates answer   │
  │                                              │
  │  GLOBAL SEARCH (thematic questions):          │
  │    Search all community summaries             │
  │    → map: each community answers partially    │
  │    → reduce: combine into final answer        │
  │    "What are the main themes in this dataset?"│
  └──────────────────────────────────────────────┘
```

### Agentic RAG (2025-2026 Standard)

```
AGENTIC RAG = RAG + Agent autonomy

  Standard RAG:
    Query → Retrieve → Generate (fixed pipeline)

  Agentic RAG:
    Query → Agent DECIDES:
      "What do I need to answer this?"
      ├── Vector search? (semantic similarity)
      ├── Graph query? (relationship traversal)
      ├── SQL query? (structured data)
      ├── Web search? (real-time data)
      ├── Rewrite query? (ambiguous question)
      └── Ask for clarification? (insufficient info)

    Agent can:
      - Self-correct: "These results aren't relevant, let me refine"
      - Multi-step: Retrieve → reason → retrieve more → answer
      - Verify: "Let me cross-check this claim"
      - Route: Different retrieval strategies for different sub-questions

  ┌────────────────────────────────────────────────┐
  │  AGENTIC RAG ARCHITECTURE                      │
  │                                                │
  │  User Query                                    │
  │      │                                         │
  │      ▼                                         │
  │  ┌────────────┐                                │
  │  │   ROUTER    │ ← "What type of question?"    │
  │  │   AGENT     │                                │
  │  └──┬───┬───┬──┘                               │
  │     │   │   │                                  │
  │  ┌──▼┐ ┌▼──┐ ┌▼──────┐                        │
  │  │Vec│ │KG │ │SQL/API│                         │
  │  │DB │ │   │ │       │                         │
  │  └──┬┘ └┬──┘ └┬──────┘                        │
  │     │   │     │                                │
  │     ▼   ▼     ▼                                │
  │  ┌────────────────┐                            │
  │  │  SYNTHESIZER   │ ← Combine, verify, reason  │
  │  │  AGENT         │                            │
  │  └───────┬────────┘                            │
  │          ▼                                     │
  │  ┌────────────────┐                            │
  │  │  SELF-CHECK    │ ← "Is my answer grounded?" │
  │  └───────┬────────┘                            │
  │          ▼                                     │
  │     Final Answer                               │
  └────────────────────────────────────────────────┘
```

### When to Use What

| Approach                        | Best For                                            | Complexity                 |
| ------------------------------- | --------------------------------------------------- | -------------------------- |
| **Basic RAG**                   | Simple Q&A over documents                           | Low                        |
| **Hybrid RAG** (vector + BM25)  | Most production use cases                           | Medium                     |
| **Graph RAG**                   | Multi-hop reasoning, entity-heavy data, aggregation | High                       |
| **Agentic RAG**                 | Complex queries needing dynamic strategy            | High                       |
| **Long Context** (no retrieval) | Small doc sets, full cross-referencing              | Low (but expensive)        |
| **Graph + Agentic**             | Enterprise knowledge systems                        | Highest (but most capable) |

---

## ◆ Quick Reference

```
GRAPH RAG DECISION:
  Simple factual Q&A?         → Vector RAG is fine
  "How many X have Y?"        → Graph RAG (aggregation)
  "What connects A to B?"     → Graph RAG (traversal)
  Complex multi-source query? → Agentic RAG
  Both structured + unstructured data? → Graph + Agentic RAG

KNOWLEDGE GRAPH TOOLS:
  Neo4j          — industry standard graph DB
  Amazon Neptune — managed graph DB (AWS)
  Microsoft GraphRAG — open-source Graph RAG framework
  LlamaIndex KG  — knowledge graph integration
  Graphiti (Zep) — temporally-aware knowledge graphs
```

---

## ○ Interview Angles

- **Q**: What is Graph RAG and when would you use it over standard RAG?
- **A**: Graph RAG combines knowledge graphs with RAG. Standard RAG retrieves text chunks by similarity — great for "what does X mean?" but fails at "how are X and Y connected?" or "summarize all instances of Z." Graph RAG extracts entities and relationships into a knowledge graph, enabling multi-hop reasoning and aggregation. Use it when: data is entity-heavy (people, organizations, events), questions require relationship traversal, or you need thematic summary across large document sets.

- **Q**: What is Agentic RAG?
- **A**: Agentic RAG gives retrieval an autonomous agent that can dynamically choose retrieval strategies (vector search, graph query, SQL, web search), self-correct when results are poor, decompose complex questions into sub-queries, and verify answers before returning. It transforms RAG from a fixed pipeline into an adaptive reasoning loop. This is the emerging standard for enterprise AI in 2026.

---

## ★ Connections

| Relationship | Topics                                                          |
| ------------ | --------------------------------------------------------------- |
| Builds on    | [Rag](./rag.md), [Vector Databases](../tools-and-infra/vector-databases.md), [Ai Agents](./ai-agents.md) |
| Leads to     | Enterprise knowledge systems, Compliance AI                     |
| Compare with | Standard RAG (similarity only), Long context (no retrieval)     |
| Cross-domain | Graph databases, Knowledge management, Information retrieval    |

---

## ★ Sources

- Microsoft, "From Local to Global: A Graph RAG Approach" (2024)
- Microsoft GraphRAG — https://github.com/microsoft/graphrag
- LlamaIndex Knowledge Graph documentation
- Neo4j + LLM integrations documentation
