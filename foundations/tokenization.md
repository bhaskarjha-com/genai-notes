---
title: "Tokenization"
tags: [tokenization, bpe, wordpiece, sentencepiece, llm-internals, genai-foundations]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["transformers.md", "embeddings.md", "../llms/llms-overview.md"]
source: "Sennrich et al. (BPE, 2016), SentencePiece, tiktoken"
created: 2026-03-18
updated: 2026-04-11
---

# Tokenization

> ✨ **Bit**: LLMs don't see words. They see token IDs. "Hello" = `[15496]`. This is why they can't count the letters in "strawberry" — they see something like `[" straw", "berry"]`, not individual characters.

---

## ★ TL;DR

- **What**: The process of breaking text into sub-word units (tokens) that LLMs actually process
- **Why**: Models can't process raw text. Tokenization determines what the model "sees" — and affects cost, multilingual performance, and model behavior
- **Key point**: ~4 English characters ≈ 1 token. Non-English text is often 2-3x more tokens per word (= more expensive, slower).

---

## ★ Overview

### Definition

**Tokenization** is the process of converting raw text into a sequence of discrete units (tokens) that a language model can process. Modern tokenizers use **sub-word algorithms** that split text into pieces between individual characters and full words, creating a vocabulary that balances expressiveness with efficiency.

### Scope

Covers tokenization algorithms (BPE, WordPiece, SentencePiece), practical implications, and model-specific tokenizers. For what happens after tokenization (embeddings), see [Embeddings](./embeddings.md).

### Significance

