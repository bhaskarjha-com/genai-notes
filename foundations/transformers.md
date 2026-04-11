---
title: "Transformers"
tags: [transformers, architecture, deep-learning, attention, genai-foundations]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[attention-mechanism]]", "[[../../llms/llms-overview]]"]
source: "Attention Is All You Need (Vaswani et al., 2017)"
created: 2026-03-18
updated: 2026-03-18
---

# Transformers

> ✨ **Bit**: The paper was titled "Attention Is All You Need" — turns out, attention + ungodly amounts of compute + internet-scale data is what you actually need.

---

## ★ TL;DR

- **What**: A neural network architecture based on self-attention that processes entire sequences in parallel
- **Why**: Replaced RNNs/LSTMs. Foundation of ALL modern LLMs and most GenAI models
- **Key point**: Parallelism + attention = trains faster and captures long-range dependencies better than anything before it

---

## ★ Overview

### Definition

The **Transformer** is a deep learning architecture introduced in 2017 by Vaswani et al. It uses a mechanism called **self-attention** (see [[attention-mechanism]]) to process input sequences in parallel rather than sequentially, making it dramatically faster to train and better at capturing relationships between distant elements in a sequence.

### Scope

This document covers the Transformer architecture itself. For attention mechanism deep dive, see [[attention-mechanism]]. For specific models built on Transformers, see [[../../llms/llms-overview]].

### Significance

- **Before Transformers**: RNNs/LSTMs processed sequences one step at a time → slow, couldn't handle long sequences
- **After Transformers**: Parallel processing + attention → scalable to billions of parameters
- **Impact**: GPT, BERT, T5, LLaMA, Gemini, Claude — ALL are Transformer variants.

### Prerequisites

- [[../prerequisites/neural-networks]] — basic neural network concepts
- [[embeddings]] — vector representations

---

## ★ Deep Dive

### The Original Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    TRANSFORMER ARCHITECTURE                  │
│                                                              │
│  ┌──────────────────┐          ┌──────────────────┐         │
│  │     ENCODER       │          │     DECODER       │        │
│  │  (understands)    │          │   (generates)     │        │
│  │                   │          │                   │        │
│  │ ┌───────────────┐ │    ┌──→ │ ┌───────────────┐ │        │
│  │ │ Multi-Head    │ │    │    │ │ Masked        │ │        │
│  │ │ Self-Attention│ │    │    │ │ Self-Attention│ │        │
│  │ └───────┬───────┘ │    │    │ └───────┬───────┘ │        │
│  │         ↓         │    │    │         ↓         │        │
│  │ ┌───────────────┐ │    │    │ ┌───────────────┐ │        │
│  │ │ Add & Norm    │ │    │    │ │ Cross-        │ │        │
│  │ └───────┬───────┘ │    │    │ │ Attention     │ │        │
│  │         ↓         │    │    │ │ (to encoder)  │ │        │
│  │ ┌───────────────┐ │    │    │ └───────┬───────┘ │        │
│  │ │ Feed-Forward  │ │    │    │         ↓         │        │
│  │ │ Network       │ │────┘    │ ┌───────────────┐ │        │
│  │ └───────┬───────┘ │         │ │ Feed-Forward  │ │        │
│  │         ↓         │         │ │ Network       │ │        │
│  │ ┌───────────────┐ │         │ └───────┬───────┘ │        │
│  │ │ Add & Norm    │ │         │         ↓         │        │
│  │ └───────────────┘ │         │    Output Probs   │        │
│  │                   │         │                   │        │
│  │   × N layers      │         │   × N layers      │        │
│  └──────────────────┘          └──────────────────┘         │
│                                                              │
│  Input: Token Embeddings + Positional Encoding               │
└─────────────────────────────────────────────────────────────┘
```

### Key Components Explained

#### 1. Input Embeddings + Positional Encoding

Tokens (words/subwords) are converted to dense vectors. Since Transformers process all tokens in parallel (no sequential order), **positional encoding** is added to inject position information.

```
Input = Token_Embedding(x) + Positional_Encoding(position)
```

Original paper uses sinusoidal encoding. Modern models often use learned positional embeddings or RoPE (Rotary Position Embeddings).

#### 2. Self-Attention (The Core Innovation)

Each token looks at ALL other tokens to decide what's important. See [[attention-mechanism]] for full deep dive.

**Simplified intuition**: For the sentence "The cat sat on the mat because **it** was tired" — self-attention lets "it" attend strongly to "cat" to understand the reference.

#### 3. Multi-Head Attention

Instead of one attention computation, run multiple in parallel (multiple "heads"). Each head can learn different relationship types:
- Head 1 might learn syntactic relationships
- Head 2 might learn semantic relationships
- Head 3 might learn positional relationships

#### 4. Feed-Forward Network (FFN)

After attention, each position passes through the same 2-layer network independently:

```
FFN(x) = ReLU(x·W₁ + b₁)·W₂ + b₂
```

This is where the model stores "knowledge" — factual information learned during training. The FFN acts as a key-value memory.

#### 5. Residual Connections + Layer Norm

Every sub-layer has a residual connection (skip connection) and layer normalization:

```
output = LayerNorm(x + SubLayer(x))
```

This prevents vanishing gradients and enables training very deep networks (100+ layers).

### Encoder vs Decoder vs Both

| Variant             | Architecture           | Models                         | Use Case                                       |
| ------------------- | ---------------------- | ------------------------------ | ---------------------------------------------- |
| **Encoder-only**    | Just the encoder stack | BERT, RoBERTa                  | Understanding: classification, NER, embeddings |
| **Decoder-only**    | Just the decoder stack | GPT, LLaMA, Claude             | Generation: text completion, chat              |
| **Encoder-Decoder** | Both stacks            | T5, BART, original Transformer | Seq2seq: translation, summarization            |

**Modern trend**: Decoder-only dominates for GenAI because generation IS the task.

### Modern Improvements Over Original

| Improvement         | What Changed                                        | Used In                           |
| ------------------- | --------------------------------------------------- | --------------------------------- |
| **RoPE**            | Rotary position embeddings (better than sinusoidal) | LLaMA, Qwen, Mistral              |
| **GQA**             | Grouped Query Attention (efficiency)                | LLaMA 2+, Gemini                  |
| **MoE**             | Mixture of Experts (sparse activation)              | LLaMA 4, Mixtral, GPT-4 (rumored) |
| **SwiGLU**          | Better activation function in FFN                   | LLaMA, PaLM                       |
| **RMSNorm**         | Simpler normalization (pre-norm)                    | LLaMA, Gemma                      |
| **Flash Attention** | Memory-efficient attention computation              | Nearly all modern models          |
| **KV Cache**        | Cache key/value for faster inference                | All autoregressive models         |

---

## ◆ Terminology

| Term                | Meaning                                                                     |
| ------------------- | --------------------------------------------------------------------------- |
| **Token**           | Smallest unit of text the model processes (word piece, ~4 chars in English) |
| **Embedding**       | Dense vector representation of a token                                      |
| **Attention Score** | How much one token should "pay attention to" another                        |
| **Head**            | One parallel attention computation                                          |
| **Layer**           | One complete block (attention + FFN + norms)                                |
| **Context Window**  | Maximum number of tokens the model can process at once                      |
| **KV Cache**        | Stored key-value pairs from previous tokens to speed up generation          |
| **MoE**             | Mixture of Experts — only activates a subset of parameters per token        |

---

## ◆ Formulas & Equations

| Name                | Formula                                                                           | Variables                                          | Use                                 |
| ------------------- | --------------------------------------------------------------------------------- | -------------------------------------------------- | ----------------------------------- |
| Attention           | $$\text{Attention}(Q,K,V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$ | Q=queries, K=keys, V=values, d_k=key dimension     | Core attention computation          |
| Positional Encoding | $$PE_{(pos,2i)} = \sin(pos/10000^{2i/d})$$                                        | pos=position, i=dimension index, d=model dimension | Inject position info                |
| FFN                 | $$FFN(x) = \text{ReLU}(xW_1 + b_1)W_2 + b_2$$                                     | W₁, W₂=weight matrices                             | Process each position independently |

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                    | ❌ Limitations                                         |
| ---------------------------------------------- | ----------------------------------------------------- |
| Parallelizable (unlike RNNs) → fast training   | Quadratic memory/compute with sequence length (O(n²)) |
| Captures long-range dependencies via attention | Fixed context window (though growing: 1M-10M tokens)  |
| Scales predictably with more data/compute      | Massive compute requirements for training             |
| Transfer learning works incredibly well        | Positional encoding schemes still imperfect           |
| Architecture is simple and modular             | No inherent understanding of time/causality           |

---

## ◆ Quick Reference

```
Transformer Block:
  Input → [Multi-Head Attention] → Add & Norm → [FFN] → Add & Norm → Output

