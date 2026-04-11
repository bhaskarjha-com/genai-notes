---
title: "Knowledge Distillation & Model Compression"
tags: [distillation, compression, pruning, teacher-student, efficiency, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[fine-tuning]]", "[[../inference/inference-optimization]]", "[[../foundations/modern-architectures]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-03-22
---

# Knowledge Distillation & Model Compression

> ✨ **Bit**: GPT-4 knows a lot, but it's enormous and expensive. Distillation is like a PhD student learning from a professor — the student ends up much smaller but captures most of the professor's knowledge. That's how Phi-3 (3.8B) can compete with models 100x its size.

---

## ★ TL;DR

- **What**: Techniques to create smaller, faster, cheaper models that retain the capabilities of larger ones
- **Why**: You can't run GPT-4 on a phone. But you CAN distill its knowledge into a 7B model that runs anywhere.
- **Key point**: Distillation transfers "dark knowledge" (soft probabilities, reasoning patterns) from teacher to student, not just the final answers. This produces students far better than training from scratch.

---

## ★ Overview

### Definition

**Knowledge Distillation (KD)**: Training a small "student" model to mimic the behavior of a large "teacher" model. The student learns from the teacher's softmax distribution (soft labels) rather than just hard labels.

**Model Compression**: The umbrella term for making models smaller/faster, including distillation, pruning, quantization, and architecture changes.

### Scope

Covers distillation and pruning. For quantization (INT4/INT8/FP8), see [[../inference/inference-optimization]]. For fine-tuning (LoRA/QLoRA), see [[fine-tuning]].

### Significance

- How DeepSeek-R1-Distill-Qwen-32B and Phi-3 models are created
- Critical for edge deployment (mobile, IoT, embedded)
- Reduces inference costs 10-100x while retaining 80-95% quality
- Hot interview topic: "How would you deploy an LLM on device?"

---

## ★ Deep Dive

### The Distillation Framework

```
┌─────────────────────────────────────────────────┐
│            KNOWLEDGE DISTILLATION                │
│                                                 │
│  TEACHER (large, expensive)                      │
│  ┌──────────────────────┐                        │
│  │  GPT-4 / R1 / 70B   │                        │
│  │  Input: "What is AI?"│                        │
│  │  Output distribution:│                        │
│  │    AI:     0.35      │ ← "Soft labels"        │
│  │    ML:     0.25      │    Rich information!    │
│  │    robot:  0.15      │    "AI and ML are       │
│  │    code:   0.10      │     related" is encoded │
│  │    other:  0.15      │     in these probs.     │
│  └──────────┬───────────┘                        │
│             │ soft probabilities                  │
│             ▼                                    │
│  STUDENT (small, efficient)                      │
│  ┌──────────────────────┐                        │
│  │  7B / 3B / 1B model  │                        │
│  │  Learns to match the │                        │
│  │  teacher's soft       │                        │
│  │  distribution, not   │                        │
│  │  just the right      │                        │
│  │  answer              │                        │
│  └──────────────────────┘                        │
│                                                 │
│  LOSS = α × KL(teacher_soft, student_soft)      │
│       + (1-α) × CrossEntropy(student, labels)   │
│                                                 │
│  Temperature T → softens distributions          │
│  Higher T → more "dark knowledge" transfer      │
└─────────────────────────────────────────────────┘
```

### Types of Distillation

| Type                  | How It Works                                              | Example                        |
| --------------------- | --------------------------------------------------------- | ------------------------------ |
| **Response-based**    | Student mimics teacher's output distribution              | Classic: soft label matching   |
| **Feature-based**     | Student mimics teacher's intermediate representations     | Match hidden layer activations |
| **Relation-based**    | Student learns relationships between samples              | Contrastive distillation       |
| **Rationale-based**   | Teacher generates step-by-step reasoning as training data | DeepSeek-R1 → R1-Distill-Qwen  |
| **Multi-teacher**     | Multiple teachers guide one student                       | Ensemble knowledge transfer    |
| **Self-distillation** | Model teaches itself (larger layers → smaller)            | Born-again networks            |

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
    DeepSeek-R1 → R1-Distill-Qwen-14B, R1-Distill-Llama-70B
    GPT-4 → Alpaca/Vicuna (early 2023, simpler version)
    GPT-4 → Phi-3 (via synthetic data distillation)
```

### Other Compression Techniques

```
PRUNING: Remove unimportant weights/neurons/layers

  Before:  ●─●─●─●─●    (all connections active)
  After:   ●─ ─●─ ─●    (weak connections removed)

  Types:
  - Unstructured: Remove individual weights (sparse matrix)
  - Structured:   Remove entire neurons/heads/layers (faster)
  - Width pruning: Fewer neurons per layer
  - Depth pruning: Fewer layers (layer dropping)

  Results: 20-50% size reduction with <5% quality loss


QUANTIZATION: Reduce number precision
  (covered in detail in [[../inference/inference-optimization]])
  FP32 → FP16 → INT8 → INT4
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

## ◆ Quick Reference

```
DISTILLATION DECISION TREE:
  Need to deploy on edge/mobile?
    → Quantize (INT4) + distill to small model
  
  Need reasoning capability in small model?
    → Rationale distillation from o1/R1
  
  Need domain-specific small model?
    → Fine-tune small model on teacher-generated domain data
  
  Need fastest possible inference?
    → Distill + quantize + prune (all three)

KEY INSIGHT:
  Distillation ≠ just fine-tuning on outputs.
  The soft probability distribution contains MORE information
  than hard labels. "AI" at 0.35 and "ML" at 0.25 tells the
  student that AI and ML are related. Hard label "AI" doesn't.
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Distilling from API outputs may violate ToS**: OpenAI/Anthropic prohibit using their outputs to train competing models. Check terms.
- ⚠️ **Not everything transfers**: Distillation works best for surface knowledge. Deep reasoning and world knowledge transfer is harder.
- ⚠️ **Model collapse risk**: Repeated distillation (distilling distilled models) degrades quality. Use the original teacher.
- ⚠️ **Temperature matters**: Too low T → student only learns top predictions. Too high T → noise. T=2-4 is typical.

---

## ○ Interview Angles

- **Q**: How does knowledge distillation work?
- **A**: A large "teacher" model's soft probability outputs (including relationships between classes) are used as training targets for a smaller "student" model. The student learns to match the teacher's full output distribution using KL divergence loss, not just the correct answer. This transfers "dark knowledge" — the teacher's implicit understanding of which concepts are similar.

- **Q**: How is DeepSeek-R1-Distill created?
- **A**: DeepSeek-R1 (671B MoE) generates reasoning chains for thousands of problems. These (input, reasoning_chain + answer) pairs become fine-tuning data for smaller models like Qwen-14B. The small model literally learns to REASON like R1 by mimicking its step-by-step thinking.

---

## ★ Connections

| Relationship | Topics                                                           |
| ------------ | ---------------------------------------------------------------- |
| Builds on    | [[fine-tuning]], [[../prerequisites/deep-learning-fundamentals]] |
| Leads to     | Edge AI deployment, [[../inference/inference-optimization]]      |
| Compare with | Quantization (number precision), Pruning (removing weights)      |
| Cross-domain | Transfer learning, Curriculum learning                           |

---

## ★ Sources

- Hinton et al., "Distilling the Knowledge in a Neural Network" (2015) — the original paper
- DeepSeek, "DeepSeek-R1 Distilled Models" (2025)
- Microsoft, "Phi-3 Technical Report" (2024)
- Gou et al., "Knowledge Distillation: A Survey" (2021)
