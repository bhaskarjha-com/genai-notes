---
title: "Deep Learning Fundamentals"
tags: [deep-learning, training, optimizer, regularization, gpu, genai-prerequisite]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["neural-networks.md", "python-for-ai.md", "../foundations/transformers.md", "../techniques/fine-tuning.md"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Deep Learning Fundamentals

> ✨ **Bit**: Training a neural network is like adjusting millions of knobs simultaneously. Each knob only has to move a tiny bit, but do it billions of times and somehow the model learns to write poetry, code, and diagnose diseases.

---

## ★ TL;DR

- **What**: The training pipeline, optimization techniques, and practical skills for training/fine-tuning deep learning models
- **Why**: Knowing architecture ([Neural Networks](./neural-networks.md)) tells you WHAT a model is. This tells you HOW it learns.
- **Key point**: The training loop (forward → loss → backward → update) is the same whether you're training a 10-parameter model or GPT-5. Only scale differs.

---

## ★ Overview

### Definition

**Deep learning fundamentals** covers the practical machinery of training neural networks — the training loop, optimizers, regularization, learning rate scheduling, and hardware considerations that turn an untrained model into a useful one.

### Scope

Covers training mechanics applicable to all GenAI models. For Transformer-specific architecture, see [Transformers](../foundations/transformers.md). For LLM-specific fine-tuning (LoRA, QLoRA), see [Fine Tuning](../techniques/fine-tuning.md).

### Prerequisites

- [Neural Networks](./neural-networks.md) — architecture basics
- [Linear Algebra For Ai](./linear-algebra-for-ai.md) — matrix operations
- [Probability And Statistics](./probability-and-statistics.md) — loss functions

---

## ★ Deep Dive

### The Training Loop (Universal)

```python
# ⚠️ Last tested: 2026-04
# THE training loop — this is the same for BERT, GPT, Stable Diffusion, everything.
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

  Data ──► [Model] ──► Prediction ──► Loss ──┐
              ↑                                │
              │         ∂Loss/∂w ◄─── Backprop ◄┘
              │              │
              └──── Update ──┘
              w = w - lr × gradient

  Repeat billions of times = trained model
```

### Optimizers (How to Update Weights)

```
BASIC GRADIENT DESCENT:
  w_new = w_old - learning_rate × gradient

  Problem: Same learning rate for all parameters.
           Noisy updates. Gets stuck in local minima.
```

| Optimizer          | How It Improves                           | Used In          | Status                         |
| ------------------ | ----------------------------------------- | ---------------- | ------------------------------ |
| **SGD**            | Random mini-batches → faster iterations   | Classic ML       | Still used with momentum       |
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
  ████████  ████████
  ████         ████    ← Unstable!
      ████████

TOO LOW:
  Loss decreases painfully slowly
  ████████████████████████████  ← Eventually converges but takes forever
  ████████████████████████

JUST RIGHT:
  ████████████
  ████████
  ████████         ← Smooth convergence
  ████████
```

**Learning Rate Schedules:**

| Schedule                  | How It Works                               | Use                   |
| ------------------------- | ------------------------------------------ | --------------------- |
| **Constant**              | lr stays the same                          | Simple experiments    |
| **Linear Warmup + Decay** | Increase LR from 0 → peak, then decrease   | **Standard for LLMs** |
| **Cosine Annealing**      | LR follows cosine curve: high → low → high | Longer training       |
| **OneCycleLR**            | Warmup → peak → decay in one cycle         | Efficient training    |

```
TYPICAL LLM LEARNING RATE SCHEDULE:

  LR   │     ╱──────╲
       │    ╱         ╲
       │   ╱            ╲
       │  ╱               ╲
       │ ╱                  ╲
       │╱                     ╲
  ─────┼───┬──────────────────┬──────
       │ warmup    training    decay
       │ (~2000     (main      (cool
       │  steps)    phase)     down)
```

### Regularization (Preventing Overfitting)

```
OVERFITTING:
  "The model memorized the training data instead of learning patterns."

  Training accuracy: 99%   ← Looks great!
  Test accuracy: 60%       ← Actually terrible.

  The model is like a student who memorized test answers
  but doesn't understand the subject.
```

| Technique               | How It Works                                         | Where Used                  |
| ----------------------- | ---------------------------------------------------- | --------------------------- |
| **Dropout**             | Randomly disable neurons during training (e.g., 10%) | Transformer attention, FFN  |
| **Weight Decay**        | Add penalty for large weights: Loss + λ·‖w‖²         | AdamW (built-in)            |
| **Batch Normalization** | Normalize layer inputs to mean=0, std=1              | CNNs (less in Transformers) |
| **Layer Normalization** | Normalize across features per sample                 | **Transformers** (standard) |
| **Data Augmentation**   | Create variations of training data                   | Image models                |
| **Early Stopping**      | Stop when validation loss starts increasing          | All models                  |

> **For Transformers**: Layer Normalization + Dropout + Weight Decay (via AdamW) is the standard combo.

### GPU/CUDA Basics

```
WHY GPUs FOR AI?

  CPU: 8-128 cores → Great at complex sequential tasks
  GPU: 10,000+ cores → Great at simple parallel tasks

  Neural network = millions of identical multiply-add operations
  = PERFECT for GPUs

NVIDIA GPU HIERARCHY (2025-2026):
  Consumer:     RTX 4090 (24GB) → Fine for inference, small training
  Professional: A100 (40/80GB) → The workhorse of AI training
  Latest:       H100 (80GB) → 2-3x faster than A100
  Newest:       B200 (Blackwell, 192GB) → Next generation

VRAM IS THE BOTTLENECK:
  Model must fit in GPU memory (VRAM)
  LLaMA 7B in FP16 = ~14 GB → Fits on 1× RTX 4090
  LLaMA 70B in FP16 = ~140 GB → Need 2× A100 80GB
  LLaMA 70B in INT4 = ~35 GB → Fits on 1× A100 40GB or RTX 4090!
```

```python
# ⚠️ Last tested: 2026-04
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
| **Overfitting**         | Train loss ↓, val loss ↑     | More data, dropout, weight decay, early stopping        |
| **Underfitting**        | Both losses stay high        | Bigger model, more training, higher LR                  |
| **OOM (Out of Memory)** | CUDA out of memory error     | Smaller batch size, gradient accumulation, quantization |
| **Slow training**       | Each step takes too long     | Mixed precision, compiled model, better data loading    |

---

## ◆ Quick Reference

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

## ○ Gotchas & Common Mistakes

- ⚠️ **Learning rate too high**: The #1 cause of training failure. Start lower than you think.
- ⚠️ **No warmup**: Starting with high LR can destabilize early training. Always use warmup for Transformers.
- ⚠️ **Forgetting `model.eval()`**: For inference, always set `model.eval()` — it disables dropout and changes batch norm behavior.
- ⚠️ **Not monitoring validation loss**: You won't catch overfitting without a separate validation set.
- ⚠️ **Gradient accumulation math**: If accumulating over N steps, effective batch size = micro_batch × N. Scale LR accordingly.

---

## ○ Interview Angles

- **Q**: What optimizer do you use for training Transformers and why?
- **A**: AdamW. It's Adam with decoupled weight decay, which provides better regularization for Transformers. Adam adapts the learning rate per-parameter using running estimates of gradient mean and variance.

- **Q**: How would you handle GPU memory limitations when training?
- **A**: (1) Reduce batch size + gradient accumulation, (2) Mixed precision (BF16), (3) Gradient checkpointing, (4) LoRA/QLoRA (train small adapters not full model), (5) DeepSpeed ZeRO / FSDP (distribute across GPUs).

---

## ★ Code & Implementation

### Backpropagation from Scratch + PyTorch Comparison

```python
# pip install torch>=2.3
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3
import torch
import torch.nn as nn
import torch.nn.functional as F

# ═══ Manual 2-layer MLP forward + backward ═══
torch.manual_seed(42)
X = torch.randn(32, 10)      # 32 samples, 10 features
y = torch.randint(0, 3, (32,))  # 3-class labels

# Weights
W1 = torch.randn(10, 64, requires_grad=True)
b1 = torch.zeros(64,      requires_grad=True)
W2 = torch.randn(64, 3,  requires_grad=True)
b2 = torch.zeros(3,       requires_grad=True)

lr = 1e-3
for epoch in range(5):
    # Forward
    h   = F.relu(X @ W1 + b1)    # (32, 64)
    out = h @ W2 + b2             # (32, 3)
    loss = F.cross_entropy(out, y)

    # Backward
    loss.backward()

    # SGD update
    with torch.no_grad():
        W1 -= lr * W1.grad; W1.grad.zero_()
        b1 -= lr * b1.grad; b1.grad.zero_()
        W2 -= lr * W2.grad; W2.grad.zero_()
        b2 -= lr * b2.grad; b2.grad.zero_()

    print(f"Epoch {epoch+1}: loss={loss.item():.4f}")

# ═══ Same with nn.Module ═══ (idiomatic PyTorch)
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(10, 64), nn.ReLU(),
            nn.Linear(64, 3),
        )
    def forward(self, x): return self.net(x)

model     = MLP()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
for epoch in range(5):
    optimizer.zero_grad()
    loss = F.cross_entropy(model(X), y)
    loss.backward()
    optimizer.step()
print(f"nn.Module final loss: {loss.item():.4f}")
```

## ★ Connections

| Relationship | Topics                                                                                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Neural Networks](./neural-networks.md), [Linear Algebra For Ai](./linear-algebra-for-ai.md), [Probability And Statistics](./probability-and-statistics.md)   |
| Leads to     | [Transformers](../foundations/transformers.md), [Fine Tuning](../techniques/fine-tuning.md), [Inference Optimization](../inference/inference-optimization.md) |
| Compare with | Classical ML training (scikit-learn — much simpler)                                                                                                           |
| Cross-domain | Optimization theory, Numerical methods, Systems engineering                                                                                                   |


