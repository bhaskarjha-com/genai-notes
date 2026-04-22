---
title: "Prompt Engineering"
aliases: ["Prompting", "Few-Shot", "Zero-Shot", "Prompt Design"]
tags: [prompt-engineering, prompting, few-shot, chain-of-thought, genai-techniques]
type: procedure
difficulty: beginner
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../agents/ai-agents.md", "rag.md", "../llms/llms-overview.md"]
source: "OpenAI Prompt Engineering Guide, Anthropic Prompting Guide"
created: 2026-03-18
updated: 2026-04-11
---

# Prompt Engineering

> âœ¨ **Bit**: Prompt engineering is the art of asking the right question. Turns out, how you ask an LLM matters as much as what you ask â€” just like talking to humans.

---

## â˜… TL;DR

- **What**: Crafting inputs (prompts) to get desired outputs from LLMs without changing the model
- **Why**: The cheapest, fastest way to improve LLM output. Zero training, zero infra â€” just better instructions.
- **Key point**: Good prompting follows patterns: be specific, give examples, assign a role, think step-by-step.

---

## â˜… Overview

### Definition

**Prompt Engineering** is the practice of designing and refining inputs to LLMs to elicit specific, high-quality responses. It encompasses techniques from simple instruction formatting to complex multi-step reasoning frameworks.

### Scope

Covers prompting techniques from basic to advanced. For when prompting isn't enough, see [Fine Tuning](./fine-tuning.md) and [Rag](./rag.md).

### Significance

- First thing to try before any other technique (cheapest, fastest)
- Skill every AI practitioner needs regardless of technical depth
- The difference between "LLM gives garbage" and "LLM gives gold" is often just the prompt

### Prerequisites

- Basic understanding of [Llms Overview](../llms/llms-overview.md)

---

## â˜… Deep Dive

### The Prompting Hierarchy (Simplest â†’ Most Complex)

```
Level 1: Zero-Shot       â†’ "Translate this to French: Hello"
Level 2: System Prompt   â†’ "You are a French translator. Translate: Hello"
Level 3: Few-Shot        â†’ "Here are 3 examples. Now do this one..."
Level 4: Chain-of-Thought â†’ "Think step by step..."
Level 5: Self-Consistency â†’ Generate multiple answers, pick the majority
Level 6: ReAct / Tool Use â†’ Think, Act, Observe loops (enters Agent territory)
```

### Key Techniques

#### 1. System Prompts (Role Assignment)

```
WEAK:  "Summarize this article"
STRONG: "You are an expert technical editor. Summarize the following
         article in 3 bullet points, focusing on practical implications
         for software engineers. Use precise technical language."
```

**Why it works**: Activates the model's "persona" â€” trained on text BY experts, so "being" an expert improves output.

#### 2. Few-Shot Prompting

```
Classify the sentiment:

"This product is amazing!" â†’ Positive
"Worst purchase ever." â†’ Negative
"It's okay, nothing special." â†’ Neutral

"The quality exceeded my expectations!" â†’
```

**Rule of thumb**: 3-5 examples is the sweet spot. More examples = more consistent, but uses context window.

#### 3. Chain of Thought (CoT)

```
WEAK:  "What is 17 Ã— 24?"
STRONG: "What is 17 Ã— 24? Think step by step."

Model output with CoT:
  "17 Ã— 24
   = 17 Ã— 20 + 17 Ã— 4
   = 340 + 68
   = 408"
```

**Why it works**: Forces the model to show intermediate reasoning, reducing errors. Especially effective for math, logic, and multi-step problems.

#### 4. Structured Output

```
"Analyze this code and respond in the following JSON format:
{
  "bugs": [{"line": int, "description": string, "severity": "high|medium|low"}],
  "suggestions": [string],
  "overall_quality": int  // 1-10
}"
```

**Why structured**: Parseable by code, consistent format, forces completeness.

#### 5. The META Framework

| Element          | Description              | Example                         |
| ---------------- | ------------------------ | ------------------------------- |
| **M**ission      | What's the overall goal? | "You are a code reviewer"       |
| **E**xpectations | What format/quality?     | "Be concise, cite line numbers" |
| **T**ask         | Specific action          | "Review this Python function"   |
| **A**rtifacts    | Examples/reference       | "Here's an example review..."   |

