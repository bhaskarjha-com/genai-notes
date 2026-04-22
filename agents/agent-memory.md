---
title: "Agent Memory Systems"
aliases: ["Agent Memory", "MemGPT", "Letta", "Conversation Memory"]
tags: [agents, memory, context, state, conversation, rag, production]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "ai-agents.md"
related: ["ai-agents.md", "multi-agent-architectures.md", "../techniques/rag.md", "../techniques/context-engineering.md"]
source: "Multiple â€” see Sources"
created: 2026-04-14
updated: 2026-04-15
---

# Agent Memory Systems

> âœ¨ **Bit**: An LLM without memory is a brilliant person with amnesia â€” they can reason perfectly but can't remember what happened 5 minutes ago. Agent memory is how you give AI systems persistence, learning, and context across interactions.

---

## â˜… TL;DR

- **What**: Architectural patterns for giving AI agents persistent memory â€” conversation history, semantic recall, structured knowledge, and episodic learning
- **Why**: Without memory, every interaction starts from zero. Memory enables personalization, multi-session reasoning, and agents that learn from experience.
- **Key point**: Memory is not one thing â€” it's a taxonomy (working, episodic, semantic, procedural) that maps to different implementation patterns (context window, vector store, knowledge graph, tool results cache).

---

## â˜… Overview

### Definition

**Agent memory** encompasses all mechanisms that allow an AI agent to retain, retrieve, and use information beyond the current prompt. This includes conversation history, learned user preferences, retrieved knowledge, and accumulated task experience.

### Scope

Covers: Memory taxonomy, implementation patterns (context stuffing, RAG-based recall, summarization chains, knowledge graphs), production code, and failure modes. For the broader agent architecture, see [AI Agents](./ai-agents.md). For retrieval specifically, see [RAG](../techniques/rag.md).

### Significance

- **Personalization**: Users expect AI to remember preferences and context
- **Multi-session continuity**: Agents that forget between sessions feel broken
- **Learning agents**: The frontier â€” agents that improve from their own experience
- **Interview topic**: "How would you give an agent long-term memory?" is a common system design question

### Prerequisites

- [AI Agents](./ai-agents.md) â€” agent architecture fundamentals
- [RAG](../techniques/rag.md) â€” retrieval as a memory mechanism
- [Context Engineering](../techniques/context-engineering.md) â€” managing context windows
- [Embeddings](../foundations/embeddings.md) â€” vector representations for semantic memory

---

## â˜… Deep Dive

### The Memory Taxonomy

```
HUMAN MEMORY                          AGENT MEMORY EQUIVALENT
â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€                         â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

WORKING MEMORY                        CONTEXT WINDOW
  "What I'm thinking about now"         Current prompt + recent messages
  Capacity: ~7 items                    Capacity: 128K-2M tokens
  Duration: seconds                     Duration: single request

EPISODIC MEMORY                       CONVERSATION HISTORY + LOGS
  "What happened to me"                 Past interactions, stored and retrieved
  Capacity: lifetime                    Capacity: unlimited (with retrieval)
  Duration: permanent                   Duration: session or persistent

SEMANTIC MEMORY                       KNOWLEDGE BASE / RAG
  "What I know about the world"         Facts, documents, embeddings
  Capacity: vast                        Capacity: unlimited
  Duration: permanent                   Duration: permanent

PROCEDURAL MEMORY                     TOOLS + LEARNED BEHAVIORS
  "How to do things"                    Tool definitions, few-shot examples,
  Capacity: skills                      fine-tuned behaviors
  Duration: permanent                   Duration: permanent

GRAPH-BASED MEMORY                    KNOWLEDGE GRAPH STORE
  "Relationships between things"         Entities + typed edges ("User â†’ works at â†’ Acme")
  Capacity: structured, scalable         Neo4j, Kuzu, in-memory graph
  Duration: permanent                    Best for: complex domain reasoning, entity traversal
```

> **2026 Benchmark**: LOCOMO (Long-Context Memory) is the emerging standard for evaluating
> agent memory quality across sessions. It tests recall, contradiction detection, and temporal
> reasoning over 50+ turn conversations. Use it to compare memory implementations.

