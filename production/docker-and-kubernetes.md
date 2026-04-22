---
title: "Docker & Kubernetes for GenAI Deployment"
aliases: ["Docker", "Kubernetes", "K8s", "Containers"]
tags: [docker, kubernetes, containers, deployment, llmops, production]
type: procedure
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "llmops.md"
related: ["model-serving.md", "monitoring-observability.md", "cicd-for-ml.md", "cost-optimization.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Docker & Kubernetes for GenAI Deployment

> Containers make GenAI workloads reproducible. Kubernetes makes them operable when one container is no longer enough.

---

## â˜… TL;DR
- **What**: The core deployment stack for packaging, shipping, and scaling AI services.
- **Why**: Most production AI systems fail on environment drift, weak rollout practices, or poor scaling long before they fail on model quality.
- **Key point**: Use Docker to standardize runtime; use Kubernetes when you need repeatable multi-instance operations, autoscaling, and infrastructure policy.

---

## â˜… Overview
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

## â˜… Deep Dive
### Why Containers Matter for AI

AI apps are unusually dependency-heavy:

- CUDA and driver compatibility matter
- model weights can be large and sensitive to path/layout assumptions
- Python environments drift easily across laptops, CI, and servers
- serving stacks often combine API code, model runtime, queues, and observability agents

Containers give you a predictable runtime boundary.

### Docker Building Blocks

| Concept        | What It Does                           | Why It Matters                                  |
| -------------- | -------------------------------------- | ----------------------------------------------- |
| **Image**      | Immutable packaged filesystem + config | What you build and deploy                       |
| **Container**  | Running instance of an image           | What actually serves traffic                    |
| **Dockerfile** | Build recipe                           | Encodes reproducibility                         |
| **Registry**   | Stores images                          | Enables CI/CD and rollbacks                     |
| **Volume**     | Persistent storage                     | Avoid baking mutable data into images           |
| **Network**    | Container connectivity                 | Important for gateways, vector DBs, and tracing |

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

| Object                      | Purpose                                         | AI Example                          |
| --------------------------- | ----------------------------------------------- | ----------------------------------- |
| **Pod**                     | Smallest deployable unit                        | One API server or inference worker  |
| **Deployment**              | Manages rolling updates for stateless workloads | LLM gateway replicas                |
| **Service**                 | Stable internal network endpoint                | Route traffic to pods               |
| **ConfigMap**               | Non-secret config                               | Feature flags, model route settings |
| **Secret**                  | Sensitive config                                | API keys, database credentials      |
| **Job/CronJob**             | Batch or scheduled work                         | Offline eval runs, embedding sync   |
| **HorizontalPodAutoscaler** | Adjust replica count                            | Scale API gateways on traffic       |
| **Ingress/Gateway**         | External traffic entry                          | Public API or internal portal       |

### Deployment Patterns

| Pattern                    | When To Use                                 | Notes                                     |
| -------------------------- | ------------------------------------------- | ----------------------------------------- |
| **Single container on VM** | Early prototype or low-traffic internal app | Lowest ops overhead                       |
| **Docker Compose**         | Local integration testing                   | Good for app + vector DB + tracing stack  |
| **Kubernetes deployment**  | Multi-service or team-managed production    | Standard platform choice                  |
| **Kubernetes + GPU nodes** | Self-hosted model serving                   | Requires GPU scheduling and cost controls |

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

## â—† Quick Reference
| Situation                                 | Better First Move                              |
| ----------------------------------------- | ---------------------------------------------- |
| Shipping a prototype                      | Docker on one VM or managed platform           |
| Reproducing dev and CI environments       | Docker                                         |
| Running several services together locally | Docker Compose                                 |
| Rolling updates and autoscaling           | Kubernetes Deployment + HPA                    |
| Offline evaluation jobs                   | Kubernetes Job or CronJob                      |
| Expensive GPU workloads                   | Separate GPU node pools and strict autoscaling |

---

## â—‹ Gotchas & Common Mistakes
- Large model downloads can make pod startup painfully slow; plan warmup and image strategy.
- "One huge container" creates noisy failure domains and painful deploys.
- Kubernetes does not fix bad serving architecture; it only manages it.
- GPU cost can explode if autoscaling and idle shutdown are weak.

---

## â—‹ Interview Angles
- **Q**: When would you choose Kubernetes for a GenAI system?
- **A**: When the system has multiple independently scaled services, controlled rollouts, background jobs, observability requirements, or self-hosted inference that needs GPU scheduling. For smaller systems, a managed platform or simple container deployment may be better.

- **Q**: What is the main Docker benefit for AI teams?
- **A**: Reproducibility. It removes "works on my machine" failures across notebooks, CI, and production while standardizing dependencies and rollout behavior.

---

## â˜… Code & Implementation

### Containerize a FastAPI LLM Service

```dockerfile
# Dockerfile â€” production LLM API service
# âš ï¸ Last tested: 2026-04 | Requires: Docker 24+
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=8080
EXPOSE 8080

# Non-root user for security
RUN useradd -m appuser && chown -R appuser /app
USER appuser

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "4"]
```

```python
# main.py â€” FastAPI LLM endpoint
# pip install fastapi>=0.110 uvicorn>=0.29 openai>=1.60 pydantic>=2
# âš ï¸ Last tested: 2026-04
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from openai import OpenAI, APIError
import os

app    = FastAPI(title="LLM API")
client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])

class ChatRequest(BaseModel):
    message: str
    model: str = "gpt-4o-mini"
    max_tokens: int = 200

class ChatResponse(BaseModel):
    response: str
    model: str
    tokens_used: int

@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest) -> ChatResponse:
    try:
        resp = client.chat.completions.create(
            model=req.model,
            messages=[{"role": "user", "content": req.message}],
            max_tokens=req.max_tokens,
        )
    except APIError as e:
        raise HTTPException(status_code=502, detail=str(e))
    return ChatResponse(
        response=resp.choices[0].message.content,
        model=resp.model,
        tokens_used=resp.usage.total_tokens,
    )

@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}
```

```yaml
# docker-compose.yml for local development + testing
version: "3.9"
services:
  llm-api:
    build: .
    ports: ["8080:8080"]
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 5s
      retries: 3
```

## â˜… Connections
| Relationship | Topics                                                                                                                                                                                    |
| ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [LLMOps & Production Deployment](./llmops.md), [AI System Design for GenAI Applications](./ai-system-design.md)                                                                           |
| Leads to     | [Model Serving for LLM Applications](./model-serving.md), [Monitoring & Observability for GenAI Systems](./monitoring-observability.md), [CI/CD for ML and LLM Systems](./cicd-for-ml.md) |
| Compare with | Managed PaaS deployment, serverless inference                                                                                                                                             |
| Cross-domain | DevOps, platform engineering, SRE                                                                                                                                                         |


---

## â—† Production Failure Modes

| Failure                          | Symptoms                               | Root Cause                                     | Mitigation                                                 |
| -------------------------------- | -------------------------------------- | ---------------------------------------------- | ---------------------------------------------------------- |
| **GPU scheduling failures**      | Pods stuck in Pending, no GPU assigned | Insufficient GPU node pool, no resource quotas | Node auto-scaling, quotas, GPU sharing (MIG, time-slicing) |
| **Image size explosion**         | 15GB+ container images, slow pulls     | CUDA runtime + model weights in image          | Multi-stage builds, model weights via volume mount         |
| **OOM kills during inference**   | Container killed mid-request           | Memory limit too low for model + KV-cache      | Profile actual memory, set limits 20% above peak           |
| **Health check false positives** | K8s restarts healthy pods              | Health check doesn't verify GPU readiness      | Custom health endpoint with test inference                 |

---

## â—† Hands-On Exercises

### Exercise 1: Containerize a Model Server

**Goal**: Build an optimized Docker image for LLM serving and deploy to K8s
**Time**: 45 minutes
**Steps**:
1. Write a multi-stage Dockerfile (build deps, then runtime-only)
2. Mount model weights as a volume (not baked into image)
3. Deploy to minikube with GPU resource requests
4. Test horizontal pod autoscaling based on request queue depth
**Expected Output**: Running pod with GPU access, image size under 2GB
---


## â˜… Recommended Resources

| Type       | Resource                                                                           | Why                                        |
| ---------- | ---------------------------------------------------------------------------------- | ------------------------------------------ |
| ðŸ”§ Hands-on | [Docker Official Documentation](https://docs.docker.com/)                          | Container fundamentals for ML deployment   |
| ðŸ”§ Hands-on | [Kubernetes for ML (Kubeflow)](https://www.kubeflow.org/docs/)                     | ML-specific Kubernetes orchestration       |
| ðŸ“˜ Book     | "Kubernetes in Action" by Luksa (2020)                                             | Comprehensive K8s reference                |
| ðŸŽ¥ Video    | [TechWorld with Nana â€” "Docker + K8s"](https://www.youtube.com/@TechWorldwithNana) | Best beginner-friendly container tutorials |

## â˜… Sources
- Docker documentation - https://docs.docker.com
- Kubernetes documentation - https://kubernetes.io/docs
- NVIDIA Kubernetes device plugin documentation
- [LLMOps & Production Deployment](./llmops.md)
