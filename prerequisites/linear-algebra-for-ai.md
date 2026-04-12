---
title: "Linear Algebra for AI"
tags: [linear-algebra, vectors, matrices, dot-product, tensors, genai-prerequisite]
type: concept
difficulty: beginner
status: published
parent: "[[../genai]]"
related: ["[[neural-networks]]", "[[../foundations/embeddings]]", "[[../foundations/attention-mechanism]]"]
source: "3Blue1Brown, Khan Academy, Deep Learning Book"
created: 2026-03-18
updated: 2026-04-11
---

# Linear Algebra for AI

> âœ¨ **Bit**: All of deep learning is matrix multiplication. Literally. The GPU is just a really fast matrix multiplier. Understanding vectors and matrices = understanding what AI actually computes.

---

## â˜… TL;DR

- **What**: The math of vectors (lists of numbers) and matrices (grids of numbers) and the operations on them
- **Why**: Neural networks ARE matrix operations. Attention IS dot products. Embeddings ARE vectors. You can't deeply understand GenAI without this.
- **Key point**: You don't need a math degree. You need: vectors, dot products, matrix multiply, and cosine similarity. That covers 90% of what matters for GenAI.

---

## â˜… Overview

### Definition

**Linear algebra** is the branch of mathematics dealing with vectors, matrices, and linear transformations. For AI, it provides the computational framework â€” every neural network forward pass is a series of matrix multiplications with non-linear activations.

### Scope

Covers only what's needed for understanding GenAI. Not a full linear algebra course â€” focused on practical AI-relevant concepts with intuition > proofs.

### Significance

- Every forward pass in an LLM = thousands of matrix multiplications
- Embeddings = vectors in high-dimensional space
- Attention mechanism = scaled dot product of matrices
- GPU acceleration exists because matrix math parallelizes perfectly

### Prerequisites

- High school math (basic arithmetic)

---

## â˜… Deep Dive

### Scalars, Vectors, Matrices, Tensors

```
SCALAR (0D):  A single number
  5, 3.14, -2.7

VECTOR (1D):  A list of numbers
  [0.2, -0.5, 0.8, 0.1]

  In AI: An embedding, a row of weights, a data point
  "King" â†’ [0.2, -0.5, 0.8, 0.1, ...] (768 numbers)

MATRIX (2D):  A grid of numbers (rows Ã— columns)
  â”Œ 1  2  3 â”
  â”‚ 4  5  6 â”‚    Shape: (2, 3) = 2 rows Ã— 3 columns
  â””         â”˜

  In AI: A weight matrix, a batch of embeddings, attention scores

TENSOR (nD):  Generalization to any number of dimensions
  3D: A stack of matrices (e.g., batch of attention matrices)
  4D: Batch Ã— Channels Ã— Height Ã— Width (images)

  In AI: Everything in PyTorch is a tensor
```

```python
import torch

scalar = torch.tensor(5.0)           # 0D: shape ()
vector = torch.tensor([1, 2, 3])     # 1D: shape (3,)
matrix = torch.tensor([[1,2],[3,4]]) # 2D: shape (2, 2)
tensor = torch.randn(32, 128, 768)   # 3D: batch Ã— sequence Ã— embedding
```

### The Operations That Matter

#### 1. Dot Product (Most Important for GenAI!)

```
Dot product of two vectors:
  a = [1, 2, 3]
  b = [4, 5, 6]

  a Â· b = (1Ã—4) + (2Ã—5) + (3Ã—6) = 4 + 10 + 18 = 32

What it measures: SIMILARITY between two vectors.
  - Large positive â†’ vectors point same direction (similar)
  - Near zero      â†’ vectors are perpendicular (unrelated)
  - Large negative â†’ vectors point opposite (opposite meaning)

WHERE IN GenAI:
  âœ¦ Attention scores:  score = Q Â· Káµ€
  âœ¦ Cosine similarity: sim = (aÂ·b) / (||a|| Ã— ||b||)
  âœ¦ Embedding comparison in RAG
  âœ¦ Neuron computation: output = wÂ·x + b
```

