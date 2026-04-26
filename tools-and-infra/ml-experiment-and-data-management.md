---
title: "ML Experiment & Data Management"
aliases: ["MLflow", "Experiment Tracking", "W&B"]
tags: [experiment-tracking, data-versioning, mlflow, wandb, dvc, lineage, infrastructure]
type: reference
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "tools-overview.md"
related: ["cloud-ml-services.md", "../production/cicd-for-ml.md", "../production/llmops.md", "../production/monitoring-observability.md"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# ML Experiment & Data Management

> ✨ **Bit**: If you can't answer "which config and data produced this result?" you're not experimenting — you're guessing. Experiment tracking and data versioning are two halves of the reproducibility story. Code versioning without data versioning is only half the picture.

---

## ★ TL;DR

- **What**: The practices and tools for recording ML runs (parameters, metrics, artifacts) and tracking dataset changes (versions, lineage, snapshots)
- **Why**: ML behavior changes when either code OR data changes. Without tracking both, reproducing results, debugging regressions, and governing models is impossible.
- **Key point**: Track not just the best run, but enough context to explain why it was better — including the exact data version behind it.

---

## ★ Overview

### Definition

**Experiment tracking** is the structured logging of model runs and metadata for reproducibility and comparison. **Data versioning** is tracking the specific data used in every experiment, enabling exact reproduction of results.

### Scope

Covers: Experiment tracking discipline, data versioning strategies, tool selection (MLflow, W&B, DVC, LakeFS), GenAI-specific considerations (prompt versions, eval sets, RAG corpora), and production code.

### Significance

- Strong tracking accelerates iteration and debugging
- ML governance and audit require lineage from data → model → deployment
- Data drift and silent dataset changes are common causes of production regressions
- Essential for promotion from notebook work to team-level ML engineering

### Prerequisites

- [CI/CD for ML](../production/cicd-for-ml.md)
- [Cloud ML Services](./cloud-ml-services.md)
- [LLMOps](../production/llmops.md)

---

## ★ Deep Dive

### What to Track

| Category | Items | Examples |
|----------|-------|---------|
| **Parameters** | Run config | learning rate, batch size, prompt version, model name |
| **Metrics** | Quality & cost signals | loss, accuracy, eval score, latency, token cost |
| **Artifacts** | Outputs | model checkpoints, plots, generated outputs |
| **Environment** | Reproducibility context | code version (git SHA), dependency set, hardware |
| **Data lineage** | Data state | dataset version, splits, preprocessing steps |

### What to Version (Data)

| Item | Examples | Why |
|------|---------|-----|
| **Raw data snapshot** | Ingestion state, source identifiers | Reproduce from source |
| **Processed dataset** | Cleaned, transformed training table | Training input reproducibility |
| **Splits** | Train/val/test partition | Fair comparison across experiments |
| **Evaluation sets** | Gold prompts, edge-case examples | Regression detection |
| **GenAI-specific** | Retrieved corpora, prompt-eval sets, preference data, synthetic datasets | LLM behavior depends on all of these |

### Why This Matters More in GenAI

GenAI teams must track more artifacts than classical ML:

- **Prompt versions**: Different wording changes behavior dramatically
- **Eval set versions**: The benchmark defines what "better" means
- **RAG corpus snapshots**: Re-indexing changes retrieval results
- **Preference/feedback datasets**: RLHF training data evolves
- **Model routing configs**: Which model handles which queries

### Tool Landscape

| Tool | Experiment Tracking | Data Versioning | Best For |
|------|:-------------------:|:---------------:|---------|
| **MLflow** | ✅ | Partial (model registry) | Open-source, self-hosted |
| **Weights & Biases** | ✅ | Partial (artifacts) | Team collaboration, visualization |
| **DVC** | Partial | ✅ | Git-based data versioning |
| **LakeFS** | ❌ | ✅ | Data lake versioning at scale |
| **Neptune.ai** | ✅ | Partial | Metadata-rich experiment tracking |
| **Vertex AI / SageMaker** | ✅ | ✅ | Integrated cloud ML platform |

### Data Versioning Strategies

| Strategy | Strength | Best For |
|----------|----------|---------|
| **Immutable snapshots** | Easy reproducibility | Small/medium datasets |
| **Object-store versioning** | Practical for large files | Cloud-native teams |
| **Git-like tools (DVC)** | Lineage and branching | ML teams using Git workflows |
| **Table formats (Delta/Iceberg)** | Schema evolution, time travel | Data engineering teams |

---

## ★ Code & Implementation

### MLflow Experiment Tracking

```python
# pip install mlflow>=2.10
# ⚠️ Last tested: 2026-04 | Requires: mlflow>=2.10

import mlflow

# Start tracking an experiment
mlflow.set_experiment("rag-retrieval-optimization")

with mlflow.start_run(run_name="bge-small-baseline"):
    # Log parameters
    mlflow.log_param("embedding_model", "BAAI/bge-small-en-v1.5")
    mlflow.log_param("chunk_size", 400)
    mlflow.log_param("chunk_overlap", 50)
    mlflow.log_param("top_k", 5)
    mlflow.log_param("dataset_version", "eval_set_v3")
    
    # Log metrics
    mlflow.log_metric("recall_at_5", 0.72)
    mlflow.log_metric("precision_at_5", 0.48)
    mlflow.log_metric("mrr", 0.65)
    mlflow.log_metric("avg_latency_ms", 45)
    
    # Log artifacts
    mlflow.log_artifact("configs/rag_config.yaml")
    
    print(f"Run ID: {mlflow.active_run().info.run_id}")

# Compare runs programmatically (for CI/CD pipelines)
experiment = mlflow.get_experiment_by_name("rag-retrieval-optimization")
runs = mlflow.search_runs(
    experiment_ids=[experiment.experiment_id],
    order_by=["metrics.mrr DESC"],
    max_results=5,
)
print(f"Best MRR: {runs.iloc[0]['metrics.mrr']:.3f} (run: {runs.iloc[0]['run_id'][:8]})")

# Model promotion gate: only promote if MRR improved
best_mrr = runs.iloc[0]["metrics.mrr"]
if best_mrr > 0.70:
    print(f"PROMOTE: MRR {best_mrr:.3f} exceeds threshold 0.70")
else:
    print(f"HOLD: MRR {best_mrr:.3f} below threshold 0.70")
# Expected output: Run tracked with full reproducibility, comparison across 5 runs
```

### DVC Data Versioning

```bash
# Install: pip install dvc[s3]
# ⚠️ Last tested: 2026-04

# Initialize DVC in your git repo
dvc init

# Track a dataset
dvc add data/eval_set_v3.jsonl
git add data/eval_set_v3.jsonl.dvc .gitignore
git commit -m "Track eval set v3"

# Push data to remote storage
dvc remote add -d myremote s3://my-bucket/dvc-store
dvc push

# Later: reproduce exact dataset state from any git commit
git checkout abc123    # checkout the commit
dvc pull               # pull the exact data version used in that commit
```

---

## ◆ Quick Reference

```
EXPERIMENT TRACKING CHECKLIST:

  Every run MUST record:
  ✓ Parameters (config, hyperparams, prompt version)
  ✓ Metrics (quality, cost, latency)
  ✓ Data version (dataset ID, split, snapshot hash)
  ✓ Code version (git SHA)
  ✓ Environment (dependencies, hardware)
  ✓ Artifacts (model, outputs, plots)

DATA VERSIONING CHECKLIST:

  ✓ Assign stable dataset identifiers
  ✓ Version evaluation sets just like code
  ✓ Record exact snapshot used by every important run
  ✓ Keep schema and provenance metadata with the data
  ✓ Make rollback and replay possible
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Unreproducible results** | Can't recreate a previous model's behavior | Data version not recorded with experiment | Always log dataset version with every run |
| **Silent data drift** | Model quality degrades over time | Training or eval data changed without explicit versioning | Immutable snapshots, checksum validation, drift detection |
| **Tracking decay** | Team stops logging experiments after initial enthusiasm | Manual tracking is tedious | Automate logging (decorators, callbacks), make it zero-effort |
| **Eval set contamination** | Model performs well on benchmarks but poorly in production | Eval set not versioned separately, leaked into training | Strict eval set versioning, separate storage, access controls |

---

## ○ Gotchas

- Tracking only the best run hides important learning
- Manual metadata entry decays quickly — automate everything
- A dashboard without artifact or data lineage is incomplete
- Naming folders `final_v2_real` is not data versioning
- Eval datasets are often forgotten even though they're critical

---

## ○ Interview Angles

- **Q**: What is the minimum metadata you would track for an ML run?
- **A**: Parameters, metrics, code version, data version, artifacts, and environment details. Without that set, comparing or reproducing results is unreliable. For GenAI specifically, I'd also track prompt versions, eval set versions, and token costs.

- **Q**: Why is data versioning essential for ML reproducibility?
- **A**: Because code alone does not determine model behavior. You need the exact dataset state, splits, and lineage to reproduce or explain results. In GenAI, this extends to RAG corpus snapshots, preference data, and evaluation sets.

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [CI/CD for ML](../production/cicd-for-ml.md), [Cloud ML Services](./cloud-ml-services.md) |
| Leads to | Model registry, auditability, reproducible training, [LLMOps](../production/llmops.md) |
| Compare with | Ad hoc notebook history, code-only versioning |
| Cross-domain | Data engineering, experiment design, governance |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [Weights & Biases Documentation](https://docs.wandb.ai/) | Industry-standard experiment tracking platform |
| 🔧 Hands-on | [MLflow Documentation](https://mlflow.org/docs/) | Open-source experiment tracking and model registry |
| 🔧 Hands-on | [DVC Documentation](https://dvc.org/doc) | Git-based data and model versioning |
| 🔧 Hands-on | [LakeFS Documentation](https://docs.lakefs.io/) | Git-like versioning for data lakes |
| 📘 Book | "Designing Machine Learning Systems" by Chip Huyen (2022), Ch 4, 6 | Data management and experiment tracking in ML workflows |


---

## ◆ Hands-On Exercises

### Exercise 1: Set Up End-to-End Experiment Tracking

**Goal**: Track a complete ML experiment with reproducibility
**Time**: 30 minutes
**Steps**:
1. Set up MLflow tracking server locally
2. Train a model with 3 hyperparameter configurations
3. Log params, metrics, artifacts, and environment info for each run
4. Use the MLflow UI to compare runs and select the best
**Expected Output**: MLflow dashboard showing 3 comparable runs with artifact links
---

## ★ Sources

- MLflow Documentation — https://mlflow.org/docs/
- Weights & Biases Documentation — https://docs.wandb.ai/
- DVC Documentation — https://dvc.org/doc
- LakeFS Documentation — https://docs.lakefs.io/
- [CI/CD for ML](../production/cicd-for-ml.md)
