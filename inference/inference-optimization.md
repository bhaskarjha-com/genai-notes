---
title: "Inference Optimization"
tags: [inference, quantization, speculative-decoding, kv-cache, serving, performance, sglang, radix-attention, pd-disaggregation, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../llms/llms-overview.md", "../tools-and-infra/tools-overview.md", "../foundations/transformers.md", "gpu-cuda-programming.md", "distributed-inference-and-serving-architecture.md", "../production/cost-optimization.md"]
source: "Multiple papers and frameworks - see Sources"
created: 2026-03-18
updated: 2026-04-15
---

# Inference Optimization

> ✨ **Bit**: Training a frontier LLM costs $100M+. Running it costs... well, also a LOT. Inference optimization is the difference between "cool demo" and "sustainable business." This is the deep tech that companies actually pay for.

---

## ★ TL;DR

- **What**: Techniques to make LLM inference faster, cheaper, and more memory-efficient without (significantly) hurting quality
- **Why**: Inference is where the money is spent (90%+ of LLM compute cost in production). This is THE skill for deep tech roles.
- **Key point**: Quantization (smaller numbers) + KV caching (don't recompute) + Speculative decoding (predict + verify) = orders of magnitude improvement.

---

## ★ Overview

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

- [Transformers](../foundations/transformers.md) — attention mechanism and KV computation
- [Llms Overview](../llms/llms-overview.md) — how generation works (autoregressive)
- Basic GPU/memory concepts

---

## ★ Deep Dive

### Why Inference Is Slow

```
AUTOREGRESSIVE GENERATION IS SEQUENTIAL:
  "The" → "capital" → "of" → "France" → "is" → "Paris" → "."

  Each token requires a FULL forward pass through the model.
  GPT-5 (rumored ~1T params): Each forward pass = massive computation.
  100-token response = 100 sequential forward passes.

TWO PHASES:
  ┌──────────────────────────────────────────────────────┐
  │ PREFILL (process input)                              │
  │   All input tokens processed in parallel.            │
  │   Compute-bound (lots of matrix math).               │
  │   One-time cost per request.                         │
  ├──────────────────────────────────────────────────────┤
  │ DECODE (generate output)                             │
  │   One token at a time, sequentially.                 │
  │   Memory-bound (loading model weights from GPU RAM). │
  │   Repeated for every output token.                   │
  │   THIS IS THE BOTTLENECK.                            │
  └──────────────────────────────────────────────────────┘
```

### The Big Three Techniques

#### 1. Quantization (Smaller Numbers = Less Memory)

```
CONCEPT:
  FP32: 11000001 01001000 00000000 00000000  (32 bits per number)
  FP16: 1100001 0010010                       (16 bits — half the memory!)
  INT8: 11001010                              (8 bits — quarter the memory!)
  INT4: 1100                                  (4 bits — 1/8 the memory!)

MEMORY IMPACT (LLaMA 70B):
  FP32:  280 GB  (7× A100 80GB)
  FP16:  140 GB  (2× A100 80GB)
  INT8:   70 GB  (1× A100 80GB)
  INT4:   35 GB  (1× RTX 4090 or A100 40GB!)  ← This is why quantization matters
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
  Running locally (consumer GPU)?     → GGUF Q4 via Ollama/llama.cpp
  Production serving on GPU?          → AWQ or GPTQ via vLLM
  Fine-tuning on limited GPU?         → QLoRA (4-bit base + 16-bit LoRA)
  Newest enterprise GPU (Blackwell)?  → Native FP8
```

#### 2. KV Cache (Don't Recompute Past Tokens)

```
WITHOUT KV CACHE:
  Generate "Paris":  Compute attention for ["The", "capital", "of", "France", "is"]
  Generate ".":      Compute attention for ["The", "capital", "of", "France", "is", "Paris"]
                     ↑ Recomputed everything again! Wasteful.

WITH KV CACHE:
  Generate "Paris":  Compute K,V for all tokens → STORE in cache
  Generate ".":      Reuse cached K,V → Only compute for new token "Paris"
                     ↑ 100x faster for long sequences!

PROBLEM: KV cache grows with sequence length × batch size:
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
  Big Model generates: T1 → T2 → T3 → T4 → T5
  Time: 5 sequential forward passes through the BIG model

SPECULATIVE DECODING (fast):
  Step 1: Small draft model rapidly generates 5 candidate tokens:
          T1, T2, T3, T4, T5  (5 fast forward passes)

  Step 2: Big model verifies ALL 5 in ONE parallel forward pass:
          "T1 ✓, T2 ✓, T3 ✓, T4 ✗ (wrong), T5 —"

  Step 3: Accept T1, T2, T3. Regenerate from T4.

  Result: 3 tokens verified in 1 big-model pass instead of 3.
  Speedup: 2-3x with ZERO quality loss (mathematically proven).

  ┌──────────┐    ┌──────────┐    ┌──────────────┐
  │  Draft   │───►│  Target  │───►│ Accept/Reject│
  │  Model   │    │  Model   │    │ verified     │
  │  (fast)  │    │ (accurate)│   │ tokens       │
  └──────────┘    └──────────┘    └──────────────┘
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
LEVEL 1: Architecture (MoE, GQA, Flash Attention)         ← Built into model
LEVEL 2: Quantization (INT4/INT8/FP8)                     ← Compress model
LEVEL 3: Serving Engine (vLLM, TGI, SGLang)               ← Efficient serving
LEVEL 4: KV Cache Optimization (PagedAttention, compression)← Memory management
LEVEL 5: Speculative Decoding (draft + verify)             ← Speed up generation
LEVEL 6: Batching (continuous/dynamic)                     ← Maximize throughput
LEVEL 7: Hardware (Blackwell GPUs, custom ASICs)           ← Raw performance

Stack them: 4-bit quant + vLLM + speculative decoding
            = 10x+ cheaper than naive FP16 serving
```

### SGLang: RadixAttention Architecture (2026 Standard)

```
SGLang vs vLLM: Same goal, different KV cache management strategy.

vLLM PagedAttention:
┌──────────────────────────────────────────────────┐
│  KV cache partitioned into fixed-size physical pages │
│  Pages allocated per request, freed on completion    │
│  Best for: diverse prompts, simple batch serving     │
└──────────────────────────────────────────────────┘

SGLang RadixAttention:
┌──────────────────────────────────────────────────┐
│  KV cache stored as a RADIX TREE (prefix trie)       │
│  Common prefix → shared nodes across requests        │
│  Automatic prefix matching at every request          │
│                                                      │
│  Request A: "System: You are a coder. User: Fix X"  │
│  Request B: "System: You are a coder. User: Fix Y"  │
│               └── Shared prefix cache ──┘            │
│  Cache hit on system prompt + instruction preamble   │
│  Only compute the unique suffix (X vs Y)             │
└──────────────────────────────────────────────────┘
```

**When to use SGLang over vLLM**: prefix cache hit rate > 30% (RAG systems, multi-turn chat, agentic workloads with shared tool schemas). For diverse prompts with < 10% cache hits, vLLM's wider ecosystem often wins.

| Workload | vLLM | SGLang | Reason |
|---|---|---|---|
| Simple batch Q&A (diverse prompts) | ✅ | Good | Both work; vLLM has wider ecosystem |
| RAG pipeline (shared system prompt) | ⚠️ Manual | ✅ | RadixAttention auto-shares prefix context |
| Multi-turn chat (shared history) | ⚠️ | ✅ | Radix tree naturally stores conversation cache |
| Agentic loops (shared tool schemas) | ⚠️ | ✅ | High-repetition prefix = massive cache hits |

### Prefill/Decode (P/D) Disaggregation

```
TRADITIONAL: One GPU handles BOTH phases
┌──────────────────────────────────────────────┐
│  GPU Node                                        │
│  Prefill (compute-bound) ► Decode (memory-bound)  │
│  Decode blocks new prefill requests!             │
└──────────────────────────────────────────────┘

P/D DISAGGREGATION: Specialized node clusters
┌──────────────────────────────────────────────┐
│  PREFILL NODES         KV xfer    DECODE NODES     │
│  ┌──────────┐            │       ┌──────────┐  │
│  │High-FLOP │────────►│        │High-BW   │  │
│  │GPUs(H100)│            │        │GPUs(H200) │  │
│  └──────────┘            │        └──────────┘  │
│  Maximize FLOPS        cache      Maximize BW      │
└──────────────────────────────────────────────┘
Result: 2-4× higher cluster throughput at same cost.
```

**Implementations (2026)**: Distserve (OSDI 2024), vLLM KVTransfer API, NVIDIA Dynamo serving stack.

### Speculative Decoding — 2026 State of the Art

| Method | Key Innovation | Speedup |
|---|---|---|
| Standard speculative | Small draft + large verify | 2-3× |
| **EAGLE-3** (2025) | Draft from target's intermediate layers; no separate model | 3-4× |
| **P-EAGLE** | EAGLE + P/D disaggregation | Up to 5× |
| **TurboSpec** | Dynamic disabling when acceptance rate drops | Avoids negative speedup |
| SPECTRA (ACL 2025) | Training-free; any draft + any target | 2-2.5× |

> **EAGLE-3 is the 2026 default**: zero memory overhead, no separate model to maintain, 3-4× real-world speedup.

---


## ◆ Formulas & Equations

| Name                   | Formula/Concept                                                                        | Use                                          |
| ---------------------- | -------------------------------------------------------------------------------------- | -------------------------------------------- |
| Memory (model weights) | $$\text{Memory} = \text{Params} \times \text{Bytes per param}$$                        | FP16: 2 bytes, INT4: 0.5 bytes               |
| KV cache size          | $$\text{KV} = 2 \times L \times H \times D \times S \times B \times \text{precision}$$ | L=layers, H=heads, D=dim, S=seq_len, B=batch |
| Throughput             | $$\text{tokens/second} = \frac{\text{batch\_size}}{\text{latency\_per\_token}}$$       | What you optimize for at scale               |

---

## ◆ Quick Reference

```
OPTIMIZATION PRIORITY ORDER (start here):
  1. Right-size the model (don't use 70B if 8B works)
  2. Quantize (INT4/INT8 via AWQ/GPTQ)
  3. Use vLLM or TGI (not naive inference)
  4. Enable KV cache optimizations
  5. Add speculative decoding (if latency-critical)
  6. Scale with tensor parallelism (multi-GPU)

MEMORY QUICK CALC:
  Model params × bytes per param = weight memory
  + KV cache per request × batch size = cache memory
  Total GPU memory needed = weights + cache + overhead (~20%)

LATENCY TARGETS (typical):
  Interactive chat: < 100ms time-to-first-token
  Streaming: 30-50 tokens/sec generation
  Batch processing: Maximize throughput, latency less critical
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Quantization isn't free**: INT4 CAN degrade quality for complex reasoning. Always benchmark YOUR use case.
- ⚠️ **KV cache OOM**: Long contexts + large batches = KV cache eats all GPU memory. Monitor and limit.
- ⚠️ **Speculative decoding overhead**: If the draft model is too slow or inaccurate, speedup disappears. Draft model must be much smaller AND accurate.
- ⚠️ **vLLM ≠ magic**: You still need to tune batch sizes, GPU memory allocation, and scheduling for your workload.
- ⚠️ **Latency vs throughput tradeoff**: Optimizing for one often hurts the other. Know which matters for your use case.
- ⚠️ **SGLang RadixAttention thrash**: If prompts are highly diverse, the radix tree evicts cache aggressively and you lose the benefit. Profile cache hit rate before committing.
- ⚠️ **P/D disaggregation complexity**: Adds network hop for KV cache transfer. Requires high-bandwidth interconnect (NVLink, InfiniBand) to avoid bottleneck.

---

## ★ Code & Implementation

### Start vLLM Server (OpenAI-Compatible)

```bash
# pip install vllm>=2.0.0
# ⚠️ Last tested: 2026-04 | Requires: vllm>=2.0, CUDA GPU

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

### Start SGLang Server (RadixAttention — Best for RAG/Agentic)

```bash
# pip install sglang[all]>=0.4.0
# ⚠️ Last tested: 2026-04 | Requires: sglang>=0.4, CUDA GPU

python -m sglang.launch_server \
  --model-path google/gemma-2-2b-it \
  --port 30000 \
  --mem-fraction-static 0.85
# RadixAttention prefix caching is automatic — no extra config needed
# High prefix cache hit rate (RAG, agents) → SGLang outperforms vLLM
```

### Load Model with 4-bit Quantization

```python
# pip install transformers>=4.40 bitsandbytes>=0.43
# ⚠️ Last tested: 2026-04 | Requires: transformers>=4.40, bitsandbytes>=0.43, CUDA GPU

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

## ○ Interview Angles

- **Q**: How does quantization make LLMs run on consumer hardware?
- **A**: By representing model weights in fewer bits (INT4 = 4 bits vs FP16 = 16 bits), memory drops 4x. LLaMA 70B goes from 140GB (needs 2× A100) to 35GB (fits on 1× RTX 4090). Modern quantization methods (AWQ, GPTQ) preserve quality by protecting important weights and using calibration data.

- **Q**: Explain speculative decoding.
- **A**: A small draft model rapidly generates N candidate tokens. The large target model verifies all N in a single parallel forward pass (since verification is parallelizable). Accepted tokens are kept, rejected ones trigger regeneration. Provably lossless (same distribution as target model) with 2-3x speedup.

- **Q**: What is PagedAttention and why does vLLM use it?
- **A**: Like OS virtual memory paging. KV cache is stored in non-contiguous memory blocks ("pages") instead of one contiguous block. This eliminates fragmentation, allows dynamic memory allocation, and enables sharing cache between requests with common prefixes. Result: 2-4x higher throughput.

---

## ★ Connections

| Relationship | Topics                                                                       |
| ------------ | ---------------------------------------------------------------------------- |
| Builds on    | [Transformers](../foundations/transformers.md), [Llms Overview](../llms/llms-overview.md)                   |
| Leads to     | Production LLM deployment, Cost optimization, Edge AI                        |
| Compare with | Training optimization (different phase), Model compression (overlapping)     |
| Cross-domain | Computer architecture (memory hierarchy), OS (paging), Compiler optimization |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Quantization quality cliff** | INT4 model produces gibberish on certain inputs | Weight outliers in specific layers | Per-channel quantization (GPTQ), SmoothQuant, mixed precision |
| **Speculative decoding mismatch** | Draft model rejects >50% of tokens; no speedup | Draft model too different from target | Tune acceptance threshold; try EAGLE-3 (no separate draft model) |
| **KV-cache OOM at batch** | Works for 1 request, OOM at batch size 8 | KV-cache scales linearly with batch size | Paged attention (vLLM), GQA/MQA, KV-cache quantization |
| **Continuous batching stalls** | Throughput plateaus despite available GPU | Short sequences blocking slots for long ones | Preemptive scheduling, iteration-level batching |
| **P/D disaggregation KV transfer latency** | Low throughput despite specialized nodes | KV cache transfer between prefill/decode nodes bottlenecks | High-bandwidth interconnect (NVLink, InfiniBand); compress KV before transfer |
| **RadixAttention cache thrash** | High eviction rate; low cache hit ratio | Extremely diverse prompts exceed cache budget | Increase SGLang cache size; or switch to vLLM for truly diverse workloads |

---

## ◆ Hands-On Exercises

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


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Dao et al. "FlashAttention-2" (2023)](https://arxiv.org/abs/2307.08691) | 2× faster attention — essential for production serving |
| 📄 Paper | [Leviathan et al. "Speculative Decoding" (2022)](https://arxiv.org/abs/2211.17192) | Accelerate decoding without quality loss |
| 📄 Paper | [Zheng et al. "SGLang" (2024)](https://arxiv.org/abs/2312.07104) | RadixAttention and efficient LLM serving |
| 📄 Paper | [Li et al. "Distserve" (2024)](https://arxiv.org/abs/2401.09670) | Prefill/Decode disaggregation architecture |
| 🔧 Hands-on | [vLLM Documentation](https://docs.vllm.ai/) | Production inference optimization in practice |
| 🔧 Hands-on | [SGLang Documentation](https://sgl-project.github.io/) | RadixAttention and efficient serving |
| 📘 Book | "Efficient Deep Learning" by Menghani (2024) | Comprehensive treatment of inference optimization techniques |

## ★ Sources

- Dettmers et al., "LLM.int8(): 8-bit Matrix Multiplication for Transformers at Scale" (2022)
- Lin et al., "AWQ: Activation-aware Weight Quantization" (2023)
- Leviathan et al., "Fast Inference from Transformers via Speculative Decoding" (2023)
- Kwon et al., "Efficient Memory Management for Large Language Model Serving with PagedAttention" (vLLM, 2023)
- Dao, "FlashAttention" (2022) — https://arxiv.org/abs/2205.14135
- Zheng et al., "SGLang: Efficient Execution of Structured Language Model Programs" (2024) — https://arxiv.org/abs/2312.07104
- Li et al., "Distserve: Disaggregating Prefill and Decoding for Goodput-Optimized LLM Serving" (2024) — https://arxiv.org/abs/2401.09670
- EAGLE-3: https://arxiv.org/abs/2503.01840
- vLLM documentation — https://docs.vllm.ai
- SGLang documentation — https://sgl-project.github.io
