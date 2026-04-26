---
title: "Graph RAG & Advanced Retrieval"
aliases: ["GraphRAG", "Knowledge Graph RAG"]
tags: [graph-rag, knowledge-graph, multi-hop-reasoning, graphrag, agentic-rag, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["rag.md", "../agents/ai-agents.md", "context-engineering.md", "../tools-and-infra/vector-databases.md"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Graph RAG & Advanced Retrieval

> ✨ **Bit**: Standard RAG is like searching a library by keyword â€” you find relevant pages but miss the connections. Graph RAG is like having a librarian who understands that "Einstein worked at Princeton, Princeton is in New Jersey, New Jersey passed X law" â€” it reasons across RELATIONSHIPS, not just similarity.

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
  âŒ Can't aggregate across entities
  âŒ Can't traverse relationships

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
     â†“                                   â†“
  Query → Similar chunks              Query → Graph traversal
     â†“                                   â†“
  "Find texts about X"               "Find entities connected to X
                                       via relationship Y"

  ✅ Simple to set up                ✅ Multi-hop reasoning
  ✅ Works for direct Q&A            ✅ Aggregation queries
  ✅ Fast retrieval                  ✅ Structured/verified answers
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
  â”‚    Entity lookup → traverse related entities  â”‚
  â”‚    → gather context → LLM generates answer   â”‚
  â”‚                                              â”‚
  â”‚  GLOBAL SEARCH (thematic questions):          â”‚
  â”‚    Search all community summaries             â”‚
  â”‚    → map: each community answers partially    â”‚
  â”‚    → reduce: combine into final answer        â”‚
  â”‚    "What are the main themes in this dataset?"â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Agentic RAG (2025-2026 Standard)

```
AGENTIC RAG = RAG + Agent autonomy

  Standard RAG:
    Query → Retrieve → Generate (fixed pipeline)

  Agentic RAG:
    Query → Agent DECIDES:
      "What do I need to answer this?"
      â”œâ”€â”€ Vector search? (semantic similarity)
      â”œâ”€â”€ Graph query? (relationship traversal)
      â”œâ”€â”€ SQL query? (structured data)
      â”œâ”€â”€ Web search? (real-time data)
      â”œâ”€â”€ Rewrite query? (ambiguous question)
      â””â”€â”€ Ask for clarification? (insufficient info)

    Agent can:
      - Self-correct: "These results aren't relevant, let me refine"
      - Multi-step: Retrieve → reason → retrieve more → answer
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

## ◆ Quick Reference

```
GRAPH RAG DECISION:
  Simple factual Q&A?         → Vector RAG is fine
  "How many X have Y?"        → Graph RAG (aggregation)
  "What connects A to B?"     → Graph RAG (traversal)
  Complex multi-source query? → Agentic RAG
  Both structured + unstructured data? → Graph + Agentic RAG

KNOWLEDGE GRAPH TOOLS:
  Neo4j          â€” industry standard graph DB
  Amazon Neptune â€” managed graph DB (AWS)
  Microsoft GraphRAG â€” open-source Graph RAG framework
  LlamaIndex KG  â€” knowledge graph integration
  Graphiti (Zep) â€” temporally-aware knowledge graphs
```

---

## ○ Interview Angles

- **Q**: What is Graph RAG and when would you use it over standard RAG?
- **A**: Graph RAG combines knowledge graphs with RAG. Standard RAG retrieves text chunks by similarity â€” great for "what does X mean?" but fails at "how are X and Y connected?" or "summarize all instances of Z." Graph RAG extracts entities and relationships into a knowledge graph, enabling multi-hop reasoning and aggregation. Use it when: data is entity-heavy (people, organizations, events), questions require relationship traversal, or you need thematic summary across large document sets.

- **Q**: What is Agentic RAG?
- **A**: Agentic RAG gives retrieval an autonomous agent that can dynamically choose retrieval strategies (vector search, graph query, SQL, web search), self-correct when results are poor, decompose complex questions into sub-queries, and verify answers before returning. It transforms RAG from a fixed pipeline into an adaptive reasoning loop. This is the emerging standard for enterprise AI in 2026.

---

## ★ Code & Implementation

### Mini Knowledge Graph RAG with NetworkX

```python
# pip install openai>=1.60 networkx>=3.2
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, networkx>=3.2, OPENAI_API_KEY
from openai import OpenAI
import networkx as nx
import json

client = OpenAI()

# Build a small knowledge graph
G = nx.DiGraph()
G.add_edges_from([
    ("Transformer",  "Self-Attention",         {"relation": "uses"}),
    ("Self-Attention","Query-Key-Value",        {"relation": "implements"}),
    ("BERT",         "Transformer",            {"relation": "is_based_on"}),
    ("GPT",          "Transformer",            {"relation": "is_based_on"}),
    ("RAG",          "Transformer",            {"relation": "uses"}),
    ("RAG",          "Vector Database",        {"relation": "retrieves_from"}),
    ("LoRA",         "Transformer",            {"relation": "adapts"}),
])

def graph_context(query_entity: str, hops: int = 2) -> str:
    """Extract k-hop neighborhood from graph as context for LLM."""
    if query_entity not in G:
        return f"Entity '{query_entity}' not in knowledge graph."
    nodes = nx.ego_graph(G, query_entity, radius=hops)
    triples = [(u, G[u][v]["relation"], v) for u, v in nodes.edges()]
    return "\n".join(f"{u} --[{r}]--> {v}" for u, r, v in triples)

def graph_rag_query(question: str, entity: str) -> str:
    context = graph_context(entity, hops=2)
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "Answer based on the knowledge graph context."},
            {"role": "user",   "content": f"Graph Context:\n{context}\n\nQuestion: {question}"},
        ],
        temperature=0, max_tokens=200,
    )
    return resp.choices[0].message.content

