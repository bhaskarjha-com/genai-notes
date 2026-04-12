---
title: "Fine-Tuning LLMs"
tags: [fine-tuning, lora, qlora, peft, training, genai-techniques]
type: procedure
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[rag]]", "[[../llms/llms-overview]]", "[[prompt-engineering]]", "[[advanced-fine-tuning]]"]
source: "Hu et al. LoRA (2021), QLoRA (2023), latest hybrid techniques"
created: 2026-03-18
updated: 2026-04-12
---

# Fine-Tuning LLMs

> ✨ **Bit**: Full fine-tuning a 70B model needs ~280GB of GPU memory (14× A100 40GBs). LoRA does it on 1 GPU. That's not an optimization — that's a paradigm shift.

---

## ★ TL;DR

- **What**: Adapting a pre-trained LLM's weights on your specific data to change its behavior, style, or domain expertise
- **Why**: When prompting isn't enough — you need the model to consistently behave a certain way
- **Key point**: LoRA/QLoRA made fine-tuning accessible. You don't need a GPU cluster anymore.

---

## ★ Overview

### Definition

**Fine-tuning** is the process of continuing to train a pre-trained LLM on a smaller, task-specific dataset to adapt it for specific use cases. **Parameter-Efficient Fine-Tuning (PEFT)** methods like LoRA achieve this by training only a tiny fraction of parameters.

### Scope

Covers: Full fine-tuning, LoRA, QLoRA, PEFT methods, when to use vs RAG. For RAG as the alternative approach, see [Rag](./rag.md). For DPO, GRPO, and other advanced post-training strategies, see [Advanced Fine-Tuning for LLM Adaptation](./advanced-fine-tuning.md).

### Significance

- Bridges gap between general-purpose LLMs and domain-specific needs
- LoRA (2021) democratized fine-tuning: any developer with 1 GPU can now customize an LLM
- 2025-2026 consensus: **Hybrid RAG + LoRA** is the production gold standard

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) — what you're fine-tuning
- Basic PyTorch / training loop understanding
- GPU access (even a single consumer GPU works with QLoRA)

---

## ★ Deep Dive

### Types of Fine-Tuning

```
Fine-Tuning Methods
├── Full Fine-Tuning
│   └── Update ALL parameters (expensive, risk of catastrophic forgetting)
│
├── Parameter-Efficient Fine-Tuning (PEFT)
│   ├── LoRA (Low-Rank Adaptation)     ← most popular
│   ├── QLoRA (Quantized LoRA)         ← most accessible
│   ├── DoRA (Weight-Decomposed LoRA)  ← latest, even better
│   ├── Adapters (insert small modules)
│   └── Prefix Tuning / Prompt Tuning
│
└── Alignment Fine-Tuning
    ├── SFT (Supervised Fine-Tuning)
    ├── RLHF (Reinforcement Learning from Human Feedback)
    ├── DPO (Direct Preference Optimization) ← simpler RLHF alternative
    └── GRPO (Group Relative Policy Optimization) ← latest for reasoning
```

### LoRA: How It Works

**Core idea**: Instead of updating the full weight matrix W (millions/billions of params), decompose the update into two small matrices.

```
Original:     y = W·x           (W is d×d, e.g. 4096×4096 = 16M params)

LoRA:         y = W·x + B·A·x   (A is d×r, B is r×d, rank r ≈ 8-64)
              Freeze W, only train A and B

Example with rank r=16:
  W: 4096 × 4096 = 16,777,216 params (FROZEN)
  A: 4096 × 16   =    65,536 params  (trainable)
  B: 16 × 4096   =    65,536 params  (trainable)
  Total trainable: 131,072 (0.78% of original!)
```

```
┌─────────────────────────────────────────┐
│                LoRA                      │
│                                         │
│  Input x ──► [W (frozen)] ──────┐       │
│     │                           │ ADD   │
│     └──► [A (trainable)] ──►    │ ──► y │
│              [B (trainable)] ───┘       │
│                                         │
│  Original path + low-rank update path   │
└─────────────────────────────────────────┘
```

### QLoRA: LoRA + Quantization

```
QLoRA = Quantize base model to 4-bit + Apply LoRA adapters (16-bit)

Memory comparison for LLaMA 70B:
  Full fine-tuning: ~280 GB  (need 7× A100 80GB)
  LoRA (16-bit):    ~160 GB  (need 4× A100 40GB)
  QLoRA (4-bit):    ~35 GB   (1× A100 40GB or 1× RTX 4090!)

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
| `lora_alpha`     | 16-32                          | Scaling factor (usually = 2×r)      |
| `lora_dropout`   | 0.05-0.1                       | Regularization                      |
| `target_modules` | q_proj, v_proj, k_proj, o_proj | Which layers to apply LoRA to       |
| `learning_rate`  | 1e-4 to 2e-4                   | Lower than pre-training             |
| `epochs`         | 1-5                            | Often just 1-3 is enough            |
| `batch_size`     | 4-16                           | Limited by GPU memory               |

---

## ◆ Procedure / How-To

### Fine-tuning with QLoRA (Step-by-Step)

```python
# 1. Install dependencies
# pip install transformers peft bitsandbytes trl datasets accelerate

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

