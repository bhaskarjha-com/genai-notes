---
title: "Monitoring & Observability for GenAI Systems"
tags: [monitoring, observability, tracing, evals, llmops, production]
type: reference
difficulty: advanced
status: published
last_verified: 2026-04
parent: "llmops.md"
related: ["model-serving.md", "cicd-for-ml.md", "cost-optimization.md", "../agents/agent-evaluation.md", "../llms/hallucination-detection.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Monitoring & Observability for GenAI Systems

> Traditional monitoring tells you if the service is alive. GenAI observability tells you if the service is alive, useful, safe, and worth the money.

---

## ★ TL;DR
- **What**: The tracing, metrics, logs, and feedback loops used to understand AI behavior in production.
- **Why**: GenAI systems can be "up" while still being wrong, unsafe, or too expensive.
- **Key point**: You need both system telemetry and quality telemetry.

---

## ★ Overview
### Definition

**Monitoring** tracks known signals such as latency and error rates. **Observability** adds enough telemetry to investigate unknown failures, regressions, and user-quality breakdowns.

### Scope

This note focuses on production telemetry for LLM apps, RAG systems, and agents. For offline quality methodology, see [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md).

### Significance

- AI failures are often semantic, not just infrastructural.
- The same request can succeed technically and fail product-wise.
- Observability is what turns prompt iteration into engineering instead of guesswork.

### Prerequisites

- [LLMOps & Production Deployment](./llmops.md)
- [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md)
- [Agent Evaluation & Observability](../agents/agent-evaluation.md)

---

## ★ Deep Dive
### The Four Telemetry Layers

| Layer | What You Track | Example Signals |
|---|---|---|
| **Infrastructure** | Service health | CPU, GPU, memory, request rate, errors |
| **Runtime** | Model-call behavior | TTFT, tokens/sec, retries, tool latency |
| **Quality** | Output usefulness | groundedness, rubric score, retrieval relevance |
| **Business** | User outcome | resolution rate, conversion, retention, escalations |

### Why GenAI Needs Traces

A single user request can include:

- retrieval
- reranking
- prompt assembly
- one or more model calls
- tool execution
- post-processing and validation

Without traces, teams see only "the answer was bad" and have no clue where the failure occurred.

### What To Capture Per Request

| Signal | Reason |
|---|---|
| Input metadata | tenant, route, model, prompt version |
| Retrieval context | documents returned, scores, chunk ids |
| Model metadata | latency, token usage, finish reason |
| Tool events | tool selected, tool latency, tool result summary |
| Validation outcome | schema pass/fail, policy pass/fail |
| User outcome | thumbs up/down, escalation, retry |

### Production Metrics That Matter

| Metric | Why It Matters |
|---|---|
| **P95 latency** | Better user experience indicator than average latency |
| **Cost per successful task** | More meaningful than cost per request |
| **Groundedness rate** | Useful for knowledge-heavy assistants |
| **Tool success rate** | Critical for agents and workflow systems |
| **Fallback frequency** | Reveals overload or low-confidence issues |
| **Human escalation rate** | Strong proxy for trust and failure severity |

### Alerts You Actually Want

Alert on:

- latency spikes beyond target budget
- error or timeout bursts
- unusual cost jumps
- sudden drops in evaluation or feedback scores
- retrieval failure surges
- guardrail trigger spikes

Do not alert on every token count wiggle.

### Tooling Landscape

The specific platform mix changes frequently, but the stable categories are:

- tracing and session inspection
- prompt and dataset evaluation
- infrastructure/APM metrics
- feedback collection

Last verified for example categories and ecosystem naming: 2026-04.

### Example Trace Schema

```json
{
  "request_id": "req_123",
  "route": "support-assistant",
  "model": "gpt-4o-mini",
  "prompt_version": "support-v7",
  "retrieval": {
    "top_k": 5,
    "doc_ids": ["kb_41", "kb_77"]
  },
  "usage": {
    "prompt_tokens": 1210,
    "completion_tokens": 182
  },
  "quality": {
    "grounded": true,
    "feedback": "upvote"
  }
}
```

### Practical Workflow

1. Define the product outcome you care about.
2. Map the request path and log the critical stages.
3. Add dashboards for infra and quality separately.
4. Review low-scoring traces weekly.
5. Feed findings back into eval sets and CI/CD.

---

## ◆ Quick Reference
| If You Need To Diagnose... | Inspect First |
|---|---|
| Slow answers | Trace timings across retrieval, model, and tools |
| Expensive answers | token usage, routing policy, retries, prompt size |
| Bad facts | retrieval payload, citations, groundedness checks |
| Broken agents | trajectory trace and tool-call outcomes |
| User dissatisfaction | feedback-linked traces and failure clusters |

---

## ○ Gotchas & Common Mistakes
- Logging raw prompts and documents can create privacy and security problems.
- Dashboards without trace drill-down rarely solve semantic failures.
- Teams often track cost per request but ignore cost per successful task.
- Manual spot checks are not enough once traffic grows.

---

## ○ Interview Angles
- **Q**: Why is observability harder for LLM systems than for normal APIs?
- **A**: Because correctness is not binary. The system can return a 200 response and still be wrong, unsafe, or unhelpful. You need traceable context, output quality signals, and user feedback, not just uptime metrics.

- **Q**: What is the minimum telemetry for a production RAG system?
- **A**: Request id, model and prompt version, retrieval documents and scores, token usage, latency, validation status, and user feedback. That gives you enough context to debug both system and semantic failures.

---

## ★ Connections
| Relationship | Topics |
|---|---|
| Builds on | [LLMOps & Production Deployment](./llmops.md), [Agent Evaluation & Observability](../agents/agent-evaluation.md), [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md) |
| Leads to | [CI/CD for ML and LLM Systems](./cicd-for-ml.md), [Cost Optimization for GenAI Systems](./cost-optimization.md) |
| Compare with | Traditional APM and log-only monitoring |
| Cross-domain | SRE, analytics engineering, experimentation |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Alert fatigue** | Team ignores alerts because too many are non-actionable | Thresholds too sensitive, no severity tiers | Tiered alerting (P0-P3), alert correlation, runbook links |
| **Metric cardinality explosion** | Monitoring system slows or crashes | Unbounded label values (per-user metrics) | Bounded label sets, metric aggregation, pre-aggregated dashboards |
| **LLM quality blind spots** | Quality degrades but no alert fires | Only tracking latency/throughput, not output quality | LLM-as-judge sampling, drift detection, user feedback loops |
| **Log volume cost** | Logging costs exceed inference costs | Logging full prompts/completions at volume | Log sampling (1-5%), structured logging, retention policies |

---

## ◆ Hands-On Exercises

### Exercise 1: Build an LLM Monitoring Dashboard

**Goal**: Create a monitoring setup that tracks latency, cost, and quality
**Time**: 45 minutes
**Steps**:
1. Instrument a FastAPI LLM endpoint with OpenTelemetry
2. Track p50/p95/p99 latency, token usage, error rate
3. Add a quality score metric (LLM-as-judge on 1% of responses)
4. Visualize in a dashboard (Grafana or matplotlib)
**Expected Output**: Dashboard with 4 panels: latency, throughput, cost, quality
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [LangSmith Documentation](https://docs.smith.langchain.com/) | Production LLM observability platform |
| 🔧 Hands-on | [Arize Phoenix](https://docs.arize.com/phoenix/) | Open-source LLM observability and evaluation |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 9 | Monitoring patterns specific to AI systems |
| 🎥 Video | [Shreya Shankar — "Rethinking ML Monitoring"](https://www.shreya-shankar.com/) | Data quality monitoring for ML systems |

## ★ Sources
- Langfuse documentation
- LangSmith documentation
- Arize Phoenix documentation
- [Agent Evaluation & Observability](../agents/agent-evaluation.md)
