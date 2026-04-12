---
title: "ML Experiment Tracking"
tags: [experiment-tracking, mlflow, wandb, metrics, lineage, infrastructure]
type: reference
difficulty: intermediate
status: published
parent: "[[tools-overview]]"
related: ["[[data-versioning-for-ml]]", "[[cloud-ml-services]]", "[[../production/cicd-for-ml]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# ML Experiment Tracking

> If you cannot answer "which config produced this result?" you are not experimenting - you are guessing.

---

## TL;DR

- **What**: The practice of recording runs, parameters, metrics, artifacts, and lineage for ML and AI work.
- **Why**: Reproducibility, comparison, and model governance depend on it.
- **Key point**: Track not just the best run, but enough context to explain why it was better.

---

## Overview

### Definition

**Experiment tracking** is the structured logging of model runs and related metadata so teams can reproduce, compare, and operationalize results.

### Scope

This note applies to classical ML, fine-tuning, evaluations, and some prompt experiments. It focuses on the discipline more than any specific tool.

### Significance

- Strong tracking accelerates iteration and debugging.
- It is essential for promotion from notebook work to team work.
- MLOps platforms almost always include this capability for a reason.

### Prerequisites

- [CI/CD for ML and LLM Systems](../production/cicd-for-ml.md)
- [Data Versioning for ML](./data-versioning-for-ml.md)
- [Cloud ML Services & Managed AI Platforms](./cloud-ml-services.md)

---

## Deep Dive

### What To Track

| Item | Examples |
|---|---|
| **Parameters** | learning rate, batch size, prompt version |
| **Metrics** | loss, accuracy, eval score, latency |
| **Artifacts** | model checkpoints, plots, outputs |
| **Environment** | code version, dependency set, hardware |
| **Data lineage** | dataset or slice version |

### Why It Matters In GenAI

Experiment tracking is useful for:

- fine-tuning runs
- prompt and eval comparisons
- RAG configuration changes
- routing-policy experiments
- offline benchmark and rubric results

### Tool Capabilities To Look For

| Capability | Why It Helps |
|---|---|
| **Run comparison** | see what changed across attempts |
| **Artifact storage** | keep outputs tied to runs |
| **Lineage** | connect data, code, model, and metrics |
| **Registry integration** | promote good outputs into deployment workflow |
| **Team collaboration** | share dashboards and notes |

### Practical Workflow

1. define the experiment question
2. log config and environment automatically
3. capture both quality and cost metrics
4. compare against a baseline run
5. publish the result and decision

### Tool Examples

Common examples include MLflow and Weights & Biases, while many cloud platforms offer built-in equivalents. The precise tool matters less than the discipline.

### Minimal MLflow Example

```python
import mlflow

with mlflow.start_run(run_name="baseline-xgboost"):
    mlflow.log_param("learning_rate", 0.05)
    mlflow.log_param("dataset_version", "customer_churn_v3")
    mlflow.log_metric("eval_score", 0.84)
    mlflow.log_metric("latency_ms", 42)
```

---

## Quick Reference

| If You Need To... | Track This Too |
|---|---|
| compare models | dataset version and runtime config |
| compare prompts | eval set version and cost |
| promote a model | artifact, metrics, and approval notes |
| debug a regression | code version, environment, and lineage |

---

## Gotchas

- Tracking only the best run hides important learning.
- Manual metadata entry usually decays quickly.
- A dashboard without artifact or data lineage is incomplete.

---

## Interview Angles

- **Q**: What is the minimum metadata you would track for an ML run?
- **A**: Parameters, metrics, code version, data version, artifacts, and environment details. Without that, comparing or reproducing results becomes unreliable.

- **Q**: Why does experiment tracking matter for GenAI if prompts change often?
- **A**: That is exactly why it matters. Prompt versions, evaluation sets, and cost differences need structured history just like model hyperparameters do.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Data Versioning for ML](./data-versioning-for-ml.md), [CI/CD for ML and LLM Systems](../production/cicd-for-ml.md) |
| Leads to | model registry, auditability, reproducibility |
| Compare with | ad hoc notebook history |
| Cross-domain | experiment design, analytics |

---

## Sources

- MLflow documentation
- Weights & Biases documentation
- [CI/CD for ML and LLM Systems](../production/cicd-for-ml.md)
