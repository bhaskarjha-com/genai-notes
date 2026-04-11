---
title: "Attention Mechanism"
tags: [attention, self-attention, multi-head, transformers, genai-foundations]
type: concept
difficulty: intermediate
status: published
parent: "[[transformers]]"
related: ["[[transformers]]", "[[../../llms/llms-overview]]"]
source: "Attention Is All You Need (Vaswani et al., 2017)"
created: 2026-03-18
updated: 2026-03-18
---

# Attention Mechanism

> ✨ **Bit**: Attention in AI is like attention in humans — you don't read every word equally; you focus on what matters for understanding the current thing.

---

## ★ TL;DR

- **What**: A mechanism that lets each element in a sequence dynamically focus on relevant parts of the entire input
- **Why**: Solves the bottleneck of fixed-size representations in sequence models. THE key innovation behind Transformers
- **Key point**: Query-Key-Value triplet: "What am I looking for?" matches against "What do I contain?" to retrieve "What should I return?"

---

## ★ Overview

### Definition

**Attention** is a mechanism that computes a weighted combination of values (V), where the weights are determined by the compatibility between a query (Q) and keys (K). It allows a model to "focus" on different parts of the input when producing each part of the output.

### Scope

Covers: Self-attention, cross-attention, multi-head attention, and modern variants (GQA, Flash Attention, MQA). For the full Transformer architecture, see [[transformers]].

### Significance

- Before attention: Encoder compressed entire sequence into ONE fixed vector → information bottleneck
- After attention: Every output position can directly access any input position → no bottleneck

### Prerequisites

- [[../prerequisites/linear-algebra-for-ai]] — matrix multiplication, dot products
- [[../prerequisites/neural-networks]] — basic concepts

---

## ★ Deep Dive

### The QKV Intuition

Think of attention as a **search engine**:

```
You have a QUERY    → "What information do I need?"
Matched against KEYS  → "What does each position contain?"  
Retrieves VALUES      → "Here's the actual content"

Example: Parsing "The cat sat because it was tired"
When processing "it":
  Query("it") · Key("cat") = HIGH score → "it" refers to "cat"
  Query("it") · Key("sat") = LOW score  → "it" doesn't refer to "sat"
  
Result: "it" attends strongly to "cat" and gets its information
```

### Step-by-Step Computation

```
Input: X (sequence of token embeddings, shape: [seq_len, d_model])

Step 1: Project into Q, K, V
  Q = X · W_Q    (shape: [seq_len, d_k])
  K = X · W_K    (shape: [seq_len, d_k])  
  V = X · W_V    (shape: [seq_len, d_v])

Step 2: Compute attention scores
  scores = Q · K^T          (shape: [seq_len, seq_len])

Step 3: Scale
  scores = scores / √d_k    (prevent exploding gradients)

Step 4: Softmax (normalize to probabilities)
  weights = softmax(scores)  (each row sums to 1)

Step 5: Weighted sum of values
  output = weights · V       (shape: [seq_len, d_v])
```

### Visual Example

```
             "The"  "cat"  "sat"  "on"  "it"
  "The"    [ 0.6    0.2    0.1    0.05   0.05 ]
  "cat"    [ 0.1    0.7    0.1    0.05   0.05 ]
  "sat"    [ 0.05   0.3    0.5    0.1    0.05 ]
  "on"     [ 0.05   0.1    0.2    0.6    0.05 ]
  "it"     [ 0.05   0.6    0.1    0.05   0.2  ]  ← "it" attends most to "cat"

  ^ Each row shows WHERE that token is "looking"
  ^ Values sum to 1.0 (softmax)
```

### Multi-Head Attention

Instead of one attention, compute `h` parallel attentions with different learned projections:

```
head_i = Attention(X·W_Q_i, X·W_K_i, X·W_V_i)

MultiHead(X) = Concat(head_1, ..., head_h) · W_O
```

**Why multiple heads?**
- Head 1 might learn: "who is the subject?"
- Head 2 might learn: "what is the verb?"
- Head 3 might learn: "positional proximity"
- Together: richer representation than any single attention

### Types of Attention

