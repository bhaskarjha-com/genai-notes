---
title: "AI Agents"
tags: [agents, agentic-ai, tool-use, function-calling, autonomy, genai-techniques]
type: concept
difficulty: intermediate
status: learning
parent: "[[../genai]]"
related: ["[[rag]]", "[[../llms/llms-overview]]", "[[prompt-engineering]]"]
source: "Multiple - see Sources"
created: 2026-03-18
updated: 2026-03-18
---

# AI Agents

> ✨ **Bit**: 2024 was "year of the chatbot." 2025-2026 is "year of the agent." The difference? Chatbots answer. Agents do.

---

## ★ TL;DR

- **What**: AI systems that autonomously plan, reason, use tools, and take multi-step actions to achieve goals
- **Why**: The biggest paradigm shift in GenAI since ChatGPT. Moves AI from "answer questions" to "complete tasks"
- **Key point**: An agent = LLM + Planning + Memory + Tools. The LLM is the brain, not the whole system.

---

## ★ Overview

### Definition

An **AI Agent** is a system where an LLM acts as a reasoning engine that can: (1) understand goals, (2) break them into sub-tasks, (3) decide which tools to use, (4) execute actions, (5) observe results, and (6) iterate until the goal is achieved — with minimal human intervention.

### Scope

Covers: Agent architecture, tool use, planning patterns, multi-agent systems, and frameworks. For the underlying LLM, see [[../llms/llms-overview]]. For RAG as a tool agents use, see [[rag]].

### Significance

- **Defining trend of 2025-2026**: Every major AI company is building agent capabilities
- Claude Opus 4 was specifically designed for agentic workflows
- Enterprise adoption is scaling: customer support, code generation, data analysis
- Projected to transform knowledge work more fundamentally than chatbots did

### Prerequisites

- [[../llms/llms-overview]] — the brain of the agent
- [[prompt-engineering]] — how to instruct agents
- [[rag]] — agents often use RAG as a tool

---

## ★ Deep Dive

### Agent Architecture

```
┌─────────────────────────────────────────────────────┐
│                    AI AGENT                          │
│                                                     │
│  ┌───────────────────────────────────────────┐      │
│  │           LLM (the brain)                 │      │
│  │  - Understands goals                      │      │
│  │  - Reasons about next steps               │      │
│  │  - Generates tool calls                   │      │
│  └───────────────────────────────────────────┘      │
│       │              │              │                │
│       ▼              ▼              ▼                │
│  ┌─────────┐   ┌──────────┐   ┌──────────┐         │
│  │ PLANNING│   │  MEMORY  │   │  TOOLS   │         │
│  │         │   │          │   │          │         │
│  │ - Task  │   │ - Short  │   │ - Search │         │
│  │   decomp│   │   (conv) │   │ - Code   │         │
│  │ - Step  │   │ - Long   │   │ - APIs   │         │
│  │   by    │   │   (RAG/  │   │ - Files  │         │
│  │   step  │   │   DB)    │   │ - Browse │         │
│  └─────────┘   └──────────┘   └──────────┘         │
│                                                     │
│  ┌───────────────────────────────────────────┐      │
│  │         OBSERVATION & FEEDBACK LOOP       │      │
│  │  Tool result → Reason → Next action → ... │      │
│  └───────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────┘
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

| Strategy | How | When |
|----------|-----|------|
| **ReAct** | Think → Act → Observe loop | General-purpose agent tasks |
| **Plan-and-Execute** | Create full plan first, then execute | Complex multi-step tasks |
| **Tree of Thoughts** | Explore multiple reasoning paths | Hard reasoning problems |
| **Reflexion** | Self-reflect on failures, retry | Tasks needing self-correction |

#### 3. Memory Systems

| Type | Implementation | Use |
|------|---------------|-----|
| **Short-term** | Conversation history in context | Current task state |
| **Long-term** | Vector DB / embeddings | Past interactions, knowledge |
| **Episodic** | Stored successful strategies | Learn from past tasks |
| **Working** | Scratchpad / notes during task | Complex reasoning steps |

### Agent Types

| Type | Description | Example |
|------|-------------|---------|
| **Single Agent** | One LLM with tools | ChatGPT with web browsing |
| **Multi-Agent** | Multiple specialized agents collaborating | CrewAI, AutoGen |
| **Hierarchical** | Manager agent delegates to worker agents | Complex workflows |
| **Competitive** | Agents debate/challenge each other | Red team / verification |

### Popular Frameworks (2025-2026)

| Framework | Strengths | Use Case |
|-----------|-----------|----------|
| **LangGraph** (LangChain) | Flexible graph-based workflows, stateful | Complex custom agents |
| **CrewAI** | Multi-agent, role-based collaboration | Team of specialized agents |
| **AutoGen** (Microsoft) | Multi-agent conversations | Research, code generation |
| **OpenAI Assistants API** | Managed, easy to start | Simple agents with tools |
| **Anthropic Tool Use** | Strong coding agents | Developer tools |
| **Semantic Kernel** | Enterprise .NET/Python | Enterprise integration |

---

## ◆ Code & Implementation

### Simple Agent with LangGraph

```python
from langgraph.graph import StateGraph, MessagesState, START, END
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool

# Define tools
@tool
def search_web(query: str) -> str:
    """Search the web for information."""
    # Implementation here
    return f"Results for: {query}"

@tool  
def calculator(expression: str) -> str:
    """Evaluate a math expression."""
    return str(eval(expression))

# Create LLM with tools
llm = ChatOpenAI(model="gpt-5.4").bind_tools([search_web, calculator])

# Define the agent logic
def agent_node(state: MessagesState):
    response = llm.invoke(state["messages"])
    return {"messages": [response]}

def tool_node(state: MessagesState):
    # Execute tool calls from the last message
    last_message = state["messages"][-1]
    results = []
    for tool_call in last_message.tool_calls:
        tool_fn = {"search_web": search_web, "calculator": calculator}
        result = tool_fn[tool_call["name"]].invoke(tool_call["args"])
        results.append(result)
    return {"messages": results}

def should_continue(state: MessagesState):
    last_message = state["messages"][-1]
    if last_message.tool_calls:
        return "tools"
    return END

# Build graph
graph = StateGraph(MessagesState)
graph.add_node("agent", agent_node)
graph.add_node("tools", tool_node)
graph.add_edge(START, "agent")
graph.add_conditional_edges("agent", should_continue, {"tools": "tools", END: END})
graph.add_edge("tools", "agent")  # After tools, back to agent

app = graph.compile()
result = app.invoke({"messages": [("user", "What is 25 * 47?")]})
```

---

## ◆ Strengths vs Limitations

| ✅ Strengths | ❌ Limitations |
|-------------|---------------|
| Can complete complex multi-step tasks | Unreliable — can get stuck in loops |
| Adapts approach based on observations | Expensive (many LLM calls per task) |
| Can use any tool via function calling | Security risk (executing code, API calls) |
| Handles ambiguous, open-ended goals | Hard to debug and test |
| Multi-agent enables specialization | Latency (multiple reasoning steps) |

---

## ◆ Agent Memory

```
MEMORY TYPES:
  ┌──────────────────────────────────────────────────────┐
  │  SHORT-TERM (Working Memory)                         │
  │  = Conversation context window                       │
  │  The messages in the current session.                │
  │  Lost when session ends.                             │
  ├──────────────────────────────────────────────────────┤
  │  LONG-TERM (Persistent Memory)                       │
  │  = External storage (vector DB, key-value store)     │
  │  Facts, preferences, past interactions.              │
  │  Persists across sessions.                           │
  │  "You told me last week you prefer Python."          │
  ├──────────────────────────────────────────────────────┤
  │  EPISODIC (Experience Memory)                        │
  │  = Records of past task executions                   │
  │  "Last time I solved this type of problem, I..."     │
  │  Enables learning from experience.                   │
  ├──────────────────────────────────────────────────────┤
  │  PROCEDURAL (How-to Memory)                          │
  │  = Tool usage patterns, successful strategies        │
  │  "When user asks for data analysis, use Python tool  │
  │   first, then visualization tool."                   │
  └──────────────────────────────────────────────────────┘

