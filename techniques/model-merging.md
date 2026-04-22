---
title: "Model Merging"
aliases: ["Model Merging", "TIES", "DARE", "SLERP", "MergeKit"]
tags: [model-merging, ties, dare, slerp, mergekit, fine-tuning, open-weight, genai]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["fine-tuning.md", "advanced-fine-tuning.md", "distillation-and-compression.md", "../inference/inference-optimization.md"]
source: "Multiple â€” see Sources"
created: 2026-04-15
updated: 2026-04-15
---

# Model Merging

> âœ¨ **Bit**: Fine-tuning gives you specialists. Model merging gives you a generalist built from specialists â€” at zero extra training cost.

---

## â˜… TL;DR

- **What**: Techniques to combine the weights of multiple fine-tuned models into a single model without additional training
- **Why**: Cheaper than training a multi-task model from scratch; lets you combine domain experts (code + medical + safety) into one deployable model
- **Key point**: Merging is NOT ensembling â€” you get ONE model at inference time, with no extra latency or memory cost

---

## â˜… Overview

### Definition

**Model merging** encompasses weight-space techniques that combine parameters from two or more models â€” typically fine-tuned from the same base model â€” into a single unified model. Unlike ensembles (which run multiple models at inference), merged models have identical cost and latency to a single model.

### Scope

Covers: TIES, DARE, SLERP, Model Soups, Frankenmerging, and the mergekit toolchain. For model size reduction, see [Distillation and Compression](./distillation-and-compression.md). For weight modification via training, see [Fine-Tuning](./fine-tuning.md) and [Advanced Fine-Tuning](./advanced-fine-tuning.md).

### Significance

- **Standard open-weight technique** in 2025-2026: top HuggingFace Open LLM Leaderboard models are typically merges
- **Cost**: Zero GPU-hours for training â€” merging is a pure weight arithmetic operation
- **Production use cases**: Multi-task deployment, domain adaptation stacking, safety alignment injection
- **Interview topic**: "When would you merge models instead of fine-tuning or distilling?" is a common system design question

### Prerequisites

- [Fine-Tuning](./fine-tuning.md) â€” understanding what fine-tuned weight deltas represent
- [Distillation and Compression](./distillation-and-compression.md) â€” alternative model optimization path
- [Inference Optimization](../inference/inference-optimization.md) â€” serving context for merged models

---

## â˜… Deep Dive

### Why Merging Works

When you fine-tune a base model for different tasks, each resulting model occupies a point in weight space near the base model. Research shows that:

1. **The loss landscape between fine-tuned models is often convex** â€” averaging weights tends to land in a good region
2. **Most weight changes are small** â€” fine-tuning modifies <5% of weights significantly
3. **Different tasks modify different weights** â€” interference is lower than expected

```
WEIGHT SPACE VISUALIZATION:

         Code Expert â—
                    â•²
                     â•²  â† Merged model lands
                      â—    somewhere in this region
                     â•±
                    â•±
     Medical Expert â—
                    â”‚
                    â”‚
              Base Model â—

Key insight: The path between fine-tuned models
often passes through regions of LOW loss for BOTH tasks.
```

### Core Techniques

| Technique | Method | When to Use | Quality | Complexity |
|-----------|--------|-------------|---------|:----------:|
| **Model Soups** | Simple weight averaging | Same base, same task, different hyperparams | Good | Low |
| **SLERP** | Spherical interpolation between 2 models | Blending 2 models with different strengths | Good | Low |
| **TIES** | Trim + Elect Sign + Merge | â‰¥2 models with potential sign conflicts | Very Good | Medium |
| **DARE** | Drop + Rescale delta params | Sparsifying merges, combines with TIES | Very Good | Medium |
| **Frankenmerging** | Layer/block stacking from different models | Experimental, architecture exploration | Variable | High |

### Model Soups (Weight Averaging)

The simplest technique â€” average the weights of models fine-tuned from the same base.

```
UNIFORM SOUP:
  merged_weight = (model_A_weight + model_B_weight + model_C_weight) / 3

WEIGHTED SOUP:
  merged_weight = 0.5 * model_A_weight + 0.3 * model_B_weight + 0.2 * model_C_weight

Works best when:
  - All models share the same base (e.g., all fine-tuned from LLaMA 3.2 8B)
  - Models were trained on similar tasks but with different hyperparameters
  - You want a more robust model (reduces variance)
```

### SLERP (Spherical Linear Interpolation)

