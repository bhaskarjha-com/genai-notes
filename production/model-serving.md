---
title: "Model Serving for LLM Applications"
tags: [serving, vllm, triton, tgi, inference, llmops, production]
type: reference
difficulty: advanced
status: published
parent: "[[llmops]]"
related: ["[[docker-and-kubernetes]]", "[[monitoring-observability]]", "[[cost-optimization]]", "[[../inference/inference-optimization]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Model Serving for LLM Applications

> Training creates a model. Serving turns it into a dependable API with latency, throughput, and failure behavior you can actually reason about.

---

## TL;DR

- **What**: The systems and patterns used to expose models as production endpoints.
- **Why**: A strong model with weak serving still feels slow, flaky, and expensive.
- **Key point**: Serving is a scheduling and systems problem, not just a "wrap it in FastAPI" problem.

---

## Overview

### Definition

**Model serving** is the runtime layer that accepts requests, prepares inputs, executes inference, and returns outputs under production constraints.

### Scope

This note covers serving architectures, runtime choices, and operational trade-offs for LLM systems. For lower-level performance techniques, see [Inference Optimization](../inference/inference-optimization.md). For platform packaging, see [Docker & Kubernetes for GenAI Deployment](./docker-and-kubernetes.md).

### Significance

- Serving determines the real user experience more than benchmark scores do.
- Self-hosted GenAI teams spend major effort on batching, scheduling, and memory efficiency.
- Serving knowledge is central to MLOps, LLMOps, and inference engineering roles.

### Prerequisites

- [LLMOps & Production Deployment](./llmops.md)
- [Inference Optimization](../inference/inference-optimization.md)
- [Docker & Kubernetes for GenAI Deployment](./docker-and-kubernetes.md)

---

## Deep Dive

### Serving Request Path

```text
Client request
-> auth and rate limiting
-> request validation
-> prompt / input shaping
-> routing to model or serving engine
-> batching and scheduling
-> inference runtime
-> output validation / formatting
-> metrics, traces, and logs
-> response
```

### Core Serving Concerns

| Concern | Why It Matters |
|---|---|
| **Latency** | Interactive chat feels broken when time-to-first-token is poor |
| **Throughput** | Determines how many concurrent users the system can handle |
| **Memory** | LLM serving is often bottlenecked by model and KV-cache memory |
| **Reliability** | Timeouts, retries, and overload behavior must be explicit |
| **Cost** | Serving choices directly shape GPU usage and token economics |

### Common Serving Patterns

| Pattern | Best For | Trade-Off |
|---|---|---|
| **Managed API** | Fast iteration, low infra overhead | Less control, possible vendor lock-in |
| **Self-hosted open model** | Privacy, cost control, fine-tuned models | Need GPU and ops maturity |
| **Hybrid routing** | Mixed workloads and cost tuning | More complexity |
| **Async batch serving** | Offline generation and evaluation | Not ideal for interactive UX |

### Serving Engines

| Engine | Best Known For | Typical Fit |
|---|---|---|
| **vLLM** | High-throughput open-source LLM serving | General self-hosted LLM serving |
| **TGI** | Hugging Face ecosystem integration | Teams already in HF stack |
| **Triton Inference Server** | Multi-model, multi-backend serving | Broader ML platform setups |
| **SGLang** | Efficient serving for structured generation workloads | High-throughput advanced setups |
| **Ollama** | Local developer ergonomics | Local testing, not primary production stack |

### API Shape Decisions

Choose early whether you need:

- synchronous response vs streaming
- chat format vs raw completion format
- tool-call capable outputs
- strict JSON schema outputs
- tenant-aware rate limits

These choices affect the gateway, eval harness, and downstream clients.

### Batch vs Interactive Serving

| Mode | Optimize For | Typical Examples |
|---|---|---|
| **Interactive** | Low latency and fast first token | Chat, copilots, agents |
| **Batch** | Throughput and unit cost | Classification, offline summaries, eval runs |

### Practical Metrics

| Metric | Why It Matters |
|---|---|
| **TTFT** | User perceives responsiveness through first token speed |
| **Tokens/sec** | Measures generation throughput |
| **Requests/sec** | Endpoint capacity indicator |
| **GPU utilization** | Tells whether hardware is being used efficiently |
| **P95 latency** | Better than averages for production reliability |
| **Error rate** | Helps separate overload from semantic failures |

### Minimal Self-Hosted OpenAI-Compatible Serving

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --host 0.0.0.0 \
  --port 8000
```

### Design Heuristics

1. Start with the simplest serving mode that meets the product need.
2. Separate gateway concerns from model runtime concerns.
3. Stream responses for chat-like experiences when possible.
4. Add caching, batching, and routing only after measuring real bottlenecks.
5. Treat overload behavior as part of product design.

---

## Quick Reference

| Problem | First Serving Move |
|---|---|
| High API cost | Evaluate self-hosting or smaller-model routing |
| Slow first token | Reduce prompt size, enable streaming, inspect prefill path |
| GPU memory pressure | Quantize, reduce batch size, inspect KV-cache growth |
| Uneven traffic | Add queueing, autoscaling, and backpressure |
| Mixed workloads | Split interactive and batch paths |

---

## Gotchas

- Teams often blame the model when the real bottleneck is gateway design or retrieval latency.
- A single serving stack for every workload usually performs badly.
- OpenAI-compatible APIs simplify clients but do not remove serving complexity.
- P50 latency can look healthy while P95 latency is unacceptable.

---

## Interview Angles

- **Q**: What is the difference between inference optimization and model serving?
- **A**: Inference optimization focuses on making the core generation path more efficient, for example quantization or KV-cache improvements. Model serving covers the full production runtime around that path, including APIs, routing, scheduling, scaling, and failure handling.

- **Q**: When would you self-host instead of using a managed API?
- **A**: When privacy, volume economics, model customization, or latency control outweigh the extra operational burden. Otherwise, managed APIs are usually the faster path.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Inference Optimization](../inference/inference-optimization.md), [Docker & Kubernetes for GenAI Deployment](./docker-and-kubernetes.md), [AI System Design for GenAI Applications](./ai-system-design.md) |
| Leads to | [Monitoring & Observability for GenAI Systems](./monitoring-observability.md), [Cost Optimization for GenAI Systems](./cost-optimization.md) |
| Compare with | Managed API consumption, classical REST service deployment |
| Cross-domain | Distributed systems, queueing, API platform design |

---

## Sources

- vLLM documentation - https://docs.vllm.ai
- Hugging Face Text Generation Inference documentation
- NVIDIA Triton Inference Server documentation
- [Inference Optimization](../inference/inference-optimization.md)
