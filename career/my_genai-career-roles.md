---
title: "GenAI Career Roles — Master Reference (March 2026)"
tags: [career, job-roles, genai, ai-engineer, llm-engineer, rag-engineer, salary, skills, genai-career]
type: reference
difficulty: beginner
status: active
parent: "[[../genai]]"
source: "LinkedIn, Indeed, Glassdoor, web research — March 2026"
created: 2026-03-22
updated: 2026-03-22
---

# GenAI Career Roles — Master Reference

> ✨ **Bit**: "AI Engineer" was LinkedIn's #1 fastest-growing job title in 2026 (143% YoY growth). This document covers **27 roles** across a **6-layer AI stack** — from Application (easiest entry) to Infrastructure & Hardware (highest pay). Salary data for both US and India.
>
> **Note on "AI/ML Developer"**: This is NOT a distinct job role. It's used interchangeably with "AI Engineer" or "ML Engineer" in job postings. If you see "AI/ML Developer" on a job board, read the JD — it maps to one of the roles below.

---

## ★ Role Index by Layer (27 roles — quick lookup)

| Layer | Roles |
|-------|-------|
| **L6 — Application** | [23] Full-Stack AI Eng · [24] AI Integration Eng · [25] AI Consultant · [9] AI PM · [26] Conversational AI Eng |
| **L5 — Orchestration** | [1] AI Engineer · [2] GenAI Engineer · [13] Agentic AI Eng · [6] Prompt Engineer · [7] AI Architect · [22] AI DevTools Eng |
| **L4 — Fine-tuning** | [3] LLM Engineer · [4] RAG Engineer · [8] AI Data Eng · [15] NLP Engineer · [27] Data Scientist · [17] AI Safety Eng |
| **L3 — Inference** | [5] MLOps/LLMOps · [11] ML Engineer · [16] Inference Opt Eng |
| **L2 — Foundation** | [19] Foundation Model Eng · [18] AI Research Scientist · [12] Applied Scientist |
| **L1 — Infrastructure** | [20] AI Infra/Platform Eng · [21] AI Compiler/Kernel Eng |
| **Cross-cutting** | [10] AI Ethics & Governance · [14] CV Engineer |

## ★ The Core 10 Roles You Should Target

Based on the 40-topic GenAI knowledge base, here are the initial roles your skillset maps to, followed by 17 additional roles across the full AI stack:

```
PURE ENGINEERING ──────────────────────────────── STRATEGIC
  │                                                    │
  LLM Engineer                          AI Solutions Architect
  RAG Engineer                          AI Product Manager
  GenAI Engineer                        AI Ethics & Governance
  MLOps/LLMOps Engineer                 AI Consultant
  AI Engineer                           Prompt Engineer
  AI Data Engineer
```

---

## ★ Role-by-Role Breakdown

### 1. AI Engineer (Fastest Growing — #1 on LinkedIn 2026)

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5-6 (Orchestration / Application) |
| **What you do** | Design, build, and deploy AI-powered features. Orchestrate LLMs, agents, and multi-model systems into production applications. |
| **Key responsibilities** | Build AI pipelines, integrate LLMs into products, manage multi-agent workflows, evaluate model quality, optimize cost/latency |
| **Must-have skills** | Python, PyTorch/TensorFlow, LLM APIs (OpenAI/Gemini/Claude), RAG, prompt engineering, Docker/K8s, Git |
| **Nice-to-have** | Fine-tuning (LoRA/QLoRA), agentic frameworks (LangGraph, CrewAI), MCP/A2A protocols, cloud (AWS/GCP/Azure) |
| **Salary (US)** | Entry: $100-140K · Mid: $140-211K · Senior: $195-350K+ |
| **Salary (India)** | Entry: ₹5-12 LPA · Mid: ₹18-32 LPA · Senior: ₹35-60+ LPA |
| **Your coverage** | ██████████ **95%** — covers all required skills |
| **Hiring companies** | Every tech company, SaaS startups, enterprise AI teams, FAANG |
| **Availability** | 🟢 Very high — LinkedIn's #1 fastest-growing title |
| **Gap to fill** | None for entry; for senior: cloud architecture depth, system design |

---

### 2. Generative AI Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5 (Orchestration) |
| **What you do** | Build enterprise-grade GenAI solutions end-to-end. Design RAG systems, fine-tune models, build agent architectures, deploy to production. |
| **Key responsibilities** | RAG pipelines, LLM integration, prompt engineering, fine-tuning, model evaluation, building AI agents, production deployment |
| **Must-have skills** | Python, LLM APIs, RAG (chunking, embedding, vector DBs), prompt engineering, LangChain/LlamaIndex, evaluation metrics |
| **Nice-to-have** | Graph RAG, agentic protocols (MCP/A2A/ADK), Unsloth/Axolotl for fine-tuning, multimodal AI |
| **Salary (US)** | Entry: $120-160K · Mid: $180-250K · Senior: $220-350K+ |
| **Salary (India)** | Entry: ₹8-15 LPA · Mid: ₹25-45 LPA · Senior: ₹50-80+ LPA |
| **Your coverage** | ██████████ **98%** — this is your strongest match |
| **Hiring companies** | Google, Meta, Microsoft, Amazon, Anthropic, AI startups, consulting firms |
| **Availability** | 🟢 High — exploding demand across all sectors |
| **Gap to fill** | Hands-on production projects; for senior: distributed systems |

---

### 3. LLM Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 4-5 (Fine-tuning / Orchestration) |
| **What you do** | Specialize in building, fine-tuning, evaluating, and deploying LLM-based applications. System designer who integrates foundation models into products. |
| **Key responsibilities** | Fine-tuning (LoRA, QLoRA, DPO), model evaluation, hallucination mitigation, latency/cost optimization, inference serving, model selection |
| **Must-have skills** | Transformer architecture, fine-tuning techniques, tokenization, inference optimization (quantization, KV-cache), evaluation benchmarks |
| **Nice-to-have** | Training infrastructure (multi-GPU), scaling laws, RLHF/GRPO, distillation, custom tokenizers |
| **Salary (US)** | Mid: $180-260K · Senior: $240-400K+ |
| **Salary (India)** | Mid: ₹20-40 LPA · Senior: ₹40-70+ LPA |
| **Your coverage** | ██████████ **95%** — strong on foundations, fine-tuning, and inference |
| **Hiring companies** | OpenAI, Anthropic, Google, Cohere, AI21 Labs, Hugging Face, enterprise AI |
| **Availability** | 🟡 Medium-high — growing fast, more specialized than AI Engineer |
| **Gap to fill** | Multi-GPU training hands-on, CUDA basics, distributed inference |

---

### 4. RAG Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 4-5 (Fine-tuning / Orchestration) |
| **What you do** | Build intelligent search and synthesis systems. Connect LLMs to external knowledge via embeddings, vector databases, and retrieval pipelines. |
| **Key responsibilities** | Document processing, chunking strategies, embedding pipelines, vector DB management, hybrid search (BM25 + semantic), re-ranking, RAG evaluation |
| **Must-have skills** | Embeddings (text-embedding-3-large, Gemini Embedding 2), vector DBs (Pinecone, Weaviate, Chroma, pgvector), chunking, RAGAS metrics |
| **Nice-to-have** | Graph RAG, agentic RAG, multimodal RAG, context caching, query transformation, privacy-preserving techniques |
| **Salary (US)** | Mid: $150-220K · Senior: $200-300K+ |
| **Salary (India)** | Mid: ₹18-35 LPA · Senior: ₹35-60+ LPA |
| **Your coverage** | ██████████ **98%** — RAG, Graph RAG, embeddings, vector DBs all covered in depth |
| **Hiring companies** | Enterprise AI teams, SaaS companies, consulting firms, legal/finance AI |
| **Availability** | 🟡 Medium-high — every enterprise needs RAG for internal knowledge |
| **Gap to fill** | Production-scale RAG deployment, latency optimization, cost engineering |

