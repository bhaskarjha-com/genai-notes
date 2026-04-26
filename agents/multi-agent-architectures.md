---
title: "Multi-Agent Architectures"
aliases: ["Multi-Agent", "CrewAI", "AutoGen", "Swarm"]
tags: [multi-agent, agents, orchestration, coordination, genai-techniques]
type: procedure
difficulty: advanced
status: published
last_verified: 2026-04
parent: "ai-agents.md"
related: ["agentic-protocols.md", "agent-evaluation.md", "../applications/code-generation.md", "../production/ai-system-design.md"]
source: "Multiple sources - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# Multi-Agent Architectures

> ✨ **Bit**: A multi-agent system should exist because specialization creates value, not because multiple LLMs sound impressive on a slide. If one agent with good tools solves your problem, stop there.

---

## ★ TL;DR

- **What**: Systems where multiple specialized agents coordinate through explicit patterns (supervisor, debate, fan-out) to solve tasks too complex or broad for a single agent
- **Why**: Enables specialization, parallel execution, and verification â€” but only when the coordination cost is justified
- **Key point**: Multi-agent is an architecture trade-off, not an automatic upgrade. Start with one agent; add more only when a specific bottleneck appears.

---

## ★ Overview

### Definition

A **multi-agent architecture** is a system in which multiple agents â€” each with separate roles, system prompts, tool access, and/or memory â€” collaborate through an explicit coordination pattern (supervisor, pipeline, debate, or swarm) to achieve a shared goal.

### Scope

Covers: Common multi-agent patterns with architecture diagrams and code, framework comparison (LangGraph vs CrewAI vs ADK), design decisions, and operational risks. For single-agent fundamentals, see [AI Agents](./ai-agents.md). For protocol-level interoperability (MCP, A2A), see [Agentic Protocols](./agentic-protocols.md).

### When Multi-Agent Helps vs Hurts

| ✅ Helps When | âŒ Hurts When |
|--------------|--------------|
| Task naturally decomposes into specialized sub-tasks | Task is simple enough for one agent with tools |
| Different sub-tasks need different tools/models | Latency budget is tight (each agent adds 1-3s) |
| Verification is as important as generation | State sharing between agents is weak |
| Parallel execution yields real speedup | Evaluation and debugging infra isn't mature |
| You need adversarial review (red team, code review) | You're adding agents because it sounds impressive |

### Prerequisites

- [AI Agents](./ai-agents.md) â€” agent loop, tool use, memory
- [Agentic Protocols & Frameworks](./agentic-protocols.md) â€” MCP, A2A, ADK
- [Function Calling and Structured Output](../techniques/function-calling-and-structured-output.md)

---

## ★ Deep Dive

### The 6 Multi-Agent Patterns

#### Pattern 1: Supervisor (Manager → Workers)

```
                    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                    â”‚   SUPERVISOR     â”‚
                    â”‚   (planner/      â”‚
                    â”‚    router)       â”‚
                    â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                             â”‚
                â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                â–¼            â–¼            â–¼
         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â”‚ Worker A â”‚ â”‚ Worker B â”‚ â”‚ Worker C â”‚
         â”‚ (researchâ”‚ â”‚  (code)  â”‚ â”‚ (review) â”‚
         â”‚  agent)  â”‚ â”‚          â”‚ â”‚          â”‚
         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

How: Supervisor receives task, breaks it down, delegates to
     specialized workers, collects results, synthesizes final answer.
Best for: Complex workflows with clear sub-tasks.
Risk: Supervisor becomes bottleneck; workers can't self-correct.
```

#### Pattern 2: Sequential Pipeline

```
  [Input] → [Agent A: Research] → [Agent B: Draft] → [Agent C: Review] → [Output]
                                                          â”‚
                                                    (if rejected)
                                                          â”‚
                                                    â—„â”€â”€â”€â”€â”€â”˜ Back to Agent B

How: Each agent processes the output of the previous one.
Best for: Workflows with natural sequential stages (research → write → review).
Risk: Errors compound through the pipeline. Feedback loops can create cycles.
```

#### Pattern 3: Debate / Adversarial

```
         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â”‚ Agent A  â”‚ â—„â”€â”€â”€â”€â”€â–º â”‚ Agent B  â”‚
         â”‚ (propose)â”‚         â”‚ (critique)â”‚
         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                    â”‚         â”‚
                    â–¼         â–¼
               â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
               â”‚     JUDGE        â”‚
               â”‚ (final decision) â”‚
               â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

How: Two agents argue opposing positions. A judge evaluates.
Best for: High-stakes decisions, red-teaming, fact verification.
Risk: Debate can be performative if both agents are equally wrong.
```

