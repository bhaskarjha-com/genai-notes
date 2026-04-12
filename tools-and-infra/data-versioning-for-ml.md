---
title: "Data Versioning for ML"
tags: [data-versioning, datasets, lineage, dvc, lakefs, infrastructure]
type: reference
difficulty: intermediate
status: published
parent: "[[tools-overview]]"
related: ["[[ml-experiment-tracking]]", "[[cloud-ml-services]]", "[[../production/cicd-for-ml]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Data Versioning for ML

> Code versioning without data versioning is only half a reproducibility story.

---

## TL;DR

- **What**: The practices and tools used to track dataset changes, lineage, and reproducible data states.
- **Why**: ML behavior can change dramatically when the data changes, even if the code does not.
- **Key point**: A model result is only reproducible if you can identify the exact data slice behind it.

---

## Overview

### Definition

**Data versioning** is the process of identifying, storing, and reproducing the specific data used in experiments, training, evaluation, or production pipelines.

### Scope

This note covers dataset lineage, snapshots, splits, and tool choices. It applies to both traditional ML and GenAI pipelines.

### Significance

- Data drift and silent dataset changes are common causes of confusion.
- Governance and debugging depend on lineage.
- Strong data versioning supports CI/CD, experiment tracking, and auditability.

### Prerequisites

- [ML Experiment Tracking](./ml-experiment-tracking.md)
- [CI/CD for ML and LLM Systems](../production/cicd-for-ml.md)
- basic data pipeline awareness

---

## Deep Dive

### What Should Be Versioned

| Item | Examples |
|---|---|
| **Raw data snapshot** | ingestion state, source identifiers |
| **Processed dataset** | cleaned and transformed training table |
| **Splits** | train, validation, test |
| **Evaluation sets** | golden prompts, edge-case examples |
| **Metadata** | schema, labels, provenance |

### Why It Matters In GenAI

GenAI teams should version:

- retrieved corpora or indexing snapshots
- prompt-eval sets
- preference or feedback datasets
- synthetic training datasets
- moderation and policy test sets

### Common Strategies

| Strategy | Strength |
|---|---|
| **Immutable snapshots** | easy reproducibility |
| **Object-store versioning** | practical for large files |
| **Git-like data tools** | lineage and branching concepts |
| **Catalog plus metadata** | useful for enterprise data governance |

### Tool Examples

Examples include DVC, lakeFS, Delta/Iceberg-style table versioning, and managed platform lineage tools. The exact stack depends on data size and platform context.

### Practical Workflow

1. assign stable dataset identifiers
2. version evaluation sets just like code
3. record the exact snapshot used by every important run
4. keep schema and provenance with the data
5. make rollback and replay possible

### Example Workflow With DVC

```bash
dvc add data/training/customer_churn_v3.parquet
git add data/training/customer_churn_v3.parquet.dvc .gitignore
git commit -m "Track customer churn dataset v3"

# Later: pull the exact dataset state used by a run
dvc pull
```

---

## Quick Reference

| Problem | Better Data Practice |
|---|---|
| model changed unexpectedly | inspect dataset version first |
| impossible-to-reproduce eval | version the eval set and prompts |
| weak governance | add lineage and provenance metadata |
| large file chaos | use object-store-backed versioning strategy |

---

## Gotchas

- Naming folders `final_v2_real` is not data versioning.
- Versioning raw data without processed data lineage is incomplete.
- Eval datasets are often forgotten even though they are critical.

---

## Interview Angles

- **Q**: Why is data versioning essential for ML reproducibility?
- **A**: Because code alone does not determine model behavior. You need the exact dataset state, splits, and lineage to reproduce or explain results.

- **Q**: What data should a GenAI team version besides training data?
- **A**: Retrieved corpora snapshots, evaluation sets, preference data, synthetic datasets, and any policy or red-team test sets that influence behavior assessment.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [ML Experiment Tracking](./ml-experiment-tracking.md), [CI/CD for ML and LLM Systems](../production/cicd-for-ml.md) |
| Leads to | reproducible training, better auditability, safer releases |
| Compare with | code-only versioning |
| Cross-domain | data engineering, governance |

---

## Sources

- DVC documentation
- lakeFS documentation
- [ML Experiment Tracking](./ml-experiment-tracking.md)
