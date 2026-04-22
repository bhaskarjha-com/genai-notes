---
title: "LLM Landscape & Model Selection"
aliases: ["Model Comparison", "GPT vs Claude vs Gemini"]
tags: [llm-comparison, gpt-5, gemini-3, claude-4, llama-4, model-selection, open-vs-closed, genai]
type: reference
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["llms-overview.md", "reasoning-models.md", "../foundations/modern-architectures.md"]
source: "Web research â€” April 2026"
created: 2026-03-22
updated: 2026-04-15
---

# LLM Landscape & Model Selection (April 2026)

> âœ¨ **Bit**: In 2023, GPT-4 was the only frontier model. In March 2026, there are 6+ frontier providers, each with 5+ model variants. Choosing the right model is now a genuine engineering decision â€” not just "use GPT."

---

## â˜… TL;DR

- **What**: A comparison of current frontier LLMs and guidance for selecting the right model
- **Why**: Interviewers ask "which model would you choose for X?" and "open vs closed?" â€” you need specifics, not generalities
- **Key point**: There's no single best model. GPT-5.4 for general tasks, Claude Opus 4.6 for long code, Gemini 3.1 for multimodal, LLaMA 4 for self-hosting. Model selection is about TRADEOFFS.

---

## â˜… Overview

### Definition

This note is a time-sensitive snapshot of the frontier and near-frontier LLM market plus a framework for choosing models based on workload constraints.

### Scope

Covers major providers, open vs closed trade-offs, and practical selection heuristics. Verify the latest model lineup with vendor release notes before using this note for a current purchasing or architecture decision.

Last verified for the March 2026 market snapshot: 2026-04.

### Significance

- Model choice affects quality, latency, privacy posture, and cost more than most teams expect.
- Engineers are increasingly expected to explain why a given model fits a workload instead of defaulting to one provider.

---

## â˜… Deep Dive

### The Frontier Models (April 2026)

### OpenAI â€” GPT-5 Family

| Model                | Released     | Context   | Best For                                            |
| -------------------- | ------------ | --------- | --------------------------------------------------- |
| **GPT-5.4**          | Mar 5, 2026  | 1M tokens | General work: spreadsheets, presentations, tool use |
| **GPT-5.4 Thinking** | Mar 2026     | 1M        | Analytical tasks, shows reasoning steps             |
| **GPT-5.4 Pro**      | Mar 2026     | 1M        | Highest accuracy (slower, expensive)                |
| **GPT-5.4 mini**     | Mar 17, 2026 | 1M        | High-volume, cost-efficient, near GPT-5.4 quality   |
| **GPT-5.4 nano**     | Mar 17, 2026 | â€”         | Cheapest, fastest: classification, extraction       |
| **GPT-5.3 Instant**  | Mar 3, 2026  | â€”         | Rapid conversational responses                      |
| **GPT-5.3-Codex**    | Feb 5, 2026  | â€”         | Coding agent (Copilot default)                      |
| **GPT-5.4-Cyber**    | Apr 14, 2026 | 1M        | Defensive cybersecurity (limited access via TAC program) |

### Google â€” Gemini 3 Family

| Model                      | Released     | Context | Best For                                           |
| -------------------------- | ------------ | ------- | -------------------------------------------------- |
| **Gemini 3.1 Pro**         | Feb 19, 2026 | 1M+     | Advanced reasoning (3-tier thinking), multimodal   |
| **Gemini 3.1 Flash-Lite**  | Mar 3, 2026  | â€”       | Cost-efficient, high throughput, Pro-level quality |
| **Gemini 3.1 Deep Think**  | 2026         | â€”       | Complex technical problems (AI Ultra subscribers)  |
| **Gemini 3.1 Flash Image** | Feb 26, 2026 | â€”       | High-efficiency image generation                   |
| **Gemini 3.1 Flash Live** | Mar 26, 2026 | â€”       | Real-time audio-to-audio, powers Search Live       |

Available in: Gemini API, AI Studio, **Gemini CLI**, **Antigravity**, Vertex AI, NotebookLM

### Anthropic â€” Claude 4.x Family

