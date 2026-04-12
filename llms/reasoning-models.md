---
title: "Reasoning Models & Test-Time Compute"
tags: [reasoning, o1, o3, chain-of-thought, test-time-compute, deepseek-r1, thinking, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[llms-overview]]", "[[../foundations/transformers]]", "[[../techniques/prompt-engineering]]"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Reasoning Models & Test-Time Compute

> âœ¨ **Bit**: Pre-2024: "Make the model bigger to make it smarter." Post-2024: "Make the model THINK LONGER to make it smarter." This shift â€” from scaling training compute to scaling inference compute â€” is the biggest paradigm change since the Transformer.

---

## â˜… TL;DR

- **What**: LLMs that generate internal "thinking" chains before answering, trading more inference compute for dramatically better reasoning
- **Why**: Standard LLMs fail at complex math, logic, and multi-step problems. Reasoning models solve these by "thinking step by step" internally â€” not as a prompting trick, but as a trained capability
- **Key point**: o1/o3/DeepSeek-R1 represent a new scaling law â€” **test-time compute scaling** â€” where spending more compute at inference yields better answers, sometimes surpassing even larger standard models

---

## â˜… Overview

### Definition

**Reasoning models** are LLMs specifically trained (usually via reinforcement learning) to produce extended chains of internal reasoning before generating a final answer. Unlike standard LLMs that generate responses token-by-token in one pass, reasoning models generate a hidden "thinking" block where they plan, verify, backtrack, and self-correct.

### Scope

Covers: Reasoning model architectures, test-time compute scaling, process reward models, and when to use reasoning vs standard models. For basic prompting techniques (zero-shot CoT), see [Prompt Engineering](../techniques/prompt-engineering.md). For standard LLM overview, see [Llms Overview](./llms-overview.md).

Last verified for model-lineup and timeline references: 2026-04.

### Significance

- o1 (Sep 2024) proved reasoning models can solve PhD-level problems standard LLMs can't
- DeepSeek-R1 (Jan 2025) showed open-source reasoning is viable
- This is the #1 interview topic for frontier GenAI roles in 2025-2026
- Fundamentally changes when to use "bigger model" vs "more thinking time"

### Prerequisites

- [Llms Overview](./llms-overview.md) â€” how standard LLMs work
- [Prompt Engineering](../techniques/prompt-engineering.md) â€” chain-of-thought prompting
- [Probability And Statistics](../prerequisites/probability-and-statistics.md) â€” reinforcement learning basics

---

## â˜… Deep Dive

### The Two Scaling Laws

```
ERA 1: PRE-TRAINING SCALING (2020-2024)
  "Make the model bigger, train on more data"

  Performance âˆ model_size Ã— data_size Ã— training_compute

  GPT-3 (175B) â†’ GPT-4 (~1.8T) â†’ GPT-5 (~1T+)
  Problem: Diminishing returns. 10x compute â†’ ~1.5x better.
  Cost: $100M+ per training run.

ERA 2: TEST-TIME COMPUTE SCALING (2024+)
  "Let the model think longer on hard problems"

  Performance âˆ inference_compute (thinking tokens)

  Small model + 100 thinking tokens â†’ beats large model on reasoning
  Cost: Pay per-problem (harder problems = more tokens = more cost)

  KEY INSIGHT: You can DYNAMICALLY allocate compute per problem.
  Easy question â†’ fast answer. Hard math â†’ 10 minutes of thinking.
```

### How Reasoning Models Work

```
STANDARD LLM:
  User: "What is 27 Ã— 34?"
  Model: "918" â† Direct answer (often wrong for harder math)
  Tokens: ~5

REASONING MODEL:
  User: "What is 27 Ã— 34?"

  [THINKING â€” hidden from user]
  "I need to multiply 27 Ã— 34.
   Let me break this down:
   27 Ã— 34 = 27 Ã— 30 + 27 Ã— 4
   27 Ã— 30 = 810
   27 Ã— 4 = 108
   810 + 108 = 918
   Let me verify: 918 / 27 = 34 âœ“"
  [/THINKING]

  Model: "918" â† Same answer, but verified
  Tokens: ~80 (thinking) + 5 (answer)
```

