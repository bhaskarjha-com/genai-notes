---
title: "Context Engineering & Long Context"
tags: [context-window, long-context, context-caching, prompt-caching, rag-vs-context, genai]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[rag]]", "[[prompt-engineering]]", "[[../llms/llms-overview]]", "[[../inference/inference-optimization]]"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Context Engineering & Long Context

> âœ¨ **Bit**: In 2023, you could feed an LLM ~4,000 tokens (~3 pages). In 2025, Gemini accepts 1,000,000 tokens (~750,000 words â€” that's 10 novels). This changes EVERYTHING about how we build AI applications. RAG? Sometimes you just paste the entire database.

---

## â˜… TL;DR

- **What**: The art and science of deciding WHAT information goes into an LLM's context window, and using long context + caching to do it efficiently
- **Why**: The context window IS the LLM's working memory. What you put in it determines everything about the output quality.
- **Key point**: Context engineering is replacing "prompt engineering" as THE critical skill. It's not just about the prompt â€” it's about the system prompt + retrieved docs + examples + tool results + conversation history, all managed within a token budget.

---

## â˜… Overview

### Definition

- **Context window**: The maximum number of tokens an LLM can process in a single call (input + output combined)
- **Context engineering**: Strategically constructing the full context (system prompt, examples, retrieved data, conversation history) to maximize output quality within token limits
- **Context caching / Prompt caching**: Reusing pre-computed token representations across API calls to save cost and latency

### Scope

Covers context strategy and optimization. For retrieval-specific techniques, see [Rag](./rag.md). For prompting techniques, see [Prompt Engineering](./prompt-engineering.md).

---

## â˜… Deep Dive

### Context Window Evolution

```
MODEL             â”‚ CONTEXT WINDOW  â”‚ â‰ˆ PAGES â”‚ YEAR
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•ªâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•ªâ•â•â•â•â•â•â•â•â•â•ªâ•â•â•â•â•â•
GPT-3             â”‚     4,096       â”‚     3   â”‚ 2020
GPT-3.5           â”‚    16,384       â”‚    12   â”‚ 2023
GPT-4             â”‚   128,000       â”‚    96   â”‚ 2023
Claude 3          â”‚   200,000       â”‚   150   â”‚ 2024
Gemini 1.5 Pro    â”‚ 1,000,000       â”‚   750   â”‚ 2024
GPT-5.4           â”‚ 1,000,000       â”‚   750   â”‚ 2026
Claude Opus 4.6   â”‚ 1,000,000       â”‚   750   â”‚ 2026
Gemini 3.1 Pro    â”‚ 1,000,000+      â”‚   750+  â”‚ 2026
LLaMA 4 Scout     â”‚10,000,000       â”‚ 7,500   â”‚ 2025

WHAT FITS IN 1M TOKENS:
  10 novels         â”‚ 30 hours of transcripts
  Entire codebase   â”‚ 1000s of documents
  Full legal case   â”‚ Year of emails
```

### RAG vs Long Context vs Context Engineering

```
THE DEBATE (2025-2026):

  RAG:                          LONG CONTEXT:
  "Retrieve relevant chunks"    "Just stuff everything in"

  PROS:                         PROS:
  âœ… Works with ANY context     âœ… No retrieval pipeline
  âœ… Scales to billions of docs âœ… Model sees FULL context
  âœ… Always up-to-date          âœ… Better cross-referencing
  âœ… Cheaper per query          âœ… Simpler architecture

  CONS:                         CONS:
  âŒ Retrieval failures         âŒ Expensive per query
  âŒ Chunking artifacts         âŒ Limited to context size
  âŒ Complex pipeline           âŒ "Lost in the middle" effect
  âŒ Can miss connections       âŒ Slower (more tokens to process)

VERDICT: It's not either/or. Context engineering uses BOTH.

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  CONTEXT ENGINEERING = Strategic combination â”‚
  â”‚                                             â”‚
  â”‚  System prompt (always present)             â”‚
  â”‚  + Cached context (heavy docs, reusable)    â”‚
  â”‚  + RAG results (query-specific chunks)      â”‚
  â”‚  + Conversation history (recent turns)      â”‚
  â”‚  + Examples (few-shot, if needed)            â”‚
  â”‚  + Tool results (function call outputs)     â”‚
  â”‚  = Optimized context window                 â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Context Caching (Prompt Caching)

```
THE COST PROBLEM:
  You have a 50-page manual in your system prompt.
  Every API call re-processes all 50 pages.
  1000 queries/day Ã— 50 pages = MASSIVE token bill.

SOLUTION: Cache the repeated part.

  WITHOUT CACHING:
    Call 1: [System + 50 pages + user question 1]  â†’ process ALL
    Call 2: [System + 50 pages + user question 2]  â†’ process ALL
    Call 3: [System + 50 pages + user question 3]  â†’ process ALL
    Cost: 100% Ã— 3 = 300% tokens

  WITH CACHING:
    Call 1: [System + 50 pages â† CACHE THIS] + [question 1]
    Call 2: [CACHED] + [question 2]  â†’ only process new part
    Call 3: [CACHED] + [question 3]  â†’ only process new part
    Cost: 100% + 10% + 10% = 120% tokens â†’ 60% SAVINGS!

PROVIDER SUPPORT (2026):
  Anthropic:  "Prompt caching" â€” explicit cache_control blocks
  Google:     "Context caching" â€” cache API for Gemini
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
  [Document 2 - low attention]     â† "lost in the middle"
  [Document 3 - low attention]     â† important info here?
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
# â•â•â• Context Engineering Example â•â•â•

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

## â—† Quick Reference

```
WHEN TO USE WHAT:
  Small doc set (< 100 pages)  â†’ Long context (just paste it)
  Large doc set (1000s of docs) â†’ RAG (retrieve relevant chunks)
  Repeated context across calls â†’ Context caching (save $$$)
  Mixed scenario               â†’ Cache + RAG + long context

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

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **More context â‰  better answers**: Irrelevant context DILUTES quality. Be strategic about what goes in.
- âš ï¸ **Lost in the middle**: Important info gets ignored if buried in the middle. Structure and position matter.
- âš ï¸ **Cache invalidation**: When your cached docs update, the cache must be refreshed. Plan for this.
- âš ï¸ **Token counting is tricky**: Different models count tokens differently. Always check with the tokenizer.
- âš ï¸ **Context window â‰  effective context**: A 1M-token window doesn't mean the model is equally good at using ALL 1M tokens. Effective context is usually shorter.

---

## â—‹ Interview Angles

- **Q**: When would you use RAG vs just a long context window?
- **A**: Long context when: few documents, need cross-references, latency isn't critical, and you can afford the token cost. RAG when: many documents (more than context window), need real-time data, cost-sensitive, or need to scale to millions of docs. In practice, combine both: cache stable reference docs in context, use RAG for dynamic query-specific retrieval.

- **Q**: What is context engineering?
- **A**: Context engineering is the practice of strategically constructing the full input to an LLM â€” system prompt, cached reference docs, RAG results, conversation history, and examples â€” to maximize output quality within the token budget. It's becoming more important than prompt engineering because the quality bottleneck is often WHAT information the model has access to, not HOW you phrase the question.

---

## â˜… Connections

| Relationship | Topics                                                             |
| ------------ | ------------------------------------------------------------------ |
| Builds on    | [Rag](./rag.md), [Prompt Engineering](./prompt-engineering.md), [Tokenization](../foundations/tokenization.md)   |
| Leads to     | [Llmops](../production/llmops.md) (cost management), Better AI applications |
| Compare with | Traditional search, Knowledge bases                                |
| Cross-domain | Information retrieval, Memory management, Caching systems          |

---

## â˜… Sources

- Google, "Gemini 1.5: Unlocking Multimodal Understanding Across Millions of Tokens" (2024)
- Anthropic, "Prompt Caching" documentation â€” https://docs.anthropic.com
- Liu et al., "Lost in the Middle: How Language Models Use Long Contexts" (2023)
- Simon Willison, "Context Engineering" blog posts (2025)
