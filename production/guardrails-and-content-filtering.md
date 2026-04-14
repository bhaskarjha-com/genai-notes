---
title: "Guardrails & Content Filtering"
tags: [guardrails, safety, content-filtering, moderation, production, llmops]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "llmops.md"
related: ["../ethics-and-safety/adversarial-ml-and-ai-security.md", "../ethics-and-safety/owasp-llm-top-10.md", "monitoring-observability.md", "../agents/ai-agents.md"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# Guardrails & Content Filtering

> ✨ **Bit**: LLMs are powerful but unpredictable. Guardrails are the safety barriers that keep your AI from generating toxic content, leaking data, executing unauthorized actions, or hallucinating medical advice. They're not optional in production.

---

## ★ TL;DR

- **What**: Input validation, output filtering, and behavioral constraints applied to LLM systems to ensure safety, compliance, and quality
- **Why**: Without guardrails, LLMs can generate harmful content, leak PII, follow injection attacks, or produce outputs that violate regulations.
- **Key point**: Guardrails operate at 3 layers — input (block bad requests), model (constrain behavior), and output (validate before delivery) — and must be fast enough to not destroy latency.

---

## ★ Overview

### Definition

**Guardrails** are the programmatic checks, filters, and constraints applied before, during, and after LLM inference to ensure outputs are safe, accurate, compliant, and on-topic.

### Scope

Covers: Input validation, output filtering, PII detection, topic boundaries, hallucination guards, structured output enforcement, and production implementation. For adversarial attacks, see [Adversarial ML](../ethics-and-safety/adversarial-ml-and-ai-security.md). For security checklist, see [OWASP Top 10](../ethics-and-safety/owasp-llm-top-10.md).

### Significance

- **Regulatory requirement**: EU AI Act, HIPAA, SOC2 all require content controls
- **Brand safety**: One toxic response can go viral and damage trust
- **Production necessity**: Every production LLM system needs guardrails — the question is which ones

### Prerequisites

- [Adversarial ML & AI Security](../ethics-and-safety/adversarial-ml-and-ai-security.md)
- [LLMOps & Production Deployment](./llmops.md)
- [Monitoring & Observability](./monitoring-observability.md)

---

## ★ Deep Dive

### Three-Layer Guardrail Architecture

```
USER INPUT
     │
     ▼
┌──────────────────────────────────────────┐
│         LAYER 1: INPUT GUARDS            │
│                                          │
│  • Prompt injection detection            │
│  • PII detection & redaction             │
│  • Topic boundary check                  │
│  • Input length / cost limits            │
│  • Rate limiting                         │
│                                          │
│  ↓ BLOCKED → return rejection message    │
│  ↓ PASSED → continue to model           │
└──────────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────────┐
│         LAYER 2: MODEL CONSTRAINTS       │
│                                          │
│  • System prompt with behavioral rules   │
│  • Temperature / token limits            │
│  • Structured output enforcement         │
│  • Tool call validation                  │
│                                          │
└──────────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────────┐
│         LAYER 3: OUTPUT GUARDS           │
│                                          │
│  • Toxicity / hate speech classifier     │
│  • PII leakage detection                 │
│  • Hallucination check (if applicable)   │
│  • Schema validation                     │
│  • Competitor mention filter             │
│  • Citation verification                 │
│                                          │
│  ↓ FAILED → fallback response or retry   │
│  ↓ PASSED → return to user              │
└──────────────────────────────────────────┘
     │
     ▼
USER RESPONSE
```

### Guardrail Types

| Guardrail | Layer | What It Catches | Implementation |
|-----------|:-----:|----------------|----------------|
| **Prompt injection** | Input | Attempts to override system instructions | Regex + classifier (see [Adversarial ML](../ethics-and-safety/adversarial-ml-and-ai-security.md)) |
| **PII detection** | Input + Output | SSN, credit cards, emails, phone numbers | Regex + NER model (Presidio, spaCy) |
| **Topic boundaries** | Input | Off-topic requests (e.g., political opinions) | Classifier or system prompt enforcement |
| **Toxicity filter** | Output | Hate speech, violence, sexual content | OpenAI Moderation API, Perspective API |
| **Hallucination guard** | Output | Ungrounded claims, fabricated citations | Cross-reference with retrieved sources |
| **Schema validation** | Output | Malformed JSON, missing fields | Pydantic / JSON Schema validation |
| **Cost guard** | Input | Excessive token usage, prompt injection via length | Token counting + budget enforcement |
| **Tool call validation** | Output | Unauthorized tool calls, dangerous parameters | Allowlist of tools + parameter validation |

---

## ★ Code & Implementation

### Production Guardrails Pipeline

```python
# pip install openai>=1.0 pydantic>=2.0
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.0

import re
from openai import OpenAI
from pydantic import BaseModel, ValidationError
from typing import Optional

client = OpenAI()

# --- INPUT GUARDS ---

# PII patterns
PII_PATTERNS = {
    "ssn": r"\b\d{3}-\d{2}-\d{4}\b",
    "credit_card": r"\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b",
    "email": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b",
    "phone": r"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b",
}

def check_pii(text: str) -> dict:
    """Detect PII in text."""
    found = {}
    for pii_type, pattern in PII_PATTERNS.items():
        matches = re.findall(pattern, text)
        if matches:
            found[pii_type] = len(matches)
    return {"has_pii": bool(found), "types": found}

def redact_pii(text: str) -> str:
    """Replace PII with redaction markers."""
    for pii_type, pattern in PII_PATTERNS.items():
        text = re.sub(pattern, f"[REDACTED_{pii_type.upper()}]", text)
    return text

# Injection detection (simplified — see adversarial-ml note for full version)
INJECTION_PATTERNS = [
    r"ignore (all |previous )?instructions",
    r"you are now",
    r"system prompt",
    r"forget everything",
]

def check_injection(text: str) -> bool:
    """Check for prompt injection attempts."""
    return any(re.search(p, text, re.IGNORECASE) for p in INJECTION_PATTERNS)

# --- OUTPUT GUARDS ---

def check_toxicity(text: str) -> dict:
    """Use OpenAI Moderation API to check for toxic content."""
    response = client.moderations.create(input=text)
    result = response.results[0]
    return {
        "flagged": result.flagged,
        "categories": {k: v for k, v in result.categories.model_dump().items() if v},
    }

# --- FULL PIPELINE ---

class GuardrailResult(BaseModel):
    allowed: bool
    response: Optional[str] = None
    blocked_reason: Optional[str] = None
    pii_redacted: bool = False
    model_used: str = ""

def guarded_completion(user_input: str, system_prompt: str) -> GuardrailResult:
    """Complete LLM request with full guardrail pipeline."""
    
    # 1. INPUT: Check injection
    if check_injection(user_input):
        return GuardrailResult(
            allowed=False,
            blocked_reason="Potential prompt injection detected",
        )
    
    # 2. INPUT: Check and redact PII
    pii_check = check_pii(user_input)
    clean_input = redact_pii(user_input) if pii_check["has_pii"] else user_input
    
    # 3. MODEL: Generate with constraints
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": clean_input},
        ],
        temperature=0.3,
        max_tokens=500,
    )
    output = response.choices[0].message.content
    
    # 4. OUTPUT: Check toxicity
    toxicity = check_toxicity(output)
    if toxicity["flagged"]:
        return GuardrailResult(
            allowed=False,
            blocked_reason=f"Output flagged for: {list(toxicity['categories'].keys())}",
        )
    
    # 5. OUTPUT: Check for PII leakage
    output_pii = check_pii(output)
    if output_pii["has_pii"]:
        output = redact_pii(output)
    
    return GuardrailResult(
        allowed=True,
        response=output,
        pii_redacted=pii_check["has_pii"] or output_pii["has_pii"],
        model_used="gpt-4o-mini",
    )

# Test
result = guarded_completion(
    "My SSN is 123-45-6789. Can you help me file taxes?",
    "You are a helpful tax assistant. Never repeat personal information."
)
print(result.model_dump_json(indent=2))
# Expected: PII redacted, response generated without SSN
```

---

## ◆ Quick Reference

```
GUARDRAIL PRIORITY (implement in this order):

  1. Prompt injection detection    — prevents control hijacking
  2. PII detection & redaction     — prevents data leakage
  3. Output toxicity filtering     — prevents brand damage
  4. Schema validation             — prevents downstream errors
  5. Topic boundaries              — keeps agent on-task
  6. Hallucination checking        — prevents misinformation
  7. Cost guards                   — prevents budget blowout

LATENCY BUDGET:
  Input guards:   < 50ms (regex + classifier)
  Output guards:  < 100ms (moderation API + validation)
  Total overhead: < 150ms added to request
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Over-blocking** | Legitimate users get blocked frequently | Guards too aggressive, high false positive rate | Tune thresholds, add human review for borderline cases |
| **Guardrail bypass** | Bad content gets through despite guards | Adversarial input that evades pattern matching | Layer multiple detection methods, adversarial testing |
| **Latency bloat** | 500ms+ added per request from guardrails | Too many synchronous guards, slow toxicity API | Parallelize guards, cache repeated checks, use fast models |
| **PII leakage** | Model outputs user PII from context | PII in system prompt or retrieved context | Redact PII before model sees it, output PII scanning |

---

## ○ Interview Angles

- **Q**: Design a guardrail system for a healthcare chatbot.
- **A**: Three-layer approach. Input: PII detection (redact SSN, DOB before model sees them), injection detection, and topic filter (reject non-health queries). Model: system prompt with strict medical disclaimer rules, temperature=0 for consistency, structured output for treatment recommendations. Output: medical claim classifier (flag unverified treatment claims), PII leakage check, mandatory disclaimer injection. I'd add a HIPAA compliance layer that logs all interactions without PII for audit. Latency budget: < 200ms total guardrail overhead. For high-risk responses (medication, diagnosis), add a human-review queue.

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Guardrailed Chatbot

**Goal**: Add input and output guards to a basic chatbot
**Time**: 45 minutes
**Steps**:
1. Build a basic chatbot with the OpenAI API
2. Add PII detection (regex-based) on input and output
3. Add prompt injection detection (regex + LLM classifier)
4. Add toxicity checking (OpenAI Moderation API)
5. Test with 10 adversarial inputs — how many get caught?
**Expected Output**: Guardrailed chatbot with attack resistance log

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Adversarial ML](../ethics-and-safety/adversarial-ml-and-ai-security.md), [OWASP Top 10](../ethics-and-safety/owasp-llm-top-10.md), [LLMOps](./llmops.md) |
| Leads to | Healthcare AI compliance, Financial AI regulation, Safe agent deployment |
| Compare with | Traditional input validation, WAF (Web Application Firewall) |
| Cross-domain | AppSec, Compliance, Content moderation, RegTech |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [Guardrails AI](https://www.guardrailsai.com/) | Open-source guardrails framework with validators |
| 🔧 Hands-on | [NeMo Guardrails (NVIDIA)](https://github.com/NVIDIA/NeMo-Guardrails) | Programmable guardrails for LLM applications |
| 🔧 Hands-on | [Microsoft Presidio](https://microsoft.github.io/presidio/) | PII detection and de-identification |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 6 | Safety and guardrail patterns in production |

---

## ★ Sources

- Guardrails AI — https://www.guardrailsai.com/
- NVIDIA NeMo Guardrails — https://github.com/NVIDIA/NeMo-Guardrails
- Microsoft Presidio — https://microsoft.github.io/presidio/
- OpenAI Moderation API — https://platform.openai.com/docs/guides/moderation
- [Adversarial ML & AI Security](../ethics-and-safety/adversarial-ml-and-ai-security.md)
