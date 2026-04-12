---
title: "Multi-Agent Architectures"
tags: [multi-agent, agents, orchestration, coordination, genai-techniques]
type: concept
difficulty: advanced
status: published
parent: "[[ai-agents]]"
related: ["[[agentic-protocols]]", "[[agent-evaluation]]", "[[../applications/code-generation]]", "[[../production/ai-system-design]]"]
source: "Multiple sources - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Multi-Agent Architectures

> A multi-agent system should exist because specialization creates value, not because multiple LLMs sound impressive on a slide.

---

## TL;DR

- **What**: Systems where multiple specialized agents coordinate to solve a task
- **Why**: Useful when decomposition, specialization, or parallelism beats a single-agent design
- **Key point**: Multi-agent is an architecture trade-off, not an automatic upgrade

---

## Overview

### Definition

A **multi-agent architecture** is a system in which multiple agents with separate roles, prompts, tool access, or memory collaborate through an explicit coordination pattern.

### Scope

This note covers common patterns, coordination mechanisms, design choices, and operational risks. For single-agent fundamentals, see [AI Agents](./ai-agents.md). For protocol-level interoperability, see [Agentic Protocols & Frameworks](./agentic-protocols.md).

### When It Helps

- large tasks benefit from decomposition
- multiple skills are needed
- work can run in parallel
- verification is as important as generation

### When It Hurts

- the task is simple enough for one agent
- latency budget is tight
- state sharing is weak
- evaluation and debugging are not mature

---

## Deep Dive

### Common Patterns

| Pattern | How It Works | Best For |
|---|---|---|
| **Planner / worker** | One agent plans, others execute subtasks | Research and operations workflows |
| **Manager / specialist** | Router delegates to role-specific experts | Enterprise assistants and copilots |
| **Critic / executor** | One agent proposes, another reviews | Safety-sensitive or code-heavy tasks |
| **Parallel fan-out** | Many agents explore in parallel, then aggregate | Search, synthesis, brainstorming |
| **Debate / committee** | Agents challenge each other | Hard reasoning and adversarial review |
| **Environment loop** | Agents interact through tools or a shared world state | Simulation and longer-running workflows |

### Coordination Building Blocks

```text
shared goal
-> role assignment
-> message passing
-> shared memory or task board
-> tool execution
-> aggregation or arbitration
-> final answer
```

### Design Decisions

#### 1. Role granularity

- broad roles reduce coordination overhead
- narrow roles improve specialization but increase orchestration complexity

#### 2. State management

- centralized state is easier to reason about
- distributed state can scale, but consistency becomes harder

#### 3. Arbitration

- who decides the final answer?
- planner, critic, explicit judge, or human reviewer

#### 4. Tool permissions

- not every agent should have every tool
- least privilege reduces damage and confusion

### Example: Coding Workflow

```text
Planner
-> breaks request into tasks
-> sends implementation to coder
-> sends test design to verifier
-> aggregates results
-> returns final patch summary
```

Why this works:

- parallel exploration
- explicit verification
- cleaner ownership boundaries

### Failure Modes

| Failure | Description | Typical Fix |
|---|---|---|
| **Role collapse** | Agents behave the same way | Make roles concrete and tool-specific |
| **Looping** | Agents keep reassigning work | Add stop conditions and ownership rules |
| **State drift** | Agents operate on inconsistent facts | Use a shared source of truth |
| **Message bloat** | Context becomes too large | Summarize aggressively |
| **Judge failure** | Critic is weak or biased | Use evidence-based scoring or human review |

### Practical Guidance

- Start with single-agent plus tools
- Introduce a second agent only when a specific bottleneck is clear
- Prefer explicit coordination graphs over vague "team" prompts
- Evaluate trajectories, not only final answers

---

## Quick Reference

| Need | Recommended Pattern |
|---|---|
| Parallel research | Fan-out / fan-in |
| Code + review | Executor + critic |
| Complex workflow planning | Planner / worker |
| Strong policy oversight | Specialist + judge or human |

---

## Gotchas

- Multi-agent systems often look smarter simply because they are slower and more expensive
- Extra agents amplify weak tool descriptions and weak state design
- Without observability, multi-agent debugging becomes guesswork

---

## Interview Angles

- **Q**: When would you choose multi-agent over single-agent?
- **A**: When specialization or parallel work materially improves task quality or speed enough to justify the extra coordination cost.

- **Q**: What is the hardest part of multi-agent productionization?
- **A**: State management and evaluation. Without a clear shared context and traceable trajectories, failures are difficult to explain or reproduce.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [AI Agents](./ai-agents.md), [Agentic Protocols & Frameworks](./agentic-protocols.md) |
| Leads to | [Agent Evaluation & Observability](./agent-evaluation.md), [AI System Design for GenAI Applications](../production/ai-system-design.md) |
| Compare with | Single-agent architectures, deterministic orchestration |
| Cross-domain | Distributed systems, organizational design, workflow engines |

---

## Sources

- Microsoft AutoGen documentation and design patterns
- LangGraph multi-agent orchestration guidance
- Anthropic guidance on effective agent architectures
- [AI Agents](./ai-agents.md)