### Memory Architecture Patterns

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    AGENT MEMORY ARCHITECTURE                     â”‚
â”‚                                                                   â”‚
â”‚  USER MESSAGE                                                     â”‚
â”‚       â”‚                                                           â”‚
â”‚       â–¼                                                           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚              MEMORY RETRIEVAL LAYER                       â”‚    â”‚
â”‚  â”‚                                                           â”‚    â”‚
â”‚  â”‚  1. Recent messages (sliding window / buffer)             â”‚    â”‚
â”‚  â”‚  2. Relevant past conversations (semantic search)         â”‚    â”‚
â”‚  â”‚  3. User profile & preferences (structured store)         â”‚    â”‚
â”‚  â”‚  4. Relevant knowledge (RAG)                              â”‚    â”‚
â”‚  â”‚  5. Task history & outcomes (episodic store)              â”‚    â”‚
â”‚  â”‚                                                           â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚                        â”‚                                          â”‚
â”‚                        â–¼                                          â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚              CONTEXT ASSEMBLY                             â”‚    â”‚
â”‚  â”‚                                                           â”‚    â”‚
â”‚  â”‚  System prompt                                            â”‚    â”‚
â”‚  â”‚  + Retrieved memories (ranked by relevance)               â”‚    â”‚
â”‚  â”‚  + Recent conversation (last N turns)                     â”‚    â”‚
â”‚  â”‚  + Current user message                                   â”‚    â”‚
â”‚  â”‚  = FINAL PROMPT (fits within context window)              â”‚    â”‚
â”‚  â”‚                                                           â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚                        â”‚                                          â”‚
â”‚                        â–¼                                          â”‚
â”‚                    LLM GENERATES RESPONSE                         â”‚
â”‚                        â”‚                                          â”‚
â”‚                        â–¼                                          â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚              MEMORY WRITE-BACK                            â”‚    â”‚
â”‚  â”‚                                                           â”‚    â”‚
â”‚  â”‚  1. Store conversation turn                               â”‚    â”‚
â”‚  â”‚  2. Extract & update user preferences                     â”‚    â”‚
â”‚  â”‚  3. Update task outcomes / success metrics                â”‚    â”‚
â”‚  â”‚  4. Summarize if buffer exceeds threshold                 â”‚    â”‚
â”‚  â”‚                                                           â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Pattern 1: Sliding Window (Buffer Memory)

The simplest â€” keep the last N messages in context.

| Aspect | Detail |
|--------|--------|
| **How** | Store last N messages, include all in every prompt |
| **Capacity** | Limited by context window (typically 10-50 turns) |
| **Pros** | Simple, no infrastructure, preserves exact wording |
| **Cons** | Loses old context, no learning, expensive for long conversations |
| **Best for** | Short task-oriented conversations, prototypes |

### Pattern 2: Summarization Memory

Periodically summarize older messages to compress history.

| Aspect | Detail |
|--------|--------|
| **How** | When buffer exceeds threshold, summarize older messages into a paragraph |
| **Capacity** | Much longer conversations (100s of turns) |
| **Pros** | Retains key information, fits in context window |
| **Cons** | Lossy (details lost in summarization), adds latency and cost |
| **Best for** | Long multi-turn conversations, support chatbots |

### Pattern 3: Semantic Memory (Vector Store)

Store and retrieve memories by relevance using embeddings.

| Aspect | Detail |
|--------|--------|
| **How** | Embed each memory, store in vector DB, retrieve by similarity to current query |
| **Capacity** | Unlimited â€” retrieve only what's relevant |
| **Pros** | Scales to millions of memories, relevance-based recall |
| **Cons** | May miss important context that isn't semantically similar to current query |
| **Best for** | Long-term user memory, cross-session recall, knowledge-heavy agents |

### Pattern 4: Knowledge Graph Memory

Store structured relationships between entities.

| Aspect | Detail |
|--------|--------|
| **How** | Extract entities and relationships from conversations, store in a graph |
| **Capacity** | Unlimited, structured |
| **Pros** | Rich relational reasoning, good for complex domains |
| **Cons** | Complex to build, extraction accuracy matters, graph maintenance |
| **Best for** | Domain-specific agents (medical, legal, research), relationship-heavy contexts |

### Pattern 5: Virtual Context Memory (Letta / MemGPT)

An OS-inspired approach where the agent manages its own memory via tool calls â€” reading, writing, and searching memory tiers autonomously.