#### 2. Matrix Multiplication

```
A (2Ã—3) Ã— B (3Ã—2) = C (2Ã—2)

  â”Œ 1  2  3 â”     â”Œ 7   8 â”     â”Œ 58   64 â”
  â”‚ 4  5  6 â”‚  Ã—  â”‚ 9  10 â”‚  =  â”‚ 139  154â”‚
  â””         â”˜     â”‚ 11 12 â”‚     â””          â”˜
                  â””       â”˜

  C[0,0] = (1Ã—7) + (2Ã—9) + (3Ã—11) = 7 + 18 + 33 = 58

RULE: Inner dimensions must match.
  (2Ã—3) Ã— (3Ã—2) â†’ works! Result: (2Ã—2)
  (2Ã—3) Ã— (4Ã—2) â†’ ERROR! 3 â‰  4

WHERE IN GenAI:
  âœ¦ Forward pass: output = WÂ·input + b (every layer!)
  âœ¦ Attention: QKáµ€ (query Ã— key transpose)
  âœ¦ Why GPUs are used: Matrix multiply parallelizes perfectly
```

```python
# Matrix multiply in PyTorch
A = torch.randn(2, 3)
B = torch.randn(3, 2)
C = A @ B            # @ = matrix multiply operator
# or: C = torch.matmul(A, B)
print(C.shape)  # torch.Size([2, 2])

# This is literally what every neural network layer does:
input = torch.randn(32, 768)      # 32 samples, 768 features
weight = torch.randn(768, 3072)   # Weight matrix
output = input @ weight            # (32, 768) Ã— (768, 3072) = (32, 3072)
```

#### 3. Transpose

```
Flip rows and columns:

  A = â”Œ 1  2  3 â”     Aáµ€ = â”Œ 1  4 â”
      â”‚ 4  5  6 â”‚          â”‚ 2  5 â”‚
      â””         â”˜          â”‚ 3  6 â”‚
                           â””     â”˜
  (2Ã—3) â†’ (3Ã—2)

WHERE IN GenAI:
  âœ¦ Attention: Káµ€ (transpose the Key matrix for dot product)
  âœ¦ Weight sharing / dimension alignment
```

#### 4. Cosine Similarity

```
Cosine similarity: measure angle between vectors (ignore magnitude)

  cos(Î¸) = (a Â· b) / (||a|| Ã— ||b||)

  ||a|| = norm = âˆš(aâ‚Â² + aâ‚‚Â² + ... + aâ‚™Â²)   â† length of vector

  Range: -1 (opposite) to 1 (identical)

WHERE IN GenAI:
  âœ¦ Comparing embeddings in vector databases
  âœ¦ Semantic similarity in RAG retrieval
  âœ¦ "How similar are these two texts?"
```

#### 5. Softmax (Vector â†’ Probability Distribution)

```
Softmax turns any vector of numbers into probabilities (sum to 1):

  logits = [2.0, 1.0, 0.1]
  softmax = [eË£â± / Î£eË£Ê²]

  eÂ²Â·â° = 7.39    â†’ 7.39 / (7.39 + 2.72 + 1.11) = 0.66
  eÂ¹Â·â° = 2.72    â†’ 2.72 / 11.22 = 0.24
  eâ°Â·Â¹ = 1.11    â†’ 1.11 / 11.22 = 0.10
                                              Sum = 1.00 âœ“

WHERE IN GenAI:
  âœ¦ Attention weights: softmax(QKáµ€/âˆšd) â€” THE equation
  âœ¦ Token prediction: LLM output layer â†’ softmax â†’ pick next token
  âœ¦ Classification: probability over classes
```

---

## â—† How It All Fits in a Transformer

