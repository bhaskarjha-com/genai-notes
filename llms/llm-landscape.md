---
title: "LLM Landscape & Model Selection"
tags: [llm-comparison, gpt-5, gemini-3, claude-4, llama-4, model-selection, open-vs-closed, genai]
type: reference
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[llms-overview]]", "[[reasoning-models]]", "[[../foundations/modern-architectures]]"]
source: "Web research — March 2026"
created: 2026-03-22
updated: 2026-04-12
---

# LLM Landscape & Model Selection (March 2026)

> ✨ **Bit**: In 2023, GPT-4 was the only frontier model. In March 2026, there are 6+ frontier providers, each with 5+ model variants. Choosing the right model is now a genuine engineering decision — not just "use GPT."

---

## ★ TL;DR

- **What**: A comparison of current frontier LLMs and guidance for selecting the right model
- **Why**: Interviewers ask "which model would you choose for X?" and "open vs closed?" — you need specifics, not generalities
- **Key point**: There's no single best model. GPT-5.4 for general tasks, Claude Opus 4.6 for long code, Gemini 3.1 for multimodal, LLaMA 4 for self-hosting. Model selection is about TRADEOFFS.

---

## ★ Overview

### Definition

This note is a time-sensitive snapshot of the frontier and near-frontier LLM market plus a framework for choosing models based on workload constraints.

### Scope

Covers major providers, open vs closed trade-offs, and practical selection heuristics. Verify the latest model lineup with vendor release notes before using this note for a current purchasing or architecture decision.

Last verified for the March 2026 market snapshot: 2026-04.

### Significance

- Model choice affects quality, latency, privacy posture, and cost more than most teams expect.
- Engineers are increasingly expected to explain why a given model fits a workload instead of defaulting to one provider.

---

## ★ Deep Dive

### The Frontier Models (March 2026)

### OpenAI — GPT-5 Family

| Model                | Released     | Context   | Best For                                            |
| -------------------- | ------------ | --------- | --------------------------------------------------- |
| **GPT-5.4**          | Mar 5, 2026  | 1M tokens | General work: spreadsheets, presentations, tool use |
| **GPT-5.4 Thinking** | Mar 2026     | 1M        | Analytical tasks, shows reasoning steps             |
| **GPT-5.4 Pro**      | Mar 2026     | 1M        | Highest accuracy (slower, expensive)                |
| **GPT-5.4 mini**     | Mar 17, 2026 | 1M        | High-volume, cost-efficient, near GPT-5.4 quality   |
| **GPT-5.4 nano**     | Mar 17, 2026 | —         | Cheapest, fastest: classification, extraction       |
| **GPT-5.3 Instant**  | Mar 3, 2026  | —         | Rapid conversational responses                      |
| **GPT-5.3-Codex**    | Feb 5, 2026  | —         | Coding agent (Copilot default)                      |

### Google — Gemini 3 Family

| Model                      | Released     | Context | Best For                                           |
| -------------------------- | ------------ | ------- | -------------------------------------------------- |
| **Gemini 3.1 Pro**         | Feb 19, 2026 | 1M+     | Advanced reasoning (3-tier thinking), multimodal   |
| **Gemini 3.1 Flash-Lite**  | Mar 3, 2026  | —       | Cost-efficient, high throughput, Pro-level quality |
| **Gemini 3.1 Deep Think**  | 2026         | —       | Complex technical problems (AI Ultra subscribers)  |
| **Gemini 3.1 Flash Image** | Feb 26, 2026 | —       | High-efficiency image generation                   |

Available in: Gemini API, AI Studio, **Gemini CLI**, **Antigravity**, Vertex AI, NotebookLM

### Anthropic — Claude 4.x Family

| Model                 | Released     | Context   | Best For                                         |
| --------------------- | ------------ | --------- | ------------------------------------------------ |
| **Claude Opus 4.6**   | Feb 5, 2026  | 1M tokens | Most capable: code, analysis, long-doc reasoning |
| **Claude Sonnet 4.6** | Feb 17, 2026 | 1M tokens | Balanced: default for claude.ai, Claude Cowork   |

### Meta — LLaMA 4 Family (Open-Source)

| Model                | Params                                     | Context    | Best For                                      |
| -------------------- | ------------------------------------------ | ---------- | --------------------------------------------- |
| **LLaMA 4 Scout**    | 17B active / 109B total (MoE, 16 experts)  | 10M tokens | Efficiency, single H100, huge context         |
| **LLaMA 4 Maverick** | 17B active / 400B total (MoE, 128 experts) | 1M tokens  | Performance, multimodal, open-weight flagship |
| **LLaMA 4 Behemoth** | 288B active / 2T total                     | —          | Teacher model (still training, not released)  |

