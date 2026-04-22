---
title: "AI Agents"
aliases: ["AI Agents", "ReAct", "Tool-Using LLM"]
tags: [agents, agentic-ai, tool-use, function-calling, autonomy, genai-techniques]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../techniques/rag.md", "../llms/llms-overview.md", "../techniques/prompt-engineering.md", "multi-agent-architectures.md", "agent-evaluation.md"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-04-12
---

# AI Agents

> âœ¨ **Bit**: 2024 was "year of the chatbot." 2025-2026 is "year of the agent." The difference? Chatbots answer. Agents do.

---

## â˜… TL;DR

- **What**: AI systems that autonomously plan, reason, use tools, and take multi-step actions to achieve goals
- **Why**: The biggest paradigm shift in GenAI since ChatGPT. Moves AI from "answer questions" to "complete tasks"
- **Key point**: An agent = LLM + Planning + Memory + Tools. The LLM is the brain, not the whole system.

---

## â˜… Overview

### Definition

An **AI Agent** is a system where an LLM acts as a reasoning engine that can: (1) understand goals, (2) break them into sub-tasks, (3) decide which tools to use, (4) execute actions, (5) observe results, and (6) iterate until the goal is achieved â€” with minimal human intervention.

### Scope

Covers: Agent architecture, tool use, planning patterns, multi-agent systems, and frameworks. For the underlying LLM, see [Llms Overview](../llms/llms-overview.md). For RAG as a tool agents use, see [Rag](../techniques/rag.md). For specialized coordination patterns, see [Multi-Agent Architectures](./multi-agent-architectures.md). For tracing and scoring agent runs, see [Agent Evaluation & Observability](./agent-evaluation.md).

### Significance

- **Defining trend of 2025-2026**: Every major AI company is building agent capabilities
- Claude Opus 4 was specifically designed for agentic workflows
- Enterprise adoption is scaling: customer support, code generation, data analysis
- Projected to transform knowledge work more fundamentally than chatbots did

### Prerequisites

- [Llms Overview](../llms/llms-overview.md) â€” the brain of the agent
- [Prompt Engineering](../techniques/prompt-engineering.md) â€” how to instruct agents
- [Rag](../techniques/rag.md) â€” agents often use RAG as a tool

---

## â˜… Deep Dive

### Agent Architecture

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    AI AGENT                          â”‚
â”‚                                                     â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”‚
â”‚  â”‚           LLM (the brain)                 â”‚      â”‚
â”‚  â”‚  - Understands goals                      â”‚      â”‚
â”‚  â”‚  - Reasons about next steps               â”‚      â”‚
â”‚  â”‚  - Generates tool calls                   â”‚      â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â”‚
â”‚       â”‚              â”‚              â”‚                â”‚
â”‚       â–¼              â–¼              â–¼                â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”         â”‚
â”‚  â”‚ PLANNINGâ”‚   â”‚  MEMORY  â”‚   â”‚  TOOLS   â”‚         â”‚
â”‚  â”‚         â”‚   â”‚          â”‚   â”‚          â”‚         â”‚
â”‚  â”‚ - Task  â”‚   â”‚ - Short  â”‚   â”‚ - Search â”‚         â”‚
â”‚  â”‚   decompâ”‚   â”‚   (conv) â”‚   â”‚ - Code   â”‚         â”‚
â”‚  â”‚ - Step  â”‚   â”‚ - Long   â”‚   â”‚ - APIs   â”‚         â”‚
â”‚  â”‚   by    â”‚   â”‚   (RAG/  â”‚   â”‚ - Files  â”‚         â”‚
â”‚  â”‚   step  â”‚   â”‚   DB)    â”‚   â”‚ - Browse â”‚         â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜         â”‚
â”‚                                                     â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”‚
â”‚  â”‚         OBSERVATION & FEEDBACK LOOP       â”‚      â”‚
â”‚  â”‚  Tool result â†’ Reason â†’ Next action â†’ ... â”‚      â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### The Agent Loop (ReAct Pattern)

```
User Goal: "Research the top 3 competitors and create a comparison table"

THINK: I need to search for competitors first.
ACT:   tool_call: web_search("top competitors for [product]")
OBSERVE: [search results returned]

THINK: I found 5 competitors. Let me get details on top 3.
ACT:   tool_call: web_search("competitor A features pricing")
OBSERVE: [detailed results]

THINK:  I have enough data. Let me create the table.
ACT:   tool_call: create_document("comparison_table.md", content)
OBSERVE: [file created successfully]

THINK: Task complete. Let me present the results.
ACT:   respond_to_user(summary + table)
```

