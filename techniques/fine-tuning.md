---
title: "Fine-Tuning LLMs"
aliases: ["Fine-Tuning", "SFT", "Supervised Fine-Tuning"]
tags: [fine-tuning, lora, qlora, peft, training, genai-techniques]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["rag.md", "../llms/llms-overview.md", "prompt-engineering.md", "advanced-fine-tuning.md"]
source: "Hu et al. LoRA (2021), QLoRA (2023), latest hybrid techniques"
created: 2026-03-18
updated: 2026-04-12
---

# Fine-Tuning LLMs

> âœ¨ **Bit**: Full fine-tuning a 70B model needs ~280GB of GPU memory (14Ã— A100 40GBs). LoRA does it on 1 GPU. That's not an optimization â€” that's a paradigm shift.

---

## â˜… TL;DR

- **What**: Adapting a pre-trained LLM's weights on your specific data to change its behavior, style, or domain expertise
- **Why**: When prompting isn't enough â€” you need the model to consistently behave a certain way
- **Key point**: LoRA/QLoRA made fine-tuning accessible. You don't need a GPU cluster anymore.

---

## â˜… Overview

### Definition

**Fine-tuning** is the process of continuing to train a pre-trained LLM on a smaller, task-specific dataset to adapt it for specific use cases. **Parameter-Efficient Fine-Tuning (PEFT)** methods like LoRA achieve this by training only a tiny fraction of parameters.

### Scope

Covers: Full fine-tuning, LoRA, QLoRA, PEFT methods, when to use vs RAG. For RAG as the alternative approach, see [Rag](./rag.md). For DPO, GRPO, and other advanced post-training strategies, see [Advanced Fine-Tuning for LLM Adaptation](./advanced-fine-tuning.md).

### Significance

- Bridges gap between general-purpose LLMs and domain-specific needs
- LoRA (2021) democratized fine-tuning: any developer with 1 GPU can now customize an LLM
- 2025-2026 consensus: **Hybrid RAG + LoRA** is the production gold standard

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) â€” what you're fine-tuning
- Basic PyTorch / training loop understanding
- GPU access (even a single consumer GPU works with QLoRA)

---

## â˜… Deep Dive

### Types of Fine-Tuning

```
Fine-Tuning Methods
â”œâ”€â”€ Full Fine-Tuning
â”‚   â””â”€â”€ Update ALL parameters (expensive, risk of catastrophic forgetting)
â”‚
â”œâ”€â”€ Parameter-Efficient Fine-Tuning (PEFT)
â”‚   â”œâ”€â”€ LoRA (Low-Rank Adaptation)     â† most popular
â”‚   â”œâ”€â”€ QLoRA (Quantized LoRA)         â† most accessible
â”‚   â”œâ”€â”€ DoRA (Weight-Decomposed LoRA)  â† latest, even better
â”‚   â”œâ”€â”€ Adapters (insert small modules)
â”‚   â””â”€â”€ Prefix Tuning / Prompt Tuning
â”‚
â””â”€â”€ Alignment Fine-Tuning
    â”œâ”€â”€ SFT (Supervised Fine-Tuning)
    â”œâ”€â”€ RLHF (Reinforcement Learning from Human Feedback)
    â”œâ”€â”€ DPO (Direct Preference Optimization) â† simpler RLHF alternative
    â””â”€â”€ GRPO (Group Relative Policy Optimization) â† latest for reasoning
```

### LoRA: How It Works

**Core idea**: Instead of updating the full weight matrix W (millions/billions of params), decompose the update into two small matrices.

```
Original:     y = WÂ·x           (W is dÃ—d, e.g. 4096Ã—4096 = 16M params)

LoRA:         y = WÂ·x + BÂ·AÂ·x   (A is dÃ—r, B is rÃ—d, rank r â‰ˆ 8-64)
              Freeze W, only train A and B

Example with rank r=16:
  W: 4096 Ã— 4096 = 16,777,216 params (FROZEN)
  A: 4096 Ã— 16   =    65,536 params  (trainable)
  B: 16 Ã— 4096   =    65,536 params  (trainable)
  Total trainable: 131,072 (0.78% of original!)
```

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                LoRA                      â”‚
â”‚                                         â”‚
â”‚  Input x â”€â”€â–º [W (frozen)] â”€â”€â”€â”€â”€â”€â”       â”‚
â”‚     â”‚                           â”‚ ADD   â”‚
â”‚     â””â”€â”€â–º [A (trainable)] â”€â”€â–º    â”‚ â”€â”€â–º y â”‚
â”‚              [B (trainable)] â”€â”€â”€â”˜       â”‚
â”‚                                         â”‚
â”‚  Original path + low-rank update path   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### QLoRA: LoRA + Quantization

```
QLoRA = Quantize base model to 4-bit + Apply LoRA adapters (16-bit)

Memory comparison for LLaMA 70B:
  Full fine-tuning: ~280 GB  (need 7Ã— A100 80GB)
  LoRA (16-bit):    ~160 GB  (need 4Ã— A100 40GB)
  QLoRA (4-bit):    ~35 GB   (1Ã— A100 40GB or 1Ã— RTX 4090!)

Performance: Within 1-2% of full fine-tuning
```

