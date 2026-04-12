---
title: "OWASP Top 10 for LLM Applications"
tags: [owasp, security, llm-top-10, genai-security, risks]
type: reference
difficulty: intermediate
status: published
parent: "[[ethics-safety-alignment]]"
related: ["[[adversarial-ml-and-ai-security]]", "[[ai-regulation]]", "[[../production/llmops]]"]
source: "OWASP primary sources - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# OWASP Top 10 for LLM Applications

> The OWASP list is useful because it translates AI security into concrete failure modes builders can actually design around.

---

## TL;DR

- **What**: A community-driven security framework highlighting the most important risks in LLM applications.
- **Why**: It gives product and engineering teams a practical checklist for design reviews, red-teaming, and secure delivery.
- **Key point**: Use it as a threat-modeling starting point, not a substitute for real system analysis.

---

## Overview

### Definition

The **OWASP Top 10 for LLM Applications** is part of the broader **OWASP GenAI Security Project** and catalogs major risk categories for LLM and GenAI systems.

### Scope

This note summarizes the framework and how builders should use it. It is not a full security playbook.

### Significance

- It gives teams a shared language for AI security reviews.
- It maps well to prompt injection, agentic workflows, and data-handling risks.
- It is increasingly referenced in enterprise security discussions.

### Prerequisites

- [Adversarial ML & AI Security](./adversarial-ml-and-ai-security.md)
- [AI Regulation for Builders](./ai-regulation.md)
- [LLMOps & Production Deployment](../production/llmops.md)

Last verified for OWASP project naming and version references: 2026-04.

---

## Deep Dive

### Why This Framework Matters

The OWASP framing helps teams move from vague fear to specific review questions:

- can user-controlled content change system behavior?
- can model outputs trigger unsafe downstream actions?
- can the system leak sensitive information?
- is autonomy excessive for the risk level?

### Core Risk Categories

The current widely referenced LLM list includes:

| Risk | Short Meaning |
|---|---|
| **LLM01 Prompt Injection** | malicious inputs manipulate behavior |
| **LLM02 Insecure Output Handling** | generated output is trusted too easily |
| **LLM03 Training Data Poisoning** | data corruption harms model behavior |
| **LLM04 Model Denial of Service** | attackers drive excessive resource use |
| **LLM05 Supply Chain Vulnerabilities** | dependencies or services are compromised |
| **LLM06 Sensitive Information Disclosure** | confidential data leaks from the system |
| **LLM07 Insecure Plugin Design** | unsafe extension or tool boundaries |
| **LLM08 Excessive Agency** | too much autonomy without enough control |
| **LLM09 Overreliance** | humans trust outputs too much |
| **LLM10 Model Theft** | unauthorized access or extraction of models |

### How To Use The List

Use the list during:

- architecture review
- threat modeling
- red-team planning
- release checklists
- incident postmortems

### Practical Mapping For Builders

| System Element | Relevant OWASP Risks |
|---|---|
| Retrieval pipeline | prompt injection, data poisoning, data disclosure |
| Tool-using agents | insecure output handling, excessive agency, plugin design |
| API gateway | model DoS, supply chain, model theft |
| User workflow | overreliance, disclosure, autonomy boundary mistakes |

### Example: Guarded Request Path

```python
def handle_llm_request(user_input, retrieved_chunks):
    safe_context = redact_secrets(retrieved_chunks)  # LLM06
    prompt = build_prompt(user_input=user_input, context=safe_context)
    raw_output = model.generate(prompt)

    safe_output = strip_html_and_commands(raw_output)  # LLM02
    if looks_like_prompt_injection(user_input, safe_output):  # LLM01
        return escalate_for_review("possible prompt injection")

    if requests_high_risk_action(safe_output):  # LLM08
        return require_human_approval(safe_output)

    return safe_output
```

### Important Context

OWASP's AI security work has expanded beyond only this Top 10 into the broader OWASP GenAI Security Project. That matters because the surrounding guidance is now wider than the original list.

---

## Quick Reference

| If Reviewing... | Start With |
|---|---|
| RAG assistant | prompt injection, disclosure, overreliance |
| agent workflow | excessive agency, insecure output handling, plugin/tool design |
| public AI API | DoS, model theft, supply chain |
| internal enterprise bot | disclosure, overreliance, injection through documents |

---

## Gotchas

- The list is a starting point, not a complete risk assessment.
- "Overreliance" is a socio-technical risk, not only a model flaw.
- Security reviews fail when they ignore downstream systems that trust model output.

---

## Interview Angles

- **Q**: Why is the OWASP LLM Top 10 useful for engineers?
- **A**: It turns vague AI security concerns into a concrete checklist of failure modes that can be mapped to architecture, threat modeling, and release controls.

- **Q**: Which OWASP categories matter most for agents?
- **A**: Prompt injection, insecure output handling, insecure plugin or tool design, excessive agency, and sensitive information disclosure are especially important because agents can take actions and traverse many trust boundaries.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Adversarial ML & AI Security](./adversarial-ml-and-ai-security.md), [AI Regulation for Builders](./ai-regulation.md) |
| Leads to | threat modeling, red teaming, secure agent design |
| Compare with | general OWASP web-app risk framing |
| Cross-domain | AppSec, governance, incident response |

---

## Sources

- OWASP Top 10 for Large Language Model Applications - https://owasp.org/www-project-top-10-for-large-language-model-applications/
- OWASP GenAI Security Project - https://genai.owasp.org/
- OWASP Top 10 for LLM Applications 2025 resource page - https://genai.owasp.org/resource/owasp-top-10-for-llm-applications-2025/
