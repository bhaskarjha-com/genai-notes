---
title: "Neural Networks"
tags: [neural-networks, perceptron, backpropagation, activation, cnn, rnn, genai-prerequisite]
type: concept
difficulty: beginner
status: published
last_verified: 2026-04
parent: "[[../genai]]"
related: ["[[../foundations/transformers]]", "[[deep-learning-fundamentals]]", "[[linear-algebra-for-ai]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Neural Networks

> ✨ **Bit**: A neural network is just layers of math (multiply, add, apply function, repeat). We call them "neurons" because marketing, not because they actually work like brains.

---

## ★ TL;DR

- **What**: Computational models made of layers of interconnected nodes that learn patterns from data by adjusting weights
- **Why**: THE foundation of deep learning and GenAI. Every LLM, every diffusion model, every AI agent runs on neural networks underneath.
- **Key point**: Input → multiply by weights → add bias → apply activation function → output. Stack layers of this = deep learning.

---

## ★ Overview

### Definition

A **neural network** is a function approximator made of layers of interconnected nodes (neurons). Each connection has a learnable weight. By adjusting these weights through training (backpropagation), the network learns to map inputs to desired outputs.

### Scope

Covers the building blocks needed to understand GenAI architectures. For the specific architecture powering LLMs, see [Transformers](../foundations/transformers.md). For training details, see [Deep Learning Fundamentals](./deep-learning-fundamentals.md).

### Significance

- Every GenAI model is a neural network
- Understanding neurons → layers → architectures is required to understand Transformers, diffusion, etc.
- Activation functions, backpropagation, and gradient flow are concepts you'll see EVERYWHERE

### Prerequisites

- [Linear Algebra For Ai](./linear-algebra-for-ai.md) — matrix multiplication is the core operation
- Basic [Python For Ai](./python-for-ai.md) — for code examples

---

## ★ Deep Dive

### The Neuron (Simplest Unit)

```
A single neuron:

  Inputs       Weights
  x₁ ──── w₁ ──┐
  x₂ ──── w₂ ──┼──► Σ(wᵢxᵢ + b) ──► activation(z) ──► output
  x₃ ──── w₃ ──┘     ↑                    ↑
                    bias (b)         e.g., ReLU, Sigmoid

MATH:
  z = w₁x₁ + w₂x₂ + w₃x₃ + b    (weighted sum + bias)
  output = activation(z)            (apply non-linearity)

In matrix form:
  z = W·x + b          ← This is why linear algebra matters!
  output = σ(z)         ← σ = activation function
```

### Layers

```
INPUT LAYER        HIDDEN LAYERS           OUTPUT LAYER
(your data)        (learned features)      (prediction)

  x₁ ─────┐    ┌──── h₁ ────┐    ┌──── h₅ ────┐
           ├────┤            ├────┤            ├──── ŷ₁
  x₂ ─────┤    ├──── h₂ ────┤    ├──── h₆ ────┤
           ├────┤            ├────┤            ├──── ŷ₂
  x₃ ─────┤    ├──── h₃ ────┤    └──── h₇ ────┘
           ├────┤            │
  x₄ ─────┘    └──── h₄ ────┘

  Layer 0         Layer 1          Layer 2        Layer 3
  (4 neurons)     (4 neurons)      (3 neurons)    (2 neurons)

  "Deep" = More than 1 hidden layer
  GPT-5 has ~100+ layers with billions of neurons
```

### Activation Functions (Why Non-Linearity Matters)

```
WITHOUT activation: Each layer is just W·x + b
  Layer 1: y = W₁x + b₁
  Layer 2: y = W₂(W₁x + b₁) + b₂ = W₂W₁x + W₂b₁ + b₂

  This collapses to: y = W'x + b'  ← Still just a LINEAR function!
  No matter how many layers, it's just one big linear transform.
  Linear functions can only draw straight lines. Useless for complex data.

WITH activation: Non-linearity lets the network learn ANY function.
```

| Function       | Formula           | Graph Shape    | When to Use                                           |
| -------------- | ----------------- | -------------- | ----------------------------------------------------- |
| **ReLU**       | max(0, x)         | `___/`         | Default for hidden layers (fast, simple)              |
| **GELU**       | x · Φ(x)          | Smooth `___/`  | Transformers (GPT, BERT) — smoother than ReLU         |
| **Sigmoid**    | 1/(1+e⁻ˣ)         | S-curve [0,1]  | Output layer for binary classification                |
| **Tanh**       | (eˣ-e⁻ˣ)/(eˣ+e⁻ˣ) | S-curve [-1,1] | When you need centered outputs                        |
| **Softmax**    | eˣⁱ/Σeˣʲ          | Probabilities  | Output layer for multi-class (next-token prediction!) |
| **SiLU/Swish** | x · sigmoid(x)    | Smooth `___/`  | Modern architectures (LLaMA, Mistral)                 |

> **For GenAI**: GELU is used in GPT/BERT. SiLU/Swish is used in LLaMA/Mistral. Softmax is the output for every LLM (probability over vocabulary).

### Backpropagation (How Networks Learn)

```
THE TRAINING LOOP:

  ┌─── 1. FORWARD PASS ──────────────────────────────┐
  │    Push input through network → get prediction     │
  │    x → Layer1 → Layer2 → ... → ŷ (prediction)     │
  └────────────────────────────────────────────────────┘
                         │
                         ▼
  ┌─── 2. COMPUTE LOSS ──────────────────────────────┐
  │    How wrong is the prediction?                    │
  │    Loss = L(ŷ, y)  e.g., cross-entropy, MSE      │
  └────────────────────────────────────────────────────┘
                         │
                         ▼
  ┌─── 3. BACKWARD PASS (Backpropagation) ───────────┐
  │    Calculate: ∂Loss/∂w for EVERY weight            │
  │    Uses the chain rule of calculus:                 │
  │    ∂L/∂w₁ = ∂L/∂ŷ · ∂ŷ/∂h₂ · ∂h₂/∂h₁ · ∂h₁/∂w₁│
  │    "How much did each weight contribute to error?"  │
  └────────────────────────────────────────────────────┘
                         │
                         ▼
  ┌─── 4. UPDATE WEIGHTS ────────────────────────────┐
  │    w_new = w_old - learning_rate × gradient        │
  │    Move each weight a tiny step to reduce loss     │
  └────────────────────────────────────────────────────┘
                         │
                         ▼
              Repeat for thousands of iterations
              until loss is small enough
```

**The chain rule** is the mathematical core. You don't need to compute it manually — PyTorch's `autograd` does it automatically. But understanding the concept is crucial.

### Network Types (Building Blocks for GenAI)

| Type                   | Architecture                        | What It's Good At                   | GenAI Relevance                                       |
| ---------------------- | ----------------------------------- | ----------------------------------- | ----------------------------------------------------- |
| **Feed-Forward (FFN)** | Input → Hidden → Output             | Simple classification/regression    | Used INSIDE Transformers (the MLP block)              |
| **CNN**                | Convolutional filters + pooling     | Images, spatial patterns            | Vision encoders (ViT combines CNN ideas + attention)  |
| **RNN/LSTM**           | Sequential processing, hidden state | Sequential data (text, time series) | **Replaced by Transformers** (RNNs can't parallelize) |
| **Transformer**        | Self-attention + FFN                | Everything (text, image, video)     | THE architecture of modern GenAI                      |

```
Evolution:  FFN (1980s) → CNN (1998) → RNN/LSTM (2014) → Transformer (2017)
                                                           ↑
                                                    This won. Everything else
                                                    is supporting architecture.
```

---

## ◆ Code & Implementation

```python
# ?? Last tested: 2026-04
# ═══ SIMPLE NEURAL NETWORK IN PYTORCH ═══
import torch
import torch.nn as nn

# Define a 3-layer neural network
class SimpleNN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super().__init__()
        self.layer1 = nn.Linear(input_size, hidden_size)   # Input → Hidden
        self.layer2 = nn.Linear(hidden_size, hidden_size)  # Hidden → Hidden
        self.layer3 = nn.Linear(hidden_size, output_size)  # Hidden → Output
        self.relu = nn.ReLU()                               # Activation

    def forward(self, x):
        x = self.relu(self.layer1(x))   # Layer 1 + ReLU
        x = self.relu(self.layer2(x))   # Layer 2 + ReLU
        x = self.layer3(x)              # Output (no activation — loss handles it)
        return x

# Create model
model = SimpleNN(input_size=784, hidden_size=256, output_size=10)
print(f"Parameters: {sum(p.numel() for p in model.parameters()):,}")
# → Parameters: 268,810  (tiny! GPT-5 has ~1 trillion)

# Training step
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
loss_fn = nn.CrossEntropyLoss()

# One training step:
input_data = torch.randn(32, 784)     # Batch of 32, 784 features
labels = torch.randint(0, 10, (32,))  # 32 labels (0-9)

prediction = model(input_data)         # 1. Forward pass
loss = loss_fn(prediction, labels)     # 2. Compute loss
loss.backward()                        # 3. Backpropagation (autograd!)
optimizer.step()                       # 4. Update weights
optimizer.zero_grad()                  # Reset gradients for next step
```

---

## ◆ Quick Reference

```
BUILDING BLOCKS:
  Neuron = weights × inputs + bias → activation
  Layer  = many neurons processing in parallel
  Network = stack of layers
  Deep   = more than 1 hidden layer

KEY NUMBERS:
  Simple NN:    ~100K-1M parameters
  CNN (ResNet): ~25M parameters
  BERT:         ~110M-340M parameters
  GPT-4:        ~1.8T parameters (estimated)
  GPT-5:        ~1T+ parameters

ACTIVATION CHOICE:
  Hidden layers → ReLU (default), GELU (Transformers), SiLU (LLaMA)
  Binary output → Sigmoid
  Multi-class  → Softmax
  Regression   → None (linear output)
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **"Neural networks work like brains"**: No. They're matrix multiplications with non-linear functions. The analogy is marketing.
- ⚠️ **Vanishing gradients**: In very deep networks, gradients can shrink to near-zero. ReLU and residual connections fix this.
- ⚠️ **More layers ≠ always better**: Without proper techniques (residuals, normalization), deeper networks can actually perform worse.
- ⚠️ **Overfitting**: Network memorizes training data instead of learning patterns. Use dropout, regularization, more data.

---

## ○ Interview Angles

- **Q**: What does backpropagation actually compute?
- **A**: The gradient of the loss function with respect to every weight in the network, using the chain rule of calculus. These gradients tell us how to adjust each weight to reduce the error.

- **Q**: Why do we need activation functions?
- **A**: Without non-linear activation, any number of layers collapses to a single linear transformation (y = Wx + b). Non-linearity lets the network approximate any function, not just lines/planes.

---

## ★ Connections

| Relationship | Topics                                                          |
| ------------ | --------------------------------------------------------------- |
| Builds on    | [Linear Algebra For Ai](./linear-algebra-for-ai.md), [Probability And Statistics](./probability-and-statistics.md)       |
| Leads to     | [Transformers](../foundations/transformers.md), [Deep Learning Fundamentals](./deep-learning-fundamentals.md) |
| Compare with | Decision trees, SVMs (simpler ML models)                        |
| Cross-domain | Neuroscience (loose inspiration), Control theory                |

---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🎥 Video | [3Blue1Brown — "What is a Neural Network?"](https://www.youtube.com/watch?v=aircAruvnKk) | Best visual introduction to neural networks |
| 🎓 Course | [Stanford CS231n](http://cs231n.stanford.edu/) | Deep dive into neural network architectures |
| 📘 Book | "Deep Learning" by Goodfellow, Bengio, Courville (2016), Ch 6 | Mathematical foundations of feedforward networks |

## ★ Sources

- 3Blue1Brown "Neural Networks" series — https://youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi
- Google "Neural Networks" course — https://developers.google.com/machine-learning/crash-course
- Ian Goodfellow, "Deep Learning" textbook (2016) — Chapter 6
- PyTorch Tutorials — https://pytorch.org/tutorials/
