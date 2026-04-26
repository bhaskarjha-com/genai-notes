---
title: "Scaling Laws & Pre-training"
aliases: ["Scaling Laws", "Chinchilla", "Pretraining"]
tags: [scaling-laws, pre-training, chinchilla, compute, training, data-mix, genai]
type: concept
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["transformers.md", "../llms/llms-overview.md", "modern-architectures.md"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Scaling Laws & Pre-training

> ✨ **Bit**: GPT-5.4 cost hundreds of millions of dollars to train. Not because the algorithm is complex â€” it's literally next-token prediction â€” but because you need ~25,000 GPUs running for months on trillions of tokens. The secret of LLMs is embarrassingly simple: scale.

---

## ★ TL;DR

- **What**: The process of training an LLM from scratch on internet-scale data, and the mathematical laws predicting how performance improves with more compute, data, and parameters
- **Why**: Understanding pre-training explains WHY bigger models are better, HOW training costs scale, and WHEN to stop training â€” critical for anyone building or evaluating LLMs
- **Key point**: Chinchilla showed training a SMALLER model on MORE data beats a bigger model on less data. This insight reshaped the entire industry.

---

## ★ Overview

### Definition

**Scaling laws** describe how model performance changes as compute, data, and parameter count increase. **Pre-training** is the large-scale learning phase where a model absorbs general patterns before later alignment or specialization.

### Scope

This note focuses on the economics, mechanics, and trade-offs of pre-training at scale. For the distributed systems layer behind these runs, see [Distributed Training for Large Models](../research-frontiers/distributed-training.md).

### Significance

- Scaling behavior explains why frontier labs invest so heavily in data, compute, and optimization.
- Pre-training remains the foundation beneath later techniques such as fine-tuning, RL alignment, and distillation.

---

## ★ Deep Dive

### The Pre-training Pipeline

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚         HOW AN LLM IS ACTUALLY TRAINED                â”‚
â”‚                                                      â”‚
â”‚  1. DATA COLLECTION                                  â”‚
â”‚     Crawl the internet: CommonCrawl, Wikipedia,      â”‚
â”‚     books, code (GitHub), research papers, forums    â”‚
â”‚     Scale: 10-15 TRILLION tokens typical (2025-2026) â”‚
â”‚                                                      â”‚
â”‚  2. DATA CLEANING & FILTERING                        â”‚
â”‚     Deduplication (exact + fuzzy matching)            â”‚
â”‚     Quality filtering (classifier-based)             â”‚
â”‚     Toxicity/PII removal                             â”‚
â”‚     Language identification and balancing             â”‚
â”‚     Cost: Months of engineering, underrated          â”‚
â”‚                                                      â”‚
â”‚  3. TOKENIZATION                                     â”‚
â”‚     BPE tokenizer trained on the data                â”‚
â”‚     Vocabulary: 32K-256K tokens                      â”‚
â”‚     See: ../foundations/tokenization.md               â”‚
â”‚                                                      â”‚
â”‚  4. DATA MIX RATIOS (secret sauce)                   â”‚
â”‚     â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”            â”‚
â”‚     â”‚ Web text:      ~50-60%            â”‚            â”‚
â”‚     â”‚ Code (GitHub): ~15-25%            â”‚            â”‚
â”‚     â”‚ Books:         ~5-10%             â”‚            â”‚
â”‚     â”‚ Scientific:    ~5-10%             â”‚            â”‚
â”‚     â”‚ Math:          ~3-5%              â”‚            â”‚
â”‚     â”‚ Multilingual:  ~10-20%            â”‚            â”‚
â”‚     â”‚ Conversation:  ~3-5%              â”‚            â”‚
â”‚     â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜            â”‚
â”‚     These ratios MASSIVELY affect capabilities       â”‚
â”‚     More code → better reasoning (!)                 â”‚
â”‚                                                      â”‚
â”‚  5. TRAINING                                         â”‚
â”‚     Objective: Predict the next token                â”‚
â”‚     Hardware: 10K-100K GPUs (H100/H200/B200)         â”‚
â”‚     Duration: 2-6 months                             â”‚
â”‚     Cost: $50M-$500M+ per training run               â”‚
â”‚     Infrastructure: NVIDIA NVLink, InfiniBand,       â”‚
â”‚       distributed training (FSDP, DeepSpeed, Megatron)â”‚
â”‚                                                      â”‚
â”‚  6. MONITORING                                       â”‚
â”‚     Track: loss curves, learning rate, gradient norms â”‚
â”‚     Handle: loss spikes (restart from checkpoint)    â”‚
â”‚     Checkpoint every N steps (recover from crashes)  â”‚
â”‚     Evaluate on held-out benchmarks periodically     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Scaling Laws

```
THE CORE INSIGHT (Kaplan et al., 2020):

  Model performance (loss) improves as a POWER LAW with:
    1. Number of parameters (N)
    2. Amount of training data (D)
    3. Amount of compute (C)

  L(C) âˆ C^(-0.05)  (loss decreases with compute)
  L(N) âˆ N^(-0.076) (loss decreases with parameters)
  L(D) âˆ D^(-0.095) (loss decreases with data)

  WHAT THIS MEANS:
  - 10x more compute → predictable improvement
  - Returns diminish but NEVER stop (no plateau found yet)
  - You can PREDICT a model's quality before training it
```

### Chinchilla Scaling (DeepMind, 2022)

```
THE GAME-CHANGER:

  OpenAI's approach (2020-2022): "Make models BIGGER"
    GPT-3: 175B params, trained on 300B tokens
    Bigger model, less data → expensive inference

  DeepMind's Chinchilla finding:
    "For a given compute budget, you should train a
     SMALLER model on MORE data"

  THE RULE:
    Optimal tokens â‰ˆ 20 Ã— parameters

    Model Size    â”‚ Optimal Data | GPT-3 Used | Chinchilla
    â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    10B params    â”‚ 200B tokens  â”‚ (N/A)      â”‚ âœ“
    70B params    â”‚ 1.4T tokens  â”‚ 300B (!)   â”‚ âœ— undertrained
    175B params   â”‚ 3.5T tokens  â”‚ 300B (!)   â”‚ âœ— MASSIVELY undertrained

  IMPACT:
    GPT-3 was 10x undertrained by this rule!
    LLaMA (Meta, 2023): 65B model trained on 1.4T tokens
      → Matched GPT-3 175B with 3x fewer parameters!

  POST-CHINCHILLA (2024-2026):
    Industry shifted to "over-training" small models:
    Train way beyond the Chinchilla-optimal point
    because inference cost matters more than training cost.

    LLaMA 3 8B: trained on 15T tokens (1875Ã— params!)
    Reason: Train once (expensive), run forever (cheap)
```

### Training Infrastructure

```
HARDWARE (2025-2026 training runs):

  GPU: NVIDIA H100 (80GB) → H200 (141GB) → B200/GB300

  Typical cluster:
    GPT-5.x training:    ~25,000+ H100s
    LLaMA 4:             ~16,000 H100s
    Gemini 3.x:          TPU v5p pods (~10,000+ chips)
    DeepSeek-R1:         ~2,000 H100s (cost-efficient!)

  PARALLELISM STRATEGIES:
    Data Parallel:     Same model on each GPU, different data
    Tensor Parallel:   Split layers WITHIN GPUs (same node)
    Pipeline Parallel: Split layers ACROSS GPUs (different nodes)
    Expert Parallel:   MoE experts on different GPUs
    FSDP:             Fully Sharded Data Parallel (PyTorch)

  NETWORKING:
    NVLink:      GPU-to-GPU within node (900 GB/s)
    InfiniBand:  Node-to-node (400 Gb/s per port)
    Critical: Training large models is often NETWORK-bound

  COST EXAMPLES (approximate, 2025-2026):
    LLaMA 3 70B:     ~$10M
    GPT-5 family:    ~$200M-$500M+
    Gemini 3.x:      ~$100M+ (TPU costs differ)
    DeepSeek-R1:     ~$5M (remarkably cost-efficient)
```

### Training Challenges

```
COMMON FAILURES:
  1. Loss spikes:    Sudden jumps in loss, often from bad data
                     Fix: restart from last checkpoint, skip bad batch

  2. Gradient issues: NaN gradients, exploding/vanishing
                     Fix: gradient clipping, learning rate warmup

  3. Hardware failures: GPUs die during months-long training
                     Fix: aggressive checkpointing, auto-restart

  4. Data contamination: Benchmark data leaks into training set
                     Fix: careful deduplication, held-out evaluation

  5. Instability at scale: Training becomes chaotic at 100B+ params
                     Fix: bf16 precision, Î¼P (maximal update parametrization)
```

---

## ◆ Quick Reference

```
SCALING RULES OF THUMB:
  Chinchilla:     tokens â‰ˆ 20Ã— parameters (compute-optimal)
  Over-training:  tokens â‰ˆ 100-2000Ã— params (inference-optimal)
  10Ã— compute:    ~5% loss reduction (reliable)

TRAINING COST COMPONENTS:
  GPU hours:       60-80% of total cost
  Networking:      10-15%
  Storage:         5-10%
  Engineering:     10-15% (often underestimated)

PRE-TRAINING OBJECTIVE:
  Next-token prediction: P(token_t | token_1, ..., token_{t-1})
  That's it. This single objective produces all LLM capabilities.
```

---

## ○ Interview Angles

- **Q**: Explain the Chinchilla scaling laws.
- **A**: For a fixed compute budget, there's an optimal ratio of model size to training data. Chinchilla showed the optimal is ~20 tokens per parameter. GPT-3 (175B params, 300B tokens) was massively undertrained â€” a 70B model on 1.4T tokens would match it. This led to LLaMA's approach: smaller models, much more data. In 2025-2026, industry "over-trains" beyond Chinchilla-optimal because inference cost (running the model) matters more than training cost (one-time).

- **Q**: How is a large language model pre-trained?
- **A**: (1) Collect trillions of tokens from internet, books, code. (2) Clean and deduplicate aggressively. (3) Train a BPE tokenizer. (4) Set data mix ratios (web, code, books, math). (5) Train using next-token prediction on 10K-100K GPUs for 2-6 months using distributed parallelism (data, tensor, pipeline). (6) Monitor loss curves, handle spikes, checkpoint regularly. Cost: $10M-$500M+ per run.

---

## ★ Code & Implementation

### Chinchilla Optimal Token Calculator

```python
# âš ï¸ Last tested: 2026-04 | Requires: Python 3.10+ (stdlib only)
# Chinchilla paper (Hoffmann et al. 2022): optimal training = 20 tokens per parameter

def chinchilla_optimal(params: float, budget_override: float | None = None) -> dict:
    """
    params: model parameters (e.g. 7e9 for 7B)
    Returns: Chinchilla-optimal token count and FLOPs estimate
    """
    tokens_optimal = 20 * params          # Chinchilla rule
    flops_estimate = 6 * params * tokens_optimal  # ~6 * N * D for transformer training
    return {
        "params":         params,
        "params_B":       params / 1e9,
        "tokens_optimal": tokens_optimal,
        "tokens_B":       tokens_optimal / 1e9,
        "flops_estimate": flops_estimate,
        "flops_e21":      flops_estimate / 1e21,
    }

# Compare common model sizes
for model_name, params in [
    ("LLaMA 3.2 1B",  1e9),
    ("LLaMA 3.2 8B",  8e9),
    ("LLaMA 3 70B",  70e9),
    ("GPT-3 175B",  175e9),
]:
    r = chinchilla_optimal(params)
    print(
        f"{model_name:<18} | {r['params_B']:>6.1f}B params | "
        f"optimal: {r['tokens_B']:>6.0f}B tokens | "
        f"{r['flops_e21']:.1f}e21 FLOPs"
    )

# Note: Modern models (LLaMA 3, Gemma 3) over-train by 5-10x for better
# inference efficiency â€” Chinchilla is the floor, not the ceiling.
```

## ★ Connections

| Relationship | Topics                                                                                                          |
| ------------ | --------------------------------------------------------------------------------------------------------------- |
| Builds on    | [Transformers](./transformers.md), [Deep Learning Fundamentals](../prerequisites/deep-learning-fundamentals.md) |
| Leads to     | [Llms Overview](../llms/llms-overview.md), [Fine Tuning](../techniques/fine-tuning.md) (SFT stage)              |
| Compare with | Fine-tuning (adaptation), Few-shot (no training)                                                                |
| Cross-domain | Distributed systems, HPC, Data engineering                                                                      |


---

## ◆ Production Failure Modes

| Failure                           | Symptoms                                                        | Root Cause                                                    | Mitigation                                                        |
| --------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------- |
| **Compute budget misallocation**  | Over-parameterized model with insufficient data (or vice versa) | Ignoring Chinchilla scaling laws (20 tokens per parameter)    | Use Chinchilla-optimal ratios for compute allocation              |
| **Data quality plateau**          | Loss stops decreasing despite more compute                      | Training data contains duplicates, noise, low-quality content | Deduplicate, filter by perplexity, quality-score data             |
| **Emergent capability surprises** | Capabilities appear or disappear at unexpected scale            | Phase transitions in model behavior                           | Benchmark at multiple scales, don't extrapolate from small models |

---

## ◆ Hands-On Exercises

### Exercise 1: Plot Your Own Scaling Law

**Goal**: Train models at 3 different scales and verify power-law behavior
**Time**: 45 minutes
**Steps**:
1. Train a small transformer at 1M, 10M, 100M parameters on the same dataset
2. Log validation loss at each scale
3. Plot loss vs compute on log-log scale
4. Fit a power law and extrapolate
**Expected Output**: Log-log plot showing linear scaling law relationship
---


## ★ Recommended Resources

| Type    | Resource                                                                                           | Why                                                                     |
| ------- | -------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ðŸ“„ Paper | [Kaplan et al. "Scaling Laws for Neural Language Models" (2020)](https://arxiv.org/abs/2001.08361) | Original OpenAI scaling laws â€” compute, data, parameters                |
| ðŸ“„ Paper | [Hoffmann et al. "Chinchilla" (2022)](https://arxiv.org/abs/2203.15556)                            | Revised scaling: compute-optimal training needs more data than expected |
| ðŸŽ¥ Video | [Andrej Karpathy â€” "Let's Build GPT"](https://www.youtube.com/watch?v=kCc8FmEb1nY)                 | Build a language model from scratch â€” pretraining intuition             |
| ðŸ“˜ Book  | "AI Engineering" by Chip Huyen (2025), Ch 2                                                        | Practical understanding of model selection and scaling tradeoffs        |

## ★ Sources

- Kaplan et al., "Scaling Laws for Neural Language Models" (2020)
- Hoffmann et al., "Training Compute-Optimal Large Language Models" (Chinchilla, 2022)
- Touvron et al., "LLaMA: Open and Efficient Foundation Language Models" (2023)
- Meta, "LLaMA 3 Technical Report" (2024)
- NVIDIA, "Megatron-LM: Training Multi-Billion Parameter Language Models" (2020)
