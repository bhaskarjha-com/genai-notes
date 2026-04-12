---
title: "LLMOps & Production Deployment"
tags: [llmops, production, monitoring, observability, deployment, ci-cd, genai]
type: procedure
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../tools-and-infra/tools-overview]]", "[[../evaluation/evaluation-and-benchmarks]]", "[[../ethics-and-safety/ethics-safety-alignment]]", "[[../inference/inference-optimization]]", "[[ai-system-design]]", "[[docker-and-kubernetes]]", "[[model-serving]]", "[[monitoring-observability]]", "[[cicd-for-ml]]", "[[cost-optimization]]"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-12
---

# LLMOps & Production Deployment

> âœ¨ **Bit**: Anyone can call an API in a notebook. Getting that same API to serve 10,000 users reliably, cheaply, safely, and without hallucinating financial advice? That's LLMOps. It's the difference between a demo and a product.

---

## â˜… TL;DR

- **What**: The practices, tools, and pipelines for deploying, monitoring, and maintaining LLM applications in production
- **Why**: 90% of GenAI projects fail to reach production. LLMOps is what separates "cool prototype" from "reliable product"
- **Key point**: LLMs are non-deterministic, expensive, and can hallucinate. You need different operational practices than traditional software.

---

## â˜… Overview

### Definition

**LLMOps** extends MLOps and DevOps to address the unique challenges of LLM applications: non-deterministic outputs, prompt management, token cost tracking, hallucination monitoring, and safety guardrails â€” all while maintaining the reliability users expect.

### Scope

Covers the production lifecycle. For deployment packaging, see [Docker & Kubernetes for GenAI Deployment](./docker-and-kubernetes.md). For runtime design, see [Model Serving for LLM Applications](./model-serving.md). For tracing and ops telemetry, see [Monitoring & Observability for GenAI Systems](./monitoring-observability.md). For release automation, see [CI/CD for ML and LLM Systems](./cicd-for-ml.md). For economics, see [Cost Optimization for GenAI Systems](./cost-optimization.md). For lower-level optimization, see [Inference Optimization](../inference/inference-optimization.md).

### Significance

- This is what "senior GenAI engineer" actually means in job descriptions
- Companies are investing more in LLMOps than in model training
- Understanding this = you can build AND ship, not just experiment

---

## â˜… Deep Dive

### The LLMOps Stack

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    USER REQUESTS                         â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  GATEWAY LAYER                                          â”‚
â”‚  Rate limiting â”‚ Auth â”‚ Request routing â”‚ Load balancing â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  GUARDRAILS (Input)                                     â”‚
â”‚  Prompt injection detection â”‚ PII scrubbing â”‚ Validation â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  APPLICATION LOGIC                                      â”‚
â”‚  RAG pipeline â”‚ Agent loops â”‚ Chain orchestration        â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  LLM LAYER         â”‚  CACHE LAYER                       â”‚
â”‚  API calls â”‚       â”‚  Semantic cache â”‚ Exact cache       â”‚
â”‚  Self-hosted       â”‚  (save $$$ on repeated queries)    â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  GUARDRAILS (Output)                                    â”‚
â”‚  Hallucination check â”‚ Toxicity filter â”‚ PII detection  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  OBSERVABILITY                                          â”‚
â”‚  Tracing â”‚ Logging â”‚ Metrics â”‚ Cost tracking â”‚ Alerts   â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  EVALUATION (Continuous)                                â”‚
â”‚  Automated evals â”‚ Human feedback â”‚ Regression testing  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Prompt Management

```
THE PROBLEM:
  Prompts are like code â€” they need version control.
  But they're stored in strings, not files.
  One bad prompt change can break everything.

SOLUTION: Treat prompts as first-class artifacts

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  PROMPT LIFECYCLE                            â”‚
  â”‚                                              â”‚
  â”‚  1. Write prompt (with template variables)   â”‚
  â”‚  2. Test against eval suite (golden examples)â”‚
  â”‚  3. Version it (v1.0, v1.1, v2.0)           â”‚
  â”‚  4. A/B test in production (v1 vs v2)        â”‚
  â”‚  5. Monitor quality metrics                  â”‚
  â”‚  6. Rollback if quality drops                â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

TOOLS:
  - LangSmith (LangChain) â€” prompt playground + versioning
  - Braintrust â€” prompt testing + A/B testing
  - Promptfoo â€” CLI-based prompt testing
  - Portkey â€” AI gateway with prompt management
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
| **User feedback**         | Ground truth                      | Custom (ðŸ‘/ðŸ‘Ž buttons)    |
| **Drift**                 | Performance degradation over time | Arize Phoenix           |

```python
# â•â•â• Basic LLM Observability with Langfuse â•â•â•
from langfuse.openai import openai  # Drop-in replacement

# Every call is now automatically traced
response = openai.chat.completions.create(
    model="gpt-5.4",
    messages=[{"role": "user", "content": "Explain RAG"}],
    metadata={"user_id": "user_123", "session": "abc"}
)
# â†’ Langfuse dashboard shows: latency, tokens, cost, trace

