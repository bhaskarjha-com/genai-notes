---
title: "Structured Outputs & Constrained Generation"
tags: [structured-output, json-mode, constrained-decoding, pydantic, schema, function-calling, genai-technique]
type: procedure
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "function-calling-and-structured-output.md"
related: ["function-calling-and-structured-output.md", "prompt-engineering.md", "../production/guardrails-and-content-filtering.md", "../applications/api-design-for-ai.md"]
source: "Multiple — see Sources"
created: 2026-04-15
updated: 2026-04-15
---

# Structured Outputs & Constrained Generation

> ✨ **Bit**: JSON Mode tells the model "give me valid JSON." Structured Outputs tells the model "give me this exact schema, or nothing." The difference is the difference between hoping and enforcing.

---

## ★ TL;DR

- **What**: Techniques that force LLMs to produce output conforming to a specific schema — guaranteed structurally valid
- **Why**: Production data pipelines, tool calling, and API integrations require deterministic structure, not free-form text
- **Key point**: Native constrained decoding (token masking) is the 2026 standard — 100% syntactically reliable and faster than prompt-based approaches

---

## ★ Overview

### Definition

**Structured outputs** are LLM generation modes that guarantee the model's response conforms to a pre-defined schema (JSON Schema, Pydantic model, Zod type). **Constrained decoding** is the underlying mechanism: at each token generation step, the model's probability distribution is masked so it physically cannot emit tokens that violate the schema.

### Scope

This note covers the spectrum from basic JSON Mode through strict schema enforcement. For function calling and tool use (which shares the underlying mechanism but serves a different purpose), see [Function Calling & Structured Output](./function-calling-and-structured-output.md).

### Significance

- Every production GenAI pipeline that feeds LLM output into downstream code needs structured output
- Understanding constrained decoding is essential for debugging schema failures
- Interview-critical: "How do you ensure LLM output is always valid JSON?" is a standard question

### Prerequisites

- [Function Calling & Structured Output](./function-calling-and-structured-output.md)
- [Prompt Engineering](./prompt-engineering.md)

---

## ★ Deep Dive

### The Hierarchy of Output Control

| Method | Reliability | Speed | Use When |
|--------|:----------:|:-----:|----------|
| Prompt instructions ("reply in JSON") | ~70-80% | Baseline | Prototyping only |
| JSON Mode (`response_format: json_object`) | ~95% syntax | Fast | Legacy apps, no schema needed |
| **Structured Outputs** (strict schema) | **100% syntax** | Fast | Production data extraction |
| Function Calling / Tools | 100% syntax | Fast | Agentic tool selection |

### How Constrained Decoding Works

The model generates tokens one at a time. At each step:

1. Compute next-token probabilities as normal
2. Convert the JSON Schema into a finite state machine (FSM)
3. Based on current FSM state, compute which tokens are valid next
4. **Mask** all invalid tokens to probability zero
5. Sample from remaining valid tokens

This means the model literally **cannot** produce output that violates the schema. It's not post-processing or retry — it's enforced during generation.

```
Schema: {"name": string, "age": integer}
                                              
Token 1: "{"         ✓ (must start with {)    
Token 2: '"name"'    ✓ (required field)       
Token 3: ":"         ✓ (key-value separator)  
Token 4: '"Alice"'   ✓ (string value expected)
Token 5: ","         ✓ (more fields needed)   
Token 6: '"age"'     ✓ (required field)       
Token 7: ":"         ✓ (separator)            
Token 8: "30"        ✓ (integer expected)     
Token 9: "}"         ✓ (all fields present)   
                                              
Token 8: '"thirty"'  ✗ MASKED — integer required
Token 5: "}"         ✗ MASKED — "age" still required
```

### Provider Comparison (April 2026)

