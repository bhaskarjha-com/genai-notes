---
title: "Context Engineering & Long Context"
tags: [context-window, long-context, context-caching, prompt-caching, rag-vs-context, genai]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[rag]]", "[[prompt-engineering]]", "[[../llms/llms-overview]]", "[[../inference/inference-optimization]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Context Engineering & Long Context

> ✨ **Bit**: In 2023, you could feed an LLM ~4,000 tokens (~3 pages). In 2025, Gemini accepts 1,000,000 tokens (~750,000 words — that's 10 novels). This changes EVERYTHING about how we build AI applications. RAG? Sometimes you just paste the entire database.

---

## ★ TL;DR

- **What**: The art and science of deciding WHAT information goes into an LLM's context window, and using long context + caching to do it efficiently
- **Why**: The context window IS the LLM's working memory. What you put in it determines everything about the output quality.
- **Key point**: Context engineering is replacing "prompt engineering" as THE critical skill. It's not just about the prompt — it's about the system prompt + retrieved docs + examples + tool results + conversation history, all managed within a token budget.

---

## ★ Overview

### Definition

- **Context window**: The maximum number of tokens an LLM can process in a single call (input + output combined)
- **Context engineering**: Strategically constructing the full context (system prompt, examples, retrieved data, conversation history) to maximize output quality within token limits
- **Context caching / Prompt caching**: Reusing pre-computed token representations across API calls to save cost and latency

### Scope

Covers context strategy and optimization. For retrieval-specific techniques, see [Rag](./rag.md). For prompting techniques, see [Prompt Engineering](./prompt-engineering.md).

---

## ★ Deep Dive

### Context Window Evolution

```
MODEL             │ CONTEXT WINDOW  │ ≈ PAGES │ YEAR
══════════════════╪═════════════════╪═════════╪══════
GPT-3             │     4,096       │     3   │ 2020
GPT-3.5           │    16,384       │    12   │ 2023
GPT-4             │   128,000       │    96   │ 2023
Claude 3          │   200,000       │   150   │ 2024
Gemini 1.5 Pro    │ 1,000,000       │   750   │ 2024
GPT-5.4           │ 1,000,000       │   750   │ 2026
Claude Opus 4.6   │ 1,000,000       │   750   │ 2026
Gemini 3.1 Pro    │ 1,000,000+      │   750+  │ 2026
LLaMA 4 Scout     │10,000,000       │ 7,500   │ 2025

WHAT FITS IN 1M TOKENS:
  10 novels         │ 30 hours of transcripts
  Entire codebase   │ 1000s of documents
  Full legal case   │ Year of emails
```

### RAG vs Long Context vs Context Engineering

```
THE DEBATE (2025-2026):

  RAG:                          LONG CONTEXT:
  "Retrieve relevant chunks"    "Just stuff everything in"

  PROS:                         PROS:
  ✅ Works with ANY context     ✅ No retrieval pipeline
  ✅ Scales to billions of docs ✅ Model sees FULL context
  ✅ Always up-to-date          ✅ Better cross-referencing
  ✅ Cheaper per query          ✅ Simpler architecture

  CONS:                         CONS:
  ❌ Retrieval failures         ❌ Expensive per query
  ❌ Chunking artifacts         ❌ Limited to context size
  ❌ Complex pipeline           ❌ "Lost in the middle" effect
  ❌ Can miss connections       ❌ Slower (more tokens to process)

VERDICT: It's not either/or. Context engineering uses BOTH.

  ┌─────────────────────────────────────────────┐
  │  CONTEXT ENGINEERING = Strategic combination │
  │                                             │
  │  System prompt (always present)             │
  │  + Cached context (heavy docs, reusable)    │
  │  + RAG results (query-specific chunks)      │
  │  + Conversation history (recent turns)      │
  │  + Examples (few-shot, if needed)            │
  │  + Tool results (function call outputs)     │
  │  = Optimized context window                 │
  └─────────────────────────────────────────────┘
```

### Context Caching (Prompt Caching)

```
THE COST PROBLEM:
  You have a 50-page manual in your system prompt.
  Every API call re-processes all 50 pages.
  1000 queries/day × 50 pages = MASSIVE token bill.

SOLUTION: Cache the repeated part.

  WITHOUT CACHING:
    Call 1: [System + 50 pages + user question 1]  → process ALL
    Call 2: [System + 50 pages + user question 2]  → process ALL
    Call 3: [System + 50 pages + user question 3]  → process ALL
    Cost: 100% × 3 = 300% tokens

  WITH CACHING:
    Call 1: [System + 50 pages ← CACHE THIS] + [question 1]
    Call 2: [CACHED] + [question 2]  → only process new part
    Call 3: [CACHED] + [question 3]  → only process new part
    Cost: 100% + 10% + 10% = 120% tokens → 60% SAVINGS!

PROVIDER SUPPORT (2026):
  Anthropic:  "Prompt caching" — explicit cache_control blocks
  Google:     "Context caching" — cache API for Gemini
  OpenAI:     Automatic caching for repeated prefixes

  Pricing:    Cached tokens cost 75-90% less than uncached
  Latency:    Cached tokens processed ~2-5x faster
```

### The "Lost in the Middle" Problem

```
PROBLEM: LLMs pay most attention to the START and END
         of the context, often "forgetting" the MIDDLE.

  [System prompt - high attention]
  [Document 1 - moderate attention]
  [Document 2 - low attention]     ← "lost in the middle"
  [Document 3 - low attention]     ← important info here?
  [Document 4 - moderate attention]
  [User question - high attention]

MITIGATIONS:
  1. Put MOST IMPORTANT info at start and end
  2. Use structured formats (headers, bullets)
  3. Explicitly reference: "Based on Document 3..."
  4. Shorter contexts when possible (quality > quantity)
  5. Modern models (Gemini 3.1 Pro, Claude Opus 4.6) handle this MUCH better
```

### Context Engineering in Practice

```python
# ═══ Context Engineering Example ═══

def build_context(user_query: str, conversation_history: list) -> list:
    messages = []

    # 1. System prompt (always first, high attention)
    messages.append({
        "role": "system",
        "content": SYSTEM_PROMPT  # Company rules, persona, constraints
    })

    # 2. Cached reference docs (expensive, reuse across calls)
    # Use provider-specific caching (Anthropic cache_control, etc.)
    messages.append({
        "role": "system",
        "content": PRODUCT_MANUAL,  # 50-page manual, cached
        "cache_control": {"type": "ephemeral"}  # Anthropic syntax
    })

    # 3. RAG results (query-specific, fresh each call)
    relevant_chunks = retrieve_from_vector_db(user_query, top_k=5)
    messages.append({
        "role": "system",
        "content": f"Relevant context:\n{format_chunks(relevant_chunks)}"
    })

    # 4. Conversation history (sliding window)
    # Keep last N turns to stay within token budget
    recent_history = conversation_history[-10:]  # Last 10 turns
    messages.extend(recent_history)

    # 5. User's actual question (last, high attention)
    messages.append({
        "role": "user",
        "content": user_query
    })

    return messages
```

---

## ◆ Quick Reference

```
WHEN TO USE WHAT:
  Small doc set (< 100 pages)  → Long context (just paste it)
  Large doc set (1000s of docs) → RAG (retrieve relevant chunks)
  Repeated context across calls → Context caching (save $$$)
  Mixed scenario               → Cache + RAG + long context

TOKEN BUDGET PLANNING:
  Total budget = model's context window
  Reserve for output: ~2K-4K tokens
  System prompt: 500-2000 tokens
  Cached context: up to 50% of remaining
  RAG results: 20-40% of remaining
  Conversation history: 10-20%
  User query: typically < 500 tokens

COST COMPARISON (per 1M input tokens, approximate):
  Standard tokens:  $3-15
  Cached tokens:    $0.30-1.50 (10x cheaper!)
  Short context:    Fast, cheap
  Long context:     Slow, expensive, but comprehensive
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **More context ≠ better answers**: Irrelevant context DILUTES quality. Be strategic about what goes in.
- ⚠️ **Lost in the middle**: Important info gets ignored if buried in the middle. Structure and position matter.
- ⚠️ **Cache invalidation**: When your cached docs update, the cache must be refreshed. Plan for this.
- ⚠️ **Token counting is tricky**: Different models count tokens differently. Always check with the tokenizer.
- ⚠️ **Context window ≠ effective context**: A 1M-token window doesn't mean the model is equally good at using ALL 1M tokens. Effective context is usually shorter.

---

## ○ Interview Angles

- **Q**: When would you use RAG vs just a long context window?
- **A**: Long context when: few documents, need cross-references, latency isn't critical, and you can afford the token cost. RAG when: many documents (more than context window), need real-time data, cost-sensitive, or need to scale to millions of docs. In practice, combine both: cache stable reference docs in context, use RAG for dynamic query-specific retrieval.

- **Q**: What is context engineering?
- **A**: Context engineering is the practice of strategically constructing the full input to an LLM — system prompt, cached reference docs, RAG results, conversation history, and examples — to maximize output quality within the token budget. It's becoming more important than prompt engineering because the quality bottleneck is often WHAT information the model has access to, not HOW you phrase the question.

---

## ★ Connections

| Relationship | Topics                                                             |
| ------------ | ------------------------------------------------------------------ |
| Builds on    | [Rag](./rag.md), [Prompt Engineering](./prompt-engineering.md), [Tokenization](../foundations/tokenization.md)   |
| Leads to     | [Llmops](../production/llmops.md) (cost management), Better AI applications |
| Compare with | Traditional search, Knowledge bases                                |
| Cross-domain | Information retrieval, Memory management, Caching systems          |

---

## ★ Sources

- Google, "Gemini 1.5: Unlocking Multimodal Understanding Across Millions of Tokens" (2024)
- Anthropic, "Prompt Caching" documentation — https://docs.anthropic.com
- Liu et al., "Lost in the Middle: How Language Models Use Long Contexts" (2023)
- Simon Willison, "Context Engineering" blog posts (2025)