### Advanced Patterns

| Pattern                 | How                                            | Use Case                         |
| ----------------------- | ---------------------------------------------- | -------------------------------- |
| **Self-Consistency**    | Generate N responses, majority vote            | Math, factual questions          |
| **Tree of Thought**     | Explore multiple reasoning branches            | Complex problem-solving          |
| **Least-to-Most**       | Break complex problem into sub-problems        | Problems requiring decomposition |
| **Generated Knowledge** | "First, tell me facts about X. Then, answer Y" | Knowledge-intensive questions    |
| **Prompt Chaining**     | Output of prompt A â†’ Input of prompt B         | Multi-stage pipelines            |

### The Prompting Mistake Matrix

| âŒ Common Mistake        | âœ… Better Approach                                                                                     |
| ----------------------- | ----------------------------------------------------------------------------------------------------- |
| "Write good code"       | "Write Python 3.12 code that handles edge cases. Include type hints, docstrings, and error handling." |
| "Summarize this"        | "Summarize in 3 bullet points for a technical audience. Each bullet max 20 words."                    |
| "Be creative"           | "Generate 5 alternative approaches, ranked by feasibility. For each, explain trade-offs."             |
| "Fix the bug"           | "Identify the root cause. Explain why it fails. Provide corrected code with comments on changes."     |
| Dumping entire codebase | Provide only the relevant function + error message + expected behavior                                |

---

## â—† Quick Reference

```
PROMPTING CHECKLIST:
â–¡ Define ROLE      â†’ "You are a [specific expert]"
â–¡ Set CONTEXT      â†’ Background info the model needs
â–¡ State TASK       â†’ Exactly what to do
â–¡ Specify FORMAT   â†’ How to structure the output
â–¡ Give EXAMPLES    â†’ 2-3 examples of desired output
â–¡ Add CONSTRAINTS  â†’ What NOT to do, length limits, etc.
â–¡ Request REASONING â†’ "Think step by step" / "Explain your reasoning"

TEMPERATURE GUIDE:
  0.0 â†’ Factual, deterministic (data extraction, classification)
  0.3 â†’ Balanced (summarization, coding)
  0.7 â†’ Creative (writing, brainstorming)
  1.0 â†’ Very creative (poetry, fiction)
```

---

## â—† Strengths vs Limitations

| âœ… Strengths                   | âŒ Limitations                                            |
| ----------------------------- | -------------------------------------------------------- |
| Zero cost (no training/infra) | Can't add new knowledge                                  |
| Instant iteration             | Fragile â€” small changes = different results              |
| Works with any model          | Context window limits complexity                         |
| Easy to A/B test              | Can't change model behavior permanently                  |
| Good starting point always    | Diminishing returns at some point â†’ need RAG/fine-tuning |

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Prompt â‰  Programming**: Prompts are probabilistic, not deterministic. Same prompt can give different results.
- âš ï¸ **"Be concise" doesn't work well**: Instead say "Respond in exactly 3 sentences" â€” be specific about constraints.
- âš ï¸ **Prompt injection**: Users can override your system prompt. Never trust user input in prompts for production apps.
- âš ï¸ **Position matters**: Important instructions at the beginning AND end of prompts are most likely followed (primacy/recency effect).
- âš ï¸ **"Just prompt engineer it" is a ceiling**: For domain expertise, consistent behavior, or new knowledge â€” prompting alone won't cut it.

---

## â—‹ Interview Angles

- **Q**: What's the difference between zero-shot, few-shot, and chain-of-thought prompting?
- **A**: Zero-shot: just instructions, no examples. Few-shot: include examples of desired inputâ†’output pairs. CoT: ask model to show reasoning steps. Each adds more guidance and typically improves quality.

- **Q**: How would you handle prompt injection in a production system?
- **A**: Input sanitization, separate system/user prompts, output validation, don't include raw user input in system prompts. Use the model's built-in system prompt separation. For critical apps, add a second LLM call to verify the first output makes sense.

---

## â˜… Code & Implementation

### Structured Prompt Builder

