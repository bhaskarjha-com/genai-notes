---
title: "Advanced Fine-Tuning for LLM Adaptation"
aliases: ["LoRA", "QLoRA", "PEFT", "Parameter-Efficient"]
tags: [fine-tuning, dpo, grpo, unsloth, trl, llm-training]
type: procedure
difficulty: expert
status: published
last_verified: 2026-04
parent: "fine-tuning.md"
related: ["rl-alignment.md", "synthetic-data-and-data-engineering.md", "distillation-and-compression.md"]
source: "Multiple sources - see Sources"
created: 2026-04-12
updated: 2026-04-15
---

# Advanced Fine-Tuning for LLM Adaptation

> ✨ **Bit**: Basic SFT teaches a model what good answers look like. DPO teaches it which of two answers to prefer. GRPO teaches it to improve by comparing its own attempts. The progression is: imitation → preference → self-improvement.

---

## ★ TL;DR

- **What**: Fine-tuning techniques beyond standard SFT — preference optimization (DPO, ORPO, KTO), RL-style training (GRPO, PPO), continued pretraining, and efficient training stacks (QLoRA, Unsloth)
- **Why**: SFT alone cannot teach nuanced preferences, reasoning quality, or consistent tool use. You need preference signals and reward-based training.
- **Key point**: The algorithm matters less than data quality. DPO with great preference pairs beats GRPO with noisy rewards every time.

---

## ★ Overview

### Scope

This note focuses on advanced post-training methods: DPO, ORPO, KTO, GRPO, continued pretraining, and practical accelerators (TRL, Unsloth). For SFT and LoRA foundations, see [Fine-Tuning LLMs](./fine-tuning.md). For the theoretical RLHF pipeline, see [RL Alignment](./rl-alignment.md).

### When You Need Advanced Fine-Tuning

| Signal | What It Means | Technique |
|--------|--------------|-----------|
| SFT model follows format but gives wrong answers | Need preference signal, not just imitation | DPO / ORPO |
| Model reasons poorly on multi-step problems | Need rollout-based reward training | GRPO |
| Tool use is inconsistent (calls wrong tool 30% of time) | Need negative examples showing wrong tool choices | DPO with tool-use pairs |
| Model is too verbose or refuses too aggressively | Behavior drifted during SFT | DPO with conciseness/helpfulness pairs |
| Domain language is very different (legal, medical) | Model's internal prior needs adaptation | Continued pretraining |
| Limited GPU budget (single GPU, 24GB) | Need memory-efficient training | QLoRA + Unsloth |

### Decision Tree

```
Do you have labeled preference pairs (chosen/rejected)?
├── YES → Do you also have reward scores?
│          ├── YES → GRPO or PPO (RL-style, strongest but hardest)
│          └── NO  → DPO (simplest preference method)
└── NO  → Can you generate them?
           ├── YES → Use LLM-as-judge to create pairs → DPO
           └── NO  → Do you have positive examples only?
                      ├── YES → KTO (binary "good/bad" signal, no pairs needed)
                      └── NO  → Start with SFT, collect feedback, return here
```

### Prerequisites

- [Fine-Tuning LLMs](./fine-tuning.md) — SFT, LoRA, QLoRA foundations
- [RL Alignment](./rl-alignment.md) — RLHF theory, reward modeling
- [Synthetic Data & Data Engineering](./synthetic-data-and-data-engineering.md) — creating training data

---

## ★ Deep Dive

### The Post-Training Landscape

```
              DIFFICULTY / INFRASTRUCTURE →
           ┌───────────────────────────────────────────────────────┐
           │                                                       │
    Low    │   SFT         KTO         DPO         ORPO           │
           │   (imitate)   (binary)    (pairs)     (combined)     │
           │                                                       │
           │                    IPO         SimPO                  │
           │                    (robust)    (simple)               │
           │                                                       │
    High   │                              GRPO        PPO         │
           │                              (groups)    (full RL)    │
           │                                                       │
           └───────────────────────────────────────────────────────┘
                     ALIGNMENT QUALITY →
```

### DPO: Direct Preference Optimization

**The key insight**: DPO shows that you can extract the optimal policy directly from preference data without ever training a reward model or running PPO. It reformulates the RLHF objective into a simple classification loss.

**DPO Loss Function**:

