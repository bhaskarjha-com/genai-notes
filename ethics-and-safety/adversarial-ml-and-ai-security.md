---
title: "Adversarial ML & AI Security"
tags: [security, adversarial-ml, prompt-injection, jailbreaks, red-teaming]
type: reference
difficulty: advanced
status: published
parent: "[[ethics-safety-alignment]]"
related: ["[[owasp-llm-top-10]]", "[[ai-regulation]]", "[[../production/llmops]]", "[[../techniques/ai-agents]]"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Adversarial ML & AI Security

> AI systems are not only inaccurate sometimes. They are attack surfaces.

---

## TL;DR

- **What**: The study of attacks against AI systems and the controls used to defend them.
- **Why**: LLM apps can leak data, misuse tools, follow malicious instructions, or become gateways into other systems.
- **Key point**: Treat the full AI application as the security boundary, not just the model.

---

## Overview

### Definition

**Adversarial ML** covers attacks that manipulate model inputs, training data, behavior, or surrounding infrastructure. In GenAI, this includes prompt injection, data poisoning, insecure tool use, and misuse of autonomous workflows.

### Scope

This note is application-focused. It covers practical threat categories and defenses rather than only academic attack taxonomies.

### Significance

- Security failures can be more damaging than quality failures.
- Agentic systems expand the blast radius by adding tools and side effects.
- AI security is rapidly becoming part of normal platform engineering.

### Prerequisites

- [Ethics, Safety & Alignment](./ethics-safety-alignment.md)
- [AI Regulation for Builders](./ai-regulation.md)
- [AI Agents](../techniques/ai-agents.md)

---

## Deep Dive

### Common Threat Families

| Threat | Example |
|---|---|
| **Prompt injection** | malicious content overrides instructions |
| **Sensitive data disclosure** | model reveals secrets or private context |
| **Tool misuse** | model invokes powerful actions incorrectly |
| **Indirect injection** | hostile content enters via documents, web pages, or tool results |
| **Data poisoning** | training or retrieval corpus is manipulated |
| **Model theft / abuse** | unauthorized extraction or overuse of model assets |

### Threat Modeling Questions

Ask:

1. What can the model read?
2. What can it do?
3. What systems trust its output?
4. What happens if a malicious user controls part of the context?
5. What logging and containment exist when things go wrong?

### Defensive Layers

| Layer | Control |
|---|---|
| **Input** | validation, sanitation, content isolation |
| **Prompting** | instruction hierarchy and tool constraints |
| **Execution** | sandboxing, permission boundaries, allowlists |
| **Output** | schema validation, escaping, downstream checks |
| **Monitoring** | anomaly detection, trace review, alerting |

### Agents Need Extra Care

Agent systems add risk through:

- external tools
- stateful memory
- autonomous retries
- access to business systems

That means security review should cover permissions, action approval, and containment boundaries.

### Security Mindset For Builders

1. Do not trust model output as safe by default.
2. Minimize tool privileges.
3. Isolate untrusted retrieved content.
4. Validate before acting on generated output.
5. Red-team realistic abuse cases, not just ideal demos.

### Example Tool-Execution Policy

```yaml
tools:
  web_search:
    allowed: true
  send_email:
    allowed: false
  create_ticket:
    allowed: true
    requires_schema_validation: true
  issue_refund:
    allowed: true
    requires_human_approval: true
```

---

## Quick Reference

| Risk | First Defense |
|---|---|
| prompt injection | context isolation and strict tool policy |
| unsafe generated code or SQL | output validation and execution sandbox |
| secret leakage | retrieval and logging hygiene, redaction, least privilege |
| harmful agent action | approvals, scoped permissions, audit trail |
| malicious corpus content | ingestion review and trust boundaries |

---

## Gotchas

- A strong system prompt is not a security boundary.
- Output validation matters even when the model is "usually right."
- Security issues often appear at system integration points, not in the model alone.
- Teams sometimes confuse safety alignment with security hardening.

---

## Interview Angles

- **Q**: Why is prompt injection a security problem and not only a quality problem?
- **A**: Because malicious instructions can manipulate system behavior, trigger data leakage, or cause unauthorized actions through tools and downstream systems. That makes it part of the application's security surface.

- **Q**: What is the first rule for AI security in agent systems?
- **A**: Minimize and constrain what the agent can do. Least privilege, validation, and human approval for sensitive actions matter more than clever prompting alone.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [Ethics, Safety & Alignment](./ethics-safety-alignment.md), [AI Regulation for Builders](./ai-regulation.md) |
| Leads to | [OWASP Top 10 for LLM Applications](./owasp-llm-top-10.md), red-teaming, secure AI delivery |
| Compare with | general app security, adversarial examples in CV |
| Cross-domain | AppSec, threat modeling, red teaming |

---

## Sources

- OWASP GenAI Security Project materials
- NIST AI RMF resources
- [AI Regulation for Builders](./ai-regulation.md)
