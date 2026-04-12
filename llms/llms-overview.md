---
title: "Large Language Models (LLMs)"
tags: [llm, gpt, claude, gemini, llama, language-models, genai]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../foundations/transformers]]", "[[../techniques/rag]]", "[[../techniques/fine-tuning]]", "[[hallucination-detection]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# Large Language Models (LLMs)

> âœ¨ **Bit**: LLMs are stochastic parrots that accidentally learned to reason. Or did they? The debate continues.

---

## â˜… TL;DR

- **What**: Neural networks (Transformer-based) trained on massive text corpora to understand and generate human language
- **Why**: Foundation of modern AI assistants, code generation, search, and almost every GenAI product
- **Key point**: "Scaling laws" showed that performance predictably improves with more data + compute + parameters. This triggered the arms race.

---

## â˜… Overview

### Definition

**Large Language Models (LLMs)** are autoregressive Transformer models (decoder-only) with billions to trillions of parameters, trained on internet-scale text data to predict the next token. Through scale, they develop emergent capabilities: reasoning, coding, translation, analysis â€” tasks they were never explicitly taught.

### Scope

This document covers LLMs as a category. For specific model families, see sub-documents. For the underlying architecture, see [Transformers](../foundations/transformers.md). For reliability risks and grounding strategy, see [Hallucination Detection & Mitigation](./hallucination-detection.md).

### Significance

- The core technology behind ChatGPT, Claude, Gemini, Copilot
- LLM market: $7.77B (2025) â†’ projected $10.57B (2026)
- Anthropic surpassed OpenAI in enterprise usage in 2025

Last verified for market and provider-snapshot statements: 2026-04.

### Prerequisites

- [Transformers](../foundations/transformers.md) â€” architecture
- [Attention Mechanism](../foundations/attention-mechanism.md) â€” how attention works

---

## â˜… Deep Dive

### How LLMs Are Built

```
Phase 1: PRE-TRAINING (the expensive part)
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚ Internet text (trillions of tokens)              â”‚
  â”‚            â†“                                     â”‚
  â”‚ Train: Predict next token                        â”‚
  â”‚   "The cat sat on the ___" â†’ "mat"              â”‚
  â”‚            â†“                                     â”‚
  â”‚ Result: Base model (knows language, world facts) â”‚
  â”‚          Cost: $10M - $100M+                     â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Phase 2: ALIGNMENT (making it helpful & safe)
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚ SFT: Supervised Fine-Tuning on instruction data â”‚
  â”‚   Input: "Explain quantum computing"            â”‚
  â”‚   Output: [high-quality human-written answer]    â”‚
  â”‚            â†“                                     â”‚
  â”‚ RLHF/DPO: Learn from human preferences          â”‚
  â”‚   "Which response is better: A or B?"           â”‚
  â”‚            â†“                                     â”‚
  â”‚ Result: Chat model (helpful, harmless, honest)   â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

Phase 3: DEPLOYMENT
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚ API / Chat interface                             â”‚
  â”‚ + RAG for up-to-date knowledge                  â”‚
  â”‚ + Tool use for actions (search, code execution) â”‚
  â”‚ + Guardrails for safety                          â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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
Performance âˆ (Compute)^Î±

Where Compute = f(Parameters Ã— Training Tokens)

Chinchilla optimal: Train for ~20 tokens per parameter
  - 7B model â†’ 140B tokens
  - 70B model â†’ 1.4T tokens

Modern trend: Over-train smaller models (more tokens per param)
for better inference efficiency
```

### Key Concepts Every Deep-Tech Person Must Know

#### Tokenization
Text â†’ numbers. Models don't see words; they see token IDs.

```python
"Hello world" â†’ [15496, 995]        # GPT-style BPE
"Hello world" â†’ [8774, 296, 1650]    # Different tokenizer

# ~4 characters â‰ˆ 1 token (English average)
# Non-English: often 2-3x more tokens per word
```

Tokenizers: BPE (GPT), WordPiece (BERT), SentencePiece (LLaMA/Gemini)

#### Inference: How Generation Works

```
Input: "The capital of France is"

Step 1: Process all input tokens (prefill)
Step 2: Generate token "Paris" â†’ append to sequence
Step 3: Generate token "." â†’ append
Step 4: Generate token "<EOS>" â†’ stop

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

## â—† Comparison

| Aspect           | GPT-5.x             | Claude 4.x      | Gemini 3.x             | LLaMA 4                 |
| ---------------- | ------------------- | --------------- | ---------------------- | ----------------------- |
| **Best at**      | General reasoning   | Coding + agents | Long context + science | Open-weight flexibility |
| **Context**      | Large               | 200K            | Up to 2M               | 10M (Scout)             |
| **Access**       | API only            | API only        | API + Cloud            | Downloadable weights    |
| **Cost**         | $$$                 | $$              | $$                     | Free (compute costs)    |
| **Fine-tuning**  | Limited             | Limited         | Via Vertex AI          | Full control            |
| **Architecture** | Dense (rumored MoE) | Dense           | Dense variants         | MoE                     |

---

## â—† Use Cases & Applications

| Use Case                | How LLMs Are Used                     | Key Challenge            |
| ----------------------- | ------------------------------------- | ------------------------ |
| **Chat assistants**     | Direct conversation (ChatGPT, Claude) | Hallucination            |
| **Code generation**     | Copilot, Cursor, Devin                | Correctness verification |
| **Search**              | Perplexity, Google AI Overviews       | Up-to-date knowledge     |
| **Document processing** | Summarization, extraction, Q&A        | Long document handling   |
| **Translation**         | Near-human quality across languages   | Nuance, cultural context |
| **Agents**              | Autonomous task execution with tools  | Reliability, safety      |

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Hallucination â‰  lying**: The model generates plausible continuations, not facts. It has no concept of truth.
- âš ï¸ **Context window â‰  memory**: LLMs don't remember across conversations unless you build memory systems
- âš ï¸ **Bigger â‰  always better**: A well-fine-tuned 7B model can beat a generic 70B model on specific tasks
- âš ï¸ **Tokens â‰  words**: Pricing and limits are in tokens (~4 chars each). Non-English = more tokens
- âš ï¸ **Benchmarks lie**: Models are increasingly trained on benchmark data. Real-world eval matters more

---

## â—‹ Interview Angles

- **Q**: Explain the training pipeline of a modern LLM.
- **A**: Pre-training (next-token prediction on internet text) â†’ SFT (supervised fine-tuning on instruction-response pairs) â†’ RLHF/DPO (learning from human preference comparisons) â†’ Safety alignment

- **Q**: What's the difference between dense and MoE architectures?
- **A**: Dense: every parameter processes every token (e.g., GPT-4, Claude). MoE: tokens are routed to a subset of "expert" sub-networks (e.g., LLaMA 4 Maverick). MoE gives more total capacity with less compute per token.

- **Q**: How do you choose between using an API (GPT/Claude) vs hosting an open model (LLaMA)?
- **A**: API: faster to start, best performance, no infra. Self-host: data stays private, no vendor lock-in, customizable. Cost crossover: at ~1M+ tokens/day, self-hosting often becomes cheaper.

---

## â˜… Connections

| Relationship | Topics                                                                                                                  |
| ------------ | ----------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Transformers](../foundations/transformers.md), [Attention Mechanism](../foundations/attention-mechanism.md)                                                 |
| Leads to     | [Rag](../techniques/rag.md), [Fine Tuning](../techniques/fine-tuning.md), [Ai Agents](../techniques/ai-agents.md), [Prompt Engineering](../techniques/prompt-engineering.md) |
| Compare with | Traditional NLP (rule-based), Smaller language models (BERT-era)                                                        |
| Cross-domain | Cognitive science (language understanding), Linguistics                                                                 |

---

## â˜… Sources

- OpenAI GPT-5 release blog and model cards (2025-2026)
- Anthropic Claude 4 model documentation (2025-2026)
- Google Gemini release notes (2025-2026)
- Meta LLaMA 4 announcement (April 2025)
- Hoffmann et al., "Training Compute-Optimal Large Language Models" (Chinchilla, 2022)
- Sebastian Raschka, "LLM Year in Review 2025"
