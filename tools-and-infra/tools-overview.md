---
title: "GenAI Tools & Infrastructure"
aliases: ["AI Tools", "LangChain", "LlamaIndex"]
tags: [tools, infrastructure, langchain, llamaindex, vector-db, serving, genai]
type: reference
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../techniques/rag.md", "../agents/ai-agents.md", "../llms/llms-overview.md", "cloud-ml-services.md", "distributed-systems-for-ai.md", "ml-experiment-and-data-management.md"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-12
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

GenAI infrastructure encompasses everything between "I have a model" and "I have a production application" â€” orchestration frameworks, vector databases, model serving engines, evaluation tools, and observability platforms.

### Scope

This is the overview/index document. Deep dives on individual tools are in sub-documents:
- [Vector Databases](./vector-databases.md) - Pinecone, Weaviate, Qdrant, Chroma, pgvector
- [Cloud ML Services & Managed AI Platforms](./cloud-ml-services.md)
- [Distributed Systems Fundamentals for AI](./distributed-systems-for-ai.md)
- [ML Experiment & Data Management](./ml-experiment-and-data-management.md)
- [ML Experiment & Data Management](./ml-experiment-and-data-management.md)
- For orchestration + RAG code, also see [Rag](../techniques/rag.md)

### Significance

- This is where **deep tech** separates from **wrapper dev**
- Understanding infra = you can architect systems, not just call APIs
- The layer where most production problems live (latency, cost, reliability)

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) â€” what you're serving/orchestrating
- [Rag](../techniques/rag.md) â€” primary use case for most tools

---

## ★ Deep Dive

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

- âš ï¸ **Framework lock-in**: LangChain abstractions are convenient but can hide important details. Understand what's happening underneath.
- âš ï¸ **"Just use the API" at scale**: At 1M+ tokens/day, API costs can be $1000+/month. Do the math before committing.
- âš ï¸ **Ignoring evaluation**: Most teams ship GenAI without measuring quality. Build eval into your pipeline from day 1.
- âš ï¸ **Ollama in production**: Ollama is for dev, not production serving. Use vLLM or TGI for production workloads.
- âš ï¸ **Vector DB hype**: For < 100K documents, pgvector (Postgres extension) is probably enough. Don't over-architect.

---

## ○ Interview Angles

- **Q**: How would you architect a production RAG system?
- **A**: LLM via API (with fallback), vector DB (Qdrant/Pinecone) with hybrid search, LangChain/LlamaIndex for orchestration, LangSmith for tracing, RAGAS for eval. Add caching layer for repeated queries, rate limiting, and graceful degradation when LLM is unavailable.

- **Q**: When would you self-host vs use an API?
- **A**: Self-host when: high volume (cost), privacy requirements (data governance), latency needs (no network hop), or need fine-tuned open models. Use API when: low volume, need best quality (GPT-5/Claude 4), fast iteration, no GPU infra.

---

## ★ Code & Implementation

### LangChain vs Direct API Comparison

```python
# pip install openai>=1.60 langchain>=0.2 langchain-openai>=0.1
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, langchain>=0.2, OPENAI_API_KEY

# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â DIRECT OPENAI API (recommended for simple cases) Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
from openai import OpenAI
client = OpenAI()

def direct_rag(query: str, docs: list[str]) -> str:
    context = "\n\n".join(docs)
    return client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": f"Answer from context:\n{context}"},
            {"role": "user",   "content": query},
        ],
        max_tokens=200,
    ).choices[0].message.content

# Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â LANGCHAIN (for complex pipelines, RAG chains, agents) Ã¢â€¢ÂÃ¢â€¢ÂÃ¢â€¢Â
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage

lc_model = ChatOpenAI(model="gpt-4o-mini", temperature=0)

def langchain_call(query: str) -> str:
    messages = [
        SystemMessage(content="You are a concise assistant."),
        HumanMessage(content=query),
    ]
    return lc_model.invoke(messages).content

# Compare outputs
docs = ["RAG combines retrieval with LLM generation to ground answers in real context."]
print("Direct:", direct_rag("What is RAG?", docs))
print("LangChain:", langchain_call("What is RAG in one sentence?"))
# Key insight: direct API = less abstraction, fewer deps, easier debugging
# LangChain = worth it when you need: memory, chains, agents, callbacks
```

## ★ Connections

| Relationship | Topics                                                                 |
| ------------ | ---------------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Rag](../techniques/rag.md) |
| Leads to     | Production GenAI systems, MLOps                                        |
| Compare with | Traditional ML infra (MLflow, Kubeflow)                                |
| Cross-domain | DevOps, Cloud architecture, Systems design                             |


---

## ◆ Production Failure Modes

| Failure                     | Symptoms                                                   | Root Cause                                   | Mitigation                                                      |
| --------------------------- | ---------------------------------------------------------- | -------------------------------------------- | --------------------------------------------------------------- |
| **Tool sprawl**             | Team uses 5 different experiment trackers, no standard     | No standardized toolchain decision           | Document standard stack, enforce via CI/CD templates            |
| **Version incompatibility** | LangChain update breaks production pipeline                | No pinned dependencies, no integration tests | Pin versions, test upgrades in staging, use lockfiles           |
| **Framework lock-in**       | Cannot switch from LangChain to LlamaIndex without rewrite | Tight coupling to framework internals        | Abstract LLM calls behind interface, minimize framework surface |

---

## ◆ Hands-On Exercises

### Exercise 1: Evaluate a GenAI Stack

**Goal**: Assess and document a complete GenAI toolchain for a use case
**Time**: 30 minutes
**Steps**:
1. Pick a use case (e.g., internal knowledge assistant)
2. Select tools for each layer: LLM, embedding, vector DB, orchestration, serving
3. Document tradeoffs for each selection (cost, lock-in, maturity)
4. Create a stack diagram with version pins
**Expected Output**: One-page stack decision document with rationale
---


## ★ Recommended Resources

| Type       | Resource                                                 | Why                                         |
| ---------- | -------------------------------------------------------- | ------------------------------------------- |
| ðŸ“˜ Book     | "AI Engineering" by Chip Huyen (2025)                    | Covers the full AI tooling landscape        |
| ðŸ”§ Hands-on | [HuggingFace Ecosystem](https://huggingface.co/)         | Central hub for models, datasets, and tools |
| ðŸ”§ Hands-on | [LangChain Documentation](https://python.langchain.com/) | Comprehensive LLM application framework     |

## ★ Sources

- LangChain documentation â€” https://docs.langchain.com
- LlamaIndex documentation â€” https://docs.llamaindex.ai
- vLLM documentation â€” https://docs.vllm.ai
- Ollama â€” https://ollama.com
- Hugging Face Hub â€” https://huggingface.co
