---
title: Inference Optimization
aliases: ["Inference", "Quantization", "Speculative Decoding"]
tags: [inference, quantization, speculative-decoding, kv-cache, serving, performance, sglang, radix-attention, pd-disaggregation, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: ../genai.md
related:
  - ../llms/llms-overview.md
  - ../tools-and-infra/tools-overview.md
  - ../foundations/transformers.md
  - gpu-cuda-programming.md
  - distributed-inference-and-serving-architecture.md
  - ../production/cost-optimization.md
source: Multiple papers and frameworks - see Sources
created: 2026-03-18
updated: 2026-04-15
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
  GPT-5.4 (frontier scale): Each forward pass = massive computation.
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

**Speculative Decoding Techniques (2025-2026):**

| Technique | Method | Training Required | Typical Speedup | Deployment Maturity |
|-----------|--------|:-----------------:|:---------------:|:-------------------:|
| **EAGLE-3** | Draft head (2-5% of target model params), feature fusion, tree-based candidate verification | Yes (lightweight head training) | 2-3x | Production (vLLM, SGLang) |
| **Medusa** | Multiple prediction heads on target model, each predicts k tokens ahead | Yes (head fine-tuning) | 1.5-2.5x | Production |
| **SPECTRA** | Training-free, uses n-gram + small model ensemble for drafting | No | 1.5-2x | Research â†’ Production |
| **Self-Speculative** | Model drafts from its own early layers (early exit) | No | 1.3-1.8x | Experimental |

```
ENABLING SPECULATIVE DECODING IN VLLM:

  # Start vLLM with speculative decoding enabled
  python -m vllm.entrypoints.openai.api_server \
    --model meta-llama/Llama-3.2-70B-Instruct \
    --speculative-model meta-llama/Llama-3.2-8B-Instruct \
    --num-speculative-tokens 5 \
    --use-v2-block-manager

  # Key flags:
  #   --speculative-model       Draft model (smaller, same tokenizer)
  #   --num-speculative-tokens   How many tokens to draft per step (3-7)
  #   --speculative-draft-tensor-parallel-size  TP for draft model

  # SGLang equivalent:
  python -m sglang.launch_server \
    --model meta-llama/Llama-3.2-70B-Instruct \
    --speculative-algorithm EAGLE \
    --speculative-eagle-path eagle-head-weights/
```

### Edge & On-Device Inference

Running LLMs on consumer hardware, mobile devices, and edge GPUs.

| Stack | Hardware | Best For | Key Feature |
|-------|----------|----------|-------------|
| **Ollama** | macOS/Linux/Windows | Local LLM experimentation | One-command setup, model registry |
| **MLX** | Apple Silicon (M1-M4) | macOS-native inference | UMA advantage, Metal acceleration |
| **llama.cpp / GGUF** | CPU + optional GPU | Universal local inference | Pure C++, no Python dependencies |
| **ExecuTorch** | iOS / Android | Mobile deployment | PyTorch mobile runtime |

```
EDGE MODEL SELECTION (April 2026):

  Device Memory    Recommended Models              Quantization
  â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€       â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€              â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  4 GB             Gemma 4 E2B (2B), Phi-4-mini    Q4_K_M
  8 GB             Gemma 4 E4B (4B), LLaMA 3.2 3B  Q4_K_M / Q5_K_M
  16 GB            Gemma 4 26B MoE, Mistral 7B     Q4_K_M
  32 GB            LLaMA 3.2 8B, Gemma 4 31B       Q5_K_M / Q6_K
  64 GB+           LLaMA 3.2 70B                   Q4_K_M

  APPLE SILICON UMA ADVANTAGE:
    CPU and GPU share the same memory pool (Unified Memory Architecture)
    No PCIe transfer bottleneck â†’ faster KV cache access
    M4 Max (128GB) can run 70B models at Q4 comfortably
```

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

### SGLang: RadixAttention Architecture (2026 Standard)

```
SGLang vs vLLM: Same goal, different KV cache management strategy.

vLLM PagedAttention:
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  KV cache partitioned into fixed-size physical pages â”‚
â”‚  Pages allocated per request, freed on completion    â”‚
â”‚  Best for: diverse prompts, simple batch serving     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

SGLang RadixAttention:
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  KV cache stored as a RADIX TREE (prefix trie)       â”‚
â”‚  Common prefix â†’ shared nodes across requests        â”‚
â”‚  Automatic prefix matching at every request          â”‚
â”‚                                                      â”‚
â”‚  Request A: "System: You are a coder. User: Fix X"  â”‚
â”‚  Request B: "System: You are a coder. User: Fix Y"  â”‚
â”‚               â””â”€â”€ Shared prefix cache â”€â”€â”˜            â”‚
â”‚  Cache hit on system prompt + instruction preamble   â”‚
â”‚  Only compute the unique suffix (X vs Y)             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**When to use SGLang over vLLM**: prefix cache hit rate > 30% (RAG systems, multi-turn chat, agentic workloads with shared tool schemas). For diverse prompts with < 10% cache hits, vLLM's wider ecosystem often wins.

| Workload | vLLM | SGLang | Reason |
|---|---|---|---|
| Simple batch Q&A (diverse prompts) | âœ… | Good | Both work; vLLM has wider ecosystem |
| RAG pipeline (shared system prompt) | âš ï¸ Manual | âœ… | RadixAttention auto-shares prefix context |
| Multi-turn chat (shared history) | âš ï¸ | âœ… | Radix tree naturally stores conversation cache |
| Agentic loops (shared tool schemas) | âš ï¸ | âœ… | High-repetition prefix = massive cache hits |

### Prefill/Decode (P/D) Disaggregation

```
TRADITIONAL: One GPU handles BOTH phases
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  GPU Node                                        â”‚
â”‚  Prefill (compute-bound) â–º Decode (memory-bound)  â”‚
â”‚  Decode blocks new prefill requests!             â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

P/D DISAGGREGATION: Specialized node clusters
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  PREFILL NODES         KV xfer    DECODE NODES     â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”            â”‚       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚High-FLOP â”‚â”€â”€â”€â”€â”€â”€â”€â”€â–ºâ”‚        â”‚High-BW   â”‚  â”‚
â”‚  â”‚GPUs(H100)â”‚            â”‚        â”‚GPUs(H200) â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜            â”‚        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚  Maximize FLOPS        cache      Maximize BW      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
Result: 2-4Ã— higher cluster throughput at same cost.
```

**Implementations (2026)**: Distserve (OSDI 2024), vLLM KVTransfer API, NVIDIA Dynamo serving stack.

### Speculative Decoding â€” 2026 State of the Art

| Method | Key Innovation | Speedup |
|---|---|---|
| Standard speculative | Small draft + large verify | 2-3Ã— |
| **EAGLE-3** (2025) | Draft from target's intermediate layers; no separate model | 3-4Ã— |
| **P-EAGLE** | EAGLE + P/D disaggregation | Up to 5Ã— |
| **TurboSpec** | Dynamic disabling when acceptance rate drops | Avoids negative speedup |
| SPECTRA (ACL 2025) | Training-free; any draft + any target | 2-2.5Ã— |

> **EAGLE-3 is the 2026 default**: zero memory overhead, no separate model to maintain, 3-4Ã— real-world speedup.

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
- âš ï¸ **SGLang RadixAttention thrash**: If prompts are highly diverse, the radix tree evicts cache aggressively and you lose the benefit. Profile cache hit rate before committing.
- âš ï¸ **P/D disaggregation complexity**: Adds network hop for KV cache transfer. Requires high-bandwidth interconnect (NVLink, InfiniBand) to avoid bottleneck.

---

## â˜… Code & Implementation

### Start vLLM Server (OpenAI-Compatible)

```bash
# pip install vllm>=0.8
# âš ï¸ Last tested: 2026-04 | Requires: vllm>=0.8, CUDA GPU

python -m vllm.entrypoints.openai.api_server \
  --model google/gemma-2-2b-it \
  --dtype bfloat16 \
  --max-model-len 4096 \
  --gpu-memory-utilization 0.85

# Test via OpenAI client:
# from openai import OpenAI
# client = OpenAI(base_url="http://localhost:8000/v1", api_key="none")
# r = client.chat.completions.create(model="google/gemma-2-2b-it",
#       messages=[{"role": "user", "content": "Explain KV caching."}])
# print(r.choices[0].message.content)
```

### Start SGLang Server (RadixAttention â€” Best for RAG/Agentic)

```bash
# pip install sglang[all]>=0.4.0
# âš ï¸ Last tested: 2026-04 | Requires: sglang>=0.4, CUDA GPU

python -m sglang.launch_server \
  --model-path google/gemma-2-2b-it \
  --port 30000 \
  --mem-fraction-static 0.85
# RadixAttention prefix caching is automatic â€” no extra config needed
# High prefix cache hit rate (RAG, agents) â†’ SGLang outperforms vLLM
```

### Load Model with 4-bit Quantization

```python
# pip install transformers>=4.40 bitsandbytes>=0.43
# âš ï¸ Last tested: 2026-04 | Requires: transformers>=4.40, bitsandbytes>=0.43, CUDA GPU

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_quant_type="nf4",        # NF4 = best quality for 4-bit
    bnb_4bit_use_double_quant=True,   # Double quant reduces metadata overhead
)

