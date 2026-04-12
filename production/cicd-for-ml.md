---
title: "CI/CD for ML and LLM Systems"
tags: [cicd, mlops, llmops, deployment, testing, automation]
type: procedure
difficulty: advanced
status: published
parent: "[[llmops]]"
related: ["[[docker-and-kubernetes]]", "[[monitoring-observability]]", "[[../evaluation/llm-evaluation-deep-dive]]", "[[model-serving]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# CI/CD for ML and LLM Systems

> In AI systems, "did the code build?" is the easy question. The hard question is "did the behavior stay good enough to ship?"

---

## TL;DR

- **What**: The automation pipeline for testing, packaging, validating, and releasing ML and LLM systems.
- **Why**: AI changes can silently degrade quality, safety, or cost while all unit tests still pass.
- **Key point**: CI/CD for AI must validate behavior, not just syntax and infrastructure.

---

## Overview

### Definition

**CI/CD for AI systems** extends normal software delivery with model, prompt, dataset, and evaluation checks.

### Scope

This note covers the delivery path for GenAI services and ML-backed applications. It focuses on artifacts, gating logic, rollout patterns, and regression control.

### Significance

- Prompt or model changes can be production regressions even when no code changed.
- AI pipelines need reproducible artifacts and quality gates.
- This knowledge sits at the core of MLOps and platform engineering interviews.

### Prerequisites

- [LLMOps & Production Deployment](./llmops.md)
- [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md)
- [Docker & Kubernetes for GenAI Deployment](./docker-and-kubernetes.md)

---

## Deep Dive

### What Changes in AI Systems

The delivery pipeline may need to track changes in:

- application code
- prompts and prompt templates
- model versions or providers
- retrieval settings
- evaluation datasets
- guardrail rules
- container images and infra config

### AI Delivery Pipeline

```text
Commit
-> unit and integration tests
-> lint / static checks
-> build image or package artifact
-> run offline eval suite
-> compare quality and cost against baseline
-> stage deployment
-> canary or shadow rollout
-> online monitoring and rollback gates
```

### Quality Gates

| Gate | Example Check |
|---|---|
| **Functional** | API tests, schema validation, tool contracts |
| **Behavioral** | rubric score, answer correctness, hallucination rate |
| **Safety** | policy refusal behavior, jailbreak resistance |
| **Cost** | prompt token increase within budget |
| **Performance** | latency and throughput within threshold |

### Artifact Discipline

Track these explicitly:

- prompt versions
- evaluation dataset versions
- model/provider versions
- container image digests
- rollout config

If the team cannot answer "what exactly changed?", rollback becomes guesswork.

### Release Strategies

| Strategy | When To Use | Benefit |
|---|---|---|
| **Canary** | User-facing systems | Safer gradual rollout |
| **Shadow** | New model under real traffic without affecting users | Great for comparison |
| **Blue/green** | Strong rollback needs | Fast environment switch |
| **Manual approval** | High-risk or regulated flows | Adds human checkpoint |

### Example GitHub Actions Shape

```yaml
name: ai-ci
on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install deps
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest
      - name: Run eval suite
        run: python scripts/run_evals.py
```

### Practical Rollout Rules

1. Block deploys on meaningful quality regression, not only test failures.
2. Keep a gold dataset for stable regression checks.
3. Separate fast PR checks from slower nightly or pre-release evals.
4. Log prompt and model versions in production.
5. Rehearse rollback for both code and model-routing changes.

---

## Quick Reference

| Change Type | Minimum Checks |
|---|---|
| Prompt change | offline evals, cost diff, formatting checks |
| Model swap | quality regression, latency, cost, safety |
| Retrieval change | context relevance, groundedness, fallback behavior |
| Infra change | build, deploy, smoke tests, observability validation |
| Agent workflow change | task success rate, tool-call regression, trace review |

---

## Gotchas

- Unit tests alone can create false confidence.
- A better benchmark score can still be a worse product outcome.
- Teams often forget to version datasets and prompts.
- Slow eval suites should be tiered, not skipped.

---

## Interview Angles

- **Q**: What makes CI/CD for LLM systems different from regular CI/CD?
- **A**: The output behavior is probabilistic and influenced by prompts, models, and datasets, so the pipeline needs evaluation gates, cost checks, and rollout safety beyond normal software tests.

- **Q**: What would you gate before shipping a model change?
- **A**: Quality against a regression set, safety checks, latency, token cost, and rollback readiness. If the change affects retrieval or agents, I would also inspect representative traces.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md), [Monitoring & Observability for GenAI Systems](./monitoring-observability.md), [Docker & Kubernetes for GenAI Deployment](./docker-and-kubernetes.md) |
| Leads to | [Cost Optimization for GenAI Systems](./cost-optimization.md), release governance, platform engineering |
| Compare with | Traditional CI/CD, classical MLOps pipelines |
| Cross-domain | DevOps, experiment management, QA engineering |

---

## Sources

- GitHub Actions documentation
- Argo CD documentation
- MLflow documentation
- [LLMOps & Production Deployment](./llmops.md)
