---
title: "Latency & Throughput Engineering for AI Systems"
tags: [latency, throughput, performance, queueing, production, llmops]
type: reference
difficulty: advanced
status: published
parent: "[[llmops]]"
related: ["[[model-serving]]", "[[cost-optimization]]", "[[monitoring-observability]]", "[[../inference/distributed-inference-and-serving-architecture]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Latency & Throughput Engineering for AI Systems

> Performance work becomes much clearer when you stop asking "is it fast?" and start asking "fast for what workload, under which constraint, at what cost?"

---

## TL;DR

- **What**: The engineering of response time and workload capacity in AI systems.
- **Why**: User experience, reliability, and infrastructure cost are all shaped by latency and throughput.
- **Key point**: Optimize against explicit budgets and bottlenecks, not intuition.

---

## Overview

### Definition

**Latency** is how long one request takes. **Throughput** is how much work the system completes over time.

### Scope

This note covers end-to-end AI performance thinking across gateways, retrieval, serving, tool calls, and output generation.

### Significance

- AI systems can feel slow even when the model is strong.
- Performance engineering strongly affects cost.
- Senior engineering interviews often expect this reasoning.

### Prerequisites

- [Model Serving for LLM Applications](./model-serving.md)
- [Monitoring & Observability for GenAI Systems](./monitoring-observability.md)
- [Distributed Inference & Serving Architecture](../inference/distributed-inference-and-serving-architecture.md)

---

## Deep Dive

### Performance Starts With Budgets

Break the request into stages and assign targets:

```text
gateway: 50 ms
retrieval: 150 ms
prompt assembly: 50 ms
model TTFT: 400 ms
generation: 1200 ms
post-processing: 50 ms
```

Without a budget, optimization becomes random.

### Common Bottleneck Areas

| Layer | Example Bottleneck |
|---|---|
| **Gateway** | auth, serialization, rate limiting |
| **Retrieval** | slow search, too many documents |
| **Model runtime** | long context, bad batching, memory pressure |
| **Tool calls** | network round trips, external service slowness |
| **Post-processing** | validation and formatting overhead |

### Latency vs Throughput

| Goal | What You Favor |
|---|---|
| **Low latency** | fast response and low queueing |
| **High throughput** | larger batches and higher utilization |

These goals often conflict.

### Performance Levers

| Lever | Effect |
|---|---|
| **Smaller or routed models** | lower compute cost and latency |
| **Streaming** | better perceived responsiveness |
| **Caching** | avoids repeated work |
| **Batching** | improves throughput |
| **Request shaping** | trims context and tool calls |
| **Async/offline split** | removes noncritical work from user path |

### Tail Latency Matters

P95 or P99 latency often matters more than average latency because users feel the slow outliers and systems fail at the tail first.

### Practical Workflow

1. measure the whole path
2. isolate the longest stage
3. optimize one bottleneck at a time
4. confirm the gain at realistic traffic
5. re-check cost side effects

### Design Heuristics

1. Keep the critical path short.
2. Avoid forcing all workloads through one serving shape.
3. Budget context size aggressively.
4. Use streaming when it improves perception.
5. Monitor tail latency, queue depth, and cost together.

---

## Quick Reference

| Performance Symptom | First Check |
|---|---|
| slow first token | prefill path, context size, gateway overhead |
| total response too long | model runtime and tool count |
| system collapses under load | queueing, backpressure, autoscaling |
| good average but bad UX | tail latency distribution |
| cost rises after speed fix | throughput gain may have worsened economics elsewhere |

---

## Gotchas

- Faster average latency can hide worse tail latency.
- Over-batching can hurt interactive response times.
- Streaming improves perception but not always total compute cost.
- Teams often optimize the model while ignoring retrieval or tool delays.

---

## Interview Angles

- **Q**: What is the difference between latency and throughput?
- **A**: Latency is the time a single request takes; throughput is how much total work the system handles over time. Optimizing one can hurt the other.

- **Q**: Why is P95 latency important in AI systems?
- **A**: Because user experience and reliability are often dominated by slow outliers, especially when requests have variable context length or tool behavior.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Model Serving for LLM Applications](./model-serving.md), [Distributed Inference & Serving Architecture](../inference/distributed-inference-and-serving-architecture.md), [Monitoring & Observability for GenAI Systems](./monitoring-observability.md) |
| Leads to | cost optimization, capacity planning, performance tuning |
| Compare with | raw benchmark speed comparisons |
| Cross-domain | SRE, queueing theory, capacity planning |

---

## Sources

- [Model Serving for LLM Applications](./model-serving.md)
- [Distributed Inference & Serving Architecture](../inference/distributed-inference-and-serving-architecture.md)
- classic performance and capacity-planning guidance