### Training Data Format

```json
// Instruction format (most common)
{
  "instruction": "Summarize the following medical report",
  "input": "[medical report text]",
  "output": "[summary]"
}

// Chat format (for conversational fine-tuning)
{
  "messages": [
    {"role": "system", "content": "You are a medical assistant"},
    {"role": "user", "content": "What does this lab result mean?"},
    {"role": "assistant", "content": "[expected response]"}
  ]
}

// How much data?
// Minimum: ~100 high-quality examples (for style/format changes)
// Good: 1,000-10,000 examples
// Diminishing returns beyond 50,000 for most tasks
```

### Key Hyperparameters

| Parameter        | Typical Value                  | What It Does                        |
| ---------------- | ------------------------------ | ----------------------------------- |
| `r` (LoRA rank)  | 8-64                           | Higher = more capacity, more memory |
| `lora_alpha`     | 16-32                          | Scaling factor (usually = 2Ã—r)      |
| `lora_dropout`   | 0.05-0.1                       | Regularization                      |
| `target_modules` | q_proj, v_proj, k_proj, o_proj | Which layers to apply LoRA to       |
| `learning_rate`  | 1e-4 to 2e-4                   | Lower than pre-training             |
| `epochs`         | 1-5                            | Often just 1-3 is enough            |
| `batch_size`     | 4-16                           | Limited by GPU memory               |

---

## â˜… Code & Implementation

### Fine-tuning with QLoRA (Step-by-Step)

```python
# pip install transformers>=4.40 peft>=0.10 bitsandbytes>=0.42 trl>=0.8 datasets accelerate
# âš ï¸ Last tested: 2026-04 | Requires: GPU with CUDA (RTX 3080+ or A100)

from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
from trl import SFTTrainer, SFTConfig
from datasets import load_dataset

# 2. Load model in 4-bit
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype="bfloat16",
    bnb_4bit_use_double_quant=True,
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-3.2-8B",
    quantization_config=bnb_config,
    device_map="auto",
)
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3.2-8B")

# 3. Configure LoRA
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM",
)

model = prepare_model_for_kbit_training(model)
model = get_peft_model(model, lora_config)

# 4. Load your dataset
dataset = load_dataset("json", data_files="your_training_data.jsonl")

# 5. Train
training_config = SFTConfig(
    output_dir="./output",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    learning_rate=2e-4,
    logging_steps=10,
    save_strategy="epoch",
)

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset["train"],
    tokenizer=tokenizer,
    args=training_config,
)

trainer.train()
model.save_pretrained("./my-fine-tuned-model")
```

---

## â—† Comparison

| Aspect             | Full Fine-Tuning  | LoRA              | QLoRA             | RAG (alternative)       |
| ------------------ | ----------------- | ----------------- | ----------------- | ----------------------- |
| **Params updated** | All               | 0.1-1%            | 0.1-1%            | None                    |
| **GPU memory**     | Very high         | Medium            | Low (1 GPU)       | N/A                     |
| **Training data**  | >10K examples     | 100-10K           | 100-10K           | Documents (no training) |
| **Changes**        | Everything        | Behavior/style    | Behavior/style    | Adds knowledge          |
| **Knowledge**      | Baked in (static) | Baked in (static) | Baked in (static) | Dynamic (updatable)     |
| **Cost**           | $$$$$             | $$                | $                 | $ (infra only)          |

---

## â—† Strengths vs Limitations

| âœ… Strengths                                | âŒ Limitations                          |
| ------------------------------------------ | -------------------------------------- |
| Permanently changes model behavior         | Requires training data curation        |
| Consistent output style/format             | Risk of catastrophic forgetting        |
| Lower inference cost (no retrieval)        | Knowledge is static (vs RAG's dynamic) |
| Can improve reasoning for specific domains | Overfitting on small datasets          |
| LoRA adapters are tiny (~10-100 MB)        | Still needs GPU for training           |

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **"Just fine-tune it" is usually wrong**: Try prompting and RAG first. Fine-tuning is for behavior, not knowledge.
- âš ï¸ **Data quality > data quantity**: 100 perfect examples beat 10,000 noisy ones
- âš ï¸ **Catastrophic forgetting**: The model may forget general capabilities. Use diverse training data and low learning rates.
- âš ï¸ **Evaluation is hard**: Always hold out a test set. Manual evaluation (vibes check) matters more than loss curves.
- âš ï¸ **LoRA rank too high**: r=256 doesn't mean better. Start with r=16, increase only if underfitting.

---

## â—‹ Interview Angles

- **Q**: When would you fine-tune vs use RAG?
- **A**: Fine-tune for: output format changes, domain-specific reasoning/style, consistent behavior. RAG for: up-to-date knowledge, source attribution, private data access. Best practice in 2026: **combine both** â€” LoRA for behavior, RAG for facts.

- **Q**: Explain how LoRA reduces memory requirements.
- **A**: Instead of updating the full dÃ—d weight matrix, LoRA decomposes it into two small matrices of rank r (dÃ—r and rÃ—d). With r=16 on a 4096-dim model, you train 0.78% of parameters. QLoRA goes further by quantizing the frozen base model to 4-bit, reducing memory from ~280GB to ~35GB for a 70B model.

---

## â˜… Connections

| Relationship | Topics                                                          |
| ------------ | --------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Transformers](../foundations/transformers.md)      |
| Leads to     | Domain-specific models, Hybrid RAG systems                      |
| Compare with | [Rag](./rag.md) (knowledge injection), Prompt engineering (no training) |
| Cross-domain | Transfer learning (CV), Adapter methods                         |

