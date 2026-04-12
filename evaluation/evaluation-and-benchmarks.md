---
title: "LLM Evaluation & Benchmarks"
tags: [evaluation, benchmarks, mmlu, humaneval, ragas, testing, genai]
type: reference
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../llms/llms-overview]]", "[[../techniques/rag]]", "[[../techniques/agent-evaluation]]", "[[../llms/hallucination-detection]]", "[[llm-evaluation-deep-dive]]", "[[system-design-for-ai-interviews]]"]
source: "Multiple benchmarks and frameworks - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# LLM Evaluation & Benchmarks

> âœ¨ **Bit**: "You can't improve what you can't measure." In GenAI, the problem is the opposite â€” you CAN measure, but the benchmarks keep getting saturated. It's an arms race between models and tests.

---

## â˜… TL;DR

- **What**: Methods, metrics, and benchmark datasets to measure LLM quality, safety, and reliability
- **Why**: Without evaluation, you're guessing. Models that score 90% on benchmarks can still hallucinate, be biased, or fail in production.
- **Key point**: Traditional benchmarks (MMLU, HumanEval) are saturated. The field is shifting to harder tests, real-world eval, and LLM-as-judge.

---

## â˜… Overview

### Definition

**LLM Evaluation** encompasses the tools, benchmarks, metrics, and methodologies used to assess language model performance across dimensions: accuracy, reasoning, coding, safety, fairness, hallucination, and real-world utility.

### Scope

Covers: Major benchmarks, RAG-specific evaluation, evaluation tools, and emerging approaches. For applied evaluation design, see [LLM Evaluation Deep Dive](./llm-evaluation-deep-dive.md). For interview-focused architecture framing, see [System Design for AI Interviews](./system-design-for-ai-interviews.md). This is a fast-moving area - benchmarks get saturated and replaced regularly.

### Significance

- Models that ace benchmarks can still fail catastrophically in production
- Companies are increasingly demanding evaluation before deploying GenAI
- Understanding eval = you can pick the right model, avoid hype, and build reliable systems
- Most teams skip evaluation â†’ most teams ship broken GenAI

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) â€” what you're evaluating
- [Rag](../techniques/rag.md) â€” for RAG-specific metrics

---

## â˜… Deep Dive

### The 7 Dimensions of LLM Evaluation

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚            WHAT TO MEASURE                               â”‚
â”‚                                                         â”‚
â”‚  1. ACCURACY & KNOWLEDGE    â†’ Does it know things?      â”‚
â”‚  2. REASONING               â†’ Can it think logically?   â”‚
â”‚  3. CODING                  â†’ Can it write code?        â”‚
â”‚  4. SAFETY & HARM           â†’ Is it safe to deploy?     â”‚
â”‚  5. FAIRNESS & BIAS         â†’ Is it equitable?          â”‚
â”‚  6. ROBUSTNESS              â†’ Does it handle edge cases?â”‚
â”‚  7. EFFICIENCY              â†’ Is it fast & cheap enough?â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Major Benchmarks (March 2026 Status)

#### Knowledge & Reasoning

| Benchmark        | What It Tests                                        | Saturated?          | Top Score (Mar 2026)   |
| ---------------- | ---------------------------------------------------- | ------------------- | ---------------------- |
| **MMLU**         | 57 subject knowledge (high school â†’ professional)    | âš ï¸ YES (>90%)        | GPT-5.3: 93%           |
| **MMLU-Pro**     | Harder MMLU: 12K grad-level, 10 options per question | Approaching         | Gemini 3 Pro: 89.8%    |
| **GPQA-Diamond** | PhD-level science (physics, chemistry, biology)      | No (60-90% range)   | ~87% (frontier models) |
| **ARC-AGI-2**    | Abstract reasoning (pattern completion)              | No (LLMs score ~0%) | Below human average    |
| **LiveBench**    | Dynamic monthly questions (no contamination)         | No (<70%)           | Rotates monthly        |

#### Coding

| Benchmark              | What It Tests                        | Saturated?     | Top Score                |
| ---------------------- | ------------------------------------ | -------------- | ------------------------ |
| **HumanEval**          | 164 Python problems (pass@1)         | âš ï¸ YES (>95%)   | Claude Sonnet 4.5: 97.6% |
| **SWE-bench Verified** | Real GitHub issues in real codebases | No (very hard) | ~50% (frontier)          |
| **BigCodeBench**       | Complex coding with library usage    | No             | Moderate                 |

#### Math