#### Pattern 4: Fan-Out / Fan-In (Parallel)

```
                    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                    â”‚ Planner  â”‚
                    â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜
                â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”
                â–¼        â–¼        â–¼
           [Agent 1] [Agent 2] [Agent 3]   â† Run in parallel
                â–¼        â–¼        â–¼
                â””â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                    â”Œâ”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”
                    â”‚ Aggregatorâ”‚
                    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

How: Multiple agents work on the same/similar tasks in parallel. Results aggregated.
Best for: Research, brainstorming, web search, diverse perspective generation.
Risk: Aggregation is hard. Which result do you trust?
```

#### Pattern 5: Hierarchical (Multi-Level Supervisors)

```
                 â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                 â”‚  CEO Agent      â”‚
                 â”‚  (orchestrator) â”‚
                 â””â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                â–¼                    â–¼
         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â”‚ Manager Aâ”‚         â”‚ Manager Bâ”‚
         â”‚ (eng)    â”‚         â”‚ (data)   â”‚
         â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜         â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜
         â”Œâ”€â”€â”€â”€â”¼â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”¼â”€â”€â”€â”€â”
         â–¼         â–¼          â–¼         â–¼
     [Worker]  [Worker]   [Worker]  [Worker]

How: Mirrors organizational hierarchy. Managers delegate to workers.
Best for: Very complex projects with multiple workstreams.
Risk: Communication overhead, latency multiplication at each level.
```

#### Pattern 6: Swarm (Peer-to-Peer)

```
     [Agent A] â—„â”€â”€â–º [Agent B]
         â–²               â–²
         â”‚               â”‚
         â–¼               â–¼
     [Agent C] â—„â”€â”€â–º [Agent D]

How: No central coordinator. Agents communicate peer-to-peer via handoffs.
Best for: Customer service (transfer between specialized agents).
Risk: Hard to track state. Conversation can "get lost" between agents.
Framework: OpenAI Swarm (experimental).
```

### Pattern Summary

| Pattern | Coordination | Parallelism | Complexity | Best When |
|---------|:----------:|:-----------:|:----------:|-----------|
| Supervisor | Central | Workers parallel | Medium | Clear sub-task decomposition |
| Pipeline | Sequential | None | Low | Natural stage-by-stage flow |
| Debate | Peer | Two in parallel | Medium | Verification, red-teaming |
| Fan-out | Central | High | Medium | Research, exploration |
| Hierarchical | Multi-level | Per-level | High | Enterprise, multi-workstream |
| Swarm | Distributed | Per-pair | High | Customer service, handoffs |

### Design Decisions

| Decision | Options | Trade-off |
|----------|---------|-----------|
| **Role granularity** | Broad (3-4 agents) vs Narrow (10+ agents) | Fewer = less coordination; More = better specialization |
| **State management** | Centralized (shared dict/DB) vs Distributed (per-agent) | Central = simpler but bottleneck; Distributed = scales but consistency hard |
| **Communication** | Direct messages vs Shared workspace vs Message queue | Direct = fast but coupling; Shared = visible but collision risk |
| **Arbitration** | Supervisor decides vs Voting vs Judge agent vs Human | Auto = fast but risky; Human = safe but slow |
| **Tool permissions** | All agents share tools vs Least privilege | Shared = flexible; Restricted = safe (principle of least privilege) |

---

## ★ Code & Implementation

### Supervisor Pattern with LangGraph

