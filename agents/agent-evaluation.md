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
updated: 2026-04-14
---

# Agent Evaluation & Observability

> ✨ **Bit**: A chatbot either knows the answer or hallucinates — you can catch that with one metric. An agent? It plans, selects tools, reads results, retries, backs off, re-plans, and then answers. If you only check the final answer, you're grading a cross-country road trip by looking at the parking job.

---

## ★ TL;DR

- **What**: The metrics, traces, and evaluation workflows used to measure agent quality in offline and online settings
- **Why**: Final-answer accuracy alone hides tool misuse, looping, latency blowups, and unsafe behavior
- **Key point**: Observe the trajectory, not just the destination

---

## ★ Overview

### Definition

**Agent evaluation** measures how well an agent completes tasks, uses tools, follows policies, and recovers from failure. **Agent observability** provides the traces and runtime signals needed to understand why it behaved that way.

### Scope

This note covers trace design, offline and online evaluation, common metrics, code examples for production tracing, and failure modes. For general eval concepts, see [LLM Evaluation & Benchmarks](../evaluation/evaluation-and-benchmarks.md). For agent design, see [AI Agents](./ai-agents.md).

### Why It Matters

- Agents can fail long before the final answer is visible
- Production agents need regression tests for workflows, not just prompts
- Observability is the bridge from "we saw a bug" to "we know why it happened"
- Without trajectory scoring, you ship agents that "look good" but cost 10x, loop endlessly, or misuse tools in ways that only matter in production

---

## ★ Deep Dive

### What To Measure

| Layer | Example Metrics |
|---|---|
| **Task outcome** | task success rate, human acceptance rate |
| **Trajectory quality** | steps taken, loops, dead ends, retry rate |
| **Tool use** | tool selection accuracy, schema validity, tool failure recovery |
| **Safety** | policy violations, risky actions blocked, escalation rate |
| **Efficiency** | latency, tokens, cost, number of tool calls |
| **Groundedness** | does the final answer use evidence from tool calls, or hallucinate past them? |

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
| Retry storm | same tool called 3+ times with identical arguments |

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

## ◆ Code & Implementation

### Traced Agent Evaluation with LangSmith

```python
# ⚠️ Last tested: 2026-04 | Requires: langsmith>=0.3, openai>=1.60
# pip install langsmith openai

from langsmith import Client, traceable
from langsmith.schemas import Run
import json

client = Client()

# ═══ 1. Define a traced agent task ═══
@traceable(name="support-agent-task", tags=["eval-suite-v2"])
def run_agent(task: str, allowed_tools: list[str]) -> dict:
    """
    Run an agent task with full trajectory capture.
    In production, this wraps your real agent (LangGraph, ADK, etc).
    """
    # -- placeholder for real agent execution --
    return {
        "answer": "Your refund has been processed.",
        "steps": 4,
        "tools_used": ["lookup_order", "check_refund_policy", "process_refund"],
        "tools_available": allowed_tools,
        "total_tokens": 2847,
        "latency_ms": 3200,
        "cost_usd": 0.023,
    }


# ═══ 2. Score trajectory programmatically ═══
def score_trajectory(run_output: dict) -> dict:
    """Score an agent run on multiple trajectory dimensions."""
    steps = run_output.get("steps", 0)
    tools_used = run_output.get("tools_used", [])
    tools_available = run_output.get("tools_available", [])

    # Tool selection precision: did agent only use relevant tools?
    valid_tools = [t for t in tools_used if t in tools_available]
    tool_precision = len(valid_tools) / max(len(tools_used), 1)

    # Step efficiency: fewer steps = better (baseline: 5 steps)
    step_efficiency = min(1.0, 5 / max(steps, 1))

    # Cost efficiency: under $0.05 is good
    cost = run_output.get("cost_usd", 0)
    cost_score = min(1.0, 0.05 / max(cost, 0.001))

    return {
        "tool_precision": round(tool_precision, 3),
        "step_efficiency": round(step_efficiency, 3),
        "cost_score": round(cost_score, 3),
        "composite": round(
            0.4 * tool_precision + 0.3 * step_efficiency + 0.3 * cost_score, 3
        ),
    }


# ═══ 3. Run evaluation ═══
result = run_agent(
    task="Process refund for order #12345",
    allowed_tools=["lookup_order", "check_refund_policy", "process_refund", "escalate"],
)

scores = score_trajectory(result)
print(json.dumps(scores, indent=2))
# Output:
# {
#   "tool_precision": 1.0,
#   "step_efficiency": 1.0,
#   "cost_score": 1.0,
#   "composite": 1.0
# }
```

### LLM-as-Judge for Agent Trajectories

```python
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60
# Use an LLM to grade trajectory quality when rubrics are insufficient

from openai import OpenAI

client = OpenAI()

JUDGE_PROMPT = """You are an agent trajectory evaluator.

Given an agent's task and its execution trace, score on these dimensions (1-5):
1. TASK_COMPLETION: Did it solve the user's problem?
2. TOOL_EFFICIENCY: Were tool calls necessary and correct?
3. SAFETY: Did it respect policies and avoid risky actions?
4. GROUNDEDNESS: Did the final answer use evidence from tool calls?

Return JSON: {"task_completion": N, "tool_efficiency": N, "safety": N, "groundedness": N, "reasoning": "..."}
"""

def judge_trajectory(task: str, trace: str) -> dict:
    response = client.chat.completions.create(
        model="gpt-5.4-mini",
        temperature=0,
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": JUDGE_PROMPT},
            {"role": "user", "content": f"Task: {task}\n\nTrace:\n{trace}"},
        ],
    )
    import json
    return json.loads(response.choices[0].message.content)


# Usage:
# scores = judge_trajectory("Refund order #12345", trace_string)
```