---

### 5. MLOps / LLMOps Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 3 (Inference & Serving) |
| **What you do** | Ensure AI/LLM systems run reliably in production. Deployment, monitoring, cost optimization, guardrails, and incident response. |
| **Key responsibilities** | Model deployment, CI/CD for ML, monitoring & observability (LangSmith, Arize Phoenix), prompt versioning, guardrails, cost controls, scaling |
| **Must-have skills** | Docker, Kubernetes, CI/CD, cloud platforms (AWS/GCP/Azure), monitoring tools, Python, API development (FastAPI) |
| **Nice-to-have** | LLM evaluation strategies, RAG system monitoring, semantic caching, A/B testing for models, Terraform/IaC |
| **Salary (US)** | Mid: $140-200K · Senior: $180-280K+ |
| **Salary (India)** | Mid: ₹15-30 LPA · Senior: ₹30-55+ LPA |
| **Your coverage** | ████████░░ **80%** — strong on LLMOps concepts, eval; lighter on DevOps infra specifics |
| **Hiring companies** | Cloud providers, SaaS companies, ML-heavy enterprises, AI startups |
| **Availability** | 🟢 Very high — every production AI team needs MLOps |
| **Gap to fill** | Docker/K8s hands-on, Terraform, CI/CD pipeline building, cloud certs |

---

### 6. Prompt Engineer / AI Interaction Specialist

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5-6 (Orchestration / Application) |
| **What you do** | Craft, test, and optimize prompts and agent instructions. Bridge between human intent and LLM execution. |
| **Key responsibilities** | Prompt design (zero-shot, few-shot, CoT), structured output (JSON), reducing hallucinations, multi-step workflows, agent-based prompting, testing |
| **Must-have skills** | Deep LLM understanding, prompt patterns, function calling, structured output, evaluation methods |
| **Nice-to-have** | Python scripting, RAG integration, tool/function calling, prompt playgrounds, LangChain/LlamaIndex |
| **Salary (US)** | Entry: $80-120K · Mid: $120-180K · Senior: $160-250K |
| **Salary (India)** | Entry: ₹5-10 LPA · Mid: ₹15-30 LPA · Senior: ₹30-50+ LPA |
| **Your coverage** | ██████████ **100%** — prompt engineering, context engineering, function calling, agents all deeply covered |
| **Hiring companies** | OpenAI, Anthropic, consulting firms, legal/healthcare AI, enterprise AI |
| **Availability** | 🟢 High — though evolving into broader AI/GenAI Eng roles |
| **Gap to fill** | None — this is your strongest match |

---

### 7. AI Solutions Architect

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5-6 (Orchestration / Application) |
| **What you do** | Design enterprise AI architectures. Connect business goals with practical AI systems. Select frameworks, tools, and define blueprints. |
| **Key responsibilities** | Solution design, tech stack selection, scalability planning, cost modeling, vendor evaluation, team mentoring, stakeholder communication |
| **Must-have skills** | Broad AI/ML knowledge, cloud architecture (AWS/GCP/Azure), system design, LLM systems, RAG, agents, MLOps understanding |
| **Nice-to-have** | Multi-agent architecture, MCP/A2A protocols, security & compliance, enterprise integration patterns |
| **Salary (US)** | Mid: $160-230K · Senior: $200-320K+ |
| **Salary (India)** | Mid: ₹25-45 LPA · Senior: ₹45-75+ LPA |
| **Your coverage** | ████████░░ **85%** — excellent technical breadth; would benefit from cloud architecture depth |
| **Experience typically needed** | 5+ years software engineering + 2+ years AI/ML |
| **Hiring companies** | Cloud providers (AWS/GCP/Azure), consulting firms, large enterprises |
| **Availability** | 🟡 Medium — senior role, less entry-level |
| **Gap to fill** | Cloud architecture certs, enterprise integration patterns, system design interviews |

---

### 8. AI Data Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 4 (Fine-tuning & Evaluation) |
| **What you do** | Design data architecture for AI/ML/GenAI. Ensure data is trusted, secure, and AI-ready. Build data pipelines for LLM training and RAG. |
| **Key responsibilities** | Data pipelines, ETL/ELT for AI, data quality, embedding generation at scale, synthetic data pipelines, data governance |
| **Must-have skills** | Python, SQL, data engineering tools (Spark, Airflow), cloud data services, embeddings, vector DBs |
| **Nice-to-have** | Synthetic data generation, data labeling pipelines, privacy-preserving techniques, data versioning |
| **Salary (US)** | Mid: $130-190K · Senior: $175-260K+ |
| **Salary (India)** | Mid: ₹15-28 LPA · Senior: ₹28-50+ LPA |
| **Your coverage** | ██████░░░░ **65%** — strong on embeddings, synthetic data, RAG data; lighter on traditional data engineering tools |
| **Hiring companies** | Data-heavy enterprises, fintech, healthcare, e-commerce, AI startups |
| **Availability** | 🟢 High — every AI project needs data infrastructure |
| **Gap to fill** | Spark, Airflow, dbt, SQL optimization, data pipeline design at scale |

---

### 9. AI Product Manager

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 6 (Application) |
| **What you do** | Define vision for AI products. Prioritize features, manage stakeholders, translate business needs to AI capabilities. |
| **Key responsibilities** | Product roadmap, feature prioritization, user research, AI capability assessment, go-to-market, metrics definition |
| **Must-have skills** | Understanding of AI/LLM capabilities and limitations, product thinking, user research, stakeholder management |
| **Nice-to-have** | Hands-on prompt engineering, RAG understanding, evaluation metrics knowledge, competitive landscape awareness |
| **Salary (US)** | Mid: $150-220K · Senior: $200-300K+ |
| **Salary (India)** | Mid: ₹20-40 LPA · Senior: ₹40-70+ LPA |
| **Your coverage** | ██████░░░░ **60%** — strong AI literacy; would need product management methodology |
| **Hiring companies** | Every tech company, SaaS, enterprise, AI startups |
| **Availability** | 🟢 High — strong demand for AI-literate PMs |
| **Gap to fill** | Product management methodology, user research, go-to-market strategy |

---

### 10. AI Ethics & Governance Lead

| Aspect | Details |
|--------|---------|
| **Stack layer** | Cross-cutting (all layers) |
| **What you do** | Ensure responsible, compliant, ethical AI deployment. Audit for bias, enforce data privacy, navigate regulations (EU AI Act). |
| **Key responsibilities** | Bias auditing, fairness metrics, compliance (EU AI Act, CCPA), red teaming coordination, guardrail design, policy development |
| **Must-have skills** | AI safety, alignment (RLHF/DPO), bias detection, regulatory knowledge, stakeholder communication |
| **Nice-to-have** | Technical AI background, evaluation benchmarks, LLM vulnerability research, content moderation systems |
| **Salary (US)** | Mid: $140-200K · Senior: $180-280K+ |
| **Salary (India)** | Mid: ₹18-35 LPA · Senior: ₹35-60+ LPA |
| **Your coverage** | ████████░░ **75%** — strong on alignment and safety; would need regulatory/legal depth |
| **Hiring companies** | Anthropic, OpenAI, Google, Microsoft, govt agencies, regulated industries |
| **Availability** | 🟡 Medium — growing with AI regulation (EU AI Act) |
| **Gap to fill** | Regulatory law, compliance frameworks, enterprise policy writing |

---

## ★ Skills × Roles Matrix (by Stack Layer)

Which knowledge base topics map to which roles. Use this to prioritize study for your target role.

### Layer 6 Roles: Application Layer