| Provider | Feature | Schema Format | Key Strength | Key Limitation |
|----------|---------|---------------|-------------|----------------|
| **OpenAI** | `response_format: { type: "json_schema", json_schema: {...} }` | JSON Schema | Most mature, widest schema support | Max ~5 levels nesting |
| **Anthropic** | Tool-based extraction (define a tool for the schema) | Tool input schema | Excellent reasoning during extraction | No native `response_format` — uses tool workaround |
| **Google** | `response_schema` in `generation_config` | JSON Schema | Integrated with Vertex AI pipelines | Some types unsupported |

### Schema Design Best Practices

1. **Field ordering matters for CoT**: Place `reasoning` or `explanation` fields **before** `answer` or `result` fields. The model generates sequentially — reasoning first produces better conclusions.

2. **Flatten deep nesting**: Schemas deeper than 3 levels reduce model accuracy. Break complex structures into pipeline stages.

3. **Use `description` as guidance**: Each field's `description` in the schema acts as implicit instructions to the model.

4. **Enum constraints**: For categorical fields, use `enum` instead of `string` — prevents hallucinated categories.

5. **Nullable fields**: Use `nullable: true` for optional data instead of making fields required with defaults.

### Semantic Validation: Beyond Syntax

Structured outputs guarantee **syntactic** correctness (valid JSON, correct types), but NOT **semantic** correctness:

| Syntactically Valid | Semantically Wrong |
|-|-|
| `{"price": -500.00}` | Prices shouldn't be negative |
| `{"start_date": "2026-12-31", "end_date": "2026-01-01"}` | End before start |
| `{"sentiment": "positive"}` for a negative review | Wrong classification |

**Always** add an application-level validation layer using Pydantic (Python) or Zod (TypeScript).

### Self-Hosted Constrained Generation

For local/open-weights models:

| Tool | How It Works | Best For |
|------|-------------|----------|
| **Outlines** | Grammar-based token masking via FSM | Any HuggingFace model, regex/JSON constraints |
| **llguidance** | Microsoft's constrained generation engine | Azure-hosted models, complex grammars |
| **vLLM** | `--guided-decoding-backend outlines` flag | Production serving with schema enforcement |
| **llama.cpp** | GBNF grammar support | Local inference on consumer hardware |

### Portability Libraries

| Library | Approach | Supports |
|---------|----------|----------|
| **Instructor** | Pydantic-first wrapper, automatic retry on validation failure | OpenAI, Anthropic, Google, Ollama, LiteLLM |
| **BAML** | Schema-first DSL with built-in retry, validation, and type generation | Multi-provider, TypeScript + Python |

---

## ◆ Quick Reference

| Problem | Solution |
|---------|----------|
| Need valid JSON from LLM | Use `response_format` with strict schema (not just JSON Mode) |
| Schema too complex, model struggles | Flatten nesting, split into pipeline stages |
| Values are valid types but semantically wrong | Add Pydantic/Zod validators, cross-field checks |
| Need same extraction across multiple providers | Use Instructor or BAML for portability |
| Running local model, need structured output | Use Outlines or vLLM's guided decoding |

---

## ○ Gotchas & Common Mistakes

- JSON Mode is NOT Structured Outputs — JSON Mode only guarantees valid JSON syntax, not your schema
- Model refusals bypass schema enforcement — always check for refusal metadata in the response
- Deep nesting (5+ levels) degrades output quality even with constrained decoding
- Structured outputs don't help with semantic correctness — a model can confidently fill every field with plausible but wrong values
- Token usage increases slightly with strict schemas due to the constrained generation overhead

---

## ○ Interview Angles

- **Q**: What's the difference between JSON Mode and Structured Outputs?
- **A**: JSON Mode only guarantees the output is syntactically valid JSON — it could be any shape. Structured Outputs enforce a specific JSON Schema using constrained decoding, guaranteeing the output has exactly the right fields, types, and structure. In production, always use Structured Outputs because you need to parse the result programmatically.

- **Q**: How does constrained decoding work under the hood?
- **A**: The JSON Schema is converted into a finite state machine. At each token generation step, the FSM determines which tokens are legal given the current state. All illegal tokens are masked to zero probability. The model samples only from valid tokens. This means schema violations are mathematically impossible — it's not retry-based, it's enforced during generation.

