---
title: "Graph RAG & Advanced Retrieval"
tags: [graph-rag, knowledge-graph, multi-hop-reasoning, graphrag, agentic-rag, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[rag]]", "[[ai-agents]]", "[[context-engineering]]", "[[../tools-and-infra/vector-databases]]"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Graph RAG & Advanced Retrieval

> âœ¨ **Bit**: Standard RAG is like searching a library by keyword â€” you find relevant pages but miss the connections. Graph RAG is like having a librarian who understands that "Einstein worked at Princeton, Princeton is in New Jersey, New Jersey passed X law" â€” it reasons across RELATIONSHIPS, not just similarity.

---

## â˜… TL;DR

- **What**: RAG enhanced with knowledge graphs for structured reasoning and multi-hop retrieval
- **Why**: Vector RAG fails at complex questions requiring relationship traversal, aggregation, or multi-step reasoning. Graph RAG fills this gap.
- **Key point**: Microsoft open-sourced GraphRAG in 2024, sparking massive adoption. By 2026, Graph RAG + Agentic RAG = the production standard for complex enterprise AI.

---

## â˜… Overview

### Definition

**Graph RAG** augments retrieval with entities and relationships so the system can reason over structure, not only semantic similarity.

### Scope

This note focuses on why graph-based retrieval helps, how it differs from vector-only RAG, and where it fits in advanced enterprise knowledge systems.

### Significance

- It addresses multi-hop and aggregation-heavy questions that standard vector retrieval often handles poorly.
- It is especially relevant for complex enterprise assistants, document intelligence, and agentic reasoning workflows.

---

## â˜… Deep Dive

### Why Vector RAG Fails

```
QUESTION: "Which departments had the highest attrition
           among employees hired in the last 2 years?"

VECTOR RAG:
  1. Embed question â†’ search vector DB
  2. Get chunks about "attrition" and "hiring"
  3. Chunks are from DIFFERENT docs, no connection
  4. LLM tries to combine â†’ often wrong or hallucinated
  âŒ Can't aggregate across entities
  âŒ Can't traverse relationships

GRAPH RAG:
  1. Knowledge graph has: Employee â†’ Department â†’ HireDate â†’ Status
  2. Query traverses: Employees(hired < 2 years) â†’ filter(left) â†’ group(department)
  3. Structured, verified answer with exact numbers
  âœ… Aggregation across entities
  âœ… Multi-hop reasoning via graph traversal
```

### Vector RAG vs Graph RAG

```
VECTOR RAG                           GRAPH RAG
(similarity search)                  (relationship traversal)

  Docs â†’ Chunks â†’ Embeddings         Docs â†’ Entities â†’ Relationships
     â†“                                   â†“
  Query â†’ Similar chunks              Query â†’ Graph traversal
     â†“                                   â†“
  "Find texts about X"               "Find entities connected to X
                                       via relationship Y"

  âœ… Simple to set up                âœ… Multi-hop reasoning
  âœ… Works for direct Q&A            âœ… Aggregation queries
  âœ… Fast retrieval                  âœ… Structured/verified answers
  âŒ No relationship awareness       âŒ Expensive graph construction
  âŒ Fails at aggregation            âŒ More complex pipeline
  âŒ Multi-hop failures              âŒ Needs entity extraction
```

### How Graph RAG Works (Microsoft GraphRAG)