Interpolates between two models along a spherical path rather than a straight line in weight space. Better preserves the magnitude of weight vectors.

```
LINEAR INTERPOLATION (naive):
  merged = (1 - t) * model_A + t * model_B
  Problem: Can shrink weight magnitudes at t = 0.5

SLERP:
  Î© = arccos(A Â· B / (|A| Ã— |B|))
  merged = sin((1-t)Î©)/sin(Î©) Ã— A + sin(tÎ©)/sin(Î©) Ã— B
  Advantage: Preserves weight vector norms

  t = 0.0 â†’ pure model A
  t = 0.5 â†’ balanced blend
  t = 1.0 â†’ pure model B

Limitation: Only works for EXACTLY 2 models.
For 3+ models, use TIES or DARE.
```

### TIES (Trim, Elect Sign, Merge)

Designed to resolve **parameter interference** when merging multiple models.

```
THE INTERFERENCE PROBLEM:
  Model A says weight_42 should increase by +0.3
  Model B says weight_42 should decrease by -0.2
  Naive averaging: +0.05 (neither model gets what it wants!)

TIES SOLUTION (3 steps):

  STEP 1 â€” TRIM: Drop low-magnitude delta parameters
    Delta = fine_tuned_weight - base_weight
    If |delta| < threshold â†’ set to 0
    Removes noise, keeps only significant changes

  STEP 2 â€” ELECT SIGN: Resolve sign conflicts by majority vote
    If 2 models say "increase" and 1 says "decrease"
    â†’ Elect positive sign, zero out the negative delta

  STEP 3 â€” MERGE: Average the remaining (trimmed, sign-aligned) deltas
    merged = base_weight + avg(surviving_deltas)
```

### DARE (Drop and Rescale)

A sparsification technique that randomly drops most delta parameters and rescales the remainder. Often combined with TIES.

```
DARE MECHANISM:
  1. Compute delta: Î” = fine_tuned - base
  2. Randomly drop p% of delta parameters (typically p = 90-99%)
  3. Rescale remaining: Î”_surviving = Î”_surviving / (1 - p)
     (Rescaling preserves the expected sum of deltas)

WHY IT WORKS:
  Most fine-tuning deltas are redundant. Dropping 90% and rescaling
  the rest preserves performance while reducing interference when merging.

TYPICAL COMBO:
  DARE (drop_rate=0.9) + TIES = DARE-TIES
  â†’ Best of both: sparsification + sign conflict resolution
```

### Frankenmerging (Layer Stacking)

Instead of averaging weights, select specific layers from different models.

```
MODEL A (good at reasoning):  [L0] [L1] [L2] [L3] [L4] [L5]
MODEL B (good at code):       [L0] [L1] [L2] [L3] [L4] [L5]

FRANKENMERGE:
  [A:L0] [A:L1] [B:L2] [B:L3] [A:L4] [A:L5]
  â†’ Take reasoning layers from A, coding layers from B

CAUTION:
  - Highly experimental, results are unpredictable
  - Works because transformer layers are somewhat modular
  - Requires matching architectures (same hidden dims, heads, etc.)
  - Popularized by the "Goliath" 120B merge on HuggingFace
```

### Decision Guide

```
WHEN TO MERGE vs OTHER APPROACHES:

  Have multiple fine-tuned models from same base?
    YES â†’ Model merging is free â€” try TIES-DARE first
    NO  â†’ Can you fine-tune from a common base? If no â†’ Distillation

  Need guaranteed quality for production?
    YES â†’ Fine-tune from scratch on combined data (safer but expensive)
    NO  â†’ Merge is fine for experimentation

  Models fine-tuned on DIFFERENT tasks?
    YES â†’ TIES or DARE-TIES (handles interference)
    NO  â†’ Model Soups or SLERP (models are close in weight space)

  Only 2 models?
    YES â†’ SLERP (best for 2-model blending)
    NO  â†’ TIES or DARE-TIES (handles 3+ models)

  Want to explore exotic architectures?
    YES â†’ Frankenmerge (experimental, high variance)
    NO  â†’ Stick with weight-average methods
```

---

## â˜… Code & Implementation

### Merging with mergekit