### Core Components

#### 1. Tool Use / Function Calling

```json
// LLM receives tool definitions
{
  "tools": [
    {
      "name": "search_web",
      "description": "Search the internet for information",
      "parameters": {
        "query": {"type": "string", "description": "Search query"}
      }
    },
    {
      "name": "run_python",
      "description": "Execute Python code",
      "parameters": {
        "code": {"type": "string", "description": "Python code to run"}
      }
    }
  ]
}

// LLM outputs a tool call (instead of text)
{
  "tool_call": {
    "name": "search_web",
    "arguments": {"query": "latest AI trends 2026"}
  }
}

// System executes tool, returns result to LLM
// LLM decides: respond to user, or call another tool
```

#### 2. Planning Strategies

| Strategy             | How                                  | When                          |
| -------------------- | ------------------------------------ | ----------------------------- |
| **ReAct**            | Think â†’ Act â†’ Observe loop           | General-purpose agent tasks   |
| **Plan-and-Execute** | Create full plan first, then execute | Complex multi-step tasks      |
| **Tree of Thoughts** | Explore multiple reasoning paths     | Hard reasoning problems       |
| **Reflexion**        | Self-reflect on failures, retry      | Tasks needing self-correction |

#### 3. Memory Systems

| Type           | Implementation                  | Use                          |
| -------------- | ------------------------------- | ---------------------------- |
| **Short-term** | Conversation history in context | Current task state           |
| **Long-term**  | Vector DB / embeddings          | Past interactions, knowledge |
| **Episodic**   | Stored successful strategies    | Learn from past tasks        |
| **Working**    | Scratchpad / notes during task  | Complex reasoning steps      |

### Agent Types

| Type             | Description                               | Example                   |
| ---------------- | ----------------------------------------- | ------------------------- |
| **Single Agent** | One LLM with tools                        | ChatGPT with web browsing |
| **Multi-Agent**  | Multiple specialized agents collaborating | CrewAI, AutoGen           |
| **Hierarchical** | Manager agent delegates to worker agents  | Complex workflows         |
| **Competitive**  | Agents debate/challenge each other        | Red team / verification   |

### Popular Frameworks (2025-2026)

| Framework                 | Strengths                                | Use Case                   |
| ------------------------- | ---------------------------------------- | -------------------------- |
| **LangGraph** (LangChain) | Flexible graph-based workflows, stateful | Complex custom agents      |
| **CrewAI**                | Multi-agent, role-based collaboration    | Team of specialized agents |
| **AutoGen** (Microsoft)   | Multi-agent conversations                | Research, code generation  |
| **OpenAI Assistants API** | Managed, easy to start                   | Simple agents with tools   |
| **Anthropic Tool Use**    | Strong coding agents                     | Developer tools            |
| **Semantic Kernel**       | Enterprise .NET/Python                   | Enterprise integration     |

---

## â—† Code & Implementation

### Simple Agent with LangGraph

```python
# pip install langgraph>=0.3 langchain-openai>=0.3
# âš ï¸ Last tested: 2026-04 | Requires: langgraph>=0.3

from langgraph.graph import StateGraph, MessagesState, START, END
from langgraph.prebuilt import ToolNode
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool

@tool
def search_web(query: str) -> str:
    """Search the web for information."""
    # Implementation here
    return f"Results for: {query}"

@tool
def calculator(expression: str) -> str:
    """Evaluate a math expression."""
    # âš ï¸ SECURITY: eval() used for demo only. In production, use a safe
    # expression parser like `simpleeval` or `numexpr`. Never eval() untrusted input.
    return str(eval(expression))

# Create LLM with tools
tools = [search_web, calculator]
llm = ChatOpenAI(model="gpt-4o").bind_tools(tools)

# Define the agent logic
def agent_node(state: MessagesState):
    response = llm.invoke(state["messages"])
    return {"messages": [response]}

def should_continue(state: MessagesState):
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tools"
    return END

# Build graph â€” ToolNode handles ToolMessage creation automatically
graph = StateGraph(MessagesState)
graph.add_node("agent", agent_node)
graph.add_node("tools", ToolNode(tools))  # Correctly wraps results in ToolMessage
graph.add_edge(START, "agent")
graph.add_conditional_edges("agent", should_continue, {"tools": "tools", END: END})
graph.add_edge("tools", "agent")  # After tools, back to agent

app = graph.compile()
result = app.invoke({"messages": [("user", "What is 25 * 47?")]})
```