```
L_DPO(π_θ; π_ref) = -E_(x, y_w, y_l) [
    log σ(β · (log π_θ(y_w|x)/π_ref(y_w|x) - log π_θ(y_l|x)/π_ref(y_l|x)))
]

Where:
  π_θ     = policy model being trained
  π_ref   = reference model (frozen copy of the base model)
  y_w     = preferred (winning) response
  y_l     = rejected (losing) response
  x       = prompt
  β       = temperature parameter (controls deviation from reference)
  σ       = sigmoid function

Intuition: The loss increases the probability of preferred responses
           relative to rejected ones, while staying close to the
           reference model (controlled by β).
```

**Why β matters**:
- **β too small (< 0.05)**: Model barely moves from reference — under-training
- **β too large (> 0.5)**: Model over-fits to preference signal, forgets general capabilities
- **Sweet spot**: β = 0.1 to 0.3 for most tasks

### GRPO: Group Relative Policy Optimization

**The key insight**: Instead of needing a separate reward model (PPO) or explicit preference pairs (DPO), GRPO generates multiple candidate responses for each prompt, scores them with a reward function, and uses the relative ranking within each group to compute the update.

```
GRPO Process:

1. For each prompt x, generate G candidate responses: {y₁, y₂, ..., y_G}
2. Score each with reward function R: {r₁, r₂, ..., r_G}
3. Normalize scores within the group:
   advantage(yᵢ) = (rᵢ - mean(r)) / std(r)
4. Update policy using normalized advantages (like REINFORCE but group-relative)

    ┌────────────────────────────────────────────────────┐
    │  Prompt: "Solve 3x + 7 = 22"                      │
    │                                                     │
    │  y₁: "x = 5" ← correct   r₁ = 1.0  adv = +1.2   │
    │  y₂: "x = 4" ← wrong     r₂ = 0.0  adv = -0.8   │
    │  y₃: "x = 5" ← correct   r₃ = 1.0  adv = +1.2   │
    │  y₄: "x = 7" ← wrong     r₄ = 0.0  adv = -0.8   │
    │                                                     │
    │  Policy update: increase P(y₁, y₃), decrease P(y₂, y₄)  │
    └────────────────────────────────────────────────────┘

Why it's powerful for reasoning:
  - Works with verifiable rewards (math correctness, code passes tests)
  - No need for human-labeled preference pairs
  - Self-improving: model generates its own training signal
  - Used by DeepSeek-R1 for reasoning training
```

### Other Preference Methods

| Method | What It Does | When to Use | Key Difference from DPO |
|--------|-------------|-------------|------------------------|
| **ORPO** | Combines SFT + preference in single loss | When you want to do SFT + alignment in one pass | No reference model needed — simpler setup |
| **KTO** | Uses binary good/bad signal per response (no pairs) | When you have thumbs up/down data but not paired comparisons | Doesn't require paired chosen/rejected responses |
| **IPO** | Adds regularization to prevent DPO from overfitting | When DPO training is unstable or overfits | Bounded loss prevents extreme policy shifts |
| **SimPO** | Length-normalized DPO without reference model | When you want DPO-like results with less memory | No reference model = 50% less GPU memory |

### Continued Pretraining vs SFT vs DPO

| Choice | What It Changes | Use When | Risk | Cost |
|--------|----------------|----------|------|------|
| **Continued pretraining** | Model's language prior (word distributions, domain patterns) | Domain language very different from base (legal, medical, code) | Catastrophic forgetting, expensive | $$$$ |
| **SFT (instruction tuning)** | Model's behavior (how it responds to instructions) | Need specific response format, style, or skill | Shallow preference learning | $$ |
| **DPO / Preference** | Model's preferences (which response is better) | Need nuanced quality judgments, safety alignment | Requires high-quality paired data | $$$ |
| **GRPO / RL** | Model's reasoning strategy (how it solves problems) | Need improved reasoning, verifiable rewards available | Reward hacking, instability | $$$$ |

**The practical training stack** (how production teams actually do it):

```
Step 1: (Optional) Continued Pretraining on Domain Corpus
        ↓
Step 2: Supervised Fine-Tuning (SFT) on Instruction Data
        ↓
Step 3: Preference Optimization (DPO/ORPO) on Preference Data
        │   ORPO note: trains SFT + alignment in one pass — no reference model
        ↓
Step 4: (Optional) GRPO/RLVR on Verifiable-Reward Tasks
        │   RLVR: uses programmatic rewards (code tests, math checkers) instead
        │   of human-ranked preferences — shift from LLM judge to objective rewards
        ↓
Step 5: Targeted Evaluation (task success, safety, capability regression)
        ↓
Step 6: Deployment Candidate
```