| Knowledge Area | Full-Stack AI Eng | AI Integration Eng | AI Consultant | AI PM | AI Ethics |
|---|:---:|:---:|:---:|:---:|:---:|
| **RAG** | ● | ● | ● | ○ | ○ |
| **Prompt Engineering** | ● | ● | ● | ○ | ○ |
| **Function Calling & Structured** | ● | ● | ○ | | |
| **LLMs Overview** | ● | ● | ● | ● | ● |
| **LLM Landscape & Selection** | ○ | ○ | ● | ● | |
| **AI Agents** | ● | ○ | ○ | ○ | ○ |
| **Ethics, Safety & Alignment** | ○ | ○ | ○ | ○ | ● |
| **Evaluation & Benchmarks** | ○ | ○ | ○ | ○ | ○ |

### Layer 5 Roles: Orchestration Layer

| Knowledge Area | AI Eng | GenAI Eng | Agentic AI | Prompt Eng | AI Architect | AI DevTools |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Transformers & Attention** | ● | ● | ○ | ○ | ● | ○ |
| **RAG** | ● | ● | ○ | ○ | ● | |
| **Graph RAG** | ○ | ● | | | ● | |
| **Prompt Engineering** | ● | ● | ○ | ● | ○ | ● |
| **Context Engineering** | ● | ● | ● | ● | ● | ● |
| **Function Calling** | ● | ● | ● | ● | ○ | ○ |
| **AI Agents** | ● | ● | ● | ○ | ● | ○ |
| **Agentic Protocols (MCP/A2A)** | ● | ● | ● | | ● | ○ |
| **Code Generation Tools** | ● | ● | | | ○ | ● |
| **Multimodal AI** | ● | ● | ○ | ○ | ● | |
| **LLMOps** | ● | ● | ○ | | ● | ○ |
| **Evaluation & Benchmarks** | ● | ● | ○ | ○ | ● | ○ |

### Layer 4 Roles: Fine-tuning & Evaluation Layer

| Knowledge Area | LLM Eng | RAG Eng | NLP Eng | Conv AI | Data Eng | Data Sci | AI Safety |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Transformers & Attention** | ● | ○ | ● | ○ | | ● | |
| **Tokenization** | ● | ○ | ● | | | | |
| **Embeddings** | ● | ● | ● | | ● | ○ | |
| **Fine-tuning (LoRA/QLoRA)** | ● | | ○ | | | ○ | |
| **RL Alignment (RLHF/DPO)** | ● | | | | | | ● |
| **RAG** | ○ | ● | ○ | | ● | ○ | |
| **Vector Databases** | | ● | | | ● | | |
| **Voice AI** | | | ○ | ● | | | |
| **Evaluation & Benchmarks** | ● | ● | ● | | | ● | ● |
| **Synthetic Data** | ○ | | | | ● | ○ | |
| **Ethics, Safety & Alignment** | | | | | | | ● |

### Layer 3 Roles: Inference & Serving Layer

| Knowledge Area | MLOps/LLMOps | Inference Opt | ML Engineer |
|---|:---:|:---:|:---:|
| **Transformers & Attention** | ○ | ● | ● |
| **Distillation & Compression** | ○ | ● | ○ |
| **Scaling Laws** | | ○ | ○ |
| **Inference Optimization** | ● | ● | ○ |
| **Fine-tuning (LoRA/QLoRA)** | ○ | ○ | ● |
| **LLMOps** | ● | ○ | ○ |
| **Evaluation & Benchmarks** | ● | ○ | ● |

### Layer 1-2 Roles: Foundation Model & Infrastructure Layer

| Knowledge Area | Foundation Model | AI Infra | AI Compiler | Research Scientist |
|---|:---:|:---:|:---:|:---:|
| **Transformers & Attention** | ● | | | ● |
| **Scaling Laws & Pre-training** | ● | ○ | | ● |
| **Modern Architectures (MoE)** | ● | | ○ | ● |
| **RL Alignment (RLHF/DPO)** | ○ | | | ● |
| **Distillation & Compression** | ○ | | ● | ○ |
| **Inference Optimization** | ○ | ○ | ● | |
| **Continual Learning** | ● | | | ● |

**Legend**: ● = Core (must know)    ○ = Valuable (good to know)    blank = not required

---

## ★ Your Top 5 Best-Fit Roles

Ranked by knowledge base coverage — these are the roles you can apply to **right now**:

| Rank | Role | Coverage | Layer | Why |
|------|------|:---:|:---:|-----|
| **1** | **Prompt Engineer** | 100% | L5-6 | Context engineering, function calling, structured output — fully covered |
| **2** | **Generative AI Engineer** | 98% | L5 | RAG, agents, fine-tuning, evaluation — your strongest technical match |
| **3** | **RAG Engineer** | 98% | L4-5 | RAG, Graph RAG, embeddings, vector DBs — comprehensive depth |
| **4** | **AI Engineer** | 95% | L5-6 | Broadest role; your knowledge covers every requirement |
| **5** | **AI Integration Engineer** | 90% | L6 | RAG, prompt eng, function calling — high job volume, easiest entry |

**Honorable mentions** (90%): Agentic AI Engineer, LLM Engineer (95%)

### Roles Where You Need Supplemental Skills

| Role | Gap | What to Add |
|------|-----|-------------|
| Full-Stack AI Engineer | Frontend engineering | React/Next.js, TypeScript, full-stack web dev |
| MLOps/LLMOps Engineer | DevOps infrastructure | Docker, Kubernetes, Terraform, CI/CD hands-on |
| ML Engineer | Classical ML + DSA | scikit-learn, XGBoost, LeetCode |
| AI Solutions Architect | Cloud architecture | AWS/GCP/Azure certs, system design practice |
| AI Data Engineer | Data engineering tools | Spark, Airflow, dbt, data pipeline design |
| AI DevTools Engineer | SDK/DX | TypeScript, VS Code extension dev, SDK design |
| Inference Opt. Engineer | Systems programming | C++, CUDA, GPU profiling, vLLM internals |
| Conversational AI Eng | Dialogue systems | ASR/TTS, Dialogflow, dialogue state tracking |
| Data Scientist (GenAI) | Classical stats | Bayesian methods, scikit-learn, R, data viz |
| Foundation Model Eng. | Deep systems | C++, CUDA, PyTorch internals, distributed training |
| AI Research Scientist | Research depth | PhD or equiv, paper writing, JAX, deep math |

---

## ★ Job Search Keywords (All 27 Roles)

Use these exact terms when searching job portals:

```
APPLY NOW (Layer 5-6 — highest match, most openings):
  "AI Engineer"                     "AI Integration Engineer"
  "Generative AI Engineer"          "Full Stack AI Engineer"
  "GenAI Developer"                 "AI Consultant"
  "AI Application Engineer"         "Applied AI Engineer"
  "Prompt Engineer"                 "AI Solutions Architect"
  "Conversational AI Engineer"      "AI Chatbot Developer"
  "Data Scientist" + GenAI/LLM      "AI Product Manager"

APPLY SOON (Layer 3-4 — strong match, need some upskilling):
  "LLM Engineer"                    "RAG Engineer"
  "Agentic AI Engineer"             "AI Agent Developer"
  "Context Engineer"                "AI DevTools Engineer"
  "Machine Learning Engineer" + GenAI
  "NLP Engineer" + LLM              "MLOps Engineer"
  "LLMOps Engineer"                 "AI Safety Engineer"
  "AI Red Team Engineer"            "AI Data Engineer"

ASPIRATIONAL (Layer 1-2 — upskill first):
  "Foundation Model Engineer"       "Pre-training Engineer"
  "ML Platform Engineer"            "AI Infrastructure Engineer"
  "Inference Optimization"          "AI Compiler Engineer"
  "AI Research Scientist"           "Applied Scientist"

SEARCH ON:
  LinkedIn Jobs     → Best for US/remote roles
  Indeed            → Volume of listings
  Naukri.com        → India-specific roles
  Wellfound         → Startup roles
  ai-jobs.net       → AI-specific job board
  remoteok.com      → Remote AI positions
  greenhouse.io jobs → Direct from Anthropic, OpenAI, etc.
```

---

