---
title: "Distributed Inference & Serving Architecture"
tags: [distributed-inference, serving, scaling, kv-cache, architecture, inference]
type: reference
difficulty: expert
status: published
last_verified: 2026-04
parent: "inference-optimization.md"
related: ["gpu-cuda-programming.md", "../production/model-serving.md", "../tools-and-infra/distributed-systems-for-ai.md", "../production/latency-and-throughput-engineering.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Distributed Inference & Serving Architecture

> Serving one model call is straightforward. Serving many users, many models, and long contexts at acceptable latency is an architecture problem.

---

## TL;DR

- **What**: The system design patterns used to scale inference across multiple machines and accelerators.
- **Why**: Large-model serving hits limits in memory, concurrency, and cost that one process or one GPU cannot handle cleanly.
- **Key point**: Distributed inference is about routing, sharding, batching, and locality as much as model execution itself.

---

## Overview

### Definition

**Distributed inference** is the execution of inference workloads across multiple processes, machines, or accelerators while coordinating requests, model state, and performance goals.

### Scope

This note covers the architecture view of scaled serving, not the internals of any one engine.

### Significance

- Large production LLM services are distributed by necessity.
- Cost, latency, and availability are inseparable at this layer.
- This topic sits between inference optimization and platform engineering.

### Prerequisites

- [Inference Optimization](./inference-optimization.md)
- [Model Serving for LLM Applications](../production/model-serving.md)
- [Distributed Systems Fundamentals for AI](../tools-and-infra/distributed-systems-for-ai.md)

---

## Deep Dive

### Common Distributed Serving Shapes

| Pattern | Why Teams Use It |
|---|---|
| **Replica scaling** | more copies for more traffic |
| **Model sharding** | fit larger models across multiple GPUs |
| **Request routing** | send traffic by tenant, model, region, or workload |
| **Batch workers** | improve hardware utilization |
| **Multi-tier routing** | cheap path for easy tasks, strong path for hard tasks |

### Core Architectural Questions

1. Does the model fit on one GPU or need sharding?
2. Are requests interactive or batch?
3. How much context and KV-cache growth should the system support?
4. How should overload be handled?
5. What locality matters: model, cache, tenant, or region?

### Request Path Example

```text
client
-> gateway
-> router
-> queue or scheduler
-> inference workers
-> cache / state tracking
-> streaming response
```

### What Makes This Hard

| Challenge | Why It Hurts |
|---|---|
| **KV-cache locality** | moving or rebuilding cache is expensive |
| **Uneven request lengths** | long requests create tail latency |
| **Burst traffic** | overload spreads quickly across the cluster |
| **Multi-model fleets** | capacity planning becomes messy |
| **GPU fragmentation** | expensive hardware gets stranded inefficiently |

### Important Patterns

- separate interactive and batch workloads
- keep hot models warm
- use routing to avoid unnecessary expensive paths
- stream where user experience benefits
- apply backpressure before the cluster collapses

### Multi-Region Thinking

Teams may distribute inference across regions for:

- lower latency
- resilience
- data-governance boundaries

That introduces trade-offs in cache reuse, model synchronization, and observability.

### Design Heuristics

1. Keep the serving topology simpler than you think you need at first.
2. Avoid mixing all workload types on the same critical path.
3. Monitor tail latency, queue depth, and GPU utilization together.
4. Treat routing policy as a product and cost lever.
5. Plan failure behavior explicitly.

---

## Quick Reference

| Problem | First Architecture Move |
|---|---|
| one GPU cannot hold the model | use model sharding or a smaller/quantized model |
| traffic spikes | add queueing, autoscaling, and backpressure |
| long requests hurt everyone | isolate workloads or add length-aware scheduling |
| costs are unstable | add routing tiers and cache strategy |
| regional latency too high | consider multi-region serving |

---

## Gotchas

- More replicas do not fix memory-fit problems.
- Throughput optimization can damage interactive latency.
- Cache design is often the hidden determinant of real performance.

---

## Interview Angles

- **Q**: What is the difference between scaling replicas and sharding a model?
- **A**: Replica scaling duplicates the full serving stack to handle more requests, while model sharding splits one model across multiple devices because it is too large or too expensive to serve as one unit.

- **Q**: Why is KV-cache locality important?
- **A**: Because rebuilding or transferring cache state is costly. Good locality helps keep follow-up tokens and turns efficient instead of repeatedly paying for the same context.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Inference Optimization](./inference-optimization.md), [Model Serving for LLM Applications](../production/model-serving.md), [Distributed Systems Fundamentals for AI](../tools-and-infra/distributed-systems-for-ai.md) |
| Leads to | inference platform engineering, serving optimization |
| Compare with | single-node serving |
| Cross-domain | queueing, scheduling, cluster design |

