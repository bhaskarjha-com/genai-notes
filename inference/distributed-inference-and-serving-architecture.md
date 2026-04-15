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

## ★ TL;DR
- **What**: The system design patterns used to scale inference across multiple machines and accelerators.
- **Why**: Large-model serving hits limits in memory, concurrency, and cost that one process or one GPU cannot handle cleanly.
- **Key point**: Distributed inference is about routing, sharding, batching, and locality as much as model execution itself.

---

## ★ Overview
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

## ★ Deep Dive
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

## ◆ Quick Reference
| Problem | First Architecture Move |
|---|---|
| one GPU cannot hold the model | use model sharding or a smaller/quantized model |
| traffic spikes | add queueing, autoscaling, and backpressure |
| long requests hurt everyone | isolate workloads or add length-aware scheduling |
| costs are unstable | add routing tiers and cache strategy |
| regional latency too high | consider multi-region serving |

---

## ○ Gotchas & Common Mistakes
- More replicas do not fix memory-fit problems.
- Throughput optimization can damage interactive latency.
- Cache design is often the hidden determinant of real performance.

---

## ○ Interview Angles
- **Q**: What is the difference between scaling replicas and sharding a model?
- **A**: Replica scaling duplicates the full serving stack to handle more requests, while model sharding splits one model across multiple devices because it is too large or too expensive to serve as one unit.

- **Q**: Why is KV-cache locality important?
- **A**: Because rebuilding or transferring cache state is costly. Good locality helps keep follow-up tokens and turns efficient instead of repeatedly paying for the same context.

---

## ★ Connections
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
# pip install vllm>=0.8
# ⚠️ Last tested: 2026-04 | Requires: vllm>=0.8

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


### Multi-GPU Health Monitor

```python
# ⚠️ Last tested: 2026-04 | Requires: nvidia-ml-py3 (pynvml), Python 3.10+
import pynvml
from dataclasses import dataclass

pynvml.nvmlInit()

@dataclass
class GPUHealth:
    index: int
    name: str
    temp_c: int
    utilization_pct: int
    memory_used_gb: float
    memory_total_gb: float
    power_w: float
    healthy: bool

def check_gpu_health(max_temp: int = 85, min_free_gb: float = 2.0) -> list[GPUHealth]:
    """Monitor all GPUs for distributed serving health checks."""
    count = pynvml.nvmlDeviceGetCount()
    results = []
    for i in range(count):
        h = pynvml.nvmlDeviceGetHandleByIndex(i)
        temp = pynvml.nvmlDeviceGetTemperature(h, pynvml.NVML_TEMPERATURE_GPU)
        util = pynvml.nvmlDeviceGetUtilizationRates(h)
        mem = pynvml.nvmlDeviceGetMemoryInfo(h)
        free_gb = (mem.total - mem.used) / (1024**3)
        results.append(GPUHealth(
            index=i, name=pynvml.nvmlDeviceGetName(h), temp_c=temp,
            utilization_pct=util.gpu,
            memory_used_gb=round(mem.used / (1024**3), 1),
            memory_total_gb=round(mem.total / (1024**3), 1),
            power_w=round(pynvml.nvmlDeviceGetPowerUsage(h) / 1000, 1),
            healthy=(temp < max_temp and free_gb > min_free_gb),
        ))
    return results

# for gpu in check_gpu_health():
#     s = "OK" if gpu.healthy else "ALERT"
#     print(f"GPU{gpu.index} [{s}]: {gpu.temp_c}C, {gpu.utilization_pct}% util, "
#           f"{gpu.memory_used_gb}/{gpu.memory_total_gb}GB")
# Expected output: Per-GPU health status with temperature, utilization, memory
```

### Prefill/Decode Disaggregation Router

```python
# ⚠️ Last tested: 2026-04 | Requires: Python 3.10+ (architecture pattern)
# P/D disaggregation: separate GPU pools for prefill (compute-bound) vs decode (memory-bound)
# Reference: DistServe (2024), Splitwise (2024)
from dataclasses import dataclass, field
from enum import Enum

class Phase(Enum):
    PREFILL = "prefill"
    DECODE = "decode"

@dataclass
class PDRouter:
    """Route LLM requests to specialized GPU pools by phase."""
    prefill_pool: list[str] = field(default_factory=lambda: ["gpu-0", "gpu-1"])
    decode_pool: list[str] = field(default_factory=lambda: ["gpu-2", "gpu-3", "gpu-4", "gpu-5"])
    _pf_idx: int = 0
    _dc_idx: int = 0

    def route(self, phase: Phase) -> str:
        if phase == Phase.PREFILL:
            w = self.prefill_pool[self._pf_idx % len(self.prefill_pool)]
            self._pf_idx += 1
            return w
        w = self.decode_pool[self._dc_idx % len(self.decode_pool)]
        self._dc_idx += 1
        return w

    def serve(self, input_tokens: int, output_tokens: int) -> dict:
        pf = self.route(Phase.PREFILL)
        dc = self.route(Phase.DECODE)
        pf_ms = input_tokens * 0.01
        dc_ms = output_tokens * 5.0
        return {"prefill": pf, "pf_ms": round(pf_ms, 1),
                "decode": dc, "dc_ms": round(dc_ms, 1),
                "total_ms": round(pf_ms + dc_ms, 1)}

router = PDRouter()
result = router.serve(input_tokens=2000, output_tokens=200)
print(f"Prefill: {result['prefill']} ({result['pf_ms']}ms)")
print(f"Decode:  {result['decode']} ({result['dc_ms']}ms)")
print(f"Total:   {result['total_ms']}ms")
# Expected output:
# Prefill: gpu-0 (20.0ms)
# Decode:  gpu-2 (1000.0ms)
# Total:   1020.0ms
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **KV-cache OOM** | Server rejects new requests, GPU memory exhausted | Too many concurrent long-context requests | Set max_model_len, implement request queuing, monitor cache utilization |
| **Tail latency spike** | P99 latency 10× worse than P50 | One long request blocks batch, straggler GPU | Length-aware scheduling, separate long/short request queues |
| **GPU fragmentation** | Low utilization despite high demand | Requests don't fill GPU batches efficiently | Dynamic batching (vLLM continuous batching), right-size GPU allocation |
| **Cascade failure** | All replicas go down simultaneously | Shared dependency failure, no circuit breakers | Health checks, circuit breakers, graceful degradation |
| **NCCL timeout** | Training/serving hangs silently for minutes | Network partition between GPUs, slow interconnect | NCCL timeout tuning, heartbeat monitoring, automatic restart |

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

### Exercise 2: Design a P/D Disaggregated Architecture

**Goal**: Design a serving system for a chat product with 10K concurrent users
**Time**: 30 minutes
**Steps**:
1. Given: average 500-token input, 200-token output, target P99 < 2s
2. Calculate: prefill compute budget vs decode memory budget
3. Determine: optimal GPU split (how many prefill vs decode workers?)
4. Draw: architecture diagram showing request flow and KV-cache transfer
**Expected Output**: Architecture diagram + capacity planning table

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