```yaml
# pip install mergekit
# âš ï¸ Last tested: 2026-04 | Requires: mergekit>=0.0.5, torch>=2.0, GPU recommended

# === mergekit YAML config: TIES-DARE merge of 2 LoRA experts ===
# Save as: merge_config.yaml

merge_method: dare_ties
base_model: meta-llama/Llama-3.2-8B-Instruct  # shared base
parameters:
  weight: 0.5          # equal weight per model
  density: 0.5         # DARE: keep 50% of delta params (drop_rate=0.5)
  normalize: true      # normalize merged weights
slices:
  - sources:
      - model: meta-llama/Llama-3.2-8B-Instruct  # base (reference)
        parameters:
          weight: 0     # base model has zero merge weight
      - model: ./models/code-expert-lora           # fine-tuned for code
        parameters:
          weight: 0.6   # code expert gets slightly more weight
          density: 0.5
      - model: ./models/medical-expert-lora         # fine-tuned for medical QA
        parameters:
          weight: 0.4
          density: 0.5
dtype: bfloat16
tokenizer_source: base  # use base model tokenizer

# Run: mergekit-yaml merge_config.yaml ./merged-model --cuda
# Output: A single model at ./merged-model/ that handles both code and medical tasks
```

### Simple Weight Averaging (Pure PyTorch)

```python
# pip install torch>=2.0 safetensors>=0.4
# âš ï¸ Last tested: 2026-04 | Requires: torch>=2.0

import torch
from safetensors.torch import load_file, save_file

def merge_models_soup(model_paths: list[str], weights: list[float] = None) -> dict:
    """Merge multiple models via weighted averaging (Model Soups).

    Args:
        model_paths: Paths to safetensors model files
        weights: Per-model weights (default: uniform)

    Returns:
        Merged state dict
    """
    if weights is None:
        weights = [1.0 / len(model_paths)] * len(model_paths)

    assert len(model_paths) == len(weights), "Must have one weight per model"
    assert abs(sum(weights) - 1.0) < 1e-6, "Weights must sum to 1.0"

    # Load first model as template
    merged = load_file(model_paths[0])
    for key in merged:
        merged[key] = merged[key].float() * weights[0]

    # Accumulate weighted contributions from other models
    for path, weight in zip(model_paths[1:], weights[1:]):
        state_dict = load_file(path)
        for key in merged:
            merged[key] += state_dict[key].float() * weight

    # Convert back to bfloat16 for efficient serving
    for key in merged:
        merged[key] = merged[key].to(torch.bfloat16)

    return merged

# Usage
merged_state = merge_models_soup(
    model_paths=[
        "models/code-expert/model.safetensors",
        "models/medical-expert/model.safetensors",
        "models/safety-tuned/model.safetensors",
    ],
    weights=[0.4, 0.3, 0.3],  # code-heavy blend
)
save_file(merged_state, "merged-model/model.safetensors")
print(f"Merged {len(merged_state)} tensors successfully")
```

---

## â—† Quick Reference

```
TECHNIQUE CHEAT SHEET:

  2 models, simple blend         â†’ SLERP (t=0.3-0.7)
  3+ models, same task           â†’ Model Soups (uniform averaging)
  3+ models, different tasks     â†’ TIES or DARE-TIES
  Experimental layer mixing      â†’ Frankenmerge (âš ï¸ high variance)
  LoRA adapters specifically     â†’ DARE-TIES via mergekit

MERGEKIT COMMANDS:
  mergekit-yaml config.yaml ./output --cuda      # GPU merge
  mergekit-yaml config.yaml ./output --lazy       # CPU (low memory)
  mergekit-yaml config.yaml ./output --out-shard-size 4G  # control shard size

COMMON HYPERPARAMETERS:
  density (DARE):  0.3-0.7  (lower = more aggressive dropping)
  weight:          0.3-0.7  (relative importance per model)
  trim threshold:  top 20%  (TIES: keep only significant deltas)
```

---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Capability collapse** | Merged model loses a skill one parent had | Weight interference â€” competing deltas cancel out | Use TIES/DARE instead of naive averaging; test each capability post-merge |
| **Safety regression** | Merged model bypasses safety training | Safety alignment weights diluted by task-specific merges | Always include safety-tuned model with high weight (â‰¥0.3); red-team test post-merge |
| **Evaluation blindspots** | Merge scores well on average benchmarks but fails on specific tasks | Averaging hides per-task regressions | Evaluate on EACH parent's original eval set, not just aggregate benchmarks |
| **Architecture mismatch** | Merge crashes or produces garbage | Models have different architectures, vocab sizes, or tokenizers | Only merge models from the same base architecture and tokenizer |
| **LoRA rank mismatch** | mergekit fails or produces degraded output | Different LoRA rank/alpha across adapters | Standardize rank/alpha across all LoRA experiments you plan to merge |

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Only merge from the same base**: Merging LLaMA with Mistral produces garbage. Models MUST share the same architecture and initialization.
- âš ï¸ **Evaluate per-task, not just aggregate**: A merge can improve average scores while catastrophically losing one parent's specialty.
- âš ï¸ **Tokenizer matters**: Use the base model's tokenizer. If any fine-tuned model added special tokens, the merge will have mismatched embeddings.
- âš ï¸ **SLERP is for 2 models only**: For 3+ models, use TIES or DARE. SLERP doesn't extend to multi-model merges.
- âš ï¸ **Merging â‰  knowledge addition**: Merging combines what models already know. It cannot teach a merged model NEW knowledge that no parent had.

