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

> âœ¨ **Bit**: LLMs don't "think." They compute probability distributions over tokens and sample from them. "The capital of France is ___" â†’ P("Paris") = 0.95, P("Lyon") = 0.03. That's literally all it does.

---

## â˜… TL;DR

- **What**: The probability and statistics concepts that underpin how GenAI models learn, generate, and are evaluated
- **Why**: LLMs are probability machines. Understanding distributions, sampling, and loss functions = understanding how models generate text.
- **Key point**: Temperature, top-k, top-p? Those are sampling strategies from probability theory. Cross-entropy loss? That's information theory. You use this daily in GenAI.

---

## â˜… Overview

### Definition

This document covers the specific probability and statistics concepts needed for GenAI â€” focused on what matters for understanding model training, text generation, and evaluation.

### Scope

GenAI-relevant probability only. Not a full statistics course. Covers: distributions, Bayes, loss functions, and sampling strategies.

### Prerequisites

- Basic math (addition, multiplication, exponents)

---

## â˜… Deep Dive

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
| **Normal/Gaussian** | Bell curve (Î¼ = mean, Ïƒ = std)    | Weight initialization, diffusion (noise is Gaussian!), embeddings |
| **Categorical**     | Probability over discrete options | LLM output: probability over vocab tokens                         |
| **Bernoulli**       | Binary (yes/no)                   | Dropout (randomly disable neurons)                                |

```
Normal (Gaussian) Distribution:

       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
       â”‚    â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ    â”‚
       â”‚  â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆ  â”‚         Î¼ = mean (center)
       â”‚â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ”‚         Ïƒ = std deviation (spread)
       â”‚â–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ–ˆâ”‚
  â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€
      -3Ïƒ  -2Ïƒ  -Ïƒ   Î¼   Ïƒ   2Ïƒ  3Ïƒ

  68% of data within 1Ïƒ of mean
  95% within 2Ïƒ
  99.7% within 3Ïƒ

GenAI Use: Diffusion models ADD Gaussian noise to images during training
           and learn to REMOVE it during generation.
```

### Bayes' Theorem

```
P(A|B) = P(B|A) Ã— P(A) / P(B)

In plain English:
  "Probability of A given B" =
    "How likely B is if A is true" Ã— "How likely A is" Ã· "How likely B is overall"

GenAI connection:
  The whole language model can be viewed as:
  P(next token | all previous tokens) â€” conditional probability

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
| **Cross-Entropy**        | -Î£ yÂ·log(Å·)                         | LLM pre-training (next-token prediction), classification |
| **MSE**                  | Î£(y - Å·)Â² / n                       | Diffusion (predict noise), regression                    |
| **KL Divergence**        | How different are two distributions | VAEs, RLHF (keep model close to original)                |
| **Binary Cross-Entropy** | Cross-entropy for yes/no            | Binary classification, DPO                               |

```
CROSS-ENTROPY EXAMPLE (LLM training):

  True next token: "Paris" (one-hot: [0, 0, 1, 0, ...])
  Model prediction: [0.05, 0.02, 0.85, 0.08, ...]

  Loss = -log(0.85) = 0.16  â† Small loss! Model is mostly right.

  If model predicted P("Paris") = 0.01:
  Loss = -log(0.01) = 4.6   â† Large loss! Model is very wrong.

  Training pushes: "Increase P(correct token), decrease P(wrong tokens)"
```

### Sampling Strategies (How LLMs Generate Text)

```
After computing P(next token), how do we PICK the actual token?

GREEDY: Always pick the highest probability token.
  P: [Paris=0.92, Lyon=0.03, ...] â†’ Always outputs "Paris"
  âœ… Deterministic, consistent
  âŒ Boring, repetitive, no creativity

TEMPERATURE SAMPLING:
  Adjust probabilities before sampling:
  P_adjusted = softmax(logits / temperature)

  temperature = 0.0: â†’ Greedy (always pick top)
  temperature = 0.3: â†’ Mostly top tokens, slight variety
  temperature = 0.7: â†’ Balanced creativity
  temperature = 1.0: â†’ Original distribution
  temperature = 2.0: â†’ Very random, less coherent

  HOW IT WORKS:
  Low temp â†’ Sharpens distribution (top token dominates)
  High temp â†’ Flattens distribution (all tokens more equal)
