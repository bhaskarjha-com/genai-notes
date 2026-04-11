---
title: "Reasoning Models & Test-Time Compute"
tags: [reasoning, o1, o3, chain-of-thought, test-time-compute, deepseek-r1, thinking, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[llms-overview]]", "[[../foundations/transformers]]", "[[../techniques/prompt-engineering]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-03-22
---

# Reasoning Models & Test-Time Compute

> ✨ **Bit**: Pre-2024: "Make the model bigger to make it smarter." Post-2024: "Make the model THINK LONGER to make it smarter." This shift — from scaling training compute to scaling inference compute — is the biggest paradigm change since the Transformer.

---

## ★ TL;DR

- **What**: LLMs that generate internal "thinking" chains before answering, trading more inference compute for dramatically better reasoning
- **Why**: Standard LLMs fail at complex math, logic, and multi-step problems. Reasoning models solve these by "thinking step by step" internally — not as a prompting trick, but as a trained capability
- **Key point**: o1/o3/DeepSeek-R1 represent a new scaling law — **test-time compute scaling** — where spending more compute at inference yields better answers, sometimes surpassing even larger standard models

---

## ★ Overview

### Definition

**Reasoning models** are LLMs specifically trained (usually via reinforcement learning) to produce extended chains of internal reasoning before generating a final answer. Unlike standard LLMs that generate responses token-by-token in one pass, reasoning models generate a hidden "thinking" block where they plan, verify, backtrack, and self-correct.

### Scope

Covers: Reasoning model architectures, test-time compute scaling, process reward models, and when to use reasoning vs standard models. For basic prompting techniques (zero-shot CoT), see [[../techniques/prompt-engineering]]. For standard LLM overview, see [[llms-overview]].

### Significance

- o1 (Sep 2024) proved reasoning models can solve PhD-level problems standard LLMs can't
- DeepSeek-R1 (Jan 2025) showed open-source reasoning is viable
- This is the #1 interview topic for frontier GenAI roles in 2025-2026
- Fundamentally changes when to use "bigger model" vs "more thinking time"

### Prerequisites

- [[llms-overview]] — how standard LLMs work
- [[../techniques/prompt-engineering]] — chain-of-thought prompting
- [[../prerequisites/probability-and-statistics]] — reinforcement learning basics

---

## ★ Deep Dive

### The Two Scaling Laws

```
ERA 1: PRE-TRAINING SCALING (2020-2024)
  "Make the model bigger, train on more data"
  
  Performance ∝ model_size × data_size × training_compute
  
  GPT-3 (175B) → GPT-4 (~1.8T) → GPT-5 (~1T+)
  Problem: Diminishing returns. 10x compute → ~1.5x better.
  Cost: $100M+ per training run.

ERA 2: TEST-TIME COMPUTE SCALING (2024+)
  "Let the model think longer on hard problems"
  
  Performance ∝ inference_compute (thinking tokens)
  
  Small model + 100 thinking tokens → beats large model on reasoning
  Cost: Pay per-problem (harder problems = more tokens = more cost)
  
  KEY INSIGHT: You can DYNAMICALLY allocate compute per problem.
  Easy question → fast answer. Hard math → 10 minutes of thinking.
```

### How Reasoning Models Work

```
STANDARD LLM:
  User: "What is 27 × 34?"
  Model: "918" ← Direct answer (often wrong for harder math)
  Tokens: ~5

REASONING MODEL:
  User: "What is 27 × 34?"
  
  [THINKING — hidden from user]
  "I need to multiply 27 × 34.
   Let me break this down:
   27 × 34 = 27 × 30 + 27 × 4
   27 × 30 = 810
   27 × 4 = 108
   810 + 108 = 918
   Let me verify: 918 / 27 = 34 ✓"
  [/THINKING]
  
  Model: "918" ← Same answer, but verified
  Tokens: ~80 (thinking) + 5 (answer)
```

### The Training Pipeline

```
┌─────────────────────────────────────────────────────┐
│         HOW REASONING MODELS ARE TRAINED             │
│                                                     │
│  STEP 1: Start with a pre-trained LLM              │
│          (e.g., GPT-4 base, DeepSeek-V3 base)      │
│                                                     │
│  STEP 2: Supervised Fine-Tuning on reasoning traces │
│          Human-written step-by-step solutions        │
│          "Here's HOW to solve this problem"          │
│                                                     │
│  STEP 3: Reinforcement Learning (the key step)      │
│          ┌──────────────────────────────────────┐   │
│          │ Model generates chain-of-thought     │   │
│          │ → Check if final answer is correct   │   │
│          │ → Reward correct reasoning paths     │   │
│          │ → Penalize wrong paths               │   │
│          │ → Model learns WHICH thinking        │   │
│          │   strategies lead to right answers   │   │
│          └──────────────────────────────────────┘   │
│          Methods: PPO, GRPO (DeepSeek)              │
│                                                     │
│  STEP 4: Process Reward Models (PRM)                │
│          Don't just check the final answer —         │
│          evaluate EACH STEP of reasoning.           │
│          "Step 3 was wrong" → more granular signal  │
│                                                     │
│  Result: Model that knows WHEN and HOW to think     │
└─────────────────────────────────────────────────────┘
```

### Major Reasoning Models (March 2026)

| Model                             | Company   | Key Feature                              | Access |
| --------------------------------- | --------- | ---------------------------------------- | ------ |
| **o1**                            | OpenAI    | First reasoning model, PhD-level science | API    |
| **o3**                            | OpenAI    | Stronger reasoning, variable compute     | API    |
| **o4-mini**                       | OpenAI    | Cost-effective reasoning, fast           | API    |
| **DeepSeek-R1**                   | DeepSeek  | Open-weight, competitive with o1         | Open   |
| **QwQ**                           | Alibaba   | Open reasoning model                     | Open   |
| **Gemini 3.1 Deep Think**         | Google    | Complex technical reasoning, multimodal  | API    |
| **Claude with extended thinking** | Anthropic | Toggleable thinking mode                 | API    |

### Standard vs Reasoning: When to Use What

| Scenario                     | Use Standard LLM | Use Reasoning Model          |
| ---------------------------- | ---------------- | ---------------------------- |
| Simple Q&A, chat             | ✅ Fast, cheap    | ❌ Overkill                   |
| Translation, summarization   | ✅                | ❌                            |
| Complex math problems        | ❌ Often wrong    | ✅ Step-by-step verification  |
| Multi-step logic/planning    | ❌                | ✅                            |
| Code debugging (complex)     | ⚠️ Sometimes      | ✅ Better at tracing issues   |
| Creative writing             | ✅                | ❌ Unnecessary reasoning      |
| PhD-level science            | ❌                | ✅ Designed for this          |
| Real-time chat (low latency) | ✅                | ❌ Thinking adds latency      |
| Cost-sensitive applications  | ✅                | ⚠️ Thinking tokens cost money |

### Test-Time Compute Techniques

| Technique                   | How It Works                                     | Used In             |
| --------------------------- | ------------------------------------------------ | ------------------- |
| **Extended CoT**            | Model generates long reasoning chains            | o1, o3, DeepSeek-R1 |
| **Self-consistency**        | Generate N answers, take majority vote           | Any LLM             |
| **Best-of-N**               | Generate N answers, pick best (via reward model) | Any LLM             |
| **Monte Carlo Tree Search** | Explore reasoning paths like a chess engine      | Research            |
| **Process Reward Models**   | Score each reasoning step, not just final answer | o1, o3              |
| **Iterative refinement**    | Model critiques and improves its own answer      | Claude, GPT         |

### DeepSeek-R1: The Open-Source Breakthrough

```
WHY IT MATTERS:
  - Open-weight reasoning model competitive with o1
  - Showed reasoning can emerge from pure RL (no supervised data!)
  - "Aha moment": During training, the model spontaneously started
    re-evaluating and self-correcting — emergent reasoning behavior
  
TRAINING APPROACH (GRPO):
  Group Relative Policy Optimization
  - Generate multiple solutions in parallel
  - Rank them against each other (group-relative, not absolute)
  - No separate reward model needed
  - Simpler and cheaper than PPO

DISTILLED VERSIONS:
  DeepSeek-R1-Distill-Qwen-32B, DeepSeek-R1-Distill-Llama-70B
  → Distill R1's reasoning into smaller models
  → Available via Ollama for local use
```

---

## ◆ Code & Implementation

```python
# ═══ Using OpenAI o3 ═══
from openai import OpenAI
client = OpenAI()

response = client.chat.completions.create(
    model="o3",
    messages=[{
        "role": "user",
        "content": "Prove that √2 is irrational."
    }],
    # Reasoning models handle CoT internally
    # No need for "think step by step" prompts
    # reasoning_effort="high"  # low/medium/high — controls thinking depth
)

# The response includes the final answer
# Thinking tokens are consumed but hidden by default
print(response.choices[0].message.content)
print(f"Total tokens: {response.usage.total_tokens}")
# → Much higher token count due to internal reasoning

# ═══ Using DeepSeek-R1 locally via Ollama ═══
# ollama run deepseek-r1:8b
# The model outputs <think>...</think> blocks visibly
```

---

## ◆ Quick Reference

```
REASONING MODEL DECISION TREE:
  Is the task complex reasoning/math/logic?
    YES → Use reasoning model (o3, DeepSeek-R1)
    NO  → Use standard LLM (GPT-5.4, Claude Sonnet 4.6)

  Is latency critical?
    YES → Use standard LLM or o4-mini
    NO  → Reasoning model is fine

  Is cost critical?
    YES → o4-mini or DeepSeek-R1 (open, self-host)
    NO  → o3 with high reasoning effort

KEY NUMBERS:
  o1 on AIME 2024: 83% (vs GPT-4o: 13%)
  o3 on ARC-AGI: 87.5% (vs GPT-4o: ~5%)
  DeepSeek-R1 on MATH-500: 97.3%
  
  Thinking tokens: 500-50,000+ per problem
  Cost: 2-20x more than standard models per query
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Don't prompt "think step by step"**: Reasoning models already do this internally. Adding CoT prompts can actually hurt performance.
- ⚠️ **Cost surprise**: A single complex query can consume 50K+ tokens of thinking. Monitor costs closely.
- ⚠️ **Latency**: Thinking takes time. A hard math problem might take 30-60 seconds. Not suitable for real-time chat.
- ⚠️ **Not always better**: For simple tasks, reasoning models waste compute and can overthink. Use standard models for simple tasks.
- ⚠️ **Hidden thinking ≠ explainable**: You see the answer but not always the reasoning (o1/o3 hide thinking by default).

---

## ○ Interview Angles

- **Q**: What is test-time compute scaling and why does it matter?
- **A**: Instead of scaling model size (pre-training compute), you scale compute at inference — let the model "think longer" on harder problems. This is more efficient because you allocate compute per-problem (easy = cheap, hard = expensive) rather than baking it all into a massive model. o1/o3 showed this can match or exceed much larger standard models.

- **Q**: How is DeepSeek-R1 trained?
- **A**: Uses GRPO (Group Relative Policy Optimization). Generate multiple reasoning chains for a problem, rank them group-relatively, and reinforce better paths. Remarkably, reasoning behavior (self-correction, re-evaluation) emerged purely from RL without supervised reasoning data.

- **Q**: When would you NOT use a reasoning model?
- **A**: Simple tasks (chat, translation, summarization), latency-critical applications (real-time), cost-sensitive high-volume scenarios, and creative tasks where "thinking" adds no value. Reasoning models are for problems where correct step-by-step logic matters.

---

## ★ Connections

| Relationship | Topics                                                                                                                                  |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [[llms-overview]], [[../techniques/prompt-engineering]] (CoT), [[../prerequisites/deep-learning-fundamentals]] (RL)                     |
| Leads to     | [[../ethics-and-safety/ethics-safety-alignment]] (alignment via RL), [[../inference/inference-optimization]] (serving reasoning models) |
| Compare with | Standard LLMs (direct generation), [[../techniques/ai-agents]] (multi-step but external planning)                                       |
| Cross-domain | Formal verification, Theorem proving, Game AI (MCTS)                                                                                    |

---

## ★ Sources

- OpenAI, "Learning to Reason with LLMs" (o1 blog post, Sep 2024)
- DeepSeek, "DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning" (Jan 2025)
- Snell et al., "Scaling LLM Test-Time Compute" (2024)
- OpenAI o3, o4-mini release announcements (2025)
