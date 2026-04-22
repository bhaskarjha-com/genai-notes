---
title: "Research Methodology & Paper Reading for AI"
aliases: ["Paper Reading", "Research Methods"]
tags: [research, papers, methodology, experiments, reproducibility]
type: reference
difficulty: advanced
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["interpretability.md", "distributed-training.md", "../evaluation/llm-evaluation-deep-dive.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Research Methodology & Paper Reading for AI

> Reading papers is not about collecting PDFs. It is about extracting claims, assumptions, methods, and limits without getting hypnotized by the leaderboard.

---

## â˜… TL;DR
- **What**: A practical framework for reading AI papers and designing research-minded experiments.
- **Why**: Frontier work moves fast, and shallow paper consumption leads to weak understanding and cargo-cult implementation.
- **Key point**: Focus on claims, setup, evidence, limitations, and reproducibility.

---

## â˜… Overview
### Definition

This note covers how to read papers critically, evaluate evidence, and structure experiments so you can learn from research rather than merely quote it.

### Scope

It applies to engineers, researchers, and advanced learners. It is not limited to academic roles.

### Significance

- AI progress is paper-driven and benchmark-driven.
- Reading well helps you separate durable ideas from hype.
- Strong research method improves engineering decisions too.

### Prerequisites

- [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md)
- [Distributed Training for Large Models](./distributed-training.md)
- Curiosity and healthy skepticism

---

## â˜… Deep Dive
### The Five Questions To Ask Of Any Paper

1. What exact claim is being made?
2. What setting or assumptions does the claim depend on?
3. What evidence supports it?
4. What are the weak spots in that evidence?
5. What would reproduction or adaptation require?

### Paper Reading Passes

| Pass       | Goal                                                         |
| ---------- | ------------------------------------------------------------ |
| **Pass 1** | skim title, abstract, intro, figures, conclusion             |
| **Pass 2** | inspect method, data, evaluation, and baselines              |
| **Pass 3** | analyze assumptions, implementation details, and limitations |

### What To Extract

Keep notes on:

- problem statement
- proposed method
- datasets and benchmarks
- baseline comparisons
- ablations
- limitations
- what is likely durable vs temporary

### Common Failure Modes When Reading AI Papers

| Failure                          | Why It Misleads                  |
| -------------------------------- | -------------------------------- |
| reading only abstract and charts | misses assumptions and setup     |
| trusting one benchmark           | ignores generalization           |
| ignoring compute budget          | hides practicality               |
| skipping baselines               | cannot judge improvement quality |
| missing ablations                | unclear what truly mattered      |

### Reproducibility Mindset

When trying an idea from a paper:

1. define the exact claim you want to test
2. choose a tractable local version
3. record configs and datasets
4. compare against a meaningful baseline
5. document failures as well as wins

### Engineering Value Of Research Reading

Paper reading improves:

- architecture judgment
- tool selection
- interview depth
- ability to detect hype
- communication with advanced teams

### Example: Experiment Card Template

```yaml
claim_under_test: "Retrieval reranking improves grounded answer quality."
baseline:
  system: "RAG without reranker"
  metric: "grounded_answer_rate"
change:
  system: "RAG plus cross-encoder reranker"
dataset:
  split: "200 held-out support questions"
success_criteria:
  grounded_answer_rate_delta: ">= 5%"
  latency_budget_ms: "<= 1200"
notes_to_capture:
  - prompt version
  - retriever config
  - failure examples
  - unexpected regressions
```

---

## â—† Quick Reference
| If You Want To Know...                | Read This Part First                    |
| ------------------------------------- | --------------------------------------- |
| what the paper claims                 | abstract and conclusion                 |
| whether the result is credible        | evaluation and baselines                |
| whether it will transfer to your work | assumptions, limitations, compute setup |
| what actually caused gains            | ablation section                        |
| whether you can implement it          | method + appendix/code                  |

---

## â—‹ Gotchas & Common Mistakes
- Newer does not automatically mean better.
- A strong benchmark result can hide weak operational value.
- Reproducing only the headline number misses the real lesson.

---

## â—‹ Interview Angles
- **Q**: How do you read an AI paper efficiently?
- **A**: I start by extracting the core claim and evaluation setup, then inspect baselines, ablations, and limitations. I try to determine what is durable knowledge versus benchmark-specific optimization.

- **Q**: Why do ablations matter?
- **A**: Because they test which parts of the method actually drive the gains. Without ablations, it is hard to know whether the headline method or some side choice caused the result.

---

## â˜… Code & Implementation

### Paper Analysis Pipeline with LLM

```python
# pip install openai>=1.60 PyPDF2>=3
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY, PyPDF2>=3
from openai import OpenAI
import PyPDF2, json

client = OpenAI()

def extract_text_from_pdf(pdf_path: str, max_chars: int = 8000) -> str:
    """Extract text from a PDF (first N chars to fit in context)."""
    reader = PyPDF2.PdfReader(pdf_path)
    text   = " ".join(page.extract_text() or "" for page in reader.pages)
    return text[:max_chars]

def analyze_paper(paper_text: str) -> dict:
    """Structured AI-powered paper analysis using the ACE framework."""
    prompt = (
        "Analyze this research paper and extract structured information.\n\n"
        f"PAPER:\n{paper_text}\n\n"
        "Return JSON with these fields:\n"
        "- problem: what problem does it solve?\n"
        "- method: what is the core method/approach?\n"
        "- key_results: top 3 quantitative results\n"
        "- limitations: what are the stated limitations?\n"
        "- reproducibility: 1-5 score (5=fully reproducible)\n"
        "- related_to: list 3 related techniques/papers\n"
        "- one_line_summary: max 20 words\n"
    )
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        response_format={"type": "json_object"},
        max_tokens=600,
    )
    return json.loads(resp.choices[0].message.content)

# Demo with a text snippet (replace with real PDF path)
demo_text = """
Title: Attention Is All You Need. We propose a new simple network architecture,
the Transformer, based solely on attention mechanisms, dispensing with recurrence
and convolutions entirely. On two machine translation tasks, it achieves state of
the art results of 28.4 BLEU on WMT 2014 English-to-German translation and 41.0
BLEU on the WMT 2014 English-to-French translation. Training took 3.5 days on 8 P100s.
"""
result = analyze_paper(demo_text)
print(json.dumps(result, indent=2))
```

## â˜… Connections
| Relationship | Topics                                                                                                                       |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------- |
| Builds on    | [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md), [Mechanistic Interpretability](./interpretability.md) |
| Leads to     | applied research, model experimentation, deeper technical interviews                                                         |
| Compare with | blog-post level understanding                                                                                                |
| Cross-domain | scientific method, experimentation                                                                                           |


---

## â—† Hands-On Exercises

### Exercise 1: Critically Analyze a Recent Paper

**Goal**: Apply structured paper reading to a 2026 ML paper
**Time**: 45 minutes
**Steps**:
1. Select a recent paper from arXiv (published within last 3 months)
2. Do a 3-pass reading: (1) abstract + figures, (2) methods, (3) experiments
3. Identify: key contribution, limitations, missing baselines, reproducibility concerns
4. Write a 1-page critical review with a recommendation (accept/reject)
**Expected Output**: Structured paper review with specific technical critiques

---

## â—† Production Failure Modes

| Failure                     | Symptoms                                                 | Root Cause                                         | Mitigation                                                          |
| --------------------------- | -------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------------------------- |
| **Reproducibility failure** | Cannot reproduce paper results in your environment       | Missing implementation details, different hardware | Check official repos, contact authors, document environment exactly |
| **Cherry-picked baselines** | Paper claims SOTA but uses weak baselines                | Author incentive to show improvement               | Compare against multiple recent baselines, reproduce yourself       |
| **Hype-driven adoption**    | Team implements flashy paper technique that doesn't help | No evaluation against simpler alternatives         | Always benchmark against simple baseline first                      |
---


## â˜… Recommended Resources

| Type       | Resource                                                                      | Why                                             |
| ---------- | ----------------------------------------------------------------------------- | ----------------------------------------------- |
| ðŸŽ¥ Video    | [Yannic Kilcher's Paper Explanations](https://www.youtube.com/@YannicKilcher) | Best ML paper walkthroughs on YouTube           |
| ðŸ”§ Hands-on | [Semantic Scholar](https://www.semanticscholar.org/)                          | AI-powered paper search and citation graph      |
| ðŸ”§ Hands-on | [Papers With Code](https://paperswithcode.com/)                               | Papers linked to implementations and benchmarks |

## â˜… Sources
- S. Keshav, "How to Read a Paper"
- reproducibility guidance from major ML venues
- [LLM Evaluation Deep Dive](../evaluation/llm-evaluation-deep-dive.md)
