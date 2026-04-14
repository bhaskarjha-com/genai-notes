---
title: "Prompt Engineering"
tags: [prompt-engineering, prompting, few-shot, chain-of-thought, genai-techniques]
type: procedure
difficulty: beginner
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../agents/ai-agents.md", "rag.md", "../llms/llms-overview.md"]
source: "OpenAI Prompt Engineering Guide, Anthropic Prompting Guide"
created: 2026-03-18
updated: 2026-04-11
---

# Prompt Engineering

> ✨ **Bit**: Prompt engineering is the art of asking the right question. Turns out, how you ask an LLM matters as much as what you ask — just like talking to humans.

---

## ★ TL;DR

- **What**: Crafting inputs (prompts) to get desired outputs from LLMs without changing the model
- **Why**: The cheapest, fastest way to improve LLM output. Zero training, zero infra — just better instructions.
- **Key point**: Good prompting follows patterns: be specific, give examples, assign a role, think step-by-step.

---

## ★ Overview

### Definition

**Prompt Engineering** is the practice of designing and refining inputs to LLMs to elicit specific, high-quality responses. It encompasses techniques from simple instruction formatting to complex multi-step reasoning frameworks.

### Scope

Covers prompting techniques from basic to advanced. For when prompting isn't enough, see [Fine Tuning](./fine-tuning.md) and [Rag](./rag.md).

### Significance

- First thing to try before any other technique (cheapest, fastest)
- Skill every AI practitioner needs regardless of technical depth
- The difference between "LLM gives garbage" and "LLM gives gold" is often just the prompt

### Prerequisites

- Basic understanding of [Llms Overview](../llms/llms-overview.md)

---

## ★ Deep Dive

### The Prompting Hierarchy (Simplest → Most Complex)

```
Level 1: Zero-Shot       → "Translate this to French: Hello"
Level 2: System Prompt   → "You are a French translator. Translate: Hello"
Level 3: Few-Shot        → "Here are 3 examples. Now do this one..."
Level 4: Chain-of-Thought → "Think step by step..."
Level 5: Self-Consistency → Generate multiple answers, pick the majority
Level 6: ReAct / Tool Use → Think, Act, Observe loops (enters Agent territory)
```

### Key Techniques

#### 1. System Prompts (Role Assignment)

```
WEAK:  "Summarize this article"
STRONG: "You are an expert technical editor. Summarize the following
         article in 3 bullet points, focusing on practical implications
         for software engineers. Use precise technical language."
```

**Why it works**: Activates the model's "persona" — trained on text BY experts, so "being" an expert improves output.

#### 2. Few-Shot Prompting

```
Classify the sentiment:

"This product is amazing!" → Positive
"Worst purchase ever." → Negative
"It's okay, nothing special." → Neutral

"The quality exceeded my expectations!" →
```

**Rule of thumb**: 3-5 examples is the sweet spot. More examples = more consistent, but uses context window.

#### 3. Chain of Thought (CoT)

```
WEAK:  "What is 17 × 24?"
STRONG: "What is 17 × 24? Think step by step."

Model output with CoT:
  "17 × 24
   = 17 × 20 + 17 × 4
   = 340 + 68
   = 408"
```

**Why it works**: Forces the model to show intermediate reasoning, reducing errors. Especially effective for math, logic, and multi-step problems.

#### 4. Structured Output

```
"Analyze this code and respond in the following JSON format:
{
  "bugs": [{"line": int, "description": string, "severity": "high|medium|low"}],
  "suggestions": [string],
  "overall_quality": int  // 1-10
}"
```

**Why structured**: Parseable by code, consistent format, forces completeness.

#### 5. The META Framework

| Element          | Description              | Example                         |
| ---------------- | ------------------------ | ------------------------------- |
| **M**ission      | What's the overall goal? | "You are a code reviewer"       |
| **E**xpectations | What format/quality?     | "Be concise, cite line numbers" |
| **T**ask         | Specific action          | "Review this Python function"   |
| **A**rtifacts    | Examples/reference       | "Here's an example review..."   |

### Advanced Patterns

| Pattern                 | How                                            | Use Case                         |
| ----------------------- | ---------------------------------------------- | -------------------------------- |
| **Self-Consistency**    | Generate N responses, majority vote            | Math, factual questions          |
| **Tree of Thought**     | Explore multiple reasoning branches            | Complex problem-solving          |
| **Least-to-Most**       | Break complex problem into sub-problems        | Problems requiring decomposition |
| **Generated Knowledge** | "First, tell me facts about X. Then, answer Y" | Knowledge-intensive questions    |
| **Prompt Chaining**     | Output of prompt A → Input of prompt B         | Multi-stage pipelines            |

