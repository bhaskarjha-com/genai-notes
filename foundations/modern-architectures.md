---
title: "Modern LLM Architectures"
tags: [moe, mixture-of-experts, gqa, rope, flash-attention, architecture, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[transformers]]", "[[attention-mechanism]]", "[[../llms/llms-overview]]", "[[../inference/inference-optimization]]"]
source: "Multiple papers — see Sources"
created: 2026-03-22
updated: 2026-03-22
---

# Modern LLM Architectures

> ✨ **Bit**: The original Transformer (2017) is like a Model T Ford. Every modern LLM has upgraded every component — MoE for efficiency, GQA for memory, RoPE for position, Flash Attention for speed. Same soul, completely different car.

---

## ★ TL;DR

- **What**: The architectural innovations that make modern LLMs (GPT-5, LLaMA 4, Gemini 3) work — beyond the basic Transformer
- **Why**: Interviewers ask "what's MoE?" and "how does RoPE work?" These are the building blocks of every frontier model.
- **Key point**: Modern LLMs aren't just bigger Transformers. They use MoE (activate only part of the model), GQA (save memory), RoPE (handle long sequences), and Flash Attention (go faster).

---

## ★ Overview

### Definition

This document covers the key architectural components added to the basic Transformer to create modern LLMs. For the base Transformer architecture, see [[transformers]]. For the attention mechanism, see [[attention-mechanism]].

### Scope

Covers: MoE, GQA, RoPE, Flash Attention, normalization choices, and how they combine. Not a full paper review — focused on intuition and practical understanding.

### Prerequisites

- [[transformers]] — encoder/decoder, self-attention
- [[attention-mechanism]] — Q, K, V matrices
- [[../prerequisites/linear-algebra-for-ai]] — matrix operations

---

## ★ Deep Dive

### What Changed from the Original Transformer

| Component               | Original (2017)           | Modern (2025)                   | Why                          |
| ----------------------- | ------------------------- | ------------------------------- | ---------------------------- |
| **Experts**             | Dense (all params active) | **MoE** (sparse, subset active) | More capacity, less compute  |
| **Attention heads**     | Multi-Head (MHA)          | **GQA** (grouped-query)         | Less memory for KV cache     |
| **Position encoding**   | Sinusoidal (absolute)     | **RoPE** (rotary)               | Better at long sequences     |
| **Attention algorithm** | Standard O(n²)            | **Flash Attention**             | 2-4x faster, less memory     |
| **Normalization**       | Post-LayerNorm            | **Pre-RMSNorm**                 | Stable training              |
| **Activation**          | ReLU                      | **SiLU/SwiGLU**                 | Smoother, better performance |

### 1. Mixture of Experts (MoE)

```
DENSE MODEL (traditional):
  Every token goes through ALL parameters.
  LLaMA 70B: 70B params active per token → expensive!

MoE MODEL:
  Each layer has N "expert" sub-networks.
  A ROUTER decides which experts handle each token.
  Only 2-4 experts active per token (out of 16+).

  ┌─────────────────────────────────────────────────┐
  │              MoE LAYER                           │
  │                                                 │
  │  Input token                                    │
  │      │                                          │
  │      ▼                                          │
  │  ┌────────┐                                     │
  │  │ ROUTER │  ← "Which experts should handle    │
  │  │(Gating)│     this token?"                    │
  │  └───┬────┘                                     │
  │      │  top-k selection (usually k=2)           │
  │      ▼                                          │
  │  ┌──────┐ ┌──────┐ ┌──────┐ ... ┌──────┐       │
  │  │ E1 ✓ │ │ E2   │ │ E3 ✓ │     │ E16  │       │
  │  │active │ │sleep │ │active│     │sleep │       │
  │  └──┬───┘ └──────┘ └──┬───┘     └──────┘       │
  │     │                  │                        │
  │     ▼                  ▼                        │
  │  weighted combination of active expert outputs  │
  │      │                                          │
  │      ▼                                          │
  │  Output token                                   │
  └─────────────────────────────────────────────────┘

RESULT:
  Total params: 600B (huge capacity)
  Active params per token: 37B (cheap to run!)
  Best of both worlds: capacity of 600B, cost of ~37B
```

