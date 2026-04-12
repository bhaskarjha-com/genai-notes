---
title: "Docker & Kubernetes for GenAI Deployment"
tags: [docker, kubernetes, containers, deployment, llmops, production]
type: procedure
difficulty: intermediate
status: published
parent: "[[llmops]]"
related: ["[[model-serving]]", "[[monitoring-observability]]", "[[cicd-for-ml]]", "[[cost-optimization]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Docker & Kubernetes for GenAI Deployment

> Containers make GenAI workloads reproducible. Kubernetes makes them operable when one container is no longer enough.

---

## TL;DR

- **What**: The core deployment stack for packaging, shipping, and scaling AI services.
- **Why**: Most production AI systems fail on environment drift, weak rollout practices, or poor scaling long before they fail on model quality.
- **Key point**: Use Docker to standardize runtime; use Kubernetes when you need repeatable multi-instance operations, autoscaling, and infrastructure policy.

---

## Overview

### Definition

**Docker** packages an application and its dependencies into a portable container image. **Kubernetes** schedules and manages those containers across a cluster.

### Scope

This note covers the practical concepts an AI engineer needs: image design, container boundaries, Kubernetes objects, GPU scheduling, and deployment patterns. For model-specific request handling, see [Model Serving for LLM Applications](./model-serving.md).

### Significance

- Self-hosted GenAI almost always becomes a container problem before it becomes a model problem.
- Hiring teams use Docker and Kubernetes as a proxy for "can this person ship systems, not just notebooks?"
- Good container discipline improves security, reproducibility, and rollback speed.

### Prerequisites

- [LLMOps & Production Deployment](./llmops.md)
- [AI System Design for GenAI Applications](./ai-system-design.md)
- [Model Serving for LLM Applications](./model-serving.md)

---

## Deep Dive

### Why Containers Matter for AI

AI apps are unusually dependency-heavy:

- CUDA and driver compatibility matter
- model weights can be large and sensitive to path/layout assumptions
- Python environments drift easily across laptops, CI, and servers
- serving stacks often combine API code, model runtime, queues, and observability agents

Containers give you a predictable runtime boundary.

### Docker Building Blocks

| Concept | What It Does | Why It Matters |
|---|---|---|
| **Image** | Immutable packaged filesystem + config | What you build and deploy |
| **Container** | Running instance of an image | What actually serves traffic |
| **Dockerfile** | Build recipe | Encodes reproducibility |
| **Registry** | Stores images | Enables CI/CD and rollbacks |
| **Volume** | Persistent storage | Avoid baking mutable data into images |
| **Network** | Container connectivity | Important for gateways, vector DBs, and tracing |

### Container Design Rules for GenAI

1. Keep the image focused on one responsibility, for example API server or worker.
2. Do not bake secrets into images.
3. Prefer pulling large model weights at startup or mounting them from managed storage.
4. Separate build-time dependencies from runtime dependencies with multi-stage builds.
5. Make health checks explicit.

### Example Dockerfile for a FastAPI LLM Gateway

```dockerfile
FROM python:3.12-slim AS base

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Core Kubernetes Objects

| Object | Purpose | AI Example |
|---|---|---|
| **Pod** | Smallest deployable unit | One API server or inference worker |
| **Deployment** | Manages rolling updates for stateless workloads | LLM gateway replicas |
| **Service** | Stable internal network endpoint | Route traffic to pods |
| **ConfigMap** | Non-secret config | Feature flags, model route settings |
| **Secret** | Sensitive config | API keys, database credentials |
| **Job/CronJob** | Batch or scheduled work | Offline eval runs, embedding sync |
| **HorizontalPodAutoscaler** | Adjust replica count | Scale API gateways on traffic |
| **Ingress/Gateway** | External traffic entry | Public API or internal portal |

### Deployment Patterns

| Pattern | When To Use | Notes |
|---|---|---|
| **Single container on VM** | Early prototype or low-traffic internal app | Lowest ops overhead |
| **Docker Compose** | Local integration testing | Good for app + vector DB + tracing stack |
| **Kubernetes deployment** | Multi-service or team-managed production | Standard platform choice |
| **Kubernetes + GPU nodes** | Self-hosted model serving | Requires GPU scheduling and cost controls |

### GPU Scheduling in Kubernetes

For self-hosted inference, the platform typically includes:

- GPU node pools
- device plugins from the hardware vendor
- node selectors or taints/tolerations to isolate GPU workloads
- autoscaling policies to avoid idle expensive nodes

A common split is:

- CPU pods for orchestration, retrieval, and API layers
- GPU pods for inference servers

### Minimal Kubernetes Deployment Shape

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-gateway
spec:
  replicas: 3
  selector:
    matchLabels:
      app: llm-gateway
  template:
    metadata:
      labels:
        app: llm-gateway
    spec:
      containers:
        - name: api
          image: ghcr.io/example/llm-gateway:1.0.0
          ports:
            - containerPort: 8000
          readinessProbe:
            httpGet:
              path: /health
              port: 8000
```

### When Kubernetes Is Worth It

Use Kubernetes when you need several of these at once:

- multiple services with independent scaling
- reliable rollouts and rollbacks
- cluster-wide policy and observability
- scheduled jobs and background workers
- shared platform conventions across teams

Do not adopt Kubernetes only because it feels "more production."

---

## Quick Reference

| Situation | Better First Move |
|---|---|
| Shipping a prototype | Docker on one VM or managed platform |
| Reproducing dev and CI environments | Docker |
| Running several services together locally | Docker Compose |
| Rolling updates and autoscaling | Kubernetes Deployment + HPA |
| Offline evaluation jobs | Kubernetes Job or CronJob |
| Expensive GPU workloads | Separate GPU node pools and strict autoscaling |

---

## Gotchas

- Large model downloads can make pod startup painfully slow; plan warmup and image strategy.
- "One huge container" creates noisy failure domains and painful deploys.
- Kubernetes does not fix bad serving architecture; it only manages it.
- GPU cost can explode if autoscaling and idle shutdown are weak.

---

## Interview Angles

- **Q**: When would you choose Kubernetes for a GenAI system?
- **A**: When the system has multiple independently scaled services, controlled rollouts, background jobs, observability requirements, or self-hosted inference that needs GPU scheduling. For smaller systems, a managed platform or simple container deployment may be better.

- **Q**: What is the main Docker benefit for AI teams?
- **A**: Reproducibility. It removes "works on my machine" failures across notebooks, CI, and production while standardizing dependencies and rollout behavior.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [LLMOps & Production Deployment](./llmops.md), [AI System Design for GenAI Applications](./ai-system-design.md) |
| Leads to | [Model Serving for LLM Applications](./model-serving.md), [Monitoring & Observability for GenAI Systems](./monitoring-observability.md), [CI/CD for ML and LLM Systems](./cicd-for-ml.md) |
| Compare with | Managed PaaS deployment, serverless inference |
| Cross-domain | DevOps, platform engineering, SRE |

---

## Sources

- Docker documentation - https://docs.docker.com
- Kubernetes documentation - https://kubernetes.io/docs
- NVIDIA Kubernetes device plugin documentation
- [LLMOps & Production Deployment](./llmops.md)