---

## â˜… Fine-Tuning Tooling (2026)

| Tool                | Key Feature                                | When to Use                                                                      |
| ------------------- | ------------------------------------------ | -------------------------------------------------------------------------------- |
| **Unsloth**         | 2x faster, 70% less memory, free tier      | Default choice for LoRA/QLoRA fine-tuning in 2026. Massive open-source adoption. |
| **Axolotl**         | YAML-based config, multi-GPU, many methods | Complex multi-dataset training, advanced configs                                 |
| **HuggingFace TRL** | Official SFTTrainer, RLHF support          | When you need RLHF/DPO integration or HF ecosystem                               |
| **LLaMA Factory**   | 100+ models, WebUI, no code needed         | Quick experiments, non-engineers                                                 |
| **torchtune**       | PyTorch-native, Meta official              | LLaMA models, when you want low-level control                                    |

```
# â•â•â• Unsloth Example (2x faster QLoRA) â•â•â•
from unsloth import FastLanguageModel

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name = "unsloth/llama-4-scout-bnb-4bit",
    max_seq_length = 2048,
    load_in_4bit = True,
)

model = FastLanguageModel.get_peft_model(
    model, r=16, target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_alpha=16, lora_dropout=0,
)

# Train with standard HuggingFace Trainer â€” just faster!
```


---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Catastrophic forgetting** | Model loses general capabilities after fine-tuning | Aggressive learning rate, too many epochs on narrow data | Lower LR (1e-5 to 5e-6), early stopping, eval on general benchmarks |
| **Overfitting to format** | Model only works with exact training format | Insufficient format diversity in training data | Augment with paraphrases, vary system prompts |
| **Data contamination** | Inflated eval metrics don't reflect real performance | Test data leaked into training set | Strict train/test split, deduplication, temporal splits |
| **Reward hacking** | High reward scores but poor actual output quality | Misspecified reward function | Human evaluation alongside automated metrics, KL penalty |
| **Training instability** | Loss spikes, NaN gradients, divergence | Learning rate too high, batch size too small | Gradient clipping, warmup schedule, data quality audit |

---

## â—† Hands-On Exercises

### Exercise 1: Fine-Tune and Measure Forgetting

**Goal**: Fine-tune a model and quantify capability regression
**Time**: 60 minutes
**Steps**:
1. Take a base model (e.g., distilbert-base)
2. Fine-tune on IMDB sentiment (3 epochs)
3. Evaluate on IMDB test set AND on a general NLI benchmark
4. Compare general capability before and after fine-tuning
**Expected Output**: Accuracy on target task vs regression on general benchmarks

### Exercise 2: Debug a Bad Fine-Tune

**Goal**: Diagnose and fix a fine-tuning job that overfits
**Time**: 30 minutes
**Steps**:
1. Run a fine-tune with intentionally bad hyperparams (LR=1e-3, 10 epochs)
2. Plot training loss vs validation loss
3. Identify the overfitting epoch
4. Re-run with corrected LR, early stopping, and dropout
**Expected Output**: Training curves showing overfitting pattern and fix
---


## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ“„ Paper | [Hu et al. "LoRA" (2021)](https://arxiv.org/abs/2106.09685) | The foundational parameter-efficient fine-tuning paper |
| ðŸ”§ Hands-on | [HuggingFace PEFT Library](https://huggingface.co/docs/peft/) | Production PEFT implementation with LoRA, QLoRA, etc. |
| ðŸ“˜ Book | "LLM Engineer's Handbook" by Iusztin & Labonne (2024), Ch 5-6 | Practical fine-tuning pipeline guide |
| ðŸŽ¥ Video | [Sebastian Raschka â€” "LoRA and Fine-Tuning LLMs"](https://www.youtube.com/watch?v=MEhQH0Xa1hw) | Clear explanation of LoRA mechanics and practical tips |

## â˜… Sources

- Hu et al., "LoRA: Low-Rank Adaptation of Large Language Models" (2021)
- Dettmers et al., "QLoRA: Efficient Finetuning of Quantized LLMs" (2023)
- Liu et al., "DoRA: Weight-Decomposed Low-Rank Adaptation" (2024)
- Hugging Face PEFT documentation â€” https://huggingface.co/docs/peft
- Unsloth â€” https://github.com/unslothai/unsloth
- Axolotl â€” https://github.com/OpenAccess-AI-Collective/axolotl
- Sebastian Raschka, "Fine-Tuning LLMs" guide

