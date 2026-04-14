---
title: "Large Language Models (LLMs)"
tags: [llm, gpt, claude, gemini, llama, language-models, genai]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../foundations/transformers.md", "../techniques/rag.md", "../techniques/fine-tuning.md", "hallucination-detection.md"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# Large Language Models (LLMs)

> ✨ **Bit**: LLMs are stochastic parrots that accidentally learned to reason. Or did they? The debate continues.

---

## ★ TL;DR

- **What**: Neural networks (Transformer-based) trained on massive text corpora to understand and generate human language
- **Why**: Foundation of modern AI assistants, code generation, search, and almost every GenAI product
- **Key point**: "Scaling laws" showed that performance predictably improves with more data + compute + parameters. This triggered the arms race.

---

## ★ Overview

### Definition

**Large Language Models (LLMs)** are autoregressive Transformer models (decoder-only) with billions to trillions of parameters, trained on internet-scale text data to predict the next token. Through scale, they develop emergent capabilities: reasoning, coding, translation, analysis — tasks they were never explicitly taught.

### Scope

This document covers LLMs as a category. For specific model families, see sub-documents. For the underlying architecture, see [Transformers](../foundations/transformers.md). For reliability risks and grounding strategy, see [Hallucination Detection & Mitigation](./hallucination-detection.md).

### Significance

- The core technology behind ChatGPT, Claude, Gemini, Copilot
- LLM market: $7.77B (2025) → projected $10.57B (2026)
- Anthropic surpassed OpenAI in enterprise usage in 2025

Last verified for market and provider-snapshot statements: 2026-04.

### Prerequisites

- [Transformers](../foundations/transformers.md) — architecture
- [Attention Mechanism](../foundations/attention-mechanism.md) — how attention works

---

## ★ Deep Dive

### How LLMs Are Built

```
Phase 1: PRE-TRAINING (the expensive part)
  ┌─────────────────────────────────────────────────┐
  │ Internet text (trillions of tokens)              │
  │            ↓                                     │
  │ Train: Predict next token                        │
  │   "The cat sat on the ___" → "mat"              │
  │            ↓                                     │
  │ Result: Base model (knows language, world facts) │
  │          Cost: $10M - $100M+                     │
  └─────────────────────────────────────────────────┘

Phase 2: ALIGNMENT (making it helpful & safe)
  ┌─────────────────────────────────────────────────┐
  │ SFT: Supervised Fine-Tuning on instruction data │
  │   Input: "Explain quantum computing"            │
  │   Output: [high-quality human-written answer]    │
  │            ↓                                     │
  │ RLHF/DPO: Learn from human preferences          │
  │   "Which response is better: A or B?"           │
  │            ↓                                     │
  │ Result: Chat model (helpful, harmless, honest)   │
  └─────────────────────────────────────────────────┘

Phase 3: DEPLOYMENT
  ┌─────────────────────────────────────────────────┐
  │ API / Chat interface                             │
  │ + RAG for up-to-date knowledge                  │
  │ + Tool use for actions (search, code execution) │
  │ + Guardrails for safety                          │
  └─────────────────────────────────────────────────┘
```

### The Major Model Families (March 2026)

#### Closed-Source

| Model      | Company   | Latest                | Key Strengths                                          | Context |
| ---------- | --------- | --------------------- | ------------------------------------------------------ | ------- |
| **GPT**    | OpenAI    | GPT-5.4 Pro           | Unified reasoning + multimodal, reduced hallucinations | Large   |
| **Claude** | Anthropic | Opus 4.6, Sonnet 4.6  | Best coding + agents, extended thinking                | 200K    |
| **Gemini** | Google    | 3.1 Pro, 3 Deep Think | Massive context (2M tokens), science/research          | 2M      |

#### Open-Weight

| Model        | Company    | Latest                            | Key Strengths                             | Architecture             |
| ------------ | ---------- | --------------------------------- | ----------------------------------------- | ------------------------ |
| **LLaMA**    | Meta       | LLaMA 4 (Scout/Maverick/Behemoth) | First multimodal LLaMA, MoE               | MoE, 10M context (Scout) |
| **Qwen**     | Alibaba    | Qwen 2.5+                         | Surpassed LLaMA in open-source popularity | Dense & MoE              |
| **Mistral**  | Mistral AI | Mistral Large 2                   | Strong European alternative               | Dense & MoE              |
| **DeepSeek** | DeepSeek   | DeepSeek-V3, R1                   | Competitive at fraction of cost           | MoE                      |
| **Gemma**    | Google     | Gemma 2                           | Small but powerful (2B-27B)               | Dense                    |

