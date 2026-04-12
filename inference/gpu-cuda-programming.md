---
title: "GPU & CUDA Programming for AI Engineers"
tags: [gpu, cuda, kernels, memory, performance, ai-infra, inference]
type: concept
difficulty: expert
status: published
parent: "[[inference-optimization]]"
related: ["[[../research-frontiers/distributed-training]]", "[[../production/model-serving]]", "[[../foundations/transformers]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# GPU & CUDA Programming for AI Engineers

> Modern AI depends on GPUs, but high-level frameworks hide the hardware until performance forces you to care. This note is about that moment.

---

## TL;DR

- **What**: The hardware and programming concepts behind GPU-accelerated AI workloads.
- **Why**: Many training and inference bottlenecks make sense only if you understand memory hierarchy, parallel execution, and kernel behavior.
- **Key point**: In AI systems, moving data efficiently is often harder than doing the math.

---

## Overview

### Definition

A **GPU** is a massively parallel processor optimized for throughput-oriented numeric computation. **CUDA** is NVIDIA's programming model and toolchain for writing GPU-accelerated programs.

### Scope

This note gives AI engineers a practical systems view: how GPU execution works, what kernels do, why memory matters, and how that connects to LLM performance.

### Significance

- CUDA literacy explains why some inference optimizations work and others do not.
- AI infrastructure, inference, and compiler roles depend on this layer deeply.
- Even application engineers benefit from understanding hardware-shaped trade-offs.

### Prerequisites

- [Neural Networks](../prerequisites/neural-networks.md)
- [Transformers](../foundations/transformers.md)
- [Inference Optimization](./inference-optimization.md)

---

## Deep Dive

### GPU Mental Model

GPUs are built for many operations in parallel:

- thousands of lightweight threads
- high memory bandwidth
- hardware specialized for matrix-heavy workloads

They are excellent for dense tensor math and poor at control-heavy, branchy logic.

### Core Concepts

| Concept | Meaning | Why It Matters |
|---|---|---|
| **Kernel** | Function launched on the GPU | Unit of GPU work |
| **Thread block** | Group of cooperating threads | Shares fast on-chip memory |
| **Warp** | Hardware scheduling group of threads | Divergence hurts efficiency |
| **Global memory** | Large but slower GPU memory | Main bottleneck for many LLM workloads |
| **Shared memory** | Small fast block-local memory | Useful for reuse and tiling |
| **Occupancy** | How fully the GPU is utilized | Higher is not always better, but often useful |

### Memory Hierarchy Matters

```text
CPU RAM
-> PCIe / NVLink transfer
-> GPU global memory
-> shared memory / registers
-> arithmetic units
```

AI performance often depends on reducing the cost of moving data between these levels.

### Why LLMs Stress GPUs

LLM workloads include:

- large matrix multiplies
- attention kernels
- KV-cache reads and writes
- memory-heavy decode loops

Prefill tends to be more compute-heavy. Decode often becomes memory-bound.

### CUDA Performance Ideas You Should Recognize

| Idea | Practical Meaning |
|---|---|
| **Kernel fusion** | Combine steps to reduce memory traffic |
| **Tiling** | Reuse data in fast memory before reloading |
| **Coalesced access** | Neighboring threads access neighboring memory for efficiency |
| **Asynchronous execution** | Overlap transfer and compute where possible |
| **CUDA graphs** | Reduce launch overhead for repeated execution patterns |

### Minimal CUDA Kernel Example

```cpp
__global__ void add_vectors(const float* a, const float* b, float* out, int n) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        out[idx] = a[idx] + b[idx];
    }
}
```

This example is simple, but it shows the pattern:

- many threads launched at once
- each thread works on one slice of data
- boundary checks matter

### Practical AI Relevance

Understanding CUDA helps explain:

- why FlashAttention is faster
- why KV-cache layout matters
- why quantization can reduce cost dramatically
- why batching changes throughput
- why some models saturate memory before compute

### Profiling Mindset

Ask:

1. Is the workload compute-bound or memory-bound?
2. Are kernels too small or too fragmented?
3. Is data transfer dominating?
4. Is GPU utilization low because of the software stack above it?

---

## Quick Reference

| Question | Heuristic |
|---|---|
| Slow decode on large model | suspect memory bandwidth or KV-cache behavior |
| Low GPU utilization | inspect batching, kernel launch shape, or host-side bottlenecks |
| Model fits but still underperforms | profile memory movement, not just FLOPs |
| CPU-heavy preprocessing | may starve the GPU |
| Lots of tiny kernels | fusion or graph capture may help |

---

## Gotchas

- GPU utilization percentages are useful but incomplete.
- Compute throughput and memory throughput are different bottlenecks.
- Kernel-level optimization is usually wasted if the higher-level architecture is wrong.
- CUDA knowledge helps diagnosis, but not every team needs custom kernels.

---

## Interview Angles

- **Q**: Why are LLM decode steps often memory-bound?
- **A**: Each generated token requires repeatedly loading weights and KV-cache state, so memory movement can dominate arithmetic. That is why layout, caching, and serving-engine design matter so much.

- **Q**: What is the practical value of understanding CUDA for an AI engineer?
- **A**: It helps you reason about hardware bottlenecks, choose the right optimizations, and communicate effectively with systems or inference teams when performance issues appear.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Transformers](../foundations/transformers.md), [Inference Optimization](./inference-optimization.md) |
| Leads to | [Distributed Training for Large Models](../research-frontiers/distributed-training.md), advanced inference engineering |
| Compare with | CPU execution, high-level framework-only view |
| Cross-domain | computer architecture, compilers, HPC |

---

## Sources

- NVIDIA CUDA documentation
- NVIDIA Nsight documentation
- [Inference Optimization](./inference-optimization.md)
- FlashAttention papers and documentation