```python
# pip install langgraph>=0.2 langchain-openai>=0.2 langchain-core>=0.3
# âš ï¸ Last tested: 2026-04 | Requires: langgraph>=0.2

from typing import TypedDict, Annotated, Literal
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langchain_openai import ChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage

# 1. Define shared state
class TeamState(TypedDict):
    messages: Annotated[list, add_messages]
    task: str
    research_output: str
    draft_output: str
    review_output: str
    current_agent: str

# 2. Define specialized agents
llm = ChatOpenAI(model="gpt-4o", temperature=0.3)

def supervisor(state: TeamState) -> dict:
    """Supervisor decides which agent to call next."""
    system = """You are a project supervisor. Based on the current state, decide the next step:
    - If no research exists: route to 'researcher'
    - If research exists but no draft: route to 'writer'
    - If draft exists but no review: route to 'reviewer'
    - If review exists: route to 'done'

    Respond with ONLY the agent name: researcher, writer, reviewer, or done"""

    context = f"""Task: {state['task']}
Research: {'Done' if state.get('research_output') else 'Not started'}
Draft: {'Done' if state.get('draft_output') else 'Not started'}
Review: {'Done' if state.get('review_output') else 'Not started'}"""

    response = llm.invoke([
        SystemMessage(content=system),
        HumanMessage(content=context),
    ])
    next_agent = response.content.strip().lower()
    return {"current_agent": next_agent}

def researcher(state: TeamState) -> dict:
    """Research agent gathers information."""
    system = "You are a research specialist. Provide thorough research findings."
    response = llm.invoke([
        SystemMessage(content=system),
        HumanMessage(content=f"Research this topic: {state['task']}"),
    ])
    return {"research_output": response.content}

def writer(state: TeamState) -> dict:
    """Writer agent drafts content based on research."""
    system = "You are a technical writer. Create a clear, well-structured draft."
    response = llm.invoke([
        SystemMessage(content=system),
        HumanMessage(content=f"Based on this research, write a draft:\n{state['research_output']}"),
    ])
    return {"draft_output": response.content}

def reviewer(state: TeamState) -> dict:
    """Reviewer agent provides feedback."""
    system = "You are a senior editor. Review for accuracy, clarity, and completeness."
    response = llm.invoke([
        SystemMessage(content=system),
        HumanMessage(content=f"Review this draft:\n{state['draft_output']}"),
    ])
    return {"review_output": response.content}

# 3. Build the graph
def route_to_agent(state: TeamState) -> str:
    return state.get("current_agent", "done")

graph = StateGraph(TeamState)
graph.add_node("supervisor", supervisor)
graph.add_node("researcher", researcher)
graph.add_node("writer", writer)
graph.add_node("reviewer", reviewer)

graph.add_edge(START, "supervisor")
graph.add_conditional_edges("supervisor", route_to_agent, {
    "researcher": "researcher",
    "writer": "writer",
    "reviewer": "reviewer",
    "done": END,
})
# After each worker, go back to supervisor for next routing decision
graph.add_edge("researcher", "supervisor")
graph.add_edge("writer", "supervisor")
graph.add_edge("reviewer", "supervisor")

app = graph.compile()

# 4. Run the multi-agent system
result = app.invoke({
    "task": "Explain how KV-cache optimization works in LLM serving",
    "messages": [],
    "research_output": "",
    "draft_output": "",
    "review_output": "",
    "current_agent": "",
})

print(f"Research: {result['research_output'][:200]}...")
print(f"Draft: {result['draft_output'][:200]}...")
print(f"Review: {result['review_output'][:200]}...")

# Expected output: 3 stages executed sequentially
# - Research: detailed technical findings
# - Draft: structured document based on research
# - Review: feedback with suggestions
```

### CrewAI Multi-Agent Team

```python
# pip install crewai>=0.80
# âš ï¸ Last tested: 2026-04 | Requires: crewai>=0.80

from crewai import Agent, Task, Crew, Process

# 1. Define specialized agents
researcher = Agent(
    role="Senior Research Analyst",
    goal="Find comprehensive, accurate information on the given topic",
    backstory="Expert researcher with deep knowledge of AI/ML systems.",
    verbose=True,
    allow_delegation=False,
)

writer = Agent(
    role="Technical Writer",
    goal="Transform research into clear, actionable documentation",
    backstory="Experienced tech writer who specializes in making complex topics accessible.",
    verbose=True,
    allow_delegation=False,
)

reviewer = Agent(
    role="Quality Reviewer",
    goal="Ensure accuracy, completeness, and clarity of the final output",
    backstory="Senior engineer who reviews technical content for production readiness.",
    verbose=True,
    allow_delegation=False,
)

# 2. Define tasks
research_task = Task(
    description="Research KV-cache optimization techniques for LLM serving: PagedAttention, prefix caching, and memory management strategies.",
    expected_output="A detailed research summary with key techniques, trade-offs, and current state-of-the-art.",
    agent=researcher,
)

writing_task = Task(
    description="Write a technical guide based on the research findings.",
    expected_output="A structured document with introduction, techniques, code examples, and best practices.",
    agent=writer,
)

review_task = Task(
    description="Review the technical guide for accuracy, completeness, and clarity.",
    expected_output="Review with specific suggestions for improvement and a quality score.",
    agent=reviewer,
)

# 3. Create and run the crew
crew = Crew(
    agents=[researcher, writer, reviewer],
    tasks=[research_task, writing_task, review_task],
    process=Process.sequential,  # or Process.hierarchical
    verbose=True,
)

result = crew.kickoff()
print(result)

# Expected output: Sequential execution through all 3 agents
# Total time: ~30-60 seconds (3 LLM calls)
```

### Framework Comparison (April 2026)