**The 2026 shift**: RLVR (Reinforcement Learning with Verifiable Rewards) is increasingly replacing human preference labels for tasks with objective ground truth. Instead of labeled "chosen vs rejected" pairs, use a reward function that checks correctness:
- Math: Does the expression evaluate to the right answer?
- Code: Do the unit tests pass?
- Structured output: Is the JSON schema valid?
- Tool use: Did the tool call succeed?

---

## ★ Code & Implementation

### Complete DPO Training with TRL

```python
# pip install trl>=0.12 transformers>=4.45 peft>=0.13 datasets>=3.0 bitsandbytes>=0.44
# ⚠️ Last tested: 2026-04 | Requires: trl>=0.12, transformers>=4.45

from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from peft import LoraConfig, get_peft_model
from trl import DPOTrainer, DPOConfig
from datasets import Dataset

# 1. Load base model with 4-bit quantization (QLoRA)
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype="bfloat16",
    bnb_4bit_use_double_quant=True,
)

model_name = "meta-llama/Llama-3.1-8B-Instruct"  # Or any base model
model = AutoModelForCausalLM.from_pretrained(
    model_name, quantization_config=bnb_config, device_map="auto"
)
tokenizer = AutoTokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

# 2. Add LoRA adapters
lora_config = LoraConfig(
    r=16,                        # Rank — higher = more capacity, more memory
    lora_alpha=32,               # Scaling factor (typically 2× rank)
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)
model = get_peft_model(model, lora_config)
print(f"Trainable parameters: {model.print_trainable_parameters()}")
# Expected: ~0.5% of total parameters are trainable

# 3. Prepare preference dataset
# Each example needs: prompt, chosen (preferred response), rejected (worse response)
preference_data = [
    {
        "prompt": "Explain quantum computing in simple terms.",
        "chosen": "Quantum computing uses qubits that can be 0, 1, or both simultaneously (superposition). This lets quantum computers explore many solutions at once, making them powerful for specific problems like optimization and cryptography. Think of it like reading all pages of a book simultaneously instead of one at a time.",
        "rejected": "Quantum computing is a revolutionary paradigm that leverages quantum mechanical phenomena such as superposition and entanglement to perform computations that are intractable for classical computers. The fundamental unit of quantum information is the qubit, which exists in a Hilbert space...",
    },
    # ... more preference pairs (typically 1000-10000 examples)
]
dataset = Dataset.from_list(preference_data)

# 4. Configure DPO training
dpo_config = DPOConfig(
    output_dir="./runs/dpo-llama3",
    per_device_train_batch_size=2,
    gradient_accumulation_steps=8,       # Effective batch = 2 × 8 = 16
    learning_rate=5e-6,                  # Lower than SFT (DPO is sensitive)
    beta=0.1,                            # KL penalty strength (start here)
    num_train_epochs=1,                  # DPO often needs only 1-2 epochs
    warmup_ratio=0.1,
    logging_steps=10,
    save_strategy="epoch",
    bf16=True,                           # Use bfloat16 for training stability
    gradient_checkpointing=True,         # Reduces memory at cost of speed
    max_length=1024,
    max_prompt_length=512,
)

# 5. Train
trainer = DPOTrainer(
    model=model,
    args=dpo_config,
    train_dataset=dataset,
    processing_class=tokenizer,
)
trainer.train()

# 6. Save the LoRA adapter
trainer.save_model("./dpo-adapter")

# Expected output:
# Training loss decreasing from ~0.7 to ~0.3-0.5 over 1 epoch
# Reward margins (chosen - rejected) increasing from ~0 to ~1-3
# GPU memory usage: ~16GB for 8B model with QLoRA
```

### Preference Dataset Creation with LLM-as-Judge

