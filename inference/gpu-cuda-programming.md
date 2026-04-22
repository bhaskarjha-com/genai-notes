---
title: "GPU & CUDA Programming for AI Engineers"
aliases: ["GPU", "CUDA", "GPU Programming"]
tags: [gpu, cuda, kernels, memory, performance, ai-infra, inference]
type: procedure
difficulty: expert
status: published
last_verified: 2026-04
parent: "inference-optimization.md"
related: ["../research-frontiers/distributed-training.md", "../production/model-serving.md", "../foundations/transformers.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# GPU & CUDA Programming for AI Engineers

> Modern AI depends on GPUs, but high-level frameworks hide the hardware until performance forces you to care. This note is about that moment.

---

## â˜… TL;DR
- **What**: The hardware and programming concepts behind GPU-accelerated AI workloads.
- **Why**: Many training and inference bottlenecks make sense only if you understand memory hierarchy, parallel execution, and kernel behavior.
- **Key point**: In AI systems, moving data efficiently is often harder than doing the math.

---

## â˜… Overview
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

## â˜… Deep Dive
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

## â—† Quick Reference
| Question | Heuristic |
|---|---|
| Slow decode on large model | suspect memory bandwidth or KV-cache behavior |
| Low GPU utilization | inspect batching, kernel launch shape, or host-side bottlenecks |
| Model fits but still underperforms | profile memory movement, not just FLOPs |
| CPU-heavy preprocessing | may starve the GPU |
| Lots of tiny kernels | fusion or graph capture may help |

---

## â—‹ Gotchas & Common Mistakes
- GPU utilization percentages are useful but incomplete.
- Compute throughput and memory throughput are different bottlenecks.
- Kernel-level optimization is usually wasted if the higher-level architecture is wrong.
- CUDA knowledge helps diagnosis, but not every team needs custom kernels.

---

## â—‹ Interview Angles
- **Q**: Why are LLM decode steps often memory-bound?
- **A**: Each generated token requires repeatedly loading weights and KV-cache state, so memory movement can dominate arithmetic. That is why layout, caching, and serving-engine design matter so much.

- **Q**: What is the practical value of understanding CUDA for an AI engineer?
- **A**: It helps you reason about hardware bottlenecks, choose the right optimizations, and communicate effectively with systems or inference teams when performance issues appear.

---

## â˜… Connections
| Relationship | Topics |
|---|---|
| Builds on | [Transformers](../foundations/transformers.md), [Inference Optimization](./inference-optimization.md) |
| Leads to | [Distributed Training for Large Models](../research-frontiers/distributed-training.md), advanced inference engineering |
| Compare with | CPU execution, high-level framework-only view |
| Cross-domain | computer architecture, compilers, HPC |

---

## â˜… Code & Implementation

### GPU Memory Profiling with PyTorch

```python
# pip install torch>=2.0
# âš ï¸ Last tested: 2026-04 | Requires: torch>=2.0

import torch

def gpu_memory_report():
    """Print current GPU memory usage."""
    if not torch.cuda.is_available():
        print("No GPU available")
        return
    
    allocated = torch.cuda.memory_allocated() / 1e9
    reserved = torch.cuda.memory_reserved() / 1e9
    max_allocated = torch.cuda.max_memory_allocated() / 1e9
    total = torch.cuda.get_device_properties(0).total_mem / 1e9
    
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    print(f"Allocated: {allocated:.2f} GB")
    print(f"Reserved:  {reserved:.2f} GB")
    print(f"Peak:      {max_allocated:.2f} GB")
    print(f"Total:     {total:.2f} GB")
    print(f"Free:      {total - reserved:.2f} GB")

# Example: profile loading a model
from transformers import AutoModelForCausalLM

gpu_memory_report()  # Before
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-3.1-8B", torch_dtype=torch.bfloat16, device_map="cuda"
)
gpu_memory_report()  # After

# Expected output:
# GPU: NVIDIA A100 80GB
# Allocated: 15.20 GB  (8B params Ã— 2 bytes)
# Reserved:  16.00 GB
# Peak:      15.20 GB
# Total:     80.00 GB
# Free:      64.00 GB
```

---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **CUDA OOM** | `RuntimeError: CUDA out of memory` | Model + activations + KV-cache exceed GPU memory | Reduce batch size, enable gradient checkpointing, use quantization |
| **Memory-bound decode** | Low GPU compute utilization, high memory bandwidth usage | Each token loads full KV-cache, bottlenecked by HBM bandwidth | Use FlashAttention, PagedAttention (vLLM), quantized KV-cache |
| **Kernel launch overhead** | Many tiny operations, GPU mostly idle | Thousands of small kernels with CPU launch overhead | CUDA graphs, kernel fusion, torch.compile |
| **PCIe bottleneck** | CPU preprocessing faster than GPU transfer | Large data transfers over PCIe instead of NVLink | Prefetch data, pin memory, overlap transfer with compute |

---

## â—† Hands-On Exercises

### Exercise 1: GPU Memory Estimation

**Goal**: Build intuition for GPU memory requirements
**Time**: 20 minutes
**Steps**:
1. Calculate memory for a 7B model in fp32, fp16, int8, and int4
2. With the model loaded in bf16, estimate remaining memory for KV-cache
3. Calculate max batch size Ã— sequence length that fits in remaining memory
4. Compare your estimates with actual usage using the profiling code above
**Expected Output**: Memory estimation table matching real GPU measurements within 10%

---

## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸŽ“ Course | [NVIDIA CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/) | Official reference for CUDA concepts and programming model |
| ðŸŽ“ Course | [Stanford CS149: Parallel Computing](http://cs149.stanford.edu/) | Deep dive into GPU parallelism, memory hierarchy, and scheduling |
| ðŸ“„ Paper | [Dao et al. "FlashAttention" (2022)](https://arxiv.org/abs/2205.14135) | Shows how IO-aware kernel design transforms attention performance |
| ðŸ”§ Hands-on | [NVIDIA Nsight Systems / Compute](https://developer.nvidia.com/nsight-systems) | Essential GPU profiling tools for identifying bottlenecks |
| ðŸŽ¥ Video | [Jeremy Howard â€” "CUDA Programming" (fast.ai)](https://course.fast.ai/) | Practical introduction to CUDA for ML engineers |

---

## â˜… Sources

- NVIDIA CUDA Programming Guide â€” https://docs.nvidia.com/cuda/
- NVIDIA Nsight Documentation â€” https://developer.nvidia.com/nsight-systems
- Dao et al. "FlashAttention: Fast and Memory-Efficient Exact Attention" (2022)
- [Inference Optimization](./inference-optimization.md)
