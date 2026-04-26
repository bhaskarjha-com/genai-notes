---
title: "Function Calling, Structured Output & Tool Use"
aliases: ["Function Calling", "Tool Use", "JSON Mode"]
tags: [function-calling, tool-use, structured-output, json-mode, mcp, grounding, genai]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../agents/ai-agents.md", "../llms/llms-overview.md", "rag.md", "prompt-engineering.md"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-04-11
---

# Function Calling, Structured Output & Tool Use

> ✨ **Bit**: An LLM that only generates text is like a brain with no hands. Function calling gives it hands — it can now search the web, query databases, send emails, and execute code. This is what makes LLMs actually useful in production.

---

## ★ TL;DR

- **What**: Mechanisms for LLMs to (1) call external functions/APIs and (2) return data in strict schemas (JSON, Pydantic)
- **Why**: Every production LLM application uses these. You can't build real apps with free-text responses alone.
- **Key point**: Function calling = LLM decides WHICH tool to use and WHAT arguments to pass. Structured output = LLM returns data in a guaranteed format. Together they make LLMs programmable.

---

## ★ Overview

### Definition

- **Function calling / Tool use**: The LLM analyzes a user request, determines that an external function should be called, and generates the function name + arguments as structured JSON. Your code then EXECUTES the function and feeds the result back.
- **Structured output**: Constraining the LLM to return responses in a specific schema (JSON, XML, Pydantic model) instead of free-form text.
- **Model Context Protocol (MCP)**: An emerging open standard for connecting LLMs to external tools and data sources.

### Scope

Covers the patterns, APIs, and protocols. For building full agents with planning loops, see [Ai Agents](../agents/ai-agents.md). For retrieval specifically, see [Rag](./rag.md).

### Significance

- Every ChatGPT plugin, every Copilot action, every enterprise AI app uses function calling
- Structured output eliminates parsing headaches and hallucinated fields
- MCP is becoming the USB of AI — one protocol for all tool connections
- This is what interviewers mean by "production LLM experience"

---

## ★ Deep Dive

### Function Calling Flow

```
┌─────────────────────────────────────────────────────────┐
│                  FUNCTION CALLING FLOW                    │
│                                                         │
│  1. User: "What's the weather in Tokyo?"                │
│                                                         │
│  2. Your Code → sends message + TOOL DEFINITIONS to LLM│
│     tools = [{                                          │
│       name: "get_weather",                              │
│       parameters: { location: string, unit: string }    │
│     }]                                                  │
│                                                         │
│  3. LLM → decides to call a tool (NOT execute it!)      │
│     Response: {                                         │
│       tool_call: "get_weather",                         │
│       arguments: { location: "Tokyo", unit: "celsius" } │
│     }                                                   │
│                                                         │
│  4. YOUR CODE executes the actual function               │
│     result = get_weather("Tokyo", "celsius")  → "22°C"  │
│                                                         │
│  5. Feed result back to LLM                             │
│     messages.append(tool_result: "22°C")                │
│                                                         │
│  6. LLM generates final answer                          │
│     "The weather in Tokyo is currently 22°C."           │
└─────────────────────────────────────────────────────────┘

KEY: The LLM NEVER executes code. It only decides what to call.
     YOUR code runs the function. Safety is YOUR responsibility.
```

## ★ Code & Implementation

### Function Calling API (OpenAI Pattern)

```python
# pip install openai>=1.60
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var
from openai import OpenAI
import json

client = OpenAI()

# 1. Define your tools
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "City name, e.g., 'Tokyo'"
                    },
                    "unit": {
                        "type": "string",
                        "enum": ["celsius", "fahrenheit"]
                    }
                },
                "required": ["location"]
            }
        }
    }
]

# 2. Send message with tools
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Weather in Tokyo?"}],
    tools=tools,
    tool_choice="auto"  # auto | none | required | specific function
)

# 3. Check if model wants to call a function
message = response.choices[0].message
if message.tool_calls:
    call = message.tool_calls[0]
    name = call.function.name           # "get_weather"
    args = json.loads(call.function.arguments)  # {"location": "Tokyo"}

    # 4. YOUR code executes the function
    result = get_weather(**args)  # You implement this

    # 5. Feed result back
    messages = [
        {"role": "user", "content": "Weather in Tokyo?"},
        message,  # assistant's tool call
        {"role": "tool", "tool_call_id": call.id, "content": str(result)}
    ]

    # 6. Get final response
    final = client.chat.completions.create(
        model="gpt-4o", messages=messages
    )
    print(final.choices[0].message.content)
    # → "The current weather in Tokyo is 22°C and partly cloudy."
```

