---
title: "Distributed Training & Training Infrastructure"
tags: [distributed-training, fsdp, deepspeed, zero, tensor-parallelism, training-infrastructure, clusters, checkpointing, research]
type: procedure
difficulty: expert
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../foundations/scaling-laws-and-pretraining.md", "../inference/gpu-cuda-programming.md", "../techniques/advanced-fine-tuning.md", "../inference/inference-optimization.md", "../tools-and-infra/cloud-ml-services.md", "../tools-and-infra/distributed-systems-for-ai.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# Distributed Training for Large Models

> ✨ **Bit**: Once the model no longer fits on one GPU, training stops being a deep-learning problem and becomes a distributed systems problem. The math is easy; the networking, memory management, and failure recovery are hard.

---

## ★ TL;DR

- **What**: Strategies to train or adapt models across multiple GPUs/machines — data parallelism, tensor parallelism, pipeline parallelism, and optimizer sharding (ZeRO/FSDP)
- **Why**: Frontier models (100B+ params) require 100s-1000s of GPUs. Even fine-tuning 7B-70B models often needs multi-GPU setups.
- **Key point**: Different parallelism strategies solve different bottlenecks. Data parallelism scales throughput, model parallelism fits larger models, and ZeRO/FSDP reduces memory without full model parallelism.

---

## ★ Overview

### Definition

**Distributed training** splits the work of training a neural network across multiple accelerators (GPUs/TPUs) so teams can train larger models, faster, or more cost-effectively than a single device allows.

### Scope

Covers: Parallelism strategies (data, tensor, pipeline, sequence), memory optimization (ZeRO, FSDP, gradient checkpointing), communication patterns, practical framework usage, and GPU memory math. For inference distribution, see [Distributed Inference](../inference/distributed-inference-and-serving-architecture.md). For fine-tuning-specific techniques (LoRA, QLoRA), see [Advanced Fine-Tuning](../techniques/advanced-fine-tuning.md).

### Significance

- **Foundation model training is impossible without it**: GPT-4 class models require 10,000+ GPUs for months
- **Even fine-tuning needs it**: A 70B model in fp16 requires 140GB just for weights — no single GPU holds that
- **Career differentiator**: This topic separates application builders from infrastructure/foundation-model roles. Senior ML engineer interviews test this heavily.

### Prerequisites

- [Scaling Laws and Pretraining](../foundations/scaling-laws-and-pretraining.md) — why models are so large
- [Transformers](../foundations/transformers.md) — the architecture being parallelized
- [GPU & CUDA Programming](../inference/gpu-cuda-programming.md) — hardware fundamentals

---

## ★ Deep Dive

### Why Single-GPU Training Breaks

A training run must hold ALL of the following in GPU memory simultaneously:

```
GPU MEMORY BREAKDOWN (training a 7B parameter model in fp32):

  Model weights:           7B × 4 bytes   =  28 GB
  Optimizer state (Adam):  7B × 8 bytes   =  56 GB  (momentum + variance)
  Gradients:               7B × 4 bytes   =  28 GB
  Activations:             variable       = ~10-40 GB (depends on batch, seq len)
  ─────────────────────────────────────────────────
  TOTAL:                                   ~122-150 GB

  Best single GPU (2026):  H100 80GB, A100 80GB

  Result: Even a 7B model in fp32 CANNOT train on a single GPU.

WITH MIXED PRECISION (fp16/bf16):
  Model weights:           7B × 2 bytes   =  14 GB
  Optimizer state (Adam):  7B × 8 bytes   =  56 GB  (still fp32!)
  Gradients:               7B × 2 bytes   =  14 GB
  Activations:                            = ~10-30 GB
  ─────────────────────────────────────────────────
  TOTAL:                                   ~94-114 GB  (still too much!)
```

**Key insight**: The optimizer state (2× model size for Adam) is often the largest single consumer. This is why ZeRO Stage 1 (shard optimizer state only) provides massive savings.

