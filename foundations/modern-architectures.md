---
title: "Modern LLM Architectures"
aliases: ["MoE", "Mixture of Experts", "Model Architectures"]
tags: [moe, mixture-of-experts, gqa, rope, flash-attention, architecture, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["transformers.md", "attention-mechanism.md", "../llms/llms-overview.md", "../inference/inference-optimization.md"]
source: "Multiple papers â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Modern LLM Architectures

> âœ¨ **Bit**: The original Transformer (2017) is like a Model T Ford. Every modern LLM has upgraded every component â€” MoE for efficiency, GQA for memory, RoPE for position, Flash Attention for speed. Same soul, completely different car.

---

## â˜… TL;DR

- **What**: The architectural innovations that make modern LLMs (GPT-5, LLaMA 4, Gemini 3) work â€” beyond the basic Transformer
- **Why**: Interviewers ask "what's MoE?" and "how does RoPE work?" These are the building blocks of every frontier model.
- **Key point**: Modern LLMs aren't just bigger Transformers. They use MoE (activate only part of the model), GQA (save memory), RoPE (handle long sequences), and Flash Attention (go faster).

---

## â˜… Overview

### Definition

This document covers the key architectural components added to the basic Transformer to create modern LLMs. For the base Transformer architecture, see [Transformers](./transformers.md). For the attention mechanism, see [Attention Mechanism](./attention-mechanism.md).

### Scope

Covers: MoE, GQA, RoPE, Flash Attention, normalization choices, and how they combine. Not a full paper review â€” focused on intuition and practical understanding.

### Prerequisites

- [Transformers](./transformers.md) â€” encoder/decoder, self-attention
- [Attention Mechanism](./attention-mechanism.md) â€” Q, K, V matrices
- [Linear Algebra For Ai](../prerequisites/linear-algebra-for-ai.md) â€” matrix operations

---

## â˜… Deep Dive

### What Changed from the Original Transformer

| Component               | Original (2017)           | Modern (2025)                   | Why                          |
| ----------------------- | ------------------------- | ------------------------------- | ---------------------------- |
| **Experts**             | Dense (all params active) | **MoE** (sparse, subset active) | More capacity, less compute  |
| **Attention heads**     | Multi-Head (MHA)          | **GQA** (grouped-query)         | Less memory for KV cache     |
| **Position encoding**   | Sinusoidal (absolute)     | **RoPE** (rotary)               | Better at long sequences     |
| **Attention algorithm** | Standard O(nÂ²)            | **Flash Attention**             | 2-4x faster, less memory     |
| **Normalization**       | Post-LayerNorm            | **Pre-RMSNorm**                 | Stable training              |
| **Activation**          | ReLU                      | **SiLU/SwiGLU**                 | Smoother, better performance |

### 1. Mixture of Experts (MoE)

```
DENSE MODEL (traditional):
  Every token goes through ALL parameters.
  LLaMA 70B: 70B params active per token â†’ expensive!

MoE MODEL:
  Each layer has N "expert" sub-networks.
  A ROUTER decides which experts handle each token.
  Only 2-4 experts active per token (out of 16+).

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚              MoE LAYER                           â”‚
  â”‚                                                 â”‚
  â”‚  Input token                                    â”‚
  â”‚      â”‚                                          â”‚
  â”‚      â–¼                                          â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”                                     â”‚
  â”‚  â”‚ ROUTER â”‚  â† "Which experts should handle    â”‚
  â”‚  â”‚(Gating)â”‚     this token?"                    â”‚
  â”‚  â””â”€â”€â”€â”¬â”€â”€â”€â”€â”˜                                     â”‚
  â”‚      â”‚  top-k selection (usually k=2)           â”‚
  â”‚      â–¼                                          â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â” ... â”Œâ”€â”€â”€â”€â”€â”€â”       â”‚
  â”‚  â”‚ E1 âœ“ â”‚ â”‚ E2   â”‚ â”‚ E3 âœ“ â”‚     â”‚ E16  â”‚       â”‚
  â”‚  â”‚active â”‚ â”‚sleep â”‚ â”‚activeâ”‚     â”‚sleep â”‚       â”‚
  â”‚  â””â”€â”€â”¬â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”¬â”€â”€â”€â”˜     â””â”€â”€â”€â”€â”€â”€â”˜       â”‚
  â”‚     â”‚                  â”‚                        â”‚
  â”‚     â–¼                  â–¼                        â”‚
  â”‚  weighted combination of active expert outputs  â”‚
  â”‚      â”‚                                          â”‚
  â”‚      â–¼                                          â”‚
  â”‚  Output token                                   â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

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
    32 heads Ã— 128 dim Ã— 4096 seq Ã— 2 (K+V) = HUGE memory!

SOLUTIONS (progressive):

  MHA (Multi-Head Attention) â€” Original
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  Q1 K1 V1  â”‚  Q2 K2 V2  â”‚ ... â”‚ Q32 K32 V32
  â”‚  Each head has its own Q, K, V
  â”‚  KV cache: 32 Ã— 2 = 64 matrices
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

  MQA (Multi-Query Attention) â€” Extreme
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  Q1  Q2  Q3 ... Q32   â”‚  K  V
  â”‚  All heads SHARE one K and one V
  â”‚  KV cache: 1 Ã— 2 = 2 matrices (32x less!)
  â”‚  Problem: Quality drops
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

  GQA (Grouped-Query Attention) â€” Sweet spot âœ…
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  Group 1: Q1 Q2 Q3 Q4 â†’ Kâ‚ Vâ‚       â”‚
  â”‚  Group 2: Q5 Q6 Q7 Q8 â†’ Kâ‚‚ Vâ‚‚       â”‚
  â”‚  ...                                  â”‚
  â”‚  Group 8: Q29..Q32    â†’ Kâ‚ˆ Vâ‚ˆ        â”‚
  â”‚  KV cache: 8 Ã— 2 = 16 matrices       â”‚
  â”‚  4x less memory, near-MHA quality!    â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Used in**: LLaMA 2/3/4, Gemini, Mistral â€” virtually every modern LLM.

### 3. RoPE (Rotary Position Embeddings)

```
THE POSITION PROBLEM:
  Transformers process all tokens in parallel (no sequential order).
  They need explicit position information: "this is token #5."

ORIGINAL: Sinusoidal (Absolute)
  Add a fixed vector per position: pos_1, pos_2, ..., pos_512
  âŒ Can't handle sequences longer than training length
  âŒ Doesn't capture relative distance well

RoPE: Rotary Position Embeddings
  Instead of ADDING position info, ROTATE the Q and K vectors
  by an angle proportional to their position.

  Key insight: After rotation, the DOT PRODUCT of QÂ·K
  naturally depends on RELATIVE position (distance between tokens).

  Token at position 5:  rotate Q by 5Î¸
  Token at position 10: rotate Q by 10Î¸
  Dot product captures: they're 5 positions apart

  âœ… Naturally handles relative positions
  âœ… Can be extended to longer sequences (NTK-aware scaling, YaRN)
  âœ… Computationally cheap (just rotation in pairs)
```

**Used in**: LLaMA 1/2/3/4, Mistral, Qwen, PaLM â€” standard in virtually all modern LLMs.

### 4. Flash Attention

```
THE SPEED PROBLEM:
  Standard attention: O(NÂ²) in both time and memory.
  4096 tokens â†’ 16 million attention scores â†’ slow + memory-heavy

FLASH ATTENTION SOLUTION:
  Don't compute the full NxN attention matrix at once.
  Instead, compute it in TILES (blocks) that fit in GPU SRAM.

  GPU Memory Hierarchy:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  SRAM (on-chip cache)  â”‚  20 MB       â”‚ â† FAST (10 TB/s)
  â”‚  HBM (GPU RAM)         â”‚  40-80 GB    â”‚ â† SLOW (2 TB/s)
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

  Standard attention: load full matrices from HBM â†’ compute â†’ store
  Flash attention:    compute in SRAM-sized tiles â†’ never materialize
                      full attention matrix in HBM

  Result:
    2-4x faster
    Linear memory instead of quadratic
    Exact same output (not approximate!)
```

**Versions**: FlashAttention-1 (2022) â†’ FlashAttention-2 (2023) â†’ FlashAttention-3 (2024, Hopper GPUs)

### 5. Normalization & Activation

```
PRE-RMSNORM (replaces Post-LayerNorm):
  Original Transformer: Attention â†’ Add â†’ LayerNorm â†’ FFN â†’ Add â†’ LayerNorm
  Modern LLM:           RMSNorm â†’ Attention â†’ Add â†’ RMSNorm â†’ FFN â†’ Add

  RMSNorm = Root Mean Square Normalization
  Simpler than LayerNorm (no mean subtraction), faster, works better.

SwiGLU ACTIVATION (replaces ReLU):
  SwiGLU(x) = (x Â· Wâ‚) âŠ™ SiLU(x Â· V)

  Three matrices instead of two (Wâ‚, Wâ‚‚, V)
  Better performance empirically, standard in LLaMA/Mistral/GPT.
```

---

## â—† How They Combine (LLaMA 3 Architecture)

```
LLaMA 3 70B â€” A complete modern LLM:

  Input â†’ Tokenizer (BPE, 128K vocab)
       â†’ Embedding lookup
       â†’ [80 Transformer layers, each:]
           â”œâ”€â”€ Pre-RMSNorm
           â”œâ”€â”€ GQA Self-Attention (8 KV heads, 64 query heads)
           â”‚   â””â”€â”€ RoPE positional encoding
           â”‚   â””â”€â”€ Flash Attention computation
           â”œâ”€â”€ Residual connection
           â”œâ”€â”€ Pre-RMSNorm
           â”œâ”€â”€ SwiGLU Feed-Forward Network
           â””â”€â”€ Residual connection
       â†’ Final RMSNorm
       â†’ Output head â†’ Softmax â†’ Next token probability

  Total: 70B parameters, 8K-128K context
```

---

## â—† Quick Reference

```
COMPONENT CHEAT SHEET:
  MoE      â†’ More capacity, less compute (sparse activation)
  GQA      â†’ Less KV cache memory (grouped key-value sharing)
  RoPE     â†’ Better position encoding (rotation-based, extensible)
  Flash    â†’ Faster attention (tiled SRAM computation)
  RMSNorm  â†’ Simpler, faster normalization
  SwiGLU   â†’ Better activation function

WHICH MODELS USE WHAT:
  LLaMA 3:    GQA + RoPE + Flash + RMSNorm + SwiGLU
  LLaMA 4:    MoE + GQA + RoPE + Flash + RMSNorm + SwiGLU
  Mistral:    GQA + RoPE + Flash + RMSNorm + SwiGLU + Sliding Window
  Mixtral:    MoE + GQA + RoPE + Flash + RMSNorm + SwiGLU
  DeepSeek:   MoE + MLA + RoPE + Flash + RMSNorm
  GPT-5:      MoE + proprietary attention + proprietary position
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **MoE doesn't reduce model size**: Total params are HUGE. MoE reduces ACTIVE params per token. You still need to fit ALL experts in memory.
- âš ï¸ **Flash Attention is exact**: It's not an approximation. Same result as standard attention, just computed more efficiently.
- âš ï¸ **RoPE extension â‰  free**: Extending context with RoPE scaling works but quality degrades beyond training length without fine-tuning.
- âš ï¸ **GQA grouping affects quality**: Too few groups = quality drop. 8 groups for 64 heads is the typical sweet spot.

---

## â—‹ Interview Angles

- **Q**: What is Mixture of Experts and why does LLaMA 4 use it?
- **A**: MoE has multiple "expert" FFN sub-networks per layer with a learned router. For each token, only top-K experts (e.g., 2 of 16) are activated. This gives the model capacity of the total parameters but computational cost of only the active experts. LLaMA 4 uses it to achieve 400B total params with only 17B active â€” massive capacity at manageable cost.

- **Q**: What is GQA and how does it save memory?
- **A**: Grouped-Query Attention shares K and V heads across groups of Q heads. With 64 Q heads and 8 KV heads, the KV cache is 8x smaller than full MHA. This is critical for serving long-context models â€” KV cache can otherwise consume more memory than the model weights.

---

## â˜… Code & Implementation

### Compare SSM vs Transformer Throughput

```python
# pip install torch>=2.3 mamba-ssm>=1.2  (mamba-ssm requires CUDA)
# âš ï¸ Last tested: 2026-04 | Requires: torch>=2.3; mamba-ssm for Mamba models
# For CPU-only demo: use PyTorch baseline only

import torch, time

def benchmark_inference(model, input_ids, n_runs: int = 10) -> float:
    """Return median inference latency in ms."""
    latencies = []
    with torch.inference_mode():
        for _ in range(n_runs):
            start = time.monotonic()
            model(input_ids)
            latencies.append((time.monotonic() - start) * 1000)
    latencies.sort()
    return latencies[len(latencies) // 2]  # median

# Transformer baseline (decoder-only, minimal)
import torch.nn as nn

class MiniTransformer(nn.Module):
    def __init__(self, d=256, heads=4, layers=4, seq=512):
        super().__init__()
        self.embed = nn.Embedding(32000, d)
        self.layers = nn.ModuleList([
            nn.TransformerDecoderLayer(d, heads, batch_first=True)
            for _ in range(layers)
        ])
        self.head = nn.Linear(d, 32000)

    def forward(self, x):
        h = self.embed(x)
        mem = torch.zeros_like(h)  # dummy memory
        for layer in self.layers:
            h = layer(h, mem)
        return self.head(h)

model = MiniTransformer()
ids   = torch.randint(0, 32000, (1, 512))
lat   = benchmark_inference(model, ids)
print(f"MiniTransformer (512 tokens): {lat:.1f}ms median")
# Note: quadratic scaling â€” try seq=1024, 2048 to see latency grow
```

## â˜… Connections

| Relationship | Topics                                                                                                                                                 |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Builds on    | [Transformers](./transformers.md), [Attention Mechanism](./attention-mechanism.md), [Linear Algebra For Ai](../prerequisites/linear-algebra-for-ai.md) |
| Leads to     | [Llms Overview](../llms/llms-overview.md), [Inference Optimization](../inference/inference-optimization.md)                                            |
| Compare with | Original Transformer (2017), RNNs (sequential)                                                                                                         |
| Cross-domain | Computer architecture (memory hierarchy), Sparse computation                                                                                           |


---

## â—† Production Failure Modes

| Failure                              | Symptoms                                           | Root Cause                                                         | Mitigation                                                                       |
| ------------------------------------ | -------------------------------------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| **Architecture-capability mismatch** | Selected architecture underperforms on task type   | Using encoder-only for generation, decoder-only for classification | Architecture selection guide: encoder for classification, decoder for generation |
| **MoE routing collapse**             | Only 1-2 experts receive all tokens, others unused | Load balancing loss insufficient                                   | Auxiliary load balancing loss, expert parallelism, capacity factors              |
| **Long-context degradation**         | Quality drops beyond pre-training context window   | Architecture doesn't support position extrapolation                | RoPE scaling, ALiBi, progressive context extension                               |

---

## â—† Hands-On Exercises

### Exercise 1: Compare Architecture Families on a Task

**Goal**: Run the same task through encoder-only, decoder-only, and encoder-decoder models
**Time**: 30 minutes
**Steps**:
1. Choose a summarization or classification task
2. Run with BERT (encoder), GPT-2 (decoder), T5 (enc-dec)
3. Compare output quality and inference speed
4. Document which architecture wins and why
**Expected Output**: Architecture comparison table with quality scores and latency
---


## â˜… Recommended Resources

| Type    | Resource                                                                                   | Why                                                 |
| ------- | ------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| ðŸ“„ Paper | [Gu & Dao "Mamba: Linear-Time Sequence Modeling" (2023)](https://arxiv.org/abs/2312.00752) | State-space models challenging transformers         |
| ðŸ“„ Paper | [Touvron et al. "LLaMA" (2023)](https://arxiv.org/abs/2302.13971)                          | Open-weight LLM architecture decisions explained    |
| ðŸŽ¥ Video | [Yannic Kilcher â€” Architecture Breakdowns](https://www.youtube.com/@YannicKilcher)         | Detailed paper walkthroughs of modern architectures |
| ðŸ“˜ Book  | "Build a Large Language Model (From Scratch)" by Sebastian Raschka (2024)                  | End-to-end architecture implementation              |

## â˜… Sources

- Shazeer et al., "Outrageously Large Neural Networks: The Sparsely-Gated Mixture-of-Experts Layer" (2017)
- Ainslie et al., "GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints" (2023)
- Su et al., "RoFormer: Enhanced Transformer with Rotary Position Embedding" (2021)
- Dao, "FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness" (2022)
- Meta, "LLaMA 3 / LLaMA 4 Technical Reports" (2024-2025)
- Shazeer, "GLU Variants Improve Transformer" (SwiGLU, 2020)