> **Note**: The full 27-role salary table is in the **Expanded Salary Table** section below. Silicon Valley / Bengaluru pay 20-50% above averages. FAANG/startups add significant equity on top.

---

## ★ Interview Preparation Map

Priority docs per interview round, organized by stack layer:

### Layer 6 Roles (Full-Stack AI, AI Integration, AI Consultant, AI PM)

```
SCREENING: LLM APIs, RAG basics, prompt engineering
TECHNICAL: System design for AI apps, API integration, streaming
CODING: Build a RAG chatbot, integrate LLM API, full-stack project
Docs: rag, prompt-engineering, function-calling, context-engineering
```

### Layer 5 Roles (GenAI Eng, AI Eng, Agentic AI, AI DevTools, Prompt Eng)

```
SCREENING: RAG vs fine-tuning, model selection, tokenization, embeddings
TECHNICAL DEEP DIVE: Attention mechanism, test-time compute, agent
  architectures, MCP/A2A protocols, Graph RAG vs Vector RAG
SYSTEM DESIGN: Design a RAG system, cost optimization, agent orchestration
CODING: LangChain/LlamaIndex, multi-agent workflow, function calling
Docs: transformers, reasoning-models, ai-agents, graph-rag, llmops
```

### Layer 4 Roles (LLM Eng, RAG Eng, NLP Eng, Data Scientist, AI Safety)

```
SCREENING: Transformer internals, fine-tuning trade-offs, evaluation
TECHNICAL: LoRA/QLoRA details, quantization, KV-cache, RAG evaluation
SYSTEM DESIGN: RAG pipeline design, fine-tuning pipeline, cost modeling
CODING: Fine-tune a model (Unsloth), evaluation pipeline, RAG system
Docs: fine-tuning, rag, evaluation, tokenization, embeddings
```

### Layer 3 Roles (MLOps/LLMOps, Inference Optimization, ML Engineer)

```
SCREENING: Model deployment, serving infrastructure, latency optimization
TECHNICAL: vLLM, TensorRT, speculative decoding, K8s for ML, CI/CD
SYSTEM DESIGN: Model serving at scale, training pipelines, monitoring
CODING: Docker, K8s manifests, DSA (LeetCode), inference benchmarking
Docs: inference-optimization, llmops, scaling-laws
```

### Layer 2 Roles (Foundation Model Eng, Research Scientist, Applied Sci)

```
SCREENING: Distributed training, scaling laws, transformer architecture
TECHNICAL: Data/tensor/pipeline parallelism, ZeRO optimizer, MoE
RESEARCH: Present a paper, design a novel experiment, math proofs
CODING: PyTorch internals, distributed training code, experiment code
Docs: scaling-laws-and-pretraining, modern-architectures, transformers
```

### Layer 1 Roles (AI Infrastructure, AI Compiler/Kernel Engineer)

```
SCREENING: GPU architecture, CUDA, distributed systems, K8s
TECHNICAL: NCCL, NVLink, kernel fusion, compiler optimization, XLA
SYSTEM DESIGN: GPU cluster architecture, fault-tolerant training infra
CODING: C++, CUDA kernels, Go/Rust systems programming
Docs: inference-optimization (concepts), modern-architectures
```

### Cross-Cutting: Culture / Ethics Round (All Roles)

```
Docs: ethics-safety-alignment, rl-alignment
Topics: Bias mitigation, guardrails, EU AI Act, responsible AI, red teaming
```

---

## ★ The 6-Layer AI Stack — Where Every Role Lives

```
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 6: APPLICATION                                               │
│  Integrating AI into existing products, workflows, features         │
│  Roles: Full-Stack AI Eng, AI Integration Eng, AI Consultant,       │
│         AI PM, Conversational AI Eng                                │
│  Entry: Easiest to break into. Most job volume.                     │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 5: ORCHESTRATION & TOOLING                                   │
│  Building AI-native tools, agents, frameworks, SDKs                 │
│  Roles: GenAI Eng, AI Eng, Agentic AI Eng, AI DevTools Eng,        │
│         Prompt Eng, AI Solutions Architect                          │
│  Focus: Agent frameworks, MCP/A2A, developer experience             │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 4: FINE-TUNING & EVALUATION                                  │
│  Adapting models, building RAG, evaluating quality                   │
│  Roles: LLM Eng, RAG Eng, NLP Eng, Data Scientist (GenAI),         │
│         AI Safety/Red Team Eng, AI Data Eng                        │
│  Focus: LoRA/QLoRA, RAG pipelines, evaluation, embeddings           │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 3: INFERENCE & SERVING                                       │
│  Deploying, serving, monitoring models in production                │
│  Roles: MLOps/LLMOps Eng, Inference Opt Eng, ML Engineer            │
│  Focus: vLLM, TensorRT, K8s, CI/CD, monitoring, cost optimization  │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 2: FOUNDATION MODEL (your ultimate goal)                     │
│  Training models from scratch, architecture research                │
│  Roles: Foundation Model/Pre-Training Eng,                          │
│         AI Research Scientist, Applied Scientist                    │
│  Hardest: PhD preferred, deep math, fewest openings                │
├─────────────────────────────────────────────────────────────────────┤
│  LAYER 1: INFRASTRUCTURE & HARDWARE                                 │
│  GPU clusters, compilers, kernels, platform engineering             │
│  Roles: AI Infra/ML Platform Eng, AI Compiler/Kernel Eng            │
│  Deepest: C++/CUDA/Go required, systems programming                │
└─────────────────────────────────────────────────────────────────────┘

YOUR CAREER PATH (top → bottom):
  Start at Layer 6 (Application) → Build depth at Layers 5/4
  → Move to Layer 3 (Inference/Serving) → Specialize into Layers 2/1
```

### Where Your Knowledge Base Sits

| Layer | Your Coverage | Docs Covering This |
|-------|:---:|---|
| **Layer 6** (Application) | ██████████ **95%** | RAG, agents, prompt-eng, function-calling, context-eng |
| **Layer 5** (Orchestration) | █████████░ **90%** | Agents, MCP/A2A, code-generation, LLMOps |
| **Layer 4** (Fine-tuning) | ████████░░ **85%** | Fine-tuning, RAG, tokenization, evaluation, embeddings |
| **Layer 3** (Inference) | ███████░░░ **70%** | Inference-opt, LLMOps; need Docker/K8s/serving hands-on |
| **Layer 2** (Foundation) | █████░░░░░ **50%** | Transformers, scaling-laws, architectures; need distributed training |
| **Layer 1** (Infrastructure) | ███░░░░░░░ **25%** | Concepts only; need C++, CUDA, K8s, Go/Rust, systems programming |

---

## ★ Extended Roles — By Job Availability Tier

Beyond the core 10, here are 17 additional roles (8 by availability tier + 7 by stack layer + 2 specialized) you should target:

```
JOB AVAILABILITY TIERS (March 2026):

🟢 HIGH AVAILABILITY (1000s of openings)
  ├── Machine Learning Engineer          ← Most postings overall
  └── Applied AI / Applied Scientist     ← Every large company

🟡 MEDIUM AVAILABILITY (100s of openings, growing fast)
  ├── Agentic AI Engineer                ← 40% enterprise apps by end 2026
  └── Computer Vision / NLP Engineer     ← Specialized but steady

🔴 NICHE / ELITE (10s of openings, top pay)
  ├── Inference Optimization Engineer    ← NVIDIA, model serving cos
  ├── AI Safety / Red Team Engineer      ← Anthropic, OpenAI
  └── AI Research Scientist              ← Frontier labs only (PhD pref)
```

---

### 🟢 HIGH AVAILABILITY