### Scaling Laws (Chinchilla)

The relationship between model size, data, and performance:

```
Performance ∝ (Compute)^α

Where Compute = f(Parameters × Training Tokens)

Chinchilla optimal: Train for ~20 tokens per parameter
  - 7B model → 140B tokens
  - 70B model → 1.4T tokens

Modern trend: Over-train smaller models (more tokens per param)
for better inference efficiency
```

### Key Concepts Every Deep-Tech Person Must Know

#### Tokenization
Text → numbers. Models don't see words; they see token IDs.

```python
# ⚠️ Last tested: 2026-04
"Hello world" → [15496, 995]        # GPT-style BPE
"Hello world" → [8774, 296, 1650]    # Different tokenizer

# ~4 characters ≈ 1 token (English average)
# Non-English: often 2-3x more tokens per word
```

Tokenizers: BPE (GPT), WordPiece (BERT), SentencePiece (LLaMA/Gemini)

#### Inference: How Generation Works

```
Input: "The capital of France is"

Step 1: Process all input tokens (prefill)
Step 2: Generate token "Paris" → append to sequence
Step 3: Generate token "." → append
Step 4: Generate token "<EOS>" → stop

Each step: Full forward pass through the model
KV Cache: Store key/value pairs to avoid recomputation
```

#### Temperature & Sampling

```
Temperature = 0.0: Always pick highest probability (deterministic)
Temperature = 0.7: Balanced creativity vs coherence (common default)
Temperature = 1.0: Full probability distribution
Temperature > 1.0: More random/creative

Top-p (nucleus sampling): Only sample from tokens whose cumulative
probability reaches p (e.g., top_p=0.9)

Top-k: Only sample from the k most likely tokens
```

---

## ◆ Comparison

| Aspect           | GPT-5.x             | Claude 4.x      | Gemini 3.x             | LLaMA 4                 |
| ---------------- | ------------------- | --------------- | ---------------------- | ----------------------- |
| **Best at**      | General reasoning   | Coding + agents | Long context + science | Open-weight flexibility |
| **Context**      | Large               | 200K            | Up to 2M               | 10M (Scout)             |
| **Access**       | API only            | API only        | API + Cloud            | Downloadable weights    |
| **Cost**         | $$$                 | $$              | $$                     | Free (compute costs)    |
| **Fine-tuning**  | Limited             | Limited         | Via Vertex AI          | Full control            |
| **Architecture** | Dense (rumored MoE) | Dense           | Dense variants         | MoE                     |

---

## ◆ Use Cases & Applications

| Use Case                | How LLMs Are Used                     | Key Challenge            |
| ----------------------- | ------------------------------------- | ------------------------ |
| **Chat assistants**     | Direct conversation (ChatGPT, Claude) | Hallucination            |
| **Code generation**     | Copilot, Cursor, Devin                | Correctness verification |
| **Search**              | Perplexity, Google AI Overviews       | Up-to-date knowledge     |
| **Document processing** | Summarization, extraction, Q&A        | Long document handling   |
| **Translation**         | Near-human quality across languages   | Nuance, cultural context |
| **Agents**              | Autonomous task execution with tools  | Reliability, safety      |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Hallucination ≠ lying**: The model generates plausible continuations, not facts. It has no concept of truth.
- ⚠️ **Context window ≠ memory**: LLMs don't remember across conversations unless you build memory systems
- ⚠️ **Bigger ≠ always better**: A well-fine-tuned 7B model can beat a generic 70B model on specific tasks
- ⚠️ **Tokens ≠ words**: Pricing and limits are in tokens (~4 chars each). Non-English = more tokens
- ⚠️ **Benchmarks lie**: Models are increasingly trained on benchmark data. Real-world eval matters more

---

## ○ Interview Angles

- **Q**: Explain the training pipeline of a modern LLM.
- **A**: Pre-training (next-token prediction on internet text) → SFT (supervised fine-tuning on instruction-response pairs) → RLHF/DPO (learning from human preference comparisons) → Safety alignment

- **Q**: What's the difference between dense and MoE architectures?
- **A**: Dense: every parameter processes every token (e.g., GPT-4, Claude). MoE: tokens are routed to a subset of "expert" sub-networks (e.g., LLaMA 4 Maverick). MoE gives more total capacity with less compute per token.

