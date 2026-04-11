---
title: "LLMOps & Production Deployment"
tags: [llmops, production, monitoring, observability, deployment, ci-cd, genai]
type: procedure
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../tools-and-infra/tools-overview]]", "[[../evaluation/evaluation-and-benchmarks]]", "[[../ethics-and-safety/ethics-safety-alignment]]", "[[../inference/inference-optimization]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-03-22
---

# LLMOps & Production Deployment

> ✨ **Bit**: Anyone can call an API in a notebook. Getting that same API to serve 10,000 users reliably, cheaply, safely, and without hallucinating financial advice? That's LLMOps. It's the difference between a demo and a product.

---

## ★ TL;DR

- **What**: The practices, tools, and pipelines for deploying, monitoring, and maintaining LLM applications in production
- **Why**: 90% of GenAI projects fail to reach production. LLMOps is what separates "cool prototype" from "reliable product"
- **Key point**: LLMs are non-deterministic, expensive, and can hallucinate. You need different operational practices than traditional software.

---

## ★ Overview

### Definition

**LLMOps** extends MLOps and DevOps to address the unique challenges of LLM applications: non-deterministic outputs, prompt management, token cost tracking, hallucination monitoring, and safety guardrails — all while maintaining the reliability users expect.

### Scope

Covers the production lifecycle. For model serving engines, see [[../tools-and-infra/tools-overview]]. For inference optimization, see [[../inference/inference-optimization]]. For safety guardrails, see [[../ethics-and-safety/ethics-safety-alignment]].

### Significance

- This is what "senior GenAI engineer" actually means in job descriptions
- Companies are investing more in LLMOps than in model training
- Understanding this = you can build AND ship, not just experiment

---

## ★ Deep Dive

### The LLMOps Stack

```
┌─────────────────────────────────────────────────────────┐
│                    USER REQUESTS                         │
├─────────────────────────────────────────────────────────┤
│  GATEWAY LAYER                                          │
│  Rate limiting │ Auth │ Request routing │ Load balancing │
├─────────────────────────────────────────────────────────┤
│  GUARDRAILS (Input)                                     │
│  Prompt injection detection │ PII scrubbing │ Validation │
├─────────────────────────────────────────────────────────┤
│  APPLICATION LOGIC                                      │
│  RAG pipeline │ Agent loops │ Chain orchestration        │
├────────────────────┬────────────────────────────────────┤
│  LLM LAYER         │  CACHE LAYER                       │
│  API calls │       │  Semantic cache │ Exact cache       │
│  Self-hosted       │  (save $$$ on repeated queries)    │
├────────────────────┴────────────────────────────────────┤
│  GUARDRAILS (Output)                                    │
│  Hallucination check │ Toxicity filter │ PII detection  │
├─────────────────────────────────────────────────────────┤
│  OBSERVABILITY                                          │
│  Tracing │ Logging │ Metrics │ Cost tracking │ Alerts   │
├─────────────────────────────────────────────────────────┤
│  EVALUATION (Continuous)                                │
│  Automated evals │ Human feedback │ Regression testing  │
└─────────────────────────────────────────────────────────┘
```

### Prompt Management

```
THE PROBLEM:
  Prompts are like code — they need version control.
  But they're stored in strings, not files.
  One bad prompt change can break everything.

SOLUTION: Treat prompts as first-class artifacts

  ┌──────────────────────────────────────────────┐
  │  PROMPT LIFECYCLE                            │
  │                                              │
  │  1. Write prompt (with template variables)   │
  │  2. Test against eval suite (golden examples)│
  │  3. Version it (v1.0, v1.1, v2.0)           │
  │  4. A/B test in production (v1 vs v2)        │
  │  5. Monitor quality metrics                  │
  │  6. Rollback if quality drops                │
  └──────────────────────────────────────────────┘

TOOLS:
  - LangSmith (LangChain) — prompt playground + versioning
  - Braintrust — prompt testing + A/B testing
  - Promptfoo — CLI-based prompt testing
  - Portkey — AI gateway with prompt management
```

### Monitoring & Observability

| What to Monitor           | Why                               | Tool                    |
| ------------------------- | --------------------------------- | ----------------------- |
| **Latency** (TTFT, total) | User experience                   | Langfuse, LangSmith     |
| **Token usage**           | Cost control                      | Portkey, custom logging |
| **Error rates**           | Reliability                       | Any APM + custom        |
| **Quality scores**        | Hallucination, relevance          | RAGAS, DeepEval         |
| **Cost per query**        | Budget management                 | Portkey, custom         |
| **Guardrail triggers**    | Safety monitoring                 | NeMo, Lakera            |
| **User feedback**         | Ground truth                      | Custom (👍/👎 buttons)    |
| **Drift**                 | Performance degradation over time | Arize Phoenix           |

```python
# ═══ Basic LLM Observability with Langfuse ═══
from langfuse.openai import openai  # Drop-in replacement

# Every call is now automatically traced
response = openai.chat.completions.create(
    model="gpt-5.4",
    messages=[{"role": "user", "content": "Explain RAG"}],
    metadata={"user_id": "user_123", "session": "abc"}
)
# → Langfuse dashboard shows: latency, tokens, cost, trace

# ═══ Semantic Caching (reduce costs 30-60%) ═══
# If a similar question was asked before, return cached answer
from gptcache import cache
cache.init()  # Initialize semantic cache
# Similar questions → cache hit → save tokens + latency
```

### Deployment Patterns

| Pattern                                       | When                       | Pros                      | Cons                       |
| --------------------------------------------- | -------------------------- | ------------------------- | -------------------------- |
| **API-only** (OpenAI, Anthropic)              | Fast start, simple         | Easy, no infra            | Cost at scale, vendor lock |
| **API + Gateway** (Portkey, LiteLLM)          | Multi-model, production    | Fallbacks, load balancing | Extra layer                |
| **Self-hosted** (vLLM + open model)           | Data privacy, cost control | Full control, no vendor   | GPU infra needed           |
| **Hybrid** (API for hard, self-host for easy) | Cost optimization          | Best of both              | Complex routing            |

```
DEPLOYMENT CHECKLIST:
  □ Rate limiting (protect against abuse)
  □ API key management (rotate, scope)
  □ Retry logic with exponential backoff
  □ Fallback models (if primary fails)
  □ Cost alerts (daily/monthly budgets)
  □ Response logging (for debugging + eval)
  □ User feedback collection (👍/👎)
  □ Automated eval suite (run on every change)
  □ Guardrails (input + output)
  □ Health checks and uptime monitoring
```

### CI/CD for LLM Applications

```
TRADITIONAL CI/CD:
  Code change → Run tests → Deploy if tests pass

LLM CI/CD (additional steps):
  Prompt change → Run eval suite → Compare with baseline
                → If better → Deploy (canary)
                → If worse → Block deployment

  ┌───────────────────────────────────────────────────┐
  │  PROMPT/CODE CHANGE                               │
  │       │                                           │
  │       ▼                                           │
  │  ┌─────────────┐                                  │
  │  │ Unit Tests   │ ← Traditional code tests        │
  │  └──────┬──────┘                                  │
  │         ▼                                         │
  │  ┌─────────────┐                                  │
  │  │ LLM Eval     │ ← Run prompt against golden set │
  │  │ Suite        │   Compare quality scores         │
  │  └──────┬──────┘                                  │
  │         ▼                                         │
  │  ┌─────────────┐                                  │
  │  │ Regression   │ ← Did any existing answers get  │
  │  │ Check        │   worse? (output diff analysis)  │
  │  └──────┬──────┘                                  │
  │         ▼                                         │
  │  ┌─────────────┐                                  │
  │  │ Cost Check   │ ← Is the new prompt more         │
  │  │              │   expensive? Within budget?       │
  │  └──────┬──────┘                                  │
  │         ▼                                         │
  │  DEPLOY (canary → 5% → 50% → 100%)               │
  └───────────────────────────────────────────────────┘
```

### Observability Platforms (2026)

| Platform          | Type        | Best For                           |
| ----------------- | ----------- | ---------------------------------- |
| **LangSmith**     | SaaS        | LangChain users, full lifecycle    |
| **Langfuse**      | Open-source | Self-hosted, privacy-first         |
| **Arize Phoenix** | Open-source | Drift monitoring, traces           |
| **Portkey**       | AI Gateway  | Multi-model routing, cost tracking |
| **Braintrust**    | SaaS        | Eval + prompt management           |
| **Maxim AI**      | SaaS        | Enterprise observability           |
| **Helicone**      | SaaS        | Simple logging + analytics         |

---

## ◆ Quick Reference

```
COST REDUCTION STRATEGIES:
  1. Semantic caching (30-60% savings)
  2. Smaller models for simple tasks (GPT-5.4-mini/nano vs GPT-5.4)
  3. Prompt optimization (fewer tokens)
  4. Batching requests (where possible)
  5. Self-host for high-volume (break-even ~$5K/month)

INCIDENT RESPONSE:
  Model returns gibberish  → Check API status, switch to fallback
  Costs spike unexpectedly → Check for prompt injection, rate limit
  Quality drops suddenly   → API model updated? Check eval scores
  Guardrail trigger surge  → Possible attack, review logs

KEY METRICS:
  TTFT (time to first token) < 500ms for interactive
  Total latency < 5s for most queries
  Error rate < 0.1%
  Cost per query: track and budget
  Eval score regression: < 5% acceptable
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **No eval suite = deploying blind**: You MUST have a set of golden test cases to catch regressions.
- ⚠️ **LLM APIs change without warning**: OpenAI/Anthropic update models silently. Your app can break overnight. Monitor quality continuously.
- ⚠️ **Logging everything is expensive**: Log smartly — sample in production, log fully in staging.
- ⚠️ **Prompt injection is a real attack**: Users WILL try to override your system prompt. Always validate.
- ⚠️ **Vendor lock-in is real**: Abstract your LLM calls behind an interface. Use gateways like Portkey/LiteLLM.

---

## ○ Interview Angles

- **Q**: How would you take an LLM prototype to production?
- **A**: (1) Create an eval suite (50+ golden examples), (2) Add input/output guardrails, (3) Implement observability (Langfuse/LangSmith), (4) Set up cost alerting, (5) Abstract the LLM provider behind a gateway for fallbacks, (6) CI/CD pipeline that runs eval suite on every prompt/code change, (7) Canary deployment with quality monitoring.

- **Q**: How do you handle LLM quality degradation in production?
- **A**: Continuous monitoring via automated evals, user feedback (👍/👎), drift detection. When quality drops: check if the provider updated the model, run regression analysis against golden set, roll back prompts if needed, or switch to a backup model.

---

## ★ Connections

| Relationship | Topics                                                                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Builds on    | [[../llms/llms-overview]], [[../evaluation/evaluation-and-benchmarks]], [[../ethics-and-safety/ethics-safety-alignment]] |
| Leads to     | Enterprise AI deployment, Scalable AI systems                                                                            |
| Compare with | Traditional MLOps (ML models), DevOps (software)                                                                         |
| Cross-domain | Site Reliability Engineering, Platform engineering                                                                       |

---

## ★ Sources

- LangSmith documentation — https://docs.smith.langchain.com
- Langfuse documentation — https://langfuse.com/docs
- Portkey AI Gateway — https://portkey.ai/docs
- Arize Phoenix — https://docs.arize.com/phoenix
- Hamel Husain, "Your AI Product Needs Evals" (2024)