| Model                 | Total Params | Active Params | Experts | Top-K   |
| --------------------- | ------------ | ------------- | ------- | ------- |
| **Mixtral 8x7B**      | 47B          | 13B           | 8       | 2       |
| **LLaMA 4 Scout**     | 109B         | 17B           | 16      | 1       |
| **LLaMA 4 Maverick**  | 400B         | 17B           | 128     | 1       |
| **DeepSeek-V3**       | 671B         | 37B           | 256     | 8       |
| **GPT-5** (estimated) | ~1T+         | ~200-300B     | MoE     | Unknown |

### 2. Grouped-Query Attention (GQA)

```
THE KV CACHE PROBLEM:
  In attention: Q, K, V matrices.
  During generation, K and V are CACHED for all past tokens.
  
  Multi-Head Attention (MHA):
    Each head has its own K and V matrices.
    32 heads × 128 dim × 4096 seq × 2 (K+V) = HUGE memory!

SOLUTIONS (progressive):

  MHA (Multi-Head Attention) — Original
  ┌───────────────────────────────────────┐
  │  Q1 K1 V1  │  Q2 K2 V2  │ ... │ Q32 K32 V32
  │  Each head has its own Q, K, V
  │  KV cache: 32 × 2 = 64 matrices
  └───────────────────────────────────────┘

  MQA (Multi-Query Attention) — Extreme
  ┌───────────────────────────────────────┐
  │  Q1  Q2  Q3 ... Q32   │  K  V
  │  All heads SHARE one K and one V
  │  KV cache: 1 × 2 = 2 matrices (32x less!)
  │  Problem: Quality drops
  └───────────────────────────────────────┘

  GQA (Grouped-Query Attention) — Sweet spot ✅
  ┌───────────────────────────────────────┐
  │  Group 1: Q1 Q2 Q3 Q4 → K₁ V₁       │
  │  Group 2: Q5 Q6 Q7 Q8 → K₂ V₂       │
  │  ...                                  │
  │  Group 8: Q29..Q32    → K₈ V₈        │
  │  KV cache: 8 × 2 = 16 matrices       │
  │  4x less memory, near-MHA quality!    │
  └───────────────────────────────────────┘
```

**Used in**: LLaMA 2/3/4, Gemini, Mistral — virtually every modern LLM.

### 3. RoPE (Rotary Position Embeddings)

```
THE POSITION PROBLEM:
  Transformers process all tokens in parallel (no sequential order).
  They need explicit position information: "this is token #5."

ORIGINAL: Sinusoidal (Absolute)
  Add a fixed vector per position: pos_1, pos_2, ..., pos_512
  ❌ Can't handle sequences longer than training length
  ❌ Doesn't capture relative distance well

RoPE: Rotary Position Embeddings
  Instead of ADDING position info, ROTATE the Q and K vectors
  by an angle proportional to their position.
  
  Key insight: After rotation, the DOT PRODUCT of Q·K
  naturally depends on RELATIVE position (distance between tokens).
  
  Token at position 5:  rotate Q by 5θ
  Token at position 10: rotate Q by 10θ
  Dot product captures: they're 5 positions apart

  ✅ Naturally handles relative positions
  ✅ Can be extended to longer sequences (NTK-aware scaling, YaRN)
  ✅ Computationally cheap (just rotation in pairs)
```

**Used in**: LLaMA 1/2/3/4, Mistral, Qwen, PaLM — standard in virtually all modern LLMs.

### 4. Flash Attention

```
THE SPEED PROBLEM:
  Standard attention: O(N²) in both time and memory.
  4096 tokens → 16 million attention scores → slow + memory-heavy

FLASH ATTENTION SOLUTION:
  Don't compute the full NxN attention matrix at once.
  Instead, compute it in TILES (blocks) that fit in GPU SRAM.

  GPU Memory Hierarchy:
  ┌────────────────────────────────────────┐
  │  SRAM (on-chip cache)  │  20 MB       │ ← FAST (10 TB/s)
  │  HBM (GPU RAM)         │  40-80 GB    │ ← SLOW (2 TB/s)
  └────────────────────────────────────────┘

  Standard attention: load full matrices from HBM → compute → store
  Flash attention:    compute in SRAM-sized tiles → never materialize
                      full attention matrix in HBM

  Result:
    2-4x faster
    Linear memory instead of quadratic
    Exact same output (not approximate!)
```

**Versions**: FlashAttention-1 (2022) → FlashAttention-2 (2023) → FlashAttention-3 (2024, Hopper GPUs)

### 5. Normalization & Activation