### The 4 Parallelism Strategies

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PARALLELISM STRATEGY MAP                         │
│                                                                     │
│  DATA PARALLELISM            TENSOR PARALLELISM                    │
│  ┌─────┐ ┌─────┐            ┌──────────────────┐                  │
│  │GPU 0│ │GPU 1│            │   Single Layer    │                  │
│  │Full │ │Full │            │  ┌─────┬─────┐   │                  │
│  │Model│ │Model│            │  │GPU 0│GPU 1│   │                  │
│  │     │ │     │            │  │half │half │   │                  │
│  │Batch│ │Batch│            │  │     │     │   │                  │
│  │ A   │ │ B   │            │  └─────┴─────┘   │                  │
│  └─────┘ └─────┘            └──────────────────┘                  │
│  Split: data                 Split: within layers                  │
│  Sync: gradients             Sync: activations (every layer!)      │
│                                                                     │
│  PIPELINE PARALLELISM        SEQUENCE PARALLELISM                  │
│  ┌─────┐ ┌─────┐            ┌──────────────────┐                  │
│  │GPU 0│ │GPU 1│            │   Attention       │                  │
│  │     │ │     │            │  ┌─────┬─────┐   │                  │
│  │L1-L4│→│L5-L8│            │  │Seq  │Seq  │   │                  │
│  │     │ │     │            │  │1-512│513+ │   │                  │
│  │     │ │     │            │  │     │     │   │                  │
│  └─────┘ └─────┘            │  └─────┴─────┘   │                  │
│  Split: layer groups         └──────────────────┘                  │
│  Sync: activations           Split: sequence dimension             │
│  (between stages)            For: long-context training            │
└─────────────────────────────────────────────────────────────────────┘
```

| Strategy | What Is Split | Main Benefit | Main Cost | When to Use |
|----------|:-------------|:------------|:---------|:-----------|
| **Data Parallelism (DDP)** | Batches across GPUs | Simple, linear throughput scaling | Gradient sync (all-reduce) | Model fits on 1 GPU |
| **ZeRO / FSDP** | Optimizer state, gradients, parameters | Fits larger models without model parallelism | Communication overhead, complexity | Model barely fits or doesn't fit |
| **Tensor Parallelism (TP)** | Within layers (matrix splits) | Fits very large layers | Heavy intra-node communication | Single layers too large for 1 GPU |
| **Pipeline Parallelism (PP)** | Layer groups across GPUs | Reduces per-device memory | Pipeline bubbles, scheduling | Very deep models (100+ layers) |
| **Sequence Parallelism (SP)** | Sequence dimension | Enables long-context training | Framework complexity | Context > 32K tokens |
| **3D Parallelism** | DP + TP + PP combined | Trains frontier models (100B+) | Maximum complexity | Foundation model training |

### ZeRO and FSDP: The Memory Optimization Revolution

```
ZeRO STAGES:

Stage 0: DDP (baseline)
  Each GPU: full weights + full optimizer + full gradients
  Memory per GPU: ~150 GB for 7B model

Stage 1: Shard Optimizer State
  Each GPU: full weights + 1/N optimizer + full gradients
  Memory saved: ~60% of optimizer = huge win
  Communication: same as DDP

Stage 2: Shard Optimizer + Gradients
  Each GPU: full weights + 1/N optimizer + 1/N gradients
  Memory saved: more, but weights still replicated
  Communication: slightly more than Stage 1

Stage 3: Shard Everything (= FSDP)
  Each GPU: 1/N weights + 1/N optimizer + 1/N gradients
  Memory saved: maximum — scales linearly with GPU count
  Communication: all-gather weights before compute, re-shard after

  ┌──────────────────────────────────────────────────┐
  │  MEMORY PER GPU (7B model, 8 GPUs, bf16)         │
  │                                                    │
  │  DDP (Stage 0):   ~95 GB   ← doesn't fit!        │
  │  ZeRO Stage 1:    ~52 GB   ← barely fits A100    │
  │  ZeRO Stage 2:    ~38 GB   ← fits A100 80GB      │
  │  ZeRO Stage 3:    ~16 GB   ← fits RTX 4090!      │
  └──────────────────────────────────────────────────┘