- **Q**: Does structured output guarantee correct answers?
- **A**: No — it guarantees correct **structure**, not correct **content**. A model can output `{"sentiment": "positive"}` for a clearly negative review. Structured output is a formatting guarantee, not a factuality guarantee. You still need semantic validation, ground-truth checks, and domain-specific validators.

---

## ★ Code & Implementation

### OpenAI Structured Output with Pydantic Validation

```python
# pip install openai>=1.60 pydantic>=2
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, pydantic>=2, OPENAI_API_KEY
import json
from pydantic import BaseModel, field_validator
from openai import OpenAI

client = OpenAI()

class ProductReview(BaseModel):
    """Structured extraction target for product reviews."""
    product_name: str
    sentiment: str  # positive, negative, neutral
    rating: float   # 1.0 to 5.0
    key_points: list[str]
    recommendation: bool

    @field_validator("rating")
    @classmethod
    def validate_rating(cls, v: float) -> float:
        if not 1.0 <= v <= 5.0:
            raise ValueError(f"Rating must be 1.0-5.0, got {v}")
        return v

    @field_validator("sentiment")
    @classmethod
    def validate_sentiment(cls, v: str) -> str:
        allowed = {"positive", "negative", "neutral"}
        if v.lower() not in allowed:
            raise ValueError(f"Sentiment must be one of {allowed}")
        return v.lower()

schema = {
    "type": "json_schema",
    "json_schema": {
        "name": "product_review",
        "strict": True,
        "schema": ProductReview.model_json_schema(),
    }
}

review_text = """Battery life is incredible — easily lasts 2 days. 
Camera is decent but struggles in low light. Build quality feels premium. 
Overpriced compared to competitors though."""

resp = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "Extract a structured review from the text."},
        {"role": "user", "content": review_text},
    ],
    response_format=schema,
    temperature=0,
)

# Parse and validate with Pydantic (catches semantic issues)
raw = json.loads(resp.choices[0].message.content)
review = ProductReview(**raw)
print(f"Product: {review.product_name}")
print(f"Sentiment: {review.sentiment} | Rating: {review.rating}/5")
print(f"Key points: {review.key_points}")
print(f"Recommends: {review.recommendation}")
# Expected output:
# Product: [phone/device name]
# Sentiment: positive | Rating: 3.5/5
# Key points: ['Great battery life', 'Decent camera', 'Premium build', 'Overpriced']
# Recommends: True
```

### Anthropic Tool-Based Structured Extraction

```python
# pip install anthropic>=0.40
# ⚠️ Last tested: 2026-04 | Requires: anthropic>=0.40, ANTHROPIC_API_KEY
import anthropic

client = anthropic.Anthropic()

# Anthropic uses tool definitions as the structured output mechanism
extract_tool = {
    "name": "extract_review",
    "description": "Extract structured review data from text",
    "input_schema": {
        "type": "object",
        "properties": {
            "product_name": {"type": "string"},
            "sentiment": {"type": "string", "enum": ["positive", "negative", "neutral"]},
            "rating": {"type": "number", "minimum": 1, "maximum": 5},
            "key_points": {"type": "array", "items": {"type": "string"}},
        },
        "required": ["product_name", "sentiment", "rating", "key_points"],
    },
}

resp = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=500,
    tools=[extract_tool],
    tool_choice={"type": "tool", "name": "extract_review"},  # Force tool use
    messages=[{"role": "user", "content": f"Extract review data: {review_text}"}],
)

# The structured data is in the tool use block
for block in resp.content:
    if block.type == "tool_use":
        print(f"Extracted: {block.input}")
# Expected output: {"product_name": "...", "sentiment": "positive", "rating": 3.5, ...}
```

### Outlines: Constrained Generation for Local Models