| Aspect | Detail |
|--------|--------|
| **How** | Three-tier memory hierarchy managed by the agent itself via memory tools |
| **Capacity** | Unlimited â€” agent pages data in/out of context as needed |
| **Pros** | Self-organizing, handles arbitrarily long histories, agent decides what to remember |
| **Cons** | Extra LLM calls for memory management, complexity, requires reliable tool use |
| **Best for** | Long-running agents, personalized assistants, agents that must learn over weeks/months |

```
LETTA / MEMGPT ARCHITECTURE:

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚                   AGENT CONTEXT WINDOW                   â”‚
  â”‚                                                         â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
  â”‚  â”‚  CORE MEMORY (always in context)                 â”‚   â”‚
  â”‚  â”‚  - System persona + user profile blocks          â”‚   â”‚
  â”‚  â”‚  - Agent can self-edit: core_memory_replace()    â”‚   â”‚
  â”‚  â”‚  Capacity: ~2K tokens (curated, high-value)      â”‚   â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
  â”‚                         â”‚                               â”‚
  â”‚                    pages in/out                          â”‚
  â”‚                         â”‚                               â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
  â”‚  â”‚  RECALL MEMORY (conversation search)             â”‚   â”‚
  â”‚  â”‚  - Full conversation log, searchable             â”‚   â”‚
  â”‚  â”‚  - Agent calls: conversation_search(query)       â”‚   â”‚
  â”‚  â”‚  Capacity: unlimited (retrieval-based)           â”‚   â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
  â”‚                         â”‚                               â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
  â”‚  â”‚  ARCHIVAL MEMORY (persistent knowledge store)    â”‚   â”‚
  â”‚  â”‚  - Long-term facts, documents, learned knowledge â”‚   â”‚
  â”‚  â”‚  - Agent calls: archival_memory_insert/search()  â”‚   â”‚
  â”‚  â”‚  Capacity: unlimited (vector DB backed)          â”‚   â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

KEY INSIGHT: The agent is its own memory manager.
  - It decides what to remember (archival_memory_insert)
  - It decides what to recall (conversation_search, archival_memory_search)
  - It maintains its own profile (core_memory_replace)
  - Unlike RAG: memory writes are autonomous, not just retrieval
```

**Letta vs Mem0 (2026 landscape):**

| Aspect | Letta (MemGPT) | Mem0 |
|--------|----------------|------|
| **Approach** | OS-inspired, agent self-manages memory via tools | Automated memory extraction + retrieval layer |
| **Control** | Agent decides what to store/retrieve | System automatically extracts and stores memories |
| **Architecture** | Three-tier (core/recall/archival) | Key-value memory with embedding search |
| **Best for** | Agents needing autonomous memory management | Simpler "remember user preferences" use cases |
| **Maturity** | Production runtime (Letta Cloud + open-source) | Open-source library + hosted API |

---

## â˜… Code & Implementation

### LangGraph Agent with Conversation Memory

```python
# pip install langgraph>=0.3 langchain-openai>=0.3 langchain-community>=0.3
# âš ï¸ Last tested: 2026-04 | Requires: langgraph>=0.3

from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.checkpoint.memory import MemorySaver
from langchain_openai import ChatOpenAI

# 1. Setup model and memory checkpointer
model = ChatOpenAI(model="gpt-4o-mini", temperature=0)
memory = MemorySaver()  # In production: use PostgresSaver or RedisSaver

# 2. Define the agent node
def agent(state: MessagesState):
    """Agent node that processes messages with full conversation history."""
    response = model.invoke(state["messages"])
    return {"messages": [response]}

# 3. Build graph
graph = StateGraph(MessagesState)
graph.add_node("agent", agent)
graph.add_edge(START, "agent")
graph.add_edge("agent", END)
app = graph.compile(checkpointer=memory)

# 4. Use with persistent memory (thread_id = conversation session)
config = {"configurable": {"thread_id": "user_123_session_1"}}

# Turn 1
response = app.invoke(
    {"messages": [("user", "My name is Alex and I'm building a RAG system")]},
    config=config,
)
print(response["messages"][-1].content)

# Turn 2 â€” agent remembers Turn 1!
response = app.invoke(
    {"messages": [("user", "What am I working on?")]},
    config=config,
)
print(response["messages"][-1].content)
# Expected: "You mentioned you're building a RAG system, Alex!"

# Turn 3 â€” different session (no memory)
config_new = {"configurable": {"thread_id": "user_123_session_2"}}
response = app.invoke(
    {"messages": [("user", "What's my name?")]},
    config=config_new,
)
print(response["messages"][-1].content)
# Expected: "I don't know your name â€” this is our first interaction."
```