| Benchmark          | What It Tests                      | Saturated?   | Top Score                |
| ------------------ | ---------------------------------- | ------------ | ------------------------ |
| **GSM8K**          | Grade school math word problems    | âš ï¸ YES (>95%) | Near-perfect             |
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

â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                                                       â”‚
â”‚   User Question                                       â”‚
â”‚        â”‚                                              â”‚
â”‚        â–¼                                              â”‚
â”‚   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”     Context         Context             â”‚
â”‚   â”‚RETRIEVERâ”œâ”€â”€â”€â–º Precision  â”€â”€â”€â–º "Did I retrieve     â”‚
â”‚   â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”˜     Context          only what matters?"â”‚
â”‚        â”‚          Recall     â”€â”€â”€â–º "Did I get ALL       â”‚
â”‚        â”‚                          relevant info?"      â”‚
â”‚        â–¼                                              â”‚
â”‚   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”     Faithfulness â”€â–º "Is the answer      â”‚
â”‚   â”‚GENERATORâ”œâ”€â”€â”€â”€â–º                 grounded in the     â”‚
â”‚   â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”˜                      retrieved context?" â”‚
â”‚        â”‚          Answer     â”€â”€â”€â–º "Does it actually    â”‚
â”‚        â”‚          Relevancy       answer the question?"â”‚
â”‚        â–¼                                              â”‚
â”‚   Final Answer                                        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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

## â—† Code & Implementation

```python
# â•â•â• RAGAS: Evaluate a RAG Pipeline â•â•â•
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision

result = evaluate(
    dataset=your_eval_dataset,  # Questions + retrieved contexts + answers + ground truth
    metrics=[faithfulness, answer_relevancy, context_precision],
)
print(result)
# {'faithfulness': 0.87, 'answer_relevancy': 0.92, 'context_precision': 0.78}

# â•â•â• DEEPEVAL: Unit Tests for LLMs â•â•â•
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

## â—† Quick Reference

```
WHICH BENCHMARK FOR WHAT:
  General knowledge â†’ MMLU-Pro (MMLU is too easy now)
  Coding            â†’ SWE-bench (HumanEval is too easy now)
  Reasoning         â†’ GPQA-Diamond, ARC-AGI-2
  Math              â†’ MATH-500, AIME
  Real-world        â†’ LiveBench (dynamic, uncontaminated)
  RAG quality       â†’ RAGAS metrics
  Safety            â†’ Red teaming + automated harm benchmarks

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

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Benchmark contamination**: Models may have trained on benchmark data. High scores â‰  real-world ability.
- âš ï¸ **LLM-as-Judge bias**: GPT-5.4 prefers GPT-5.4 outputs. Claude prefers Claude outputs. Use multiple judges or human verification.
- âš ï¸ **No eval = shipping blind**: Most teams skip evaluation entirely. Build at least a minimal test set (20-50 golden examples).
- âš ï¸ **Accuracy isn't enough**: A model can be accurate AND unsafe, biased, or hallucinating. Evaluate multiple dimensions.
- âš ï¸ **Leaderboard chasing**: Models optimized for benchmarks may sacrifice real-world usability. Always test on YOUR use case.

---

## â—‹ Interview Angles

- **Q**: How would you evaluate a RAG system?
- **A**: Component-level: Retrieval quality (context precision + recall) â€” are the right chunks found? Generation quality (faithfulness + answer relevancy) â€” is the answer grounded and on-topic? Use RAGAS for automated metrics, plus a golden test set of 50+ question-answer pairs with human-verified ground truth.

- **Q**: Why are traditional benchmarks becoming less useful?
- **A**: Saturation (top models all score >90%), contamination (benchmark data in training sets), and gap between benchmark performance and real-world utility. The field is moving to dynamic benchmarks (LiveBench), harder tests (SWE-bench, ARC-AGI-2), and domain-specific evaluation.

---

## â˜… Connections

| Relationship | Topics                                                            |
| ------------ | ----------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Rag](../techniques/rag.md)                  |
| Leads to     | Production monitoring, Model selection, Quality assurance         |
| Compare with | Traditional ML metrics (accuracy, F1), Software testing           |
| Cross-domain | Psychometrics (test design), Statistics (inter-rater reliability) |

---

## â˜… Sources

- MMLU: Hendrycks et al. (2020) â€” https://arxiv.org/abs/2009.03300
- RAGAS documentation â€” https://docs.ragas.io
- DeepEval documentation â€” https://docs.confident-ai.com
- LiveBench â€” https://livebench.ai
- EleutherAI lm-evaluation-harness â€” https://github.com/EleutherAI/lm-evaluation-harness