| Model                 | Released     | Context   | Best For                                         |
| --------------------- | ------------ | --------- | ------------------------------------------------ |
| **Claude Opus 4.6**   | Feb 5, 2026  | 1M tokens | Most capable: code, analysis, long-doc reasoning |
| **Claude Sonnet 4.6** | Feb 17, 2026 | 1M tokens | Balanced: default for claude.ai, Claude Cowork   |
| **Claude Mythos** (Preview) | Apr 7, 2026 | â€”     | Gated research preview (~50 orgs, Project Glasswing, defensive cyber) |

### Meta â€” LLaMA 4 Family (Open-Source)

| Model                | Params                                     | Context    | Best For                                      |
| -------------------- | ------------------------------------------ | ---------- | --------------------------------------------- |
| **LLaMA 4 Scout**    | 17B active / 109B total (MoE, 16 experts)  | 10M tokens | Efficiency, single H100, huge context         |
| **LLaMA 4 Maverick** | 17B active / 400B total (MoE, 128 experts) | 1M tokens  | Performance, multimodal, open-weight flagship |
| **LLaMA 4 Behemoth** | 288B active / 2T total                     | â€”          | Teacher model (still training, not released)  |

Meta 2026 roadmap: **Mango** (generative video) + **Avocado** (reasoning LLM)

### Other Notable Models

| Model                | By         | Key Feature                                          |
| -------------------- | ---------- | ---------------------------------------------------- |
| **DeepSeek-V3 / R1** | DeepSeek   | Cost-efficient reasoning, GRPO training, open-source |
| **Gemma 4 (E2B/E4B)** | Google DeepMind | Ultra-efficient; audio input; April 2, 2026 |
| **Gemma 4 (26B MoE)** | Google DeepMind | Multimodal (vision+video+audio); hybrid attention; 256K context |
| **Gemma 4 (31B Dense)** | Google DeepMind | Dense flagship; thinking mode; 256K context; best open-weight reasoning |
| **Mistral Large 2**  | Mistral AI | European, strong multilingual, 128K context          |
| **Qwen 2.5**         | Alibaba    | Leading Chinese LLM, strong code + math              |
| **Grok-3**           | xAI        | Real-time X/Twitter data, humor-capable              |

---

### Gemma 4 Family (April 2, 2026) â€” Architecture Deep Dive

Gemma 4 represents a major architectural shift from Gemma 3. Key innovations:

| Variant | Params | Context | Modalities | Key Feature |
|---|---|---|---|---|
| **Gemma 4 E2B** | 2B | 64K | Text + Audio | Embedded; mobile/edge; audio understanding |
| **Gemma 4 E4B** | 4B | 64K | Text + Audio | Embedded; improved reasoning over E2B |
| **Gemma 4 26B** | 26B (MoE) | 256K | Text + Vision + Video + Audio | Hybrid attention (local+global); sharing KV cache across heads |
| **Gemma 4 31B** | 31B (Dense) | 256K | Text + Vision + Video + Audio | Thinking mode; best open-weight reasoning; 2026 benchmark leader |

**Architecture innovations**:
- **Hybrid Attention**: alternates local (sliding window) and global (full) attention layers for O(n) local + full context at key positions
- **Dual RoPE**: separate positional encodings for local vs global attention layers
- **PLE (Per-Layer Embeddings)**: distinct learned embeddings per decoder layer instead of tied across all layers
- **Shared KV Cache**: multiple attention heads share the same key-value cache; reduces KV memory by 3-4x vs standard MHA

**Available via**: Google AI Studio, Vertex AI, Ollama (ollama pull gemma4), Hugging Face

---


### By Capability (March 2026)

