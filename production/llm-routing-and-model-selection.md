---
title: "LLM Routing & Model Selection"
tags: [routing, model-selection, cost, latency, production, llmops]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "[[llmops]]"
related: ["[[cost-optimization]]", "[[model-serving]]", "[[../llms/llm-landscape]]", "[[../techniques/context-engineering]]"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# LLM Routing & Model Selection

> ✨ **Bit**: Using GPT-4 for everything is like taking an ambulance to the grocery store. Model routing sends simple requests to cheap/fast models and hard requests to powerful/expensive ones — cutting costs 60-80% with minimal quality loss.

---

## ★ TL;DR

- **What**: Techniques for dynamically selecting which LLM handles each request based on task complexity, cost, latency, and quality requirements
- **Why**: LLM costs vary 100× between models (Gemini Flash: $0.075/M vs Claude Opus: $75/M input tokens). Routing simple tasks to cheap models saves enormous money.
- **Key point**: A well-tuned router sends 70-80% of traffic to cheap models, 15-25% to mid-tier, and < 5% to expensive models — reducing average cost per request by 5-10× while maintaining quality.

---

## ★ Overview

### Definition

**LLM routing** is the practice of using a classifier, heuristic, or meta-model to select the optimal LLM for each incoming request based on task difficulty, cost constraints, latency requirements, and quality thresholds.

### Scope

Covers: Routing strategies (rule-based, classifier-based, cascade), model selection frameworks, cost-quality tradeoff analysis, and production implementation. For broader cost optimization, see [Cost Optimization](./cost-optimization.md). For model landscape, see [LLM Landscape](../llms/llm-landscape.md).

### Significance

- **Cost is the #1 production AI concern**: Most teams overspend by 5-10× using a single expensive model for all requests
- **Latency varies dramatically**: Flash/Haiku models respond in 200ms, Opus/GPT-4 in 2-5 seconds
- **Interview staple**: "How would you reduce LLM costs by 80% without losing quality?" tests this directly

### Prerequisites

- [Cost Optimization](./cost-optimization.md) — cost fundamentals
- [LLM Landscape](../llms/llm-landscape.md) — model capabilities
- [LLMs Overview](../llms/llms-overview.md) — LLM fundamentals

---

## ★ Deep Dive

### The Cost-Quality Spectrum (April 2026)

```
MODEL TIERS (per 1M input tokens):

  TIER 1: CHEAP & FAST              $0.075 - $0.25
    Gemini Flash, GPT-4o-mini, Claude Haiku
    Use for: classification, extraction, simple Q&A, reformatting
    Latency: 100-300ms TTFT

  TIER 2: MID-RANGE                 $1.00 - $5.00
    GPT-4o, Claude Sonnet, Gemini Pro
    Use for: complex Q&A, summarization, code generation
    Latency: 300-800ms TTFT

  TIER 3: POWERFUL & EXPENSIVE      $15.00 - $75.00
    Claude Opus, GPT-4 Turbo, o1-pro
    Use for: complex reasoning, hard code, multi-step analysis
    Latency: 1-5s TTFT

  COST DIFFERENCE: Tier 3 is up to 1000× more expensive than Tier 1

  QUALITY DIFFERENCE: For simple tasks, Tier 1 ≈ Tier 3 quality
                      For hard tasks, Tier 3 >> Tier 1 quality
```

### Routing Strategies

```
┌──────────────────────────────────────────────────────────────────┐
│                    ROUTING STRATEGIES                              │
│                                                                    │
│  STRATEGY 1: RULE-BASED                                           │
│  ┌──────────────────────────────────────────────┐                 │
│  │ if task_type == "classify": use Haiku         │                 │
│  │ if task_type == "summarize": use Sonnet       │                 │
│  │ if task_type == "reason": use Opus            │                 │
│  └──────────────────────────────────────────────┘                 │
│  ✅ Simple, predictable, no overhead                              │
│  ❌ Can't handle ambiguous requests                               │
│                                                                    │
│  STRATEGY 2: CLASSIFIER-BASED                                     │
│  ┌──────────────────────────────────────────────┐                 │
│  │ Train a small classifier on labeled examples   │                │
│  │ Input: user request → Output: model tier       │                │
│  │ Use: logistic regression, small BERT, or LLM   │                │
│  └──────────────────────────────────────────────┘                 │
│  ✅ Handles nuance, data-driven                                   │
│  ❌ Needs labeled data, can misroute                              │
│                                                                    │
│  STRATEGY 3: CASCADE (TRY CHEAP FIRST)                            │
│  ┌──────────────────────────────────────────────┐                 │
│  │ 1. Send to cheap model                         │                │
│  │ 2. Check confidence / quality score            │                │
│  │ 3. If below threshold → escalate to expensive  │                │
│  └──────────────────────────────────────────────┘                 │
│  ✅ No misrouting (always has fallback)                           │
│  ❌ Adds latency for escalated requests                           │
│                                                                    │
│  STRATEGY 4: LLM-AS-ROUTER                                       │
│  ┌──────────────────────────────────────────────┐                 │
│  │ Use a cheap LLM to classify difficulty:        │                │
│  │ "Rate this query 1-3 for complexity"            │                │
│  │ Route based on the rating                       │                │
│  └──────────────────────────────────────────────┘                 │
│  ✅ Flexible, understands context                                 │
│  ❌ Adds cost and latency for the routing call                    │
└──────────────────────────────────────────────────────────────────┘
```

### When to Use Each Strategy

| Strategy | Best When | Overhead | Accuracy |
|----------|----------|:--------:|:--------:|
| **Rule-based** | Known task types (API with defined endpoints) | Zero | Medium |
| **Classifier** | High traffic, labeled historical data available | ~5ms | High |
| **Cascade** | Quality is critical, can't afford misrouting | +200ms for escalations | Highest |
| **LLM-as-router** | Diverse queries, no labeled data yet | +100-200ms, +$0.0001 | High |

---

## ★ Code & Implementation

### LLM Router with Cascade Fallback

```python
# pip install openai>=1.0
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.0

from openai import OpenAI
import json, time

client = OpenAI()

# Model tier configuration
MODELS = {
    "cheap": {"name": "gpt-4o-mini", "input_cost": 0.15, "output_cost": 0.60},
    "mid":   {"name": "gpt-4o",      "input_cost": 2.50, "output_cost": 10.00},
    "expensive": {"name": "gpt-4-turbo", "input_cost": 10.0, "output_cost": 30.0},
}

def classify_difficulty(query: str) -> str:
    """Use cheap LLM to classify query difficulty."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "system",
            "content": """Classify the difficulty of this user query.
Output JSON: {"difficulty": "easy"|"medium"|"hard", "reason": "brief explanation"}

easy: simple facts, formatting, classification, short answers
medium: summarization, code generation, multi-step reasoning
hard: complex analysis, mathematical proofs, novel code architecture"""
        }, {
            "role": "user",
            "content": query,
        }],
        response_format={"type": "json_object"},
        temperature=0,
        max_tokens=100,
    )
    result = json.loads(response.choices[0].message.content)
    return result["difficulty"]

def route_and_respond(query: str, messages: list[dict] = None) -> dict:
    """Route query to appropriate model and return response with metadata."""
    start = time.time()

    # Step 1: Classify difficulty
    difficulty = classify_difficulty(query)
    tier_map = {"easy": "cheap", "medium": "mid", "hard": "expensive"}
    tier = tier_map[difficulty]
    model_config = MODELS[tier]

    # Step 2: Generate response with selected model
    msgs = messages or [{"role": "user", "content": query}]
    response = client.chat.completions.create(
        model=model_config["name"],
        messages=msgs,
    )

    # Step 3: Calculate cost
    usage = response.usage
    cost = (
        usage.prompt_tokens * model_config["input_cost"] / 1_000_000 +
        usage.completion_tokens * model_config["output_cost"] / 1_000_000
    )

    return {
        "content": response.choices[0].message.content,
        "model_used": model_config["name"],
        "difficulty": difficulty,
        "cost_usd": f"${cost:.6f}",
        "latency_ms": round((time.time() - start) * 1000),
    }

# Test
print(route_and_respond("What is 2+2?"))
# Expected: {"model_used": "gpt-4o-mini", "difficulty": "easy", "cost_usd": "$0.000030", ...}

print(route_and_respond("Write a async Python web scraper with rate limiting and retry logic"))
# Expected: {"model_used": "gpt-4o", "difficulty": "medium", "cost_usd": "$0.005000", ...}

print(route_and_respond("Prove that P ≠ NP or explain the key obstacles to a proof"))
# Expected: {"model_used": "gpt-4-turbo", "difficulty": "hard", "cost_usd": "$0.010000", ...}
```

---

## ◆ Quick Reference

```
ROUTING DECISION GUIDE:

  Known task types (APIs)?          → Rule-based routing
  High traffic + labeled data?      → Train a classifier
  Quality-critical + can't misroute? → Cascade (try cheap first)
  Cold start / no labeled data?     → LLM-as-router

COST SAVINGS ESTIMATES:
  No routing (all GPT-4):           $100/day baseline
  Rule-based routing:               $30-50/day (50-70% savings)
  Classifier routing:               $15-25/day (75-85% savings)
  Cascade with confidence:          $20-30/day (70-80% savings)

TRAFFIC DISTRIBUTION TARGET:
  Tier 1 (cheap):    70-80% of requests
  Tier 2 (mid):      15-25% of requests
  Tier 3 (expensive): 2-5% of requests
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Under-routing** | Hard queries sent to cheap model, quality drops | Router classifier too aggressive on cost | Monitor quality per route, set minimum quality thresholds |
| **Over-routing** | Most traffic goes to expensive model, costs high | Router too conservative, scared of quality drops | Track routing distribution, set target % per tier |
| **Router latency** | Added 200ms+ for every request from routing overhead | LLM-as-router is slow, classifier model is large | Use lightweight classifier (~5ms), cache routing decisions |
| **Cascade cost explosion** | Escalation rate too high, negating savings | Confidence threshold too strict, cheap model underperforms | Tune threshold on labeled data, improve cheap model prompt |

---

## ○ Interview Angles

- **Q**: How would you reduce LLM costs by 80% without losing quality?
- **A**: Model routing. I'd analyze our traffic and find that 70-80% of requests are simple (classification, extraction, formatting) and can be handled by a cheap model like GPT-4o-mini or Gemini Flash at 1/100th the cost of GPT-4. I'd implement a classifier-based router trained on labeled examples of easy/medium/hard queries. For the remaining 20-30% of complex requests, I'd use a mid-tier model, reserving expensive models (GPT-4, Opus) for only the hardest 2-5%. I'd monitor quality per route with automated evals and adjust thresholds weekly. Expected savings: 5-10× reduction in average cost per request.

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Cost-Optimizing Router

**Goal**: Implement model routing that reduces costs by 5×
**Time**: 45 minutes
**Steps**:
1. Collect 50 example queries spanning easy/medium/hard
2. Implement the LLM-as-router from the code section
3. Process all 50 queries, measure cost per request for each model tier
4. Compare: all-GPT-4 cost vs routed cost → calculate savings
**Expected Output**: Cost comparison table showing 5-10× savings with routing

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Cost Optimization](./cost-optimization.md), [LLM Landscape](../llms/llm-landscape.md), [Model Serving](./model-serving.md) |
| Leads to | AI platform engineering, autonomous cost management |
| Compare with | Static model selection, manual A/B testing |
| Cross-domain | Load balancing, API gateway routing, CDN edge logic |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Ding et al. "RouteLLM" (2024)](https://arxiv.org/abs/2406.18665) | Academic approach to cost-aware LLM routing |
| 🔧 Hands-on | [Martian Router](https://withmartian.com/) | Commercial LLM routing service |
| 🔧 Hands-on | [Artificial Analysis](https://artificialanalysis.ai/) | Compare model speed/cost/quality for routing decisions |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 9 | Cost-aware architecture patterns including routing |

---

## ★ Sources

- Ding et al. "RouteLLM: Learning to Route LLMs with Preference Data" (2024)
- OpenAI, Anthropic, Google AI pricing pages (April 2026)
- [Cost Optimization](./cost-optimization.md)
- [LLM Landscape](../llms/llm-landscape.md)