```

### Communication Patterns

| Pattern | Used By | What It Does | Cost |
|---------|---------|-------------|------|
| **All-Reduce** | DDP gradient sync | Sum gradients across all GPUs | O(N × param_size) |
| **All-Gather** | FSDP/ZeRO-3 | Collect sharded params before compute | O(N × shard_size) |
| **Reduce-Scatter** | FSDP/ZeRO-3 | Distribute gradient shards after backward | O(N × shard_size) |
| **Point-to-Point** | Pipeline parallel | Send activations between pipeline stages | O(activation_size) |

**The interconnect hierarchy** (bandwidth matters enormously):

```
NVLink (intra-node):    600-900 GB/s  ← fast, use for tensor parallelism
PCIe 5.0:               64 GB/s       ← 10× slower than NVLink
InfiniBand (inter-node): 200-400 GB/s ← fast enough for data parallelism
Ethernet (inter-node):   25-100 GB/s  ← can work if communication is minimized

Rule: Put communication-heavy parallelism (tensor) on fast links (NVLink).
      Put communication-light parallelism (data, pipeline) across nodes.
```

### GPU Memory Math Cheat Sheet

```
MEMORY ESTIMATION FORMULAS:

  Model weights (bytes):
    fp32: params × 4
    fp16/bf16: params × 2
    int8: params × 1
    int4: params × 0.5

  Adam optimizer state:
    2 × params × 4 bytes (momentum + variance in fp32)
    = 8 bytes per parameter

  Gradients:
    Same size as model weights (fp32 or fp16)

  Total (fp16 mixed precision, single GPU):
    weights(2) + optimizer(8) + gradients(2) = 12 bytes per parameter

  EXAMPLES:
    7B model:   7B × 12 = 84 GB  (needs A100 80GB + gradient checkpointing)
    13B model:  13B × 12 = 156 GB (needs multi-GPU)
    70B model:  70B × 12 = 840 GB (needs 11+ A100 80GB)
    405B model: 405B × 12 = 4.8 TB (needs 60+ A100 80GB)
```

---

## ★ Code & Implementation

### Multi-GPU Training with PyTorch FSDP

```python
# pip install torch>=2.2 transformers>=4.40
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.2

import torch
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from torch.distributed.fsdp import ShardingStrategy
import torch.distributed as dist
from transformers import AutoModelForCausalLM, AutoTokenizer

def train_with_fsdp():
    """Example: FSDP training setup for a large language model."""

    # 1. Initialize distributed
    dist.init_process_group("nccl")
    local_rank = dist.get_rank()
    torch.cuda.set_device(local_rank)

    # 2. Load model
    model = AutoModelForCausalLM.from_pretrained(
        "meta-llama/Llama-3.1-8B",
        torch_dtype=torch.bfloat16,
    )

    # 3. Wrap with FSDP
    model = FSDP(
        model,
        sharding_strategy=ShardingStrategy.FULL_SHARD,  # = ZeRO Stage 3
        # Options:
        # FULL_SHARD = ZeRO-3 (shard everything, minimum memory)
        # SHARD_GRAD_OP = ZeRO-2 (shard gradients + optimizer)
        # NO_SHARD = DDP (replicate everything)
        device_id=local_rank,
        use_orig_params=True,  # Required for torch.compile compatibility
    )

    # 4. Setup optimizer (operates on sharded parameters)
    optimizer = torch.optim.AdamW(model.parameters(), lr=2e-5)

    # 5. Training loop (simplified)
    model.train()
    for batch in dataloader:  # Your distributed dataloader
        batch = {k: v.to(local_rank) for k, v in batch.items()}
        outputs = model(**batch)
        loss = outputs.loss
        loss.backward()
        optimizer.step()
        optimizer.zero_grad()

        if local_rank == 0:
            print(f"Loss: {loss.item():.4f}")

    dist.destroy_process_group()

# Launch: torchrun --nproc_per_node=4 train.py
# Expected: Model sharded across 4 GPUs, ~4× less memory per GPU
```

### DeepSpeed ZeRO Configuration

```python
# pip install deepspeed>=0.14 transformers>=4.40
# ⚠️ Last tested: 2026-04 | Requires: deepspeed>=0.14