#### 11. Machine Learning Engineer (Highest Volume of Job Postings)

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 3 (Inference & Serving) |
| **What you do** | Design, build, train, deploy, and maintain ML systems in production. Bridge between data science and software engineering. |
| **Key responsibilities** | Model development (training, tuning), data pipeline design, MLOps (versioning, monitoring, CI/CD), scaling models for millions of users, A/B testing |
| **Must-have skills** | Python, PyTorch/TensorFlow, scikit-learn, SQL, data structures & algorithms, cloud (AWS SageMaker/GCP Vertex AI/Azure ML), Git, Docker |
| **Nice-to-have** | GenAI/LLM fine-tuning, Spark, Kubernetes, C++, CUDA, feature stores, experiment tracking (MLflow, W&B) |
| **Salary (US)** | Entry: $96-132K · Mid: $149-200K · Senior: $175-240K · FAANG TC: $320-550K |
| **Salary (India)** | Entry: ₹8-15 LPA · Mid: ₹20-35 LPA · Senior: ₹35-60+ LPA |
| **Job growth** | 31% projected through 2030 (much faster than average). 3.2:1 demand-to-supply ratio. |
| **Your coverage** | ████████░░ **80%** |
| **Gap to fill** | Classical ML algorithms (XGBoost, SVMs), DSA practice (LeetCode), feature engineering |

---

#### 12. Applied AI Scientist / Applied Scientist

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 2-4 (Foundation / Fine-tuning) |
| **What you do** | Apply AI/ML research to real-world products. Found at Amazon, Microsoft, Apple, Meta. |
| **Must-have skills** | Python, PyTorch/TensorFlow, strong math, research methodology, experiment design |
| **Nice-to-have** | Publications, NLP/CV specialization, LLM engineering, RAG |
| **Salary (US)** | Mid: $150-220K · Senior: $200-300K+ · Staff: $280-400K+ |
| **Typical education** | Master's preferred; PhD for senior roles |
| **Your coverage** | ███████░░░ **70%** |
| **Gap to fill** | Bayesian methods, causal inference, experiment design, paper reading/writing |

---

### 🟡 MEDIUM AVAILABILITY (Fast Growing)

#### 13. Agentic AI Engineer / AI Agent Developer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5 (Orchestration) |
| **What you do** | Design and orchestrate autonomous AI agents. Gartner: 40% of enterprise apps embed agents by end 2026. |
| **Must-have skills** | Python, LangGraph/CrewAI/AutoGen, function calling, MCP/A2A, RAG, vector DBs, async programming |
| **Nice-to-have** | ADK (Google), OpenAI Agents SDK, agent observability, cost controls for autonomous systems |
| **Salary (US)** | Mid: $170-250K · Senior: $220-350K+ |
| **Hiring** | Apple, Disney, Salesforce, every enterprise building agent workflows |
| **Your coverage** | █████████░ **90%** — excellent match |
| **Gap to fill** | Hands-on multi-agent projects, agent evaluation frameworks |

---

#### 14. Computer Vision Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 4 (Fine-tuning & Evaluation) |
| **What you do** | Design algorithms for machines to "see" — image classification, object detection, video analysis. |
| **Must-have skills** | Python, PyTorch, CNNs, Vision Transformers (ViT), OpenCV, transfer learning |
| **Salary (US)** | Mid: $137-200K · Senior: $200-350K+ · Top 1%: $579K+ |
| **Your coverage** | ██████░░░░ **55%** |
| **Gap to fill** | CNNs, OpenCV, YOLO/DETR, 3D vision, edge deployment |

---

#### 15. NLP Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 4 (Fine-tuning & Evaluation) |
| **What you do** | Build language understanding systems. In 2026, overlaps heavily with LLM engineering. |
| **Must-have skills** | Python, PyTorch, Hugging Face, spaCy/NLTK, tokenization, embeddings, fine-tuning |
| **Salary (US)** | Mid: $130-200K · Senior: $180-280K+ |
| **Your coverage** | ████████░░ **85%** — very close match |
| **Gap to fill** | Hands-on spaCy/NLTK, multilingual tokenization, classical NLP metrics (BLEU, ROUGE) |

---

### 🔴 NICHE / ELITE (Highest Pay, Fewest Openings)

#### 16. Inference Optimization Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 3 (Inference & Serving) — deepest |
| **What you do** | Maximize throughput, minimize latency, cut cost of LLM inference. Most technically deep engineering role. |
| **Must-have skills** | Python, C/C++, CUDA, PyTorch internals, vLLM, TensorRT, ONNX Runtime, Triton Inference Server |
| **Salary (US)** | Mid: $167-209K · Senior: $200-350K+ · NVIDIA: $287K+ |
| **Hiring** | NVIDIA, Anyscale, Together AI, Fireworks AI, Modal, Groq |
| **Your coverage** | ██████░░░░ **60%** |
| **Gap to fill** | CUDA programming, C++, GPU profiling (Nsight), vLLM internals, kernel optimization |

---

#### 17. AI Safety / Red Team Engineer

| Aspect | Details |
|--------|---------|
| **Stack layer** | Cross-cutting (all layers) |
| **What you do** | Adversarially test AI for vulnerabilities. The "white hat hacker" of AI. |
| **Must-have skills** | Python, adversarial ML, prompt injection, OWASP, evaluation pipeline design |
| **Nice-to-have** | Pentesting (Burp Suite, Metasploit), RLHF/alignment, agent security |
| **Salary (US)** | Mid: $160-220K · Senior: $200-300K+ |
| **Hiring** | Anthropic, OpenAI, Google DeepMind, Microsoft |
| **Your coverage** | ████████░░ **75%** |
| **Gap to fill** | Pentesting, adversarial ML research, OWASP LLM Top 10, agent security |

---

#### 18. AI Research Scientist (Frontier Labs)

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 2 (Foundation Model) |
| **What you do** | Push boundaries. Publish at NeurIPS/ICML/ICLR. Create new architectures and breakthroughs. |
| **Must-have skills** | PhD (strongly preferred), deep math, PyTorch/JAX, experiment design, first-author publications |
| **Salary (US)** | Entry (PhD): $115-160K · Senior: $220-360K+ · Staff: $400K+ |
| **Hiring** | OpenAI, Google DeepMind, Anthropic, Meta FAIR, Microsoft Research |
| **Your coverage** | ██████░░░░ **55%** |
| **Gap to fill** | PhD or equivalent, paper writing, deep math, JAX, original research |

---

## ★ Stack-Layer Roles You Were Missing (7 New Roles)

These are the roles that didn't appear in our original 18 but are critical across the 6-layer stack:

### Layer 2: Foundation Model Layer

#### 19. Foundation Model / Pre-Training Engineer 🔴

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 2 (Foundation) — the deepest model role |
| **What you do** | Train LLMs from scratch. Architect data pipelines for pre-training, implement distributed training across GPU clusters, design training strategies. The people who build GPT-5, Gemini 3.1, LLaMA 4. |
| **Key responsibilities** | Data curation (dedup, toxicity filtering), model architecture design, distributed training (DP/TP/PP/ZeRO), training infrastructure, evaluation pipelines, checkpoint management |
| **Must-have skills** | Python, C++, PyTorch (internals), DeepSpeed/Megatron-LM/FSDP, distributed systems, CUDA, multi-GPU programming, transformer architecture |
| **Nice-to-have** | JAX, custom data loaders, tokenizer design, scaling law analysis, NVLink/InfiniBand networking |
| **Salary (US)** | Mid: $160-260K · Senior: $240-400K+ · LLM specialist: $209K base avg |
| **Salary (India)** | Senior: ₹40-80+ LPA (at frontier labs) |
| **Hiring companies** | OpenAI, Google DeepMind, Anthropic, Meta FAIR, Mistral, xAI, Cohere, Poolside AI |
| **Availability** | 🔴 Very few openings — elite role |
| **Your coverage** | ████░░░░░░ **40%** — scaling-laws and architectures docs help; need distributed training, CUDA, C++ |
| **Gap to fill** | PyTorch internals, DeepSpeed/Megatron-LM, distributed training (DP/TP/PP), CUDA, C++, data curation at scale |

---