---

## â—† Strengths vs Limitations

| âœ… Strengths                           | âŒ Limitations                             |
| ------------------------------------- | ----------------------------------------- |
| Can complete complex multi-step tasks | Unreliable â€” can get stuck in loops       |
| Adapts approach based on observations | Expensive (many LLM calls per task)       |
| Can use any tool via function calling | Security risk (executing code, API calls) |
| Handles ambiguous, open-ended goals   | Hard to debug and test                    |
| Multi-agent enables specialization    | Latency (multiple reasoning steps)        |

---

## â—† Agent Memory

```
MEMORY TYPES:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  SHORT-TERM (Working Memory)                         â”‚
  â”‚  = Conversation context window                       â”‚
  â”‚  The messages in the current session.                â”‚
  â”‚  Lost when session ends.                             â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚  LONG-TERM (Persistent Memory)                       â”‚
  â”‚  = External storage (vector DB, key-value store)     â”‚
  â”‚  Facts, preferences, past interactions.              â”‚
  â”‚  Persists across sessions.                           â”‚
  â”‚  "You told me last week you prefer Python."          â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚  EPISODIC (Experience Memory)                        â”‚
  â”‚  = Records of past task executions                   â”‚
  â”‚  "Last time I solved this type of problem, I..."     â”‚
  â”‚  Enables learning from experience.                   â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚  PROCEDURAL (How-to Memory)                          â”‚
  â”‚  = Tool usage patterns, successful strategies        â”‚
  â”‚  "When user asks for data analysis, use Python tool  â”‚
  â”‚   first, then visualization tool."                   â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

IMPLEMENTATION:
  Short-term  â†’ Sliding window on conversation history
  Long-term   â†’ Vector DB (Chroma, Pinecone) + retrieval
  Episodic    â†’ Summarize and store past task outcomes
  Procedural  â†’ Fine-tuned behaviors or prompt templates
```

---

## â—† Framework Comparison (March 2026)

| Framework           | By        | Orchestration        | Multi-Agent | Best For                        |
| ------------------- | --------- | -------------------- | ----------- | ------------------------------- |
| **LangGraph**       | LangChain | Graph-based stateful | âœ…           | Complex workflows with state    |
| **CrewAI**          | Community | Role-based teams     | âœ…           | Business process automation     |
| **AutoGen**         | Microsoft | Chat-based           | âœ…           | Research, conversational agents |
| **ADK**             | Google    | Hierarchical + graph | âœ…           | Google ecosystem, production    |
| **Semantic Kernel** | Microsoft | Plugin-based         | âš ï¸ Basic     | Enterprise .NET/Python          |
| **Mastra**          | Community | TypeScript-first     | âœ…           | JS/TS developers                |

For protocols connecting agents (MCP, A2A), see [Agentic Protocols](./agentic-protocols.md).

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Agent â‰  Chatbot with tools**: A chatbot uses tools reactively. An agent plans proactively. Don't call everything an "agent."
- âš ï¸ **Infinite loops**: Agents can get stuck retrying failed actions. Always set max iterations.
- âš ï¸ **Tool description quality**: Agents are only as good as their tool descriptions. Bad descriptions = wrong tool choices.
- âš ï¸ **Over-engineering**: Most problems don't need agents. Start with simple chains; add agent complexity only when needed.
- âš ï¸ **Security**: Agents executing code or calling APIs can cause real damage. Always sandbox and add human-in-the-loop for critical actions.
- âš ï¸ **Memory overflow**: Long-term memory without curation becomes noisy. Implement summarization and relevance filtering.

---

## â—‹ Interview Angles

- **Q**: What makes an AI agent different from a chatbot?
- **A**: A chatbot responds to messages. An agent sets goals, plans multi-step approaches, uses tools, observes results, and iterates. Agents are autonomous; chatbots are reactive.

