---
title: "Inference Optimization"
tags: [inference, quantization, speculative-decoding, kv-cache, serving, performance, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[../llms/llms-overview]]", "[[../tools-and-infra/tools-overview]]", "[[../foundations/transformers]]", "[[gpu-cuda-programming]]", "[[distributed-inference-and-serving-architecture]]", "[[../production/cost-optimization]]"]
source: "Multiple papers and frameworks - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# Inference Optimization

> âœ¨ **Bit**: Training a frontier LLM costs $100M+. Running it costs... well, also a LOT. Inference optimization is the difference between "cool demo" and "sustainable business." This is the deep tech that companies actually pay for.

---

## â˜… TL;DR

- **What**: Techniques to make LLM inference faster, cheaper, and more memory-efficient without (significantly) hurting quality
- **Why**: Inference is where the money is spent (90%+ of LLM compute cost in production). This is THE skill for deep tech roles.
- **Key point**: Quantization (smaller numbers) + KV caching (don't recompute) + Speculative decoding (predict + verify) = orders of magnitude improvement.

---

## â˜… Overview

### Definition

**Inference optimization** covers all techniques that reduce the latency, memory, cost, or compute required to generate outputs from a trained LLM. Unlike training optimization (done once), inference optimization impacts every single request forever.

### Scope

Covers: Quantization, KV cache, speculative decoding, batching, and architectural optimizations. For serving infrastructure, see [Model Serving for LLM Applications](../production/model-serving.md) and [GenAI Tools & Infrastructure](../tools-and-infra/tools-overview.md). For hardware foundations, see [GPU & CUDA Programming for AI Engineers](./gpu-cuda-programming.md). For scaled serving topologies, see [Distributed Inference & Serving Architecture](./distributed-inference-and-serving-architecture.md).

### Significance

- At scale, inference cost > training cost (by 3-10x)
- The reason you can run LLaMA 70B on a single GPU (quantization)
- The reason vLLM serves 10x more requests than naive serving (PagedAttention)
- Deep tech roles require this knowledge: not everyone who uses LLMs understands HOW to make them fast

### Prerequisites

- [Transformers](../foundations/transformers.md) â€” attention mechanism and KV computation
- [Llms Overview](../llms/llms-overview.md) â€” how generation works (autoregressive)
- Basic GPU/memory concepts

---

## â˜… Deep Dive

### Why Inference Is Slow

```
AUTOREGRESSIVE GENERATION IS SEQUENTIAL:
  "The" â†’ "capital" â†’ "of" â†’ "France" â†’ "is" â†’ "Paris" â†’ "."

  Each token requires a FULL forward pass through the model.
  GPT-5 (rumored ~1T params): Each forward pass = massive computation.
  100-token response = 100 sequential forward passes.

TWO PHASES:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚ PREFILL (process input)                              â”‚
  â”‚   All input tokens processed in parallel.            â”‚
  â”‚   Compute-bound (lots of matrix math).               â”‚
  â”‚   One-time cost per request.                         â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚ DECODE (generate output)                             â”‚
  â”‚   One token at a time, sequentially.                 â”‚
  â”‚   Memory-bound (loading model weights from GPU RAM). â”‚
  â”‚   Repeated for every output token.                   â”‚
  â”‚   THIS IS THE BOTTLENECK.                            â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### The Big Three Techniques

#### 1. Quantization (Smaller Numbers = Less Memory)

```
CONCEPT:
  FP32: 11000001 01001000 00000000 00000000  (32 bits per number)
  FP16: 1100001 0010010                       (16 bits â€” half the memory!)
  INT8: 11001010                              (8 bits â€” quarter the memory!)
  INT4: 1100                                  (4 bits â€” 1/8 the memory!)

MEMORY IMPACT (LLaMA 70B):
  FP32:  280 GB  (7Ã— A100 80GB)
  FP16:  140 GB  (2Ã— A100 80GB)
  INT8:   70 GB  (1Ã— A100 80GB)
  INT4:   35 GB  (1Ã— RTX 4090 or A100 40GB!)  â† This is why quantization matters
```

| Method    | Type                   | How It Works                                       | Quality Loss   |
| --------- | ---------------------- | -------------------------------------------------- | -------------- |
| **GPTQ**  | PTQ (post-training)    | Layer-by-layer quantization using calibration data | Low (< 1%)     |
| **AWQ**   | PTQ                    | Protects "salient" weights from quantization       | Very low       |
| **GGUF**  | PTQ                    | CPU-friendly format used by llama.cpp              | Varies by bits |
| **QLoRA** | QAT (quantize + train) | 4-bit base + LoRA adapters in 16-bit               | Minimal        |
| **FP8**   | Native hardware        | Supported on Blackwell/Rubin GPUs (2025+)          | Very low       |

```
QUICK DECISION:
  Running locally (consumer GPU)?     â†’ GGUF Q4 via Ollama/llama.cpp
  Production serving on GPU?          â†’ AWQ or GPTQ via vLLM
  Fine-tuning on limited GPU?         â†’ QLoRA (4-bit base + 16-bit LoRA)
  Newest enterprise GPU (Blackwell)?  â†’ Native FP8
```

#### 2. KV Cache (Don't Recompute Past Tokens)

```
WITHOUT KV CACHE:
  Generate "Paris":  Compute attention for ["The", "capital", "of", "France", "is"]
  Generate ".":      Compute attention for ["The", "capital", "of", "France", "is", "Paris"]
                     â†‘ Recomputed everything again! Wasteful.

WITH KV CACHE:
  Generate "Paris":  Compute K,V for all tokens â†’ STORE in cache
  Generate ".":      Reuse cached K,V â†’ Only compute for new token "Paris"
                     â†‘ 100x faster for long sequences!

PROBLEM: KV cache grows with sequence length Ã— batch size:
  LLaMA 70B, 4096 context, batch=32:
    KV cache = ~40 GB of GPU memory just for the cache!
```

| KV Cache Technique         | What It Does                        | Impact                    |
| -------------------------- | ----------------------------------- | ------------------------- |
| **PagedAttention** (vLLM)  | Paging like OS memory management    | 2-4x more throughput      |
| **KV Cache Quantization**  | Compress cache to FP8/INT4          | 50-75% less cache memory  |
| **Prefix Caching**         | Share cache for common prefixes     | Fewer recomputations      |
| **Sliding Window**         | Only cache recent N tokens          | Bounded memory (Mistral)  |
| **Token Pruning/Eviction** | Remove less important cached tokens | More capacity per request |

#### 3. Speculative Decoding (Predict + Verify in Parallel)

```
NORMAL DECODING (slow):
  Big Model generates: T1 â†’ T2 â†’ T3 â†’ T4 â†’ T5
  Time: 5 sequential forward passes through the BIG model

SPECULATIVE DECODING (fast):
  Step 1: Small draft model rapidly generates 5 candidate tokens:
          T1, T2, T3, T4, T5  (5 fast forward passes)

  Step 2: Big model verifies ALL 5 in ONE parallel forward pass:
          "T1 âœ“, T2 âœ“, T3 âœ“, T4 âœ— (wrong), T5 â€”"

  Step 3: Accept T1, T2, T3. Regenerate from T4.

  Result: 3 tokens verified in 1 big-model pass instead of 3.
  Speedup: 2-3x with ZERO quality loss (mathematically proven).

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  Draft   â”‚â”€â”€â”€â–ºâ”‚  Target  â”‚â”€â”€â”€â–ºâ”‚ Accept/Rejectâ”‚
  â”‚  Model   â”‚    â”‚  Model   â”‚    â”‚ verified     â”‚
  â”‚  (fast)  â”‚    â”‚ (accurate)â”‚   â”‚ tokens       â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**2025-2026 advances:**
- **Universal Speculative Acceleration**: Any draft model can accelerate any target model (Intel Labs, 2025)
- **SPECTRA**: Training-free speculative decoding (ACL 2025)
- **Mirror-SD**: Parallel speculation + verification

### Other Key Techniques

| Technique                    | What                                         | Impact                           |
| ---------------------------- | -------------------------------------------- | -------------------------------- |
| **Continuous Batching**      | Dynamically add/remove requests from a batch | Better GPU utilization           |
| **Tensor Parallelism**       | Split model across multiple GPUs             | Run models too large for 1 GPU   |
| **Pipeline Parallelism**     | Different layers on different GPUs           | Reduce per-GPU memory            |
| **Flash Attention**          | Tiled attention computation                  | 2-4x faster attention            |
| **Knowledge Distillation**   | Train smaller model to mimic larger          | Smaller, faster model            |
| **Pruning**                  | Remove unimportant weights                   | Smaller model, some quality loss |
| **MoE (Mixture of Experts)** | Only activate subset of params per token     | More capacity, less compute      |

### The Optimization Stack (Layer Them)

```
LEVEL 1: Architecture (MoE, GQA, Flash Attention)         â† Built into model
LEVEL 2: Quantization (INT4/INT8/FP8)                     â† Compress model
LEVEL 3: Serving Engine (vLLM, TGI, SGLang)               â† Efficient serving
LEVEL 4: KV Cache Optimization (PagedAttention, compression)â† Memory management
LEVEL 5: Speculative Decoding (draft + verify)             â† Speed up generation
LEVEL 6: Batching (continuous/dynamic)                     â† Maximize throughput
LEVEL 7: Hardware (Blackwell GPUs, custom ASICs)           â† Raw performance

Stack them: 4-bit quant + vLLM + speculative decoding
            = 10x+ cheaper than naive FP16 serving
```

---

## â—† Formulas & Equations

| Name                   | Formula/Concept                                                                        | Use                                          |
| ---------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------- |
| Memory (model weights) | $$\text{Memory} = \text{Params} \times \text{Bytes per param}$$                        | FP16: 2 bytes, INT4: 0.5 bytes               |
| KV cache size          | $$\text{KV} = 2 \times L \times H \times D \times S \times B \times \text{precision}$$ | L=layers, H=heads, D=dim, S=seq_len, B=batch |
| Throughput             | $$\text{tokens/second} = \frac{\text{batch\_size}}{\text{latency\_per\_token}}$$       | What you optimize for at scale               |

---

## â—† Quick Reference

```
OPTIMIZATION PRIORITY ORDER (start here):
  1. Right-size the model (don't use 70B if 8B works)
  2. Quantize (INT4/INT8 via AWQ/GPTQ)
  3. Use vLLM or TGI (not naive inference)
  4. Enable KV cache optimizations
  5. Add speculative decoding (if latency-critical)
  6. Scale with tensor parallelism (multi-GPU)

MEMORY QUICK CALC:
  Model params Ã— bytes per param = weight memory
  + KV cache per request Ã— batch size = cache memory
  Total GPU memory needed = weights + cache + overhead (~20%)

LATENCY TARGETS (typical):
  Interactive chat: < 100ms time-to-first-token
  Streaming: 30-50 tokens/sec generation
  Batch processing: Maximize throughput, latency less critical
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Quantization isn't free**: INT4 CAN degrade quality for complex reasoning. Always benchmark YOUR use case.
- âš ï¸ **KV cache OOM**: Long contexts + large batches = KV cache eats all GPU memory. Monitor and limit.
- âš ï¸ **Speculative decoding overhead**: If the draft model is too slow or inaccurate, speedup disappears. Draft model must be much smaller AND accurate.
- âš ï¸ **vLLM â‰  magic**: You still need to tune batch sizes, GPU memory allocation, and scheduling for your workload.
- âš ï¸ **Latency vs throughput tradeoff**: Optimizing for one often hurts the other. Know which matters for your use case.

---

## â—‹ Interview Angles

- **Q**: How does quantization make LLMs run on consumer hardware?
- **A**: By representing model weights in fewer bits (INT4 = 4 bits vs FP16 = 16 bits), memory drops 4x. LLaMA 70B goes from 140GB (needs 2Ã— A100) to 35GB (fits on 1Ã— RTX 4090). Modern quantization methods (AWQ, GPTQ) preserve quality by protecting important weights and using calibration data.

- **Q**: Explain speculative decoding.
- **A**: A small draft model rapidly generates N candidate tokens. The large target model verifies all N in a single parallel forward pass (since verification is parallelizable). Accepted tokens are kept, rejected ones trigger regeneration. Provably lossless (same distribution as target model) with 2-3x speedup.

- **Q**: What is PagedAttention and why does vLLM use it?
- **A**: Like OS virtual memory paging. KV cache is stored in non-contiguous memory blocks ("pages") instead of one contiguous block. This eliminates fragmentation, allows dynamic memory allocation, and enables sharing cache between requests with common prefixes. Result: 2-4x higher throughput.

---

## â˜… Connections

| Relationship | Topics                                                                       |
| ------------ | ---------------------------------------------------------------------------- |
| Builds on    | [Transformers](../foundations/transformers.md), [Llms Overview](../llms/llms-overview.md)                   |
| Leads to     | Production LLM deployment, Cost optimization, Edge AI                        |
| Compare with | Training optimization (different phase), Model compression (overlapping)     |
| Cross-domain | Computer architecture (memory hierarchy), OS (paging), Compiler optimization |

---

## â˜… Sources

- Dettmers et al., "LLM.int8(): 8-bit Matrix Multiplication for Transformers at Scale" (2022)
- Lin et al., "AWQ: Activation-aware Weight Quantization" (2023)
- Leviathan et al., "Fast Inference from Transformers via Speculative Decoding" (2023)
- Kwon et al., "Efficient Memory Management for Large Language Model Serving with PagedAttention" (vLLM, 2023)
- Dao, "FlashAttention" (2022) â€” https://arxiv.org/abs/2205.14135
- vLLM documentation â€” https://docs.vllm.ai