model = AutoModelForCausalLM.from_pretrained(
    "google/gemma-2-2b-it",
    quantization_config=bnb_config,
    device_map="auto",
    attn_implementation="flash_attention_2",
)
tokenizer = AutoTokenizer.from_pretrained("google/gemma-2-2b-it")
mem_gb = torch.cuda.memory_allocated() / (1024**3)
print(f"Model loaded in {mem_gb:.1f} GB (4-bit quantized)")

inputs = tokenizer("Explain quantization in one sentence:", return_tensors="pt").to(model.device)
output = model.generate(**inputs, max_new_tokens=50)
print(tokenizer.decode(output[0], skip_special_tokens=True))
# LLaMA-70B: 140 GB in FP16 -> ~35 GB with 4-bit (fits on single A100!)
```

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

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Quantization quality cliff** | INT4 model produces gibberish on certain inputs | Weight outliers in specific layers | Per-channel quantization (GPTQ), SmoothQuant, mixed precision |
| **Speculative decoding mismatch** | Draft model rejects >50% of tokens; no speedup | Draft model too different from target | Tune acceptance threshold; try EAGLE-3 (no separate draft model) |
| **KV-cache OOM at batch** | Works for 1 request, OOM at batch size 8 | KV-cache scales linearly with batch size | Paged attention (vLLM), GQA/MQA, KV-cache quantization |
| **Continuous batching stalls** | Throughput plateaus despite available GPU | Short sequences blocking slots for long ones | Preemptive scheduling, iteration-level batching |
| **P/D disaggregation KV transfer latency** | Low throughput despite specialized nodes | KV cache transfer between prefill/decode nodes bottlenecks | High-bandwidth interconnect (NVLink, InfiniBand); compress KV before transfer |
| **RadixAttention cache thrash** | High eviction rate; low cache hit ratio | Extremely diverse prompts exceed cache budget | Increase SGLang cache size; or switch to vLLM for truly diverse workloads |

---

## â—† Hands-On Exercises

### Exercise 1: Benchmark Quantization Levels

**Goal**: Compare FP16, INT8, INT4 on latency, throughput, and quality
**Time**: 30 minutes
**Steps**:
1. Load the same model at FP16, INT8 (bitsandbytes), and INT4 (GPTQ)
2. Run 50 inference samples at each precision
3. Measure tokens/second, memory usage, and output quality (BLEU or LLM-judge)
4. Plot the Pareto frontier of quality vs speed
**Expected Output**: Quality/speed tradeoff chart across precisions
---


## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ“„ Paper | [Dao et al. "FlashAttention-2" (2023)](https://arxiv.org/abs/2307.08691) | 2Ã— faster attention â€” essential for production serving |
| ðŸ“„ Paper | [Leviathan et al. "Speculative Decoding" (2022)](https://arxiv.org/abs/2211.17192) | Accelerate decoding without quality loss |
| ðŸ“„ Paper | [Zheng et al. "SGLang" (2024)](https://arxiv.org/abs/2312.07104) | RadixAttention and efficient LLM serving |
| ðŸ“„ Paper | [Li et al. "Distserve" (2024)](https://arxiv.org/abs/2401.09670) | Prefill/Decode disaggregation architecture |
| ðŸ”§ Hands-on | [vLLM Documentation](https://docs.vllm.ai/) | Production inference optimization in practice |
| ðŸ”§ Hands-on | [SGLang Documentation](https://sgl-project.github.io/) | RadixAttention and efficient serving |
| ðŸ“˜ Book | "Efficient Deep Learning" by Menghani (2024) | Comprehensive treatment of inference optimization techniques |

## â˜… Sources

- Dettmers et al., "LLM.int8(): 8-bit Matrix Multiplication for Transformers at Scale" (2022)
- Lin et al., "AWQ: Activation-aware Weight Quantization" (2023)
- Leviathan et al., "Fast Inference from Transformers via Speculative Decoding" (2023)
- Kwon et al., "Efficient Memory Management for Large Language Model Serving with PagedAttention" (vLLM, 2023)
- Dao, "FlashAttention" (2022) â€” https://arxiv.org/abs/2205.14135
- Zheng et al., "SGLang: Efficient Execution of Structured Language Model Programs" (2024) â€” https://arxiv.org/abs/2312.07104
- Li et al., "Distserve: Disaggregating Prefill and Decoding for Goodput-Optimized LLM Serving" (2024) â€” https://arxiv.org/abs/2401.09670
- EAGLE-3: https://arxiv.org/abs/2503.01840
- vLLM documentation â€” https://docs.vllm.ai
- SGLang documentation â€” https://sgl-project.github.io