print(graph_context("RAG", hops=2))
print("\n---")
print(graph_rag_query("What components does RAG rely on?", entity="RAG"))
```

## ★ Connections

| Relationship | Topics                                                                                                           |
| ------------ | ---------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Rag](./rag.md), [Vector Databases](../tools-and-infra/vector-databases.md), [Ai Agents](../agents/ai-agents.md) |
| Leads to     | Enterprise knowledge systems, Compliance AI                                                                      |
| Compare with | Standard RAG (similarity only), Long context (no retrieval)                                                      |
| Cross-domain | Graph databases, Knowledge management, Information retrieval                                                     |


---

## ◆ Production Failure Modes

| Failure                        | Symptoms                                                     | Root Cause                                          | Mitigation                                                      |
| ------------------------------ | ------------------------------------------------------------ | --------------------------------------------------- | --------------------------------------------------------------- |
| **Graph construction drift**   | Knowledge graph becomes stale while source docs update       | No incremental graph update pipeline                | Event-driven graph refresh, diff-based entity extraction        |
| **Entity resolution failures** | Same entity appears as multiple nodes ("OpenAI" vs "openai") | No entity normalization step                        | Fuzzy matching, canonical entity index, embedding-based dedup   |
| **Sparse subgraph retrieval**  | Queries return disconnected nodes with no relationships      | Query doesn't map to graph structure                | Hybrid retrieval (vector + graph), community detection          |
| **Triple extraction noise**    | Garbage relationships pollute the graph                      | LLM hallucination during entity/relation extraction | Confidence thresholds, human-in-the-loop for high-value domains |

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Mini Knowledge Graph from Documents

**Goal**: Extract entities and relationships from documents and query the graph
**Time**: 45 minutes
**Steps**:
1. Use an LLM to extract (subject, predicate, object) triples from 5 documents
2. Build a NetworkX graph
3. Implement a simple graph traversal retriever
4. Compare answers from graph-RAG vs naive vector-RAG on 5 relationship questions
**Expected Output**: Side-by-side answer comparison showing graph-RAG advantage on relationship queries
---


## ★ Recommended Resources

| Type       | Resource                                                                      | Why                                                    |
| ---------- | ----------------------------------------------------------------------------- | ------------------------------------------------------ |
| ðŸ“„ Paper    | [Edge et al. "Graph RAG" (Microsoft, 2024)](https://arxiv.org/abs/2404.16130) | The paper that introduced graph-based RAG architecture |
| ðŸ”§ Hands-on | [Microsoft GraphRAG](https://github.com/microsoft/graphrag)                   | Open-source Graph RAG implementation                   |
| ðŸ”§ Hands-on | [Neo4j GenAI Documentation](https://neo4j.com/docs/genai/)                    | Graph database + LLM integration patterns              |

## ★ Sources

- Microsoft, "From Local to Global: A Graph RAG Approach" (2024)
- Microsoft GraphRAG â€” https://github.com/microsoft/graphrag
- LlamaIndex Knowledge Graph documentation
- Neo4j + LLM integrations documentation