# â•â•â• Semantic Caching (reduce costs 30-60%) â•â•â•
# If a similar question was asked before, return cached answer
from gptcache import cache
cache.init()  # Initialize semantic cache
# Similar questions â†’ cache hit â†’ save tokens + latency
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
  â–¡ Rate limiting (protect against abuse)
  â–¡ API key management (rotate, scope)
  â–¡ Retry logic with exponential backoff
  â–¡ Fallback models (if primary fails)
  â–¡ Cost alerts (daily/monthly budgets)
  â–¡ Response logging (for debugging + eval)
  â–¡ User feedback collection (ðŸ‘/ðŸ‘Ž)
  â–¡ Automated eval suite (run on every change)
  â–¡ Guardrails (input + output)
  â–¡ Health checks and uptime monitoring
```

### CI/CD for LLM Applications

```
TRADITIONAL CI/CD:
  Code change â†’ Run tests â†’ Deploy if tests pass

LLM CI/CD (additional steps):
  Prompt change â†’ Run eval suite â†’ Compare with baseline
                â†’ If better â†’ Deploy (canary)
                â†’ If worse â†’ Block deployment

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  PROMPT/CODE CHANGE                               â”‚
  â”‚       â”‚                                           â”‚
  â”‚       â–¼                                           â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                  â”‚
  â”‚  â”‚ Unit Tests   â”‚ â† Traditional code tests        â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜                                  â”‚
  â”‚         â–¼                                         â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                  â”‚
  â”‚  â”‚ LLM Eval     â”‚ â† Run prompt against golden set â”‚
  â”‚  â”‚ Suite        â”‚   Compare quality scores         â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜                                  â”‚
  â”‚         â–¼                                         â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                  â”‚
  â”‚  â”‚ Regression   â”‚ â† Did any existing answers get  â”‚
  â”‚  â”‚ Check        â”‚   worse? (output diff analysis)  â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜                                  â”‚
  â”‚         â–¼                                         â”‚
  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                  â”‚
  â”‚  â”‚ Cost Check   â”‚ â† Is the new prompt more         â”‚
  â”‚  â”‚              â”‚   expensive? Within budget?       â”‚
  â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜                                  â”‚
  â”‚         â–¼                                         â”‚
  â”‚  DEPLOY (canary â†’ 5% â†’ 50% â†’ 100%)               â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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

## â—† Quick Reference

```
COST REDUCTION STRATEGIES:
  1. Semantic caching (30-60% savings)
  2. Smaller models for simple tasks (GPT-5.4-mini/nano vs GPT-5.4)
  3. Prompt optimization (fewer tokens)
  4. Batching requests (where possible)
  5. Self-host for high-volume (break-even ~$5K/month)

INCIDENT RESPONSE:
  Model returns gibberish  â†’ Check API status, switch to fallback
  Costs spike unexpectedly â†’ Check for prompt injection, rate limit
  Quality drops suddenly   â†’ API model updated? Check eval scores
  Guardrail trigger surge  â†’ Possible attack, review logs

KEY METRICS:
  TTFT (time to first token) < 500ms for interactive
  Total latency < 5s for most queries
  Error rate < 0.1%
  Cost per query: track and budget
  Eval score regression: < 5% acceptable
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **No eval suite = deploying blind**: You MUST have a set of golden test cases to catch regressions.
- âš ï¸ **LLM APIs change without warning**: OpenAI/Anthropic update models silently. Your app can break overnight. Monitor quality continuously.
- âš ï¸ **Logging everything is expensive**: Log smartly â€” sample in production, log fully in staging.
- âš ï¸ **Prompt injection is a real attack**: Users WILL try to override your system prompt. Always validate.
- âš ï¸ **Vendor lock-in is real**: Abstract your LLM calls behind an interface. Use gateways like Portkey/LiteLLM.

---

## â—‹ Interview Angles

- **Q**: How would you take an LLM prototype to production?
- **A**: (1) Create an eval suite (50+ golden examples), (2) Add input/output guardrails, (3) Implement observability (Langfuse/LangSmith), (4) Set up cost alerting, (5) Abstract the LLM provider behind a gateway for fallbacks, (6) CI/CD pipeline that runs eval suite on every prompt/code change, (7) Canary deployment with quality monitoring.

- **Q**: How do you handle LLM quality degradation in production?
- **A**: Continuous monitoring via automated evals, user feedback (ðŸ‘/ðŸ‘Ž), drift detection. When quality drops: check if the provider updated the model, run regression analysis against golden set, roll back prompts if needed, or switch to a backup model.

---

## â˜… Connections

| Relationship | Topics                                                                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------------------ |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Evaluation And Benchmarks](../evaluation/evaluation-and-benchmarks.md), [Ethics Safety Alignment](../ethics-and-safety/ethics-safety-alignment.md) |
| Leads to     | Enterprise AI deployment, Scalable AI systems                                                                            |
| Compare with | Traditional MLOps (ML models), DevOps (software)                                                                         |
| Cross-domain | Site Reliability Engineering, Platform engineering                                                                       |

---

## â˜… Sources

- LangSmith documentation â€” https://docs.smith.langchain.com
- Langfuse documentation â€” https://langfuse.com/docs
- Portkey AI Gateway â€” https://portkey.ai/docs
- Arize Phoenix â€” https://docs.arize.com/phoenix
- Hamel Husain, "Your AI Product Needs Evals" (2024)