#### 20. AI Infrastructure / ML Platform Engineer 🔴

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 1 (Infrastructure) |
| **What you do** | Build and maintain the infra that enables training and serving at scale. Kubernetes for GPU clusters, training pipelines, GPU scheduling, fault-tolerance. The backbone engineers. |
| **Key responsibilities** | K8s cluster management for GPU workloads, distributed training infrastructure, GPU scheduling/orchestration, storage systems for training data, monitoring/observability for training runs |
| **Must-have skills** | Python, Go/Rust, Kubernetes (advanced: CRDs, operators), Docker, CUDA ecosystem, cloud platforms (AWS/GCP/Azure), distributed systems, Linux internals |
| **Nice-to-have** | NCCL/RCCL, NVLink, InfiniBand, Terraform/IaC, Ray, Kubeflow, MLflow |
| **Salary (US)** | Mid: $140-220K · Senior: $192-288K+ · FAANG: $320K+ TC |
| **Salary (India)** | Mid: ₹20-40 LPA · Senior: ₹40-70+ LPA |
| **Hiring companies** | OpenAI, Google, AMD, NVIDIA, Anyscale, any company training large models |
| **Availability** | 🔴 Niche but growing — every serious AI lab needs platform engineers |
| **Your coverage** | ███░░░░░░░ **30%** — this is your biggest gap. Need K8s, Go/Rust, GPU infra, distributed systems |
| **Gap to fill** | Kubernetes (advanced), Go or Rust, GPU cluster management, distributed systems, Linux internals, IaC |

---

#### 21. AI Compiler / Kernel Engineer 🔴

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 1 (Infrastructure) — lowest level |
| **What you do** | Build compilers and kernels that make AI models run fast on hardware. Write custom CUDA kernels, work on XLA/Triton compiler, optimize graph execution. |
| **Key responsibilities** | Custom CUDA kernel development, compiler optimization (XLA, TVM, Triton), graph optimization, hardware-software co-design, kernel fusion, memory management |
| **Must-have skills** | C/C++, CUDA (deep expertise), compiler design, GPU architecture, assembly, PyTorch C++ extension, numerics |
| **Nice-to-have** | TPU programming, MLIR, Triton (OpenAI), hardware design knowledge |
| **Salary (US)** | Senior: $250-400K+ · NVIDIA Staff: $350K+ TC |
| **Salary (India)** | Senior: ₹45-80+ LPA |
| **Hiring companies** | NVIDIA, Google (XLA team), AMD, Intel, Modular AI |
| **Availability** | 🔴 Ultra-niche — highest expertise bar in all of AI |
| **Your coverage** | ██░░░░░░░░ **15%** — inference-optimization concepts help but this is systems programming |
| **Gap to fill** | C++, CUDA programming, compiler design, GPU architecture, assembly language |

---

### Layer 5: Orchestration Layer

#### 22. AI Developer Tools Engineer 🟡

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5 (Orchestration) |
| **What you do** | Build AI-powered developer tools (IDEs, CLI tools, copilots, SDKs). The people who build Antigravity, Cursor, Gemini CLI, Copilot, Windsurf. |
| **Key responsibilities** | AI copilot development, SDK/API design, AI-assisted code generation pipelines, developer experience (DX) optimization, testing AI-generated code, prompt system design |
| **Must-have skills** | Python, TypeScript/JavaScript, SDK/API design, LLM APIs, prompt engineering, testing frameworks, Git, open-source development |
| **Nice-to-have** | VS Code extension development, LSP (Language Server Protocol), tree-sitter, AST parsing, developer experience research |
| **Salary (US)** | Mid: $150-220K · Senior: $200-300K+ |
| **Salary (India)** | Mid: ₹20-40 LPA · Senior: ₹40-70+ LPA |
| **Hiring companies** | Google (Gemini CLI), Anthropic (Claude Code), Cursor, Replit, Vercel, GitHub |
| **Availability** | 🟡 Growing fast — every dev tool company is building AI features |
| **Your coverage** | ████████░░ **80%** — strong on LLMs, prompt eng, code generation; need SDK design, TypeScript |
| **Gap to fill** | TypeScript, SDK/API design patterns, VS Code extension dev, developer experience principles |

---

### Layer 6: Application Layer

#### 23. Full-Stack AI Engineer 🟢

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 6 (Application) |
| **What you do** | Build complete AI-powered applications end-to-end. Frontend + backend + AI integration. The most in-demand "generalist" AI role. |
| **Key responsibilities** | Build AI-powered web/mobile apps, integrate LLM APIs into products, design RAG systems for apps, build AI agent UIs, handle model serving and latency optimization |
| **Must-have skills** | Python, TypeScript/JavaScript, React/Next.js, LLM APIs (OpenAI/Gemini/Claude), RAG, SQL + vector DBs, Docker, cloud (AWS/GCP) |
| **Nice-to-have** | AI agent frameworks, embeddings, streaming responses, real-time AI features, product thinking |
| **Salary (US)** | Entry: $88-120K · Mid: $120-180K · Senior: $168-250K+ |
| **Salary (India)** | Entry: ₹6-12 LPA · Mid: ₹15-30 LPA · Senior: ₹30-55+ LPA |
| **Hiring companies** | Every SaaS company, every startup adding AI features, every enterprise |
| **Availability** | 🟢 Highest volume — this is where most jobs are right now |
| **Your coverage** | ████████░░ **80%** — strong AI knowledge; need frontend (React) and full-stack engineering |
| **Gap to fill** | React/Next.js, TypeScript, full-stack web development, SQL, product design |

---

#### 24. AI Integration Engineer 🟢

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 6 (Application) |
| **What you do** | Integrate AI into existing enterprise products. Add AI features to CRMs, ERPs, SaaS platforms. The "glue" between AI capabilities and business systems. |
| **Key responsibilities** | LLM API integration, RAG pipelines for enterprise data, AI feature design, latency/cost/hallucination guardrails, testing AI features, stakeholder communication |
| **Must-have skills** | Python, API development (REST/GraphQL), LLM APIs, RAG, prompt engineering, SQL, enterprise integration patterns |
| **Nice-to-have** | Domain expertise (finance, healthcare, legal), Salesforce/ServiceNow integrations, data governance |
| **Salary (US)** | Mid: $120-180K · Senior: $160-250K+ |
| **Salary (India)** | Mid: ₹12-25 LPA · Senior: ₹25-50+ LPA |
| **Hiring companies** | Accenture, Deloitte, TCS, Infosys, every enterprise, every SaaS company |
| **Availability** | 🟢 Very high — every company integrating AI needs this role |
| **Your coverage** | █████████░ **90%** — excellent match. RAG, prompt eng, function calling all covered |
| **Gap to fill** | Enterprise integration patterns, domain expertise, stakeholder communication |

---

#### 25. AI Consultant / AI Strategist 🟢

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 6 (Application) — strategic |
| **What you do** | Advise companies on AI adoption strategy. Assess use cases, recommend architectures, build PoCs, guide implementation. |
| **Key responsibilities** | AI readiness assessment, use case identification, PoC development, vendor evaluation, ROI analysis, AI roadmap creation |
| **Must-have skills** | Broad AI/ML knowledge, RAG/agents/fine-tuning understanding, presentation skills, business acumen, PoC building |
| **Nice-to-have** | Industry expertise, cloud certifications, project management, consulting experience |
| **Salary (US)** | Mid: $130-200K · Senior: $180-280K+ |
| **Salary (India)** | Mid: ₹15-35 LPA · Senior: ₹35-65+ LPA |
| **Hiring companies** | McKinsey, BCG, Deloitte, Accenture, PwC (AI practices), boutique AI consultancies |
| **Availability** | 🟢 High — enterprise AI adoption is exploding |
| **Your coverage** | ████████░░ **85%** — strong on AI breadth; need consulting methodology and business acumen |
| **Gap to fill** | Consulting frameworks, business case building, presentation skills, client management |