```python
# pip install openai>=1.60
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var
from openai import OpenAI
from dataclasses import dataclass

client = OpenAI()

@dataclass
class PromptConfig:
    """Structured prompt using the META framework."""
    role: str        # Mission: what expert persona
    context: str     # Context background
    task: str        # Task: specific action
    format: str      # Expected output format
    examples: list[tuple[str, str]]  # (input, output) pairs for few-shot
    constraints: str = ""            # what NOT to do

def build_messages(user_input: str, config: PromptConfig) -> list[dict]:
    """Build few-shot messages list from a PromptConfig."""
    system = (
        f"You are {config.role}.\n\n"
        f"Context: {config.context}\n\n"
        f"Task: {config.task}\n\n"
        f"Output format: {config.format}"
    )
    if config.constraints:
        system += f"\n\nConstraints: {config.constraints}"

    messages = [{"role": "system", "content": system}]
    # Few-shot examples
    for example_input, example_output in config.examples:
        messages.append({"role": "user", "content": example_input})
        messages.append({"role": "assistant", "content": example_output})
    # Actual query
    messages.append({"role": "user", "content": user_input})
    return messages

# Example: Sentiment classifier with few-shot
config = PromptConfig(
    role="an expert sentiment analyst",
    context="You are classifying customer feedback for a SaaS product.",
    task="Classify the sentiment of the user's review.",
    format='{"sentiment": "positive|negative|neutral", "confidence": 0.0-1.0, "reason": "..."}',
    examples=[
        ("This product is amazing!", '{"sentiment": "positive", "confidence": 0.97, "reason": "clear enthusiasm"}'),
        ("Worst purchase ever.",     '{"sentiment": "negative", "confidence": 0.99, "reason": "strong negative language"}'),
    ],
    constraints="Only respond with valid JSON. No extra text.",
)

messages = build_messages("The onboarding is okay but the dashboard is confusing.", config)
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=messages,
    temperature=0.0,   # deterministic for classification
    max_tokens=100,
)
print(response.choices[0].message.content)
# â†’ {"sentiment": "negative", "confidence": 0.82, "reason": "mixed review, negative feature mentioned"}
```

### Chain-of-Thought vs Direct: Side-by-Side Test

```python
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY

def compare_cot(question: str, model: str = "gpt-4o-mini") -> None:
    """Compare direct vs chain-of-thought prompting on a reasoning question."""
    # Direct prompt
    direct = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": question}],
        temperature=0, max_tokens=100,
    )
    # CoT prompt
    cot = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": f"{question} Think step by step."}],
        temperature=0, max_tokens=300,
    )
    print("=== DIRECT ===")
    print(direct.choices[0].message.content)
    print("\n=== CHAIN-OF-THOUGHT ===")
    print(cot.choices[0].message.content)

compare_cot("If a train travels 120km at 60km/h and then 90km at 45km/h, what is the total travel time?")
# Direct: often gives wrong answer quickly
# CoT: breaks into phases â†’ gets 2h + 2h = 4h (correct)
```

---

## â˜… Connections


| Relationship | Topics                                                                |
| ------------ | --------------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md)                                             |
| Leads to     | [Ai Agents](../agents/ai-agents.md), [Rag](./rag.md) (prompt is key in RAG too)                     |
| Compare with | [Fine Tuning](./fine-tuning.md) (permanent behavior change), [Rag](./rag.md) (adds knowledge) |
| Cross-domain | UX writing, Human communication, Psychology (framing effects)         |

---


## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ”§ Hands-on | [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering) | Industry-best prompt engineering documentation |
| ðŸ“˜ Book | "AI Engineering" by Chip Huyen (2025), Ch 5 (Prompt Engineering) | Systematic treatment of prompting techniques with evaluation |
| ðŸ”§ Hands-on | [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering) | Practical tips with examples for GPT models |
| ðŸŽ“ Course | [deeplearning.ai â€” "ChatGPT Prompt Engineering"](https://www.deeplearning.ai/) | Short, practical course on effective prompting |

## â˜… Sources

- OpenAI Prompt Engineering Guide â€” https://platform.openai.com/docs/guides/prompt-engineering
- Anthropic Prompt Engineering Guide â€” https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering
- Wei et al., "Chain-of-Thought Prompting" (2022)
- Yao et al., "Tree of Thoughts" (2023)
