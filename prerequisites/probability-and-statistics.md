---
title: "Probability & Statistics for AI"
tags: [probability, statistics, bayes, distributions, loss-functions, sampling, genai-prerequisite]
type: concept
difficulty: beginner
status: published
parent: "[[../genai]]"
related: ["[[neural-networks]]", "[[deep-learning-fundamentals]]", "[[../llms/llms-overview]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-11
---

# Probability & Statistics for AI

> ✨ **Bit**: LLMs don't "think." They compute probability distributions over tokens and sample from them. "The capital of France is ___" → P("Paris") = 0.95, P("Lyon") = 0.03. That's literally all it does.

---

## ★ TL;DR

- **What**: The probability and statistics concepts that underpin how GenAI models learn, generate, and are evaluated
- **Why**: LLMs are probability machines. Understanding distributions, sampling, and loss functions = understanding how models generate text.
- **Key point**: Temperature, top-k, top-p? Those are sampling strategies from probability theory. Cross-entropy loss? That's information theory. You use this daily in GenAI.

---

## ★ Overview

### Definition

This document covers the specific probability and statistics concepts needed for GenAI — focused on what matters for understanding model training, text generation, and evaluation.

### Scope

GenAI-relevant probability only. Not a full statistics course. Covers: distributions, Bayes, loss functions, and sampling strategies.

### Prerequisites

- Basic math (addition, multiplication, exponents)

---

## ★ Deep Dive

### Probability Basics for GenAI

```
FUNDAMENTAL IDEA:
  P(next token = "Paris" | context = "The capital of France is")

  This is what EVERY language model computes:
  "Given what came before, what's the probability of each possible next word?"

  The model outputs a probability DISTRIBUTION over the entire vocabulary:

  Token         Probability
  "Paris"       0.92
  "Lyon"        0.03
  "the"         0.01
  "Berlin"      0.001
  ...           ...
  (50,000+ tokens, all probabilities sum to 1.0)
```

### Key Distributions

| Distribution        | Shape                             | Where in GenAI                                                    |
| ------------------- | --------------------------------- | ----------------------------------------------------------------- |
| **Uniform**         | All outcomes equally likely       | Random initialization of weights                                  |
| **Normal/Gaussian** | Bell curve (μ = mean, σ = std)    | Weight initialization, diffusion (noise is Gaussian!), embeddings |
| **Categorical**     | Probability over discrete options | LLM output: probability over vocab tokens                         |
| **Bernoulli**       | Binary (yes/no)                   | Dropout (randomly disable neurons)                                |

```
Normal (Gaussian) Distribution:

       ┌────────────────┐
       │    ████████    │
       │  ████████████  │         μ = mean (center)
       │████████████████│         σ = std deviation (spread)
       │████████████████│
  ─────┼────────────────┼─────
      -3σ  -2σ  -σ   μ   σ   2σ  3σ

  68% of data within 1σ of mean
  95% within 2σ
  99.7% within 3σ

GenAI Use: Diffusion models ADD Gaussian noise to images during training
           and learn to REMOVE it during generation.
```

### Bayes' Theorem

```
P(A|B) = P(B|A) × P(A) / P(B)

In plain English:
  "Probability of A given B" =
    "How likely B is if A is true" × "How likely A is" ÷ "How likely B is overall"

GenAI connection:
  The whole language model can be viewed as:
  P(next token | all previous tokens) — conditional probability

  Bayesian updating is conceptually how we think about
  adding new information (RAG context) to change model predictions.
```

### Loss Functions (How Models Learn)

```
Loss = "How wrong is the model?" (lower = better)

TRAINING GOAL: Minimize the loss function by adjusting weights.
```

| Loss Function            | Formula Intuition                   | Used For                                                 |
| ------------------------ | ----------------------------------- | -------------------------------------------------------- |
| **Cross-Entropy**        | -Σ y·log(ŷ)                         | LLM pre-training (next-token prediction), classification |
| **MSE**                  | Σ(y - ŷ)² / n                       | Diffusion (predict noise), regression                    |
| **KL Divergence**        | How different are two distributions | VAEs, RLHF (keep model close to original)                |
| **Binary Cross-Entropy** | Cross-entropy for yes/no            | Binary classification, DPO                               |

```
CROSS-ENTROPY EXAMPLE (LLM training):

  True next token: "Paris" (one-hot: [0, 0, 1, 0, ...])
  Model prediction: [0.05, 0.02, 0.85, 0.08, ...]

  Loss = -log(0.85) = 0.16  ← Small loss! Model is mostly right.

  If model predicted P("Paris") = 0.01:
  Loss = -log(0.01) = 4.6   ← Large loss! Model is very wrong.

  Training pushes: "Increase P(correct token), decrease P(wrong tokens)"
```

### Sampling Strategies (How LLMs Generate Text)

```
After computing P(next token), how do we PICK the actual token?

GREEDY: Always pick the highest probability token.
  P: [Paris=0.92, Lyon=0.03, ...] → Always outputs "Paris"
  ✅ Deterministic, consistent
  ❌ Boring, repetitive, no creativity

TEMPERATURE SAMPLING:
  Adjust probabilities before sampling:
  P_adjusted = softmax(logits / temperature)

  temperature = 0.0: → Greedy (always pick top)
  temperature = 0.3: → Mostly top tokens, slight variety
  temperature = 0.7: → Balanced creativity
  temperature = 1.0: → Original distribution
  temperature = 2.0: → Very random, less coherent

  HOW IT WORKS:
  Low temp → Sharpens distribution (top token dominates)
  High temp → Flattens distribution (all tokens more equal)
```

| Strategy            | How It Works                                      | When to Use                       |
| ------------------- | ------------------------------------------------- | --------------------------------- |
| **Greedy**          | Pick highest P every time                         | Factual/deterministic tasks       |
| **Temperature**     | Scale logits before softmax                       | General creativity control        |
| **Top-K**           | Only consider top K tokens                        | Prevent very rare token selection |
| **Top-P (Nucleus)** | Consider smallest set of tokens whose P sums to P | Adaptive — good default           |
| **Top-K + Top-P**   | Apply both filters                                | Production default for most APIs  |

```python
# OpenAI API example — these ARE sampling strategies
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[{"role": "user", "content": "Write a poem"}],
    temperature=0.7,    # Creativity level
    top_p=0.9,          # Nucleus sampling (consider top 90% probability mass)
    max_tokens=200
)
```

---

## ◆ Quick Reference

```
SAMPLING PARAMETERS:
  temperature = 0    → Deterministic (data extraction, coding)
  temperature = 0.3  → Low creativity (summarization, Q&A)
  temperature = 0.7  → Balanced (general chat, writing)
  temperature = 1.0  → Full creativity (brainstorming)
  top_p = 0.9        → Good default (ignore bottom 10% probability)
  top_k = 50         → Only consider top 50 tokens

LOSS FUNCTIONS:
  LLM training    → Cross-entropy
  Diffusion       → MSE (predict noise)
  Classification  → Cross-entropy
  Regression      → MSE
  RLHF           → KL divergence + reward

KEY DISTRIBUTIONS:
  Gaussian noise → Diffusion models
  Categorical    → Token generation
  Uniform        → Weight initialization
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Temperature 0 ≠ deterministic in all APIs**: Some implementations still have slight randomness at temperature 0. Use `seed` parameter for true determinism.
- ⚠️ **Cross-entropy loss can be misleading**: Low loss ≠ good model. A model with low loss might still hallucinate or be unsafe.
- ⚠️ **Top-P and Top-K stack**: They're applied together, not alternatives. Top-K filters first, then Top-P within the remaining.
- ⚠️ **"Probability" in LLMs isn't belief**: The model's P("Paris") = 0.92 doesn't mean it "believes" Paris is the answer. It means the pattern "France is [Paris]" is statistically dominant in training data.

---

## ○ Interview Angles

- **Q**: What is temperature in LLM generation?
- **A**: Temperature scales the logits before softmax. Low temperature (→0) makes the distribution sharper (confident picks), high temperature makes it flatter (random picks). Mathematically: P = softmax(logits / T).

- **Q**: What loss function do LLMs use and why?
- **A**: Cross-entropy loss. It measures how different the model's predicted probability distribution is from the true distribution (where the correct next token has probability 1). Minimizing cross-entropy pushes the model to assign high probability to the correct token.

---

## ★ Connections

| Relationship | Topics                                                                         |
| ------------ | ------------------------------------------------------------------------------ |
| Builds on    | Basic math                                                                     |
| Leads to     | [Neural Networks](./neural-networks.md), [Deep Learning Fundamentals](./deep-learning-fundamentals.md), [Llms Overview](../llms/llms-overview.md) |
| Compare with | Deterministic programming (no randomness), Rule-based systems                  |
| Cross-domain | Information theory (entropy), Bayesian statistics, Signal processing           |

---

## ★ Sources

- Ian Goodfellow, "Deep Learning" Chapter 3 (Probability and Information Theory)
- OpenAI API Parameter Guide — https://platform.openai.com/docs/api-reference
- StatQuest "Probability" series — https://youtube.com/statquest