### Semantic Memory with Vector Store

```python
# pip install openai>=1.0 numpy>=1.24
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.0

from openai import OpenAI
import numpy as np
import json
from datetime import datetime

client = OpenAI()

class SemanticMemory:
    """Simple semantic memory using embeddings for relevance-based recall."""
    
    def __init__(self):
        self.memories: list[dict] = []
        self.embeddings: list[np.ndarray] = []
    
    def _embed(self, text: str) -> np.ndarray:
        """Get embedding for text."""
        # Production: add tenacity @retry(wait=wait_exponential(min=1, max=10), stop=stop_after_attempt(3))
        try:
            response = client.embeddings.create(
                model="text-embedding-3-small",
                input=text,
            )
            return np.array(response.data[0].embedding)
        except Exception as e:
            # Production: log error, fall back to cached embedding or raise
            raise RuntimeError(f"Embedding API call failed: {e}") from e
    
    def store(self, content: str, metadata: dict = None):
        """Store a memory with its embedding."""
        embedding = self._embed(content)  # May raise on API failure
        self.memories.append({
            "content": content,
            "timestamp": datetime.now().isoformat(),
            "metadata": metadata or {},
        })
        self.embeddings.append(embedding)
    
    def recall(self, query: str, top_k: int = 3) -> list[dict]:
        """Retrieve most relevant memories for a query."""
        if not self.memories:
            return []
        
        query_emb = self._embed(query)
        similarities = [
            np.dot(query_emb, emb) / (np.linalg.norm(query_emb) * np.linalg.norm(emb))
            for emb in self.embeddings
        ]
        
        top_indices = np.argsort(similarities)[-top_k:][::-1]
        return [
            {**self.memories[i], "similarity": similarities[i]}
            for i in top_indices
            if similarities[i] > 0.3  # Minimum relevance threshold
        ]

# Usage
memory = SemanticMemory()

# Store memories from conversations
memory.store("User prefers Python over JavaScript for backend work")
memory.store("User is building a customer support chatbot for healthcare")
memory.store("User's company uses AWS and PostgreSQL")
memory.store("User asked about HIPAA compliance requirements")

# Recall relevant memories
results = memory.recall("What cloud provider should I use for my medical chatbot?")
for r in results:
    print(f"  [{r['similarity']:.2f}] {r['content']}")

# Expected output (ranked by relevance):
#   [0.82] User's company uses AWS and PostgreSQL
#   [0.78] User is building a customer support chatbot for healthcare
#   [0.65] User asked about HIPAA compliance requirements
```

---

## â—† Quick Reference

```
MEMORY PATTERN DECISION GUIDE:

  Short conversation (< 20 turns)?     â†’ Sliding window buffer
  Long conversation (20-200 turns)?     â†’ Summarization memory
  Cross-session personalization?        â†’ Semantic memory (vector store)
  Complex domain relationships?         â†’ Knowledge graph memory
  Agent-managed long-term memory?       â†’ Letta / MemGPT (virtual context)
  Production multi-user system?         â†’ Vector store + structured user profiles
  
MEMORY STORAGE OPTIONS:
  Prototype:     In-memory (list/dict)
  Development:   SQLite + FAISS
  Production:    PostgreSQL + pgvector or Qdrant/Pinecone
  Enterprise:    Redis (hot) + PostgreSQL (cold) + vector DB (semantic)
  
MEMORY SIZING:
  1 conversation turn â‰ˆ 100-500 tokens
  Context window budget for memory â‰ˆ 30-50% of total context
  Semantic memory retrieval â‰ˆ top 3-5 most relevant memories
```

---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Memory poisoning** | Agent acts on incorrect "memories" from past conversations | User manipulated memory entries, or extraction errors | Validate memories before storage, add confidence scores, allow user correction |
| **Irrelevant recall** | Agent brings up unrelated past context | Embedding similarity too loose, no recency weighting | Tune similarity threshold, add time decay, filter by topic |
| **Context window overflow** | Agent crashes or truncates important context | Too many memories retrieved, no budget management | Set strict token budget per memory type, prioritize recent + relevant |
| **Privacy leakage** | Agent shares one user's memories with another | Incorrect memory isolation, shared vector namespace | Per-user memory partitioning, tenant isolation in vector DB |
| **Stale memory** | Agent uses outdated information about user | No memory expiration or update mechanism | TTL on memories, periodic refresh, user-triggered memory reset |

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **More memory â‰  better responses**: Stuffing too many memories into context confuses the model. Retrieve 3-5 most relevant, not 50.
- âš ï¸ **Summarization is lossy**: When you summarize old conversations, specific details (dates, numbers, names) are often lost. Store facts separately.
- âš ï¸ **Embedding similarity â‰  importance**: A memory can be highly similar to the current query but unimportant, or vice versa. Combine relevance with recency and importance scoring.
- âš ï¸ **Memory writes have latency and cost**: Each embedding call adds ~100ms and ~$0.0001. At scale (1000s of conversations/day), this adds up.

