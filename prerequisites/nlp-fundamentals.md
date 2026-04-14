---
title: "NLP Fundamentals"
tags: [nlp, natural-language-processing, ner, sentiment, text-classification, bert, genai-prerequisite]
type: concept
difficulty: beginner
status: published
last_verified: 2026-04
parent: "[[../genai]]"
related: ["[[../foundations/transformers]]", "[[../foundations/embeddings]]", "[[../foundations/tokenization]]", "[[../llms/llms-overview]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# NLP Fundamentals

> ✨ **Bit**: Before GPT, NLP was a completely different world — specific models for specific tasks. Sentiment analysis? Train a model. Translation? Train a different model. Named entities? Yet another model. Then Transformers said "one model to rule them all" — and traditional NLP became a chapter in LLM history.

---

## ★ TL;DR

- **What**: The foundational techniques for understanding, processing, and generating human language — from classical methods to the Transformer revolution
- **Why**: GenAI REPLACED much of traditional NLP, but interviewers still ask about it. You need to know what came before to understand why GenAI is powerful.
- **Key point**: BERT (2018) = encoder Transformer (understand text). GPT (2018) = decoder Transformer (generate text). This encoder vs decoder split defined GenAI.

---

## ★ Overview

### Definition

**NLP (Natural Language Processing)** is the field of AI focused on enabling computers to understand, interpret, and generate human language. Pre-2018, it used task-specific models. Post-2018, Transformers unified most NLP tasks under one architecture.

### Scope

Covers classical NLP tasks, the BERT vs GPT paradigm, and how LLMs changed everything. For Transformer architecture, see [Transformers](../foundations/transformers.md). For modern LLM capabilities, see [Llms Overview](../llms/llms-overview.md).

---

## ★ Deep Dive

### NLP Task Landscape

| Task                         | What It Does                       | Classical Approach             | Modern (LLM) Approach           |
| ---------------------------- | ---------------------------------- | ------------------------------ | ------------------------------- |
| **Text Classification**      | Categorize text (spam/not spam)    | TF-IDF + SVM/Naive Bayes       | LLM zero-shot or fine-tuned     |
| **Sentiment Analysis**       | Detect emotion (positive/negative) | Lexicon-based + ML classifiers | LLM prompt: "Is this positive?" |
| **Named Entity Recognition** | Find names, places, dates          | CRF / BiLSTM-CRF               | LLM extraction + JSON output    |
| **Machine Translation**      | English → French                   | Seq2seq + attention            | LLM prompt or specialized model |
| **Summarization**            | Condense text                      | Extractive (select sentences)  | LLM abstractive summarization   |
| **Question Answering**       | Answer from context                | BERT fine-tuned on SQuAD       | LLM + RAG                       |
| **Text Generation**          | Write new text                     | RNNs, Markov chains            | GPT, Claude, LLaMA              |
| **POS Tagging**              | Label parts of speech              | HMM, CRF                       | Mostly replaced by LLMs         |

### The Pre-Transformer Era (Know This for Interviews)

```
TEXT REPRESENTATION EVOLUTION:

  BAG OF WORDS (BoW):
    "the cat sat on the mat"
    → {the: 2, cat: 1, sat: 1, on: 1, mat: 1}
    ❌ Ignores word order
    ❌ No semantics

  TF-IDF (Term Frequency × Inverse Document Frequency):
    Weights words by importance (rare words score higher)
    TF = count(word) / total_words
    IDF = log(total_docs / docs_containing_word)
    ✅ Better than BoW for retrieval
    ❌ Still no semantics

  WORD2VEC (2013):
    Learn 300-dim vectors where similar words are nearby
    "king" - "man" + "woman" ≈ "queen"
    ✅ Captures semantic relationships
    ❌ One vector per word (no context: "bank" = river or money?)

  ELMo (2018):
    Context-dependent embeddings using BiLSTM
    "bank" gets different vectors in different contexts
    ✅ Context-aware
    ❌ Sequential processing (slow)

  BERT / GPT (2018+):
    Transformer-based, attention-powered
    ✅ Deep context, parallel processing, state-of-the-art everything
```

### The BERT vs GPT Paradigm (Critical!)

```
THE FUNDAMENTAL SPLIT:

  ENCODER (BERT family):              DECODER (GPT family):
  "Understand text"                   "Generate text"

  Sees: ← all tokens →               Sees: ← only past tokens
  (bidirectional)                     (autoregressive, left-to-right)

  Training: Predict [MASK]ed words    Training: Predict next token
  "The [MASK] sat on the mat"        "The cat sat on the" → "mat"

  Output: Hidden representations      Output: Next token probabilities
  (good for classification, NER)      (good for generation)

  Models:                             Models:
  - BERT (2018)                       - GPT-1/2/3/4/5 (2018-)
  - RoBERTa (2019)                    - LLaMA (2023-)
  - DeBERTa (2020)                    - Claude (2023-)
  - ModernBERT (2024)                 - Gemini (2023-)

  Use when:                           Use when:
  - Classification                    - Text generation
  - Search / retrieval                - Chatbots
  - Token-level tasks (NER)           - Code generation
  - Embedding generation              - Anything creative

  GPT WON the scaling war.
  BERT family is still used for embeddings and classification
  but LLMs handle most NLP tasks now via prompting.
```

### Key Classical Concepts Still Relevant

```
NAMED ENTITY RECOGNITION (NER):
  Input:  "Apple Inc. was founded by Steve Jobs in Cupertino."
  Output: [Apple Inc.]=ORG  [Steve Jobs]=PERSON  [Cupertino]=LOCATION

  Modern approach: Use LLM with structured output
  → "Extract all entities as JSON: {persons: [], orgs: [], locations: []}"


SENTIMENT ANALYSIS:
  Input:  "This product is absolutely terrible, waste of money!"
  Output: NEGATIVE (confidence: 0.95)

  Modern approach: LLM prompt
  → "Rate the sentiment of this review: positive, negative, or neutral"


TEXT CLASSIFICATION:
  Input:  Support ticket text
  Output: Category (billing, technical, shipping)

  Modern approach:
  1. Zero-shot: Give LLM category list, ask it to classify
  2. Few-shot: Provide examples of each category
  3. Fine-tuned: LoRA-tune on your labeled data for best accuracy
```

### Information Extraction (Generative IE)

```
TRADITIONAL IE:            GENERATIVE IE (2025):
  Pipeline of models:        One LLM handles everything:
  1. NER model               prompt: "Extract from this text:
  2. Relation extraction        - Entities (person, org, loc)
  3. Event extraction           - Relations between entities
  4. Coreference resolution     - Key events
  5. Temporal extraction        - Return as JSON"

  6 models, 6 training runs   1 prompt, 1 model, done.
  Fragile pipeline             Robust, flexible, adaptable
```

---

## ◆ Quick Reference

```
NLP TASK → MODERN APPROACH:
  Classification      → Zero-shot LLM or fine-tuned classifier
  Sentiment           → LLM prompt or fine-tuned BERT
  NER                 → LLM with JSON output
  Translation         → NLLB, GPT-5.4, or fine-tuned model
  Summarization       → LLM (abstractive)
  Search              → Embedding model (BERT/BGE) + vector DB
  Q&A                 → RAG (retrieve + generate)

STILL RELEVANT IN 2026:
  TF-IDF       → BM25 search is still fast and effective
  BERT family  → Embeddings, classification, reranking
  spaCy        → Fast NER, POS, dependency parsing
  Regex        → Pattern extraction (dates, emails, IDs)

MOSTLY OBSOLETE:
  Word2Vec     → Replaced by contextual embeddings
  BiLSTM-CRF   → Replaced by Transformer models
  Seq2seq+attn → Replaced by Transformers
```

---

## ○ Interview Angles

- **Q**: What's the difference between BERT and GPT?
- **A**: BERT is an ENCODER that sees all tokens bidirectionally (optimized for understanding — classification, NER, embeddings). GPT is a DECODER that sees only past tokens (optimized for generation — text, code, chat). Both use Transformers, but BERT predicts masked tokens while GPT predicts the next token.

- **Q**: Has GenAI made traditional NLP obsolete?
- **A**: Mostly, yes. LLMs handle most NLP tasks via prompting, often better than task-specific models. However, BERT-based models survive for: (1) embeddings (BGE, E5), (2) sub-100ms classification at scale, (3) BM25/TF-IDF for initial retrieval in RAG. The field has consolidated around "one model, many tasks."

---

## ★ Connections

| Relationship | Topics                                                                                    |
| ------------ | ----------------------------------------------------------------------------------------- |
| Builds on    | [Neural Networks](./neural-networks.md), [Python For Ai](./python-for-ai.md)                  |
| Leads to     | [Transformers](../foundations/transformers.md), [Embeddings](../foundations/embeddings.md), [Llms Overview](../llms/llms-overview.md) |
| Compare with | Rule-based NLP (regex, grammars), Classical ML (SVM, CRF)                                 |
| Cross-domain | Linguistics, Information retrieval, Search engines                                        |

---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "Speech and Language Processing" by Jurafsky & Martin (3rd ed.) | The NLP bible — freely available online |
| 🎓 Course | [Stanford CS224n: NLP with Deep Learning](http://web.stanford.edu/class/cs224n/) | Best NLP course covering classical to modern methods |
| 🔧 Hands-on | [spaCy Course](https://course.spacy.io/) | Practical NLP with production-ready tools |

## ★ Sources

- Jurafsky & Martin, "Speech and Language Processing" (3rd ed.) — https://web.stanford.edu/~jurafsky/slp3/
- Devlin et al., "BERT: Pre-training of Deep Bidirectional Transformers" (2018)
- spaCy documentation — https://spacy.io
- HuggingFace NLP Course — https://huggingface.co/learn/nlp-course