```
"Hello" â†’ [Tokenize] â†’ token_id [15496]
           â†“
[Embedding Lookup]  â†’  vector [0.12, -0.45, ...] (768-dim)
                        â†‘ This is a VECTOR
           â†“
[Attention Layer]
  Q = input Ã— Wq      â† MATRIX MULTIPLY
  K = input Ã— Wk      â† MATRIX MULTIPLY
  V = input Ã— Wv      â† MATRIX MULTIPLY
  scores = Q Ã— Káµ€     â† MATRIX MULTIPLY + TRANSPOSE
  weights = softmax(scores / âˆšd)  â† SOFTMAX
  output = weights Ã— V â† MATRIX MULTIPLY
           â†“
[Feed-Forward]
  output = Wâ‚‚ Â· GELU(Wâ‚ Â· input + bâ‚) + bâ‚‚  â† MATRIX MULTIPLY Ã— 2
           â†“
[Repeat Ã— 100 layers]
           â†“
[Output] â†’ logits â†’ SOFTMAX â†’ probabilities â†’ next token
```

**That's it.** Transformers are matrix multiplications + softmax + non-linear activations stacked 100+ times.

---

## â—† Quick Reference

```
ESSENTIAL OPERATIONS (ranked by importance for GenAI):
  1. Dot product       â†’ Attention scores, similarity
  2. Matrix multiply   â†’ Every layer computation
  3. Transpose         â†’ Attention mechanism (Káµ€)
  4. Cosine similarity â†’ Embedding comparison
  5. Softmax           â†’ Probabilities (attention weights, output)
  6. Norms             â†’ Normalization, regularization

SHAPES TO KNOW:
  Embedding:    (batch_size, seq_len, d_model)     e.g., (32, 512, 768)
  Weight matrix: (d_in, d_out)                      e.g., (768, 3072)
  Attention:     (batch, heads, seq_len, seq_len)   e.g., (32, 12, 512, 512)

PYTORCH CHEAT SHEET:
  a @ b          â†’ matrix multiply
  a.T            â†’ transpose
  a.shape        â†’ dimensions
  torch.randn()  â†’ random tensor
  torch.sum()    â†’ sum elements
  F.softmax()    â†’ softmax
  F.cosine_similarity()  â†’ cosine sim
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Shape errors are 80% of debugging**: Always print `.shape` when things break. Most bugs are dimension mismatches.
- âš ï¸ **Dot product â‰  element-wise multiply**: `a * b` â‰  `a @ b`. Element-wise keeps the shape; dot product reduces dimensions.
- âš ï¸ **Matrix multiply is NOT commutative**: A Ã— B â‰  B Ã— A (usually). Order matters.
- âš ï¸ **You don't need eigenvalues for GenAI**: They matter for PCA/SVD but are rarely needed in day-to-day GenAI work.

---

## â—‹ Interview Angles

- **Q**: Why is the dot product central to the attention mechanism?
- **A**: Attention computes QÂ·Káµ€ where Q = query and K = key. The dot product measures how "related" each query is to each key â€” high dot product = high attention. This is then softmaxed into weights that determine how much each value V contributes to the output.

- **Q**: Why are GPUs used for deep learning?
- **A**: Neural networks are fundamentally matrix multiplications. GPUs have thousands of cores designed for parallel math operations. A CPU might do matrix multiply sequentially; a GPU does thousands of multiply-adds simultaneously.

---

## â˜… Connections

| Relationship | Topics                                                                                                                      |
| ------------ | --------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | High school math                                                                                                            |
| Leads to     | [Neural Networks](./neural-networks.md), [Transformers](../foundations/transformers.md), [Attention Mechanism](../foundations/attention-mechanism.md), [Embeddings](../foundations/embeddings.md) |
| Compare with | Calculus (for backprop), Statistics (for distributions)                                                                     |
| Cross-domain | Physics (vector spaces), Computer graphics (transformations)                                                                |

---

## â˜… Sources

- 3Blue1Brown "Essence of Linear Algebra" â€” https://youtube.com/playlist?list=PLZHQObOWTQDPD3MizzM2xVFitgF8hE_ab
- Ian Goodfellow, "Deep Learning" Chapter 2 (Linear Algebra)
- Khan Academy Linear Algebra â€” https://khanacademy.org/math/linear-algebra
- Jay Alammar, "A Visual Intro to NumPy and Data Representation"
