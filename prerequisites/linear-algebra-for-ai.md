---
title: "Linear Algebra for AI"
tags: [linear-algebra, vectors, matrices, dot-product, tensors, genai-prerequisite]
type: concept
difficulty: beginner
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["neural-networks.md", "../foundations/embeddings.md", "../foundations/attention-mechanism.md"]
source: "3Blue1Brown, Khan Academy, Deep Learning Book"
created: 2026-03-18
updated: 2026-04-11
---

# Linear Algebra for AI

> ✨ **Bit**: All of deep learning is matrix multiplication. Literally. The GPU is just a really fast matrix multiplier. Understanding vectors and matrices = understanding what AI actually computes.

---

## ★ TL;DR

- **What**: The math of vectors (lists of numbers) and matrices (grids of numbers) and the operations on them
- **Why**: Neural networks ARE matrix operations. Attention IS dot products. Embeddings ARE vectors. You can't deeply understand GenAI without this.
- **Key point**: You don't need a math degree. You need: vectors, dot products, matrix multiply, and cosine similarity. That covers 90% of what matters for GenAI.

---

## ★ Overview

### Definition

**Linear algebra** is the branch of mathematics dealing with vectors, matrices, and linear transformations. For AI, it provides the computational framework — every neural network forward pass is a series of matrix multiplications with non-linear activations.

### Scope

Covers only what's needed for understanding GenAI. Not a full linear algebra course — focused on practical AI-relevant concepts with intuition > proofs.

### Significance

- Every forward pass in an LLM = thousands of matrix multiplications
- Embeddings = vectors in high-dimensional space
- Attention mechanism = scaled dot product of matrices
- GPU acceleration exists because matrix math parallelizes perfectly

### Prerequisites

- High school math (basic arithmetic)

---

## ★ Deep Dive

### Scalars, Vectors, Matrices, Tensors

```
SCALAR (0D):  A single number
  5, 3.14, -2.7

VECTOR (1D):  A list of numbers
  [0.2, -0.5, 0.8, 0.1]

  In AI: An embedding, a row of weights, a data point
  "King" → [0.2, -0.5, 0.8, 0.1, ...] (768 numbers)

MATRIX (2D):  A grid of numbers (rows × columns)
  ┌ 1  2  3 ┐
  │ 4  5  6 │    Shape: (2, 3) = 2 rows × 3 columns
  └         ┘

  In AI: A weight matrix, a batch of embeddings, attention scores

TENSOR (nD):  Generalization to any number of dimensions
  3D: A stack of matrices (e.g., batch of attention matrices)
  4D: Batch × Channels × Height × Width (images)

  In AI: Everything in PyTorch is a tensor
```

```python
# ?? Last tested: 2026-04
import torch

scalar = torch.tensor(5.0)           # 0D: shape ()
vector = torch.tensor([1, 2, 3])     # 1D: shape (3,)
matrix = torch.tensor([[1,2],[3,4]]) # 2D: shape (2, 2)
tensor = torch.randn(32, 128, 768)   # 3D: batch × sequence × embedding
```

### The Operations That Matter

#### 1. Dot Product (Most Important for GenAI!)

```
Dot product of two vectors:
  a = [1, 2, 3]
  b = [4, 5, 6]

  a · b = (1×4) + (2×5) + (3×6) = 4 + 10 + 18 = 32

What it measures: SIMILARITY between two vectors.
  - Large positive → vectors point same direction (similar)
  - Near zero      → vectors are perpendicular (unrelated)
  - Large negative → vectors point opposite (opposite meaning)

WHERE IN GenAI:
  ✦ Attention scores:  score = Q · Kᵀ
  ✦ Cosine similarity: sim = (a·b) / (||a|| × ||b||)
  ✦ Embedding comparison in RAG
  ✦ Neuron computation: output = w·x + b
```

#### 2. Matrix Multiplication

```
A (2×3) × B (3×2) = C (2×2)

  ┌ 1  2  3 ┐     ┌ 7   8 ┐     ┌ 58   64 ┐
  │ 4  5  6 │  ×  │ 9  10 │  =  │ 139  154│
  └         ┘     │ 11 12 │     └          ┘
                  └       ┘

  C[0,0] = (1×7) + (2×9) + (3×11) = 7 + 18 + 33 = 58

RULE: Inner dimensions must match.
  (2×3) × (3×2) → works! Result: (2×2)
  (2×3) × (4×2) → ERROR! 3 ≠ 4

WHERE IN GenAI:
  ✦ Forward pass: output = W·input + b (every layer!)
  ✦ Attention: QKᵀ (query × key transpose)
  ✦ Why GPUs are used: Matrix multiply parallelizes perfectly
```

```python
# ?? Last tested: 2026-04
# Matrix multiply in PyTorch
A = torch.randn(2, 3)
B = torch.randn(3, 2)
C = A @ B            # @ = matrix multiply operator
# or: C = torch.matmul(A, B)
print(C.shape)  # torch.Size([2, 2])

# This is literally what every neural network layer does:
input = torch.randn(32, 768)      # 32 samples, 768 features
weight = torch.randn(768, 3072)   # Weight matrix
output = input @ weight            # (32, 768) × (768, 3072) = (32, 3072)
```

#### 3. Transpose

```
Flip rows and columns:

  A = ┌ 1  2  3 ┐     Aᵀ = ┌ 1  4 ┐
      │ 4  5  6 │          │ 2  5 │
      └         ┘          │ 3  6 │
                           └     ┘
  (2×3) → (3×2)

WHERE IN GenAI:
  ✦ Attention: Kᵀ (transpose the Key matrix for dot product)
  ✦ Weight sharing / dimension alignment
```

#### 4. Cosine Similarity

