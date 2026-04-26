---
title: "Tokenization"
aliases: ["Tokenizer", "BPE", "SentencePiece"]
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

> ✨ **Bit**: LLMs don't see words. They see token IDs. "Hello" = `[15496]`. This is why they can't count the letters in "strawberry" â€” they see something like `[" straw", "berry"]`, not individual characters.

---

## ★ TL;DR

- **What**: The process of breaking text into sub-word units (tokens) that LLMs actually process
- **Why**: Models can't process raw text. Tokenization determines what the model "sees" â€” and affects cost, multilingual performance, and model behavior
- **Key point**: ~4 English characters â‰ˆ 1 token. Non-English text is often 2-3x more tokens per word (= more expensive, slower).

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
- Different models use different tokenizers â€” tokens aren't transferable

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
  "unhappiness" → ["un", "happiness"]  â† Common words stay whole
  "transformer" → ["transform", "er"]   â† Rare words split intelligently
  Balance: Compact vocabulary + handles any text
```

### How BPE Works (Most Common Algorithm)

**Byte Pair Encoding** (BPE) â€” used by GPT, LLaMA, Mistral:

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
# âš ï¸ Last tested: 2026-04
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
tokens = enc.encode("à¤¨à¤®à¤¸à¥à¤¤à¥‡, à¤†à¤ª à¤•à¥ˆà¤¸à¥‡ à¤¹à¥ˆà¤‚?")  # Hindi
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

These are NOT part of the text â€” they're control signals the model was trained on.
Different models use different special tokens (not compatible).
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths                                      | âŒ Limitations                                             |
| ------------------------------------------------ | --------------------------------------------------------- |
| Sub-word = handles any text (even made-up words) | Non-English languages get more tokens per word = inequity |
| Fixed vocabulary = predictable model size        | Arithmetic is hard (numbers split unpredictably)          |
| BPE is fast and deterministic                    | Character-level tasks (counting letters, reversal) fail   |
| Tokenizers are model-specific and well-tested    | Can't easily swap tokenizers between models               |

---

## ◆ Quick Reference

```
TOKEN ESTIMATION:
  1 token â‰ˆ 4 characters (English)
  1 token â‰ˆ Â¾ of a word (English)
  100 tokens â‰ˆ 75 words
  1 page â‰ˆ 300 tokens

COST IMPACT (example at $3/1M tokens):
  1,000 word document â‰ˆ 1,300 tokens â‰ˆ $0.004
  Full book (80K words) â‰ˆ 100K tokens â‰ˆ $0.30

TOOLS:
  tiktoken (OpenAI): pip install tiktoken
  tokenizers (HuggingFace): pip install tokenizers
  Online: platform.openai.com/tokenizer
```

---

## ○ Gotchas & Common Mistakes

- âš ï¸ **"Why can't GPT count letters in strawberry?"** â€” Because it sees `["straw", "berry"]`, not individual characters. It literally can't see the letters.
- âš ï¸ **Token â‰  word**: Never estimate costs by word count. Always use the tokenizer library.
- âš ï¸ **Multilingual cost surprise**: Hindi/Arabic/Japanese text can be 2-4x more tokens than equivalent English.
- âš ï¸ **Context window is in tokens**: "128K context" means 128K tokens, not characters or words. In English, that's roughly 96K words.
- âš ï¸ **Leading whitespace matters**: `" hello"` (with space) and `"hello"` are often different tokens.

---

## ○ Interview Angles

- **Q**: Why do LLMs use sub-word tokenization instead of word-level?
- **A**: Word-level requires an impossibly large vocabulary (every word in every language) and can't handle misspellings, new words, or code. Sub-word splits rare words into common pieces ("unhappiness" → ["un", "happiness"]) while keeping frequent words whole. Fixed vocab size (~32K-128K), handles any input.

- **Q**: Why is tokenization a source of bias?
- **A**: Languages with less representation in training data get worse tokenization â€” more tokens per word. This means non-English users spend more money, get slower responses, and use more of their context window for the same content. Larger vocabularies (LLaMA 3's 128K vs LLaMA 2's 32K) help mitigate this.

---

## ★ Code & Implementation

### Token Cost Calculator (tiktoken)

```python
# pip install tiktoken>=0.6
# âš ï¸ Last tested: 2026-04 | Requires: tiktoken>=0.6
import tiktoken

