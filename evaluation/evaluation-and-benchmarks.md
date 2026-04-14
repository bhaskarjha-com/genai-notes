---
title: "LLM Evaluation & Benchmarks"
tags: [evaluation, benchmarks, mmlu, humaneval, ragas, testing, genai]
type: reference
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "[[../genai]]"
related: ["[[../llms/llms-overview]]", "[[../techniques/rag]]", "[[../agents/agent-evaluation]]", "[[../llms/hallucination-detection]]", "[[llm-evaluation-deep-dive]]", "[[system-design-for-ai-interviews]]"]
source: "Multiple benchmarks and frameworks - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# LLM Evaluation & Benchmarks

> ✨ **Bit**: "You can't improve what you can't measure." In GenAI, the problem is the opposite — you CAN measure, but the benchmarks keep getting saturated. It's an arms race between models and tests.

---

## ★ TL;DR

- **What**: Methods, metrics, and benchmark datasets to measure LLM quality, safety, and reliability
- **Why**: Without evaluation, you're guessing. Models that score 90% on benchmarks can still hallucinate, be biased, or fail in production.
- **Key point**: Traditional benchmarks (MMLU, HumanEval) are saturated. The field is shifting to harder tests, real-world eval, and LLM-as-judge.

---

## ★ Overview

### Definition

**LLM Evaluation** encompasses the tools, benchmarks, metrics, and methodologies used to assess language model performance across dimensions: accuracy, reasoning, coding, safety, fairness, hallucination, and real-world utility.

### Scope

Covers: Major benchmarks, RAG-specific evaluation, evaluation tools, and emerging approaches. For applied evaluation design, see [LLM Evaluation Deep Dive](./llm-evaluation-deep-dive.md). For interview-focused architecture framing, see [System Design for AI Interviews](./system-design-for-ai-interviews.md). This is a fast-moving area - benchmarks get saturated and replaced regularly.

### Significance

- Models that ace benchmarks can still fail catastrophically in production
- Companies are increasingly demanding evaluation before deploying GenAI
- Understanding eval = you can pick the right model, avoid hype, and build reliable systems
- Most teams skip evaluation → most teams ship broken GenAI

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) — what you're evaluating
- [Rag](../techniques/rag.md) — for RAG-specific metrics

---

## ★ Deep Dive

### The 7 Dimensions of LLM Evaluation

```
┌─────────────────────────────────────────────────────────┐
│            WHAT TO MEASURE                               │
│                                                         │
│  1. ACCURACY & KNOWLEDGE    → Does it know things?      │
│  2. REASONING               → Can it think logically?   │
│  3. CODING                  → Can it write code?        │
│  4. SAFETY & HARM           → Is it safe to deploy?     │
│  5. FAIRNESS & BIAS         → Is it equitable?          │
│  6. ROBUSTNESS              → Does it handle edge cases?│
│  7. EFFICIENCY              → Is it fast & cheap enough?│
└─────────────────────────────────────────────────────────┘
```

### Major Benchmarks (March 2026 Status)

#### Knowledge & Reasoning

| Benchmark        | What It Tests                                        | Saturated?          | Top Score (Mar 2026)   |
| ---------------- | ---------------------------------------------------- | ------------------- | ---------------------- |
| **MMLU**         | 57 subject knowledge (high school → professional)    | ⚠️ YES (>90%)        | GPT-5.3: 93%           |
| **MMLU-Pro**     | Harder MMLU: 12K grad-level, 10 options per question | Approaching         | Gemini 3 Pro: 89.8%    |
| **GPQA-Diamond** | PhD-level science (physics, chemistry, biology)      | No (60-90% range)   | ~87% (frontier models) |
| **ARC-AGI-2**    | Abstract reasoning (pattern completion)              | No (LLMs score ~0%) | Below human average    |
| **LiveBench**    | Dynamic monthly questions (no contamination)         | No (<70%)           | Rotates monthly        |

#### Coding