- Directly affects API cost (pricing is per-token)
- Determines multilingual capability (poor tokenizers = expensive for non-English)
- Explains many LLM "failures" (can't count letters, bad at math = tokenization artifacts)
- Different models use different tokenizers — tokens aren't transferable

### Prerequisites

- Basic understanding of what [Large Language Models (LLMs)](../llms/llms-overview.md) are

---

## ★ Deep Dive

### Why Not Just Use Words or Characters?

```
WORD-LEVEL:
  Vocabulary: Every word in every language = unlimited
  Problem: "unhappiness" = unknown word? Need infinite vocabulary.

CHARACTER-LEVEL:
  Vocabulary: ~100 characters (a-z, A-Z, 0-9, punctuation)
  Problem: "transformer" = 11 tokens. Sequences become way too long.

SUB-WORD (what we actually use):
  Vocabulary: 32K - 128K tokens
  "unhappiness" → ["un", "happiness"]  ← Common words stay whole
  "transformer" → ["transform", "er"]   ← Rare words split intelligently
  Balance: Compact vocabulary + handles any text
```

### How BPE Works (Most Common Algorithm)

**Byte Pair Encoding** (BPE) — used by GPT, LLaMA, Mistral:

```
START: Split everything into characters
  "lower" → ['l', 'o', 'w', 'e', 'r']
  "lowest" → ['l', 'o', 'w', 'e', 's', 't']

STEP 1: Find most frequent pair → ('l', 'o') appears most
  Merge: "lo" becomes a token
  "lower" → ['lo', 'w', 'e', 'r']

STEP 2: Find most frequent pair → ('lo', 'w')
  Merge: "low" becomes a token
  "lower" → ['low', 'e', 'r']

STEP 3: ('e', 'r') is frequent
  Merge: "er" becomes a token
  "lower" → ['low', 'er']

STEP 4: ('low', 'er') is frequent
  Merge: "lower" becomes a token
  "lower" → ['lower']

... Continue until vocabulary reaches target size (32K-128K)
```

### Tokenization Algorithms Compared

| Algorithm         | Used By                        | Key Difference                                                     |
| ----------------- | ------------------------------ | ------------------------------------------------------------------ |
| **BPE**           | GPT-2/3/4/5, LLaMA, Mistral    | Merge most frequent byte pairs bottom-up                           |
| **WordPiece**     | BERT, DistilBERT               | Like BPE but maximizes likelihood of training data                 |
| **Unigram**       | T5, ALBERT (via SentencePiece) | Starts with large vocab, prunes least useful tokens                |
| **SentencePiece** | LLaMA, Gemma, T5               | Language-agnostic, treats input as raw bytes (no pre-tokenization) |

### Practical Impact

```python
# ⚠️ Last tested: 2026-04
# Using OpenAI's tiktoken
import tiktoken
enc = tiktoken.encoding_for_model("gpt-4o")

# English is efficient:
tokens = enc.encode("Hello, how are you?")
print(len(tokens))         # 6 tokens
print(tokens)              # [9906, 11, 1268, 527, 499, 30]

# Code is less efficient:
tokens = enc.encode("def calculate_fibonacci(n):")
print(len(tokens))         # 7 tokens

# Non-English is expensive:
tokens = enc.encode("नमस्ते, आप कैसे हैं?")  # Hindi
print(len(tokens))         # 20+ tokens for same meaning!

# This means Hindi/Arabic/CJK users pay 2-4x more per API call
```

### Vocabulary Sizes Across Models

| Model          | Vocab Size | Tokenizer                   |
| -------------- | ---------- | --------------------------- |
| GPT-2          | 50,257     | BPE (tiktoken)              |
| GPT-4 / GPT-4o | 100,277    | BPE (tiktoken, cl100k_base) |
| GPT-5          | ~200,000   | BPE (tiktoken, o200k_base)  |
| LLaMA 2        | 32,000     | SentencePiece (BPE)         |
| LLaMA 3/4      | 128,256    | SentencePiece (BPE)         |
| Gemini         | 256,000    | SentencePiece               |
| Claude         | ~100,000   | BPE variant                 |

**Trend**: Vocab sizes are GROWING. Larger vocab = fewer tokens per text = faster inference but larger embedding table.

### Special Tokens

```
Common special tokens across models:

<|begin_of_text|>   → Start of sequence
<|end_of_text|>     → End of sequence / stop generating
<|im_start|>        → Start of a message (ChatML format)
<|im_end|>          → End of a message
<|system|>          → System prompt marker

These are NOT part of the text — they're control signals the model was trained on.
Different models use different special tokens (not compatible).
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                      | ❌ Limitations                                             |
| ------------------------------------------------ | --------------------------------------------------------- |
| Sub-word = handles any text (even made-up words) | Non-English languages get more tokens per word = inequity |
| Fixed vocabulary = predictable model size        | Arithmetic is hard (numbers split unpredictably)          |
| BPE is fast and deterministic                    | Character-level tasks (counting letters, reversal) fail   |
| Tokenizers are model-specific and well-tested    | Can't easily swap tokenizers between models               |

---

## ◆ Quick Reference

```
TOKEN ESTIMATION:
  1 token ≈ 4 characters (English)
  1 token ≈ ¾ of a word (English)
  100 tokens ≈ 75 words
  1 page ≈ 300 tokens

COST IMPACT (example at $3/1M tokens):
  1,000 word document ≈ 1,300 tokens ≈ $0.004
  Full book (80K words) ≈ 100K tokens ≈ $0.30

TOOLS:
  tiktoken (OpenAI): pip install tiktoken
  tokenizers (HuggingFace): pip install tokenizers
  Online: platform.openai.com/tokenizer
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **"Why can't GPT count letters in strawberry?"** — Because it sees `["straw", "berry"]`, not individual characters. It literally can't see the letters.
- ⚠️ **Token ≠ word**: Never estimate costs by word count. Always use the tokenizer library.
- ⚠️ **Multilingual cost surprise**: Hindi/Arabic/Japanese text can be 2-4x more tokens than equivalent English.
- ⚠️ **Context window is in tokens**: "128K context" means 128K tokens, not characters or words. In English, that's roughly 96K words.
- ⚠️ **Leading whitespace matters**: `" hello"` (with space) and `"hello"` are often different tokens.

---

## ○ Interview Angles

- **Q**: Why do LLMs use sub-word tokenization instead of word-level?
- **A**: Word-level requires an impossibly large vocabulary (every word in every language) and can't handle misspellings, new words, or code. Sub-word splits rare words into common pieces ("unhappiness" → ["un", "happiness"]) while keeping frequent words whole. Fixed vocab size (~32K-128K), handles any input.

- **Q**: Why is tokenization a source of bias?
- **A**: Languages with less representation in training data get worse tokenization — more tokens per word. This means non-English users spend more money, get slower responses, and use more of their context window for the same content. Larger vocabularies (LLaMA 3's 128K vs LLaMA 2's 32K) help mitigate this.

---

## ★ Connections

| Relationship | Topics                                                                    |
| ------------ | ------------------------------------------------------------------------- |
| Builds on    | String processing, Compression algorithms (BPE originated in compression) |
| Leads to     | [Embeddings](./embeddings.md) (tokens → vectors), [Large Language Models (LLMs)](../llms/llms-overview.md)           |
| Compare with | Character encoding (ASCII/UTF-8), Word-level parsing                      |
| Cross-domain | Linguistic morphology, Data compression                                   |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Token count mismatch** | Context window overflow despite short text | Different tokenizers produce different counts; code/non-English inflate tokens | Use exact model tokenizer (tiktoken), not character heuristics |
| **Multilingual over-tokenization** | Non-English text uses 2-5x more tokens | BPE trained primarily on English corpus | Multilingual tokenizers, language-specific models |
| **Special token injection** | User input contains control tokens that alter behavior | No input sanitization | Strip or escape special tokens from user input |

---

## ◆ Hands-On Exercises

### Exercise 1: Token Economics Calculator

**Goal**: Build a tool that estimates API cost from text input
**Time**: 20 minutes
**Steps**:
1. Use tiktoken to count tokens for 10 sample texts (English, code, multilingual)
2. Calculate cost at GPT-4o pricing per input/output
3. Compare token counts across languages and content types
**Expected Output**: Cost table showing 2-3x variance across languages
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Sennrich et al. "BPE for Neural Machine Translation" (2016)](https://arxiv.org/abs/1508.07909) | The paper that introduced BPE to NLP |
| 🎥 Video | [Andrej Karpathy — "Let's Build GPT Tokenizer"](https://www.youtube.com/watch?v=zduSFxRajkE) | Build BPE from scratch — best practical walkthrough |
| 🔧 Hands-on | [HuggingFace Tokenizers Library](https://huggingface.co/docs/tokenizers/) | Fast, production-grade tokenizer implementations |
| 📘 Book | "Build a Large Language Model (From Scratch)" by Sebastian Raschka (2024), Ch 2 | Tokenizer implementation with BPE and SentencePiece |

## ★ Sources

- Sennrich et al., "Neural Machine Translation of Rare Words with Subword Units" (BPE, 2016)
- Kudo & Richardson, "SentencePiece: A simple and language independent subword tokenizer" (2018)
- OpenAI tiktoken — https://github.com/openai/tiktoken
- Hugging Face Tokenizers — https://huggingface.co/docs/tokenizers