### Structured Output

```python
# ⚠️ Last tested: 2026-04
# ═══ METHOD 1: JSON Mode (basic) ═══
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "List 3 planets"}],
    response_format={"type": "json_object"}
)
# Returns valid JSON, but schema is NOT enforced

# ═══ METHOD 2: Structured Output with Schema (strict) ═══
from pydantic import BaseModel

class Planet(BaseModel):
    name: str
    diameter_km: int
    has_rings: bool

class PlanetList(BaseModel):
    planets: list[Planet]

response = client.beta.chat.completions.parse(
    model="gpt-4o",
    messages=[{"role": "user", "content": "List 3 planets with details"}],
    response_format=PlanetList  # Schema is STRICTLY enforced
)

planets = response.choices[0].message.parsed  # → PlanetList object
for p in planets.planets:
    print(f"{p.name}: {p.diameter_km}km, rings={p.has_rings}")

# ═══ METHOD 3: Instructor library (popular in production) ═══
import instructor

client = instructor.from_openai(OpenAI())

planets = client.chat.completions.create(
    model="gpt-4o",
    response_model=PlanetList,
    messages=[{"role": "user", "content": "List 3 planets"}]
)
# Returns validated Pydantic object directly
```

### Model Context Protocol (MCP)

```
MCP = "The USB of AI" — a universal standard for connecting
      LLMs to tools, data sources, and services.

BEFORE MCP:
  Each tool needs custom integration code for each LLM
  OpenAI tools ≠ Claude tools ≠ Gemini tools
  N models × M tools = N×M integrations

WITH MCP:
  Tool implements MCP server → works with ANY MCP client
  N models + M tools = N + M integrations

  ┌────────────┐     MCP     ┌────────────────┐
  │ LLM Client │◄───────────►│ MCP Server     │
  │ (Claude,   │  Protocol   │ (Database,     │
  │  Cursor,   │             │  GitHub,       │
  │  custom)   │             │  Slack, etc.)  │
  └────────────┘             └────────────────┘

MCP CONCEPTS:
  Tools     = Functions the LLM can call
  Resources = Data the LLM can read (like files)
  Prompts   = Templated prompts for common tasks

STATUS (2026): Growing adoption. Claude Desktop, Cursor,
  and many IDE tools support MCP natively.
```

### Grounding Techniques

```
PROBLEM: LLMs hallucinate. They generate plausible but false info.
SOLUTION: Ground responses in external, trusted data.

GROUNDING METHODS (from simple to complex):

  1. SYSTEM PROMPT GROUNDING
     "Only answer based on the following context: ..."
     Simple but limited.

  2. RAG (Retrieval-Augmented Generation)
     Retrieve relevant documents → inject as context → generate
See [Retrieval-Augmented Generation (RAG)](./rag.md) for full details.

  3. FUNCTION CALLING + LIVE DATA
     LLM calls get_stock_price() → gets real-time data
     Most accurate for dynamic information.

  4. KNOWLEDGE GRAPHS
     Structured entity relationships (Company → CEO → Founded)
     Graph databases (Neo4j) + LLM reasoning.

  5. MULTI-SOURCE VERIFICATION
     Query multiple sources → cross-validate → generate
     Highest accuracy, highest latency.
```

---

## ◆ Comparison

| Feature                  | JSON Mode                  | Structured Output          | Function Calling        |
| ------------------------ | -------------------------- | -------------------------- | ----------------------- |
| **What**                 | Valid JSON output          | Schema-enforced output     | Call external functions |
| **Schema guaranteed?**   | ❌ (valid JSON, not schema) | ✅ (100% schema compliance) | ✅ (function signature)  |
| **Use case**             | Simple extraction          | Data pipelines, APIs       | Tool use, agents        |
| **Hallucinated fields?** | Possible                   | No                         | No (args validated)     |

---

## ◆ Quick Reference