| Benchmark              | What It Tests                        | Saturated?     | Top Score                |
| ---------------------- | ------------------------------------ | -------------- | ------------------------ |
| **HumanEval**          | 164 Python problems (pass@1)         | ⚠️ YES (>95%)   | Claude Sonnet 4.5: 97.6% |
| **SWE-bench Verified** | Real GitHub issues in real codebases | No (very hard) | ~50% (frontier)          |
| **BigCodeBench**       | Complex coding with library usage    | No             | Moderate                 |

#### Math

| Benchmark          | What It Tests                      | Saturated?   | Top Score                |
| ------------------ | ---------------------------------- | ------------ | ------------------------ |
| **GSM8K**          | Grade school math word problems    | ⚠️ YES (>95%) | Near-perfect             |
| **MATH-500**       | Competition-level math             | Approaching  | ~90%+ (reasoning models) |
| **AIME 2025/2026** | American math competition problems | No           | Varies                   |

#### Multimodal

| Benchmark     | What It Tests                       |
| ------------- | ----------------------------------- |
| **MMMU**      | Visual understanding + reasoning    |
| **MathVista** | Math reasoning with visual elements |

### RAG-Specific Evaluation (RAGAS Framework)

```
RAG Evaluation = Separate what went wrong WHERE

┌───────────────────────────────────────────────────────┐
│                                                       │
│   User Question                                       │
│        │                                              │
│        ▼                                              │
│   ┌─────────┐     Context         Context             │
│   │RETRIEVER├───► Precision  ───► "Did I retrieve     │
│   └────┬────┘     Context          only what matters?"│
│        │          Recall     ───► "Did I get ALL       │
│        │                          relevant info?"      │
│        ▼                                              │
│   ┌─────────┐     Faithfulness ─► "Is the answer      │
│   │GENERATOR├────►                 grounded in the     │
│   └────┬────┘                      retrieved context?" │
│        │          Answer     ───► "Does it actually    │
│        │          Relevancy       answer the question?"│
│        ▼                                              │
│   Final Answer                                        │
└───────────────────────────────────────────────────────┘
```

| RAGAS Metric           | What It Measures                             | Why It Matters              |
| ---------------------- | -------------------------------------------- | --------------------------- |
| **Faithfulness**       | Is the answer grounded in retrieved context? | Catches hallucinations      |
| **Answer Relevancy**   | Does the answer address the actual question? | Catches off-topic responses |
| **Context Precision**  | Were retrieved chunks relevant?              | Evaluates retrieval quality |
| **Context Recall**     | Did retrieval find all needed info?          | Catches missing information |
| **Answer Correctness** | Is the answer factually correct?             | Ground truth comparison     |

### Evaluation Methods

| Method                | How                                 | Pros                     | Cons                               |
| --------------------- | ----------------------------------- | ------------------------ | ---------------------------------- |
| **Benchmarks**        | Run standardized test sets          | Reproducible, comparable | Saturated, gameable                |
| **Human evaluation**  | Humans rate outputs                 | Gold standard            | Expensive, slow, subjective        |
| **LLM-as-Judge**      | Use GPT-5.4/Claude to judge outputs | Scalable, cheap          | Self-preference bias, inconsistent |
| **A/B Testing**       | Real users compare variants         | Real-world signal        | Need traffic, slow                 |
| **Automated metrics** | BLEU, ROUGE, perplexity             | Fast, cheap              | Don't capture quality well         |
| **Red teaming**       | Adversarial testing for safety      | Catches edge cases       | Requires expertise                 |

### Evaluation Tools & Platforms

| Tool                      | Type                     | Best For                          |
| ------------------------- | ------------------------ | --------------------------------- |
| **RAGAS**                 | Open-source framework    | RAG pipeline evaluation           |
| **DeepEval**              | Open-source framework    | Unit tests for LLM outputs        |
| **LangSmith**             | Platform (LangChain)     | Tracing + evaluation + monitoring |
| **Braintrust**            | Platform                 | Eval + prompt playground          |
| **Phoenix** (Arize)       | Open-source              | Observability + tracing           |
| **Promptfoo**             | Open-source CLI          | Prompt testing & comparison       |
| **lm-evaluation-harness** | Open-source (EleutherAI) | Running academic benchmarks       |

---

## ◆ Code & Implementation

