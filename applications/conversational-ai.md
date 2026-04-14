---
title: "Conversational AI & Dialogue Systems"
tags: [conversational-ai, dialogue, chatbots, voice, state, agents]
type: procedure
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "voice-ai.md"
related: ["../agents/ai-agents.md", "../techniques/function-calling-and-structured-output.md", "../production/ai-system-design.md", "../evaluation/llm-evaluation-deep-dive.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# Conversational AI & Dialogue Systems

> ✨ **Bit**: A good chatbot answers questions. A great conversational system manages context, clarifies intent, recovers from confusion, escalates when needed, and knows when to shut up.

---

## ★ TL;DR

- **What**: The design of systems that maintain coherent, multi-turn interaction with users through text or voice
- **Why**: Conversation is not just generation — it is state management, turn-taking, recovery, and UX design. Getting this wrong means users abandon even if the model is brilliant.
- **Key point**: The hard part is almost never "make it answer" — it's "make it behave coherently over time" (memory, recovery, escalation, latency)

---

## ★ Overview

### Definition

**Conversational AI** systems support ongoing user interaction across turns, using memory, dialogue state, tools, and policy to produce useful, coherent responses. They range from simple FAQ bots to complex multi-modal voice agents.

### Scope

Covers: Dialogue state management, memory strategies, conversation design patterns, framework comparison, production implementation, voice-specific challenges, and evaluation. For speech-specific infrastructure (ASR/TTS/VAD), see [Voice AI & Speech](./voice-ai.md). For the underlying agent patterns, see [AI Agents](../agents/ai-agents.md).

### Significance

- **Largest GenAI deployment surface**: Customer support, internal copilots, scheduling assistants, and healthcare triage all use conversational AI
- **Product-critical**: Conversation quality depends as much on orchestration and UX rules as on model quality. A brilliantly smart model in a poorly designed conversation system feels broken.
- **Interview staple**: System design interviews for AI roles frequently ask "design a customer support chatbot" or "design a conversational assistant"

### Prerequisites

- [AI Agents](../agents/ai-agents.md) — agent loop, tool use, memory
- [Function Calling and Structured Output](../techniques/function-calling-and-structured-output.md) — how LLMs call tools
- [Voice AI & Speech](./voice-ai.md) — for voice conversation patterns
- [Prompt Engineering](../techniques/prompt-engineering.md) — system prompts and persona design

---

## ★ Deep Dive

### What Makes Conversation Hard

Unlike one-shot generation, dialogue systems must manage:

```
┌──────────────────────────────────────────────────────────────────┐
│                  WHY CONVERSATION IS HARD                        │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. INTENT TRACKING     "I want to reschedule" → which meeting? │
│     across turns         with whom? what constraints?            │
│                                                                  │
│  2. AMBIGUITY           "Can you make it earlier?"               │
│     resolution           Earlier today? Earlier in the week?     │
│                                                                  │
│  3. CONTEXT WINDOW      Turn 1: user name, role, problem        │
│     management           Turn 15: should we still remember T1?   │
│                                                                  │
│  4. INTERRUPTION        User changes topic mid-flow              │
│     & correction         "Actually, forget that — let's..."      │
│                                                                  │
│  5. RECOVERY            ASR error, misunderstood intent          │
│     & repair             "No, I said NEW YORK, not Newark"       │
│                                                                  │
│  6. ESCALATION          When to hand off to human                │
│     decisions            When to refuse, when to retry            │
│                                                                  │
│  7. LATENCY             Voice: 200ms VAD → 500ms total response │
│     constraints          Text: TTFT < 500ms or users click away  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Conversation Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONVERSATIONAL AI SYSTEM                      │
│                                                                  │
│  User Input ──► [ASR/Text] ──► [Turn Manager] ──► [Response]    │
│                                     │                            │
│                    ┌────────────────┼────────────────┐           │
│                    │                │                │           │
│                    ▼                ▼                ▼           │
│              ┌──────────┐    ┌──────────┐    ┌──────────┐       │
│              │ DIALOGUE │    │  MEMORY  │    │  TOOLS   │       │
│              │  STATE   │    │  POLICY  │    │  LAYER   │       │
│              │          │    │          │    │          │       │
│              │ - Intent │    │ - Short  │    │ - Search │       │
│              │ - Slots  │    │   term   │    │ - CRM    │       │
│              │ - Phase  │    │ - Long   │    │ - Calendar│      │
│              │ - History│    │   term   │    │ - APIs   │       │
│              └──────────┘    │ - Summary│    └──────────┘       │
│                              └──────────┘                        │
│                                     │                            │
│                              ┌──────────┐                        │
│                              │  SAFETY  │                        │
│                              │  POLICY  │                        │
│                              │          │                        │
│                              │ - Refusal│                        │
│                              │ - Escal. │                        │
│                              │ - PII    │                        │
│                              └──────────┘                        │
└─────────────────────────────────────────────────────────────────┘
```

### Core Dialogue Components

| Component | What It Does | Implementation |
|-----------|-------------|----------------|
| **Turn Manager** | Decides how the system responds each turn — clarify, answer, use tool, or escalate | LLM with structured output or state machine |
| **Dialogue State** | Tracks what matters from the conversation (intent, slots, phase) | Pydantic model or typed dict |
| **Memory Policy** | Decides what to keep, summarize, or discard | Sliding window + periodic summary |
| **Tool Layer** | Connects to search, CRM, scheduling, or business systems | Function calling / MCP |
| **Safety Policy** | Handles refusals, escalation, PII scrubbing, and risky actions | Guardrails layer (pre/post) |
| **Persona** | Defines tone, vocabulary, behavior rules | System prompt + few-shot examples |

### Conversation Design Patterns

| Pattern | Architecture | Best For | Limitation |
|---------|-------------|----------|------------|
| **Stateless RAG chat** | Query → retrieve → generate. No turn memory. | FAQ, documentation search | No continuity across turns |
| **Context-window memory** | Append all messages to context | Short interactions (< 10 turns) | Expensive, fills context window |
| **Summarized memory** | Periodically summarize old turns, keep recent ones | Longer sessions (10-50 turns) | Summary drift, information loss |
| **State-machine + LLM** | Hard-coded flow graph with LLM for NLU/NLG in each node | Structured workflows (booking, support tickets) | Less flexible, brittle edges |
| **Agentic dialogue** | LLM decides when to use tools, clarify, or answer | Task completion with external systems | Harder to evaluate, more expensive |
| **Hybrid (graph + agent)** | LangGraph: structured flow with LLM decision nodes | Production systems needing both structure and flexibility | More complex to build/test |

### Dialogue State Management

```json
{
  "session_id": "abc-123",
  "user_goal": "reschedule my interview",
  "conversation_phase": "slot_filling",
  "known_slots": {
    "date": "next Tuesday",
    "role": "backend engineer",
    "company": null,
    "time_preference": null
  },
  "pending_question": "What time works best for you?",
  "last_action": "calendar_lookup",
  "turn_count": 4,
  "escalation_trigger": false,
  "confidence": 0.85
}
```

**Key principle**: State should capture the minimum information needed to continue the conversation if the context window were cleared. It's a product decision, not a dump of everything.

### Memory Strategies

| Strategy | How It Works | When to Use | Risk |
|----------|-------------|-------------|------|
| **Full history** | Keep all messages in context | < 10 turns, non-sensitive | Context overflow, cost explosion |
| **Sliding window** | Keep last N turns, drop older ones | Medium conversations | Loses early context |
| **Summary + recent** | Summarize turns 1-N, keep N+1 to now verbatim | Long conversations | Summary drift, hallucinated "memories" |
| **Entity extraction** | Extract key facts into structured state | Customer support, booking | Extraction errors compound |
| **Hybrid** | Structured state + summary + last 3 turns | Production systems | Most complex to implement |

### Voice vs Text Conversations

| Dimension | Text | Voice |
|-----------|------|-------|
| **Latency tolerance** | 2-3 seconds acceptable | > 500ms feels laggy, > 1s is broken |
| **Input errors** | Typos (minor) | ASR errors ("New York" → "Newark") — critical |
| **Turn-taking** | Explicit (user hits send) | Implicit (VAD detects end-of-speech) |
| **Interruption** | User can edit before sending | User talks over the bot — must handle |
| **Repair** | User re-types | "No, I said..." — bot must recover gracefully |
| **Output length** | Long responses OK | Keep responses < 30 seconds of speech |
| **Emotional cues** | Limited to text tone | Tone, pace, volume detectable |

**Critical voice latency thresholds** (as of 2026):
- **VAD detection**: < 200ms (when user stops speaking)
- **Total response time**: < 500ms (VAD → first audio output)
- **Human-like pause**: 300-500ms delay feels natural; < 200ms feels robotic

### Framework Comparison (April 2026)

| Framework | Type | Multi-turn | Tool Use | Best For |
|-----------|------|:----------:|:--------:|----------|
| **LangGraph** | Graph-based agent | ✅ State persistence | ✅ Function calling | Custom conversation flows with complex state |
| **Rasa** | Open-source NLU + dialogue | ✅ Tracker store | ✅ Custom actions | Enterprise on-prem, privacy-sensitive |
| **Voiceflow** | No-code conversation design | ✅ Visual builder | ✅ API integrations | Rapid prototyping, non-technical teams |
| **Dialogflow CX** | Google Cloud managed | ✅ Session state | ✅ Webhooks/fulfillment | Google ecosystem, voice + text |
| **Amazon Lex** | AWS managed | ✅ Session attributes | ✅ Lambda fulfillment | AWS ecosystem, Alexa integration |
| **Chainlit/Streamlit** | Python UI frameworks | ⚠️ Basic | ✅ Via LangChain | Demos, internal tools, prototyping |

---

## ★ Code & Implementation

### Multi-Turn Conversation with LangGraph

```python
# pip install langgraph>=0.2 langchain-openai>=0.2 langchain-core>=0.3
# ⚠️ Last tested: 2026-04 | Requires: langgraph>=0.2

from typing import TypedDict, Annotated, Literal
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage

# 1. Define conversation state
class ConversationState(TypedDict):
    messages: Annotated[list, add_messages]
    intent: str
    slots: dict
    turn_count: int

# 2. Define the conversation system prompt
SYSTEM_PROMPT = """You are a helpful scheduling assistant. Your job is to:
1. Understand what the user wants to schedule/reschedule
2. Collect required information: date, time, participants
3. Confirm details before taking action
4. Use tools when you have enough information

Always be concise. Ask ONE clarifying question at a time.
If you don't understand, say so and ask the user to rephrase."""

# 3. Create the conversation node
llm = ChatOpenAI(model="gpt-4o", temperature=0.3)

def conversation_node(state: ConversationState) -> dict:
    """Main conversation turn — LLM processes input and responds."""
    messages = [SystemMessage(content=SYSTEM_PROMPT)] + state["messages"]
    response = llm.invoke(messages)
    return {
        "messages": [response],
        "turn_count": state.get("turn_count", 0) + 1,
    }

def should_continue(state: ConversationState) -> Literal["continue", "end"]:
    """Check if conversation should continue or end."""
    if state.get("turn_count", 0) >= 20:  # Safety limit
        return "end"
    return "continue"

# 4. Build the conversation graph
graph = StateGraph(ConversationState)
graph.add_node("chat", conversation_node)
graph.add_edge(START, "chat")
graph.add_conditional_edges("chat", should_continue, {
    "continue": END,  # Returns to user for next input
    "end": END,
})

app = graph.compile()

# 5. Run a multi-turn conversation
state = {"messages": [], "intent": "", "slots": {}, "turn_count": 0}

# Turn 1
state = app.invoke({
    **state,
    "messages": [HumanMessage(content="I need to reschedule my interview")]
})
print(f"Bot: {state['messages'][-1].content}")

# Turn 2
state = app.invoke({
    **state,
    "messages": [HumanMessage(content="Next Tuesday afternoon, anytime after 2pm")]
})
print(f"Bot: {state['messages'][-1].content}")

# Expected output:
# Bot: I'd be happy to help you reschedule your interview. Could you tell me:
#      - Which interview is this for (role/company)?
# Bot: Got it — next Tuesday after 2pm. Let me check available slots.
#      Would 2:30 PM or 3:00 PM work better for you?
```

### Conversation Memory with Summarization

```python
# pip install langchain-openai>=0.2 langchain-core>=0.3
# ⚠️ Last tested: 2026-04 | Requires: langchain-openai>=0.2

from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage, HumanMessage, AIMessage

class ConversationMemory:
    """Hybrid memory: summary of old turns + recent turns verbatim."""
    
    def __init__(self, max_recent_turns: int = 6, summarize_every: int = 10):
        self.messages: list = []
        self.summary: str = ""
        self.max_recent = max_recent_turns
        self.summarize_every = summarize_every
        self.llm = ChatOpenAI(model="gpt-4o-mini", temperature=0)
    
    def add_turn(self, user_msg: str, ai_msg: str):
        self.messages.append(HumanMessage(content=user_msg))
        self.messages.append(AIMessage(content=ai_msg))
        
        # Summarize when history gets long
        if len(self.messages) > self.summarize_every * 2:
            self._summarize_old_turns()
    
    def _summarize_old_turns(self):
        """Compress old turns into a summary, keep recent ones verbatim."""
        old = self.messages[:-self.max_recent * 2]
        recent = self.messages[-self.max_recent * 2:]
        
        summary_prompt = f"""Summarize this conversation history into key facts and decisions.
Previous summary: {self.summary}
New messages to summarize:
{chr(10).join(f'{m.type}: {m.content}' for m in old)}

Output a concise summary of all important facts, user preferences, and decisions made."""
        
        result = self.llm.invoke([HumanMessage(content=summary_prompt)])
        self.summary = result.content
        self.messages = recent  # Keep only recent turns
    
    def get_context(self) -> list:
        """Return the full context for the next LLM call."""
        context = []
        if self.summary:
            context.append(SystemMessage(
                content=f"Summary of earlier conversation:\n{self.summary}"
            ))
        context.extend(self.messages)
        return context

# Usage
memory = ConversationMemory(max_recent_turns=4, summarize_every=8)
memory.add_turn("I need to book a flight to NYC", "Sure! When do you want to fly?")
memory.add_turn("Next Friday", "One-way or round trip?")
memory.add_turn("Round trip, back on Sunday", "How many passengers?")
memory.add_turn("Just me", "Let me search for flights...")

context = memory.get_context()
print(f"Context messages: {len(context)}")
# Expected output: Context messages: 8 (4 turns × 2 messages each)
# After 8+ turns, old ones get summarized automatically
```

---

## ◆ Comparison

| Aspect | Stateless RAG Chat | LangGraph Conversation | Rasa | Voiceflow |
|--------|-------------------|----------------------|------|-----------|
| **Multi-turn state** | ❌ None | ✅ Full graph state | ✅ Tracker store | ✅ Visual state |
| **Learning curve** | Low | Medium-High | High | Low |
| **Customization** | High | Very High | High | Medium |
| **Voice support** | ❌ | Via integration | ❌ (text-only) | ✅ Native |
| **Production ready** | ⚠️ | ✅ | ✅ | ✅ |
| **Cost** | Per-API-call | OSS + LLM costs | OSS | SaaS pricing |
| **Best for** | FAQ, search | Custom agents | Enterprise NLU | Rapid prototyping |

---

## ◆ Quick Reference

```
CONVERSATION DESIGN CHECKLIST:
  □ Define clear conversation boundaries (what it does / doesn't do)
  □ Design clarification flows for ambiguous inputs
  □ Implement repair strategies for misunderstandings
  □ Set up human escalation path for edge cases
  □ Separate persona from policy in system prompt
  □ Add PII scrubbing for sensitive conversations
  □ Set max turn limits to prevent infinite loops
  □ Test with adversarial inputs (off-topic, abusive, injection)

LATENCY TARGETS:
  Text chatbot:  TTFT < 500ms, total < 3s
  Voice agent:   VAD < 200ms, total response < 500ms
  Streaming:     First chunk < 200ms

MEMORY RULES OF THUMB:
  < 10 turns:   Full history in context window
  10-50 turns:  Summary + last 6 turns
  50+ turns:    Entity extraction + summary + last 4 turns
  Across sessions: Long-term memory (vector DB / key-value store)
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Context overflow** | Bot "forgets" early turns, gives contradictory answers | Conversation exceeds context window, old turns silently dropped | Implement summarization memory, set explicit context budget |
| **Slot confusion** | Bot mixes up entities ("Your flight to LA" when user said NYC) | Poor entity extraction, ambiguous references not resolved | Use structured state with explicit slot tracking, confirm before acting |
| **Repair deadlock** | Bot and user stuck in clarification loop ("I don't understand" × 5) | No escalation path, overly strict intent matching | Max clarification attempts (3), then offer human handoff or menu |
| **Summary drift** | Bot confidently states things that were never said | Summarization hallucinated facts from old turns | Validate summaries against source messages, use extractive summaries |
| **Persona bleed** | Bot breaks character, reveals system prompt content | Adversarial prompting, context pollution | Separate persona/policy prompts, use guardrails for prompt injection |
| **Voice interruption failure** | Bot keeps talking after user interrupts, or cuts off prematurely | Bad VAD tuning, no barge-in support | Tune VAD sensitivity, implement barge-in (stop TTS on new speech) |

---

## ○ Gotchas & Common Mistakes

- ⚠️ **More memory ≠ better conversations**: Keeping everything amplifies confusion. Curate what to remember.
- ⚠️ **Conversational polish can hide weak task completion**: A friendly bot that never books the meeting is still a failure.
- ⚠️ **Persona and policy should not be mixed**: "Be casual and fun!" in the same prompt as "Never discuss competitor pricing" creates conflicts. Separate them.
- ⚠️ **Teams under-design repair flows**: The happy path gets all the attention. Misunderstandings, corrections, and "actually I meant..." are where users really judge quality.
- ⚠️ **Testing with your own team ≠ testing with users**: Your team knows how the bot works. Real users will ask things you never imagined.

---

## ○ Interview Angles

- **Q**: How is conversational AI different from a basic chatbot?
- **A**: A basic chatbot generates locally plausible replies — it answers the current message without tracking state. A conversational AI system manages dialogue state across turns (tracking intent, confirmed slots, pending questions), handles ambiguity through clarification, recovers from misunderstandings, uses tools to take real actions, and knows when to escalate to a human. The key difference is that a conversational system has explicit state management (what has been said, what's confirmed, what's pending) rather than relying purely on the LLM's context window to "remember" everything.

- **Q**: Design a customer support chatbot for an e-commerce company.
- **A**: I'd start by defining the scope: order status, returns/refunds, product questions, and escalation to human agents. The architecture would be a LangGraph-based conversation flow with: (1) an intent classifier node that routes to specialized sub-flows, (2) structured state tracking order IDs, customer info, and issue type, (3) tool integrations for order lookup, return initiation, and ticket creation, (4) a summarization memory layer for conversations > 10 turns, (5) guardrails for PII handling and policy compliance. For latency, I'd target TTFT < 500ms with streaming. For evaluation, I'd track task completion rate, turns-to-resolution, escalation rate, and CSAT scores. The critical design decision is the escalation policy — I'd implement confidence-based routing where the bot hands off proactively when confidence drops below 0.7, rather than waiting for the user to ask for a human.

- **Q**: What should a conversational system remember and forget?
- **A**: This is a product decision, not a technical one. Remember: user's stated goal, confirmed facts (slots), tool results, and explicit preferences. Forget: rejected alternatives, small talk, verbose explanations, and intermediate reasoning steps. The implementation I'd use is a hybrid: structured state for confirmed facts (a Pydantic model with intent, slots, phase), periodic summarization for conversation flow, and the last 4-6 turns verbatim for immediate context. Critical rule: never "remember" something that was said in a summary that wasn't in the original messages — that's how summary drift causes hallucinated memories.

---

## ◆ Hands-On Exercises

### Exercise 1: Build a Multi-Turn Booking Assistant

**Goal**: Build a conversation that collects booking information across multiple turns
**Time**: 60 minutes
**Steps**:
1. Define a `BookingState` with slots: date, time, participants, room_type
2. Implement a LangGraph conversation that asks clarifying questions until all slots are filled
3. Add a confirmation step before "booking"
4. Test with 3 scenarios: cooperative user, ambiguous user, user who changes mind
**Expected Output**: Working multi-turn bot that correctly fills all slots across 3-7 turns

### Exercise 2: Add Summarization Memory

**Goal**: Implement conversation memory that handles 20+ turn conversations
**Time**: 45 minutes
**Steps**:
1. Start with the ConversationMemory class from the Code section
2. Run a 25-turn simulated conversation about travel planning
3. Verify that the summary correctly preserves key facts from early turns
4. Test edge case: user corrects a fact from turn 2 in turn 20 — does the system handle it?
**Expected Output**: Memory system that maintains coherence over 25+ turns with < 4 messages in context

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [AI Agents](../agents/ai-agents.md), [Voice AI & Speech](./voice-ai.md), [Function Calling](../techniques/function-calling-and-structured-output.md) |
| Leads to | Customer support systems, [AI System Design](../production/ai-system-design.md), Voice agents |
| Compare with | One-shot RAG chat, Search interfaces, Static FAQ bots |
| Cross-domain | UX writing, Conversation design (Google, Voiceflow), Contact-center operations |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 7 (Agents) | Practical treatment of conversation state management and memory patterns |
| 🎓 Course | [deeplearning.ai — "Building Agentic RAG with LlamaIndex"](https://www.deeplearning.ai/) | Hands-on implementation of conversational retrieval with state |
| 🔧 Hands-on | [LangGraph Tutorials — Customer Support Bot](https://langchain-ai.github.io/langgraph/tutorials/) | Step-by-step guide to building a production conversation system |
| 🎥 Video | [Google — Conversation Design Best Practices](https://designguidelines.withgoogle.com/conversation/) | The definitive guide to conversation UX — persona, repair, turn-taking |
| 📄 Paper | [Roller et al. "Recipes for Building an Open-Domain Chatbot" (2021)](https://arxiv.org/abs/2004.13637) | Facebook's analysis of what makes conversations work — blending, empathy, knowledge |
| 🔧 Hands-on | [Rasa Open Source Documentation](https://rasa.com/docs/) | Most mature open-source dialogue framework — excellent for learning NLU + dialogue management concepts |
| 📘 Book | "Designing Voice User Interfaces" by Cathy Pearl | Gold standard for voice conversation design — turn-taking, repair, persona |

---

## ★ Sources

- Google Conversation Design Guidelines — https://designguidelines.withgoogle.com/conversation/
- Microsoft Bot Framework Design Guidance — https://docs.microsoft.com/en-us/azure/bot-service/bot-service-design-principles
- LangGraph Documentation — https://langchain-ai.github.io/langgraph/
- Rasa Documentation — https://rasa.com/docs/
- Roller et al. "Recipes for Building an Open-Domain Chatbot" (2021)
- [Voice AI & Speech](./voice-ai.md)
- [AI Agents](../agents/ai-agents.md)