Key Dimensions (GPT-3 175B example):
  - Layers: 96
  - Heads: 96  
  - d_model: 12288
  - d_ff: 49152 (4x d_model)
  - Context: 2048 tokens

Modern Scaling (LLaMA 4 Behemoth):
  - Parameters: 2T+ (but MoE, so ~288B active)
  - Context: 10M tokens (Scout variant)
```

---

## ○ Interview Angles

- **Q**: Why do Transformers use scaled dot-product attention (divide by √d_k)?
- **A**: Without scaling, dot products grow large with high dimensions, pushing softmax into regions with tiny gradients. Dividing by √d_k keeps gradients healthy.

- **Q**: What's the computational complexity of self-attention?
- **A**: O(n²·d) where n is sequence length and d is dimension. This quadratic scaling with n is the main bottleneck for long sequences.

- **Q**: Why decoder-only for generation instead of encoder-decoder?
- **A**: Simpler architecture, easier to scale, and with enough data the decoder learns to "encode" implicitly. Also, causal masking naturally fits left-to-right generation.

---

## ★ Connections

| Relationship | Topics                                                                        |
| ------------ | ----------------------------------------------------------------------------- |
| Builds on    | [[../prerequisites/neural-networks]], [[embeddings]], [[attention-mechanism]] |
| Leads to     | [[../../llms/llms-overview]], [[../../image-generation/diffusion-models]]     |
| Compare with | RNNs (sequential), LSTMs (gated sequential), CNNs (local patterns)            |
| Cross-domain | Graph attention networks (GNNs), Vision Transformers (ViT)                    |

---

## ★ Sources

- Vaswani et al., "Attention Is All You Need" (2017) — https://arxiv.org/abs/1706.03762
- "The Illustrated Transformer" by Jay Alammar — https://jalammar.github.io/illustrated-transformer/
- Andrej Karpathy, "Let's build GPT from scratch" — YouTube lecture
- "Formal Algorithms for Transformers" (Phuong & Hutter, 2022)