---

## â—‹ Interview Angles

- **Q**: When would you use model merging instead of fine-tuning on combined data?
- **A**: Merging when: (1) you already have multiple fine-tuned models and want to avoid retraining, (2) you don't have access to the original training data, (3) you want to quickly iterate on combinations (merging takes minutes, fine-tuning takes hours). Fine-tuning on combined data when: (1) you need guaranteed quality, (2) you have the data and compute budget, (3) the task combination is complex enough that weight averaging won't capture interactions.

- **Q**: How do you evaluate whether a merge was successful?
- **A**: Three levels. First, run each parent model's original eval suite against the merge â€” the merge should retain â‰¥90% of each parent's task-specific performance. Second, run general benchmarks (MMLU-Pro, HumanEval) to ensure no broad capability loss. Third, red-team for safety regressions, especially if one parent was a safety-tuned model. If any parent's capability drops below acceptable threshold, adjust merge weights or switch to TIES/DARE to reduce interference.

---

## â—† Hands-On Exercises

### Exercise 1: Merge Two LoRA Adapters with mergekit

**Goal**: Create a multi-task model from two LoRA experts
**Time**: 30 minutes
**Steps**:
1. Fine-tune two LoRA adapters from the same base (e.g., one for code, one for summarization) â€” or download two from HuggingFace
2. Write a mergekit YAML config using `dare_ties` method
3. Run `mergekit-yaml config.yaml ./merged --cuda`
4. Evaluate the merged model on both tasks
5. Compare: merged model vs each parent on their respective task
**Expected Output**: A single model that handles both tasks with â‰¤10% quality degradation per task

---

## â˜… Connections

| Relationship | Topics |
|---|---|
| Builds on | [Fine-Tuning](./fine-tuning.md), [Advanced Fine-Tuning](./advanced-fine-tuning.md), [Distillation and Compression](./distillation-and-compression.md) |
| Leads to | [Inference Optimization](../inference/inference-optimization.md) (serving merged models), [LLM Landscape](../llms/llm-landscape.md) (open-weight ecosystem) |
| Compare with | Ensemble methods (multiple models at inference), Multi-task fine-tuning (single training run) |
| Cross-domain | Federated learning (weight aggregation), Neural architecture search |

---

## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ”§ Hands-on | [mergekit](https://github.com/arcee-ai/mergekit) | Industry-standard toolkit for all merge methods |
| ðŸ“„ Paper | [Yadav et al., "Resolving Interference When Merging Models" (2023)](https://arxiv.org/abs/2306.01708) | The TIES paper â€” foundational reading |
| ðŸ“„ Paper | [Yu et al., "Language Models are Super Mario" (2023)](https://arxiv.org/abs/2311.03099) | The DARE paper â€” drop and rescale technique |
| ðŸ“„ Paper | [Wortsman et al., "Model Soups" (2022)](https://arxiv.org/abs/2203.05482) | Original work on weight averaging of fine-tuned models |
| ðŸ”§ Hands-on | [HuggingFace Open LLM Leaderboard](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard) | See which top models are merges |

---

## â˜… Sources

- Yadav et al., "Resolving Interference When Merging Models" (TIES, NeurIPS 2023)
- Yu et al., "Language Models are Super Mario: Absorbing Abilities from Homologous Models as a Free Lunch" (DARE, 2023)
- Wortsman et al., "Model Soups: Averaging Weights of Multiple Fine-tuned Models Improves Accuracy" (ICML 2022)
- mergekit documentation â€” https://github.com/arcee-ai/mergekit
- [Fine-Tuning](./fine-tuning.md)
- [Advanced Fine-Tuning](./advanced-fine-tuning.md)