### The Prompting Mistake Matrix

| ❌ Common Mistake        | ✅ Better Approach                                                                                     |
| ----------------------- | ----------------------------------------------------------------------------------------------------- |
| "Write good code"       | "Write Python 3.12 code that handles edge cases. Include type hints, docstrings, and error handling." |
| "Summarize this"        | "Summarize in 3 bullet points for a technical audience. Each bullet max 20 words."                    |
| "Be creative"           | "Generate 5 alternative approaches, ranked by feasibility. For each, explain trade-offs."             |
| "Fix the bug"           | "Identify the root cause. Explain why it fails. Provide corrected code with comments on changes."     |
| Dumping entire codebase | Provide only the relevant function + error message + expected behavior                                |

---

## ◆ Quick Reference

```
PROMPTING CHECKLIST:
□ Define ROLE      → "You are a [specific expert]"
□ Set CONTEXT      → Background info the model needs
□ State TASK       → Exactly what to do
□ Specify FORMAT   → How to structure the output
□ Give EXAMPLES    → 2-3 examples of desired output
□ Add CONSTRAINTS  → What NOT to do, length limits, etc.
□ Request REASONING → "Think step by step" / "Explain your reasoning"

TEMPERATURE GUIDE:
  0.0 → Factual, deterministic (data extraction, classification)
  0.3 → Balanced (summarization, coding)
  0.7 → Creative (writing, brainstorming)
  1.0 → Very creative (poetry, fiction)
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths                   | ❌ Limitations                                            |
| ----------------------------- | -------------------------------------------------------- |
| Zero cost (no training/infra) | Can't add new knowledge                                  |
| Instant iteration             | Fragile — small changes = different results              |
| Works with any model          | Context window limits complexity                         |
| Easy to A/B test              | Can't change model behavior permanently                  |
| Good starting point always    | Diminishing returns at some point → need RAG/fine-tuning |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Prompt ≠ Programming**: Prompts are probabilistic, not deterministic. Same prompt can give different results.
- ⚠️ **"Be concise" doesn't work well**: Instead say "Respond in exactly 3 sentences" — be specific about constraints.
- ⚠️ **Prompt injection**: Users can override your system prompt. Never trust user input in prompts for production apps.
- ⚠️ **Position matters**: Important instructions at the beginning AND end of prompts are most likely followed (primacy/recency effect).
- ⚠️ **"Just prompt engineer it" is a ceiling**: For domain expertise, consistent behavior, or new knowledge — prompting alone won't cut it.

---

## ○ Interview Angles

- **Q**: What's the difference between zero-shot, few-shot, and chain-of-thought prompting?
- **A**: Zero-shot: just instructions, no examples. Few-shot: include examples of desired input→output pairs. CoT: ask model to show reasoning steps. Each adds more guidance and typically improves quality.

- **Q**: How would you handle prompt injection in a production system?
- **A**: Input sanitization, separate system/user prompts, output validation, don't include raw user input in system prompts. Use the model's built-in system prompt separation. For critical apps, add a second LLM call to verify the first output makes sense.

---

## ★ Connections

| Relationship | Topics                                                                |
| ------------ | --------------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md)                                             |
| Leads to     | [Ai Agents](../agents/ai-agents.md), [Rag](./rag.md) (prompt is key in RAG too)                     |
| Compare with | [Fine Tuning](./fine-tuning.md) (permanent behavior change), [Rag](./rag.md) (adds knowledge) |
| Cross-domain | UX writing, Human communication, Psychology (framing effects)         |

---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering) | Industry-best prompt engineering documentation |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 5 (Prompt Engineering) | Systematic treatment of prompting techniques with evaluation |
| 🔧 Hands-on | [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering) | Practical tips with examples for GPT models |
| 🎓 Course | [deeplearning.ai — "ChatGPT Prompt Engineering"](https://www.deeplearning.ai/) | Short, practical course on effective prompting |

## ★ Sources

- OpenAI Prompt Engineering Guide — https://platform.openai.com/docs/guides/prompt-engineering
- Anthropic Prompt Engineering Guide — https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering
- Wei et al., "Chain-of-Thought Prompting" (2022)
- Yao et al., "Tree of Thoughts" (2023)
