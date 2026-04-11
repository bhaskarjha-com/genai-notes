---
title: "GenAI Tools & Infrastructure"
tags: [tools, infrastructure, langchain, llamaindex, vector-db, serving, genai]
type: reference
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../techniques/rag]]", "[[../techniques/ai-agents]]", "[[../llms/llms-overview]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-03-18
---

# GenAI Tools & Infrastructure

> ✨ **Bit**: The model is 10% of the work. The infrastructure around it is the other 90%. Welcome to production.

---

## ★ TL;DR

- **What**: The ecosystem of frameworks, databases, serving engines, and platforms used to build GenAI applications
- **Why**: Knowing models is theory. Knowing the tooling is what gets you hired and makes things work in production.
- **Key point**: The stack is converging: Orchestration (LangChain/LlamaIndex) + Vector DB + Serving Engine + Observability

---

## ★ Overview

### Definition

GenAI infrastructure encompasses everything between "I have a model" and "I have a production application" — orchestration frameworks, vector databases, model serving engines, evaluation tools, and observability platforms.

### Scope

This is the overview/index document. Deep dives on individual tools are in sub-documents:
- [[vector-databases]] — Pinecone, Weaviate, Qdrant, Chroma, pgvector
- For orchestration + RAG code, also see [[../techniques/rag]]

### Significance

- This is where **deep tech** separates from **wrapper dev**
- Understanding infra = you can architect systems, not just call APIs
- The layer where most production problems live (latency, cost, reliability)

### Prerequisites

- [[../llms/llms-overview]] — what you're serving/orchestrating
- [[../techniques/rag]] — primary use case for most tools

---

## ★ Deep Dive

### The GenAI Application Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│  Chat UI │ API Endpoints │ Slack/Teams Bot │ Internal Tools  │
├─────────────────────────────────────────────────────────────┤
│                    ORCHESTRATION LAYER                       │
│  LangChain │ LlamaIndex │ Semantic Kernel │ Custom Code     │
├──────────────────────┬──────────────────────────────────────┤
│   RETRIEVAL          │         GENERATION                    │
│  ┌────────────────┐  │  ┌────────────────────────────────┐  │
│  │ Vector DB      │  │  │ Model API / Self-hosted LLM    │  │
│  │ (Pinecone,     │  │  │ (OpenAI, Anthropic, vLLM,      │  │
│  │  Weaviate,     │  │  │  Ollama, TGI)                  │  │
│  │  Qdrant)       │  │  │                                │  │
│  ├────────────────┤  │  ├────────────────────────────────┤  │
│  │ Embedding      │  │  │ Guardrails / Safety            │  │
│  │ Models         │  │  │ (NeMo, Guardrails AI)          │  │
│  └────────────────┘  │  └────────────────────────────────┘  │
├──────────────────────┴──────────────────────────────────────┤
│                    OBSERVABILITY & EVAL                      │
│  LangSmith │ Weights & Biases │ Phoenix │ RAGAS │ DeepEval  │
├─────────────────────────────────────────────────────────────┤
│                    COMPUTE / INFRA                           │
│  GPU Cloud (AWS, GCP, Azure) │ Serverless │ On-prem         │
└─────────────────────────────────────────────────────────────┘
```

### Tool Categories & Top Picks

#### 1. Orchestration Frameworks

| Framework           | Language  | Strengths                              | Best For                           |
| ------------------- | --------- | -------------------------------------- | ---------------------------------- |
| **LangChain**       | Python/JS | Largest ecosystem, most integrations   | General purpose, RAG, chains       |
| **LlamaIndex**      | Python    | Best for data/RAG, structured indexing | Data-heavy apps, enterprise search |
| **LangGraph**       | Python    | Stateful agent graphs (by LangChain)   | Complex agents, workflows          |
| **Semantic Kernel** | C#/Python | Microsoft ecosystem, enterprise        | .NET shops, Azure-first            |
| **Haystack**        | Python    | Clean API, production-focused          | Search/RAG pipelines               |

**When to use what:**
```
"I need a quick RAG prototype"       → LlamaIndex
"I need complex agent workflows"     → LangGraph
"I need maximum flexibility/control" → LangChain
"I'm in the Microsoft ecosystem"     → Semantic Kernel
"I want minimal abstraction"         → Direct API calls + custom code
```

#### 2. Model Serving & Inference

| Engine                | Use Case           | Key Feature                                   |
| --------------------- | ------------------ | --------------------------------------------- |
| **vLLM**              | Self-host LLMs     | PagedAttention, fastest open-source inference |
| **Ollama**            | Local development  | Run LLMs locally with one command             |
| **TGI** (HuggingFace) | Production serving | Docker-ready, HF integration                  |
| **TensorRT-LLM**      | NVIDIA GPUs        | Best NVIDIA optimization                      |
| **llama.cpp**         | CPU / Edge         | Run quantized models on CPU                   |
| **SGLang**            | High throughput    | RadixAttention, constrained decoding          |

```bash
# Run LLaMA locally with Ollama (simplest start)
ollama run llama3.2

# Serve with vLLM (production)
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.2-8B \
  --tensor-parallel-size 2
```

#### 3. Evaluation & Observability

| Tool                 | Purpose                   | Key Feature                              |
| -------------------- | ------------------------- | ---------------------------------------- |
| **LangSmith**        | Tracing, eval, monitoring | LangChain native, best debugging         |
| **RAGAS**            | RAG evaluation            | Automated faithfulness/relevance metrics |
| **DeepEval**         | LLM testing               | Unit tests for LLM outputs               |
| **Phoenix** (Arize)  | Observability             | Open-source tracing                      |
| **Weights & Biases** | Experiment tracking       | ML experiment management                 |
| **Braintrust**       | Eval + logging            | Prompt playground + eval                 |

#### 4. Platforms (Managed)

| Platform             | What It Provides                           |
| -------------------- | ------------------------------------------ |
| **Hugging Face**     | Model hub, Spaces, Inference API, datasets |
| **Replicate**        | One-click model deployment                 |
| **Together AI**      | Fast API for open models                   |
| **Fireworks AI**     | Fastest open model serving                 |
| **AWS Bedrock**      | Managed access to multiple models          |
| **Google Vertex AI** | Gemini + model garden + fine-tuning        |
| **Azure AI Studio**  | OpenAI models + enterprise features        |

---

## ◆ Types & Classifications

### By Deployment Pattern

```
How to Serve LLMs
├── API (Managed)
│   ├── Direct: OpenAI, Anthropic, Google APIs
│   └── Aggregator: Together AI, Fireworks, Replicate
│
├── Self-Hosted (Your Infra)
│   ├── vLLM / TGI (GPU server)
│   ├── Ollama (local dev)
│   └── llama.cpp (CPU/edge)
│
└── Hybrid
    ├── Cloud GPU (RunPod, Lambda, AWS)
    └── On-prem + cloud burst
```

### Cost Decision Matrix

| Scenario           | Best Choice          | Why                        |
| ------------------ | -------------------- | -------------------------- |
| Prototyping        | API (OpenAI/Claude)  | Fast start, no infra       |
| < 100K tokens/day  | API                  | Cheaper than running a GPU |
| 100K-1M tokens/day | Evaluate both        | Crossover point            |
| > 1M tokens/day    | Self-host (vLLM)     | API costs explode          |
| Privacy-critical   | Self-host            | Data stays on your infra   |
| Latency-critical   | Self-host + optimize | Control over serving       |

---

## ◆ Quick Reference

```
STARTER STACK (prototype):
  LLM:        OpenAI API / Claude API
  Framework:  LangChain or LlamaIndex
  Vector DB:  Chroma (local) or Pinecone (managed)
  Eval:       Manual + RAGAS

PRODUCTION STACK:
  LLM:        vLLM (self-host) or API with fallback
  Framework:  LangGraph / custom orchestration
  Vector DB:  Qdrant or Weaviate (self-host) or Pinecone
  Eval:       LangSmith + RAGAS + custom metrics
  Monitor:    LangSmith or Phoenix
  Guardrails: NeMo Guardrails or custom

BUDGET STACK (learning / hobby):
  LLM:        Ollama (local) + free tier APIs
  Framework:  LangChain
  Vector DB:  Chroma (embedded)
  Eval:       Manual testing
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Framework lock-in**: LangChain abstractions are convenient but can hide important details. Understand what's happening underneath.
- ⚠️ **"Just use the API" at scale**: At 1M+ tokens/day, API costs can be $1000+/month. Do the math before committing.
- ⚠️ **Ignoring evaluation**: Most teams ship GenAI without measuring quality. Build eval into your pipeline from day 1.
- ⚠️ **Ollama in production**: Ollama is for dev, not production serving. Use vLLM or TGI for production workloads.
- ⚠️ **Vector DB hype**: For < 100K documents, pgvector (Postgres extension) is probably enough. Don't over-architect.

---

## ○ Interview Angles

- **Q**: How would you architect a production RAG system?
- **A**: LLM via API (with fallback), vector DB (Qdrant/Pinecone) with hybrid search, LangChain/LlamaIndex for orchestration, LangSmith for tracing, RAGAS for eval. Add caching layer for repeated queries, rate limiting, and graceful degradation when LLM is unavailable.

- **Q**: When would you self-host vs use an API?
- **A**: Self-host when: high volume (cost), privacy requirements (data governance), latency needs (no network hop), or need fine-tuned open models. Use API when: low volume, need best quality (GPT-5/Claude 4), fast iteration, no GPU infra.

---

## ★ Connections

| Relationship | Topics                                           |
| ------------ | ------------------------------------------------ |
| Builds on    | [[../llms/llms-overview]], [[../techniques/rag]] |
| Leads to     | Production GenAI systems, MLOps                  |
| Compare with | Traditional ML infra (MLflow, Kubeflow)          |
| Cross-domain | DevOps, Cloud architecture, Systems design       |

---

## ★ Sources

- LangChain documentation — https://docs.langchain.com
- LlamaIndex documentation — https://docs.llamaindex.ai
- vLLM documentation — https://docs.vllm.ai
- Ollama — https://ollama.com
- Hugging Face Hub — https://huggingface.co
