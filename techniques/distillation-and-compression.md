---
title: "Knowledge Distillation & Model Compression"
aliases: ["Distillation", "Model Compression", "Pruning"]
tags: [distillation, compression, pruning, teacher-student, efficiency, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["fine-tuning.md", "../inference/inference-optimization.md", "../foundations/modern-architectures.md"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Knowledge Distillation & Model Compression

> âœ¨ **Bit**: GPT-4 knows a lot, but it's enormous and expensive. Distillation is like a PhD student learning from a professor â€” the student ends up much smaller but captures most of the professor's knowledge. That's how Phi-3 (3.8B) can compete with models 100x its size.

---

## â˜… TL;DR

- **What**: Techniques to create smaller, faster, cheaper models that retain the capabilities of larger ones
- **Why**: You can't run GPT-4 on a phone. But you CAN distill its knowledge into a 7B model that runs anywhere.
- **Key point**: Distillation transfers "dark knowledge" (soft probabilities, reasoning patterns) from teacher to student, not just the final answers. This produces students far better than training from scratch.

---

## â˜… Overview

### Definition

**Knowledge Distillation (KD)**: Training a small "student" model to mimic the behavior of a large "teacher" model. The student learns from the teacher's softmax distribution (soft labels) rather than just hard labels.

**Model Compression**: The umbrella term for making models smaller/faster, including distillation, pruning, quantization, and architecture changes.

### Scope

Covers distillation and pruning. For quantization (INT4/INT8/FP8), see [Inference Optimization](../inference/inference-optimization.md). For fine-tuning (LoRA/QLoRA), see [Fine Tuning](./fine-tuning.md).

### Significance

- How DeepSeek-R1-Distill-Qwen-32B and Phi-3 models are created
- Critical for edge deployment (mobile, IoT, embedded)
- Reduces inference costs 10-100x while retaining 80-95% quality
- Hot interview topic: "How would you deploy an LLM on device?"

---

## â˜… Deep Dive

### The Distillation Framework

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚            KNOWLEDGE DISTILLATION                â”‚
â”‚                                                 â”‚
â”‚  TEACHER (large, expensive)                      â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                        â”‚
â”‚  â”‚  GPT-4 / R1 / 70B   â”‚                        â”‚
â”‚  â”‚  Input: "What is AI?"â”‚                        â”‚
â”‚  â”‚  Output distribution:â”‚                        â”‚
â”‚  â”‚    AI:     0.35      â”‚ â† "Soft labels"        â”‚
â”‚  â”‚    ML:     0.25      â”‚    Rich information!    â”‚
â”‚  â”‚    robot:  0.15      â”‚    "AI and ML are       â”‚
â”‚  â”‚    code:   0.10      â”‚     related" is encoded â”‚
â”‚  â”‚    other:  0.15      â”‚     in these probs.     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                        â”‚
â”‚             â”‚ soft probabilities                  â”‚
â”‚             â–¼                                    â”‚
â”‚  STUDENT (small, efficient)                      â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                        â”‚
â”‚  â”‚  7B / 3B / 1B model  â”‚                        â”‚
â”‚  â”‚  Learns to match the â”‚                        â”‚
â”‚  â”‚  teacher's soft       â”‚                        â”‚
â”‚  â”‚  distribution, not   â”‚                        â”‚
â”‚  â”‚  just the right      â”‚                        â”‚
â”‚  â”‚  answer              â”‚                        â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                        â”‚
â”‚                                                 â”‚
â”‚  LOSS = Î± Ã— KL(teacher_soft, student_soft)      â”‚
â”‚       + (1-Î±) Ã— CrossEntropy(student, labels)   â”‚
â”‚                                                 â”‚
â”‚  Temperature T â†’ softens distributions          â”‚
â”‚  Higher T â†’ more "dark knowledge" transfer      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Types of Distillation

| Type                  | How It Works                                              | Example                        |
| --------------------- | --------------------------------------------------------- | ------------------------------ |
| **Response-based**    | Student mimics teacher's output distribution              | Classic: soft label matching   |
| **Feature-based**     | Student mimics teacher's intermediate representations     | Match hidden layer activations |
| **Relation-based**    | Student learns relationships between samples              | Contrastive distillation       |
| **Rationale-based**   | Teacher generates step-by-step reasoning as training data | DeepSeek-R1 â†’ R1-Distill-Qwen  |
| **Multi-teacher**     | Multiple teachers guide one student                       | Ensemble knowledge transfer    |
| **Self-distillation** | Model teaches itself (larger layers â†’ smaller)            | Born-again networks            |

### Rationale Distillation (Modern LLM Pattern)

```
The most common pattern in 2025-2026:

  1. Teacher generates high-quality outputs
     Teacher (R1): "Let me think... [reasoning chain] ... Answer: 42"

  2. Collect outputs as training data
     dataset = [(input, teacher_output) for input in prompts]

  3. Fine-tune student on teacher's outputs
     Student (7B) trained on (input, reasoning + answer) pairs

  This is how:
    DeepSeek-R1 â†’ R1-Distill-Qwen-14B, R1-Distill-Llama-70B
    GPT-4 â†’ Alpaca/Vicuna (early 2023, simpler version)
    GPT-4 â†’ Phi-3 (via synthetic data distillation)
```

### Other Compression Techniques

```
PRUNING: Remove unimportant weights/neurons/layers

  Before:  â—â”€â—â”€â—â”€â—â”€â—    (all connections active)
  After:   â—â”€ â”€â—â”€ â”€â—    (weak connections removed)

  Types:
  - Unstructured: Remove individual weights (sparse matrix)
  - Structured:   Remove entire neurons/heads/layers (faster)
  - Width pruning: Fewer neurons per layer
  - Depth pruning: Fewer layers (layer dropping)

  Results: 20-50% size reduction with <5% quality loss


QUANTIZATION: Reduce number precision
  (covered in detail in [Inference Optimization](../inference/inference-optimization.md))
  FP32 â†’ FP16 â†’ INT8 â†’ INT4
  Each step: ~2x smaller, slight quality trade-off


ARCHITECTURE CHANGES:
  - Replace attention with more efficient variants
  - Reduce hidden dimensions
  - Fewer layers
  - Smaller vocabulary
```

### Compression Comparison

| Technique               | Size Reduction | Speed Gain | Quality Loss   | Effort                   |
| ----------------------- | -------------- | ---------- | -------------- | ------------------------ |
| **Distillation**        | 10-50x         | 10-50x     | 5-20%          | High (need teacher data) |
| **Pruning**             | 2-5x           | 2-3x       | 2-10%          | Medium                   |
| **Quantization** (INT4) | 4x             | 2-3x       | 1-5%           | Low (post-hoc)           |
| **LoRA/QLoRA**          | ~same size     | ~same      | Tuned for task | Low                      |
| **Combined**            | 50-200x        | 20-100x    | 10-25%         | High                     |

### Real-World Distillation Examples

| Teacher            | Student             | Size Ratio    | Quality Retained              |
| ------------------ | ------------------- | ------------- | ----------------------------- |
| DeepSeek-R1 (671B) | R1-Distill-Qwen-32B | 21x smaller   | ~85-90% on reasoning          |
| DeepSeek-R1 (671B) | R1-Distill-Qwen-7B  | 96x smaller   | ~70-80% on reasoning          |
| GPT-4 (1.8T est.)  | Phi-3 (3.8B)        | ~470x smaller | ~75-85% on benchmarks         |
| Claude/GPT-4       | Orca-2 (13B)        | ~140x smaller | Strong step-by-step reasoning |

---

## â—† Quick Reference

```
DISTILLATION DECISION TREE:
  Need to deploy on edge/mobile?
    â†’ Quantize (INT4) + distill to small model

  Need reasoning capability in small model?
    â†’ Rationale distillation from o1/R1

  Need domain-specific small model?
    â†’ Fine-tune small model on teacher-generated domain data

  Need fastest possible inference?
    â†’ Distill + quantize + prune (all three)

KEY INSIGHT:
  Distillation â‰  just fine-tuning on outputs.
  The soft probability distribution contains MORE information
  than hard labels. "AI" at 0.35 and "ML" at 0.25 tells the
  student that AI and ML are related. Hard label "AI" doesn't.
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Distilling from API outputs may violate ToS**: OpenAI/Anthropic prohibit using their outputs to train competing models. Check terms.
- âš ï¸ **Not everything transfers**: Distillation works best for surface knowledge. Deep reasoning and world knowledge transfer is harder.
- âš ï¸ **Model collapse risk**: Repeated distillation (distilling distilled models) degrades quality. Use the original teacher.
- âš ï¸ **Temperature matters**: Too low T â†’ student only learns top predictions. Too high T â†’ noise. T=2-4 is typical.

---

## â—‹ Interview Angles

- **Q**: How does knowledge distillation work?
- **A**: A large "teacher" model's soft probability outputs (including relationships between classes) are used as training targets for a smaller "student" model. The student learns to match the teacher's full output distribution using KL divergence loss, not just the correct answer. This transfers "dark knowledge" â€” the teacher's implicit understanding of which concepts are similar.

- **Q**: How is DeepSeek-R1-Distill created?
- **A**: DeepSeek-R1 (671B MoE) generates reasoning chains for thousands of problems. These (input, reasoning_chain + answer) pairs become fine-tuning data for smaller models like Qwen-14B. The small model literally learns to REASON like R1 by mimicking its step-by-step thinking.

---

## â˜… Code & Implementation

### Knowledge Distillation: Teacher â†’ Student Loss

```python
# pip install torch>=2.3 transformers>=4.40
# âš ï¸ Last tested: 2026-04 | Requires: torch>=2.3
import torch
import torch.nn as nn
import torch.nn.functional as F

def distillation_loss(
    student_logits: torch.Tensor,
    teacher_logits: torch.Tensor,
    labels: torch.Tensor,
    temperature: float = 4.0,
    alpha: float = 0.7,
) -> torch.Tensor:
    """
    Combined distillation + CE loss.

    student_logits: (batch, seq, vocab)
    teacher_logits: (batch, seq, vocab)
    labels:         (batch, seq) ground-truth token IDs
    temperature:    softs the teacher distribution (higher = more information)
    alpha:          weight of distillation loss (1-alpha = CE weight)
    """
    # Soft targets from teacher (temperature scaling)
    soft_teacher = F.softmax(teacher_logits / temperature, dim=-1)
    soft_student = F.log_softmax(student_logits / temperature, dim=-1)
    kd_loss = F.kl_div(soft_student, soft_teacher, reduction="batchmean") * (temperature ** 2)

    # Hard targets from ground truth labels
    ce_loss = F.cross_entropy(
        student_logits.view(-1, student_logits.size(-1)),
        labels.view(-1),
        ignore_index=-100,
    )

    return alpha * kd_loss + (1 - alpha) * ce_loss

# Example shapes (tiny vocab for demo)
batch, seq, vocab = 2, 10, 100
student_logits = torch.randn(batch, seq, vocab)
teacher_logits = torch.randn(batch, seq, vocab)
labels         = torch.randint(0, vocab, (batch, seq))

loss = distillation_loss(student_logits, teacher_logits, labels)
print(f"Distillation loss: {loss.item():.4f}")

# GGUF Quantization check (inference only â€” requires llama.cpp)
# After downloading a GGUF model:
# from llama_cpp import Llama
# llm = Llama(model_path="./model.gguf", n_ctx=2048)
# output = llm("Explain LoRA in one sentence.", max_tokens=80)
# print(output["choices"][0]["text"])
```

## â˜… Connections

| Relationship | Topics                                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Fine Tuning](./fine-tuning.md), [Deep Learning Fundamentals](../prerequisites/deep-learning-fundamentals.md) |
| Leads to     | Edge AI deployment, [Inference Optimization](../inference/inference-optimization.md)                          |
| Compare with | Quantization (number precision), Pruning (removing weights)                                                   |
| Cross-domain | Transfer learning, Curriculum learning                                                                        |


---

## â—† Production Failure Modes

| Failure                   | Symptoms                                                                   | Root Cause                                 | Mitigation                                                     |
| ------------------------- | -------------------------------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------- |
| **Capability cliff**      | Student model loses specific capabilities while matching aggregate metrics | Distillation data doesn't cover edge cases | Targeted distillation on weak subsets, multi-task distillation |
| **Quantization outliers** | Quality drops sharply at INT4/INT8                                         | Activation outliers in certain layers      | SmoothQuant, GPTQ per-channel quantization, mixed precision    |
| **Pruning instability**   | Structured pruning removes critical attention heads                        | No importance scoring before pruning       | Magnitude + gradient importance scores, iterative pruning      |
| **Format mismatch**       | Distilled model can't follow complex instructions                          | Training data focused on short completions | Include instruction-following examples in distillation dataset |

---

## â—† Hands-On Exercises

### Exercise 1: Quantize and Benchmark at Multiple Precisions

**Goal**: Quantize a model from FP16 to INT8 to INT4 and benchmark
**Time**: 30 minutes
**Steps**:
1. Load a base model in FP16
2. Quantize with bitsandbytes (8-bit, then 4-bit)
3. Run a standard benchmark at each precision
4. Measure inference speed at each level
**Expected Output**: Quality/speed tradeoff chart across precisions
---


## â˜… Recommended Resources

| Type    | Resource                                                                                           | Why                                               |
| ------- | -------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| ðŸ“„ Paper | [Hinton et al. "Distilling Knowledge in Neural Networks" (2015)](https://arxiv.org/abs/1503.02531) | The foundational knowledge distillation paper     |
| ðŸ“„ Paper | [Dettmers et al. "GPTQ" (2022)](https://arxiv.org/abs/2210.17323)                                  | Post-training quantization for large models       |
| ðŸ“˜ Book  | "Efficient Deep Learning" by Menghani (2024)                                                       | Comprehensive treatment of compression techniques |

## â˜… Sources

- Hinton et al., "Distilling the Knowledge in a Neural Network" (2015) â€” the original paper
- DeepSeek, "DeepSeek-R1 Distilled Models" (2025)
- Microsoft, "Phi-3 Technical Report" (2024)
- Gou et al., "Knowledge Distillation: A Survey" (2021)