---

## ◆ Production Failure Modes

| Failure                           | Symptoms                                    | Root Cause                                                 | Mitigation                                               |
| --------------------------------- | ------------------------------------------- | ---------------------------------------------------------- | -------------------------------------------------------- |
| **Vanishing/exploding gradients** | Training loss plateaus or diverges          | Deep networks with poor initialization or no normalization | Layer normalization, residual connections, careful init  |
| **Overfitting on small datasets** | Training accuracy 99% but test accuracy 60% | Insufficient regularization, model too large for data      | Dropout, weight decay, data augmentation, early stopping |
| **Learning rate pathology**       | Training never converges or oscillates      | LR too high/low, no schedule                               | LR finder, cosine annealing, warmup + decay              |

---

## ◆ Hands-On Exercises

### Exercise 1: Diagnose Training Pathologies

**Goal**: Deliberately cause and then fix common training failures
**Time**: 30 minutes
**Steps**:
1. Train a small neural network on MNIST
2. Remove batch normalization — observe gradient issues
3. Set learning rate to 1.0 — observe divergence
4. Fix each issue and plot the corrected training curves
**Expected Output**: Before/after training curves for each pathology
---


## ★ Recommended Resources

| Type     | Resource                                                                                                    | Why                                          |
| -------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| 📘 Book   | "Deep Learning" by Goodfellow, Bengio, Courville (2016)                                                     | The definitive deep learning textbook        |
| 🎓 Course | [fast.ai — Practical Deep Learning](https://course.fast.ai/)                                                | Best practical introduction to deep learning |
| 🎥 Video  | [3Blue1Brown — "Neural Networks"](https://www.youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi) | Beautiful visual explanations of DL concepts |

## ★ Sources

- Karpathy, "Let's Build GPT from Scratch" — https://youtube.com/watch?v=kCc8FmEb1nY
- Ian Goodfellow, "Deep Learning" Chapters 7-8 (Regularization, Optimization)
- PyTorch Training Tutorial — https://pytorch.org/tutorials/beginner/basics/optimization_tutorial.html
- Loshchilov & Hutter, "Decoupled Weight Decay Regularization" (AdamW, 2017)