### The Training Pipeline

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         HOW REASONING MODELS ARE TRAINED             â”‚
â”‚                                                     â”‚
â”‚  STEP 1: Start with a pre-trained LLM              â”‚
â”‚          (e.g., GPT-4 base, DeepSeek-V3 base)      â”‚
â”‚                                                     â”‚
â”‚  STEP 2: Supervised Fine-Tuning on reasoning traces â”‚
â”‚          Human-written step-by-step solutions        â”‚
â”‚          "Here's HOW to solve this problem"          â”‚
â”‚                                                     â”‚
â”‚  STEP 3: Reinforcement Learning (the key step)      â”‚
â”‚          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”‚
â”‚          â”‚ Model generates chain-of-thought     â”‚   â”‚
â”‚          â”‚ â†’ Check if final answer is correct   â”‚   â”‚
â”‚          â”‚ â†’ Reward correct reasoning paths     â”‚   â”‚
â”‚          â”‚ â†’ Penalize wrong paths               â”‚   â”‚
â”‚          â”‚ â†’ Model learns WHICH thinking        â”‚   â”‚
â”‚          â”‚   strategies lead to right answers   â”‚   â”‚
â”‚          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â”‚
â”‚          Methods: PPO, GRPO (DeepSeek)              â”‚
â”‚                                                     â”‚
â”‚  STEP 4: Process Reward Models (PRM)                â”‚
â”‚          Don't just check the final answer â€”         â”‚
â”‚          evaluate EACH STEP of reasoning.           â”‚
â”‚          "Step 3 was wrong" â†’ more granular signal  â”‚
â”‚                                                     â”‚
â”‚  Result: Model that knows WHEN and HOW to think     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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
| Simple Q&A, chat             | âœ… Fast, cheap    | âŒ Overkill                   |
| Translation, summarization   | âœ…                | âŒ                            |
| Complex math problems        | âŒ Often wrong    | âœ… Step-by-step verification  |
| Multi-step logic/planning    | âŒ                | âœ…                            |
| Code debugging (complex)     | âš ï¸ Sometimes      | âœ… Better at tracing issues   |
| Creative writing             | âœ…                | âŒ Unnecessary reasoning      |
| PhD-level science            | âŒ                | âœ… Designed for this          |
| Real-time chat (low latency) | âœ…                | âŒ Thinking adds latency      |
| Cost-sensitive applications  | âœ…                | âš ï¸ Thinking tokens cost money |

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
    re-evaluating and self-correcting â€” emergent reasoning behavior

TRAINING APPROACH (GRPO):
  Group Relative Policy Optimization
  - Generate multiple solutions in parallel
  - Rank them against each other (group-relative, not absolute)
  - No separate reward model needed
  - Simpler and cheaper than PPO

DISTILLED VERSIONS:
  DeepSeek-R1-Distill-Qwen-32B, DeepSeek-R1-Distill-Llama-70B
  â†’ Distill R1's reasoning into smaller models
  â†’ Available via Ollama for local use
```

---

## â—† Code & Implementation

```python
# â•â•â• Using OpenAI o3 â•â•â•
from openai import OpenAI
client = OpenAI()

response = client.chat.completions.create(
    model="o3",
    messages=[{
        "role": "user",
        "content": "Prove that âˆš2 is irrational."
    }],
    # Reasoning models handle CoT internally
    # No need for "think step by step" prompts
    # reasoning_effort="high"  # low/medium/high â€” controls thinking depth
)

# The response includes the final answer
# Thinking tokens are consumed but hidden by default
print(response.choices[0].message.content)
print(f"Total tokens: {response.usage.total_tokens}")
# â†’ Much higher token count due to internal reasoning