# deepspeed_config.json
"""
{
    "bf16": {"enabled": true},
    "zero_optimization": {
        "stage": 2,
        "offload_optimizer": {"device": "cpu"},
        "allgather_partitions": true,
        "reduce_scatter": true,
        "overlap_comm": true
    },
    "gradient_accumulation_steps": 4,
    "gradient_clipping": 1.0,
    "train_batch_size": 32,
    "train_micro_batch_size_per_gpu": 4,
    "wall_clock_breakdown": true
}
"""

# Training with HuggingFace Trainer + DeepSpeed
from transformers import Trainer, TrainingArguments

training_args = TrainingArguments(
    output_dir="./runs/deepspeed",
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-5,
    bf16=True,
    deepspeed="deepspeed_config.json",  # Pass config
    num_train_epochs=1,
    logging_steps=10,
    save_strategy="epoch",
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=dataset,
    tokenizer=tokenizer,
)
trainer.train()

# Launch: deepspeed --num_gpus=4 train.py
# or: accelerate launch --config_file accelerate_config.yaml train.py
```

---

## ◆ Formulas & Equations

| Name | Formula | Use |
|------|---------|-----|
| **Memory per GPU (DDP)** | $M = 2P + 8P + 2P = 12P$ bytes (bf16 weights + Adam + gradients) | Estimate if model fits on 1 GPU |
| **Memory per GPU (ZeRO-3)** | $M = \frac{12P}{N} + \text{activations}$ | Memory with N-way full sharding |
| **Communication (all-reduce)** | $T = \frac{2(N-1)}{N} \times \frac{S}{B}$ | Time for gradient sync (S=size, B=bandwidth) |
| **Pipeline bubble fraction** | $\text{bubble} = \frac{p-1}{m+p-1}$ | p=pipeline stages, m=micro-batches |
| **Linear throughput scaling** | $\text{throughput} \approx N \times T_1 \times \eta$ | N=GPUs, T₁=single-GPU throughput, η=scaling efficiency |

---

## ◆ Quick Reference

```
DECISION GUIDE:

  Model fits on 1 GPU?
  ├── YES → Use DDP (data parallelism). Done.
  └── NO  → Does it fit with mixed precision (bf16)?
             ├── YES → Use DDP + bf16 + gradient checkpointing
             └── NO  → Use ZeRO/FSDP
                        ├── ZeRO Stage 1: shard optimizer (easiest)
                        ├── ZeRO Stage 2: + shard gradients
                        └── ZeRO Stage 3/FSDP: shard everything
                            └── Still doesn't fit?
                                → Add tensor parallelism (intra-node)
                                → Add pipeline parallelism (inter-node)
                                → Welcome to 3D parallelism.

GPU COUNT ESTIMATES (bf16, fine-tuning with Adam):
  7B model:    1-2 × A100 80GB  (FSDP Stage 2)
  13B model:   2-4 × A100 80GB  (FSDP Stage 3)
  70B model:   8-16 × A100 80GB (FSDP Stage 3 + TP)
  405B model:  64+ × A100 80GB  (3D parallelism)
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **NCCL timeout** | Training hangs, then crashes with timeout error | Network congestion, straggler GPU, NCCL deadlock | Set NCCL_TIMEOUT, use NCCL debug logging, check network health |
| **OOM during backward** | OOM crash partway through training (not at start) | Activation memory spikes during backward pass | Enable gradient checkpointing, reduce micro-batch size |
| **Gradient NaN/Inf** | Loss becomes NaN, training diverges | Numerical instability in bf16, learning rate too high | Use bf16 (not fp16), gradient clipping, reduce LR, check data for outliers |
| **Checkpoint corruption** | Cannot resume from checkpoint, state mismatch | Multi-GPU checkpoint save interrupted, FSDP state mismanagement | Use async checkpointing, validate checkpoints, save optimizer state separately |
| **Pipeline bubble waste** | GPU utilization drops to 50-60% with pipeline parallelism | Too few micro-batches relative to pipeline stages | Increase micro-batches (aim for 4× pipeline stages minimum) |
| **Scaling efficiency collapse** | Adding GPUs doesn't improve training speed | Communication overhead dominates compute, bad parallelism strategy | Profile with torch.profiler, check communication/compute ratio, try different strategy |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **More GPUs ≠ faster training**: If communication dominates compute, adding GPUs makes it slower. Always profile before scaling.
- ⚠️ **ZeRO Stage 3 has overhead**: While it saves the most memory, Stage 3 requires all-gather before every forward pass. Stage 2 is often the better tradeoff.
- ⚠️ **Pipeline parallelism requires careful micro-batch tuning**: Pipeline bubbles waste GPU time. Use at least 4× micro-batches per pipeline stage to keep utilization > 80%.
- ⚠️ **Gradient accumulation doesn't reduce communication**: It delays sync but total bytes transferred is the same. It helps with memory, not bandwidth.
- ⚠️ **Distributed bugs are systems bugs, not math bugs**: Most failures are timeouts, race conditions, checkpoint inconsistency, or network issues — not gradient computation errors.

