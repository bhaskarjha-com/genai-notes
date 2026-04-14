---
title: "AI UX Patterns"
tags: [ux, ui, design, streaming, feedback, trust, ai-product]
type: reference
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "[[../production/ai-system-design]]"
related: ["[[api-design-for-ai]]", "[[conversational-ai]]", "[[voice-ai]]", "[[ai-product-management-fundamentals]]"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# AI UX Patterns

> ✨ **Bit**: The best AI model in the world is useless if users don't trust it, can't understand it, or give up waiting 8 seconds for a response. AI UX design is about making intelligence feel reliable, fast, and controllable.

---

## ★ TL;DR

- **What**: Design patterns for building user interfaces around AI systems — handling latency, uncertainty, trust, and error
- **Why**: AI behaves differently from traditional software (non-deterministic, sometimes wrong, variable latency). Generic UX patterns don't work.
- **Key point**: The three pillars of AI UX: make it fast (streaming), make it trustable (citations, confidence), make it controllable (edit, regenerate, undo).

---

## ★ Overview

### Definition

**AI UX patterns** are recurring design solutions for the unique challenges of AI-powered interfaces: communicating uncertainty, managing variable latency, building user trust, and enabling human correction.

### Prerequisites

- [Conversational AI](./conversational-ai.md)
- [API Design for AI](./api-design-for-ai.md)

---

## ★ Deep Dive

### The Three Pillars of AI UX

```
PILLAR 1: SPEED                    PILLAR 2: TRUST                  PILLAR 3: CONTROL
─────────────────                  ───────────────                   ──────────────────
• Stream tokens                    • Show citations                  • Regenerate button
• Skeleton loading                 • Confidence indicators           • Edit AI output
• Progressive rendering            • Source attribution              • Undo / revert
• Optimistic updates               • "I don't know" admission        • Feedback (👍/👎)
• Background prefetch              • Transparent limitations          • Temperature control
                                   • Consistent persona               • Mode switching
```

### Core AI UX Patterns

| Pattern | Problem It Solves | Example |
|---------|------------------|---------|
| **Streaming response** | 3-8 second wait feels slow | ChatGPT token-by-token rendering |
| **Skeleton loading** | User doesn't know something is happening | Shimmer animation during model inference |
| **Citation cards** | User can't verify AI claims | Perplexity-style inline source links |
| **Confidence indicators** | Not all answers are equally reliable | Color-coded confidence bars |
| **Suggested prompts** | Users don't know what to ask | Starter chips, autocomplete |
| **Regeneration** | First answer wasn't good enough | "Try again" button with different seed |
| **Inline editing** | AI was 90% right but needs correction | Editable responses with diff tracking |
| **Progressive disclosure** | Too much information at once | Summary first, expandable details |
| **Guardrail messaging** | AI refuses a request | Clear explanation of what's not possible and why |
| **Feedback capture** | Need to improve model quality | Thumbs up/down, report, correction |

### Anti-Patterns to Avoid

| Anti-Pattern | Why It Hurts | Better Alternative |
|-------------|-------------|-------------------|
| **No loading state** | User thinks it's broken | Streaming + skeleton loading |
| **Fake confidence** | Erodes trust when wrong | Show uncertainty explicitly |
| **Wall of text** | Overwhelming, unreadable | Progressive disclosure, formatting |
| **No attribution** | "The AI said so" isn't trustworthy | Citations with source links |
| **No way to correct** | Users feel powerless | Edit, regenerate, and feedback buttons |
| **Hiding AI involvement** | Users feel deceived | Be transparent about AI-generated content |

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Trust erosion** | Users stop relying on AI answers | Confident wrong answers without citations | Add citations, confidence indicators, "I don't know" |
| **Latency abandonment** | Users leave during model inference | No streaming, no loading indicator | Stream tokens, add skeleton loading |
| **Feedback fatigue** | Users stop giving feedback | Too many feedback prompts, no visible impact | Make feedback easy (one click), show when it improves results |

---

## ○ Interview Angles

- **Q**: How would you design the UX for an AI research assistant?
- **A**: Three core principles. Speed: stream responses token-by-token with a skeleton loading state. Trust: every claim gets an inline citation with a link to the source document — clicking opens the relevant passage highlighted. Control: users can regenerate, edit the response, or thumbs-down with a reason. I'd add progressive disclosure — a TL;DR summary with expandable details underneath. For uncertainty, I'd use a confidence indicator and have the AI explicitly say "I'm not sure about this" rather than hallucinating confidently.

---

## ◆ Hands-On Exercises

### Exercise 1: Audit an AI Product's UX

**Goal**: Evaluate an existing AI product against the three pillars
**Time**: 20 minutes
**Steps**:
1. Choose an AI product (ChatGPT, Perplexity, Cursor, etc.)
2. Score it on Speed, Trust, and Control (1-10 each)
3. Identify 3 UX anti-patterns and suggest improvements
**Expected Output**: UX audit scorecard with improvement recommendations

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [Conversational AI](./conversational-ai.md), [API Design](./api-design-for-ai.md) |
| Leads to | AI product design, user research for AI, [AI Product Management](./ai-product-management-fundamentals.md) |
| Compare with | Traditional software UX, mobile UX patterns |
| Cross-domain | Product design, human-computer interaction, psychology |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 1 | AI product design from an engineering perspective |
| 🔧 Hands-on | [Google PAIR Guidelines](https://pair.withgoogle.com/) | Google's AI UX design principles |
| 🔧 Hands-on | [Apple Human Interface Guidelines — Machine Learning](https://developer.apple.com/design/human-interface-guidelines/machine-learning) | Apple's AI UX design principles |

---

## ★ Sources

- Google PAIR — https://pair.withgoogle.com/
- Apple HIG: Machine Learning — https://developer.apple.com/design/human-interface-guidelines/machine-learning
- Nielsen Norman Group — AI UX Research — https://www.nngroup.com/
