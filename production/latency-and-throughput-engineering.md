---
title: "Latency & Throughput Engineering for AI Systems"
tags: [latency, throughput, performance, queueing, production, llmops]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "[[llmops]]"
related: ["[[model-serving]]", "[[cost-optimization]]", "[[monitoring-observability]]", "[[../inference/distributed-inference-and-serving-architecture]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# Latency & Throughput Engineering for AI Systems

> ✨ **Bit**: Little's Law (L = λW) is the universal truth of performance engineering — "the average number of items in a system equals the arrival rate multiplied by the average time each item spends in the system." If you remember one formula from this note, make it this one.

---

## ★ TL;DR

- **What**: The engineering discipline of measuring, budgeting, and optimizing response time (latency) and work capacity (throughput) in AI systems
- **Why**: A model that's 10% smarter but 3× slower loses in production every time. Users abandon after 2-3 seconds.
- **Key point**: Optimize against explicit latency budgets and mathematical models (Little's Law, Amdahl's Law), not intuition. Measure tail latency (P95/P99), not averages.

---

## ★ Overview

### Definition

**Latency** is how long one request takes (typically measured as Time To First Token (TTFT) and Total Generation Time). **Throughput** is how many requests the system completes per unit time (requests/second or tokens/second). These are the two fundamental dimensions of AI system performance.

### Scope

Covers: End-to-end AI performance engineering including latency budgets, queuing theory, mathematical foundations, instrumentation, and optimization strategies. For model-level inference optimization (quantization, batching), see [Inference Optimization](../inference/inference-optimization.md). For serving infrastructure, see [Model Serving](./model-serving.md).

### Significance

- **User experience cliff**: Studies show users abandon AI interactions after 2-3 seconds of waiting. TTFT < 500ms is the standard for acceptable latency.
- **Cost-performance tradeoff**: Faster inference ≠ cheaper inference. Understanding this tradeoff is a core production engineering skill.
- **Interview-critical**: System design interviews for any ML/AI infrastructure role expect quantitative latency/throughput reasoning.

### Prerequisites

- [Model Serving for LLM Applications](./model-serving.md) — serving infrastructure basics
- [Monitoring & Observability for GenAI Systems](./monitoring-observability.md) — how to measure these metrics
- [Distributed Inference & Serving Architecture](../inference/distributed-inference-and-serving-architecture.md) — multi-GPU serving

---

## ★ Deep Dive

### The Two-Phase Nature of LLM Latency

LLM inference has two distinct phases, each with different bottlenecks:

```
REQUEST LIFECYCLE:

                    ┌────── Prefill Phase ──────┐┌──── Decode Phase ────────────┐
                    │                           ││                              │
User sends ───► [Gateway] ──► [Retrieval] ──► [Prompt Assembly] ──► [PREFILL] ──► [DECODE tok1, tok2, ...tokN] ──► Response
   request        ~50ms         ~150ms           ~50ms              ~400ms              ~1200ms (N tokens)
                    │                                               │                  │
                    │                                               │                  │
                    │                                          COMPUTE-BOUND      MEMORY-BOUND
                    │                                          (batch-friendly)   (bandwidth-limited)
                    └───────────────────────────────────────────────────────────────────┘
                                        Total End-to-End Latency: ~1900ms
```

| Phase | What Happens | Bottleneck | Key Metric |
|-------|-------------|------------|------------|
| **Prefill** | Process entire input prompt at once | Compute (FLOPs) | Time To First Token (TTFT) |
| **Decode** | Generate tokens one-by-one, autoregressively | Memory bandwidth (KV cache reads) | Time Per Output Token (TPOT) |

**Why this matters**: Optimizing prefill (e.g., Flash Attention) has zero effect on decode speed. Different bottlenecks need different solutions.

### Mathematical Foundations

#### Little's Law: L = λW

The single most important formula in performance engineering:

```
L = λ × W

Where:
  L = average number of requests in the system (queue + being served)
  λ = arrival rate (requests/second)
  W = average time a request spends in the system (seconds)
```

**Worked Example — LLM Serving Capacity**:

```
Given:
  - Average request latency (W) = 2 seconds
  - GPU can handle 8 concurrent requests (L = 8)

Question: What is the maximum throughput?

  λ = L / W = 8 / 2 = 4 requests/second

If arrival rate exceeds 4 req/s → queue grows → latency increases → system degrades.

To serve 10 req/s with the same latency:
  L = λ × W = 10 × 2 = 20 concurrent slots needed
  → Need 20/8 = 2.5 → 3 GPUs minimum
```

#### Amdahl's Law for AI Pipelines

```
Speedup = 1 / ((1 - P) + P/S)

Where:
  P = fraction of time spent in the parallelizable/optimizable component
  S = speedup factor achieved in that component
```

**Worked Example — Is Model Optimization Worth It?**:

```
Your pipeline: Gateway(5%) + Retrieval(15%) + Model(70%) + Post-process(10%)

If you make the model 2× faster:
  Speedup = 1 / ((1 - 0.70) + 0.70/2)
          = 1 / (0.30 + 0.35)
          = 1 / 0.65
          = 1.54× speedup (not 2×!)

If you make the model 10× faster:
  Speedup = 1 / (0.30 + 0.07) = 2.7× speedup (not 10×!)

Lesson: Once model is fast enough, retrieval/gateway become the bottleneck.
There's a ceiling on total speedup based on the non-optimized fraction.
```

#### Queuing Theory: M/M/1 Queue Basics

```
For a single-server queue with Poisson arrivals:

  ρ = λ/μ                    (utilization: arrival rate / service rate)
  Lq = ρ²/(1-ρ)             (average queue length)
  Wq = ρ/(μ(1-ρ))           (average wait time in queue)

Key insight: As utilization (ρ) approaches 1.0, queue length explodes:

  ρ = 0.5  →  Lq = 0.5     (manageable)
  ρ = 0.8  →  Lq = 3.2     (getting crowded)
  ρ = 0.9  →  Lq = 8.1     (dangerous)
  ρ = 0.95 →  Lq = 18.1    (system failing)

  ┌────────────────────────────────────────────┐
  │ Queue Length                                │
  │  20│                                   *   │
  │    │                                  *    │
  │  15│                                 *     │
  │    │                                *      │
  │  10│                              *        │
  │    │                           *           │
  │   5│                       *               │
  │    │                 *                      │
  │   0│ * * * * * *                            │
  │    └──────────────────────────────────────  │
  │     0.1 0.3 0.5 0.7 0.8 0.9 0.95  1.0     │
  │              Utilization (ρ)                │
  └────────────────────────────────────────────┘

RULE OF THUMB: Never run GPU utilization above 80-85% for latency-sensitive
AI workloads. The queue explosion above 90% will destroy your P99 latency.
```

### Latency Budget Breakdown

A real latency budget for a production RAG chatbot:

```
┌─────────────────────────────────────────────────────────────────┐
│                    LATENCY BUDGET: 3000ms                       │
├──────────────────┬────────────┬──────────────────────────────────┤
│ Stage            │ Budget     │ Key Optimization                 │
├──────────────────┼────────────┼──────────────────────────────────┤
│ API Gateway      │   30ms     │ Connection pooling, edge routing │
│ Auth + Rate Limit│   20ms     │ Token validation cache           │
│ Embedding query  │   50ms     │ Batch, local model, cache        │
│ Vector search    │  100ms     │ HNSW index, pre-filter           │
│ Reranking        │  100ms     │ Cross-encoder or small model     │
│ Prompt assembly  │   50ms     │ Template caching, trim context   │
│ === PREFILL ===  │  400ms     │ Flash Attention, shorter context │
│ === DECODE ===   │ 2000ms     │ Speculative decoding, KV cache   │
│ Post-processing  │   50ms     │ Structured output, streaming     │
│ Response         │   50ms     │ Compression, HTTP/2              │
├──────────────────┼────────────┼──────────────────────────────────┤
│ TOTAL BUDGET     │ 2850ms     │ 150ms margin for variance        │
└──────────────────┴────────────┴──────────────────────────────────┘
```

### Tail Latency: Why P99 Matters More Than Averages

```
Distribution of request latencies (typical LLM serving):

  Count │
   200  │ ████
   150  │ ████████
   100  │ ████████████
    50  │ ████████████████████
        │ ████████████████████████████         long tail →→→
     0  └─────────────────────────────────── • • • • •
        200  500  1000  1500  2000  3000  5000  8000ms

  P50 = 800ms   ← "typical" request
  P95 = 2500ms  ← 1 in 20 requests
  P99 = 5000ms  ← 1 in 100 requests

Why tail matters:
  - A page showing 10 AI components → P(all fast) = 0.95^10 = 60%
  - 40% of page loads hit at least one slow component
  - User experience is defined by the slowest component
```

### Performance Optimization Levers

| Category | Lever | Latency Impact | Throughput Impact | Trade-off |
|----------|-------|:-------------:|:-----------------:|-----------|
| **Model** | Smaller model / model routing | ⬇️⬇️⬇️ | ⬆️⬆️⬆️ | Quality loss |
| **Model** | Quantization (FP16→INT8→INT4) | ⬇️⬇️ | ⬆️⬆️ | Slight quality loss |
| **Model** | Speculative decoding | ⬇️⬇️ | ⬆️ | Complexity, draft model needed |
| **Serving** | Continuous batching (vLLM) | ⬆️ (slightly) | ⬆️⬆️⬆️ | More complex serving |
| **Serving** | KV cache optimization | ⬇️ | ⬆️⬆️ | Memory management |
| **Caching** | Semantic cache (exact/similar) | ⬇️⬇️⬇️ | ⬆️⬆️⬆️ | Stale results, cache invalidation |
| **Caching** | KV cache reuse (prompt prefix) | ⬇️⬇️ | ⬆️ | Memory usage |
| **Request** | Context window trimming | ⬇️⬇️ | ⬆️⬆️ | Information loss |
| **Request** | Streaming | Perceived ⬇️⬇️⬇️ | Neutral | No actual compute savings |
| **Infra** | GPU upgrade (A100→H100) | ⬇️⬇️ | ⬆️⬆️⬆️ | Cost |
| **Infra** | Autoscaling | ⬇️ (at tail) | ⬆️⬆️ | Cold start latency |
| **Architecture** | Async/offline split | ⬇️⬇️⬇️ (user path) | Neutral | Delayed results |

---

## ★ Code & Implementation

### Latency Instrumentation with OpenTelemetry

```python
# pip install opentelemetry-api>=1.20 opentelemetry-sdk>=1.20
# ⚠️ Last tested: 2026-04 | Requires: opentelemetry-api>=1.20

import time
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import SimpleSpanProcessor, ConsoleSpanExporter

# Setup tracer
provider = TracerProvider()
provider.add_span_processor(SimpleSpanProcessor(ConsoleSpanExporter()))
trace.set_tracer_provider(provider)
tracer = trace.get_tracer("ai-pipeline")

def instrumented_rag_pipeline(query: str):
    """Full RAG pipeline with per-stage latency measurement."""
    with tracer.start_as_current_span("rag_pipeline") as root_span:
        root_span.set_attribute("query_length", len(query))
        
        # Stage 1: Embedding
        with tracer.start_as_current_span("embed_query") as span:
            t0 = time.perf_counter()
            query_embedding = embed(query)  # Your embedding function
            embed_ms = (time.perf_counter() - t0) * 1000
            span.set_attribute("latency_ms", embed_ms)
        
        # Stage 2: Vector search
        with tracer.start_as_current_span("vector_search") as span:
            t0 = time.perf_counter()
            docs = vector_db.search(query_embedding, k=5)
            search_ms = (time.perf_counter() - t0) * 1000
            span.set_attribute("latency_ms", search_ms)
            span.set_attribute("docs_retrieved", len(docs))
        
        # Stage 3: LLM generation
        with tracer.start_as_current_span("llm_generate") as span:
            t0 = time.perf_counter()
            response = llm.generate(prompt=build_prompt(query, docs))
            gen_ms = (time.perf_counter() - t0) * 1000
            span.set_attribute("latency_ms", gen_ms)
            span.set_attribute("tokens_generated", response.usage.completion_tokens)
        
        # Log the budget breakdown
        total_ms = embed_ms + search_ms + gen_ms
        root_span.set_attribute("total_latency_ms", total_ms)
        root_span.set_attribute("budget_breakdown", {
            "embed": f"{embed_ms:.0f}ms",
            "search": f"{search_ms:.0f}ms",
            "generate": f"{gen_ms:.0f}ms",
        })
        
        return response

# Expected output:
# Trace with nested spans showing per-stage latency:
#   rag_pipeline (total: 1850ms)
#   ├── embed_query (45ms)
#   ├── vector_search (95ms)
#   └── llm_generate (1710ms)
```

### P95/P99 Latency Computation

```python
# pip install numpy>=1.24
# ⚠️ Last tested: 2026-04 | Requires: numpy>=1.24

import numpy as np
from collections import deque
import time

class LatencyTracker:
    """Sliding-window latency tracker with percentile computation."""
    
    def __init__(self, window_size: int = 1000):
        self.latencies = deque(maxlen=window_size)
    
    def record(self, latency_ms: float):
        self.latencies.append(latency_ms)
    
    def percentile(self, p: float) -> float:
        if not self.latencies:
            return 0.0
        return float(np.percentile(list(self.latencies), p))
    
    def report(self) -> dict:
        if not self.latencies:
            return {}
        data = list(self.latencies)
        return {
            "count": len(data),
            "p50": f"{np.percentile(data, 50):.0f}ms",
            "p95": f"{np.percentile(data, 95):.0f}ms",
            "p99": f"{np.percentile(data, 99):.0f}ms",
            "max": f"{max(data):.0f}ms",
            "mean": f"{np.mean(data):.0f}ms",
        }

# Usage
tracker = LatencyTracker(window_size=1000)

# Simulate 100 requests with realistic LLM latency distribution
np.random.seed(42)
for _ in range(100):
    # Log-normal distribution (common for LLM latencies)
    latency = np.random.lognormal(mean=7.0, sigma=0.5)  # ~1100ms median
    tracker.record(latency)

print(tracker.report())
# Expected output:
# {'count': 100, 'p50': '1100ms', 'p95': '2450ms', 'p99': '3200ms', 'max': '4100ms', 'mean': '1290ms'}
```

### Capacity Planning Calculator

```python
# No external dependencies required
# ⚠️ Last tested: 2026-04

def capacity_plan(
    target_rps: float,        # Desired requests per second
    avg_latency_s: float,     # Average request latency (seconds)
    max_concurrent: int,      # Max concurrent requests per GPU
    target_utilization: float = 0.80,  # Target GPU utilization (keep < 85%)
) -> dict:
    """
    Calculate GPU requirements using Little's Law.
    
    Little's Law: L = λ × W
    Where L = concurrent requests, λ = arrival rate, W = avg time in system
    """
    # Required concurrency (Little's Law)
    required_concurrent = target_rps * avg_latency_s
    
    # GPUs needed at target utilization
    effective_capacity_per_gpu = max_concurrent * target_utilization
    gpus_needed = required_concurrent / effective_capacity_per_gpu
    
    # Actual throughput per GPU
    actual_throughput_per_gpu = effective_capacity_per_gpu / avg_latency_s
    
    import math
    return {
        "required_concurrent_slots": round(required_concurrent, 1),
        "gpus_needed": math.ceil(gpus_needed),
        "actual_throughput_per_gpu": round(actual_throughput_per_gpu, 1),
        "total_capacity_rps": round(math.ceil(gpus_needed) * actual_throughput_per_gpu, 1),
        "headroom_percent": round((1 - target_utilization) * 100),
    }

# Example: RAG chatbot capacity planning
result = capacity_plan(
    target_rps=50,           # 50 requests/second peak
    avg_latency_s=2.0,      # 2 second average response
    max_concurrent=8,        # vLLM with 8 concurrent slots
    target_utilization=0.80  # 80% utilization ceiling
)
print(result)
# Expected output:
# {'required_concurrent_slots': 100.0, 'gpus_needed': 16,
#  'actual_throughput_per_gpu': 3.2, 'total_capacity_rps': 51.2,
#  'headroom_percent': 20}
```

---

## ◆ Formulas & Equations

| Name | Formula | Variables | Use |
|------|---------|-----------|-----|
| **Little's Law** | $L = \lambda W$ | L = items in system, λ = arrival rate, W = avg time | Capacity planning, queue sizing |
| **Amdahl's Law** | $S = \frac{1}{(1-P) + P/S_p}$ | P = parallel fraction, S_p = speedup of that fraction | Estimating optimization ceiling |
| **Utilization** | $\rho = \lambda / \mu$ | λ = arrival rate, μ = service rate | GPU load assessment |
| **Queue wait** | $W_q = \frac{\rho}{\mu(1-\rho)}$ | M/M/1 queue | Predicting wait times under load |
| **Tokens/sec** | $T = \frac{\text{output\_tokens}}{\text{decode\_time}}$ | Per-request decode throughput | Model speed comparison |
| **TTFT** | $\text{TTFT} = t_{\text{prefill}} + t_{\text{queue}}$ | Time to first token | User-perceived responsiveness |
| **Total latency** | $t = \text{TTFT} + n \times \text{TPOT}$ | n = output tokens, TPOT = time per output token | End-to-end request time |

---

## ◆ Quick Reference

```
LATENCY TARGETS (production AI chatbot, 2026):
  TTFT (Time To First Token):  < 500ms
  TPOT (Time Per Output Token): < 30ms
  Total response (500 tokens):  < 3000ms
  P99 / P50 ratio:              < 3×

CAPACITY PLANNING CHEAT SHEET:
  1. Little's Law:        L = λ × W
  2. Never exceed 85% GPU utilization for latency-sensitive workloads
  3. Plan for 2× peak traffic (burst headroom)
  4. Budget 150ms margin for variance in latency budget

OPTIMIZATION PRIORITY ORDER:
  1. Measure (instrument everything first)
  2. Cache (cheapest latency win)
  3. Route (use smaller model when possible)
  4. Trim context (less input = faster prefill)
  5. Batch (improve throughput)
  6. Scale (add hardware last)
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **KV cache OOM** | Sudden 500 errors under load, GPU memory exhaustion | Long context + high concurrency fills GPU memory | Set max_model_len in vLLM, implement request queue with admission control |
| **Head-of-line blocking** | One slow request blocks all others, cascade failures | Long-running generation blocks batch slots | Continuous batching (vLLM), preemption for long requests, per-request timeout |
| **Cold start spikes** | First requests after deploy take 5-10× longer | Model loading, JIT compilation, cache warming | Warm-up requests on deploy, pre-load models, readiness probes |
| **Queue explosion** | P99 latency grows exponentially, timeouts cascade | Arrival rate exceeds service rate (ρ > 0.95) | Autoscaling with queue-depth trigger, load shedding, rate limiting per-user |
| **Tail latency amplification** | Good P50 but terrible P99 | Variable input lengths, GC pauses, noisy neighbors | Hedged requests, latency-based routing, dedicated GPU pools |
| **Streaming disconnect** | Partial responses, user sees truncated output | Network timeout during long generation, proxy buffering | Keep-alive headers, chunked transfer encoding, client retry with offset |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Optimizing averages, not tails**: A P50 of 500ms means nothing if P99 is 8000ms. Always measure and optimize tail latency.
- ⚠️ **Faster model ≠ faster system**: Amdahl's Law applies — if the model is 70% of latency, making it 2× faster only gives 1.5× total speedup.
- ⚠️ **Over-batching kills interactivity**: Large batches improve throughput but hurt individual request latency. Balance batch size against SLA.
- ⚠️ **Streaming hides latency, doesn't fix it**: TTFT improves perceived responsiveness, but total compute time and cost remain the same.
- ⚠️ **GPU utilization > 85% is a trap**: Queuing theory shows queue length explodes non-linearly above 85% utilization. Budget headroom.
- ⚠️ **Ignoring the retrieval phase**: Teams optimize model speed while retrieval (vector search, reranking) silently accounts for 15-25% of total latency.

---

## ○ Interview Angles

- **Q**: What is the difference between latency and throughput, and when do they conflict?
- **A**: Latency is the time a single request takes from submission to completion. Throughput is the total work the system handles per unit time (req/s or tokens/s). They conflict because optimizing throughput often means larger batch sizes and higher GPU utilization, which increases queuing time and thus individual request latency. In production, you typically set a latency SLA first (e.g., P95 < 2s), then maximize throughput within that constraint. The mathematical relationship is captured by Little's Law: L = λW — at a given concurrency level (L), you can trade latency (W) for throughput (λ) and vice versa.

- **Q**: Why is P95/P99 latency more important than average latency in AI systems?
- **A**: Because user experience is defined by the slowest interaction, not the average one. If your P50 is 800ms but P99 is 5000ms, then 1 in 100 users waits 5+ seconds — and those users remember. It gets worse with fan-out: a page showing 10 AI-powered components has a 40% chance that at least one component hits P95 latency (0.95^10 = 0.60, so 40% chance of at least one slow response). Furthermore, tail latency often reveals systemic issues (garbage collection, memory pressure, noisy neighbors) that averages hide. In system design interviews, always say "I'd measure P95 and P99" — it signals production experience.

- **Q**: How would you capacity-plan an LLM serving system for 50 requests/second?
- **A**: I'd use Little's Law. If average latency is 2 seconds and each GPU handles 8 concurrent requests at 80% utilization (to avoid queue explosion), then: Required concurrency = λ × W = 50 × 2 = 100 concurrent slots. Effective capacity per GPU = 8 × 0.8 = 6.4. GPUs needed = 100 / 6.4 = 16 GPUs. I'd add 20% headroom for traffic bursts, so 19-20 GPUs. Then I'd validate with load testing, watching P99 latency and queue depth to confirm the model holds under realistic traffic patterns.

---

## ◆ Hands-On Exercises

### Exercise 1: Latency Budget Analysis

**Goal**: Break down an AI pipeline into stages and identify the bottleneck
**Time**: 30 minutes
**Steps**:
1. Instrument a simple RAG pipeline (embedding → search → LLM) with `time.perf_counter()` timing
2. Run 50 requests and record per-stage latency
3. Create a latency budget table (like the one in Deep Dive)
4. Apply Amdahl's Law: What's the maximum total speedup if you make the LLM 5× faster?
**Expected Output**: Budget table showing stage breakdown, Amdahl's Law calculation showing the speedup ceiling

### Exercise 2: Queue Explosion Simulation

**Goal**: Observe how queue length explodes as utilization approaches 1.0
**Time**: 20 minutes
**Steps**:
1. Implement the M/M/1 queue formula: Lq = ρ²/(1-ρ)
2. Plot queue length vs utilization for ρ = 0.1 to 0.99
3. Find the utilization level where queue length exceeds 10
4. Explain why GPU utilization > 85% is dangerous for latency-sensitive workloads
**Expected Output**: Plot showing hockey stick curve, identified threshold (~0.91), written explanation

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Model Serving](./model-serving.md), [Distributed Inference](../inference/distributed-inference-and-serving-architecture.md), [Monitoring & Observability](./monitoring-observability.md) |
| Leads to | [Cost Optimization](./cost-optimization.md) (latency-cost tradeoff), [AI System Design](./ai-system-design.md) (design for performance) |
| Compare with | Raw benchmark speed (ignores system-level effects), [Inference Optimization](../inference/inference-optimization.md) (model-level, not system-level) |
| Cross-domain | SRE (Google SRE Book Ch 4-5), Queuing theory, Network engineering, Database performance tuning |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "Designing Data-Intensive Applications" by Kleppmann, Ch 1 (Reliability, Scalability) | The definitive treatment of latency percentiles and tail latency amplification |
| 📘 Book | Google SRE Book, Ch 4-5 (SLOs, Latency) | Industry standard for setting and measuring latency targets |
| 📄 Paper | "The Tail at Scale" by Dean & Barroso (2013) | Google's seminal paper on why tail latency matters and how to mitigate it |
| 🎥 Video | [Gil Tene — "How NOT to Measure Latency"](https://www.youtube.com/watch?v=lJ8ydIuPFeU) | Eye-opening talk on coordinated omission and latency measurement pitfalls |
| 📄 Paper | [vLLM: Efficient Memory Management for LLM Serving](https://arxiv.org/abs/2309.06180) — Sections 3-4 | PagedAttention and continuous batching — the mechanisms behind LLM throughput optimization |
| 🔧 Hands-on | [Locust load testing tool](https://locust.io/) | Python-based load testing for benchmarking AI API latency under realistic conditions |
| 🎓 Course | [MIT 6.172: Performance Engineering of Software Systems](https://ocw.mit.edu/courses/6-172-performance-engineering-of-software-systems-fall-2018/) | Foundational systems performance concepts (profiling, memory hierarchy, parallelism) |

---

## ★ Sources

- Dean, J., & Barroso, L. A. "The Tail at Scale." Communications of the ACM, 2013.
- Little, J. D. C. "A Proof for the Queuing Formula: L = λW." Operations Research, 1961.
- Kwon, W. et al. "Efficient Memory Management for Large Language Model Serving with PagedAttention." SOSP 2023.
- Google SRE Book — https://sre.google/sre-book/
- [Model Serving for LLM Applications](./model-serving.md)
- [Distributed Inference & Serving Architecture](../inference/distributed-inference-and-serving-architecture.md)
