---
title: "Mechanistic Interpretability"
tags: [interpretability, mech-interp, superposition, sparse-autoencoders, circuits, genai]
type: concept
difficulty: expert
status: learning
parent: "[[../genai]]"
related: ["[[../ethics-and-safety/ethics-safety-alignment]]", "[[../foundations/transformers]]", "[[../llms/llms-overview]]"]
source: "Anthropic, OpenAI — see Sources"
created: 2026-03-22
updated: 2026-03-22
---

# Mechanistic Interpretability

> ✨ **Bit**: We built AGI-approaching systems and we have NO IDEA what's happening inside them. Mechanistic interpretability is reverse-engineering neural networks — finding the "circuits" that implement specific capabilities. It's neuroscience, but for artificial brains.

---

## ★ TL;DR

- **What**: Understanding WHAT individual neurons, attention heads, and circuits in neural networks actually do — reverse-engineering the model's internal algorithms
- **Why**: We can't trust what we can't understand. AI safety REQUIRES understanding model internals. Also: Anthropic's biggest research bet.
- **Key point**: Models represent features in "superposition" — a single neuron encodes MANY concepts simultaneously. Sparse autoencoders can extract these hidden features.

---

## ★ Overview

### Definition

**Mechanistic interpretability** (mech-interp) aims to understand neural networks by identifying the specific computations that neurons, attention heads, and circuits perform. It's different from "behavioral" interpretability (what the model does) — mech-interp focuses on HOW it does it internally.

### Scope

Frontier research. This is not needed for building apps but shows deep technical understanding. For practical safety/alignment, see [[../ethics-and-safety/ethics-safety-alignment]].

### Significance

- Anthropic's primary research direction (largest mech-interp team in the world)
- OpenAI's Superalignment team worked on this before dissolution
- Frontier AI labs argue this is essential for safe AGI
- Demonstrates research-depth in interviews at top AI labs

---

## ★ Deep Dive

### Key Concepts

```
SUPERPOSITION:
  The biggest insight in mech-interp.
  
  Problem: A model with 768 neurons represents > 768 concepts.
  How? SUPERPOSITION — multiple features share the same neurons.
  
  Analogy: Storing 1,000 songs on 100 CDs using compression.
  Each CD contributes a little to many songs.
  
  ┌─────────────────────────────────────────────┐
  │  Neuron 42 responds to:                     │
  │    "Python code"    (activation: 0.7)       │
  │    "Snakes"         (activation: 0.3)       │
  │    "British comedy" (activation: 0.1)       │
  │                                             │
  │  These features are SUPERPOSED in one neuron│
  │  The model uses directions in activation    │
  │  space, not individual neurons, to encode   │
  │  concepts.                                  │
  └─────────────────────────────────────────────┘


FEATURES:
  The actual concepts the model represents internally.
  Not neurons — features are DIRECTIONS in activation space.
  
  Example features found via sparse autoencoders:
  - "This text is in French"
  - "This number is a year"
  - "The Golden Gate Bridge" (famous Anthropic discovery)
  - "Code contains a bug"
  - "Deceptive behavior" (safety-critical!)


CIRCUITS:
  Connected patterns of features that implement specific behaviors.
  
  Example: "Indirect Object Identification" circuit
  "Mary gave the book to ___" → [John]
  
  Attention head A finds "Mary" (subject)
  Attention head B finds "John" (recipient)
  Attention head C copies "John" to output position
  
  Three heads working together = a circuit
```

### Sparse Autoencoders (SAEs)

```
HOW TO EXTRACT FEATURES FROM SUPERPOSITION:

  Problem: Neurons are polysemantic (respond to many things).
  Solution: Train a sparse autoencoder to decompose activations.

  ┌────────────────────────────────────────────┐
  │  Model activation (768-dim)                │
  │         │                                  │
  │         ▼                                  │
  │  ┌──────────────┐                          │
  │  │ ENCODER       │  768 → 65,536 dimensions│
  │  │ (expand)      │  (overcomplete)         │
  │  └──────┬───────┘                          │
  │         │  + sparsity constraint            │
  │         │  (only ~100 of 65K neurons active)│
  │         ▼                                  │
  │  ┌──────────────┐                          │
  │  │ SPARSE HIDDEN │  Most are ZERO          │
  │  │ FEATURES      │  Active ones =          │
  │  │               │  interpretable features │
  │  └──────┬───────┘                          │
  │         ▼                                  │
  │  ┌──────────────┐                          │
  │  │ DECODER       │  65,536 → 768           │
  │  │ (reconstruct) │  Reconstruct original   │
  │  └──────────────┘                          │
  │                                            │
  │  Training: minimize reconstruction error   │
  │            + sparsity penalty              │
  └────────────────────────────────────────────┘

  Result: Each of the 65K sparse neurons corresponds
  to ONE interpretable feature (ideally).
  
  Anthropic found ~10 million features in Claude 3 Sonnet!
```