| Aspect | LangGraph | CrewAI | Google ADK |
|--------|-----------|--------|------------|
| **Architecture** | Graph-based (nodes + edges) | Role-based teams | Hierarchical + graph |
| **State management** | Explicit typed state | Implicit task context | Session-based |
| **Flexibility** | Maximum â€” build any pattern | Medium â€” opinionated framework | High â€” Google ecosystem |
| **Multi-agent** | ✅ Any pattern (supervisor, swarm, etc.) | ✅ Sequential or hierarchical | ✅ Sub-agents + delegation |
| **Protocol support** | MCP via langchain-mcp | MCP via plugins | A2A native, MCP support |
| **Learning curve** | High (graph concepts) | Low (intuitive roles/tasks) | Medium |
| **Production use** | ✅ Widely adopted | âš ï¸ Growing | ✅ Google-backed |
| **Best for** | Custom, complex workflows | Quick prototyping, business automation | Google Cloud integration |

```
DECISION GUIDE:
  "I need maximum control and custom patterns"     → LangGraph
  "I want to prototype quickly with roles/tasks"   → CrewAI
  "I'm in the Google Cloud ecosystem"              → Google ADK
  "I need inter-company agent communication"       → A2A protocol (any framework)
```

---

## ◆ Quick Reference

```
MULTI-AGENT DESIGN CHECKLIST:
  â–¡ Can a single agent with tools solve this? (If yes → don't use multi-agent)
  â–¡ What specific bottleneck justifies adding agents?
  â–¡ What's the coordination pattern? (Supervisor / Pipeline / Debate / Fan-out)
  â–¡ How do agents share state? (Shared dict / Message passing / Workspace)
  â–¡ What's the failure path? (Max retries, human escalation, fallback)
  â–¡ How do you observe and debug? (Tracing per-agent, trajectory logging)
  â–¡ What's the cost per request? (N agents Ã— LLM cost per agent)

MULTI-AGENT COST MODEL:
  Single agent:    1 Ã— (LLM call + tools) = ~$0.03
  Supervisor + 3 workers: 4-7 Ã— LLM call = ~$0.12-$0.21
  Debate (2 rounds): 5-7 Ã— LLM call = ~$0.15-$0.21

  Rule of thumb: Multi-agent costs 3-7Ã— more than single-agent.
  Make sure the quality improvement justifies this.
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Token explosion** | Costs spike, context windows overflow | Each agent adds messages to shared context; N agents Ã— M turns = huge context | Summarize between agents, limit message passing to structured data only |
| **Cascading failures** | One agent error causes all downstream agents to produce garbage | No error handling between agents, errors propagate as corrupted context | Add error boundaries, validate inter-agent output with schemas |
| **State inconsistency** | Agents contradict each other, use stale information | Distributed state without consistency guarantees | Use centralized state store, version state updates |
| **Role collapse** | All agents behave identically despite different system prompts | System prompts too similar, shared tools dominate behavior | Make roles concrete with tool restrictions, test role differentiation |
| **Infinite delegation** | Supervisor keeps routing back to the same agent, never finishes | No progress detection, weak stop conditions | Max iterations per agent (3-5), progress metrics, force termination |
| **Coordination overhead > value** | Multi-agent is slower and more expensive than single-agent with same quality | Task doesn't benefit from specialization | Benchmark single-agent baseline first; justify each additional agent |

---

## ○ Gotchas & Common Mistakes

- âš ï¸ **Multi-agent â‰  better**: The most common mistake is assuming more agents = more capability. Often one agent with good tools beats three agents with bad coordination.
- âš ï¸ **Debugging is 5Ã— harder**: Each agent adds a layer of opacity. Invest in trajectory logging and per-agent tracing before scaling up.
- âš ï¸ **Context sharing is the hardest part**: How agents share information (full messages vs summaries vs structured data) determines whether multi-agent works or fails.
- âš ï¸ **Cost multiplier is real**: 4 agents Ã— 3 turns each = 12 LLM calls per request. At $0.03/call, that's $0.36/request vs $0.09 for single-agent.
- âš ï¸ **Start with 2 agents, not 7**: The jump from 1→2 agents teaches you more about coordination than the jump from 5→7.

---

## ○ Interview Angles

- **Q**: When would you choose multi-agent over single-agent?
- **A**: I'd choose multi-agent when three conditions are met: (1) the task has natural decomposition boundaries where different sub-tasks benefit from different tool access, system prompts, or contexts â€” for example, a research agent with web search and a coding agent with a sandbox; (2) the quality improvement from specialization is measurable and significant, not incremental; and (3) the latency and cost multiplier (3-7Ã— more expensive) is acceptable for the use case. I'd always benchmark a single-agent baseline first. If one agent with well-designed tools achieves 80%+ of the quality, the coordination overhead of multi-agent isn't justified. The exception is adversarial review: having a critic agent that challenges the primary agent's output catches errors that self-review misses.

- **Q**: Design a multi-agent system for automated code review.
- **A**: I'd use a pipeline pattern with 3 agents. First, a Code Analyzer agent with access to static analysis tools (linting, complexity metrics, type checking) processes the diff and produces a structured analysis. Second, a Logic Reviewer agent with access to the codebase context (via RAG over the repo) evaluates correctness, identifies potential bugs, and checks for security issues. Third, a Summary Agent synthesizes both analyses into a human-readable review with actionable suggestions, severity levels, and specific line references. State management: each agent writes to a shared ReviewState dict with typed fields (analysis, logic_issues, suggestions). I'd add a max_cost guard ($0.50/review), trajectory logging via LangSmith, and a confidence scoreâ€”if any agent is < 70% confident, flag for human review instead of auto-approving.

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Research + Writing Team

**Goal**: Build a 2-agent system where one researches and one writes
**Time**: 60 minutes
**Steps**:
1. Create two agents in LangGraph: Researcher (with web search tool) and Writer
2. Implement the supervisor pattern that routes: research → write → done
3. Give them a topic: "Compare vLLM vs TGI for LLM serving in production"
4. Measure: total cost, latency, and output quality vs single-agent baseline
**Expected Output**: Structured document produced by the team, comparison metrics showing when multi-agent adds value

### Exercise 2: Debate Pattern for Fact Verification

**Goal**: Build a debate system that validates claims through adversarial review
**Time**: 45 minutes
**Steps**:
1. Create Agent A (claim defender) and Agent B (claim challenger)
2. Start with a claim: "Speculative decoding always reduces latency for LLM serving"
3. Run 2 rounds of debate (each agent responds to the other)
4. Add a Judge agent that reads the debate and renders a verdict
**Expected Output**: 2-round debate transcript + judge verdict explaining nuanced truth (speculative decoding only helps when draft model is fast and acceptance rate is high)

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [AI Agents](./ai-agents.md), [Agentic Protocols](./agentic-protocols.md), [Function Calling](../techniques/function-calling-and-structured-output.md) |
| Leads to | [Agent Evaluation](./agent-evaluation.md), [AI System Design](../production/ai-system-design.md), Enterprise automation |
| Compare with | Single-agent (simpler, cheaper), deterministic orchestration (Airflow/Prefect â€” no LLM reasoning), microservices (code not agents) |
| Cross-domain | Distributed systems, organizational design (Conway's Law), multi-player game AI |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ“„ Paper | [Anthropic â€” "Building Effective Agents" (2025)](https://docs.anthropic.com/en/docs/build-with-claude/agent-patterns) | Industry reference for when to use multi-agent vs single-agent patterns |
| ðŸ”§ Hands-on | [LangGraph Multi-Agent Tutorial](https://langchain-ai.github.io/langgraph/tutorials/multi_agent/) | Step-by-step supervisor and swarm pattern implementation |
| ðŸ”§ Hands-on | [CrewAI Documentation](https://docs.crewai.com/) | Easiest framework to prototype multi-agent teams quickly |
| ðŸŽ¥ Video | [Harrison Chase â€” "Multi-Agent Architectures" (LangChain)](https://www.youtube.com/watch?v=hvAPnpSfSGo) | LangGraph creator explaining when and how to use multi-agent patterns |
| ðŸ“˜ Book | "AI Engineering" by Chip Huyen (2025), Ch 7 (Agents) | Practical treatment of agent systems including multi-agent coordination |
| ðŸ“„ Paper | [Wu et al. "AutoGen: Enabling Next-Gen LLM Applications" (2023)](https://arxiv.org/abs/2308.08155) | Microsoft's multi-agent conversation framework and design patterns |
| ðŸ”§ Hands-on | [Google ADK Multi-Agent Documentation](https://google.github.io/adk-docs/) | Hierarchical agent teams with sub-agent delegation |

---

## ★ Sources

- Anthropic "Building Effective Agents" Guide (2025)
- LangGraph Multi-Agent Documentation â€” https://langchain-ai.github.io/langgraph/
- CrewAI Documentation â€” https://docs.crewai.com/
- Wu et al. "AutoGen: Enabling Next-Gen LLM Applications via Multi-Agent Conversation" (2023)
- Google ADK Documentation â€” https://google.github.io/adk-docs/
- [AI Agents](./ai-agents.md)