---

## â—‹ Interview Angles

- **Q**: How would you implement long-term memory for a customer support agent?
- **A**: I'd use a three-layer memory architecture. Layer 1: sliding window of the last 10 messages for immediate context. Layer 2: a structured user profile (name, plan, past issues) stored in PostgreSQL, updated after each conversation. Layer 3: semantic memory in a vector database for retrieving relevant past tickets and resolutions. On each new message, I'd retrieve the user profile + top 3 relevant past interactions and inject them into the system prompt. I'd budget 30% of context for memory, 20% for system prompt, and 50% for the current conversation. Memory writes happen asynchronously after each turn to avoid adding latency.

- **Q**: What are the risks of giving an agent memory?
- **A**: Four main risks. (1) Privacy: memories must be strictly isolated per user/tenant â€” a vector DB namespace leak would expose personal data. (2) Poisoning: users can intentionally inject false memories ("remember that I'm an admin") â€” validate and sanitize memory writes. (3) Staleness: preferences change but old memories persist â€” add TTLs and explicit update mechanisms. (4) Hallucinated memories: the LLM may "remember" things that never happened â€” always check retrieved memories against actual stored data, never rely on the model's internal "memory."

---

## â—† Hands-On Exercises

### Exercise 1: Build a Memory-Enabled Chatbot

**Goal**: Create a chatbot that remembers across sessions
**Time**: 60 minutes
**Steps**:
1. Build a basic chatbot using the LangGraph code above
2. Add semantic memory using the vector store implementation
3. Test: have 3 conversations, then start a 4th â€” does it recall relevant context?
4. Test memory isolation: create 2 users, verify they can't see each other's memories
**Expected Output**: Working chatbot with cross-session memory, isolation verification

---

## â˜… Connections

| Relationship | Topics |
|---|---|
| Builds on | [AI Agents](./ai-agents.md), [RAG](../techniques/rag.md), [Embeddings](../foundations/embeddings.md) |
| Leads to | [Multi-Agent Architectures](./multi-agent-architectures.md) (shared agent memory), Personalization systems |
| Compare with | Database state management, session stores, user profiles |
| Cross-domain | Cognitive science, information retrieval, database design |

---

## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ“˜ Book | "AI Engineering" by Chip Huyen (2025), Ch 7 | Covers agent memory patterns in production context |
| ðŸ”§ Hands-on | [LangGraph Memory Tutorial](https://langchain-ai.github.io/langgraph/concepts/memory/) | Official guide to checkpointing and memory in LangGraph |
| ðŸ”§ Hands-on | [Mem0 Library](https://github.com/mem0ai/mem0) | Open-source long-term memory layer for AI agents |
| ðŸ”§ Hands-on | [Letta (MemGPT)](https://github.com/letta-ai/letta) | Virtual context memory runtime â€” agent self-manages memory tiers |
| ðŸ“„ Paper | [Packer et al. "MemGPT" (2023)](https://arxiv.org/abs/2310.08560) | OS-inspired virtual context management for LLM agents |
| ðŸ“„ Paper | [Park et al. "Generative Agents" (2023)](https://arxiv.org/abs/2304.03442) | Stanford's simulation of memory-enabled AI agents in a virtual world |

---

## â˜… Sources

- LangGraph Documentation â€” https://langchain-ai.github.io/langgraph/
- Mem0 Documentation â€” https://docs.mem0.ai/
- Letta (MemGPT) Documentation â€” https://docs.letta.com/
- Packer et al. "MemGPT: Towards LLMs as Operating Systems" (2023) â€” https://arxiv.org/abs/2310.08560
- Park et al. "Generative Agents: Interactive Simulacra of Human Behavior" (2023)
- [AI Agents](./ai-agents.md)
- [RAG](../techniques/rag.md)
