---
title: "Deep Learning Fundamentals"
tags: [deep-learning, training, optimizer, regularization, gpu, genai-prerequisite]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[neural-networks]]", "[[python-for-ai]]", "[[../foundations/transformers]]", "[[../techniques/fine-tuning]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Deep Learning Fundamentals

> âœ¨ **Bit**: Training a neural network is like adjusting millions of knobs simultaneously. Each knob only has to move a tiny bit, but do it billions of times and somehow the model learns to write poetry, code, and diagnose diseases.

---

## â˜… TL;DR

- **What**: The training pipeline, optimization techniques, and practical skills for training/fine-tuning deep learning models
- **Why**: Knowing architecture ([Neural Networks](./neural-networks.md)) tells you WHAT a model is. This tells you HOW it learns.
- **Key point**: The training loop (forward â†’ loss â†’ backward â†’ update) is the same whether you're training a 10-parameter model or GPT-5. Only scale differs.

---

## â˜… Overview

### Definition

**Deep learning fundamentals** covers the practical machinery of training neural networks â€” the training loop, optimizers, regularization, learning rate scheduling, and hardware considerations that turn an untrained model into a useful one.

### Scope

Covers training mechanics applicable to all GenAI models. For Transformer-specific architecture, see [Transformers](../foundations/transformers.md). For LLM-specific fine-tuning (LoRA, QLoRA), see [Fine Tuning](../techniques/fine-tuning.md).

### Prerequisites

- [Neural Networks](./neural-networks.md) â€” architecture basics
- [Linear Algebra For Ai](./linear-algebra-for-ai.md) â€” matrix operations
- [Probability And Statistics](./probability-and-statistics.md) â€” loss functions

---

## â˜… Deep Dive

### The Training Loop (Universal)

```python
# THE training loop â€” this is the same for BERT, GPT, Stable Diffusion, everything.
for epoch in range(num_epochs):
    for batch in dataloader:
        # 1. FORWARD PASS: push data through model
        predictions = model(batch.inputs)

        # 2. COMPUTE LOSS: how wrong is the model?
        loss = loss_function(predictions, batch.targets)

        # 3. BACKWARD PASS: compute gradients (backpropagation)
        loss.backward()

        # 4. UPDATE WEIGHTS: adjust model parameters
        optimizer.step()

        # 5. RESET: clear gradients for next iteration
        optimizer.zero_grad()

        # 6. (Optional) SCHEDULE: adjust learning rate
        scheduler.step()
```

```
VISUALLY:

  Data â”€â”€â–º [Model] â”€â”€â–º Prediction â”€â”€â–º Loss â”€â”€â”
              â†‘                                â”‚
              â”‚         âˆ‚Loss/âˆ‚w â—„â”€â”€â”€ Backprop â—„â”˜
              â”‚              â”‚
              â””â”€â”€â”€â”€ Update â”€â”€â”˜
              w = w - lr Ã— gradient

  Repeat billions of times = trained model
```

### Optimizers (How to Update Weights)

```
BASIC GRADIENT DESCENT:
  w_new = w_old - learning_rate Ã— gradient

  Problem: Same learning rate for all parameters.
           Noisy updates. Gets stuck in local minima.
```

| Optimizer          | How It Improves                           | Used In          | Status                         |
| ------------------ | ----------------------------------------- | ---------------- | ------------------------------ |
| **SGD**            | Random mini-batches â†’ faster iterations   | Classic ML       | Still used with momentum       |
| **SGD + Momentum** | Accumulates past gradient direction       | CNNs             | Image models                   |
| **Adam**           | Adaptive LR per-parameter + momentum      | General          | Most popular default           |
| **AdamW**          | Adam + proper weight decay regularization | **Transformers** | **Standard for LLMs**          |
| **Adafactor**      | Memory-efficient Adam variant             | Large models     | When memory-constrained        |
| **LION**           | Simple sign-based updates                 | Emerging         | Research, sometimes beats Adam |

> **For GenAI**: AdamW is the standard. Almost every LLM/Transformer uses AdamW.

### Learning Rate (The Most Important Hyperparameter)

```
TOO HIGH:
  Loss bounces around, never converges, or explodes
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ
  â–ˆâ–ˆâ–ˆâ–ˆ         â–ˆâ–ˆâ–ˆâ–ˆ    â† Unstable!
      â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ

TOO LOW:
  Loss decreases painfully slowly
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ  â† Eventually converges but takes forever
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ

JUST RIGHT:
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ         â† Smooth convergence
  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ
```

**Learning Rate Schedules:**

| Schedule                  | How It Works                               | Use                   |
| ------------------------- | ------------------------------------------ | --------------------- |
| **Constant**              | lr stays the same                          | Simple experiments    |
| **Linear Warmup + Decay** | Increase LR from 0 â†’ peak, then decrease   | **Standard for LLMs** |
| **Cosine Annealing**      | LR follows cosine curve: high â†’ low â†’ high | Longer training       |
| **OneCycleLR**            | Warmup â†’ peak â†’ decay in one cycle         | Efficient training    |

```
TYPICAL LLM LEARNING RATE SCHEDULE:

  LR   â”‚     â•±â”€â”€â”€â”€â”€â”€â•²
       â”‚    â•±         â•²
       â”‚   â•±            â•²
       â”‚  â•±               â•²
       â”‚ â•±                  â•²
       â”‚â•±                     â•²
  â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€
       â”‚ warmup    training    decay
       â”‚ (~2000     (main      (cool
       â”‚  steps)    phase)     down)
```

### Regularization (Preventing Overfitting)

```
OVERFITTING:
  "The model memorized the training data instead of learning patterns."

  Training accuracy: 99%   â† Looks great!
  Test accuracy: 60%       â† Actually terrible.

  The model is like a student who memorized test answers
  but doesn't understand the subject.
```

| Technique               | How It Works                                         | Where Used                  |
| ----------------------- | ---------------------------------------------------- | --------------------------- |
| **Dropout**             | Randomly disable neurons during training (e.g., 10%) | Transformer attention, FFN  |
| **Weight Decay**        | Add penalty for large weights: Loss + Î»Â·â€–wâ€–Â²         | AdamW (built-in)            |
| **Batch Normalization** | Normalize layer inputs to mean=0, std=1              | CNNs (less in Transformers) |
| **Layer Normalization** | Normalize across features per sample                 | **Transformers** (standard) |
| **Data Augmentation**   | Create variations of training data                   | Image models                |
| **Early Stopping**      | Stop when validation loss starts increasing          | All models                  |

> **For Transformers**: Layer Normalization + Dropout + Weight Decay (via AdamW) is the standard combo.

### GPU/CUDA Basics

```
WHY GPUs FOR AI?

  CPU: 8-128 cores â†’ Great at complex sequential tasks
  GPU: 10,000+ cores â†’ Great at simple parallel tasks

  Neural network = millions of identical multiply-add operations
  = PERFECT for GPUs

NVIDIA GPU HIERARCHY (2025-2026):
  Consumer:     RTX 4090 (24GB) â†’ Fine for inference, small training
  Professional: A100 (40/80GB) â†’ The workhorse of AI training
  Latest:       H100 (80GB) â†’ 2-3x faster than A100
  Newest:       B200 (Blackwell, 192GB) â†’ Next generation

VRAM IS THE BOTTLENECK:
  Model must fit in GPU memory (VRAM)
  LLaMA 7B in FP16 = ~14 GB â†’ Fits on 1Ã— RTX 4090
  LLaMA 70B in FP16 = ~140 GB â†’ Need 2Ã— A100 80GB
  LLaMA 70B in INT4 = ~35 GB â†’ Fits on 1Ã— A100 40GB or RTX 4090!
```

```python
# Check GPU
import torch
print(torch.cuda.is_available())          # True if GPU ready
print(torch.cuda.get_device_name(0))      # e.g., "NVIDIA GeForce RTX 4090"
print(f"{torch.cuda.mem_get_info()[0]/1e9:.1f} GB free")  # Available VRAM

# Mixed precision training (use FP16 for speed, FP32 for stability)
from torch.cuda.amp import autocast, GradScaler
scaler = GradScaler()

with autocast():                     # Use FP16 where safe
    output = model(input)
    loss = loss_fn(output, target)

scaler.scale(loss).backward()        # Scale loss to prevent underflow
scaler.step(optimizer)               # Unscale and step
scaler.update()
```

### Common Training Problems & Fixes

| Problem                 | Symptom                      | Fix                                                     |
| ----------------------- | ---------------------------- | ------------------------------------------------------- |
| **Loss not decreasing** | Loss stays flat or increases | Lower LR, check data, check loss function               |
| **Loss explodes (NaN)** | Loss = inf or NaN            | Lower LR, gradient clipping, check data                 |
| **Overfitting**         | Train loss â†“, val loss â†‘     | More data, dropout, weight decay, early stopping        |
| **Underfitting**        | Both losses stay high        | Bigger model, more training, higher LR                  |
| **OOM (Out of Memory)** | CUDA out of memory error     | Smaller batch size, gradient accumulation, quantization |
| **Slow training**       | Each step takes too long     | Mixed precision, compiled model, better data loading    |

---

## â—† Quick Reference

```
TRAINING RECIPE (LLM fine-tuning):
  Optimizer: AdamW
  LR: 1e-4 to 2e-5  (lower for bigger models)
  Schedule: Linear warmup (5-10% of steps) + cosine decay
  Batch size: As large as VRAM allows (use gradient accumulation)
  Epochs: 1-3 (for fine-tuning; pre-training = 1 pass over data)
  Precision: BF16 or FP16 (mixed precision)
  Regularization: Dropout 0.1 + weight decay 0.01

MEMORY-SAVING TRICKS:
  1. Gradient accumulation (simulate large batches)
  2. Mixed precision (FP16/BF16)
  3. Gradient checkpointing (recompute instead of store)
  4. LoRA/QLoRA (train only small adapters)
  5. DeepSpeed / FSDP (distribute across GPUs)

METRICS TO MONITOR:
  - Training loss (should decrease)
  - Validation loss (should decrease, not diverge from train)
  - Learning rate (check schedule is working)
  - GPU utilization (should be >90%)
  - Memory usage (stay under limit)
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Learning rate too high**: The #1 cause of training failure. Start lower than you think.
- âš ï¸ **No warmup**: Starting with high LR can destabilize early training. Always use warmup for Transformers.
- âš ï¸ **Forgetting `model.eval()`**: For inference, always set `model.eval()` â€” it disables dropout and changes batch norm behavior.
- âš ï¸ **Not monitoring validation loss**: You won't catch overfitting without a separate validation set.
- âš ï¸ **Gradient accumulation math**: If accumulating over N steps, effective batch size = micro_batch Ã— N. Scale LR accordingly.

---

## â—‹ Interview Angles

- **Q**: What optimizer do you use for training Transformers and why?
- **A**: AdamW. It's Adam with decoupled weight decay, which provides better regularization for Transformers. Adam adapts the learning rate per-parameter using running estimates of gradient mean and variance.

- **Q**: How would you handle GPU memory limitations when training?
- **A**: (1) Reduce batch size + gradient accumulation, (2) Mixed precision (BF16), (3) Gradient checkpointing, (4) LoRA/QLoRA (train small adapters not full model), (5) DeepSpeed ZeRO / FSDP (distribute across GPUs).

---

## â˜… Connections

| Relationship | Topics                                                                                                  |
| ------------ | ------------------------------------------------------------------------------------------------------- |
| Builds on    | [Neural Networks](./neural-networks.md), [Linear Algebra For Ai](./linear-algebra-for-ai.md), [Probability And Statistics](./probability-and-statistics.md)                          |
| Leads to     | [Transformers](../foundations/transformers.md), [Fine Tuning](../techniques/fine-tuning.md), [Inference Optimization](../inference/inference-optimization.md) |
| Compare with | Classical ML training (scikit-learn â€” much simpler)                                                     |
| Cross-domain | Optimization theory, Numerical methods, Systems engineering                                             |

---

## â˜… Sources

- Karpathy, "Let's Build GPT from Scratch" â€” https://youtube.com/watch?v=kCc8FmEb1nY
- Ian Goodfellow, "Deep Learning" Chapters 7-8 (Regularization, Optimization)
- PyTorch Training Tutorial â€” https://pytorch.org/tutorials/beginner/basics/optimization_tutorial.html
- Loshchilov & Hutter, "Decoupled Weight Decay Regularization" (AdamW, 2017)