---

## ◆ Quick Reference

| If You See | Investigate |
|---|---|
| High final-answer quality but high cost | unnecessary tools or too many steps |
| Frequent loops | planner prompt, stop rules, or missing tool feedback |
| Safe final answers but poor user trust | missing citations or weak transparency |
| High tool validity but poor results | wrong planner or wrong retrieval context |
| Scores diverge between offline and online | eval set is not representative of production traffic |

---

## ○ Gotchas & Common Mistakes

- ⚠️ Final-answer grading alone will miss most agent failures
- ⚠️ Online feedback without trace context is hard to act on
- ⚠️ Judge-model scores should be grounded in evidence, not only style
- ⚠️ Good observability requires stable metadata schemas — version them or traces become incomparable across releases
- ⚠️ Non-determinism is a feature of LLMs but a bug in evaluation — always pin temperature=0 and use seeds for offline eval suites
- ⚠️ Don't confuse observability with logging — observability means you can reconstruct the full trajectory from stored data; logging means you printed some text

---

## ○ Interview Angles

- **Q**: How would you evaluate an agent beyond task success?
- **A**: I would score the trajectory: tool selection, tool arguments, retry behavior, safety, latency, cost, and whether the final answer actually used the evidence produced during execution. I'd build a composite score weighing task completion (40%), tool precision (30%), and cost efficiency (30%), and track regression across prompt/model changes.

- **Q**: Why is observability mandatory for agents?
- **A**: Because agent failures are sequential. Without traces, you only see the bad final answer, not the exact step where the planner, tool call, or verifier went wrong. A refund agent that loops 8 times and then gives the right answer looks "correct" in a success-only metric but costs 4x and takes 30 seconds.

- **Q**: How do you handle non-determinism in agent evaluation?
- **A**: Three approaches: (1) Pin temperature=0 and use seed parameters for reproducible runs, (2) Run each eval task 3-5 times and report median + variance, (3) Use majority-vote scoring where a task "passes" only if 3/5 runs succeed. For production monitoring, track distributions, not point estimates.

- **Q**: When should you use LLM-as-Judge vs programmatic scoring?
- **A**: Programmatic scoring (tool precision, step count, cost) is faster, cheaper, and more reproducible — use it for everything you can formalize. LLM-as-Judge fills the gap for subjective quality: tone, helpfulness, groundedness. In practice, use both: programmatic scores gate the CI pipeline, LLM-Judge scores provide qualitative insight for manual review of borderline cases.

---

## ★ Connections

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
1. Define 10 agent tasks with expected outcomes and allowed tools
2. Implement the `score_trajectory` function from the code example above
3. Run your agent on each task 3 times (test determinism)
4. Score on: task completion, cost, latency, tool precision, and step efficiency
5. Create a regression test suite that can run in CI with `pytest`
**Expected Output**: Agent evaluation report with pass/fail per task, composite score, and variance analysis

### Exercise 2: Build an LLM-as-Judge Pipeline

**Goal**: Use a judge model to grade agent trajectories on qualitative dimensions
**Time**: 30 minutes
**Steps**:
1. Capture 5 agent traces (mix of good and bad runs)
2. Implement the `judge_trajectory` function from the code example above
3. Run the judge on all 5 traces
4. Compare judge scores with your manual assessment — calibrate the prompt
**Expected Output**: JSON scores for each trace with reasoning, plus a calibration analysis

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Non-deterministic results** | Same agent task produces different outcomes on each run | LLM sampling randomness, tool output variance | Temperature=0, seed pinning, majority vote across runs |
| **Eval metric gaming** | Agent scores high on eval but fails on real tasks | Eval tasks too narrow, no edge cases | Diverse eval suite, production failure replay, held-out test sets |
| **Cost-blind evaluation** | Agent solves task but at 10x expected cost | No cost tracking in eval harness | Include cost/token metrics in eval scoring |
| **Trace schema drift** | Old traces can't be compared to new traces after a deploy | Metadata fields changed without versioning | Version all trace schemas, maintain backward compatibility layer |
| **Observer effect** | Agent behaves differently in eval vs production | Eval harness constrains tool access, timing, or context | Use production-identical environment for eval, including real tool endpoints |
| **Judge model bias** | LLM-as-Judge systematically over-scores verbose answers | Judge model has its own biases, prefers length or formality | Calibrate judge with human annotations, use structured rubrics with evidence grounding |

---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📄 Paper | [Jimenez et al. "SWE-bench" (2023)](https://arxiv.org/abs/2310.06770) | Benchmark for evaluating coding agents on real GitHub issues |
| 📄 Paper | [Zhuge et al. "Agent-as-a-Judge" (2024)](https://arxiv.org/abs/2410.10934) | Using agentic systems as evaluators for other agents |
| 🔧 Hands-on | [LangSmith Evaluations](https://docs.smith.langchain.com/) | Production agent evaluation and tracing |
| 🔧 Hands-on | [Langfuse](https://langfuse.com/docs) | Open-source LLM observability and evaluation |
| 🔧 Hands-on | [Braintrust](https://www.braintrust.dev/docs) | Eval-focused observability for LLM applications |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 7 | Agent evaluation patterns and metrics |

## ★ Sources

- LangSmith evaluation concepts documentation
- Langfuse open-source observability documentation
- RAGAS documentation
- DeepEval documentation
- OpenAI evaluation guidance for application testing
- Anthropic, "Building effective agents" (2024)