### Research Techniques

| Technique | What It Does | How |
|-----------|-------------|-----|
| **Activation patching** | Test if a component is necessary for a behavior | Replace its output, see if behavior changes |
| **Probing** | Check if information exists in a layer | Train a linear classifier on activations |
| **Ablation** | Remove a component and measure impact | Zero out neurons/heads, check output |
| **Logit lens** | See what each layer "thinks" the next token is | Project hidden states directly to vocabulary |
| **Sparse autoencoders** | Extract interpretable features | Overcomplete autoencoder with sparsity |
| **Causal tracing** | Find where a fact is stored | Corrupt inputs, restore at each layer |

### Notable Discoveries

| Discovery | Who | What |
|-----------|-----|------|
| **Induction heads** | Anthropic (2022) | Attention heads that implement in-context learning ("A B ... A → B") |
| **Golden Gate Claude** | Anthropic (2024) | Amplifying the "Golden Gate Bridge" feature made Claude obsessed with it |
| **10M features** | Anthropic (2024) | Extracted 10M interpretable features from Claude 3 Sonnet via SAEs |
| **ROME** | Meng et al. (2022) | Located and edited specific facts in GPT models |
| **Deception features** | Anthropic (2024) | Found features that activate when model is being "deceptive" |

---

## ◆ Quick Reference

```
WHY IT MATTERS FOR SAFETY:
  1. Find deception: detect features that activate when
     model is strategically being dishonest
  2. Understand capabilities: know what model CAN do vs DOES
  3. Controlled editing: surgically modify behavior
  4. Trust: "We can verify the model works as intended"

KEY TERMS:
  Monosemantic    = neuron responds to one concept
  Polysemantic    = neuron responds to many concepts
  Superposition   = features > neurons (compression)
  Circuit         = connected features implementing behavior
  SAE             = sparse autoencoder (feature extraction)
  Logit lens      = what each layer predicts
  Activation patching = causal intervention

RESEARCH GROUPS:
  Anthropic Interpretability team (largest)
  Google DeepMind (mech-interp group)
  EleutherAI (open-source research)
  Independent researchers (Neel Nanda, others)
```

---

## ○ Interview Angles

- **Q**: What is superposition in neural networks?
- **A**: Neural networks represent more concepts (features) than they have neurons. Features are encoded as DIRECTIONS in activation space, not individual neurons. Multiple features share the same neurons through superposition — similar to how compressed audio encodes many frequencies in fewer data points. Sparse autoencoders can decompose these back into individual features.

- **Q**: Why does mechanistic interpretability matter for AI safety?
- **A**: We need to understand what models are doing internally — not just what they output. Mech-interp can detect deceptive behavior (features that activate during strategic dishonesty), verify alignment (the model genuinely follows safety training, not just surface compliance), and enable targeted interventions (edit specific behaviors without retraining).

---

## ★ Connections

| Relationship | Topics |
|-------------|--------|
| Builds on | [[../foundations/transformers]], [[../prerequisites/neural-networks]], [[../prerequisites/linear-algebra-for-ai]] |
| Leads to | AI safety, [[../ethics-and-safety/ethics-safety-alignment]], Trustworthy AI |
| Compare with | Behavioral evaluation (external), Explainable AI (XAI, surface-level) |
| Cross-domain | Neuroscience, Reverse engineering, Complex systems |

---

## ★ Sources

- Anthropic, "Scaling Monosemanticity" (2024) — https://transformer-circuits.pub/2024/scaling-monosemanticity/
- Anthropic, "A Mathematical Framework for Transformer Circuits" (2021)
- Neel Nanda, "200 Concrete Open Problems in Mechanistic Interpretability" (2022)
- TransformerLens library — https://github.com/neelnanda-io/TransformerLens
- Meng et al., "Locating and Editing Factual Associations in GPT" (ROME, 2022)
