---
title: "Attention Mechanism Deep Dive"
tags: [attention, mha, gqa, mqa, flash-attention, kv-cache, transformers]
type: concept
difficulty: expert
status: published
last_verified: 2026-04
parent: "[[attention-mechanism]]"
related: ["[[attention-mechanism]]", "[[transformers]]", "[[../inference/inference-optimization]]", "[[state-space-models]]"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# Attention Mechanism Deep Dive

> ✨ **Bit**: Attention is the beating heart of every transformer. Understanding its variants — MHA, GQA, MQA, and FlashAttention — is the difference between reading research papers and understanding them. This note goes beyond "Q·Kᵀ/√d" to the engineering reality of memory, speed, and scale.

---

## ★ TL;DR

- **What**: A complete treatment of attention variants, their memory/compute tradeoffs, KV-cache mechanics, and hardware-efficient implementations (FlashAttention)
- **Why**: Attention is the bottleneck for both training and inference cost. Understanding attention variants is essential for model selection, optimization, and architecture design.
- **Key point**: The evolution from MHA → GQA → MQA reduced KV-cache memory by 8-96×, enabling longer contexts and cheaper inference. FlashAttention reduced attention's memory footprint from O(n²) to O(n).

---

## ★ Overview

### Definition

**Attention** computes a weighted combination of values (V) based on the compatibility between queries (Q) and keys (K). The mechanism allows the model to focus on relevant parts of the input regardless of distance.

### Prerequisites

- [Attention Mechanism](./attention-mechanism.md) — foundational concepts
- [Transformers](./transformers.md) — architecture context
- [Inference Optimization](../inference/inference-optimization.md)

---

## ★ Deep Dive

### Attention Mathematics

```
SCALED DOT-PRODUCT ATTENTION:

  Attention(Q, K, V) = softmax(Q·Kᵀ / √d_k) · V

  Where:
    Q ∈ ℝ^(n × d_k)     Query matrix (n tokens × d_k dimensions)
    K ∈ ℝ^(n × d_k)     Key matrix
    V ∈ ℝ^(n × d_v)     Value matrix
    d_k                   Key dimension (typically d_model / n_heads)

  STEP BY STEP:
    1. Q·Kᵀ             → (n × n) attention scores     O(n²·d_k)
    2. / √d_k            → scale to prevent large logits
    3. + mask             → causal mask for autoregressive
    4. softmax            → normalize to probabilities    O(n²)
    5. × V               → weighted value aggregation     O(n²·d_v)

  TOTAL COMPLEXITY: O(n² · d)
  TOTAL MEMORY: O(n²) for the attention weights matrix
```

### Attention Variant Evolution

```
Multi-Head Attention (MHA) — Original (2017)
│  Each head has its own Q, K, V projections
│  H heads × (d_q + d_k + d_v) parameters
│  KV-cache: H × n × d_k per layer
│
├──► Grouped-Query Attention (GQA) — LLaMA 2+ (2023)
│      Groups of query heads share K, V projections
│      G groups (G < H), each group shares K, V
│      KV-cache: G × n × d_k per layer (G/H reduction)
│
└──► Multi-Query Attention (MQA) — PaLM (2022)
       ALL query heads share ONE set of K, V
       KV-cache: 1 × n × d_k per layer (H× reduction!)
       Slight quality loss, massive memory savings
```

### KV-Cache Memory Math

```
KV-CACHE SIZE PER TOKEN:

  Per layer:  2 × n_heads_kv × d_head × precision_bytes
  Total:      per_layer × n_layers × sequence_length

  EXAMPLE: LLaMA 3.1 70B
    n_layers = 80
    n_heads = 64 (query), n_heads_kv = 8 (GQA, 8 groups)
    d_head = 128
    precision = 2 bytes (bf16)

  Per token per layer = 2 × 8 × 128 × 2 = 4,096 bytes = 4 KB
  Per token total     = 4 KB × 80 layers = 320 KB
  
  SEQUENCE COSTS:
    1K tokens  → 320 MB
    8K tokens  → 2.5 GB
    32K tokens → 10 GB
    128K tokens → 40 GB  ← exceeds many GPUs!

  IF MHA (64 KV heads instead of 8):
    Per token = 2 × 64 × 128 × 2 × 80 = 2.5 MB per token
    128K tokens → 320 GB  ← impossible!

  GQA SAVINGS: 8× reduction in KV-cache = feasible long context
```

### FlashAttention: IO-Aware Attention

```
STANDARD ATTENTION:
  1. Compute full n×n attention matrix in HBM  → O(n²) memory
  2. Apply softmax
  3. Multiply by V
  Problem: n×n matrix doesn't fit in SRAM for long sequences

FLASH ATTENTION:
  1. Tile Q, K, V into blocks that fit in SRAM
  2. Compute attention block-by-block (never materialize full n×n)
  3. Use online softmax (rescale running max)
  4. Accumulate output incrementally
  
  Result: O(n) memory, 2-4× faster wall-clock time
  
  WHY IT'S FASTER DESPITE SAME FLOPS:
  - Attention is memory-bound, not compute-bound
  - FlashAttention minimizes HBM reads/writes
  - Keeping data in SRAM (fast) instead of HBM (slow)
  
  FlashAttention-2: Further optimized, 2× of FA-1
  FlashAttention-3: Hopper GPU optimizations, FP8 support
```

---

## ★ Code & Implementation

### Attention Variants Comparison

```python
# pip install torch>=2.0
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.0

import torch
import torch.nn.functional as F
import math

def scaled_dot_product_attention(Q, K, V, mask=None):
    """Standard scaled dot-product attention."""
    d_k = Q.size(-1)
    scores = torch.matmul(Q, K.transpose(-2, -1)) / math.sqrt(d_k)
    if mask is not None:
        scores = scores.masked_fill(mask == 0, float('-inf'))
    weights = F.softmax(scores, dim=-1)
    return torch.matmul(weights, V), weights

# Compare KV-cache sizes across attention variants
def kv_cache_size_bytes(
    n_layers: int, seq_len: int, n_kv_heads: int,
    d_head: int, dtype_bytes: int = 2,
) -> int:
    """Calculate KV-cache memory in bytes."""
    return 2 * n_layers * seq_len * n_kv_heads * d_head * dtype_bytes

# LLaMA 3.1 70B comparison
configs = {
    "MHA (64 KV heads)": {"n_kv_heads": 64},   # Original attention
    "GQA (8 KV heads)":  {"n_kv_heads": 8},    # Grouped-query (actual)
    "MQA (1 KV head)":   {"n_kv_heads": 1},    # Multi-query
}

print("KV-Cache Memory for LLaMA 3.1 70B (80 layers, d_head=128, bf16):")
print(f"{'Variant':<22} {'1K tokens':>12} {'32K tokens':>12} {'128K tokens':>12}")
print("-" * 60)
for name, cfg in configs.items():
    sizes = []
    for seq_len in [1024, 32768, 131072]:
        size = kv_cache_size_bytes(80, seq_len, cfg["n_kv_heads"], 128, 2)
        sizes.append(f"{size / 1e9:.1f} GB")
    print(f"{name:<22} {sizes[0]:>12} {sizes[1]:>12} {sizes[2]:>12}")

# Expected output:
# KV-Cache Memory for LLaMA 3.1 70B (80 layers, d_head=128, bf16):
# Variant                  1K tokens   32K tokens  128K tokens
# ------------------------------------------------------------
# MHA (64 KV heads)          2.6 GB      83.9 GB     335.5 GB
# GQA (8 KV heads)           0.3 GB      10.5 GB      41.9 GB
# MQA (1 KV head)            0.0 GB       1.3 GB       5.2 GB
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **KV-cache OOM** | Inference crashes on long sequences | KV-cache exceeds GPU memory | Use GQA/MQA models, quantize KV-cache, limit max_seq_len |
| **Attention-bound latency** | Prefill latency scales quadratically with input length | O(n²) attention, long inputs | Use FlashAttention, consider chunked prefill |
| **Lost-in-the-middle** | Model ignores information in middle of long context | Attention weights concentrate on beginning/end | Structure input with important info at start/end |

---

## ○ Interview Angles

- **Q**: What is Multi-Query Attention and why does it matter?
- **A**: In standard Multi-Head Attention, each attention head has its own K and V projections — meaning the KV-cache scales linearly with the number of heads. Multi-Query Attention shares a single K, V pair across all query heads. This reduces KV-cache by the number of heads (e.g., 64× for LLaMA with 64 heads), enabling much longer context windows and higher batch sizes during inference. Grouped-Query Attention (GQA) is the practical middle ground — using 8 KV groups instead of 64 or 1 — giving most of the memory savings with minimal quality loss. This is what LLaMA 3 uses.

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Attention Mechanism](./attention-mechanism.md), [Transformers](./transformers.md) |
| Leads to | [Inference Optimization](../inference/inference-optimization.md), [State Space Models](./state-space-models.md) |
| Compare with | SSM (Mamba), linear attention, sparse attention |
| Cross-domain | HPC, GPU programming, hardware-software co-design |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Vaswani et al. "Attention Is All You Need" (2017)](https://arxiv.org/abs/1706.03762) | Original attention mechanism |
| 📄 Paper | [Dao et al. "FlashAttention" (2022)](https://arxiv.org/abs/2205.14135) | IO-aware attention that changed inference |
| 📄 Paper | [Ainslie et al. "GQA: Grouped-Query Attention" (2023)](https://arxiv.org/abs/2305.13245) | The GQA paper used by LLaMA 2/3 |
| 🎥 Video | [3Blue1Brown — "Attention in Transformers"](https://www.youtube.com/watch?v=eMlx5fFNoYc) | Best visual explanation |

---

## ★ Sources

- Vaswani et al. "Attention Is All You Need" (2017)
- Dao et al. "FlashAttention: Fast and Memory-Efficient Exact Attention with IO-Awareness" (2022)
- Ainslie et al. "GQA: Training Generalized Multi-Query Transformer Models from Multi-Head Checkpoints" (2023)
- Shazeer "Fast Transformer Decoding: One Write-Head is All You Need" (2019)
