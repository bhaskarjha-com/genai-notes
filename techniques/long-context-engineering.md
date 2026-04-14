---
title: "Long-Context Engineering"
tags: [long-context, context-window, rag, chunking, needle-in-haystack, production]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "[[../foundations/transformers]]"
related: ["[[../techniques/rag]]", "[[../techniques/context-engineering]]", "[[../inference/inference-optimization]]", "[[../foundations/attention-mechanism]]"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# Long-Context Engineering

> ✨ **Bit**: Models now accept 1M+ tokens — but "accepts" ≠ "uses well." Long-context engineering is the art of deciding what to put in that window, how to structure it, and when RAG still beats stuffing everything in.

---

## ★ TL;DR

- **What**: Techniques for effectively using large context windows (128K-2M tokens) — structuring input, managing retrieval vs context stuffing, and handling the "lost in the middle" problem
- **Why**: Context windows grew 1000× in 3 years (4K → 2M tokens). Knowing how to use them well is now a core GenAI engineering skill.
- **Key point**: Longer context ≠ better results. Models degrade on information in the middle of long contexts. Strategic placement, chunking, and hybrid RAG+context approaches outperform naive stuffing.

---

## ★ Overview

### Definition

**Long-context engineering** is the practice of designing AI systems that effectively utilize large context windows — deciding what information to include, how to structure it, and when to use retrieval vs direct context inclusion.

### Scope

Covers: Context window capabilities across models, the "lost in the middle" phenomenon, RAG vs long context tradeoffs, practical structuring strategies, and production code. For retrieval specifically, see [RAG](../techniques/rag.md). For attention mechanics, see [Attention Mechanism](../foundations/attention-mechanism.md).

### Significance

- **Architecture decision**: RAG vs long context vs hybrid is a key system design choice
- **Cost impact**: 1M tokens of context costs $2.50-$75 per request depending on model
- **Quality impact**: Poorly structured long context can degrade performance vs shorter, curated context

### Prerequisites

- [Context Engineering](../techniques/context-engineering.md)
- [RAG](../techniques/rag.md)
- [Attention Mechanism](../foundations/attention-mechanism.md)

---

## ★ Deep Dive

### Context Window Landscape (April 2026)

| Model | Max Context | Effective Context | Cost per 1M Input Tokens |
|-------|:----------:|:-----------------:|:------------------------:|
| Gemini 2.5 Pro | 1M tokens | ~800K reliable | $1.25 |
| Gemini 2.5 Flash | 1M tokens | ~800K reliable | $0.15 |
| Claude 3.5 Sonnet | 200K tokens | ~150K reliable | $3.00 |
| GPT-4o | 128K tokens | ~100K reliable | $2.50 |
| Llama 3.1 405B | 128K tokens | ~80K reliable | Self-hosted |

### The "Lost in the Middle" Problem

```
INFORMATION RECALL BY POSITION IN CONTEXT:

  Beginning ████████████████████ 95% recall   ← STRONG
  Position 25%  ███████████████  80% recall
  Middle    ██████████           55% recall   ← WEAK (lost!)
  Position 75%  ███████████████  78% recall
  End       ████████████████████ 92% recall   ← STRONG

  KEY INSIGHT: Models attend strongest to the beginning and
  end of context. Information buried in the middle gets
  "lost" — lower recall accuracy on retrieval tasks.

  PRACTICAL IMPACT:
  - Put the most important information at the START or END
  - Don't bury key instructions in the middle of examples
  - For RAG: put the most relevant chunk first, not randomly
```

### RAG vs Long Context vs Hybrid

```
DECISION FRAMEWORK:

  ┌─────────────────────────────────────────────────────┐
  │ How much source material do you have?                │
  │                                                       │
  │  < 50K tokens?                                       │
  │  └─ STUFF IT ALL IN CONTEXT                          │
  │     Simpler, no retrieval infrastructure needed       │
  │                                                       │
  │  50K - 500K tokens?                                  │
  │  └─ HYBRID: Retrieve top chunks + long context       │
  │     Best of both worlds                               │
  │                                                       │
  │  > 500K tokens? (e.g., entire codebase, doc corpus)  │
  │  └─ RAG with retrieval pipeline                      │
  │     Can't fit it all, need smart selection            │
  └─────────────────────────────────────────────────────┘

  COST COMPARISON (processing 200K tokens of source material):

  Approach          | Per Request Cost | Latency | Quality
  ──────────────────|─────────────────|─────────|────────
  Full context      | $0.50 - $15.00  | 3-15s   | Good (if structured)
  RAG (top 5 chunks)| $0.01 - $0.10  | 1-3s    | Good (if retrieval works)
  Hybrid            | $0.10 - $1.00  | 2-5s    | Best
```

### Context Structuring Best Practices

```
OPTIMAL CONTEXT LAYOUT:

  ┌──────────────────────────────────────────┐
  │  SYSTEM PROMPT (instructions, persona)   │  ← Beginning: highest attention
  ├──────────────────────────────────────────┤
  │  MOST RELEVANT CONTEXT                   │  ← Place critical info early
  │  (top RAG chunks, key documents)         │
  ├──────────────────────────────────────────┤
  │  SUPPORTING CONTEXT                      │  ← Middle: lower attention
  │  (additional chunks, examples)           │
  ├──────────────────────────────────────────┤
  │  CONVERSATION HISTORY                    │  ← Recent context
  ├──────────────────────────────────────────┤
  │  USER'S CURRENT MESSAGE                  │  ← End: high attention
  └──────────────────────────────────────────┘

  RULES:
  1. Put instructions at START (system prompt)
  2. Put most relevant info RIGHT AFTER system prompt
  3. Put the user's question at the END
  4. Never bury key constraints in the middle
  5. Use clear section headers/delimiters (XML tags, markdown headers)
```

---

## ★ Code & Implementation

### Structured Long-Context Prompt Builder

```python
# pip install openai>=1.0 tiktoken>=0.7
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.0

import tiktoken
from openai import OpenAI

client = OpenAI()
encoder = tiktoken.encoding_for_model("gpt-4o")

def count_tokens(text: str) -> int:
    """Count tokens in text."""
    return len(encoder.encode(text))

def build_long_context_prompt(
    system_prompt: str,
    relevant_chunks: list[str],       # Ranked by relevance (best first)
    supporting_docs: list[str],
    conversation_history: list[dict],
    user_question: str,
    max_context_tokens: int = 100_000,
) -> list[dict]:
    """Build an optimally structured long-context prompt.
    
    Places information strategically:
    - System prompt: beginning (highest attention)
    - Most relevant chunks: right after system prompt
    - Supporting docs: middle (lower attention, OK for background)
    - Conversation history: before user message
    - User question: end (high attention)
    """
    messages = [{"role": "system", "content": system_prompt}]
    token_budget = max_context_tokens - count_tokens(system_prompt) - count_tokens(user_question)
    used_tokens = 0
    
    # Priority 1: Add relevant chunks (highest value)
    context_parts = []
    for i, chunk in enumerate(relevant_chunks):
        chunk_tokens = count_tokens(chunk)
        if used_tokens + chunk_tokens > token_budget * 0.6:  # 60% budget for relevant
            break
        context_parts.append(f"<relevant_context id='{i+1}'>\n{chunk}\n</relevant_context>")
        used_tokens += chunk_tokens
    
    # Priority 2: Add supporting docs (fill remaining budget)
    for i, doc in enumerate(supporting_docs):
        doc_tokens = count_tokens(doc)
        if used_tokens + doc_tokens > token_budget * 0.85:  # 85% total budget
            break
        context_parts.append(f"<supporting_doc id='{i+1}'>\n{doc}\n</supporting_doc>")
        used_tokens += doc_tokens
    
    # Assemble: relevant context first (high attention position)
    if context_parts:
        messages.append({
            "role": "user",
            "content": "Here is the reference material:\n\n" + "\n\n".join(context_parts),
        })
        messages.append({
            "role": "assistant",
            "content": "I've reviewed all the reference material. What would you like to know?",
        })
    
    # Add conversation history (recent turns only)
    for msg in conversation_history[-10:]:  # Last 10 turns
        messages.append(msg)
    
    # User question at the end (high attention position)
    messages.append({"role": "user", "content": user_question})
    
    total = sum(count_tokens(m["content"]) for m in messages)
    print(f"Total context: {total:,} tokens ({total/max_context_tokens:.0%} of budget)")
    return messages

# Usage
messages = build_long_context_prompt(
    system_prompt="You are a technical writer. Answer based ONLY on the provided context.",
    relevant_chunks=["Chunk 1: Most relevant info...", "Chunk 2: Second most relevant..."],
    supporting_docs=["Full document A...", "Full document B..."],
    conversation_history=[],
    user_question="Summarize the key findings about distributed training.",
    max_context_tokens=100_000,
)

response = client.chat.completions.create(model="gpt-4o", messages=messages)
print(response.choices[0].message.content)
```

---

## ◆ Quick Reference

```
CONTEXT WINDOW RULES OF THUMB:

  < 10K tokens:    Any model works, no special engineering needed
  10K-50K tokens:  Structure matters — use XML tags, headers, clear sections
  50K-200K tokens: "Lost in the middle" is real — put key info at start/end
  200K-1M tokens:  Cost dominates — consider hybrid RAG + context approach
  > 1M tokens:     Must use RAG — no model handles this reliably yet

TOKEN ESTIMATION:
  1 page of text  ≈ 400-500 tokens
  1 code file     ≈ 200-2000 tokens
  10-page PDF     ≈ 4,000-5,000 tokens
  100-page report ≈ 40,000-50,000 tokens
  Entire codebase ≈ 200,000-2,000,000 tokens
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Lost in the middle** | Model ignores key info buried in long context | Attention degradation in middle positions | Place critical info at start/end, use clear delimiters |
| **Context window cost explosion** | $10+ per request | Stuffing entire documents when only paragraphs are needed | Use RAG to select relevant chunks, not whole documents |
| **Hallucination despite context** | Model makes up facts not in the provided documents | Context too long for reliable grounding | Shorten context, add "answer ONLY from context" instruction, verify citations |
| **Latency spike** | 10-30 second response times | Processing 500K+ tokens takes time (TTFT scales with input) | Reduce context, use faster models (Flash), cache repeated contexts |

---

## ○ Interview Angles

- **Q**: When would you use RAG vs long context?
- **A**: It depends on corpus size, cost tolerance, and update frequency. If the source material is < 50K tokens and relatively static (e.g., a product manual), I'd stuff it directly into context — simpler architecture, no retrieval failures. For 50K-500K tokens, I'd use a hybrid: retrieve the top 5-10 most relevant chunks via RAG, then include them in a long-context prompt with supporting background. For > 500K tokens (entire codebases, large doc collections), RAG is necessary — no model reliably processes that much context. I'd also consider cost: a 200K-token context costs $0.50-$15 per request at API prices, vs $0.01-$0.10 for RAG with small chunks.

---

## ◆ Hands-On Exercises

### Exercise 1: Needle-in-a-Haystack Test

**Goal**: Test your model's recall at different positions in a long context
**Time**: 30 minutes
**Steps**:
1. Create a 50K-token document by concatenating text
2. Insert a unique fact ("The secret code is ALPHA-7") at positions: start, 25%, middle, 75%, end
3. Ask the model "What is the secret code?" for each position
4. Compare recall accuracy by position
**Expected Output**: Accuracy table showing the "lost in the middle" effect

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Context Engineering](../techniques/context-engineering.md), [RAG](../techniques/rag.md), [Attention Mechanism](../foundations/attention-mechanism.md) |
| Leads to | Document processing pipelines, codebase-aware AI tools, long-form analysis |
| Compare with | Short-context techniques, summarization chains |
| Cross-domain | Information retrieval, document management, search systems |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Liu et al. "Lost in the Middle" (2023)](https://arxiv.org/abs/2307.03172) | Definitive study of positional attention degradation |
| 📄 Paper | [Google "Leave No Context Behind" (2024)](https://arxiv.org/abs/2404.07143) | Infini-attention for unbounded context |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 3 | RAG vs long context tradeoffs in production |
| 🔧 Hands-on | [Google AI Studio](https://aistudio.google.com/) | Test Gemini's 1M-token context window for free |

---

## ★ Sources

- Liu et al. "Lost in the Middle: How Language Models Use Long Contexts" (2023)
- Google "Leave No Context Behind: Efficient Infinite Context Transformers" (2024)
- Anthropic Context Window Documentation — https://docs.anthropic.com/
- [RAG](../techniques/rag.md)
- [Context Engineering](../techniques/context-engineering.md)
