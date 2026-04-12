---
title: "Classical ML for GenAI Builders"
tags: [classical-ml, xgboost, sklearn, ranking, routing, production]
type: concept
difficulty: intermediate
status: published
parent: "[[llmops]]"
related: ["[[../tools-and-infra/ml-experiment-tracking]]", "[[../tools-and-infra/data-versioning-for-ml]]", "[[cost-optimization]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Classical ML for GenAI Builders

> Not every AI problem needs an LLM. Often the best GenAI system quietly depends on simpler models around the edges.

---

## TL;DR

- **What**: The role of traditional ML methods such as logistic regression, gradient boosting, and ranking models in GenAI systems.
- **Why**: LLMs are powerful but expensive, harder to control, and unnecessary for many supporting tasks.
- **Key point**: Use classical ML where prediction is narrow, structured, and cost-sensitive.

---

## Overview

### Definition

This note covers **classical ML** in the context of GenAI products, meaning supervised and unsupervised methods outside the main LLM generation step.

### Scope

It does not try to teach all of machine learning. It explains where simpler models fit in the GenAI stack and why teams still care about them.

### Significance

- Many practical AI systems are hybrids, not pure LLM stacks.
- Classical ML is often cheaper, faster, and easier to evaluate for narrow decisions.
- ML engineer roles still expect this fluency even inside GenAI teams.

### Prerequisites

- [LLMOps & Production Deployment](./llmops.md)
- [Cost Optimization for GenAI Systems](./cost-optimization.md)
- Basic statistics and supervised learning knowledge

---

## Deep Dive

### Where Classical ML Shows Up Around GenAI

| Use Case | Why Classical ML Helps |
|---|---|
| **Routing** | choose model or path cheaply |
| **Spam / abuse detection** | narrow classifiers can be fast and reliable |
| **Ranking** | rerank candidates or tickets efficiently |
| **Forecasting** | demand and capacity planning around AI usage |
| **Anomaly detection** | detect unusual usage or failure patterns |
| **Tabular prediction** | many business tasks remain tabular, not generative |

### Why Not Use An LLM For Everything

- cost is often much higher
- latency is worse
- output control is weaker
- evaluation may be harder

### Typical Hybrid Architecture

```text
request
-> cheap classifier or router
-> if simple, handle with deterministic or classical path
-> if complex, use LLM path
-> track outcome and cost
```

### Common Model Families

| Family | Good For |
|---|---|
| **Logistic regression** | baseline classification and calibrated probability |
| **Gradient boosting / XGBoost** | strong tabular performance |
| **Linear ranking models** | simple retrieval or routing features |
| **Clustering / anomaly methods** | segmentation and monitoring support |

### Practical Reasons Teams Keep These Skills

1. They offer strong baselines.
2. They are easier to deploy cheaply.
3. They help explain and instrument decisions around the LLM.
4. They often outperform LLMs on narrow structured tasks.

---

## Quick Reference

| Problem Type | First Model To Consider |
|---|---|
| binary structured decision | logistic regression or gradient boosting |
| tabular business prediction | XGBoost or similar |
| cheap request routing | lightweight classifier |
| anomaly detection | classical anomaly model before LLM investigation |
| free-form generation | LLM path |

---

## Gotchas

- Teams sometimes replace simple reliable models with expensive LLM calls for no real gain.
- A hybrid stack needs clear ownership and instrumentation.
- Classical ML still needs data quality, feature design, and monitoring.

---

## Interview Angles

- **Q**: Why should an LLM engineer care about classical ML?
- **A**: Because many production GenAI systems use simpler models for routing, ranking, moderation, and analytics. Knowing when not to use an LLM is part of good engineering judgment.

- **Q**: What is a good hybrid example?
- **A**: Use a lightweight classifier to route only hard or high-value requests to an LLM, while simpler cases stay on a cheap deterministic or classical ML path.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Cost Optimization for GenAI Systems](./cost-optimization.md), [LLMOps & Production Deployment](./llmops.md) |
| Leads to | ML engineer workflows, routing design, experiment tracking |
| Compare with | LLM-only architecture |
| Cross-domain | data science, recommendation, analytics |

---

## Sources

- scikit-learn documentation
- XGBoost documentation
- [Cost Optimization for GenAI Systems](./cost-optimization.md)
