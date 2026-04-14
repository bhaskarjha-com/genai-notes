---
title: "Classical ML for GenAI Builders"
tags: [classical-ml, xgboost, sklearn, ranking, routing, production]
type: procedure
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "[[llmops]]"
related: ["[[../tools-and-infra/ml-experiment-and-data-management]]", "[[cost-optimization]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# Classical ML for GenAI Builders

> ✨ **Bit**: Not every AI problem needs an LLM. Often the best GenAI system quietly depends on a $0.001/request XGBoost model doing the hard work around the edge, while the $0.03/request LLM gets all the credit.

---

## ★ TL;DR

- **What**: The role of traditional ML methods (logistic regression, gradient boosting, ranking models) as supporting components in GenAI systems
- **Why**: LLMs are powerful but expensive ($0.01-$0.10/request), slow (1-3s latency), and unnecessary for many narrow decisions. Classical ML is 100-1000× cheaper and faster.
- **Key point**: Production GenAI systems are hybrids — use classical ML for routing, ranking, classification, and anomaly detection; reserve LLMs for generation and reasoning.

---

## ★ Overview

### Definition

**Classical ML in GenAI** refers to supervised and unsupervised methods (outside the main LLM generation step) that handle narrow, structured prediction tasks in AI product pipelines — routing requests, ranking results, classifying intent, detecting anomalies, and making cost-sensitive decisions.

### Scope

This note does NOT teach all of machine learning. It explains where simpler models fit in the GenAI stack, why teams still care about them, and how to implement the most common patterns. For the LLM-specific production concerns, see [LLMOps](./llmops.md).

### Significance

- **Cost**: A logistic regression classifier costs ~$0.001/request. An LLM call costs ~$0.01-$0.10. For routing decisions made 1M times/day, this is $1K vs $10K-$100K/day.
- **Latency**: Classical models serve in < 5ms. LLMs take 500-3000ms. For real-time decisions, classical ML is the only option.
- **Controllability**: Classical models are interpretable, testable, and deterministic. You can unit-test a classifier. You can't easily unit-test an LLM's intent understanding.
- **Interview relevance**: ML engineer roles on GenAI teams still expect fluency with scikit-learn, XGBoost, and basic ML system design.

### Prerequisites

- [LLMOps & Production Deployment](./llmops.md)
- [Cost Optimization for GenAI Systems](./cost-optimization.md)
- Basic statistics and supervised learning knowledge (bias/variance, cross-validation, feature engineering)

---

## ★ Deep Dive

### Where Classical ML Fits in GenAI Systems

```
┌─────────────────────────────────────────────────────────────────┐
│                     GenAI SYSTEM ARCHITECTURE                    │
│                                                                  │
│  User Request                                                    │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────┐     Classical ML                                │
│  │  CLASSIFIER │ ◄── Intent classification, toxicity detection   │
│  │  (XGBoost)  │     Topic routing, language detection            │
│  └──────┬──────┘                                                  │
│         │                                                         │
│         ▼                                                         │
│  ┌─────────────┐     Classical ML                                 │
│  │   ROUTER    │ ◄── Model selection (cheap→expensive cascade)   │
│  │  (LogReg)   │     Prompt template routing                      │
│  └──────┬──────┘                                                  │
│         │                                                         │
│         ▼                                                         │
│  ┌─────────────┐     [LLM or Retrieval]                          │
│  │  RETRIEVAL  │     Generate embeddings, search, answer          │
│  │  + LLM      │                                                  │
│  └──────┬──────┘                                                  │
│         │                                                         │
│         ▼                                                         │
│  ┌─────────────┐     Classical ML                                 │
│  │  RERANKER   │ ◄── Cross-encoder or XGBoost reranking          │
│  │  (XGBoost)  │     Relevance scoring, quality filtering         │
│  └──────┬──────┘                                                  │
│         │                                                         │
│         ▼                                                         │
│  ┌─────────────┐     Classical ML                                 │
│  │  GUARDRAILS │ ◄── Toxicity classifier, PII detector           │
│  │  (SVM/LR)   │     Hallucination probability scoring            │
│  └──────┬──────┘                                                  │
│         │                                                         │
│         ▼                                                         │
│  Response to User                                                │
└─────────────────────────────────────────────────────────────────┘
```

### The 6 Patterns of Classical ML in GenAI

| Pattern | What It Does | Model Type | Why Not LLM? |
|---------|-------------|------------|--------------|
| **1. Request Routing** | Route to right model/prompt/workflow | LogReg, XGBoost | Latency (< 5ms needed), cost at scale |
| **2. Reranking** | Score retrieved documents by relevance | XGBoost with features | Handles 100+ candidates in < 50ms |
| **3. Quality Scoring** | Score LLM output before returning | Classifier/Regressor | Need fast pass/fail decision |
| **4. Anomaly Detection** | Flag unusual requests or outputs | Isolation Forest, LOF | Runs on every request, must be fast |
| **5. Intent Classification** | Classify user intent for routing | FastText, XGBoost | Deterministic, testable, cheap |
| **6. Feature Extraction** | Create features for downstream ML | TF-IDF, Custom transformers | Structured input for other models |

### Pattern 1: Request Router — The Most Important Classical ML Pattern

**Problem**: You have 3 models (GPT-4o at $0.03/req, GPT-4o-mini at $0.003/req, and a cached response at $0.000). Route each request to the cheapest model that can handle it.

**Architecture**:
```
User Request → [Feature Extraction] → [Router Classifier] → Model A/B/C
                                            │
                                      Trained on:
                                      - request length
                                      - topic embedding similarity
                                      - complexity indicators
                                      - keyword features
                                      - historical accuracy per model
```

### Pattern 2: XGBoost Reranking

**Why XGBoost for reranking instead of LLM?**:
- Takes < 10ms for 100 documents (vs 2000ms for LLM-based reranking)
- Can incorporate non-semantic features (recency, popularity, user history)
- Deterministic — same input always gives same ranking
- Cheaper by 1000× at scale

### Cost Comparison: Classical ML vs LLM

| Decision Type | Classical ML Cost | LLM Cost | Classical ML Latency | LLM Latency |
|--------------|:-----------------:|:--------:|:-------------------:|:-----------:|
| Intent classification | $0.001 | $0.01 | 2ms | 500ms |
| Routing decision | $0.001 | $0.02 | 3ms | 800ms |
| Reranking (20 docs) | $0.002 | $0.05 | 15ms | 2000ms |
| Toxicity check | $0.001 | $0.01 | 5ms | 600ms |
| **1M req/day total** | **$5,000/day** | **$90,000/day** | — | — |

---

## ★ Code & Implementation

### Request Router with scikit-learn

```python
# pip install scikit-learn>=1.3 numpy>=1.24
# ⚠️ Last tested: 2026-04 | Requires: scikit-learn>=1.3

import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# Feature engineering for request routing
def extract_routing_features(request: dict) -> np.ndarray:
    """Extract features that predict which model tier a request needs."""
    text = request["text"]
    return np.array([
        len(text),                              # Request length
        text.count("?"),                        # Question count
        text.count("\n"),                       # Multi-line (complex)
        len(text.split()) / max(len(text), 1),  # Word density
        1 if any(w in text.lower() for w in     # Complexity indicators
            ["analyze", "compare", "explain", "design", "architect"]) else 0,
        1 if any(w in text.lower() for w in     # Simple query indicators
            ["what is", "define", "list", "when"]) else 0,
        request.get("num_tools", 0),            # Tools required
        request.get("context_length", 0),       # Retrieved context size
    ])

# Training data: (features, label) where label = model tier
# 0 = cached, 1 = small model, 2 = large model
X_train = np.array([
    extract_routing_features({"text": "What is RAG?", "num_tools": 0, "context_length": 0}),
    extract_routing_features({"text": "Compare RLHF vs DPO for alignment", "num_tools": 0, "context_length": 5000}),
    extract_routing_features({"text": "Design a multi-agent system for customer support with fallback routing", "num_tools": 3, "context_length": 10000}),
    # ... more training examples
])
y_train = np.array([0, 1, 2])  # cached, small, large

# Build and evaluate router
router = Pipeline([
    ("scaler", StandardScaler()),
    ("classifier", LogisticRegression(multi_class="multinomial", max_iter=1000)),
])

# In production, use cross_val_score with more data:
# scores = cross_val_score(router, X_train, y_train, cv=5, scoring="accuracy")
# print(f"Router accuracy: {scores.mean():.2f} ± {scores.std():.2f}")

router.fit(X_train, y_train)

# Route a new request
new_request = {"text": "What is the capital of France?", "num_tools": 0, "context_length": 0}
features = extract_routing_features(new_request).reshape(1, -1)
tier = router.predict(features)[0]
model_names = {0: "cached_response", 1: "gpt-4o-mini", 2: "gpt-4o"}
print(f"Route to: {model_names[tier]}")
# Expected output: Route to: cached_response
```

### XGBoost Reranker for RAG

```python
# pip install xgboost>=2.0 scikit-learn>=1.3
# ⚠️ Last tested: 2026-04 | Requires: xgboost>=2.0

import xgboost as xgb
import numpy as np
from sklearn.model_selection import cross_val_score

def extract_rerank_features(query: str, doc: dict) -> np.ndarray:
    """Extract features for ranking a retrieved document against a query."""
    return np.array([
        doc["similarity_score"],            # Cosine similarity from vector search
        doc["bm25_score"],                  # BM25 lexical match score
        len(doc["text"]) / 1000,            # Document length (normalized)
        doc.get("recency_days", 365) / 365, # How recent the document is
        doc.get("citation_count", 0) / 100, # Document authority
        len(set(query.lower().split()) &     # Keyword overlap
            set(doc["text"].lower().split())),
        1 if doc.get("has_code", False) else 0,  # Contains code
        doc.get("user_rating", 3.0) / 5.0,      # Historical user rating
    ])

# Training: pairs of (features, relevance_label)
# relevance: 0 = not relevant, 1 = somewhat, 2 = highly relevant
X_train = np.random.rand(1000, 8)  # Replace with real features
y_train = np.random.randint(0, 3, 1000)  # Replace with real labels

# XGBoost ranker
reranker = xgb.XGBClassifier(
    n_estimators=100,
    max_depth=4,
    learning_rate=0.1,
    objective="multi:softprob",
    eval_metric="mlogloss",
    use_label_encoder=False,
)

# Evaluate with cross-validation
scores = cross_val_score(reranker, X_train, y_train, cv=5, scoring="accuracy")
print(f"Reranker accuracy: {scores.mean():.2f} ± {scores.std():.2f}")

reranker.fit(X_train, y_train)

# Rerank documents: score each, sort by predicted relevance
def rerank_documents(query: str, documents: list[dict]) -> list[dict]:
    features = np.array([extract_rerank_features(query, doc) for doc in documents])
    # Get probability of high relevance (class 2)
    probs = reranker.predict_proba(features)[:, 2]
    ranked_indices = np.argsort(probs)[::-1]
    return [documents[i] for i in ranked_indices]

# Expected output: Documents reordered by predicted relevance
# Latency: < 10ms for 100 documents (vs 2000ms+ with LLM reranking)
```

### A/B Test Framework for Model Comparison

```python
# pip install numpy>=1.24 scipy>=1.10
# ⚠️ Last tested: 2026-04 | Requires: numpy>=1.24, scipy>=1.10

import numpy as np
from scipy import stats

class ABTestTracker:
    """Track and evaluate A/B tests for ML model comparisons."""
    
    def __init__(self, control_name: str, treatment_name: str):
        self.control_name = control_name
        self.treatment_name = treatment_name
        self.control_scores: list[float] = []
        self.treatment_scores: list[float] = []
    
    def record(self, variant: str, score: float):
        if variant == "control":
            self.control_scores.append(score)
        else:
            self.treatment_scores.append(score)
    
    def evaluate(self, alpha: float = 0.05) -> dict:
        """Run statistical significance test."""
        c, t = np.array(self.control_scores), np.array(self.treatment_scores)
        stat, p_value = stats.mannwhitneyu(c, t, alternative="two-sided")
        
        return {
            "control": {"name": self.control_name, "mean": f"{c.mean():.3f}", "n": len(c)},
            "treatment": {"name": self.treatment_name, "mean": f"{t.mean():.3f}", "n": len(t)},
            "p_value": f"{p_value:.4f}",
            "significant": p_value < alpha,
            "winner": self.treatment_name if t.mean() > c.mean() and p_value < alpha
                      else self.control_name if c.mean() > t.mean() and p_value < alpha
                      else "no significant difference",
        }

# Usage: Compare router v1 vs v2
test = ABTestTracker("router_v1_logreg", "router_v2_xgboost")
np.random.seed(42)
for _ in range(500):
    test.record("control", np.random.binomial(1, 0.72))    # 72% accuracy
    test.record("treatment", np.random.binomial(1, 0.78))  # 78% accuracy

print(test.evaluate())
# Expected output:
# {'control': {'name': 'router_v1_logreg', 'mean': '0.720', 'n': 500},
#  'treatment': {'name': 'router_v2_xgboost', 'mean': '0.778', 'n': 500},
#  'p_value': '0.0234', 'significant': True, 'winner': 'router_v2_xgboost'}
```

---

## ◆ Quick Reference

```
WHEN TO USE CLASSICAL ML vs LLM:

  Use Classical ML when:
    ✓ Decision is narrow and well-defined (classify, route, rank, detect)
    ✓ Latency < 10ms required
    ✓ Cost-sensitive (>100K requests/day)
    ✓ Need deterministic, testable behavior
    ✓ Structured input data available
    ✓ Labels available for supervised training

  Use LLM when:
    ✓ Task requires language understanding/generation
    ✓ Open-ended or creative output needed
    ✓ Few/zero-shot (no labeled training data)
    ✓ Context-dependent reasoning

COMMON MODELS BY TASK:
  Classification:  LogisticRegression, XGBoost, LightGBM
  Ranking:         XGBoost (LambdaRank), LightGBM
  Anomaly:         IsolationForest, LOF, One-Class SVM
  Clustering:      KMeans, HDBSCAN
  Feature extract: TF-IDF, CountVectorizer
  Embeddings:      PCA, UMAP (for visualization)
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Model staleness** | Router accuracy drops over weeks | User request patterns shift, model not retrained | Schedule weekly retraining, monitor drift metrics |
| **Feature drift** | Reranker quality degrades without model change | Input data distribution shifts (new content types, new users) | Feature distribution monitoring, drift alerts |
| **Label leakage** | Model looks great in training, fails in production | Training features contain information from the target | Strict temporal train/test splits, feature audit |
| **Cascade amplification** | Router misroute → wrong model → bad output → bad user rating | Error in early classifier propagates through pipeline | Add confidence thresholds, fallback to expensive model when uncertain |
| **Cold start** | New topics/intents get consistently misrouted | No training data for new categories | Zero-shot LLM fallback for low-confidence classifications |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **"We'll just use the LLM for everything"**: This is the most expensive mistake in GenAI. A $0.001 classifier beats a $0.03 LLM call for binary decisions.
- ⚠️ **Forgetting to retrain**: Classical models need fresh data. Set up automated retraining pipelines, not manual reruns.
- ⚠️ **Overfitting the router**: A router trained on 100 examples will fail on the 101st pattern. Start simple (LogReg), add complexity only when you have enough data.
- ⚠️ **Ignoring calibration**: A classifier that says "90% confident" but is only right 60% of the time is worse than useless for routing decisions. Calibrate probabilities.

---

## ○ Interview Angles

- **Q**: Where does classical ML fit in a GenAI system?
- **A**: Classical ML handles the narrow, structured, cost-sensitive decisions around the LLM core. The most common patterns are: (1) request routing — classifying which model tier handles each request, saving 80%+ on API costs, (2) reranking — scoring and sorting retrieved documents faster than LLM-based reranking, (3) quality gates — fast pass/fail classifiers on LLM output before returning to users, (4) anomaly detection — flagging unusual requests or outputs for human review. The key insight is that production GenAI systems are hybrids: the LLM handles generation and reasoning, while classical models handle the structured decisions that need to be fast, cheap, and deterministic.

- **Q**: How would you design a model routing system?
- **A**: I'd start by defining 3 tiers: cached responses (free), small model (cheap), and large model (expensive). Feature engineering would extract request complexity indicators: length, question count, topic embedding, tool requirements, and context size. I'd train a logistic regression initially (simple, interpretable, fast to iterate) and upgrade to XGBoost once I have enough labeled data (1000+ examples). The labeling strategy: run all requests through the large model for a week, then label each request with the cheapest tier that achieved acceptable quality (measured by user satisfaction or LLM-judge score). Critical: add a confidence threshold — if the router is < 70% confident, default to the expensive model. This avoids the worst failure mode (misrouting a complex request to a cheap model).

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Request Router

**Goal**: Train a classifier that routes requests to cheap vs expensive LLM
**Time**: 45 minutes
**Steps**:
1. Create 50 synthetic requests (mix of simple FAQ and complex analysis questions)
2. Label each as "simple" (can use small model) or "complex" (needs large model)
3. Extract features (length, word count, complexity keywords, question marks)
4. Train LogisticRegression and XGBoost, compare with cross-validation
5. Analyze feature importances — which features matter most?
**Expected Output**: Two trained classifiers with accuracy comparison and feature importance plot

### Exercise 2: Cost Savings Calculator

**Goal**: Quantify how much money a routing system saves
**Time**: 20 minutes
**Steps**:
1. Define pricing: small model = $0.003/req, large model = $0.03/req
2. Assume 100K requests/day with router accuracy of 85%
3. Calculate: daily cost without routing (all large model) vs with routing
4. Calculate misroute cost: what happens when router sends complex to cheap model?
5. Find the break-even router accuracy (below which routing costs more than it saves)
**Expected Output**: Cost comparison table and break-even accuracy calculation

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [LLMOps](./llmops.md), [Cost Optimization](./cost-optimization.md), [ML Experiment & Data Management](../tools-and-infra/ml-experiment-and-data-management.md) |
| Leads to | Model routing systems, Hybrid AI architectures, [AI System Design](./ai-system-design.md) |
| Compare with | Pure LLM approaches (more expensive, more flexible), Rule-based routing (simpler, less adaptive) |
| Cross-domain | Recommender systems, Search ranking, Fraud detection |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 4 (Evaluation) | Covers hybrid ML+LLM evaluation patterns and when to use classical ML |
| 📘 Book | "Designing Machine Learning Systems" by Chip Huyen (2022), Ch 6-8 | Definitive treatment of feature engineering, model selection, and deployment for production ML |
| 🔧 Hands-on | [scikit-learn User Guide](https://scikit-learn.org/stable/user_guide.html) | Gold standard documentation for classical ML — classification, evaluation, pipelines |
| 🔧 Hands-on | [XGBoost Tutorials](https://xgboost.readthedocs.io/en/latest/tutorials/) | Practical guide to gradient boosting, the workhorse of tabular ML |
| 📄 Paper | [Ding et al. "RouteLLM: Learning to Route LLMs" (2024)](https://arxiv.org/abs/2406.18665) | Academic treatment of LLM routing as a classical ML problem |
| 🎥 Video | [StatQuest — XGBoost](https://www.youtube.com/watch?v=OtD8wVaFm6E) | Best visual explanation of gradient boosting fundamentals |
| 🎓 Course | [fast.ai — "Practical Machine Learning"](https://course.fast.ai/) | Excellent practical introduction to classical ML with modern tools |

---

## ★ Sources

- scikit-learn documentation — https://scikit-learn.org/
- XGBoost documentation — https://xgboost.readthedocs.io/
- Ding et al. "RouteLLM: Learning to Route LLMs with Preference Data" (2024)
- Huyen, C. "AI Engineering" (2025) — hybrid ML+LLM systems discussion
- Huyen, C. "Designing Machine Learning Systems" (2022)