```
INDEXING PHASE:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  1. ENTITY EXTRACTION                        â”‚
  â”‚     LLM reads documents, extracts:            â”‚
  â”‚     - Entities: "Albert Einstein", "Princeton"â”‚
  â”‚     - Relationships: "worked at", "located in"â”‚
  â”‚                                              â”‚
  â”‚  2. BUILD KNOWLEDGE GRAPH                     â”‚
  â”‚     Entities = nodes, Relationships = edges   â”‚
  â”‚     [Einstein]â”€â”€works_atâ”€â”€â–¶[Princeton]        â”‚
  â”‚     [Princeton]â”€â”€located_inâ”€â”€â–¶[New Jersey]    â”‚
  â”‚                                              â”‚
  â”‚  3. COMMUNITY DETECTION                       â”‚
  â”‚     Cluster related entities into communities â”‚
  â”‚     Community: "Princeton Academic Network"   â”‚
  â”‚                                              â”‚
  â”‚  4. COMMUNITY SUMMARIES                       â”‚
  â”‚     LLM summarizes each community             â”‚
  â”‚     "Princeton University, founded in 1746,   â”‚
  â”‚      notable faculty include Einstein..."     â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

QUERY PHASE:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  LOCAL SEARCH (specific questions):           â”‚
  â”‚    Entity lookup â†’ traverse related entities  â”‚
  â”‚    â†’ gather context â†’ LLM generates answer   â”‚
  â”‚                                              â”‚
  â”‚  GLOBAL SEARCH (thematic questions):          â”‚
  â”‚    Search all community summaries             â”‚
  â”‚    â†’ map: each community answers partially    â”‚
  â”‚    â†’ reduce: combine into final answer        â”‚
  â”‚    "What are the main themes in this dataset?"â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Agentic RAG (2025-2026 Standard)

```
AGENTIC RAG = RAG + Agent autonomy

  Standard RAG:
    Query â†’ Retrieve â†’ Generate (fixed pipeline)

  Agentic RAG:
    Query â†’ Agent DECIDES:
      "What do I need to answer this?"
      â”œâ”€â”€ Vector search? (semantic similarity)
      â”œâ”€â”€ Graph query? (relationship traversal)
      â”œâ”€â”€ SQL query? (structured data)
      â”œâ”€â”€ Web search? (real-time data)
      â”œâ”€â”€ Rewrite query? (ambiguous question)
      â””â”€â”€ Ask for clarification? (insufficient info)

    Agent can:
      - Self-correct: "These results aren't relevant, let me refine"
      - Multi-step: Retrieve â†’ reason â†’ retrieve more â†’ answer
      - Verify: "Let me cross-check this claim"
      - Route: Different retrieval strategies for different sub-questions

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  AGENTIC RAG ARCHITECTURE                      â”‚
  â”‚                                                â”‚
  â”‚  User Query                                    â”‚
  â”‚      â”‚                                         â”‚
  â”‚      â–¼                                         â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                â”‚
  â”‚  â”‚   ROUTER    â”‚ â† "What type of question?"    â”‚
  â”‚  â”‚   AGENT     â”‚                                â”‚
  â”‚  â””â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”€â”¬â”€â”€â”˜                               â”‚
  â”‚     â”‚   â”‚   â”‚                                  â”‚
  â”‚  â”Œâ”€â”€â–¼â” â”Œâ–¼â”€â”€â” â”Œâ–¼â”€â”€â”€â”€â”€â”€â”                        â”‚
  â”‚  â”‚Vecâ”‚ â”‚KG â”‚ â”‚SQL/APIâ”‚                         â”‚
  â”‚  â”‚DB â”‚ â”‚   â”‚ â”‚       â”‚                         â”‚
  â”‚  â””â”€â”€â”¬â”˜ â””â”¬â”€â”€â”˜ â””â”¬â”€â”€â”€â”€â”€â”€â”˜                        â”‚
  â”‚     â”‚   â”‚     â”‚                                â”‚
  â”‚     â–¼   â–¼     â–¼                                â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                            â”‚
  â”‚  â”‚  SYNTHESIZER   â”‚ â† Combine, verify, reason  â”‚
  â”‚  â”‚  AGENT         â”‚                            â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜                            â”‚
  â”‚          â–¼                                     â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                            â”‚
  â”‚  â”‚  SELF-CHECK    â”‚ â† "Is my answer grounded?" â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜                            â”‚
  â”‚          â–¼                                     â”‚
  â”‚     Final Answer                               â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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

## â—† Quick Reference

```
GRAPH RAG DECISION:
  Simple factual Q&A?         â†’ Vector RAG is fine
  "How many X have Y?"        â†’ Graph RAG (aggregation)
  "What connects A to B?"     â†’ Graph RAG (traversal)
  Complex multi-source query? â†’ Agentic RAG
  Both structured + unstructured data? â†’ Graph + Agentic RAG

KNOWLEDGE GRAPH TOOLS:
  Neo4j          â€” industry standard graph DB
  Amazon Neptune â€” managed graph DB (AWS)
  Microsoft GraphRAG â€” open-source Graph RAG framework
  LlamaIndex KG  â€” knowledge graph integration
  Graphiti (Zep) â€” temporally-aware knowledge graphs
```

---

## â—‹ Interview Angles

- **Q**: What is Graph RAG and when would you use it over standard RAG?
- **A**: Graph RAG combines knowledge graphs with RAG. Standard RAG retrieves text chunks by similarity â€” great for "what does X mean?" but fails at "how are X and Y connected?" or "summarize all instances of Z." Graph RAG extracts entities and relationships into a knowledge graph, enabling multi-hop reasoning and aggregation. Use it when: data is entity-heavy (people, organizations, events), questions require relationship traversal, or you need thematic summary across large document sets.

- **Q**: What is Agentic RAG?
- **A**: Agentic RAG gives retrieval an autonomous agent that can dynamically choose retrieval strategies (vector search, graph query, SQL, web search), self-correct when results are poor, decompose complex questions into sub-queries, and verify answers before returning. It transforms RAG from a fixed pipeline into an adaptive reasoning loop. This is the emerging standard for enterprise AI in 2026.

---

## â˜… Connections

| Relationship | Topics                                                          |
| ------------ | --------------------------------------------------------------- |
| Builds on    | [Rag](./rag.md), [Vector Databases](../tools-and-infra/vector-databases.md), [Ai Agents](./ai-agents.md) |
| Leads to     | Enterprise knowledge systems, Compliance AI                     |
| Compare with | Standard RAG (similarity only), Long context (no retrieval)     |
| Cross-domain | Graph databases, Knowledge management, Information retrieval    |

---

## â˜… Sources

- Microsoft, "From Local to Global: A Graph RAG Approach" (2024)
- Microsoft GraphRAG â€” https://github.com/microsoft/graphrag
- LlamaIndex Knowledge Graph documentation
- Neo4j + LLM integrations documentation
