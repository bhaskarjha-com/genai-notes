---
title: "Reinforcement Learning for LLM Alignment"
aliases: ["RLHF", "DPO", "Alignment", "Reinforcement Learning"]
tags: [rlhf, dpo, ppo, grpo, alignment, reward-model, preference-optimization, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../ethics-and-safety/ethics-safety-alignment.md", "../llms/llms-overview.md", "../llms/reasoning-models.md", "fine-tuning.md"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Reinforcement Learning for LLM Alignment

> âœ¨ **Bit**: Pre-training gives the model knowledge. SFT gives it manners. RL alignment gives it values. Without this step, GPT would be a Wikipedia-quoting sociopath â€” brilliant but unsafe. RLHF, DPO, and GRPO are HOW we teach models to be helpful, harmless, and honest.

---

## â˜… TL;DR

- **What**: Techniques that align LLM behavior with human preferences using reinforcement learning or preference optimization
- **Why**: Pre-trained LLMs know a lot but don't know WHAT to say. Alignment makes them helpful, honest, and harmless.
- **Key point**: The field has rapidly evolved: RLHF (complex, expensive) â†’ DPO (simpler, no reward model) â†’ GRPO (no critic, efficient, powers DeepSeek-R1). Each generation trades complexity for efficiency.

---

## â˜… Overview

### Definition

**Alignment** is the process of ensuring an LLM's outputs are helpful, honest, and harmless â€” matching human intent and values. RL-based alignment techniques fine-tune model behavior using human preferences rather than just demonstration data.

### Scope

Covers the full alignment technique landscape: RLHF, DPO, PPO, GRPO, ORPO, KTO. For the safety/policy layer (guardrails, bias, regulations), see [Ethics Safety Alignment](../ethics-and-safety/ethics-safety-alignment.md). For basic fine-tuning (LoRA/QLoRA), see [Fine Tuning](./fine-tuning.md).

### Significance

- Every commercial LLM (GPT-4, Claude, Gemini) uses alignment training
- GRPO is how DeepSeek-R1 achieves reasoning â€” the user asked about this specifically
- Understanding this is required for ML Engineer / GenAI Researcher roles
- Active research frontier: new techniques every 6 months

---

## â˜… Deep Dive

### The LLM Training Pipeline

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         COMPLETE LLM TRAINING PIPELINE               â”‚
â”‚                                                     â”‚
â”‚  STAGE 1: PRE-TRAINING                              â”‚
â”‚  Train on internet text â†’ predict next token        â”‚
â”‚  Result: knows a lot, but no conversational skills  â”‚
â”‚  Cost: $10M-$100M+                                  â”‚
â”‚                â”‚                                    â”‚
â”‚                â–¼                                    â”‚
â”‚  STAGE 2: SUPERVISED FINE-TUNING (SFT)              â”‚
â”‚  Train on (instruction, response) pairs              â”‚
â”‚  "How to be helpful" â€” demonstration data           â”‚
â”‚  Result: can follow instructions, chat format       â”‚
â”‚  Cost: $1K-$100K                                    â”‚
â”‚                â”‚                                    â”‚
â”‚                â–¼                                    â”‚
â”‚  STAGE 3: ALIGNMENT / PREFERENCE OPTIMIZATION       â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚  RLHF  â”‚  DPO  â”‚  GRPO  â”‚  ORPO  â”‚  KTO   â”‚    â”‚
â”‚  â”‚        Choose one (or combine)              â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚  "How to be GOOD" â€” preference data                 â”‚
â”‚  Result: helpful, harmless, honest                  â”‚
â”‚  Cost: $10K-$1M                                     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### 1. RLHF (Reinforcement Learning from Human Feedback)

```
THE CLASSIC 3-STAGE PIPELINE:

  STEP 1: Collect Preference Data
    Prompt: "Explain quantum computing"
    Response A: [technical, complete, accurate]
    Response B: [vague, wrong, harmful]
    Human annotator: A > B  âœ“

  STEP 2: Train Reward Model
    Input: (prompt, response) â†’ Output: scalar score
    The reward model LEARNS what humans prefer
    Trained on 100K+ comparison pairs

  STEP 3: Optimize Policy with PPO
    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
    â”‚  LLM generates response                   â”‚
    â”‚       â”‚                                   â”‚
    â”‚       â–¼                                   â”‚
    â”‚  Reward model scores response             â”‚
    â”‚       â”‚                                   â”‚
    â”‚       â–¼                                   â”‚
    â”‚  PPO updates LLM weights to increase      â”‚
    â”‚  probability of high-reward responses     â”‚
    â”‚       â”‚                                   â”‚
    â”‚       â–¼                                   â”‚
    â”‚  KL penalty prevents drifting too far     â”‚
    â”‚  from the SFT model (avoid reward hacking)â”‚
    â”‚       â”‚                                   â”‚
    â”‚       â–¼                                   â”‚
    â”‚  Repeat thousands of times                â”‚
    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

USED BY: OpenAI (GPT-4), early Claude models
PROS: Powerful, handles complex preferences
CONS: 4 models in memory (policy, ref, reward, value),
      unstable training, expensive, reward hacking risk
```

### 2. PPO (Proximal Policy Optimization)

```
PPO = The RL algorithm USED INSIDE RLHF (Step 3)

KEY IDEA: Update the model, but not TOO much at once.
  "Take small, careful steps in parameter space"

HOW:
  ratio = Ï€_new(action) / Ï€_old(action)

  Clipped objective:
    L = min(ratio Ã— advantage,
            clip(ratio, 1-Îµ, 1+Îµ) Ã— advantage)

  If ratio > 1+Îµ â†’ clip it (prevent too-large updates)
  If ratio < 1-Îµ â†’ clip it (prevent too-large updates)
  Îµ typically = 0.2

REQUIRES:
  - Policy model (the LLM being trained)
  - Value model (estimates expected future reward)
  - Reference model (prevents drift via KL penalty)
  - Reward model (scores quality)
  = 4 MODELS IN MEMORY!

PROS: Stable, well-understood, robust
CONS: Memory-heavy (4 models), complex hyperparameters
```

### 3. DPO (Direct Preference Optimization)

```
DPO = "Skip the reward model, skip the RL â€” just optimize directly"

KEY INSIGHT (Rafailov et al., 2023):
  The RLHF objective can be MATHEMATICALLY REARRANGED
  into a simple classification loss!

  Instead of: train reward model â†’ run PPO
  Do:         directly optimize on preference pairs

  Loss = -log Ïƒ(Î² Ã— (log Ï€(y_w|x) - log Ï€(y_l|x)
                     - log Ï€_ref(y_w|x) + log Ï€_ref(y_l|x)))

  Where:
    y_w = preferred (winning) response
    y_l = dispreferred (losing) response
    Ï€    = current policy
    Ï€_ref = reference (SFT) model
    Î²    = temperature controlling deviation from ref

IN PLAIN ENGLISH:
  "Increase the probability of good responses,
   decrease the probability of bad responses,
   but don't stray too far from the starting model."

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  RLHF:  SFT â†’ Reward Model â†’ PPO training  â”‚
  â”‚         3 stages, 4 models, complex          â”‚
  â”‚                                             â”‚
  â”‚  DPO:   SFT â†’ Direct optimization           â”‚
  â”‚         1 stage, 2 models (policy + ref),    â”‚
  â”‚         simple as fine-tuning!               â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

USED BY: LLaMA 2-Chat, Zephyr, many open-source models
PROS: Simple, stable, cheap, easy to implement
CONS: Quality depends heavily on preference data quality,
      may underperform PPO on hardest tasks
```

### 4. GRPO (Group Relative Policy Optimization) â­

```
GRPO = "PPO WITHOUT the critic/value model"
       Pioneered by DeepSeek (DeepSeek-Math, DeepSeek-R1)

THE KEY INNOVATION:
  PPO needs a value model to estimate "advantage"
  (how much better is this response than expected?)

  GRPO says: "Don't estimate. MEASURE DIRECTLY."

  For each prompt, generate G responses (a group).
  Score each with the reward model.
  Use the GROUP MEAN as the baseline.

  advantage_i = (reward_i - mean(group_rewards)) / std(group_rewards)

  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  GRPO TRAINING LOOP                           â”‚
  â”‚                                               â”‚
  â”‚  1. Sample prompt                             â”‚
  â”‚  2. Generate G responses (e.g., G=16)         â”‚
  â”‚     Response 1: "Let me think... answer: 42"  â”‚
  â”‚     Response 2: "The answer is 43"            â”‚
  â”‚     ...                                       â”‚
  â”‚     Response 16: "Hmm, 27 Ã— 3 = 81... no..."  â”‚
  â”‚                                               â”‚
  â”‚  3. Score each with reward (e.g., correctness)â”‚
  â”‚     R1=1.0, R2=0.0, R3=0.5, ... R16=0.0     â”‚
  â”‚                                               â”‚
  â”‚  4. Compute group advantage                   â”‚
  â”‚     mean = 0.35, std = 0.4                    â”‚
  â”‚     adv_1 = (1.0 - 0.35) / 0.4 = 1.625      â”‚
  â”‚     adv_2 = (0.0 - 0.35) / 0.4 = -0.875     â”‚
  â”‚                                               â”‚
  â”‚  5. Update policy:                            â”‚
  â”‚     - Increase prob of response 1 (adv > 0)  â”‚
  â”‚     - Decrease prob of response 2 (adv < 0)  â”‚
  â”‚     + KL penalty to stay near reference       â”‚
  â”‚     + Clipped objective (like PPO)            â”‚
  â”‚                                               â”‚
  â”‚  6. Repeat for thousands of prompts           â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

WHY IT MATTERS:
  Memory: ~50% less than PPO (no value model!)
  Stability: Group baseline has lower variance
  Reasoning: Particularly effective for math/code

  DeepSeek-R1-Zero: Pure GRPO (no SFT!) â†’
    Model SPONTANEOUSLY developed chain-of-thought,
    self-correction, and "aha moment" behaviors.
    Reasoning emerged from RL alone!

REWARD TYPES:
  RLHF: Learned reward model (human preferences)
  RLVR: Verifiable rewards (math = check answer,
         code = run tests) â† What DeepSeek-R1 uses!
         No human labels needed for verifiable tasks.
```

### 5. Emerging Alternatives

| Technique                        | Key Idea                                                 | Status            |
| -------------------------------- | -------------------------------------------------------- | ----------------- |
| **ORPO** (Odds Ratio Preference) | Combines SFT + alignment in one step, no reference model | Growing adoption  |
| **KTO** (Kahneman-Tversky)       | Works with binary feedback (good/bad) instead of pairs   | Research          |
| **SimPO**                        | Simplified preference, length-normalized                 | Research          |
| **IPO** (Identity Preference)    | Fixes DPO's overfitting issue                            | Research          |
| **Self-Play**                    | Model debates itself, no human labels                    | Research (Google) |

---

## â—† The Complete Comparison

| Feature                | RLHF+PPO                       | DPO                             | GRPO                                    |
| ---------------------- | ------------------------------ | ------------------------------- | --------------------------------------- |
| **Reward model**       | âœ… Required                     | âŒ Not needed                    | âš ï¸ Optional (can use verifiable rewards) |
| **Value/Critic model** | âœ… Required                     | âŒ Not needed                    | âŒ Not needed                            |
| **Models in memory**   | 4 (policy, ref, reward, value) | 2 (policy, ref)                 | 2-3 (policy, ref, +optional reward)     |
| **Complexity**         | Very high                      | Low                             | Medium                                  |
| **Stability**          | âš ï¸ Can be unstable              | âœ… Stable                        | âœ… Stable                                |
| **Data needed**        | Preference pairs + RL rollouts | Preference pairs only           | Prompts + reward signal                 |
| **Memory usage**       | Highest                        | Lowest                          | ~50% of PPO                             |
| **Best for**           | Complex alignment              | Simple alignment, open-source   | Reasoning, math, code                   |
| **Used by**            | GPT-4, early Claude            | LLaMA-Chat, Zephyr, open models | DeepSeek-R1, DeepSeek-Math              |
| **Year introduced**    | 2022 (InstructGPT)             | 2023 (Stanford)                 | 2024 (DeepSeek)                         |

---

## â—† Quick Reference

```
DECISION TREE:
  Building a chat model with general alignment?
    Budget high â†’ RLHF+PPO (most proven)
    Budget low  â†’ DPO (simplest, cheapest)

  Building a reasoning model (math, code)?
    â†’ GRPO + verifiable rewards (RLVR)

  Have only binary feedback (ðŸ‘/ðŸ‘Ž)?
    â†’ KTO (works without paired comparisons)

  Want SFT + alignment in one step?
    â†’ ORPO (saves training time)

KEY FORMULAS:
  PPO:  L = min(rÂ·A, clip(r, 1Â±Îµ)Â·A
  DPO:  L = -log Ïƒ(Î²(log Ï€/Ï€_ref on chosen - log Ï€/Ï€_ref on rejected))
  GRPO: advantage = (reward_i - mean(rewards)) / std(rewards)
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Reward hacking**: In RLHF, models learn to exploit the reward model's weaknesses rather than genuinely improving. KL penalty helps but doesn't eliminate this.
- âš ï¸ **DPO data quality**: DPO is only as good as its preference pairs. Noisy or biased data = poorly aligned model.
- âš ï¸ **GRPO needs multiple samples**: Generating G=16 responses per prompt during training is compute-intensive. Trade-off: more samples = better gradient estimate.
- âš ï¸ **Alignment tax**: All alignment techniques slightly reduce raw capability. The model gets "safer" but may lose some edge-case knowledge.
- âš ï¸ **RLHF â‰  RLVR**: For math/code, verifiable rewards (check answer correctness) are BETTER than learned reward models. GRPO + RLVR is the DeepSeek recipe.

---

## â—‹ Interview Angles

- **Q**: What is GRPO and how is it different from PPO?
- **A**: GRPO eliminates the value/critic network that PPO requires. Instead of estimating expected rewards, GRPO generates multiple responses per prompt and uses the group mean reward as a baseline. This cuts memory by ~50% and provides lower-variance advantage estimates. DeepSeek-R1 used GRPO to achieve state-of-the-art reasoning by rewarding correct final answers (RLVR) rather than training a separate reward model.

- **Q**: Compare RLHF and DPO.
- **A**: RLHF trains a separate reward model on human preferences, then uses PPO to optimize the LLM against it â€” complex (4 models in memory), expensive, but powerful. DPO mathematically rearranges the RLHF objective into a direct classification loss on preference pairs â€” simpler (2 models), cheaper, more stable, and achieves comparable results on many tasks. DPO is the go-to for open-source model alignment.

- **Q**: What is RLVR?
- **A**: Reinforcement Learning from Verifiable Rewards. Instead of using a learned reward model (which can be gamed), use objectively verifiable rewards: does the code pass tests? Does the math answer match? This is more robust for reasoning tasks and is what powers DeepSeek-R1's math capabilities.

---

## â˜… Code & Implementation

### DPO Training Data Format + Trainer Setup

```python
# pip install transformers>=4.40 trl>=0.8 datasets peft>=0.10
# âš ï¸ Last tested: 2026-04 | Requires: GPU, trl>=0.8, HuggingFace login
from datasets import Dataset
from trl import DPOTrainer, DPOConfig
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import LoraConfig

# DPO data format: prompt + chosen response + rejected response
dpo_data = [
    {
        "prompt":   "What is the capital of France?",
        "chosen":   "The capital of France is Paris.",
        "rejected": "France is a country in Europe.",
    },
    {
        "prompt":   "Summarize the transformer architecture.",
        "chosen":   "Transformers use self-attention to process sequences in parallel, enabling long-range dependency capture without recurrence.",
        "rejected": "Transformers are neural networks used for NLP tasks.",
    },
]
dataset = Dataset.from_list(dpo_data)

model_id  = "google/gemma-2-2b-it"     # small model for demo
tokenizer = AutoTokenizer.from_pretrained(model_id)
model     = AutoModelForCausalLM.from_pretrained(model_id)

lora_config = LoraConfig(r=8, lora_alpha=16, target_modules=["q_proj", "v_proj"])

config = DPOConfig(
    output_dir="./dpo-output",
    num_train_epochs=1,
    per_device_train_batch_size=1,
    learning_rate=5e-6,
    beta=0.1,           # KL penalty coefficient â€” higher = closer to reference model
    logging_steps=5,
)

trainer = DPOTrainer(
    model=model,
    ref_model=None,        # None = use PEFT reference internally
    args=config,
    train_dataset=dataset,
    tokenizer=tokenizer,
    peft_config=lora_config,
)
# trainer.train()  # Uncomment to train (requires GPU)
print("DPO trainer initialized. Dataset:", dataset)
print("Beta (KL coeff):", config.beta)
```

## â˜… Connections

| Relationship | Topics                                                                                                                                                 |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Builds on    | [Fine Tuning](./fine-tuning.md) (SFT stage), [Deep Learning Fundamentals](../prerequisites/deep-learning-fundamentals.md) (optimization)               |
| Leads to     | [Reasoning Models](../llms/reasoning-models.md) (GRPO â†’ R1), [Ethics Safety Alignment](../ethics-and-safety/ethics-safety-alignment.md) (safety layer) |
| Compare with | Constitutional AI (Anthropic's approach), Self-play                                                                                                    |
| Cross-domain | Game theory, Behavioural economics (KTO), Curriculum learning                                                                                          |


---

## â—† Production Failure Modes

| Failure                           | Symptoms                                              | Root Cause                                           | Mitigation                                                         |
| --------------------------------- | ----------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------ |
| **Reward model overoptimization** | High reward scores but sycophantic or robotic outputs | Policy exploits reward model weaknesses              | KL divergence penalty, reward model ensembles, periodic human eval |
| **Mode collapse**                 | Model produces same style/format regardless of prompt | Insufficient exploration, overly strong optimization | Temperature tuning, entropy bonus, diverse training prompts        |
| **Alignment tax**                 | Model becomes "safe" but less capable or helpful      | Over-cautious refusal behavior                       | Balanced training data (helpful + harmless), capability benchmarks |
| **Preference data bias**          | Model reflects annotator biases, not user preferences | Homogeneous annotator pool, unclear guidelines       | Diverse annotators, inter-annotator agreement checks               |
| **PPO training instability**      | Loss diverges, reward spikes then crashes             | Hyperparameter sensitivity (clip ratio, GAE lambda)  | DPO for stability, gradient clipping, careful PPO tuning           |

---

## â—† Hands-On Exercises

### Exercise 1: Compare DPO vs PPO on a Toy Task

**Goal**: Understand practical differences between DPO and PPO alignment
**Time**: 45 minutes
**Steps**:
1. Create a preference dataset of 100 chosen/rejected pairs for helpfulness
2. Fine-tune a small model with DPO using TRL
3. Fine-tune the same model with PPO+reward model
4. Compare output quality, training time, and stability
**Expected Output**: Side-by-side comparison table (quality, training curves, wall time)

### Exercise 2: Detect Reward Hacking

**Goal**: Deliberately cause and detect reward model overoptimization
**Time**: 30 minutes
**Steps**:
1. Train a simple reward model on preferences
2. Optimize policy against it for too many steps (no KL penalty)
3. Plot reward score vs human preference as training progresses
4. Identify the point where reward diverges from quality
**Expected Output**: Plot showing reward overoptimization inflection point
---


## â˜… Recommended Resources

| Type    | Resource                                                               | Why                                                   |
| ------- | ---------------------------------------------------------------------- | ----------------------------------------------------- |
| ðŸ“„ Paper | [Ouyang et al. "InstructGPT" (2022)](https://arxiv.org/abs/2203.02155) | Definitive RLHF paper â€” SFT â†’ RM â†’ PPO pipeline       |
| ðŸ“„ Paper | [Rafailov et al. "DPO" (2023)](https://arxiv.org/abs/2305.18290)       | DPO as simpler alternative to PPO                     |
| ðŸ“˜ Book  | "AI Engineering" by Chip Huyen (2025), Ch 5                            | Covers RLHF, DPO, and alignment in production context |
| ðŸŽ¥ Video | [Hugging Face â€” "RLHF Explained"](https://huggingface.co/blog/rlhf)    | Clear visual walkthrough of the RLHF pipeline         |

## â˜… Sources

- Ouyang et al., "Training Language Models to Follow Instructions with Human Feedback" (InstructGPT/RLHF, 2022)
- Rafailov et al., "Direct Preference Optimization" (DPO, 2023)
- Schulman et al., "Proximal Policy Optimization Algorithms" (PPO, 2017)
- DeepSeek, "DeepSeek-Math: Pushing the Limits via Reinforcement Learning" (GRPO, 2024)
- DeepSeek, "DeepSeek-R1" (GRPO + RLVR at scale, 2025)
- Hong et al., "ORPO: Monolithic Preference Optimization without Reference Model" (2024)
