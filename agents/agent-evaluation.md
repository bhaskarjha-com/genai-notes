---
title: "Agent Evaluation & Observability"
tags: [agent-eval, observability, tracing, evaluation, genai-techniques]
type: reference
difficulty: advanced
status: published
last_verified: 2026-04
parent: "ai-agents.md"
related: ["multi-agent-architectures.md", "../evaluation/evaluation-and-benchmarks.md", "../production/llmops.md", "../llms/hallucination-detection.md"]
source: "Multiple sources - see Sources"
created: 2026-04-12
updated: 2026-04-12
---

# Agent Evaluation & Observability

> A useful agent is not just one that eventually answers. It is one whose trajectory, tool use, and failure behavior are measurable.

---

## TL;DR

- **What**: The metrics, traces, and evaluation workflows used to measure agent quality in offline and online settings
- **Why**: Final-answer accuracy alone hides tool misuse, looping, latency blowups, and unsafe behavior
- **Key point**: Observe the trajectory, not just the destination

---

## Overview

### Definition

**Agent evaluation** measures how well an agent completes tasks, uses tools, follows policies, and recovers from failure. **Agent observability** provides the traces and runtime signals needed to understand why it behaved that way.

### Scope

This note covers trace design, offline and online evaluation, common metrics, and production feedback loops. For general eval concepts, see [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md). For agent design, see [AI Agents](./ai-agents.md).

### Why It Matters

- Agents can fail long before the final answer is visible
- Production agents need regression tests for workflows, not just prompts
- Observability is the bridge from "we saw a bug" to "we know why it happened"

---

## Deep Dive

### What To Measure

| Layer | Example Metrics |
|---|---|
| **Task outcome** | task success rate, human acceptance rate |
| **Trajectory quality** | steps taken, loops, dead ends, retry rate |
| **Tool use** | tool selection accuracy, schema validity, tool failure recovery |
| **Safety** | policy violations, risky actions blocked, escalation rate |
| **Efficiency** | latency, tokens, cost, number of tool calls |

### Offline Evaluation

Use a fixed dataset of tasks with expected outcomes, references, or rubrics.

Good for:

- regression testing
- comparing prompts or planners
- validating new tools before production rollout

Typical offline inputs:

- user task
- allowed tools
- gold answer or scoring rubric
- expected intermediate actions if available

### Online Evaluation

Use live traces and human or automatic feedback in production.

Good for:

- catching drift
- discovering new failure modes
- measuring business impact

Typical online signals:

- thumbs up / down
- abandonment rate
- fallback or human-handoff rate
- tool error concentration

### Trace Design

```text
trace
|- input
|- retrieved context or tool outputs
|- planner thoughts or state transitions
|- tool calls and arguments
|- model outputs
|- verifier decisions
`- final response + metadata
```

A good trace lets you answer:

- what the agent saw
- why it chose a tool
- what happened after the tool call
- where latency and cost accumulated

### Evaluating Tool Use

| Failure Mode | What To Check |
|---|---|
| Wrong tool chosen | compare selected tool vs acceptable tools |
| Bad arguments | schema and semantic validation |
| Unnecessary tool calls | cost and latency waste |
| Ignored tool evidence | mismatch between evidence and final answer |

### Agent Scorecard Example

```text
Task completion rate:        78%
Tool-call validity:          94%
Average steps per task:      6.1
Loop rate:                   8%
Human escalation rate:       5%
Median latency:              4.8 s
Median cost per task:        $0.031
```

### Evaluation Workflow

1. Create representative task sets
2. Trace every run with consistent metadata
3. Score task success, tool correctness, and safety
4. Review worst traces manually
5. Fix planner prompts, tool schemas, or policies
6. Re-run regression suite before deployment

### Observability Stack

| Capability | Why You Need It |
|---|---|
| **Tracing** | reconstruct agent trajectories |
| **Datasets** | enable repeatable offline tests |
| **Feedback capture** | tie runtime quality to user outcomes |
| **Alerts** | detect loops, tool spikes, or cost blowups |
| **Experiment tags** | compare prompts, models, and planner versions |

---

## Quick Reference

| If You See | Investigate |
|---|---|
| High final-answer quality but high cost | unnecessary tools or too many steps |
| Frequent loops | planner prompt, stop rules, or missing tool feedback |
| Safe final answers but poor user trust | missing citations or weak transparency |
| High tool validity but poor results | wrong planner or wrong retrieval context |

---

## Gotchas

- Final-answer grading alone will miss most agent failures
- Online feedback without trace context is hard to act on
- Judge-model scores should be grounded in evidence, not only style
- Good observability requires stable metadata schemas

---

## Interview Angles

- **Q**: How would you evaluate an agent beyond task success?
- **A**: I would score the trajectory: tool selection, tool arguments, retry behavior, safety, latency, cost, and whether the final answer actually used the evidence produced during execution.

- **Q**: Why is observability mandatory for agents?
- **A**: Because agent failures are sequential. Without traces, you only see the bad final answer, not the exact step where the planner, tool call, or verifier went wrong.

---

## Connections

| Relationship | Topics |
|---|---|
| Builds on | [AI Agents](./ai-agents.md), [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md), [LLMOps & Production Deployment](../production/llmops.md) |
| Leads to | [Multi-Agent Architectures](./multi-agent-architectures.md), [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md) |
| Compare with | Static prompt evaluation, benchmark-only evaluation |
| Cross-domain | APM, distributed tracing, experiment management |


---

## ◆ Hands-On Exercises

### Exercise 1: Build an Agent Evaluation Harness

**Goal**: Create a reproducible evaluation framework for agent workflows
**Time**: 45 minutes
**Steps**:
1. Define 10 agent tasks with expected outcomes
2. Run your agent on each task 3 times (test determinism)
3. Score on: task completion, cost, latency, and tool usage efficiency
4. Create a regression test suite that can run in CI
**Expected Output**: Agent evaluation report with pass/fail per task and variance analysis

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Non-deterministic results** | Same agent task produces different outcomes on each run | LLM sampling randomness, tool output variance | Temperature=0, seed pinning, majority vote across runs |
| **Eval metric gaming** | Agent scores high on eval but fails on real tasks | Eval tasks too narrow, no edge cases | Diverse eval suite, production failure replay, held-out test sets |
| **Cost-blind evaluation** | Agent solves task but at 10x expected cost | No cost tracking in eval harness | Include cost/token metrics in eval scoring |
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Jimenez et al. "SWE-bench" (2023)](https://arxiv.org/abs/2310.06770) | Benchmark for evaluating coding agents on real GitHub issues |
| 🔧 Hands-on | [LangSmith Evaluations](https://docs.smith.langchain.com/) | Production agent evaluation and tracing |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 7 | Agent evaluation patterns and metrics |

## Sources

- LangSmith evaluation concepts documentation
- RAGAS documentation
- DeepEval documentation
- OpenAI evaluation guidance for application testing