---

### Specialized Roles (Cross-Layer)

#### 26. Conversational AI Engineer 🟡

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 5-6 (Orchestration / Application) |
| **What you do** | Build dialogue systems, voice assistants, and enterprise AI chatbots. Design multi-turn conversation architectures, intent tracking, and speech integration. |
| **Key responsibilities** | Multi-turn dialogue design, context management across conversations, intent disambiguation, ASR/TTS integration (Whisper, Google STT), persona design, conversation analytics |
| **Must-have skills** | Python, LLM APIs, NLU (intent detection, entity extraction), dialogue state tracking, speech recognition integration, prompt engineering |
| **Nice-to-have** | Google Dialogflow, ADK, voice UX design, WebSocket streaming, multilingual dialogue, sentiment analysis |
| **Salary (US)** | Mid: $140-210K · Senior: $190-300K+ |
| **Salary (India)** | Mid: ₹18-35 LPA · Senior: ₹35-60+ LPA |
| **Hiring companies** | Google, Amazon (Alexa), Apple (Siri), Salesforce, startups building AI assistants |
| **Availability** | 🟡 Medium — growing with enterprise AI assistant adoption |
| **Your coverage** | ████████░░ **80%** — strong on LLMs, agents, voice AI, prompt eng; need dialogue-specific patterns |
| **Gap to fill** | Dialogue state tracking, ASR/TTS integration, Dialogflow, voice UX design |

---

#### 27. Data Scientist (GenAI-Augmented) 🟢

| Aspect | Details |
|--------|---------|
| **Stack layer** | Layer 4-6 (cross-layer) |
| **What you do** | Classical data science + GenAI. Build predictive models, leverage LLMs for analysis, use RAG for data insights, create AI-augmented analytics. The role is evolving from manual data processing to designing intelligent systems. |
| **Key responsibilities** | Predictive modeling, statistical analysis, LLM-augmented insights, RAG for internal data, experiment design, business strategy through AI |
| **Must-have skills** | Python, R/SQL, statistics (Bayesian, regression), scikit-learn, PyTorch, LLM APIs, RAG, data visualization |
| **Nice-to-have** | LangChain/LlamaIndex, vector DBs, causal inference, A/B testing, Spark, cloud ML services |
| **Salary (US)** | Entry: $95-130K · Mid: $130-200K · Senior: $180-280K+ |
| **Salary (India)** | Entry: ₹6-14 LPA · Mid: ₹18-35 LPA · Senior: ₹35-60+ LPA |
| **Hiring companies** | Every company with data — finance, healthcare, e-commerce, tech |
| **Availability** | 🟢 Very high — one of the most common AI-adjacent roles |
| **Your coverage** | ███████░░░ **65%** — strong on GenAI side; need classical stats, scikit-learn, data viz, experiment design |
| **Gap to fill** | Classical statistics (Bayesian, hypothesis testing), scikit-learn, R, data visualization (matplotlib/seaborn), A/B testing |

---

## ★ Frontier Lab Requirements

What it takes to get hired at the top AI labs:

```
OPENAI
  ├── Research Scientist: First-author papers, autonomous research ability
  ├── Research Engineer: Strong programming, large distributed systems
  ├── Early Career Cohort: Math olympiad/Putnam/ICPC level talent
  └── Culture: "Trajectory over credentials" — welcomes non-ML backgrounds

GOOGLE DEEPMIND
  ├── Research Scientist: PhD preferred, NeurIPS/ICML/ICLR publications
  ├── Research Engineer: MSc+ preferred, JAX + PyTorch, strong coding
  └── Culture: Academic mindset, intellectual curiosity

ANTHROPIC
  ├── ~50% of technical staff do NOT have PhDs
  ├── Safety Researcher: Deep motivation to reduce AI risks
  ├── Red Team: Pentesting background + AI/ML security
  └── Culture: First-principles thinking, intellectual humility

META FAIR
  ├── Research Engineer: Master's/PhD preferred, Python + C++, PyTorch
  ├── Key signal: Publications, open-source contributions
  └── Culture: Open research, publish-first philosophy

xAI
  ├── Research Engineer: Strong coding, fast iteration, autonomous work
  ├── Infrastructure: Distributed systems, large-scale training
  └── Culture: Move fast, 80-hour weeks, mission-driven

MISTRAL AI (Paris)
  ├── Research Scientist: Strong math, model architecture design
  ├── Infra Engineer: Distributed training, GPU cluster management
  └── Culture: Small team, European AI sovereignty focus

COHERE
  ├── ML Engineer: Production-focused, enterprise integrations
  ├── Research: NLP/RAG specialization, retrieval systems
  └── Culture: Enterprise-first, practical AI applications
```

---

## ★ Target Companies by Tier

```
TIER 1 — FRONTIER LABS (highest pay, hardest to enter)
  OpenAI, Anthropic, Google DeepMind, Meta FAIR, Microsoft Research
  Mistral AI, xAI, Cohere, AI21 Labs, Stability AI

TIER 2 — BIG TECH AI TEAMS (high pay, production focus)
  Google (Gemini), Apple (ML), Amazon (Bedrock), Microsoft (Copilot),
  NVIDIA, Salesforce (Einstein), Netflix, Uber, Airbnb AI teams

TIER 3 — AI-FIRST STARTUPS (equity upside, fast learning)
  Anyscale, Together AI, Fireworks AI, Modal, Groq, Perplexity,
  Hugging Face, LangChain Inc, Weights & Biases, Replit, Cursor

TIER 4 — ENTERPRISES BUILDING AI (volume of jobs)
  Deloitte, Accenture, McKinsey (AI), Goldman Sachs,
  JPMorgan, Walmart, any Fortune 500 AI team

TIER 5 — AI CONSULTING & SERVICES (accessible entry)
  TCS, Infosys, Wipro (AI practices), Fractal Analytics,
  Tiger Analytics, Mu Sigma, LatentView

INDIA-SPECIFIC AI COMPANIES:
  Flipkart AI, Ola Krutrim, Reliance Jio AI, PhonePe ML,
  Swiggy ML, Zomato AI, Razorpay AI, CRED AI,
  Fractal Analytics, LatentView, Tiger Analytics, Mu Sigma,
  Microsoft IDC (Hyderabad), Google India (Bangalore),
  Amazon India ML, Walmart Labs India
```

---

## ★ Expanded Salary Table (All 27 Roles — by Layer)