Meta 2026 roadmap: **Mango** (generative video) + **Avocado** (reasoning LLM)

### Other Notable Models

| Model                | By         | Key Feature                                          |
| -------------------- | ---------- | ---------------------------------------------------- |
| **DeepSeek-V3 / R1** | DeepSeek   | Cost-efficient reasoning, GRPO training, open-source |
| **Mistral Large 2**  | Mistral AI | European, strong multilingual, 128K context          |
| **Qwen 2.5**         | Alibaba    | Leading Chinese LLM, strong code + math              |
| **Grok-3**           | xAI        | Real-time X/Twitter data, humor-capable              |

---

## ★ The Comparison

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

  ✅ Highest capability              ✅ Full control over deployment
  ✅ Managed, zero-ops               ✅ No vendor lock-in
  ✅ Continuously updated            ✅ Fine-tunable (LoRA, full)
  ✅ Safety/alignment built in       ✅ Data stays on your infra
  ❌ Data leaves your infra          ❌ You manage inference infra
  ❌ Vendor lock-in                  ❌ 6-12 months behind frontier
  ❌ Costs scale linearly            ❌ Safety is YOUR responsibility
  ❌ Can't fine-tune deeply          ❌ Less multimodal capability
```

---

## ◆ Model Selection Decision Tree

```
START: What's your use case?
  │
  ├── Simple classification, extraction, routing
  │   → GPT-5.4 nano or mini (cheapest, fastest)
  │
  ├── General chat / customer support
  │   → Claude Sonnet 4.6 or GPT-5.4 (balanced)
  │
  ├── Complex coding / large codebase
  │   → Claude Opus 4.6 (best reasoning for code)
  │   → GPT-5.3-Codex (if using Copilot)
  │
  ├── Math / science / reasoning
  │   → GPT-5.4 Thinking or Gemini 3.1 Deep Think
  │
  ├── Multimodal (images, video, audio input)
  │   → Gemini 3.1 Pro (native multimodal, best)
  │
  ├── Data must stay on-premise / regulated industry
  │   → LLaMA 4 Scout/Maverick (self-host)
  │   → Qwen 2.5 (if Asian market)
  │
  ├── High volume / cost-sensitive
  │   → GPT-5.4 nano < mini < Gemini Flash-Lite
  │   → Self-host LLaMA 4 Scout (1 GPU, 10M context!)
  │
  └── Research / experimental
      → DeepSeek (cost-efficient frontier)
      → Multiple models (benchmark on YOUR data)
```

---

## ○ Interview Angles

- **Q**: Which LLM would you choose for a production RAG system?
- **A**: Depends on constraints. For highest quality: Claude Opus 4.6 (1M context, best at following complex instructions with citations). For cost efficiency: GPT-5.4 mini (near GPT-5.4 quality at fraction of cost). For data privacy: LLaMA 4 Scout self-hosted (10M context, fits on 1 H100). For multimodal RAG: Gemini 3.1 Pro (native vision for image documents). In practice, use a cheaper model for retrieval/routing and a powerful model for generation.

- **Q**: Open source vs closed source — when?
- **A**: Closed (GPT-5.4, Claude) when: you need cutting-edge capability, have budget, want zero-ops, and your data policies allow API calls. Open (LLaMA 4, DeepSeek) when: data must stay on-premise (healthcare, finance, government), you need fine-tuning beyond what APIs allow, or cost at scale is prohibitive. Trend in 2026: open models are 6-12 months behind closed but closing the gap fast.

---

## ★ Connections

| Relationship | Topics |
| ------------ | ------ |
| Builds on    | [Llms Overview](./llms-overview.md), [Reasoning Models & Test-Time Compute](./reasoning-models.md) |
| Leads to     | [Inference Optimization](../inference/inference-optimization.md), [Cost Optimization for GenAI Systems](../production/cost-optimization.md), model-routing decisions |
| Compare with | open-weight deployment choices, provider API strategy |
| Cross-domain | procurement, architecture, platform strategy |

---

## ★ Sources

- OpenAI model releases — https://openai.com/index
- Google DeepMind Gemini — https://deepmind.google/technologies/gemini/
- Anthropic Claude — https://anthropic.com
- Meta LLaMA 4 announcement (April 2025)
- Chatbot Arena / LMSYS leaderboard — https://chat.lmsys.org