## ◆ Comparison

| Aspect             | Full Fine-Tuning  | LoRA              | QLoRA             | RAG (alternative)       |
| ------------------ | ----------------- | ----------------- | ----------------- | ----------------------- |
| **Params updated** | All               | 0.1-1%            | 0.1-1%            | None                    |
| **GPU memory**     | Very high         | Medium            | Low (1 GPU)       | N/A                     |
| **Training data**  | >10K examples     | 100-10K           | 100-10K           | Documents (no training) |
| **Changes**        | Everything        | Behavior/style    | Behavior/style    | Adds knowledge          |
| **Knowledge**      | Baked in (static) | Baked in (static) | Baked in (static) | Dynamic (updatable)     |
| **Cost**           | $$$$$             | $$                | $                 | $ (infra only)          |

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                | ❌ Limitations                          |
| ------------------------------------------ | -------------------------------------- |
| Permanently changes model behavior         | Requires training data curation        |
| Consistent output style/format             | Risk of catastrophic forgetting        |
| Lower inference cost (no retrieval)        | Knowledge is static (vs RAG's dynamic) |
| Can improve reasoning for specific domains | Overfitting on small datasets          |
| LoRA adapters are tiny (~10-100 MB)        | Still needs GPU for training           |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **"Just fine-tune it" is usually wrong**: Try prompting and RAG first. Fine-tuning is for behavior, not knowledge.
- ⚠️ **Data quality > data quantity**: 100 perfect examples beat 10,000 noisy ones
- ⚠️ **Catastrophic forgetting**: The model may forget general capabilities. Use diverse training data and low learning rates.
- ⚠️ **Evaluation is hard**: Always hold out a test set. Manual evaluation (vibes check) matters more than loss curves.
- ⚠️ **LoRA rank too high**: r=256 doesn't mean better. Start with r=16, increase only if underfitting.

---

## ○ Interview Angles

- **Q**: When would you fine-tune vs use RAG?
- **A**: Fine-tune for: output format changes, domain-specific reasoning/style, consistent behavior. RAG for: up-to-date knowledge, source attribution, private data access. Best practice in 2026: **combine both** — LoRA for behavior, RAG for facts.

- **Q**: Explain how LoRA reduces memory requirements.
- **A**: Instead of updating the full d×d weight matrix, LoRA decomposes it into two small matrices of rank r (d×r and r×d). With r=16 on a 4096-dim model, you train 0.78% of parameters. QLoRA goes further by quantizing the frozen base model to 4-bit, reducing memory from ~280GB to ~35GB for a 70B model.

---

## ★ Connections

| Relationship | Topics                                                          |
| ------------ | --------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Transformers](../foundations/transformers.md)      |
| Leads to     | Domain-specific models, Hybrid RAG systems                      |
| Compare with | [Rag](./rag.md) (knowledge injection), Prompt engineering (no training) |
| Cross-domain | Transfer learning (CV), Adapter methods                         |

---

## ★ Fine-Tuning Tooling (2026)

| Tool                | Key Feature                                | When to Use                                                                      |
| ------------------- | ------------------------------------------ | -------------------------------------------------------------------------------- |
| **Unsloth**         | 2x faster, 70% less memory, free tier      | Default choice for LoRA/QLoRA fine-tuning in 2026. Massive open-source adoption. |
| **Axolotl**         | YAML-based config, multi-GPU, many methods | Complex multi-dataset training, advanced configs                                 |
| **HuggingFace TRL** | Official SFTTrainer, RLHF support          | When you need RLHF/DPO integration or HF ecosystem                               |
| **LLaMA Factory**   | 100+ models, WebUI, no code needed         | Quick experiments, non-engineers                                                 |
| **torchtune**       | PyTorch-native, Meta official              | LLaMA models, when you want low-level control                                    |

```
# ═══ Unsloth Example (2x faster QLoRA) ═══
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

# Train with standard HuggingFace Trainer — just faster!
```

---

## ★ Sources

- Hu et al., "LoRA: Low-Rank Adaptation of Large Language Models" (2021)
- Dettmers et al., "QLoRA: Efficient Finetuning of Quantized LLMs" (2023)
- Liu et al., "DoRA: Weight-Decomposed Low-Rank Adaptation" (2024)
- Hugging Face PEFT documentation — https://huggingface.co/docs/peft
- Unsloth — https://github.com/unslothai/unsloth
- Axolotl — https://github.com/OpenAccess-AI-Collective/axolotl
- Sebastian Raschka, "Fine-Tuning LLMs" guide