```
WHEN TO USE WHAT:
  Need LLM to call APIs/tools    → Function calling
  Need structured data extraction → Structured output (Pydantic)
  Need basic JSON response        → JSON mode
  Need tool interop standard      → MCP
  Need factual grounding          → RAG + citations

TOOL CHOICE OPTIONS:
  "auto"      → LLM decides whether to call a tool
  "required"  → LLM MUST call at least one tool
  "none"      → LLM cannot call any tools
  {name: "x"} → LLM must call specific tool

LIBRARIES:
  instructor    → Structured output with retries
  marvin        → AI functions with type hints
  langchain     → Tool/agent framework
  pydantic      → Schema definition
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **LLM doesn't execute functions**: It only generates the call. YOUR code runs it. Never let the LLM run arbitrary code.
- ⚠️ **Tool descriptions matter enormously**: Vague descriptions → wrong tool selection. Be specific and include examples.
- ⚠️ **Parallel tool calls**: Models can request multiple tool calls at once. Handle them all before responding.
- ⚠️ **JSON mode ≠ Structured Output**: JSON mode guarantees valid JSON but NOT schema compliance. Use structured output for reliable schemas.
- ⚠️ **Cost of tool calling**: Each round-trip (user → tool call → result → final answer) doubles token usage.

---

## ○ Interview Angles

- **Q**: How does function calling work in LLMs?
- **A**: You define tools with names, descriptions, and parameter schemas. The LLM receives the user message + tool definitions, decides if a tool should be called, and generates a JSON object with the function name and arguments. YOUR code executes the function and feeds the result back to the LLM for final response generation. The LLM never actually runs the function.

- **Q**: What is MCP and why does it matter?
- **A**: Model Context Protocol is an open standard for connecting LLMs to external tools. Before MCP, every tool needed custom integration for each model. MCP provides a universal interface — any MCP-compatible tool works with any MCP-compatible client. It's becoming the "USB standard" for AI tool integration.

---

## ★ Connections

| Relationship | Topics                                                                                    |
| ------------ | ----------------------------------------------------------------------------------------- |
| Builds on    | [Llms Overview](../llms/llms-overview.md), [Prompt Engineering](./prompt-engineering.md)                                         |
| Leads to     | [Ai Agents](../agents/ai-agents.md) (agents = function calling + planning loops), [Rag](./rag.md) (retrieval as a tool) |
| Compare with | Direct prompting (text-only), Fine-tuning (embedding knowledge)                           |
| Cross-domain | API design, RPC protocols, Software architecture                                          |


---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Schema hallucination** | Model invents function names or parameters not in schema | Ambiguous intent, schema too complex | Constrained decoding, explicit examples in system prompt |
| **Argument type mismatch** | Function receives string instead of int, null for required field | LLM outputs approximate types | Pydantic validation layer, strict JSON schema with type coercion |
| **Infinite tool loops** | Agent calls the same tool repeatedly without progress | No exit condition, tool returns don't resolve query | Max iteration limit, loop detection, escalation to human |
| **Partial extraction** | Structured output missing fields or has empty values | Complex input requiring multi-step reasoning | Chain-of-thought before extraction, break into sub-extractions |
| **Format regression across models** | Code breaks when switching LLM providers | Different models interpret schemas differently | Provider abstraction layer, model-specific schema adapters |

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Structured Data Extractor

**Goal**: Extract structured data from unstructured text using function calling
**Time**: 30 minutes
**Steps**:
1. Define a Pydantic model for a job posting (title, company, salary_range, skills, location)
2. Use OpenAI function calling with
esponse_format
3. Test on 5 real job posting descriptions
4. Log extraction accuracy per field
**Expected Output**: JSON extractions with >90% field accuracy

### Exercise 2: Handle Tool Calling Edge Cases

**Goal**: Build robust error handling for function calling failures
**Time**: 30 minutes
**Steps**:
1. Create 3 tools (weather, calculator, search)
2. Send 10 queries including ambiguous ones
3. Add validation that catches schema violations
4. Add fallback when tool call fails
**Expected Output**: Error handling reduces failures from ~30% to <5%
---


## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [OpenAI Function Calling Guide](https://platform.openai.com/docs/guides/function-calling) | Best documentation for function calling implementation |
| 🔧 Hands-on | [Instructor Library](https://python.useinstructor.com/) | Production library for structured output extraction with Pydantic |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 6 (Agents) | Covers tool use and structured output in agent architectures |
| 🔧 Hands-on | [Anthropic Tool Use Guide](https://docs.anthropic.com/en/docs/build-with-claude/tool-use) | Claude's approach to function calling with examples |

## ★ Sources

- OpenAI Function Calling Guide — https://platform.openai.com/docs/guides/function-calling
- OpenAI Structured Outputs — https://platform.openai.com/docs/guides/structured-outputs
- Anthropic Tool Use — https://docs.anthropic.com/en/docs/build-with-claude/tool-use
- Model Context Protocol — https://modelcontextprotocol.io
- Instructor library — https://python.useinstructor.com