```

| Strategy            | How It Works                                      | When to Use                       |
| ------------------- | ------------------------------------------------- | --------------------------------- |
| **Greedy**          | Pick highest P every time                         | Factual/deterministic tasks       |
| **Temperature**     | Scale logits before softmax                       | General creativity control        |
| **Top-K**           | Only consider top K tokens                        | Prevent very rare token selection |
| **Top-P (Nucleus)** | Consider smallest set of tokens whose P sums to P | Adaptive â€” good default           |
| **Top-K + Top-P**   | Apply both filters                                | Production default for most APIs  |

```python
# OpenAI API example â€” these ARE sampling strategies
response = client.chat.completions.create(
    model="gpt-5.4",
    messages=[{"role": "user", "content": "Write a poem"}],
    temperature=0.7,    # Creativity level
    top_p=0.9,          # Nucleus sampling (consider top 90% probability mass)
    max_tokens=200
)
```

---

## â—† Quick Reference

```
SAMPLING PARAMETERS:
  temperature = 0    â†’ Deterministic (data extraction, coding)
  temperature = 0.3  â†’ Low creativity (summarization, Q&A)
  temperature = 0.7  â†’ Balanced (general chat, writing)
  temperature = 1.0  â†’ Full creativity (brainstorming)
  top_p = 0.9        â†’ Good default (ignore bottom 10% probability)
  top_k = 50         â†’ Only consider top 50 tokens

LOSS FUNCTIONS:
  LLM training    â†’ Cross-entropy
  Diffusion       â†’ MSE (predict noise)
  Classification  â†’ Cross-entropy
  Regression      â†’ MSE
  RLHF           â†’ KL divergence + reward

KEY DISTRIBUTIONS:
  Gaussian noise â†’ Diffusion models
  Categorical    â†’ Token generation
  Uniform        â†’ Weight initialization
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Temperature 0 â‰  deterministic in all APIs**: Some implementations still have slight randomness at temperature 0. Use `seed` parameter for true determinism.
- âš ï¸ **Cross-entropy loss can be misleading**: Low loss â‰  good model. A model with low loss might still hallucinate or be unsafe.
- âš ï¸ **Top-P and Top-K stack**: They're applied together, not alternatives. Top-K filters first, then Top-P within the remaining.
- âš ï¸ **"Probability" in LLMs isn't belief**: The model's P("Paris") = 0.92 doesn't mean it "believes" Paris is the answer. It means the pattern "France is [Paris]" is statistically dominant in training data.

---

## â—‹ Interview Angles

- **Q**: What is temperature in LLM generation?
- **A**: Temperature scales the logits before softmax. Low temperature (â†’0) makes the distribution sharper (confident picks), high temperature makes it flatter (random picks). Mathematically: P = softmax(logits / T).

- **Q**: What loss function do LLMs use and why?
- **A**: Cross-entropy loss. It measures how different the model's predicted probability distribution is from the true distribution (where the correct next token has probability 1). Minimizing cross-entropy pushes the model to assign high probability to the correct token.

---

## â˜… Connections

| Relationship | Topics                                                                         |
| ------------ | ------------------------------------------------------------------------------ |
| Builds on    | Basic math                                                                     |
| Leads to     | [Neural Networks](./neural-networks.md), [Deep Learning Fundamentals](./deep-learning-fundamentals.md), [Llms Overview](../llms/llms-overview.md) |
| Compare with | Deterministic programming (no randomness), Rule-based systems                  |
| Cross-domain | Information theory (entropy), Bayesian statistics, Signal processing           |

---

## â˜… Sources

- Ian Goodfellow, "Deep Learning" Chapter 3 (Probability and Information Theory)
- OpenAI API Parameter Guide â€” https://platform.openai.com/docs/api-reference
- StatQuest "Probability" series â€” https://youtube.com/statquest