# â•â•â• Using DeepSeek-R1 locally via Ollama â•â•â•
# ollama run deepseek-r1:8b
# The model outputs <think>...</think> blocks visibly
```

---

## â—† Quick Reference

```
REASONING MODEL DECISION TREE:
  Is the task complex reasoning/math/logic?
    YES â†’ Use reasoning model (o3, DeepSeek-R1)
    NO  â†’ Use standard LLM (GPT-5.4, Claude Sonnet 4.6)

  Is latency critical?
    YES â†’ Use standard LLM or o4-mini
    NO  â†’ Reasoning model is fine

  Is cost critical?
    YES â†’ o4-mini or DeepSeek-R1 (open, self-host)
    NO  â†’ o3 with high reasoning effort

KEY NUMBERS:
  o1 on AIME 2024: 83% (vs GPT-4o: 13%)
  o3 on ARC-AGI: 87.5% (vs GPT-4o: ~5%)
  DeepSeek-R1 on MATH-500: 97.3%

  Thinking tokens: 500-50,000+ per problem
  Cost: 2-20x more than standard models per query
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Don't prompt "think step by step"**: Reasoning models already do this internally. Adding CoT prompts can actually hurt performance.
- âš ï¸ **Cost surprise**: A single complex query can consume 50K+ tokens of thinking. Monitor costs closely.
- âš ï¸ **Latency**: Thinking takes time. A hard math problem might take 30-60 seconds. Not suitable for real-time chat.
- âš ï¸ **Not always better**: For simple tasks, reasoning models waste compute and can overthink. Use standard models for simple tasks.
- âš ï¸ **Hidden thinking â‰  explainable**: You see the answer but not always the reasoning (o1/o3 hide thinking by default).

---

## â—‹ Interview Angles

- **Q**: What is test-time compute scaling and why does it matter?
- **A**: Instead of scaling model size (pre-training compute), you scale compute at inference â€” let the model "think longer" on harder problems. This is more efficient because you allocate compute per-problem (easy = cheap, hard = expensive) rather than baking it all into a massive model. o1/o3 showed this can match or exceed much larger standard models.

- **Q**: How is DeepSeek-R1 trained?
- **A**: Uses GRPO (Group Relative Policy Optimization). Generate multiple reasoning chains for a problem, rank them group-relatively, and reinforce better paths. Remarkably, reasoning behavior (self-correction, re-evaluation) emerged purely from RL without supervised reasoning data.

- **Q**: When would you NOT use a reasoning model?
- **A**: Simple tasks (chat, translation, summarization), latency-critical applications (real-time), cost-sensitive high-volume scenarios, and creative tasks where "thinking" adds no value. Reasoning models are for problems where correct step-by-step logic matters.

---

## â˜… Connections

| Relationship | Topics                                                                                                                                  |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Llms Overview](./llms-overview.md), [Prompt Engineering](../techniques/prompt-engineering.md) (CoT), [Deep Learning Fundamentals](../prerequisites/deep-learning-fundamentals.md) (RL)                     |
| Leads to     | [Ethics Safety Alignment](../ethics-and-safety/ethics-safety-alignment.md) (alignment via RL), [Inference Optimization](../inference/inference-optimization.md) (serving reasoning models) |
| Compare with | Standard LLMs (direct generation), [Ai Agents](../techniques/ai-agents.md) (multi-step but external planning)                                       |
| Cross-domain | Formal verification, Theorem proving, Game AI (MCTS)                                                                                    |

---

## â˜… Sources

- OpenAI, "Learning to Reason with LLMs" (o1 blog post, Sep 2024)
- DeepSeek, "DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning" (Jan 2025)
- Snell et al., "Scaling LLM Test-Time Compute" (2024)
- OpenAI o3, o4-mini release announcements (2025)