- **Q**: How do you choose between using an API (GPT/Claude) vs hosting an open model (LLaMA)?
- **A**: API: faster to start, best performance, no infra. Self-host: data stays private, no vendor lock-in, customizable. Cost crossover: at ~1M+ tokens/day, self-hosting often becomes cheaper.

---

## ★ Code & Implementation

### Call OpenAI GPT API (Streaming)

```python
# pip install openai>=1.60
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var
from openai import OpenAI

client = OpenAI()

# Token counting pre-flight (avoid hitting context limits)
import tiktoken
enc = tiktoken.encoding_for_model("gpt-4o")
user_message = "Explain transformers in 3 sentences."
token_count = len(enc.encode(user_message))
print(f"Prompt tokens: {token_count}")  # Budget-check before expensive call

# Streaming generation
stream = client.chat.completions.create(
    model="gpt-4o-mini",  # ~30x cheaper than gpt-4o, 90% quality
    messages=[
        {"role": "system", "content": "You are a concise ML expert."},
        {"role": "user", "content": user_message},
    ],
    max_tokens=200,
    temperature=0.7,
    stream=True,
)
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
print()  # newline after streaming
```

### Load Open-Weight LLM with HuggingFace

```python
# pip install transformers>=4.40 torch>=2.3
# ⚠️ Last tested: 2026-04 | Requires: transformers>=4.40, torch>=2.3
# Note: CPU-only is slow. GPU (CUDA or MPS) strongly recommended.
from transformers import pipeline

# Gemma 4 E2B: 2B params, ~5GB, runs on most GPUs
pipe = pipeline(
    "text-generation",
    model="google/gemma-2-2b-it",
    device_map="auto",  # auto-detect GPU/CPU
    max_new_tokens=200,
    do_sample=True,
    temperature=0.7,
)

response = pipe([{"role": "user", "content": "What is an LLM?"}])
print(response[0]["generated_text"][-1]["content"])
```

---

## ★ Connections


| Relationship | Topics                                                                                                                  |
| ------------ | ----------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Transformers](../foundations/transformers.md), [Attention Mechanism](../foundations/attention-mechanism.md)                                                 |
| Leads to     | [Rag](../techniques/rag.md), [Fine Tuning](../techniques/fine-tuning.md), [Ai Agents](../agents/ai-agents.md), [Prompt Engineering](../techniques/prompt-engineering.md) |
| Compare with | Traditional NLP (rule-based), Smaller language models (BERT-era)                                                        |
| Cross-domain | Cognitive science (language understanding), Linguistics                                                                 |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Hallucination in critical paths** | Confident but factually wrong outputs in production | No grounding, no verification layer | RAG, citation requirements, confidence calibration |
| **Prompt sensitivity** | Small wording changes cause dramatically different outputs | Models are sensitive to prompt phrasing | Prompt testing suite, A/B test prompts, few-shot examples |
| **Context window mismanagement** | Truncated context or token limit errors | No token counting before API call | Pre-flight token counting, dynamic prompt assembly |

---

## ◆ Hands-On Exercises

### Exercise 1: Stress-Test an LLM's Boundaries

**Goal**: Systematically discover where an LLM fails
**Time**: 30 minutes
**Steps**:
1. Create 20 test cases: factual, reasoning, math, code, multilingual
2. Run through your production LLM
3. Grade each response (correct, partially correct, hallucinated, refused)
4. Create a failure pattern taxonomy
**Expected Output**: Failure taxonomy with frequency counts per category
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 1-2 | Best introduction to LLMs for practitioners |
| 🎥 Video | [Andrej Karpathy — "Intro to Large Language Models"](https://www.youtube.com/watch?v=zjkBMFhNj_g) | Best 1-hour overview of how LLMs work |
| 📘 Book | "Build a Large Language Model (From Scratch)" by Sebastian Raschka (2024) | Implement an LLM from scratch in PyTorch |
| 🔧 Hands-on | [HuggingFace Transformers](https://huggingface.co/docs/transformers/) | Production library for working with LLMs |

## ★ Sources

- OpenAI GPT-5 release blog and model cards (2025-2026)
- Anthropic Claude 4 model documentation (2025-2026)
- Google Gemini release notes (2025-2026)
- Meta LLaMA 4 announcement (April 2025)
- Hoffmann et al., "Training Compute-Optimal Large Language Models" (Chinchilla, 2022)
- Sebastian Raschka, "LLM Year in Review 2025"