| Capability               | Best Model(s)                           | Runner-Up                 |
| ------------------------ | --------------------------------------- | ------------------------- |
| **General intelligence** | GPT-5.4, Claude Opus 4.6                | Gemini 3.1 Pro            |
| **Coding**               | GPT-5.3-Codex, Claude Opus 4.6          | Gemini 3.1 Pro            |
| **Reasoning / Math**     | GPT-5.4 Thinking, Gemini 3.1 Deep Think | DeepSeek-R1               |
| **Multimodal (vision)**  | Gemini 3.1 Pro (native)                 | GPT-5.4                   |
| **Long document**        | Claude Opus 4.6 (1M, reliable)          | LLaMA 4 Scout (10M)       |
| **Cost efficiency**      | GPT-5.4 mini/nano, Gemini Flash-Lite    | LLaMA 4 Scout (self-host) |
| **Open-source**          | LLaMA 4 Maverick                        | DeepSeek-V3, Qwen 2.5     |
| **Self-hosting**         | LLaMA 4 Scout (1 GPU!), Qwen            | Mistral                   |

### Open vs Closed Models

```
CLOSED SOURCE (API-only):           OPEN SOURCE / WEIGHTS:
  GPT-5.4, Claude 4.6, Gemini 3.1   LLaMA 4, DeepSeek, Qwen, Mistral

  âœ… Highest capability              âœ… Full control over deployment
  âœ… Managed, zero-ops               âœ… No vendor lock-in
  âœ… Continuously updated            âœ… Fine-tunable (LoRA, full)
  âœ… Safety/alignment built in       âœ… Data stays on your infra
  âŒ Data leaves your infra          âŒ You manage inference infra
  âŒ Vendor lock-in                  âŒ 6-12 months behind frontier
  âŒ Costs scale linearly            âŒ Safety is YOUR responsibility
  âŒ Can't fine-tune deeply          âŒ Less multimodal capability
```

---

## â—† Model Selection Decision Tree

```
START: What's your use case?
  â”‚
  â”œâ”€â”€ Simple classification, extraction, routing
  â”‚   â†’ GPT-5.4 nano or mini (cheapest, fastest)
  â”‚
  â”œâ”€â”€ General chat / customer support
  â”‚   â†’ Claude Sonnet 4.6 or GPT-5.4 (balanced)
  â”‚
  â”œâ”€â”€ Complex coding / large codebase
  â”‚   â†’ Claude Opus 4.6 (best reasoning for code)
  â”‚   â†’ GPT-5.3-Codex (if using Copilot)
  â”‚
  â”œâ”€â”€ Math / science / reasoning
  â”‚   â†’ GPT-5.4 Thinking or Gemini 3.1 Deep Think
  â”‚
  â”œâ”€â”€ Multimodal (images, video, audio input)
  â”‚   â†’ Gemini 3.1 Pro (native multimodal, best)
  â”‚
  â”œâ”€â”€ Data must stay on-premise / regulated industry
  â”‚   â†’ LLaMA 4 Scout/Maverick (self-host)
  â”‚   â†’ Qwen 2.5 (if Asian market)
  â”‚
  â”œâ”€â”€ High volume / cost-sensitive
  â”‚   â†’ GPT-5.4 nano < mini < Gemini Flash-Lite
  â”‚   â†’ Self-host LLaMA 4 Scout (1 GPU, 10M context!)
  â”‚
  â””â”€â”€ Research / experimental
      â†’ DeepSeek (cost-efficient frontier)
      â†’ Multiple models (benchmark on YOUR data)
```

---

## â—‹ Interview Angles

- **Q**: Which LLM would you choose for a production RAG system?
- **A**: Depends on constraints. For highest quality: Claude Opus 4.6 (1M context, best at following complex instructions with citations). For cost efficiency: GPT-5.4 mini (near GPT-5.4 quality at fraction of cost). For data privacy: LLaMA 4 Scout self-hosted (10M context, fits on 1 H100). For multimodal RAG: Gemini 3.1 Pro (native vision for image documents). In practice, use a cheaper model for retrieval/routing and a powerful model for generation.

- **Q**: Open source vs closed source â€” when?
- **A**: Closed (GPT-5.4, Claude) when: you need cutting-edge capability, have budget, want zero-ops, and your data policies allow API calls. Open (LLaMA 4, Gemma 4, DeepSeek) when: data must stay on-premise (healthcare, finance, government), you need fine-tuning beyond what APIs allow, or cost at scale is prohibitive. Trend in 2026: Gemma 4 31B and LLaMA 4 Scout are competitive with mid-tier closed models while being fully self-hostable.

