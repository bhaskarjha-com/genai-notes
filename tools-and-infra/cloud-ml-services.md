---
title: "Cloud ML Services & Managed AI Platforms"
tags: [cloud, sagemaker, vertex-ai, azure-ai-foundry, mlops, infrastructure]
type: reference
difficulty: intermediate
status: published
parent: "[[tools-overview]]"
related: ["[[ml-experiment-tracking]]", "[[data-versioning-for-ml]]", "[[../production/llmops]]", "[[../production/docker-and-kubernetes]]"]
source: "Primary vendor docs - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Cloud ML Services & Managed AI Platforms

> Managed AI platforms trade some control for speed, governance, and operational leverage. For many teams, that trade is worth it.

---

## TL;DR

- **What**: The major managed cloud platforms used to build, deploy, and operate ML and GenAI systems.
- **Why**: These platforms bundle notebooks, training, deployment, evaluation, security, and governance into one operating environment.
- **Key point**: The best platform choice depends less on raw features and more on team context, cloud alignment, and governance needs.

---

## Overview

### Definition

**Cloud ML services** are managed platforms that support parts or all of the ML and GenAI lifecycle, including data prep, training, experimentation, deployment, monitoring, and governance.

### Scope

This note focuses on platform categories and the major hyperscaler offerings rather than deep vendor-specific setup instructions.

### Significance

- Most enterprise AI teams use a managed platform somewhere in the stack.
- Platform choice affects velocity, compliance posture, and operating model.
- ML engineer and MLOps interviews often expect a point of view here.

### Prerequisites

- [GenAI Tools & Infrastructure](./tools-overview.md)
- [LLMOps & Production Deployment](../production/llmops.md)
- [Docker & Kubernetes for GenAI Deployment](../production/docker-and-kubernetes.md)

Last verified for major platform naming and positioning: 2026-04.

---

## Deep Dive

### What Managed Platforms Usually Provide

| Capability | Examples |
|---|---|
| **Development** | notebooks, prompt studios, SDKs |
| **Training** | managed jobs, tuning, distributed runs |
| **Model management** | registry, versioning, approval workflows |
| **Deployment** | endpoints, scaling, online and batch inference |
| **Observability** | logs, traces, metrics, monitoring |
| **Governance** | IAM, audit, approval, policy controls |

### Major Platform Families

| Platform | Short Description | Typical Strength |
|---|---|---|
| **AWS SageMaker AI** | Broad managed ML/AI platform on AWS | strong AWS integration and end-to-end workflow support |
| **Google Vertex AI** | Unified platform for ML and GenAI on GCP | strong generative AI, model garden, and GCP workflow integration |
| **Azure AI Foundry + Azure ML** | Microsoft's platform family for AI apps, agents, and ML workflows | strong enterprise governance and Microsoft ecosystem fit |

### How To Compare Platforms

| Question | Why It Matters |
|---|---|
| Does the team already live in this cloud? | biggest practical force in most decisions |
| Do we need managed training, managed inference, or both? | some teams only need part of the stack |
| How strong are governance and identity needs? | enterprise adoption depends on this |
| Are we building classic ML, GenAI apps, or both? | platform depth differs by workload |
| How much portability do we need? | affects lock-in risk |

### Typical Adoption Patterns

| Pattern | Example |
|---|---|
| **All-in platform** | training, registry, deployment, monitoring in one cloud |
| **Hybrid** | managed training plus custom serving stack |
| **Managed GenAI only** | prompt tooling and model access on cloud, custom app layer elsewhere |

### When Managed Platforms Shine

- fast team setup
- tighter IAM and compliance integration
- shared workflows across data science and engineering
- reduced platform maintenance burden

### When They Feel Heavy

- small teams shipping fast prototypes
- highly custom serving stacks
- multi-cloud portability requirements
- cost-sensitive workloads where custom infra is leaner

### Quick CLI Examples

```bash
# AWS SageMaker AI
aws sagemaker list-endpoints

# Google Vertex AI
gcloud ai endpoints list --region=us-central1

# Azure AI / Azure ML
az ml online-endpoint list
```

---

## Quick Reference

| Need | Good Direction |
|---|---|
| already on AWS | evaluate SageMaker AI first |
| already on GCP | evaluate Vertex AI first |
| already on Microsoft enterprise stack | evaluate Azure AI Foundry and Azure ML first |
| need full custom control | managed platform may be partial, not primary |
| need enterprise governance fast | managed platform usually helps |

---

## Gotchas

- Teams overestimate how much of the platform they will actually use.
- Platform convenience can turn into lock-in if abstraction boundaries are weak.
- Billing complexity can hide in adjacent services, not only the platform headline cost.
- Managed does not mean no architecture decisions.

---

## Interview Angles

- **Q**: How would you choose between SageMaker, Vertex AI, and Azure AI Foundry?
- **A**: I would start with the existing cloud footprint, governance requirements, workload type, and team skills. The best choice is usually the platform that fits the organization's operating context, not the one with the longest feature list.

- **Q**: When would you avoid a full managed platform?
- **A**: When the team needs extreme portability, a highly custom serving stack, or the platform overhead outweighs the operational value for the size of the workload.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [GenAI Tools & Infrastructure](./tools-overview.md), [LLMOps & Production Deployment](../production/llmops.md) |
| Leads to | experiment tracking, registry workflows, managed deployment patterns |
| Compare with | self-hosted platform engineering |
| Cross-domain | cloud architecture, governance, platform strategy |

---

## Sources

- AWS SageMaker AI documentation and overview pages
- Google Cloud Vertex AI documentation and overview pages
- Microsoft Azure AI Foundry and Azure Machine Learning documentation