```python
# pip install openai>=1.0
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.0

from openai import OpenAI
import json

client = OpenAI()

def create_preference_pair(prompt: str, response_a: str, response_b: str) -> dict:
    """Use LLM-as-judge to create labeled preference pairs for DPO training."""
    
    judge_prompt = f"""You are a helpful assistant judge. Compare two responses to the same prompt.

PROMPT: {prompt}

RESPONSE A:
{response_a}

RESPONSE B:
{response_b}

Which response is better? Consider: accuracy, helpfulness, conciseness, and safety.
Output JSON: {{"winner": "A" or "B", "reason": "brief explanation"}}"""

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": judge_prompt}],
        response_format={"type": "json_object"},
        temperature=0,
    )
    
    judgment = json.loads(response.choices[0].message.content)
    
    if judgment["winner"] == "A":
        return {"prompt": prompt, "chosen": response_a, "rejected": response_b}
    else:
        return {"prompt": prompt, "chosen": response_b, "rejected": response_a}

# Generate preference pairs at scale
# 1. Collect prompts from your use case
# 2. Generate 2+ responses per prompt (different temperatures, models)
# 3. Use LLM-as-judge to label preferences
# 4. Verify a random sample manually (judge accuracy ~85-90%)
```

### QLoRA with Unsloth (2× Faster, 60% Less Memory)

```python
# pip install unsloth
# ⚠️ Last tested: 2026-04 | Requires: unsloth (installs torch, transformers, etc.)

from unsloth import FastLanguageModel
from trl import SFTTrainer, SFTConfig
from datasets import load_dataset

# 1. Load model with Unsloth (4-bit, optimized)
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/Llama-3.1-8B-Instruct",
    max_seq_length=2048,
    dtype=None,           # Auto-detect
    load_in_4bit=True,    # QLoRA
)

# 2. Add LoRA adapters (Unsloth-optimized)
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                     "gate_proj", "up_proj", "down_proj"],
    lora_alpha=16,
    lora_dropout=0,            # Unsloth recommends 0 for QLoRA
    bias="none",
    use_gradient_checkpointing="unsloth",  # 30% less VRAM
)

# Memory comparison:
# Standard QLoRA (bitsandbytes + PEFT):  ~18 GB for Llama-3.1-8B
# Unsloth QLoRA:                         ~7 GB for Llama-3.1-8B
# Speedup: ~2× faster training

# 3. Train (same TRL interface)
dataset = load_dataset("your-dataset", split="train")

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    args=SFTConfig(
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-4,
        num_train_epochs=1,
        output_dir="./runs/unsloth-sft",
        bf16=True,
    ),
)
trainer.train()

# Expected output:
# Training at ~2× speed of standard PEFT
# GPU memory: ~7GB (vs ~18GB standard)
# Same quality as standard QLoRA fine-tuning
```

---

## ◆ Formulas & Equations

| Name | Formula | Variables | Use |
|------|---------|-----------|-----|
| **DPO Loss** | $\mathcal{L} = -\log\sigma(\beta \cdot (\log\frac{\pi_\theta(y_w|x)}{\pi_{ref}(y_w|x)} - \log\frac{\pi_\theta(y_l|x)}{\pi_{ref}(y_l|x)}))$ | $y_w$=chosen, $y_l$=rejected, $\beta$=temperature | Core DPO training objective |
| **GRPO Advantage** | $A(y_i) = \frac{R(y_i) - \mu_G}{\sigma_G}$ | $R$=reward, $\mu_G$=group mean, $\sigma_G$=group std | Normalizing rewards within group |
| **LoRA update** | $W = W_0 + \alpha \cdot BA$ | $W_0$=frozen, $B \in \mathbb{R}^{d \times r}$, $A \in \mathbb{R}^{r \times k}$ | Low-rank weight adaptation |
| **QLoRA memory** | $\text{Memory} \approx \frac{|W| \times 4}{8} + r \times (d+k) \times 2$ | 4-bit base + fp16 adapters | GPU memory estimation |

---

## ◆ Quick Reference