| Type                | Q from        | K,V from               | Use Case                                     |
| ------------------- | ------------- | ---------------------- | -------------------------------------------- |
| **Self-Attention**  | Same sequence | Same sequence          | Token-to-token within input                  |
| **Cross-Attention** | Decoder       | Encoder output         | Decoder attending to encoder (translation)   |
| **Causal/Masked**   | Same sequence | Same sequence (masked) | Autoregressive generation (can't see future) |

### Causal Masking (Critical for LLMs)

In generation, token at position `i` should only attend to positions `≤ i` (can't see the future):

```
Mask:
  [1, -∞, -∞, -∞]     "The" can only see "The"
  [1,  1, -∞, -∞]     "cat" can see "The", "cat"  
  [1,  1,  1, -∞]     "sat" can see "The", "cat", "sat"
  [1,  1,  1,  1]     "on" can see everything before it

Applied BEFORE softmax: e^(-∞) = 0, so masked positions get zero weight
```

### Modern Variants

| Variant                 | What It Does                                                        | Why                                            |
| ----------------------- | ------------------------------------------------------------------- | ---------------------------------------------- |
| **MHA** (Multi-Head)    | Full Q,K,V per head                                                 | Original, most expressive                      |
| **MQA** (Multi-Query)   | Shared K,V across heads, unique Q                                   | 10x faster inference, slight quality drop      |
| **GQA** (Grouped Query) | Groups of heads share K,V                                           | Best of both: fast + quality. Used by LLaMA 2+ |
| **Flash Attention**     | Tiling + recomputation to avoid materializing full attention matrix | 2-4x faster, way less memory                   |
| **RoPE**                | Rotary Position Embeddings baked into Q,K                           | Better extrapolation to unseen lengths         |
| **Sliding Window**      | Only attend to nearby tokens within a window                        | Handles very long sequences (Mistral)          |

---

## ◆ Formulas & Equations

| Name               | Formula                                                                           | Variables                            | Use                |
| ------------------ | --------------------------------------------------------------------------------- | ------------------------------------ | ------------------ |
| Scaled Dot-Product | $$\text{Attention}(Q,K,V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$ | Q,K,V matrices ; d_k = key dimension | Core attention     |
| Multi-Head         | $$\text{MultiHead}(Q,K,V) = \text{Concat}(\text{head}_1,...,\text{head}_h)W^O$$   | h=num heads, W^O=output projection   | Parallel attention |
| Complexity         | $$O(n^2 \cdot d)$$                                                                | n=sequence length, d=dimension       | Time & memory cost |

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                                  | ❌ Limitations                                        |
| ------------------------------------------------------------ | ---------------------------------------------------- |
| Captures long-range dependencies                             | O(n²) — quadratic with sequence length               |
| Fully parallelizable                                         | Large memory footprint for long sequences            |
| Interpretable (attention weights show what model "looks at") | Attention maps don't always reflect causal reasoning |
| Works across modalities (text, image, audio)                 | Still needs positional encoding (no inherent order)  |

---

## ◆ Quick Reference

```
Attention(Q,K,V) = softmax(QKᵀ/√d_k) · V

Multi-Head: Run h parallel attentions, concat, project

Causal mask: Upper triangle = -∞ (can't see future)

Complexity: O(n²·d) per layer

Modern defaults:
  - GQA (not full MHA) for efficiency
  - Flash Attention for memory
  - RoPE for positions
  - Sliding window for very long contexts
```

---

## ○ Interview Angles

- **Q**: Why divide by √d_k in attention?
- **A**: Without it, for large d_k, dot products become huge → softmax saturates → near-zero gradients. Scaling keeps variance at ~1.

- **Q**: What's the difference between MHA, MQA, and GQA?
- **A**: MHA: separate K,V per head (most expressive, slowest). MQA: one shared K,V (fastest, some quality loss). GQA: groups of heads share K,V (good balance). LLaMA 2+ uses GQA.

- **Q**: How does Flash Attention improve efficiency without changing the math?
- **A**: It tiles the computation to fit in SRAM (fast cache), avoiding materialization of the full n×n attention matrix in slow HBM (GPU memory). Same result, ~2-4x faster.

---

## ★ Connections

| Relationship | Topics                                                                           |
| ------------ | -------------------------------------------------------------------------------- |
| Builds on    | [[../prerequisites/linear-algebra-for-ai]], [[../prerequisites/neural-networks]] |
| Leads to     | [[transformers]], [[../../llms/llms-overview]]                                   |
| Compare with | Recurrence (RNNs), Convolution (CNNs)                                            |
| Cross-domain | Vision Transformers (ViT), Graph Attention Networks                              |

---

## ★ Sources

- Vaswani et al., "Attention Is All You Need" (2017) — https://arxiv.org/abs/1706.03762
- Bahdanau et al., "Neural Machine Translation by Jointly Learning to Align and Translate" (2014) — Original attention paper
- Jay Alammar, "The Illustrated Transformer" — https://jalammar.github.io/illustrated-transformer/
- Tri Dao, "Flash Attention" (2022) — https://arxiv.org/abs/2205.14135