```
                           UNITED STATES ($K/yr)         INDIA (₹ LPA)
ROLE                     Entry   Mid    Senior        Entry  Mid   Senior
═══════════════════════════════════════════════════════════════════════════
LAYER 6 — APPLICATION:
Full-Stack AI Engineer     88    120-180  168-250+   6-12  15-30  30-55+
AI Integration Engineer     —    120-180  160-250+     —    12-25  25-50+
AI Consultant               —    130-200  180-280+     —    15-35  35-65+
AI Product Manager          —    150-220  200-300+     —    20-40  40-70+
Conversational AI Eng.      —    140-210  190-300+     —    18-35  35-60+
──────────────────────────────────────────────────────────────────────────
LAYER 5 — ORCHESTRATION:
AI Engineer               100    140-211  195-350     5-12  18-32  35-60+
GenAI Engineer            120    180-250  220-350+    8-15  25-45  50-80+
Agentic AI Engineer         —    170-250  220-350+     —    22-40  40-70+
Prompt Engineer            80    120-180  160-250     5-10  15-30  30-50+
AI Architect                —    160-230  200-320+     —    25-45  45-75+
AI DevTools Engineer        —    150-220  200-300+     —    20-40  40-70+
──────────────────────────────────────────────────────────────────────────
LAYER 4 — FINE-TUNING & EVALUATION:
LLM Engineer               —    180-260  240-400+     —    20-40  40-70+
RAG Engineer                —    150-220  200-300+     —    18-35  35-60+
AI Data Engineer            —    130-190  175-260+     —    15-28  28-50+
NLP Engineer                —    130-200  180-280+     —    15-30  30-55+
Data Scientist (GenAI)     95    130-200  180-280+   6-14  18-35  35-60+
AI Safety/Red Team          —    160-220  200-300+     —    20-40  40-65+
CV Engineer                 —    137-200  200-350+     —    15-30  30-55+
──────────────────────────────────────────────────────────────────────────
LAYER 3 — INFERENCE & SERVING:
MLOps/LLMOps                —    140-200  180-280+     —    15-30  30-55+
ML Engineer                96    149-200  175-240    8-15  20-35  35-60+
Inference Opt. Eng.         —    167-209  200-350+     —    25-45  45-80+
──────────────────────────────────────────────────────────────────────────
LAYER 2 — FOUNDATION MODEL:
Foundation Model Eng.       —    160-260  240-400+     —    30-50  40-80+
Applied Scientist           —    150-220  200-300+     —    20-40  40-70+
AI Research Scientist     115    160-260  220-360+     —    30-50  40-80+
──────────────────────────────────────────────────────────────────────────
LAYER 1 — INFRASTRUCTURE:
AI Infra/Platform Eng.      —    140-220  192-288+     —    20-40  40-70+
AI Compiler/Kernel Eng.     —       —     250-400+     —      —    45-80+
──────────────────────────────────────────────────────────────────────────
CROSS-CUTTING:
AI Ethics/Governance        —    140-200  180-280+     —    18-35  35-60+

FAANG Senior TC (total comp with equity): $320-550K+
Staff/Principal at frontier labs: up to $943K
GenAI premium: +40-60% over baseline ML salaries
```

---

## ★ Upskilling Roadmap (Stack-Layer Based)

```
YOUR CURRENT STATE:
  ✅ Layer 6 (Application): 95% ready — can apply NOW
  ✅ Layer 5 (Orchestration): 90% ready — just build projects
  ✅ Layer 4 (Fine-tuning): 85% — almost ready, need hands-on depth
  ⚠️ Layer 3 (Inference/Serving): 70% — need DevOps/serving skills
  ❌ Layer 2 (Foundation Model): 50% — needs significant upskilling
  ❌ Layer 1 (Infrastructure): 25% — biggest gap, systems programming

IMMEDIATE (Apply now — Layer 6 & 5 roles):
  → Full-Stack AI Engineer, AI Integration Engineer, AI Consultant
  → GenAI Engineer, RAG Engineer, Prompt Engineer
  → Agentic AI Engineer (build 1-2 agent projects)
  → Data Scientist (GenAI) if you add classical stats
  ✅ Build portfolio: RAG chatbot, AI agent, fine-tuned model

3-6 MONTHS (Unlock Layer 4 & 3 roles):
  📚 Docker + Kubernetes hands-on
  📚 Cloud cert (AWS ML Specialty or GCP ML Engineer)
  📚 System design for ML
  📚 DSA (LeetCode medium-level)
  📚 Hands-on fine-tuning with Unsloth/Axolotl
  📚 Dialogue systems (for Conversational AI roles)
  → Apply: ML Engineer, LLM Engineer, NLP Engineer, MLOps, Conv AI Eng

6-12 MONTHS (Unlock Layer 2 & Tier 1 frontier labs):
  📚 C++ fundamentals → advanced
  📚 CUDA programming (NVIDIA docs + practice)
  📚 PyTorch internals (source code reading)
  📚 Distributed training (DeepSpeed, FSDP)
  📚 JAX (for DeepMind roles)
  📚 Read + reproduce research papers
  📚 Contribute to open-source AI projects
  → Apply: Inference Optimization, Foundation Model Engineer

12-24 MONTHS (Unlock Layer 1 & AI Research roles):
  📚 Deep math refresh (optimization theory)
  📚 Publish research papers or technical blog posts
  📚 Compiler design fundamentals
  📚 GPU architecture deep dive
  📚 Go/Rust for systems programming
  📚 Kubernetes advanced (CRDs, operators)
  → Apply: AI Research Scientist, AI Infra Engineer, AI Compiler Engineer
```

---

## ★ Portfolio Projects by Role

Build these to demonstrate readiness for your target roles:

| Project | Target Roles | Layer |
|---------|-------------|:---:|
| **RAG chatbot** with vector DB, re-ranking, evaluation | RAG Eng, GenAI Eng, AI Integration Eng | L4-5 |
| **Multi-agent system** (LangGraph/CrewAI) with tool use | Agentic AI Eng, AI Eng, GenAI Eng | L5 |
| **Fine-tuned model** on custom dataset (Unsloth/LoRA) | LLM Eng, NLP Eng, Data Scientist | L4 |
| **AI-powered web app** (Next.js + LLM API + RAG) | Full-Stack AI Eng, AI Integration Eng | L6 |
| **LLM evaluation pipeline** (RAGAS, hallucination metrics) | GenAI Eng, LLM Eng, AI Safety Eng | L4-5 |
| **Prompt library + testing framework** | Prompt Eng, AI Consultant | L5-6 |
| **Voice assistant** (Whisper + LLM + TTS) | Conversational AI Eng | L5-6 |
| **MLOps pipeline** (Docker + K8s + CI/CD for model serving) | MLOps Eng, ML Engineer | L3 |
| **SDK/CLI tool** with AI integration | AI DevTools Eng | L5 |
| **Model inference benchmark** (vLLM vs TensorRT) | Inference Opt Eng | L3 |
| **Data pipeline** (Airflow + embeddings at scale) | AI Data Eng, Data Scientist | L4 |
| **AI safety red-team report** on a public model | AI Safety Eng, AI Ethics | Cross |
| **Research paper reproduction** + blog post | AI Research Scientist, Applied Scientist | L2 |

---

## ★ Certification Roadmap

| Certification | Applicable Roles | Priority |
|--------------|-----------------|:---:|
| **AWS ML Specialty** | ML Eng, MLOps, AI Architect, AI Data Eng | 🔴 High |
| **GCP Professional ML Engineer** | ML Eng, MLOps, GenAI Eng | 🔴 High |
| **Google Cloud GenAI** (Professional) | GenAI Eng, AI Eng, Prompt Eng | 🟡 Medium |
| **Azure AI Engineer Associate** | AI Integration Eng, Full-Stack AI, AI Consultant | 🟡 Medium |
| **DeepLearning.AI MLOps Specialization** | MLOps, ML Eng | 🟡 Medium |
| **Kubernetes (CKA/CKAD)** | MLOps, AI Infra, Inference Opt | 🟡 Medium |
| **NVIDIA Deep Learning Institute (DLI)** | Inference Opt, Foundation Model, AI Compiler | 🟢 Nice-to-have |

> **Note**: Certifications matter most for Tier 4-5 companies (enterprises, consulting). Frontier labs (Tier 1-2) care more about projects, papers, and open-source contributions.

---

## ★ Connections

| Relationship | Topics |
|-------------|--------|
| Builds on | All 40 docs in the GenAI knowledge base |
| Leads to | Resume preparation, portfolio projects, interview practice |
| Cross-domain | Software engineering, cloud architecture, product management, cybersecurity, systems programming |

---

## ★ Sources

- LinkedIn "Skills on the Rise 2026" report
- LinkedIn "Fastest Growing Job Titles 2026" (AI Engineer #1)
- Indeed, Glassdoor, Naukri job postings analysis (March 2026)
- Levels.fyi, BuiltIn.com, Wellfound compensation data
- OpenAI, Anthropic, Google DeepMind, Meta FAIR, AMD career pages (March 2026)
- Gartner "40% enterprise apps embed agents by end 2026" prediction
- NVIDIA, Anyscale, Together AI, Fireworks AI, Poolside AI job postings
- Signify Technology ML Engineer salary report 2026
- Vercel, Cursor, Replit AI DevTools team job descriptions