```
TRAINING METHOD CHEAT SHEET:

  SFT:   "Imitate these good examples"
  DPO:   "This response is better than that one"
  KTO:   "This is good / this is bad" (no pairs needed)
  ORPO:  "SFT + preference in one loss" (no ref model)
  GRPO:  "Generate many, rank by reward, improve"
  PPO:   "Full RL with reward model" (most complex)

HYPERPARAMETER STARTING POINTS (DPO):
  learning_rate:  5e-6 to 5e-7 (lower than SFT!)
  beta:           0.1 (start here, range 0.05-0.5)
  epochs:         1-2 (DPO overfits fast)
  batch_size:     16-32 effective (with gradient accumulation)
  warmup:         10% of steps
  
GPU MEMORY ESTIMATES (Llama-3.1-8B):
  Full fine-tune:          ~65 GB (A100 80GB)
  LoRA (fp16):             ~32 GB (A100 40GB)
  QLoRA (4-bit):           ~18 GB (RTX 4090)
  QLoRA + Unsloth:         ~7 GB  (RTX 3090)
  
DATA SIZE GUIDELINES:
  SFT:                     1K-50K examples
  DPO preference pairs:    1K-10K pairs
  GRPO:                    10K+ prompts (generates own pairs)
  Continued pretraining:   100M+ tokens (expensive)
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Reward hacking** | Model finds shortcuts to maximize preference signal without actual quality | Reward function has exploitable proxies (e.g., longer = better) | Use multiple evaluation criteria, inspect outputs manually, add length penalty |
| **Capability regression** | Model gets better at target task but worse at general knowledge | Over-training on narrow preference data, catastrophic forgetting | Run regression test suite, keep training short (1-2 epochs), higher Î² |
| **Verbosity drift** | DPO-trained model becomes excessively verbose | Longer responses more often labeled "preferred" in training data | Filter training data for length bias, add length normalization (SimPO) |
| **Refusal collapse** | Model refuses too aggressively after safety DPO | Safety preference pairs too dominant in training mix | Balance safety pairs (< 10% of dataset), include "helpful but safe" chosen examples |
| **Mode collapse on DPO** | Model generates near-identical responses regardless of prompt | Î² too low, model collapsed to single high-reward pattern | Increase Î², add KL regularization, diversify training prompts |
| **Data poisoning** | LLM-as-judge labels are systematically biased | Judge model has its own biases (verbosity, style preferences) | Use multiple judges, validate sample manually, use diverse judge models |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **A fancier algorithm cannot rescue bad data**: DPO with perfect preference pairs beats GRPO with noisy rewards. Always invest in data quality first.
- ⚠️ **DPO learning rate must be lower than SFT**: Using SFT learning rates (2e-4) with DPO causes rapid divergence. Start at 5e-6.
- ⚠️ **Don't skip the SFT step**: DPO on a non-instruction-tuned model produces garbage. Always SFT first, then DPO.
- ⚠️ **β is not optional to tune**: The default β=0.1 works OK but is rarely optimal. Run 3-5 experiments varying β from 0.05 to 0.5.
- ⚠️ **Always compare to prompt engineering first**: If you can get 80% of the quality improvement with a better system prompt, fine-tuning is premature optimization.

---

## ○ Interview Angles

- **Q**: Why has DPO become more popular than PPO for alignment?
- **A**: DPO reformulates the RLHF objective so that the optimal policy can be extracted directly from preference pairs, without needing a separate reward model or the unstable PPO training loop. This makes it dramatically simpler to implement — you just need ranked pairs of "chosen" and "rejected" responses, a reference model, and a standard classification-like loss. PPO requires training a reward model, running policy rollouts, computing advantages, and maintaining a value function — all of which introduce instability and hyperparameter sensitivity. In practice, DPO achieves comparable alignment quality to PPO with 3-5× less infrastructure complexity. The tradeoff is that DPO is an offline method (it uses a fixed dataset), while PPO can potentially explore and self-improve through online generation. This is where GRPO bridges the gap — it gets PPO-like self-improvement with DPO-like simplicity.

- **Q**: When would you choose GRPO over DPO?
- **A**: GRPO shines in two scenarios. First, when you have a verifiable reward function — like math problems (answer is correct or not), code generation (tests pass or fail), or structured output (valid JSON or not). DPO needs someone to label which response is "better," but GRPO can generate its own training signal. Second, when you want the model to explore and find better solutions than what's in your training data. DPO is limited to the quality of your preference pairs — the model can only learn to prefer responses already in the dataset. GRPO generates new candidates and improves on them, enabling genuine self-improvement. DeepSeek used GRPO for training reasoning models (DeepSeek-R1) specifically because math reasoning benefits from this verifiable-reward, generate-and-rank approach.

- **Q**: How do you prevent capability regression during fine-tuning?
- **A**: Three practical strategies. First, always maintain a regression test suite that covers core capabilities you care about preserving — general knowledge, instruction following, safety, and language quality. Run this after every training run, not just the final one. Second, keep training short (1-2 epochs for DPO) and use a higher β value (0.2-0.3) to keep the model closer to the reference. Third, use LoRA/QLoRA rather than full fine-tuning — by only modifying a small number of parameters, you inherently limit how much the model can drift from its base capabilities. If you detect regression, you can blend LoRA weights at inference time to find the optimal balance between new capability and preserved performance.

---

## ◆ Hands-On Exercises

### Exercise 1: DPO Training on Preference Data

**Goal**: Train a DPO adapter and compare it to the SFT baseline
**Time**: 90 minutes (including training time)
**Steps**:
1. Pick a small model (Llama-3.1-8B or Phi-3-mini) and a task (summarization, coding, or Q&A)
2. Create 100 preference pairs (use LLM-as-judge to label)
3. Train DPO adapter using the TRL code above
4. Generate responses from both SFT and DPO models on 20 test prompts
5. Evaluate: which model do you (or an LLM judge) prefer?
**Expected Output**: DPO model preferred on 60-75% of test prompts. Training loss ~0.3-0.5.

### Exercise 2: Î² Sensitivity Analysis

**Goal**: Understand how Î² affects DPO training behavior
**Time**: 60 minutes
**Steps**:
1. Using the same preference dataset, train 3 DPO models: Î²=0.05, Î²=0.1, Î²=0.5
2. For each, measure: training loss, reward margin (chosen - rejected log prob), and generation quality
3. Compare: which Î² gives best task quality? Which preserves general capability best?
4. Create a recommendation for your use case
**Expected Output**: Table comparing 3 Î² values across quality, safety, and capability retention metrics

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Fine-Tuning LLMs](./fine-tuning.md) (SFT + LoRA foundations), [RL Alignment](./rl-alignment.md) (RLHF theory), [Synthetic Data](./synthetic-data-and-data-engineering.md) |
| Leads to | [Distillation & Compression](./distillation-and-compression.md), reasoning model training, tool-use specialization |
| Compare with | Prompt-only adaptation (cheaper, less capable), pure RAG (no model changes), full RLHF/PPO (more complex, potentially more powerful) |
| Cross-domain | Recommender system optimization, offline reinforcement learning, ranking systems |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Rafailov et al. "DPO: Your Language Model is Secretly a Reward Model" (2023)](https://arxiv.org/abs/2305.18290) — Sections 3-4 | The original DPO paper. Section 3 derives the loss; Section 4 shows it matches PPO quality |
| 📄 Paper | [Shao et al. "DeepSeekMath: Pushing the Limits of Math Reasoning" (2024)](https://arxiv.org/abs/2402.03300) — GRPO section | Introduces GRPO and shows its application to mathematical reasoning |
| 📘 Book | "LLM Engineer's Handbook" by Iusztin & Labonne (2024), Ch 5-6 | Practical guide to fine-tuning pipelines including DPO implementation details |
| 🔧 Hands-on | [HuggingFace TRL Documentation — DPO Trainer](https://huggingface.co/docs/trl/dpo_trainer) | Official docs with examples, hyperparameter guidance, and dataset format |
| 🔧 Hands-on | [Unsloth Documentation](https://docs.unsloth.ai/) | 2× faster QLoRA fine-tuning with 60% less memory — essential for GPU-constrained training |
| 🎥 Video | [Sebastian Raschka — "DPO Explained"](https://www.youtube.com/watch?v=pzh2oc6shic) | Clear mathematical walk-through of DPO loss derivation and intuition |
| 📄 Paper | [Hu et al. "LoRA: Low-Rank Adaptation" (2021)](https://arxiv.org/abs/2106.09685) | The foundational paper for parameter-efficient fine-tuning |

---

## ★ Sources

- Rafailov et al. "Direct Preference Optimization: Your Language Model is Secretly a Reward Model" (2023) — https://arxiv.org/abs/2305.18290
- Shao et al. "DeepSeekMath: Pushing the Limits of Mathematical Reasoning" (2024) — https://arxiv.org/abs/2402.03300
- Hu et al. "LoRA: Low-Rank Adaptation of Large Language Models" (2021) — https://arxiv.org/abs/2106.09685
- Dettmers et al. "QLoRA: Efficient Finetuning of Quantized LLMs" (2023) — https://arxiv.org/abs/2305.14314
- HuggingFace TRL Documentation — https://huggingface.co/docs/trl/
- Unsloth Documentation — https://docs.unsloth.ai/