- **Q**: How would you prevent an AI agent from getting stuck in a loop?
- **A**: Max iteration limits, self-reflection prompts ("Am I making progress?"), fallback to human, diverse retry strategies (try different tools/approaches), and logging for debugging.

- **Q**: What's the ReAct pattern?
- **A**: Reason + Act. The agent alternates between thinking (reasoning about what to do) and acting (calling tools). After each action, it observes the result and reasons about next steps. This interleaving of thought and action is more reliable than planning everything upfront.

- **Q**: How does agent memory work?
- **A**: Four types: short-term (conversation context), long-term (vector DB storing facts/preferences across sessions), episodic (summaries of past task executions for learning), and procedural (learned strategies and tool patterns). In practice, most production agents use short-term + simple long-term memory with vector retrieval.

---

## â˜… Connections

| Relationship | Topics                                                                                                 |
| ------------ | ------------------------------------------------------------------------------------------------------ |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Rag](../techniques/rag.md), [Prompt Engineering](../techniques/prompt-engineering.md), [Function Calling And Structured Output](../techniques/function-calling-and-structured-output.md) |
| Leads to     | [Agentic Protocols](./agentic-protocols.md) (MCP/A2A/ADK), [Code Generation](../applications/code-generation.md) (coding agents)               |
| Compare with | Simple chains (no autonomy), Chatbots (reactive only)                                                  |
| Cross-domain | Robotics (embodied agents), Game AI, Control theory                                                    |


---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Infinite loops** | Agent repeats the same action indefinitely, burning tokens | No exit condition, tool output doesn't resolve query | Max iteration limits, loop detection, exponential backoff |
| **Tool misuse** | Agent calls wrong tool or passes wrong arguments | Ambiguous tool descriptions, too many tools | Clear docstrings, reduce active tool set per task, few-shot examples |
| **State corruption** | Agent "forgets" previous observations, contradicts itself | Message history exceeds context window | Sliding window with summarization, explicit state tracking |
| **Cascading failures** | One tool error causes entire workflow to crash | No error handling in tool execution layer | Try/catch per tool call, graceful degradation, fallback tools |
| **Cost explosion** | Agent runs up large bills on a single query | Unconstrained reasoning depth | Token budgets per run, model routing (expensive for reasoning only) |

---

## â—† Hands-On Exercises

### Exercise 1: Build an Agent with Guardrails

**Goal**: Create a LangGraph agent with loop detection and cost limits
**Time**: 45 minutes
**Steps**:
1. Build a 3-tool agent (search, calculator, code interpreter)
2. Add max_iterations=10 limit
3. Add duplicate-action detection
4. Add token counting per run
5. Test with adversarial queries designed to trigger loops
**Expected Output**: Agent that gracefully terminates rather than looping, with cost logged

### Exercise 2: Compare Agent Architectures

**Goal**: Build the same workflow as ReAct vs Plan-and-Execute and compare
**Time**: 30 minutes
**Steps**:
1. Implement a ReAct loop for a research task
2. Implement a Plan-then-Execute version for the same task
3. Run 5 queries on both
4. Compare cost, latency, and answer quality
**Expected Output**: Comparison table with cost/latency/quality per architecture
---


## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸ“„ Paper | [Anthropic â€” "Building Effective Agents" (2025)](https://docs.anthropic.com/en/docs/build-with-claude/agent-patterns) | Industry reference for agent design patterns |
| ðŸ“˜ Book | "AI Engineering" by Chip Huyen (2025), Ch 7 (Agents) | Practical treatment of agent loops, tools, and memory |
| ðŸ”§ Hands-on | [LangGraph Documentation](https://langchain-ai.github.io/langgraph/) | Build production agent workflows with state management |
| ðŸŽ¥ Video | [Harrison Chase â€” "What Are AI Agents?"](https://www.youtube.com/watch?v=DWUdGhRrv2c) | LangChain creator explaining agent architectures |

## â˜… Sources

- LangGraph documentation â€” https://langchain-ai.github.io/langgraph/
- Anthropic "Building Effective Agents" guide (2025)
- Yao et al., "ReAct: Synergizing Reasoning and Acting in Language Models" (2022)
- CrewAI documentation â€” https://docs.crewai.com
- AutoGen documentation â€” https://microsoft.github.io/autogen/
- Google ADK documentation â€” https://google.github.io/adk-docs/
- deeplearning.ai, "Agent Memory: Building Memory-Aware Agents" (2025)