```
Cosine similarity: measure angle between vectors (ignore magnitude)

  cos(θ) = (a · b) / (||a|| × ||b||)

  ||a|| = norm = √(a₁² + a₂² + ... + aₙ²)   ← length of vector

  Range: -1 (opposite) to 1 (identical)

WHERE IN GenAI:
  ✦ Comparing embeddings in vector databases
  ✦ Semantic similarity in RAG retrieval
  ✦ "How similar are these two texts?"
```

#### 5. Softmax (Vector → Probability Distribution)

```
Softmax turns any vector of numbers into probabilities (sum to 1):

  logits = [2.0, 1.0, 0.1]
  softmax = [eˣⁱ / Σeˣʲ]

  e²·⁰ = 7.39    → 7.39 / (7.39 + 2.72 + 1.11) = 0.66
  e¹·⁰ = 2.72    → 2.72 / 11.22 = 0.24
  e⁰·¹ = 1.11    → 1.11 / 11.22 = 0.10
                                              Sum = 1.00 ✓

WHERE IN GenAI:
  ✦ Attention weights: softmax(QKᵀ/√d) — THE equation
  ✦ Token prediction: LLM output layer → softmax → pick next token
  ✦ Classification: probability over classes
```

---

## ◆ How It All Fits in a Transformer

```
"Hello" → [Tokenize] → token_id [15496]
           ↓
[Embedding Lookup]  →  vector [0.12, -0.45, ...] (768-dim)
                        ↑ This is a VECTOR
           ↓
[Attention Layer]
  Q = input × Wq      ← MATRIX MULTIPLY
  K = input × Wk      ← MATRIX MULTIPLY
  V = input × Wv      ← MATRIX MULTIPLY
  scores = Q × Kᵀ     ← MATRIX MULTIPLY + TRANSPOSE
  weights = softmax(scores / √d)  ← SOFTMAX
  output = weights × V ← MATRIX MULTIPLY
           ↓
[Feed-Forward]
  output = W₂ · GELU(W₁ · input + b₁) + b₂  ← MATRIX MULTIPLY × 2
           ↓
[Repeat × 100 layers]
           ↓
[Output] → logits → SOFTMAX → probabilities → next token
```

**That's it.** Transformers are matrix multiplications + softmax + non-linear activations stacked 100+ times.

---

## ◆ Quick Reference

```
ESSENTIAL OPERATIONS (ranked by importance for GenAI):
  1. Dot product       → Attention scores, similarity
  2. Matrix multiply   → Every layer computation
  3. Transpose         → Attention mechanism (Kᵀ)
  4. Cosine similarity → Embedding comparison
  5. Softmax           → Probabilities (attention weights, output)
  6. Norms             → Normalization, regularization

SHAPES TO KNOW:
  Embedding:    (batch_size, seq_len, d_model)     e.g., (32, 512, 768)
  Weight matrix: (d_in, d_out)                      e.g., (768, 3072)
  Attention:     (batch, heads, seq_len, seq_len)   e.g., (32, 12, 512, 512)

PYTORCH CHEAT SHEET:
  a @ b          → matrix multiply
  a.T            → transpose
  a.shape        → dimensions
  torch.randn()  → random tensor
  torch.sum()    → sum elements
  F.softmax()    → softmax
  F.cosine_similarity()  → cosine sim
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Shape errors are 80% of debugging**: Always print `.shape` when things break. Most bugs are dimension mismatches.
- ⚠️ **Dot product ≠ element-wise multiply**: `a * b` ≠ `a @ b`. Element-wise keeps the shape; dot product reduces dimensions.
- ⚠️ **Matrix multiply is NOT commutative**: A × B ≠ B × A (usually). Order matters.
- ⚠️ **You don't need eigenvalues for GenAI**: They matter for PCA/SVD but are rarely needed in day-to-day GenAI work.

---

## ○ Interview Angles

- **Q**: Why is the dot product central to the attention mechanism?
- **A**: Attention computes Q·Kᵀ where Q = query and K = key. The dot product measures how "related" each query is to each key — high dot product = high attention. This is then softmaxed into weights that determine how much each value V contributes to the output.

- **Q**: Why are GPUs used for deep learning?
- **A**: Neural networks are fundamentally matrix multiplications. GPUs have thousands of cores designed for parallel math operations. A CPU might do matrix multiply sequentially; a GPU does thousands of multiply-adds simultaneously.

---

## ★ Connections

| Relationship | Topics                                                                                                                      |
| ------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | High school math                                                                                                            |
| Leads to     | [Neural Networks](./neural-networks.md), [Transformers](../foundations/transformers.md), [Attention Mechanism](../foundations/attention-mechanism.md), [Embeddings](../foundations/embeddings.md) |
| Compare with | Calculus (for backprop), Statistics (for distributions)                                                                     |
| Cross-domain | Physics (vector spaces), Computer graphics (transformations)                                                                |

---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🎥 Video | [3Blue1Brown — "Essence of Linear Algebra"](https://www.youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab) | Best visual linear algebra series ever created |
| 📘 Book | "Linear Algebra Done Right" by Axler (2015) | Rigorous but readable linear algebra |
| 🎓 Course | [MIT 18.06: Linear Algebra](https://ocw.mit.edu/courses/18-06sc-linear-algebra-fall-2011/) | Gilbert Strang's legendary course |

## ★ Sources

- 3Blue1Brown "Essence of Linear Algebra" — https://youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab
- Ian Goodfellow, "Deep Learning" Chapter 2 (Linear Algebra)
- Khan Academy Linear Algebra — https://khanacademy.org/math/linear-algebra
- Jay Alammar, "A Visual Intro to NumPy and Data Representation"
