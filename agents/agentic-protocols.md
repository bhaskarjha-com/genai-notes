---
title: "Agentic Protocols & Frameworks"
tags: [mcp, a2a, adk, agent-protocols, langraph, crewai, autogen, agentic-infra, genai]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["ai-agents.md", "../techniques/function-calling-and-structured-output.md", "../tools-and-infra/tools-overview.md"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Agentic Protocols & Frameworks

> ✨ **Bit**: MCP is like USB — it connects your AI to tools. A2A is like TCP/IP — it lets AIs talk to each other. ADK is like a factory — it builds the AIs. Together they're the plumbing of the agentic revolution.

---

## ★ TL;DR

- **What**: The standard protocols and frameworks for building, connecting, and orchestrating AI agents
- **Why**: Building one agent is easy. Building 5 agents that use 20 tools and talk to each other? You need standards. MCP, A2A, and ADK are those standards.
- **Key point**: MCP (agent↔tool), A2A (agent↔agent), and ADK (build agents) are complementary — not competitors. Think HTTP + WebSocket + a web framework.

---

## ★ Overview

### Definition

- **MCP (Model Context Protocol)**: Open standard (originally by Anthropic, now governed by the Linux Foundation's Agentic AI Foundation) for connecting LLM applications to external tools, data, and services
- **A2A (Agent-to-Agent Protocol)**: Open standard by Google for communication between different AI agents
- **ADK (Agent Development Kit)**: Google's open-source framework for building, deploying, and orchestrating AI agents

### Scope

Covers protocols and frameworks. For agent architecture/planning patterns, see [Ai Agents](./ai-agents.md). For function calling API patterns, see [Function Calling And Structured Output](../techniques/function-calling-and-structured-output.md).

### Significance

- deeplearning.ai has 3+ courses on MCP/A2A/ADK (2025-2026)
- Google Cloud NEXT 2025 featured ADK + A2A as headline announcements
- MCP adopted by OpenAI, Google, Anthropic — industry standard
- These are the "infrastructure layer" that GenAI engineers build on

---

## ★ Deep Dive

### How They Fit Together

```
┌─────────────────────────────────────────────────────────┐
│                 THE AGENTIC STACK                        │
│                                                         │
│  ┌─────────────────────────────────────────────┐        │
│  │           YOUR APPLICATION                    │        │
│  │  (Chat app, workflow automation, etc.)        │        │
│  └────────────────────┬────────────────────────┘        │
│                       │                                  │
│  ┌────────────────────▼────────────────────────┐        │
│  │           AGENT FRAMEWORK (ADK)              │        │
│  │  Build agents, orchestrate, deploy            │        │
│  │  Also: LangGraph, CrewAI, AutoGen            │        │
│  └──────┬──────────────────────┬───────────────┘        │
│         │                      │                         │
│  ┌──────▼──────┐       ┌──────▼──────┐                  │
│  │ MCP Protocol│       │ A2A Protocol│                  │
│  │ Agent ↔ Tool│       │ Agent ↔ Agent│                 │
│  │             │       │              │                  │
│  │ "Use this   │       │ "Hey Agent B,│                 │
│  │  database"  │       │  do this task│                 │
│  │  "Search    │       │  for me"     │                  │
│  │   the web"  │       │              │                  │
│  └──────┬──────┘       └──────┬──────┘                  │
│         │                      │                         │
│  ┌──────▼──────┐       ┌──────▼──────┐                  │
│  │ MCP Servers │       │ Other Agents │                  │
│  │ (GitHub,    │       │ (May be built│                  │
│  │  Postgres,  │       │  by different│                  │
│  │  Slack...)  │       │  companies)  │                  │
│  └─────────────┘       └─────────────┘                  │
└─────────────────────────────────────────────────────────┘
```

### MCP (Model Context Protocol) — Agent ↔ Tool

```
ARCHITECTURE: Client-Host-Server

  ┌────────────┐    ┌────────────┐    ┌────────────┐
  │  MCP HOST   │    │  MCP HOST   │    │            │
  │  (Claude,   │    │  (Your App) │    │ MCP SERVER │
  │   Cursor)   │    │             │    │ (Postgres) │
  │             │    │             │    │            │
  │ ┌────────┐  │    │ ┌────────┐  │    │ Exposes:   │
  │ │MCP     │──┼────┼─│MCP     │  │    │ - Tools    │
  │ │CLIENT  │  │    │ │CLIENT  │──┼───▶│ - Resources│
  │ └────────┘  │    │ └────────┘  │    │ - Prompts  │
  └────────────┘    └────────────┘    └────────────┘

  Transport: JSON-RPC 2.0 over:
    - STDIO (local process, same machine)
    - HTTP + SSE (remote, network)

THREE PRIMITIVES:
  ┌──────────────────────────────────────────────┐
  │  TOOLS = Functions the LLM can call           │
  │    get_weather(), query_database(), commit()  │
  │    Model-controlled, needs human approval     │
  │                                              │
  │  RESOURCES = Data the LLM can read            │
  │    file:///users/data.csv                     │
  │    db://users/schema                          │
  │    Application-controlled (UI exposes them)   │
  │                                              │
  │  PROMPTS = Pre-built templates                │
  │    "Summarize this document"                  │
  │    "Generate a SQL query for..."              │
  │    User-controlled (user selects them)        │
  └──────────────────────────────────────────────┘

SECURITY (2026 spec):
  - MCP servers = OAuth 2.0 Resource Servers
  - Enterprise auth: SSO-integrated flows (Cross-App Access)
  - Structured JSON output (structuredContent)
  - User elicitation (model can ask for input mid-session)
  - Rate limiting, scope consent, observability/audit trails

MCP SERVER EXAMPLES:
  GitHub       → repos, issues, PRs as tools
  PostgreSQL   → query, schema as tools + resources
  Slack        → send/read messages
  Filesystem   → read/write files
  Web Search   → search the internet
  Custom       → YOUR API as an MCP server
```

### A2A (Agent-to-Agent Protocol) — Agent ↔ Agent

```
WHAT: Standard for AI agents made by DIFFERENT providers
      to communicate and collaborate.

WHY: MCP connects agent to tools.
     But what if one agent needs ANOTHER agent's help?

     Agent A (travel planner) needs Agent B (payment processor)
     They may be built by different companies/frameworks.
     A2A is their common language.

HOW IT WORKS:

  1. AGENT CARDS (Discovery)
     Each agent publishes a JSON "Agent Card" describing:
     - Name, description
     - Capabilities (what it can do)
     - Endpoints (how to reach it)
     - Auth requirements

     Like a business card for AI agents.
     Typically at: /.well-known/agent.json

  2. TASK MANAGEMENT
     Agent A sends a task to Agent B:
     {
       "task": "book_flight",
       "params": {"from": "NYC", "to": "LON", "date": "..."}
     }

     Agent B can:
     - Accept and process immediately
     - Return progress updates (async via webhooks)
     - Stream results (via SSE)
     - Request more info

  3. COMMUNICATION MODES
     Synchronous:  Request → Response (simple tasks)
     Async:        Request → Webhook updates → Final result
     Streaming:    Request → SSE stream → Progressive results

A2A vs MCP:
  ┌──────────────────────────────────────────────┐
  │  MCP:  "Hey database, give me user data"     │
  │         Agent → Tool (structured function)    │
  │                                              │
  │  A2A:  "Hey booking agent, find me a flight" │
  │         Agent → Agent (autonomous delegation) │
  │                                              │
  │  They're COMPLEMENTARY, not competing.       │
  └──────────────────────────────────────────────┘
```

### ADK (Agent Development Kit) — Build Agents

```
WHAT: Google's open-source framework for building AI agents.
      Announced at Google Cloud NEXT 2025.

KEY FEATURES:
  - Multi-agent orchestration (hierarchical teams)
  - Built-in MCP + A2A support
  - Model-agnostic (Gemini, GPT, Claude)
  - Graph-based workflows (ADK Python 2.0)
  - Local UI playground for testing
  - Deploy to Vertex AI, Cloud Run, or Docker

AGENT HIERARCHY IN ADK:
  ┌─────────────────────────────────────────┐
  │  ROOT AGENT (orchestrator)              │
  │    │                                    │
  │    ├── Sub-Agent: Research              │
  │    │   └── Tools: web_search, read_doc  │
  │    │                                    │
  │    ├── Sub-Agent: Analysis              │
  │    │   └── Tools: python_exec, db_query │
  │    │                                    │
  │    └── Sub-Agent: Report Writer         │
  │        └── Tools: file_write, format    │
  │                                         │
  │  Root delegates tasks to sub-agents     │
  │  Sub-agents can delegate further        │
  └─────────────────────────────────────────┘
```

### Framework Comparison (March 2026)

| Framework           | By        | Best For                         | Multi-Agent    | MCP | A2A | Graph Workflow |
| ------------------- | --------- | -------------------------------- | -------------- | --- | --- | -------------- |
| **ADK**             | Google    | Google ecosystem, full lifecycle | ✅ Hierarchical | ✅   | ✅   | ✅ (2.0)        |
| **LangGraph**       | LangChain | Complex stateful agents          | ✅ Graph-based  | ✅   | ❌   | ✅              |
| **CrewAI**          | Community | Role-based agent teams           | ✅ Role-based   | ✅   | ❌   | ⚠️ Limited      |
| **AutoGen**         | Microsoft | Research, conversational         | ✅ Chat-based   | ✅   | ❌   | ❌              |
| **Semantic Kernel** | Microsoft | Enterprise .NET/Python           | ⚠️ Basic        | ✅   | ❌   | ❌              |
| **Mastra**          | Community | TypeScript-first                 | ✅              | ✅   | ❌   | ✅              |

---

## ◆ Code Example: MCP Server

```python
# ⚠️ Last tested: 2026-04
# ═══ Building a simple MCP server ═══
from mcp.server import Server
from mcp.types import Tool, TextContent

app = Server("weather-server")

@app.list_tools()
async def list_tools():
    return [
        Tool(
            name="get_weather",
            description="Get current weather for a city",
            inputSchema={
                "type": "object",
                "properties": {
                    "city": {"type": "string", "description": "City name"}
                },
                "required": ["city"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "get_weather":
        city = arguments["city"]
        # Your actual weather API call here
        return [TextContent(type="text", text=f"Weather in {city}: 22°C, sunny")]

# Run with: python server.py
# Connect from Claude Desktop, Cursor, or any MCP client
```

---

## ◆ Quick Reference

```
PROTOCOL CHEAT SHEET:
  Need agent to use tools (DB, API, files)?  → MCP
  Need agents to talk to each other?          → A2A
  Need to build the agents?                    → ADK / LangGraph / CrewAI

MATURITY (March 2026):
  MCP:     Production-ready ✅ (Linux Foundation standard, adopted by OpenAI, Google, Anthropic)
  A2A:     Early adoption ⚠️ (spec stable, ecosystem growing)
  ADK:     GA ✅ (deployed on Vertex AI, active development)

MCP PRIMITIVES:
  Tools     = functions to call (model-controlled)
  Resources = data to read (application-controlled)
  Prompts   = pre-built templates (user-controlled)
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **MCP ≠ function calling**: Function calling is the LLM API feature. MCP is the PROTOCOL for discovering and connecting to tools. MCP uses function calling under the hood.
- ⚠️ **A2A is not for tool use**: Don't use A2A when MCP suffices. A2A is for agent-to-agent delegation, not simple tool calls.
- ⚠️ **ADK is Google-optimized**: While model-agnostic, ADK works best with Gemini + Vertex AI. Consider LangGraph for fully provider-neutral needs.
- ⚠️ **Security is YOUR problem**: MCP servers can expose sensitive data. Always implement auth, rate limiting, and access controls.

---

## ○ Interview Angles

- **Q**: What's the difference between MCP and A2A?
- **A**: MCP connects an agent to TOOLS (databases, APIs, filesystems) — it's agent-to-tool communication. A2A connects an agent to OTHER AGENTS — it's agent-to-agent collaboration. MCP is like a USB port (connect devices), A2A is like a network protocol (connect computers). They're complementary: an agent uses MCP to access its own tools and A2A to delegate tasks to other agents.

- **Q**: Why do we need MCP if we already have function calling?
- **A**: Function calling is model-specific (OpenAI's API, Anthropic's API). MCP is a universal standard — build one MCP server and it works with Claude, GPT, Gemini, Cursor, and any MCP client. It also adds discovery (list available tools), resources (data access), and security (OAuth). It's the difference between every device having a custom charger vs. everyone using USB-C.

---

## ★ Code & Implementation

### MCP-Compatible Tool Server (FastMCP)

```python
# pip install fastmcp>=0.1 httpx>=0.27
# ⚠️ Last tested: 2026-04 | Requires: fastmcp>=0.1
# Model Context Protocol server — compatible with Claude Desktop, Cursor, custom agents

from fastmcp import FastMCP
import httpx

mcp = FastMCP("demo-server")

@mcp.tool()
def get_weather(city: str) -> str:
    """Get current weather for a city. Returns temperature and condition."""
    # In production: call real weather API
    return f"{city}: 22°C, partly cloudy (simulated)"

@mcp.tool()
def calculate(expression: str) -> str:
    """Safely evaluate a math expression. Supports +, -, *, /, **, sqrt."""
    import math
    try:
        result = eval(expression, {"__builtins__": {}}, {"sqrt": math.sqrt, "pi": math.pi})
        return str(result)
    except Exception as e:
        return f"Error: {e}"

@mcp.resource("docs://readme")
def get_readme() -> str:
    """Expose the project README as a resource."""
    return "This is the project documentation (placeholder)."

# Run: python server.py (starts on stdio for MCP clients)
# or:  mcp.run(transport="sse")  for HTTP/SSE transport
if __name__ == "__main__":
    mcp.run()
```

### ReAct Agent Loop

```python
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY
from openai import OpenAI
import json

client = OpenAI()

TOOLS = [{
    "type": "function",
    "function": {
        "name": "calculate",
        "description": "Evaluate a math expression",
        "parameters": {"type": "object", "properties": {
            "expression": {"type": "string", "description": "e.g. '2 ** 10'"}
        }, "required": ["expression"]},
    }
}]

def calculate(expression: str) -> str:
    import math
    return str(eval(expression, {}, {"sqrt": math.sqrt}))

def react_agent(user_query: str, max_steps: int = 5) -> str:
    messages = [{"role": "user", "content": user_query}]
    for step in range(max_steps):
        resp = client.chat.completions.create(
            model="gpt-4o-mini", messages=messages, tools=TOOLS, tool_choice="auto"
        )
        msg = resp.choices[0].message
        messages.append(msg)
        if not msg.tool_calls:
            return msg.content   # final answer
        for call in msg.tool_calls:
            args   = json.loads(call.function.arguments)
            result = calculate(**args)
            messages.append({"role": "tool", "tool_call_id": call.id, "content": result})
    return "Max steps reached"

print(react_agent("What is 2 to the power of 10, times pi?"))
```

## ★ Connections

| Relationship | Topics                                                                                                                         |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| Builds on    | [Function Calling And Structured Output](../techniques/function-calling-and-structured-output.md), [Ai Agents](./ai-agents.md) |
| Leads to     | Production multi-agent systems, Enterprise AI                                                                                  |
| Compare with | REST APIs (static), GraphQL (query), gRPC (binary)                                                                             |
| Cross-domain | Microservices architecture, API gateways, Service mesh                                                                         |


---

## ◆ Production Failure Modes

| Failure                       | Symptoms                                                  | Root Cause                                   | Mitigation                                                    |
| ----------------------------- | --------------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------- |
| **Protocol version mismatch** | Agent fails to connect to MCP server or A2A endpoint      | Client/server on different protocol versions | Version negotiation in handshake, backward compat layer       |
| **Tool discovery overload**   | Agent overwhelmed by too many available tools             | Server exposes all tools without filtering   | Server-side tool filtering, capability manifests per task     |
| **Auth token expiration**     | Agent mid-workflow loses access to services               | OAuth token TTL shorter than workflow        | Token refresh middleware, proactive refresh before expiration |
| **Serialization failures**    | Complex tool inputs/outputs fail across protocol boundary | Non-JSON-serializable types, binary data     | Schema validation at boundary, base64 for binary              |

---

## ◆ Hands-On Exercises

### Exercise 1: Connect to an MCP Server

**Goal**: Set up a local MCP server and connect an agent client to it
**Time**: 30 minutes
**Steps**:
1. Create a simple MCP server with 2 tools using the MCP SDK
2. Create an MCP client that discovers tools
3. Send a query that requires tool use
4. Log the full MCP message exchange
**Expected Output**: Complete MCP message trace showing discovery, call, response
---


## ★ Recommended Resources

| Type       | Resource                                                       | Why                                                    |
| ---------- | -------------------------------------------------------------- | ------------------------------------------------------ |
| 🔧 Hands-on | [MCP Specification](https://modelcontextprotocol.io/)          | The standard protocol for agent-tool communication     |
| 🔧 Hands-on | [Google A2A Protocol](https://google.github.io/A2A/)           | Agent-to-agent communication protocol                  |
| 🔧 Hands-on | [Google ADK Documentation](https://google.github.io/adk-docs/) | Google's Agent Development Kit                         |
| 📘 Book     | "AI Engineering" by Chip Huyen (2025), Ch 7                    | Agent protocols and inter-agent communication patterns |

## ★ Sources

- MCP Specification — https://modelcontextprotocol.io
- A2A Protocol — https://a2aprotocol.org
- Google ADK — https://google.github.io/adk-docs/
- deeplearning.ai, "MCP: Build Rich-Context AI Apps with Anthropic" (2025)
- deeplearning.ai, "Build AI Apps with MCP Servers: Working with Box Files" (2025)
- deeplearning.ai, "Building Live Voice Agents with Google's ADK" (2025)
- Google Cloud NEXT 2025, ADK + A2A announcement
