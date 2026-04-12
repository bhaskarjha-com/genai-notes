---
title: "Distributed Training for Large Models"
tags: [distributed-training, fsdp, deepspeed, zero, tensor-parallelism, research]
type: concept
difficulty: expert
status: published
parent: "[[../genai]]"
related: ["[[../foundations/scaling-laws-and-pretraining]]", "[[../inference/gpu-cuda-programming]]", "[[../techniques/advanced-fine-tuning]]", "[[../inference/inference-optimization]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Distributed Training for Large Models

> Once the model no longer fits comfortably on one GPU, training stops being a deep-learning problem and becomes a distributed systems problem.

---

## TL;DR

- **What**: The strategies used to train or adapt models across multiple GPUs and machines.
- **Why**: Frontier and even many mid-sized models exceed the memory, bandwidth, and wall-clock limits of single-device training.
- **Key point**: Different parallelism strategies solve different bottlenecks: memory, compute, communication, or throughput.

---

## Overview

### Definition

**Distributed training** splits model training work across multiple accelerators so teams can train larger models faster or more cheaply.

### Scope

This note covers the practical mental model for data parallelism, model parallelism, optimizer sharding, and communication bottlenecks. It is a systems overview, not a framework manual.

### Significance

- Large-model work is impossible without distributed training.
- Even fine-tuning big open models often needs sharding and memory management.
- This topic separates application builders from foundation-model and infrastructure roles.

### Prerequisites

- [Scaling Laws and Pretraining](../foundations/scaling-laws-and-pretraining.md)
- [Transformers](../foundations/transformers.md)
- [GPU & CUDA Programming for AI Engineers](../inference/gpu-cuda-programming.md)

---

## Deep Dive

### Why Single-GPU Training Breaks

A large training run must hold:

- model weights
- optimizer state
- gradients
- activations
- dataloader and communication overhead

That is why a model far smaller than raw GPU memory can still fail to train on one device.

### Major Parallelism Strategies

| Strategy | What Is Split | Main Benefit | Main Cost |
|---|---|---|---|
| **Data parallelism** | Batches | Simple scaling | Gradient synchronization |
| **Tensor parallelism** | Inside layers | Fits larger models | Heavy communication |
| **Pipeline parallelism** | Layer groups | Reduces per-device memory | Pipeline bubbles and scheduling complexity |
| **Sequence/context parallelism** | Sequence dimension | Helps long-context workloads | Framework complexity |

### Data Parallelism

Each GPU gets a different mini-batch, computes gradients locally, then participates in gradient synchronization.

This works well when:

- the model fits on each device
- interconnect bandwidth is good enough
- communication cost does not dominate compute

### FSDP and ZeRO

These approaches shard state instead of fully replicating it.

| Method | Main Idea |
|---|---|
| **DDP** | Full model replica on each device |
| **ZeRO** | Shard optimizer state, gradients, and optionally parameters |
| **FSDP** | Fully sharded parameter handling with all-gather and reshard around compute |

They are often the first step when the model barely fits or fine-tuning becomes memory-bound.

### Tensor and Pipeline Parallelism

For models that are simply too large for one device replica:

- **tensor parallelism** splits layer computations across GPUs
- **pipeline parallelism** assigns different layer blocks to different GPUs or nodes

In practice, large training systems often combine:

- data parallelism
- tensor parallelism
- pipeline parallelism

That combination is often called **3D parallelism**.

### Communication Is The Hidden Boss

Distributed training speed is limited not only by FLOPs but by:

- all-reduce costs
- network topology
- cross-node bandwidth
- straggler effects
- checkpoint save/load time

This is why interconnect quality and cluster design matter so much.

### Memory-Saving Techniques Around Distributed Training

- gradient checkpointing
- mixed precision
- activation recomputation
- optimizer sharding
- parameter-efficient fine-tuning such as LoRA

### Practical Training Stack

```text
Data loader
-> distributed sampler
-> framework runtime
-> precision + sharding policy
-> communication backend
-> checkpointing and recovery
-> experiment tracking
```

### Rule Of Thumb

1. Use data parallelism first if the model fits.
2. Add sharding when memory is the problem.
3. Add tensor or pipeline parallelism when the model itself is too large.
4. Profile communication before assuming more GPUs will help.

---

## Quick Reference

| Problem | Typical First Move |
|---|---|
| Model barely fits | mixed precision + FSDP/ZeRO |
| Model does not fit at all | tensor or pipeline parallelism |
| Training is too slow | more data parallel workers if communication allows |
| Long context blows up memory | checkpointing, sequence parallelism, smaller micro-batches |
| Recovery from failure is painful | better checkpointing and resume logic |

---

## Gotchas

- More GPUs can make training slower if communication dominates.
- Pipeline parallelism wastes time when stage balance is poor.
- Gradient accumulation helps batch size but does not remove communication complexity.
- Distributed bugs are often race, timeout, or checkpoint-consistency problems rather than math errors.

---

## Interview Angles

- **Q**: What is the difference between data parallelism and tensor parallelism?
- **A**: Data parallelism replicates the model and splits the batch across devices, while tensor parallelism splits the actual layer computation across devices. Data parallelism scales throughput; tensor parallelism helps fit larger models.

- **Q**: When would you choose FSDP or ZeRO?
- **A**: When the model almost fits or optimizer state becomes the dominant memory problem. They reduce replication overhead without immediately needing full model-parallel complexity.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Scaling Laws and Pretraining](../foundations/scaling-laws-and-pretraining.md), [GPU & CUDA Programming for AI Engineers](../inference/gpu-cuda-programming.md) |
| Leads to | foundation-model engineering, training infrastructure, large-scale fine-tuning |
| Compare with | single-GPU training, distributed inference |
| Cross-domain | HPC, networking, systems engineering |

---

## Sources

- PyTorch FSDP documentation
- DeepSpeed ZeRO documentation
- Megatron-LM documentation
- [Scaling Laws and Pretraining](../foundations/scaling-laws-and-pretraining.md)