---

## ○ Interview Angles

- **Q**: What's the difference between data parallelism and tensor parallelism?
- **A**: Data parallelism replicates the entire model on each GPU and splits the batch — each GPU processes different data, then gradients are synchronized via all-reduce. This scales throughput linearly for models that fit on a single GPU. Tensor parallelism splits individual layer computations across GPUs — for example, a large matrix multiplication is split column-wise across 4 GPUs, each computing 1/4 of the result. This enables layers that are too large for one GPU but requires extremely fast inter-GPU communication (NVLink, not Ethernet) because activations must be synchronized at every layer boundary. In practice, tensor parallelism is used intra-node (within a server with NVLink) while data parallelism is used inter-node (across servers).

- **Q**: Explain ZeRO optimization stages.
- **A**: ZeRO addresses the memory inefficiency of standard DDP, where each GPU holds a full copy of model weights, optimizer state, and gradients. ZeRO eliminates this redundancy in 3 stages. Stage 1 shards only the optimizer state (Adam momentum + variance) — this alone saves ~60% of optimizer memory with minimal communication overhead, making it the best first step. Stage 2 additionally shards gradients via reduce-scatter instead of all-reduce. Stage 3 (equivalent to FSDP) shards everything including model weights — each GPU holds only 1/N of parameters and uses all-gather to reconstruct weights before each forward pass. The tradeoff is progressive: each stage saves more memory but adds more communication. For fine-tuning, Stage 2 is usually the sweet spot; for training models that truly don't fit, Stage 3 is necessary.

---

## ◆ Hands-On Exercises

### Exercise 1: GPU Memory Calculator

**Goal**: Calculate memory requirements for training different model sizes
**Time**: 20 minutes
**Steps**:
1. Write the memory formula: M = 12P bytes per parameter (bf16 + Adam)
2. Calculate for: 1B, 7B, 13B, 70B models — do they fit on A100 80GB? H100 80GB?
3. Calculate ZeRO Stage 3 memory with 4 GPUs and 8 GPUs
4. Add activation memory estimate: ~2× batch_size × seq_len × hidden_dim × num_layers × 2 bytes
**Expected Output**: Table showing memory per GPU for each model size and parallelism strategy

### Exercise 2: FSDP Training Script

**Goal**: Train a small model with FSDP and observe memory savings
**Time**: 60 minutes (requires multi-GPU)
**Steps**:
1. Start with a 1.3B model (e.g., OPT-1.3B) on 2 GPUs
2. First train with DDP — observe GPU memory usage
3. Switch to FSDP (FULL_SHARD) — observe memory reduction
4. Try gradient checkpointing — how much more memory is saved?
5. Profile with torch.profiler — what fraction of time is communication?
**Expected Output**: Memory comparison table (DDP vs FSDP), communication breakdown

---

## ★ Training Infrastructure

> Absorbed from the former standalone `distributed-training.md` — the operational substrate behind large-scale training.

### Infrastructure Layers

| Layer | Purpose | Key Concerns |
|-------|---------|-------------|
| **Compute** | GPU/accelerator nodes | GPU type, memory, interconnect (NVLink, NVSwitch) |
| **Scheduling** | Job placement, quotas, priority | SLURM, Kubernetes, fair-share policies |
| **Storage** | Datasets, checkpoints, logs | Throughput (not just capacity), parallel filesystem |
| **Networking** | Inter-node communication | InfiniBand, RoCE, bandwidth vs latency |
| **Observability** | Utilization, failures, throughput | GPU utilization, stragglers, job state |
| **Artifact systems** | Checkpoints, configs, outputs | Versioning, cleanup policies, restore testing |

