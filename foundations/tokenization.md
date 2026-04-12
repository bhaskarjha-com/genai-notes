---
title: "Tokenization"
tags: [tokenization, bpe, wordpiece, sentencepiece, llm-internals, genai-foundations]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[transformers]]", "[[embeddings]]", "[[../llms/llms-overview]]"]
source: "Sennrich et al. (BPE, 2016), SentencePiece, tiktoken"
created: 2026-03-18
updated: 2026-04-11
---

# Tokenization

> âœ¨ **Bit**: LLMs don't see words. They see token IDs. "Hello" = `[15496]`. This is why they can't count the letters in "strawberry" â€” they see something like `[" straw", "berry"]`, not individual characters.

---

## â˜… TL;DR

- **What**: The process of breaking text into sub-word units (tokens) that LLMs actually process
- **Why**: Models can't process raw text. Tokenization determines what the model "sees" â€” and affects cost, multilingual performance, and model behavior
- **Key point**: ~4 English characters â‰ˆ 1 token. Non-English text is often 2-3x more tokens per word (= more expensive, slower).

---

## â˜… Overview

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

## â˜… Deep Dive

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
  "unhappiness" â†’ ["un", "happiness"]  â† Common words stay whole
  "transformer" â†’ ["transform", "er"]   â† Rare words split intelligently
  Balance: Compact vocabulary + handles any text
```

### How BPE Works (Most Common Algorithm)

**Byte Pair Encoding** (BPE) â€” used by GPT, LLaMA, Mistral:

```
START: Split everything into characters
  "lower" â†’ ['l', 'o', 'w', 'e', 'r']
  "lowest" â†’ ['l', 'o', 'w', 'e', 's', 't']

STEP 1: Find most frequent pair â†’ ('l', 'o') appears most
  Merge: "lo" becomes a token
  "lower" â†’ ['lo', 'w', 'e', 'r']

STEP 2: Find most frequent pair â†’ ('lo', 'w')
  Merge: "low" becomes a token
  "lower" â†’ ['low', 'e', 'r']

STEP 3: ('e', 'r') is frequent
  Merge: "er" becomes a token
  "lower" â†’ ['low', 'er']

STEP 4: ('low', 'er') is frequent
  Merge: "lower" becomes a token
  "lower" â†’ ['lower']

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
# Using OpenAI's tiktoken
import tiktoken
enc = tiktoken.encoding_for_model("gpt-5.4")

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

<|begin_of_text|>   â†’ Start of sequence
<|end_of_text|>     â†’ End of sequence / stop generating
<|im_start|>        â†’ Start of a message (ChatML format)
<|im_end|>          â†’ End of a message
<|system|>          â†’ System prompt marker

These are NOT part of the text â€” they're control signals the model was trained on.
Different models use different special tokens (not compatible).
```

---

## â—† Strengths vs Limitations

| âœ… Strengths                                      | âŒ Limitations                                             |
| ------------------------------------------------ | --------------------------------------------------------- |
| Sub-word = handles any text (even made-up words) | Non-English languages get more tokens per word = inequity |
| Fixed vocabulary = predictable model size        | Arithmetic is hard (numbers split unpredictably)          |
| BPE is fast and deterministic                    | Character-level tasks (counting letters, reversal) fail   |
| Tokenizers are model-specific and well-tested    | Can't easily swap tokenizers between models               |

---

## â—† Quick Reference

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

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **"Why can't GPT count letters in strawberry?"** â€” Because it sees `["straw", "berry"]`, not individual characters. It literally can't see the letters.
- âš ï¸ **Token â‰  word**: Never estimate costs by word count. Always use the tokenizer library.
- âš ï¸ **Multilingual cost surprise**: Hindi/Arabic/Japanese text can be 2-4x more tokens than equivalent English.
- âš ï¸ **Context window is in tokens**: "128K context" means 128K tokens, not characters or words. In English, that's roughly 96K words.
- âš ï¸ **Leading whitespace matters**: `" hello"` (with space) and `"hello"` are often different tokens.

---

## â—‹ Interview Angles

- **Q**: Why do LLMs use sub-word tokenization instead of word-level?
- **A**: Word-level requires an impossibly large vocabulary (every word in every language) and can't handle misspellings, new words, or code. Sub-word splits rare words into common pieces ("unhappiness" â†’ ["un", "happiness"]) while keeping frequent words whole. Fixed vocab size (~32K-128K), handles any input.

- **Q**: Why is tokenization a source of bias?
- **A**: Languages with less representation in training data get worse tokenization â€” more tokens per word. This means non-English users spend more money, get slower responses, and use more of their context window for the same content. Larger vocabularies (LLaMA 3's 128K vs LLaMA 2's 32K) help mitigate this.

---

## â˜… Connections

| Relationship | Topics                                                                    |
| ------------ | ------------------------------------------------------------------------- |
| Builds on    | String processing, Compression algorithms (BPE originated in compression) |
| Leads to     | [Embeddings](./embeddings.md) (tokens â†’ vectors), [Large Language Models (LLMs)](../llms/llms-overview.md)           |
| Compare with | Character encoding (ASCII/UTF-8), Word-level parsing                      |
| Cross-domain | Linguistic morphology, Data compression                                   |

---

## â˜… Sources

- Sennrich et al., "Neural Machine Translation of Rare Words with Subword Units" (BPE, 2016)
- Kudo & Richardson, "SentencePiece: A simple and language independent subword tokenizer" (2018)
- OpenAI tiktoken â€” https://github.com/openai/tiktoken
- Hugging Face Tokenizers â€” https://huggingface.co/docs/tokenizers