```
PRE-RMSNORM (replaces Post-LayerNorm):
  Original Transformer: Attention → Add → LayerNorm → FFN → Add → LayerNorm
  Modern LLM:           RMSNorm → Attention → Add → RMSNorm → FFN → Add
  
  RMSNorm = Root Mean Square Normalization
  Simpler than LayerNorm (no mean subtraction), faster, works better.

SwiGLU ACTIVATION (replaces ReLU):
  SwiGLU(x) = (x · W₁) ⊙ SiLU(x · V)
  
  Three matrices instead of two (W₁, W₂, V)
  Better performance empirically, standard in LLaMA/Mistral/GPT.
```

---

## ◆ How They Combine (LLaMA 3 Architecture)

```
LLaMA 3 70B — A complete modern LLM:

  Input → Tokenizer (BPE, 128K vocab)
       → Embedding lookup
       → [80 Transformer layers, each:]
           ├── Pre-RMSNorm
           ├── GQA Self-Attention (8 KV heads, 64 query heads)
           │   └── RoPE positional encoding
           │   └── Flash Attention computation
           ├── Residual connection
           ├── Pre-RMSNorm
           ├── SwiGLU Feed-Forward Network
           └── Residual connection
       → Final RMSNorm
       → Output head → Softmax → Next token probability

  Total: 70B parameters, 8K-128K context
```

---

## ◆ Quick Reference

```
COMPONENT CHEAT SHEET:
  MoE      → More capacity, less compute (sparse activation)
  GQA      → Less KV cache memory (grouped key-value sharing)
  RoPE     → Better position encoding (rotation-based, extensible)
  Flash    → Faster attention (tiled SRAM computation)
  RMSNorm  → Simpler, faster normalization
  SwiGLU   → Better activation function

WHICH MODELS USE WHAT:
  LLaMA 3:    GQA + RoPE + Flash + RMSNorm + SwiGLU
  LLaMA 4:    MoE + GQA + RoPE + Flash + RMSNorm + SwiGLU
  Mistral:    GQA + RoPE + Flash + RMSNorm + SwiGLU + Sliding Window
  Mixtral:    MoE + GQA + RoPE + Flash + RMSNorm + SwiGLU
  DeepSeek:   MoE + MLA + RoPE + Flash + RMSNorm
  GPT-5:      MoE + proprietary attention + proprietary position
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **MoE doesn't reduce model size**: Total params are HUGE. MoE reduces ACTIVE params per token. You still need to fit ALL experts in memory.
- ⚠️ **Flash Attention is exact**: It's not an approximation. Same result as standard attention, just computed more efficiently.
- ⚠️ **RoPE extension ≠ free**: Extending context with RoPE scaling works but quality degrades beyond training length without fine-tuning.
- ⚠️ **GQA grouping affects quality**: Too few groups = quality drop. 8 groups for 64 heads is the typical sweet spot.

---

## ○ Interview Angles

- **Q**: What is Mixture of Experts and why does LLaMA 4 use it?
- **A**: MoE has multiple "expert" FFN sub-networks per layer with a learned router. For each token, only top-K experts (e.g., 2 of 16) are activated. This gives the model capacity of the total parameters but computational cost of only the active experts. LLaMA 4 uses it to achieve 400B total params with only 17B active — massive capacity at manageable cost.

- **Q**: What is GQA and how does it save memory?
- **A**: Grouped-Query Attention shares K and V heads across groups of Q heads. With 64 Q heads and 8 KV heads, the KV cache is 8x smaller than full MHA. This is critical for serving long-context models — KV cache can otherwise consume more memory than the model weights.

---

## ★ Connections

| Relationship | Topics                                                                                |
| ------------ | ------------------------------------------------------------------------------------- |
| Builds on    | [[transformers]], [[attention-mechanism]], [[../prerequisites/linear-algebra-for-ai]] |
| Leads to     | [[../llms/llms-overview]], [[../inference/inference-optimization]]                    |
| Compare with | Original Transformer (2017), RNNs (sequential)                                        |
| Cross-domain | Computer architecture (memory hierarchy), Sparse computation                          |

---

## ★ Sources

- Shazeer et al., "Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer" (2017)
- Ainslie et al., "GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints" (2023)
- Su et al., "RoFormer: Enhanced Transformer with Rotary Position Embedding" (2021)
- Dao, "FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness" (2022)
- Meta, "LLaMA 3 / LLaMA 4 Technical Reports" (2024-2025)
- Shazeer, "GLU Variants Improve Transformer" (SwiGLU, 2020)