enc = tiktoken.encoding_for_model("gpt-4o")

def token_cost_report(texts: dict[str, str], price_per_1m: float = 2.50) -> None:
    """Report token count and estimated cost for a dict of text samples."""
    print(f"{'Label':<25} {'Tokens':>8} {'Cost ($)':>12}")
    print("-" * 48)
    for label, text in texts.items():
        n = len(enc.encode(text))
        cost = (n / 1_000_000) * price_per_1m
        print(f"{label:<25} {n:>8,} {cost:>12.6f}")

samples = {
    "English (100 words)":  "The quick brown fox jumps over the lazy dog. " * 5,
    "Code (Python func)":   "def fibonacci(n):\n    if n <= 1:\n        return n\n    return fibonacci(n-1) + fibonacci(n-2)\n" * 3,
    "Hindi (same meaning)":  "à¤¨à¤®à¤¸à¥à¤¤à¥‡, à¤†à¤ª à¤•à¥ˆà¤¸à¥‡ à¤¹à¥ˆà¤‚? à¤®à¥ˆà¤‚ à¤ à¥€à¤• à¤¹à¥‚à¤à¥¤ " * 10,   # 2-4x more tokens
    "JSON (structured)":    '{"name": "Alice", "age": 30, "city": "Tokyo"}\n' * 10,
}
token_cost_report(samples)
# English: ~75 tokens  â€” Hindi: ~200+ tokens for equivalent content
```

### Cross-Model Token Comparison

```python
# âš ï¸ Last tested: 2026-04 | Requires: tiktoken>=0.6, transformers>=4.40
import tiktoken
from transformers import AutoTokenizer

text = "The transformer architecture revolutionized natural language processing in 2017."

# OpenAI tokenizers
for model in ["gpt-4o", "gpt-3.5-turbo"]:
    enc = tiktoken.encoding_for_model(model)
    tokens = enc.encode(text)
    print(f"OpenAI {model}: {len(tokens)} tokens → {tokens}")

# HuggingFace tokenizers
for hf_model in ["meta-llama/Llama-3.2-1B", "google/gemma-2-2b"]:
    tok = AutoTokenizer.from_pretrained(hf_model)
    tokens = tok.encode(text)
    print(f"HF {hf_model.split('/')[-1]}: {len(tokens)} tokens")
# Different tokenizers → different counts for same text
# This is why you MUST use the correct tokenizer for each model
```

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
| ðŸ“„ Paper | [Sennrich et al. "BPE for Neural Machine Translation" (2016)](https://arxiv.org/abs/1508.07909) | The paper that introduced BPE to NLP |
| ðŸŽ¥ Video | [Andrej Karpathy â€” "Let's Build GPT Tokenizer"](https://www.youtube.com/watch?v=zduSFxRajkE) | Build BPE from scratch â€” best practical walkthrough |
| ðŸ”§ Hands-on | [HuggingFace Tokenizers Library](https://huggingface.co/docs/tokenizers/) | Fast, production-grade tokenizer implementations |
| ðŸ“˜ Book | "Build a Large Language Model (From Scratch)" by Sebastian Raschka (2024), Ch 2 | Tokenizer implementation with BPE and SentencePiece |

## ★ Sources

- Sennrich et al., "Neural Machine Translation of Rare Words with Subword Units" (BPE, 2016)
- Kudo & Richardson, "SentencePiece: A simple and language independent subword tokenizer" (2018)
- OpenAI tiktoken â€” https://github.com/openai/tiktoken
- Hugging Face Tokenizers â€” https://huggingface.co/docs/tokenizers