---

## ★ Code & Implementation

### vLLM Distributed Serving

```python
# pip install vllm>=0.6
# ⚠️ Last tested: 2026-04 | Requires: vllm>=0.6

# Launch vLLM with tensor parallelism across 4 GPUs
# Command line:
# python -m vllm.entrypoints.openai.api_server \
#     --model meta-llama/Llama-3.1-70B-Instruct \
#     --tensor-parallel-size 4 \
#     --max-model-len 8192 \
#     --gpu-memory-utilization 0.9 \
#     --port 8000

# Python client (OpenAI-compatible API)
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="unused")
response = client.chat.completions.create(
    model="meta-llama/Llama-3.1-70B-Instruct",
    messages=[{"role": "user", "content": "Explain KV-cache in 2 sentences."}],
    max_tokens=100,
)
print(response.choices[0].message.content)
# Expected: Served across 4 GPUs with automatic tensor parallelism
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **KV-cache OOM** | Server rejects new requests, GPU memory exhausted | Too many concurrent long-context requests | Set max_model_len, implement request queuing, monitor cache utilization |
| **Tail latency spike** | P99 latency 10× worse than P50 | One long request blocks batch, straggler GPU | Length-aware scheduling, separate long/short request queues |
| **GPU fragmentation** | Low utilization despite high demand | Requests don't fill GPU batches efficiently | Dynamic batching (vLLM continuous batching), right-size GPU allocation |
| **Cascade failure** | All replicas go down simultaneously | Shared dependency failure, no circuit breakers | Health checks, circuit breakers, graceful degradation |

---

## ◆ Hands-On Exercises

### Exercise 1: Benchmark Serving Throughput

**Goal**: Compare single-GPU vs multi-GPU serving performance
**Time**: 45 minutes
**Steps**:
1. Deploy a 7B model on 1 GPU with vLLM, benchmark with 100 concurrent requests
2. Deploy the same model on 2 GPUs with tensor parallelism, repeat benchmark
3. Measure: throughput (tokens/sec), P50/P95/P99 latency, GPU utilization
4. Analyze: when does adding GPUs help vs hurt?
**Expected Output**: Throughput/latency comparison table, scaling efficiency analysis

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [vLLM Documentation](https://docs.vllm.ai/) | Best open-source LLM serving engine — PagedAttention, continuous batching |
| 🔧 Hands-on | [TGI Documentation](https://huggingface.co/docs/text-generation-inference/) | HuggingFace’s production serving engine |
| 📄 Paper | [Kwon et al. "PagedAttention" (vLLM, 2023)](https://arxiv.org/abs/2309.06180) | The paper that revolutionized KV-cache management for LLM serving |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 8 | Covers serving architecture, batching, and scaling patterns |

---

## ★ Sources

- vLLM documentation — https://docs.vllm.ai/
- TGI documentation — https://huggingface.co/docs/text-generation-inference/
- [Inference Optimization](./inference-optimization.md)
- [Distributed Systems Fundamentals for AI](../tools-and-infra/distributed-systems-for-ai.md)
