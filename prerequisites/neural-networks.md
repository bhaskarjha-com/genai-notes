---
title: "Neural Networks"
tags: [neural-networks, perceptron, backpropagation, activation, cnn, rnn, genai-prerequisite]
type: concept
difficulty: beginner
status: published
parent: "[[../genai]]"
related: ["[[../foundations/transformers]]", "[[deep-learning-fundamentals]]", "[[linear-algebra-for-ai]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Neural Networks

> âœ¨ **Bit**: A neural network is just layers of math (multiply, add, apply function, repeat). We call them "neurons" because marketing, not because they actually work like brains.

---

## â˜… TL;DR

- **What**: Computational models made of layers of interconnected nodes that learn patterns from data by adjusting weights
- **Why**: THE foundation of deep learning and GenAI. Every LLM, every diffusion model, every AI agent runs on neural networks underneath.
- **Key point**: Input â†’ multiply by weights â†’ add bias â†’ apply activation function â†’ output. Stack layers of this = deep learning.

---

## â˜… Overview

### Definition

A **neural network** is a function approximator made of layers of interconnected nodes (neurons). Each connection has a learnable weight. By adjusting these weights through training (backpropagation), the network learns to map inputs to desired outputs.

### Scope

Covers the building blocks needed to understand GenAI architectures. For the specific architecture powering LLMs, see [Transformers](../foundations/transformers.md). For training details, see [Deep Learning Fundamentals](./deep-learning-fundamentals.md).

### Significance

- Every GenAI model is a neural network
- Understanding neurons â†’ layers â†’ architectures is required to understand Transformers, diffusion, etc.
- Activation functions, backpropagation, and gradient flow are concepts you'll see EVERYWHERE

### Prerequisites

- [Linear Algebra For Ai](./linear-algebra-for-ai.md) â€” matrix multiplication is the core operation
- Basic [Python For Ai](./python-for-ai.md) â€” for code examples

---

## â˜… Deep Dive

### The Neuron (Simplest Unit)

```
A single neuron:

  Inputs       Weights
  xâ‚ â”€â”€â”€â”€ wâ‚ â”€â”€â”
  xâ‚‚ â”€â”€â”€â”€ wâ‚‚ â”€â”€â”¼â”€â”€â–º Î£(wáµ¢xáµ¢ + b) â”€â”€â–º activation(z) â”€â”€â–º output
  xâ‚ƒ â”€â”€â”€â”€ wâ‚ƒ â”€â”€â”˜     â†‘                    â†‘
                    bias (b)         e.g., ReLU, Sigmoid

MATH:
  z = wâ‚xâ‚ + wâ‚‚xâ‚‚ + wâ‚ƒxâ‚ƒ + b    (weighted sum + bias)
  output = activation(z)            (apply non-linearity)

In matrix form:
  z = WÂ·x + b          â† This is why linear algebra matters!
  output = Ïƒ(z)         â† Ïƒ = activation function
```

### Layers

```
INPUT LAYER        HIDDEN LAYERS           OUTPUT LAYER
(your data)        (learned features)      (prediction)

  xâ‚ â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€ hâ‚ â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€ hâ‚… â”€â”€â”€â”€â”
           â”œâ”€â”€â”€â”€â”¤            â”œâ”€â”€â”€â”€â”¤            â”œâ”€â”€â”€â”€ Å·â‚
  xâ‚‚ â”€â”€â”€â”€â”€â”¤    â”œâ”€â”€â”€â”€ hâ‚‚ â”€â”€â”€â”€â”¤    â”œâ”€â”€â”€â”€ hâ‚† â”€â”€â”€â”€â”¤
           â”œâ”€â”€â”€â”€â”¤            â”œâ”€â”€â”€â”€â”¤            â”œâ”€â”€â”€â”€ Å·â‚‚
  xâ‚ƒ â”€â”€â”€â”€â”€â”¤    â”œâ”€â”€â”€â”€ hâ‚ƒ â”€â”€â”€â”€â”¤    â””â”€â”€â”€â”€ hâ‚‡ â”€â”€â”€â”€â”˜
           â”œâ”€â”€â”€â”€â”¤            â”‚
  xâ‚„ â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€ hâ‚„ â”€â”€â”€â”€â”˜

  Layer 0         Layer 1          Layer 2        Layer 3
  (4 neurons)     (4 neurons)      (3 neurons)    (2 neurons)

  "Deep" = More than 1 hidden layer
  GPT-5 has ~100+ layers with billions of neurons
```

### Activation Functions (Why Non-Linearity Matters)

```
WITHOUT activation: Each layer is just WÂ·x + b
  Layer 1: y = Wâ‚x + bâ‚
  Layer 2: y = Wâ‚‚(Wâ‚x + bâ‚) + bâ‚‚ = Wâ‚‚Wâ‚x + Wâ‚‚bâ‚ + bâ‚‚

  This collapses to: y = W'x + b'  â† Still just a LINEAR function!
  No matter how many layers, it's just one big linear transform.
  Linear functions can only draw straight lines. Useless for complex data.

WITH activation: Non-linearity lets the network learn ANY function.
```

| Function       | Formula           | Graph Shape    | When to Use                                           |
| -------------- | ----------------- | -------------- | ----------------------------------------------------- |
| **ReLU**       | max(0, x)         | `___/`         | Default for hidden layers (fast, simple)              |
| **GELU**       | x Â· Î¦(x)          | Smooth `___/`  | Transformers (GPT, BERT) â€” smoother than ReLU         |
| **Sigmoid**    | 1/(1+eâ»Ë£)         | S-curve [0,1]  | Output layer for binary classification                |
| **Tanh**       | (eË£-eâ»Ë£)/(eË£+eâ»Ë£) | S-curve [-1,1] | When you need centered outputs                        |
| **Softmax**    | eË£â±/Î£eË£Ê²          | Probabilities  | Output layer for multi-class (next-token prediction!) |
| **SiLU/Swish** | x Â· sigmoid(x)    | Smooth `___/`  | Modern architectures (LLaMA, Mistral)                 |

> **For GenAI**: GELU is used in GPT/BERT. SiLU/Swish is used in LLaMA/Mistral. Softmax is the output for every LLM (probability over vocabulary).

### Backpropagation (How Networks Learn)

```
THE TRAINING LOOP:

  â”Œâ”€â”€â”€ 1. FORWARD PASS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚    Push input through network â†’ get prediction     â”‚
  â”‚    x â†’ Layer1 â†’ Layer2 â†’ ... â†’ Å· (prediction)     â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
  â”Œâ”€â”€â”€ 2. COMPUTE LOSS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚    How wrong is the prediction?                    â”‚
  â”‚    Loss = L(Å·, y)  e.g., cross-entropy, MSE      â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
  â”Œâ”€â”€â”€ 3. BACKWARD PASS (Backpropagation) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚    Calculate: âˆ‚Loss/âˆ‚w for EVERY weight            â”‚
  â”‚    Uses the chain rule of calculus:                 â”‚
  â”‚    âˆ‚L/âˆ‚wâ‚ = âˆ‚L/âˆ‚Å· Â· âˆ‚Å·/âˆ‚hâ‚‚ Â· âˆ‚hâ‚‚/âˆ‚hâ‚ Â· âˆ‚hâ‚/âˆ‚wâ‚â”‚
  â”‚    "How much did each weight contribute to error?"  â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
  â”Œâ”€â”€â”€ 4. UPDATE WEIGHTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚    w_new = w_old - learning_rate Ã— gradient        â”‚
  â”‚    Move each weight a tiny step to reduce loss     â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                         â”‚
                         â–¼
              Repeat for thousands of iterations
              until loss is small enough
```

**The chain rule** is the mathematical core. You don't need to compute it manually â€” PyTorch's `autograd` does it automatically. But understanding the concept is crucial.

### Network Types (Building Blocks for GenAI)

| Type                   | Architecture                        | What It's Good At                   | GenAI Relevance                                       |
| ---------------------- | ----------------------------------- | ----------------------------------- | ----------------------------------------------------- |
| **Feed-Forward (FFN)** | Input â†’ Hidden â†’ Output             | Simple classification/regression    | Used INSIDE Transformers (the MLP block)              |
| **CNN**                | Convolutional filters + pooling     | Images, spatial patterns            | Vision encoders (ViT combines CNN ideas + attention)  |
| **RNN/LSTM**           | Sequential processing, hidden state | Sequential data (text, time series) | **Replaced by Transformers** (RNNs can't parallelize) |
| **Transformer**        | Self-attention + FFN                | Everything (text, image, video)     | THE architecture of modern GenAI                      |

```
Evolution:  FFN (1980s) â†’ CNN (1998) â†’ RNN/LSTM (2014) â†’ Transformer (2017)
                                                           â†‘
                                                    This won. Everything else
                                                    is supporting architecture.
```

---

## â—† Code & Implementation

```python
# â•â•â• SIMPLE NEURAL NETWORK IN PYTORCH â•â•â•
import torch
import torch.nn as nn

# Define a 3-layer neural network
class SimpleNN(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super().__init__()
        self.layer1 = nn.Linear(input_size, hidden_size)   # Input â†’ Hidden
        self.layer2 = nn.Linear(hidden_size, hidden_size)  # Hidden â†’ Hidden
        self.layer3 = nn.Linear(hidden_size, output_size)  # Hidden â†’ Output
        self.relu = nn.ReLU()                               # Activation

    def forward(self, x):
        x = self.relu(self.layer1(x))   # Layer 1 + ReLU
        x = self.relu(self.layer2(x))   # Layer 2 + ReLU
        x = self.layer3(x)              # Output (no activation â€” loss handles it)
        return x

# Create model
model = SimpleNN(input_size=784, hidden_size=256, output_size=10)
print(f"Parameters: {sum(p.numel() for p in model.parameters()):,}")
# â†’ Parameters: 268,810  (tiny! GPT-5 has ~1 trillion)

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

## â—† Quick Reference

```
BUILDING BLOCKS:
  Neuron = weights Ã— inputs + bias â†’ activation
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
  Hidden layers â†’ ReLU (default), GELU (Transformers), SiLU (LLaMA)
  Binary output â†’ Sigmoid
  Multi-class  â†’ Softmax
  Regression   â†’ None (linear output)
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **"Neural networks work like brains"**: No. They're matrix multiplications with non-linear functions. The analogy is marketing.
- âš ï¸ **Vanishing gradients**: In very deep networks, gradients can shrink to near-zero. ReLU and residual connections fix this.
- âš ï¸ **More layers â‰  always better**: Without proper techniques (residuals, normalization), deeper networks can actually perform worse.
- âš ï¸ **Overfitting**: Network memorizes training data instead of learning patterns. Use dropout, regularization, more data.

---

## â—‹ Interview Angles

- **Q**: What does backpropagation actually compute?
- **A**: The gradient of the loss function with respect to every weight in the network, using the chain rule of calculus. These gradients tell us how to adjust each weight to reduce the error.

- **Q**: Why do we need activation functions?
- **A**: Without non-linear activation, any number of layers collapses to a single linear transformation (y = Wx + b). Non-linearity lets the network approximate any function, not just lines/planes.

---

## â˜… Connections

| Relationship | Topics                                                          |
| ------------ | --------------------------------------------------------------- |
| Builds on    | [Linear Algebra For Ai](./linear-algebra-for-ai.md), [Probability And Statistics](./probability-and-statistics.md)       |
| Leads to     | [Transformers](../foundations/transformers.md), [Deep Learning Fundamentals](./deep-learning-fundamentals.md) |
| Compare with | Decision trees, SVMs (simpler ML models)                        |
| Cross-domain | Neuroscience (loose inspiration), Control theory                |

---

## â˜… Sources

- 3Blue1Brown "Neural Networks" series â€” https://youtube.com/playlist?list=PLZHQObOWTQDNU6R1_67000Dx_ZCJB-3pi
- Google "Neural Networks" course â€” https://developers.google.com/machine-learning/crash-course
- Ian Goodfellow, "Deep Learning" textbook (2016) â€” Chapter 6
- PyTorch Tutorials â€” https://pytorch.org/tutorials/