```python
# ?? Last tested: 2026-04
# ═══ RAGAS: Evaluate a RAG Pipeline ═══
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision

result = evaluate(
    dataset=your_eval_dataset,  # Questions + retrieved contexts + answers + ground truth
    metrics=[faithfulness, answer_relevancy, context_precision],
)
print(result)
# {'faithfulness': 0.87, 'answer_relevancy': 0.92, 'context_precision': 0.78}

# ═══ DEEPEVAL: Unit Tests for LLMs ═══
from deepeval import assert_test
from deepeval.test_case import LLMTestCase
from deepeval.metrics import HallucinationMetric

test_case = LLMTestCase(
    input="What is the capital of France?",
    actual_output="The capital of France is Paris.",
    context=["Paris is the capital city of France."]
)

metric = HallucinationMetric(threshold=0.5)
assert_test(test_case, [metric])  # Passes if hallucination score < 0.5
```

---

## ◆ Quick Reference

```
WHICH BENCHMARK FOR WHAT:
  General knowledge → MMLU-Pro (MMLU is too easy now)
  Coding            → SWE-bench (HumanEval is too easy now)
  Reasoning         → GPQA-Diamond, ARC-AGI-2
  Math              → MATH-500, AIME
  Real-world        → LiveBench (dynamic, uncontaminated)
  RAG quality       → RAGAS metrics
  Safety            → Red teaming + automated harm benchmarks

MINIMUM EVAL STACK:
  1. RAGAS (if building RAG)
  2. A handful of golden test cases (manual)
  3. LLM-as-judge for subjective quality
  4. Prod monitoring (LangSmith / Phoenix)

BENCHMARK SATURATION WARNING:
  If top models score > 90%, the benchmark is no longer useful
  for distinguishing frontier models. Look for harder alternatives.
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Benchmark contamination**: Models may have trained on benchmark data. High scores ≠ real-world ability.
- ⚠️ **LLM-as-Judge bias**: GPT-5.4 prefers GPT-5.4 outputs. Claude prefers Claude outputs. Use multiple judges or human verification.
- ⚠️ **No eval = shipping blind**: Most teams skip evaluation entirely. Build at least a minimal test set (20-50 golden examples).
- ⚠️ **Accuracy isn't enough**: A model can be accurate AND unsafe, biased, or hallucinating. Evaluate multiple dimensions.
- ⚠️ **Leaderboard chasing**: Models optimized for benchmarks may sacrifice real-world usability. Always test on YOUR use case.

---

## ○ Interview Angles

- **Q**: How would you evaluate a RAG system?
- **A**: Component-level: Retrieval quality (context precision + recall) — are the right chunks found? Generation quality (faithfulness + answer relevancy) — is the answer grounded and on-topic? Use RAGAS for automated metrics, plus a golden test set of 50+ question-answer pairs with human-verified ground truth.

- **Q**: Why are traditional benchmarks becoming less useful?
- **A**: Saturation (top models all score >90%), contamination (benchmark data in training sets), and gap between benchmark performance and real-world utility. The field is moving to dynamic benchmarks (LiveBench), harder tests (SWE-bench, ARC-AGI-2), and domain-specific evaluation.

---

## ★ Connections

| Relationship | Topics                                                            |
| ------------ | ----------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Rag](../techniques/rag.md)                  |
| Leads to     | Production monitoring, Model selection, Quality assurance         |
| Compare with | Traditional ML metrics (accuracy, F1), Software testing           |
| Cross-domain | Psychometrics (test design), Statistics (inter-rater reliability) |

---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 4 | Best treatment of AI evaluation strategy |
| 🔧 Hands-on | [Eleuther AI LM Eval Harness](https://github.com/EleutherAI/lm-evaluation-harness) | Standard LLM benchmark suite |
| 🔧 Hands-on | [LMSYS Chatbot Arena](https://chat.lmsys.org/) | Human evaluation via head-to-head comparisons |

## ★ Sources

- MMLU: Hendrycks et al. (2020) — https://arxiv.org/abs/2009.03300
- RAGAS documentation — https://docs.ragas.io
- DeepEval documentation — https://docs.confident-ai.com
- LiveBench — https://livebench.ai
- EleutherAI lm-evaluation-harness — https://github.com/EleutherAI/lm-evaluation-harness