---

## â˜… Code & Implementation

### Multi-Provider LLM API Comparison

```python
# pip install openai>=1.60 anthropic>=0.40 google-generativeai>=0.8
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, anthropic>=0.40, google-generativeai>=0.8
# Set: OPENAI_API_KEY, ANTHROPIC_API_KEY, GOOGLE_API_KEY env vars

import os
from openai import OpenAI
import anthropic
import google.generativeai as genai

prompt = "Explain the transformer attention mechanism in 3 sentences."

# OpenAI
oai_client = OpenAI()
oai = oai_client.chat.completions.create(
    model="gpt-4o-mini",  # Replace with gpt-5.4 for frontier
    messages=[{"role": "user", "content": prompt}],
    max_tokens=200,
)
print("OpenAI:", oai.choices[0].message.content[:100])

# Anthropic
ant_client = anthropic.Anthropic()
ant = ant_client.messages.create(
    model="claude-3-5-haiku-20241022",  # Replace with claude-sonnet-4-6 for frontier
    max_tokens=200,
    messages=[{"role": "user", "content": prompt}],
)
print("Anthropic:", ant.content[0].text[:100])

# Google Gemini
genai.configure(api_key=os.environ["GOOGLE_API_KEY"])
gem = genai.GenerativeModel("gemini-2.0-flash")  # Replace with gemini-3.1-pro for frontier
res = gem.generate_content(prompt)
print("Gemini:", res.text[:100])

# Self-hosted Gemma 4 via Ollama (free, no API key):
# ollama pull gemma4  (downloads ~20GB for the 26B MoE variant)
# curl http://localhost:11434/api/generate -d '{"model": "gemma4", "prompt": "..."}'
```

---

## â˜… Connections

| Relationship | Topics |
| ------------ | ------ |
| Builds on    | [Llms Overview](./llms-overview.md), [Reasoning Models & Test-Time Compute](./reasoning-models.md) |
| Leads to     | [Inference Optimization](../inference/inference-optimization.md), [Cost Optimization for GenAI Systems](../production/cost-optimization.md), model-routing decisions |
| Compare with | open-weight deployment choices, provider API strategy |
| Cross-domain | procurement, architecture, platform strategy |


---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Model selection bias** | Team always picks the largest/newest model | No structured evaluation against requirements | Decision matrix: cost, latency, quality, compliance constraints |
| **API deprecation** | Production breaks when provider sunsets model version | No model version pinning or migration plan | Pin versions, monitor deprecation notices, abstract provider |
| **Benchmark â‰  production** | Top benchmark model underperforms on your task | Benchmarks don't represent your distribution | Custom eval on your data before committing |

---

## â—† Hands-On Exercises

### Exercise 1: Build a Model Selection Matrix

**Goal**: Evaluate 3 models for a specific production use case
**Time**: 30 minutes
**Steps**:
1. Define 5 evaluation criteria (quality, latency, cost, context length, safety)
2. Run 20 representative queries through GPT-4o, Claude Sonnet, and Gemini Flash
3. Score each model on each criterion (1-5)
4. Calculate weighted scores and recommend
**Expected Output**: Decision matrix with recommendation and rationale
---


## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ”§ Hands-on | [LMSYS Chatbot Arena](https://chat.lmsys.org/) | Live human-evaluated model rankings |
| ðŸ”§ Hands-on | [Artificial Analysis](https://artificialanalysis.ai/) | Speed, price, and quality comparisons across LLM providers |
| ðŸ“˜ Book | "AI Engineering" by Chip Huyen (2025), Ch 2 | Model selection framework for practitioners |

## â˜… Sources

- OpenAI model releases â€” https://openai.com/index
- Google DeepMind Gemini â€” https://deepmind.google/technologies/gemini/
- Anthropic Claude â€” https://anthropic.com
- Meta LLaMA 4 announcement (April 2025)
- Chatbot Arena / LMSYS leaderboard â€” https://chat.lmsys.org