IMPLEMENTATION:
  Short-term  → Sliding window on conversation history
  Long-term   → Vector DB (Chroma, Pinecone) + retrieval
  Episodic    → Summarize and store past task outcomes
  Procedural  → Fine-tuned behaviors or prompt templates
```

---

## ◆ Framework Comparison (March 2026)

| Framework | By | Orchestration | Multi-Agent | Best For |
|-----------|-----|--------------|-------------|----------|
| **LangGraph** | LangChain | Graph-based stateful | ✅ | Complex workflows with state |
| **CrewAI** | Community | Role-based teams | ✅ | Business process automation |
| **AutoGen** | Microsoft | Chat-based | ✅ | Research, conversational agents |
| **ADK** | Google | Hierarchical + graph | ✅ | Google ecosystem, production |
| **Semantic Kernel** | Microsoft | Plugin-based | ⚠️ Basic | Enterprise .NET/Python |
| **Mastra** | Community | TypeScript-first | ✅ | JS/TS developers |

For protocols connecting agents (MCP, A2A), see [[agentic-protocols]].

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Agent ≠ Chatbot with tools**: A chatbot uses tools reactively. An agent plans proactively. Don't call everything an "agent."
- ⚠️ **Infinite loops**: Agents can get stuck retrying failed actions. Always set max iterations.
- ⚠️ **Tool description quality**: Agents are only as good as their tool descriptions. Bad descriptions = wrong tool choices.
- ⚠️ **Over-engineering**: Most problems don't need agents. Start with simple chains; add agent complexity only when needed.
- ⚠️ **Security**: Agents executing code or calling APIs can cause real damage. Always sandbox and add human-in-the-loop for critical actions.
- ⚠️ **Memory overflow**: Long-term memory without curation becomes noisy. Implement summarization and relevance filtering.

---

## ○ Interview Angles

- **Q**: What makes an AI agent different from a chatbot?
- **A**: A chatbot responds to messages. An agent sets goals, plans multi-step approaches, uses tools, observes results, and iterates. Agents are autonomous; chatbots are reactive.

- **Q**: How would you prevent an AI agent from getting stuck in a loop?
- **A**: Max iteration limits, self-reflection prompts ("Am I making progress?"), fallback to human, diverse retry strategies (try different tools/approaches), and logging for debugging.

- **Q**: What's the ReAct pattern?
- **A**: Reason + Act. The agent alternates between thinking (reasoning about what to do) and acting (calling tools). After each action, it observes the result and reasons about next steps. This interleaving of thought and action is more reliable than planning everything upfront.

- **Q**: How does agent memory work?
- **A**: Four types: short-term (conversation context), long-term (vector DB storing facts/preferences across sessions), episodic (summaries of past task executions for learning), and procedural (learned strategies and tool patterns). In practice, most production agents use short-term + simple long-term memory with vector retrieval.

---

## ★ Connections

| Relationship | Topics |
|-------------|--------|
| Builds on | [[../llms/llms-overview]], [[rag]], [[prompt-engineering]], [[function-calling-and-structured-output]] |
| Leads to | [[agentic-protocols]] (MCP/A2A/ADK), [[../applications/code-generation]] (coding agents) |
| Compare with | Simple chains (no autonomy), Chatbots (reactive only) |
| Cross-domain | Robotics (embodied agents), Game AI, Control theory |

---

## ★ Sources

- LangGraph documentation — https://langchain-ai.github.io/langgraph/
- Anthropic "Building Effective Agents" guide (2025)
- Yao et al., "ReAct: Synergizing Reasoning and Acting in Language Models" (2022)
- CrewAI documentation — https://docs.crewai.com
- AutoGen documentation — https://microsoft.github.io/autogen/
- Google ADK documentation — https://google.github.io/adk-docs/
- deeplearning.ai, "Agent Memory: Building Memory-Aware Agents" (2025)