```python
# pip install outlines transformers torch
# ⚠️ Last tested: 2026-04 | Requires: outlines>=0.1, transformers>=4.48, GPU recommended
import outlines

model = outlines.models.transformers("microsoft/Phi-3-mini-4k-instruct")

# Define schema as a JSON Schema or Pydantic model
schema = '''{
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "sentiment": {"type": "string", "enum": ["positive", "negative", "neutral"]},
        "score": {"type": "integer", "minimum": 1, "maximum": 10}
    },
    "required": ["name", "sentiment", "score"]
}'''

generator = outlines.generate.json(model, schema)
result = generator("Analyze this review: Great product, fast shipping, would buy again!")
print(result)
# Expected output: {"name": "...", "sentiment": "positive", "score": 9}
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Schema too complex** | Model accuracy drops, timeouts, truncated output | >5 nesting levels, massive schemas | Flatten schema, split into pipeline stages, reduce required fields |
| **Semantic garbage** | Valid JSON with nonsensical values | No business logic validation layer | Pydantic validators, post-processing checks, cross-field validation |
| **Model refusal** | Empty or refusal response instead of structured data | Content policy triggered by input text | Check refusal metadata, handle gracefully, fallback to less restrictive prompt |
| **Provider portability failure** | Works on OpenAI, breaks on Anthropic | Different schema support levels, different tool patterns | Use Instructor/BAML for portability, test across providers |
| **Enum hallucination** | Values outside defined enum set in older models | Model generates plausible-but-invalid category | Stricter schema with explicit enum, validation layer, model upgrade |

---

## ◆ Hands-On Exercises

### Exercise 1: Cross-Provider Extraction Comparison

**Goal**: Compare structured output reliability across 3 providers
**Time**: 30 minutes

**Steps**:
1. Define a Pydantic model: `JobPosting(title, company, salary_range, required_skills, remote_policy)`
2. Collect 10 job posting texts from any job board
3. Extract structured data using OpenAI Structured Outputs, Anthropic tool-based extraction, and Google `response_schema`
4. Score: schema compliance rate, semantic accuracy (manual check), latency

**Expected Output**: Comparison table showing compliance % and quality per provider

### Exercise 2: Build a Validated Extraction Pipeline

**Goal**: Build a production-grade extraction pipeline with semantic validation
**Time**: 45 minutes

**Steps**:
1. Define a schema for invoice extraction: `Invoice(vendor, date, line_items, total, currency)`
2. Add Pydantic validators: total must equal sum of line items, date must be valid, currency must be ISO 4217
3. Implement retry logic: if validation fails, re-prompt with the error message
4. Test on 5 sample invoices (create mock text)

**Expected Output**: Pipeline that achieves 100% schema compliance and 90%+ semantic accuracy

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Function Calling & Structured Output](./function-calling-and-structured-output.md), [Prompt Engineering](./prompt-engineering.md) |
| Leads to | Reliable data extraction pipelines, agentic tool use, automated data processing |
| Compare with | Regex parsing, traditional NLP extraction, template-based generation |
| Cross-domain | Data engineering, API design, schema management |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Docs | [OpenAI Structured Outputs Guide](https://platform.openai.com/docs/guides/structured-outputs) | The definitive guide to schema-enforced generation |
| 🔧 Hands-on | [Instructor Library](https://python.useinstructor.com/) | Best tool for multi-provider structured output with Pydantic |
| 📄 Paper | [Willard & Louf — "Efficient Guided Generation" (Outlines, 2023)](https://arxiv.org/abs/2307.09702) | The paper that formalized constrained decoding via FSMs |
| 🔧 Hands-on | [BAML](https://docs.boundaryml.com/) | Schema-first structured output with built-in validation and multi-provider support |

---

## ★ Sources

- OpenAI Structured Outputs documentation — https://platform.openai.com/docs/guides/structured-outputs
- Anthropic Tool Use documentation — https://docs.anthropic.com/en/docs/build-with-claude/tool-use
- Outlines library — https://github.com/outlines-dev/outlines
- Instructor library — https://python.useinstructor.com/