### Critical Infrastructure Design Questions

1. **Data throughput**: How fast can the system feed training data to accelerators? Slow storage starves GPUs.
2. **Checkpoint cadence**: How often can you checkpoint without killing training throughput? Balance recovery cost vs checkpoint overhead.
3. **Fault recovery**: What happens when a node dies mid-run? Automatic restart from last checkpoint is the minimum viable solution.
4. **Multi-tenancy**: How are quotas and priority handled across teams on a shared cluster?
5. **Reproducibility**: Can you recover the exact config, code, data, and environment for any training run?

### Infrastructure Failure Quick Reference

| Problem | Likely Infra Cause |
|---------|-------------------|
| GPUs idle during training | Storage or data pipeline bottleneck |
| Painful restarts | Weak checkpointing or orchestration |
| Low cluster utilization | Scheduler policy or fragmentation issue |
| Unreproducible results | Poor artifact and config tracking |
| Slow distributed scaling | Networking or topology bottleneck |

### Practical Infrastructure Rules

1. Optimize data throughput before buying more compute
2. Test checkpoint **restore** regularly, not just checkpoint write
3. Keep configuration and artifacts versioned together
4. Build for failure, especially in multi-node runs
5. Separate experiment convenience from production-grade cluster policy

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Scaling Laws](../foundations/scaling-laws-and-pretraining.md), [GPU & CUDA](../inference/gpu-cuda-programming.md), [Transformers](../foundations/transformers.md) |
| Leads to | Foundation model engineering, [Advanced Fine-Tuning](../techniques/advanced-fine-tuning.md) (QLoRA needs FSDP for large models) |
| Compare with | Single-GPU training, [Distributed Inference](../inference/distributed-inference-and-serving-architecture.md) (different problem, similar tools) |
| Cross-domain | HPC, Network engineering, Distributed systems, Cloud infrastructure |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Rajbhandari et al. "ZeRO: Memory Optimizations Toward Training Trillion Parameter Models" (2020)](https://arxiv.org/abs/1910.02054) | The paper that made multi-GPU training practical for everyone |
| 🔧 Hands-on | [PyTorch FSDP Tutorial](https://pytorch.org/tutorials/intermediate/FSDP_tutorial.html) | Official step-by-step guide to FSDP with code |
| 🔧 Hands-on | [DeepSpeed Getting Started](https://www.deepspeed.ai/getting-started/) | Microsoft's framework with excellent ZeRO implementation |
| 📄 Paper | [Shoeybi et al. "Megatron-LM: Training Multi-Billion Parameter Language Models" (2020)](https://arxiv.org/abs/1909.08053) | NVIDIA's approach to 3D parallelism — the foundation for large-scale training |
| 🎥 Video | [Stas Bekman — "Efficient Training on Multiple GPUs" (HuggingFace)](https://huggingface.co/docs/transformers/perf_train_gpu_many) | Best practical guide to multi-GPU training with HuggingFace |
| 📘 Book | "Efficient Deep Learning" by Menghani (2024) | Covers distributed training alongside quantization, pruning, and other efficiency techniques |
| 🎓 Course | [Stanford CS336: Language Modeling from Scratch](https://stanford-cs336.github.io/) | Teaches distributed training as part of building LLMs from scratch |

---

## ★ Sources

- Rajbhandari et al. "ZeRO: Memory Optimizations Toward Training Trillion Parameter Models" (2020)
- Shoeybi et al. "Megatron-LM: Training Multi-Billion Parameter Language Models Using Model Parallelism" (2020)
- PyTorch FSDP Documentation — https://pytorch.org/docs/stable/fsdp.html
- DeepSpeed Documentation — https://www.deepspeed.ai/
- HuggingFace Multi-GPU Training Guide — https://huggingface.co/docs/transformers/perf_train_gpu_many
- [Scaling Laws and Pretraining](../foundations/scaling-laws-and-pretraining.md)
