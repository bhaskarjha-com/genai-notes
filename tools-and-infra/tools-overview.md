---
title: "GenAI Tools & Infrastructure"
tags: [tools, infrastructure, langchain, llamaindex, vector-db, serving, genai]
type: reference
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../techniques/rag]]", "[[../techniques/ai-agents]]", "[[../llms/llms-overview]]", "[[cloud-ml-services]]", "[[distributed-systems-for-ai]]", "[[ml-experiment-tracking]]", "[[data-versioning-for-ml]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# GenAI Tools & Infrastructure

> âœ¨ **Bit**: The model is 10% of the work. The infrastructure around it is the other 90%. Welcome to production.

---

## â˜… TL;DR

- **What**: The ecosystem of frameworks, databases, serving engines, and platforms used to build GenAI applications
- **Why**: Knowing models is theory. Knowing the tooling is what gets you hired and makes things work in production.
- **Key point**: The stack is converging: Orchestration (LangChain/LlamaIndex) + Vector DB + Serving Engine + Observability

---

## â˜… Overview

### Definition

GenAI infrastructure encompasses everything between "I have a model" and "I have a production application" â€” orchestration frameworks, vector databases, model serving engines, evaluation tools, and observability platforms.

### Scope

This is the overview/index document. Deep dives on individual tools are in sub-documents:
- [Vector Databases](./vector-databases.md) - Pinecone, Weaviate, Qdrant, Chroma, pgvector
- [Cloud ML Services & Managed AI Platforms](./cloud-ml-services.md)
- [Distributed Systems Fundamentals for AI](./distributed-systems-for-ai.md)
- [ML Experiment Tracking](./ml-experiment-tracking.md)
- [Data Versioning for ML](./data-versioning-for-ml.md)
- For orchestration + RAG code, also see [Rag](../techniques/rag.md)

### Significance

- This is where **deep tech** separates from **wrapper dev**
- Understanding infra = you can architect systems, not just call APIs
- The layer where most production problems live (latency, cost, reliability)

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) â€” what you're serving/orchestrating
- [Rag](../techniques/rag.md) â€” primary use case for most tools

---

## â˜… Deep Dive

### The GenAI Application Stack

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    APPLICATION LAYER                         â”‚
â”‚  Chat UI â”‚ API Endpoints â”‚ Slack/Teams Bot â”‚ Internal Tools  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                    ORCHESTRATION LAYER                       â”‚
â”‚  LangChain â”‚ LlamaIndex â”‚ Semantic Kernel â”‚ Custom Code     â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚   RETRIEVAL          â”‚         GENERATION                    â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚ Vector DB      â”‚  â”‚  â”‚ Model API / Self-hosted LLM    â”‚  â”‚
â”‚  â”‚ (Pinecone,     â”‚  â”‚  â”‚ (OpenAI, Anthropic, vLLM,      â”‚  â”‚
â”‚  â”‚  Weaviate,     â”‚  â”‚  â”‚  Ollama, TGI)                  â”‚  â”‚
â”‚  â”‚  Qdrant)       â”‚  â”‚  â”‚                                â”‚  â”‚
â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤  â”‚  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤  â”‚
â”‚  â”‚ Embedding      â”‚  â”‚  â”‚ Guardrails / Safety            â”‚  â”‚
â”‚  â”‚ Models         â”‚  â”‚  â”‚ (NeMo, Guardrails AI)          â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                    OBSERVABILITY & EVAL                      â”‚
â”‚  LangSmith â”‚ Weights & Biases â”‚ Phoenix â”‚ RAGAS â”‚ DeepEval  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                    COMPUTE / INFRA                           â”‚
â”‚  GPU Cloud (AWS, GCP, Azure) â”‚ Serverless â”‚ On-prem         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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
"I need a quick RAG prototype"       â†’ LlamaIndex
"I need complex agent workflows"     â†’ LangGraph
"I need maximum flexibility/control" â†’ LangChain
"I'm in the Microsoft ecosystem"     â†’ Semantic Kernel
"I want minimal abstraction"         â†’ Direct API calls + custom code
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

## â—† Types & Classifications

### By Deployment Pattern

```
How to Serve LLMs
â”œâ”€â”€ API (Managed)
â”‚   â”œâ”€â”€ Direct: OpenAI, Anthropic, Google APIs
â”‚   â””â”€â”€ Aggregator: Together AI, Fireworks, Replicate
â”‚
â”œâ”€â”€ Self-Hosted (Your Infra)
â”‚   â”œâ”€â”€ vLLM / TGI (GPU server)
â”‚   â”œâ”€â”€ Ollama (local dev)
â”‚   â””â”€â”€ llama.cpp (CPU/edge)
â”‚
â””â”€â”€ Hybrid
    â”œâ”€â”€ Cloud GPU (RunPod, Lambda, AWS)
    â””â”€â”€ On-prem + cloud burst
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

## â—† Quick Reference

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

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Framework lock-in**: LangChain abstractions are convenient but can hide important details. Understand what's happening underneath.
- âš ï¸ **"Just use the API" at scale**: At 1M+ tokens/day, API costs can be $1000+/month. Do the math before committing.
- âš ï¸ **Ignoring evaluation**: Most teams ship GenAI without measuring quality. Build eval into your pipeline from day 1.
- âš ï¸ **Ollama in production**: Ollama is for dev, not production serving. Use vLLM or TGI for production workloads.
- âš ï¸ **Vector DB hype**: For < 100K documents, pgvector (Postgres extension) is probably enough. Don't over-architect.

---

## â—‹ Interview Angles

- **Q**: How would you architect a production RAG system?
- **A**: LLM via API (with fallback), vector DB (Qdrant/Pinecone) with hybrid search, LangChain/LlamaIndex for orchestration, LangSmith for tracing, RAGAS for eval. Add caching layer for repeated queries, rate limiting, and graceful degradation when LLM is unavailable.

- **Q**: When would you self-host vs use an API?
- **A**: Self-host when: high volume (cost), privacy requirements (data governance), latency needs (no network hop), or need fine-tuned open models. Use API when: low volume, need best quality (GPT-5/Claude 4), fast iteration, no GPU infra.

---

## â˜… Connections

| Relationship | Topics                                           |
| ------------ | ------------------------------------------------ |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Rag](../techniques/rag.md) |
| Leads to     | Production GenAI systems, MLOps                  |
| Compare with | Traditional ML infra (MLflow, Kubeflow)          |
| Cross-domain | DevOps, Cloud architecture, Systems design       |

---

## â˜… Sources

- LangChain documentation â€” https://docs.langchain.com
- LlamaIndex documentation â€” https://docs.llamaindex.ai
- vLLM documentation â€” https://docs.vllm.ai
- Ollama â€” https://ollama.com
- Hugging Face Hub â€” https://huggingface.co
