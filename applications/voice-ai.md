---
title: "Voice AI & Speech"
tags: [voice-ai, tts, stt, text-to-speech, speech-to-text, realtime-api, whisper, genai]
type: concept
difficulty: intermediate
status: published
parent: "[[../genai]]"
related: ["[[../multimodal/multimodal-ai]]", "[[../techniques/ai-agents]]", "[[../techniques/agentic-protocols]]", "[[conversational-ai]]"]
source: "Multiple — see Sources"
created: 2026-03-22
updated: 2026-04-12
---

# Voice AI & Speech

> ✨ **Bit**: In 2024, talking to AI felt like talking to Siri — robotic and frustrating. By 2026, voice AI agents do customer support calls, conduct job interviews, and have natural conversations with sub-300ms latency. The interface is disappearing — you just talk.

---

## ★ TL;DR

- **What**: AI systems that understand speech (STT), generate speech (TTS), and enable real-time voice conversations
- **Why**: Voice is the most natural human interface. Voice AI agents are the fastest-growing GenAI application vertical. deeplearning.ai has a dedicated course on it.
- **Key point**: Modern voice AI isn't just STT→LLM→TTS glued together. End-to-end models process speech directly, achieving human-like latency and expressiveness.

---

## ★ Overview

### Definition

- **STT (Speech-to-Text)**: Converting spoken audio to text (also called ASR — Automatic Speech Recognition)
- **TTS (Text-to-Speech)**: Converting text to natural-sounding audio
- **Voice Agent**: An AI agent that converses in real-time via voice, handling turn-taking, interruptions, and context

### Scope

Covers the voice AI stack for GenAI applications. For the broader dialogue-systems view, see [Conversational AI & Dialogue Systems](./conversational-ai.md). For general multimodal AI (images, video), see [Multimodal Ai](../multimodal/multimodal-ai.md).

Last verified for provider and product examples in this note: 2026-04.

---

## ★ Deep Dive

### Voice AI Architecture

```
TRADITIONAL PIPELINE (cascaded):
  ┌────────┐    ┌─────────┐    ┌────────┐
  │  STT   │───▶│   LLM   │───▶│  TTS   │
  │(Whisper│    │(GPT-5.4)│    │(ElevenLabs)
  │ V4)   │    └─────────┘    └────────┘
  └────────┘    └─────────┘    └────────┘
  Audio → Text → Text → Audio

  Latency: STT(300ms) + LLM(500ms) + TTS(200ms) = ~1000ms
  ❌ Loses tone, emotion, context from audio
  ❌ Error compounds across stages

MODERN END-TO-END (speech-to-speech):
  ┌──────────────────────────────────┐
  │  MULTIMODAL MODEL                │
  │  (GPT-5.4, Gemini 3.1 Live)      │
  │                                  │
  │  Audio IN ──────▶ Audio OUT     │
  │  (understands tone, emotion,    │
  │   generates expressive speech)  │
  └──────────────────────────────────┘

  Latency: ~250-400ms (one model, no pipeline)
  ✅ Preserves audio context
  ✅ Natural turn-taking and interruptions
```

### STT (Speech-to-Text) Models

| Model               | By         | Languages | Key Feature                                          |
| ------------------- | ---------- | --------- | ---------------------------------------------------- |
| **Whisper** (V4)    | OpenAI     | 100+      | Open-source, diarization, real-time streaming        |
| **Deepgram Nova-3** | Deepgram   | 40+       | 5.26% WER, real-time, speaker diarization            |
| **Deepgram Flux**   | Deepgram   | Multi     | Conversational AI, turn detection, ultra-low latency |
| **Google Chirp 3**  | Google     | 100+      | Multilingual champion, diarization                   |
| **Azure Speech**    | Microsoft  | 100+      | Enterprise, custom models                            |
| **AssemblyAI**      | AssemblyAI | Multi     | Summarization built-in                               |

```
STT KEY CONCEPTS:
  WER (Word Error Rate) — lower is better, top models < 5%
  Diarization — who said what ("Speaker 1: ... Speaker 2: ...")
  VAD (Voice Activity Detection) — detect when someone is speaking
  Streaming vs Batch — real-time transcription vs file processing
  Code-switching — handling mid-sentence language switches
```

### TTS (Text-to-Speech) Models

| Model                | By          | Latency | Key Feature                            |
| -------------------- | ----------- | ------- | -------------------------------------- |
| **ElevenLabs**       | ElevenLabs  | ~100ms  | Best quality, voice cloning, emotional |
| **OpenAI TTS**       | OpenAI      | ~200ms  | Simple API, good quality               |
| **Google Cloud TTS** | Google      | ~150ms  | Neural2 voices, SSML                   |
| **Cartesia Sonic**   | Cartesia    | ~50ms   | Ultra-low latency                      |
| **Fish Speech**      | Open-source | Varies  | Open, voice cloning                    |
| **XTTS** (Coqui)     | Open-source | Varies  | Open, multilingual                     |

```
TTS KEY CONCEPTS:
  Voice cloning — reproduce a specific voice from seconds of audio
  Emotional tags — <happy>, <serious>, <whisper> control
  SSML — Speech Synthesis Markup Language (pauses, emphasis)
  Prosody — rhythm, stress, intonation patterns
  Streaming — start playing audio before the full response is ready
  Zero-shot — generate believable voice from minutes of sample
```

### Real-Time Voice APIs

```
OPENAI REALTIME API (GPT-5.4):
  - WebSocket-based, full-duplex
  - Speech-to-speech (no intermediate text needed)
  - Sub-300ms latency
  - Interruption handling (user can cut in)
  - Function calling during voice conversation
  - Tools: search, compute, external APIs

  Architecture:
    User speaks → WebSocket → GPT-5.4 processes audio →
    Generates audio response → Streams back → User hears

GOOGLE GEMINI 3.1 LIVE:
  - Multimodal real-time: voice + video + screen
  - ADK integration for building voice agents
  - 3-tier thinking for adaptive complexity

VOICE AGENT ARCHITECTURE:
  ┌───────────────────────────────────────────────┐
  │  VAD: Is there speech? Start listening.        │
  │       │                                       │
  │       ▼                                       │
  │  STT/End-to-end: Transcribe or process audio  │
  │       │                                       │
  │       ▼                                       │
  │  LLM: Understand intent, generate response    │
  │       │ ← Tools: calendar, CRM, database      │
  │       ▼                                       │
  │  TTS: Generate natural speech response         │
  │       │                                       │
  │       ▼                                       │
  │  Turn management: Handle interruptions,        │
  │  silence, back-channeling ("uh-huh")          │
  └───────────────────────────────────────────────┘
```

### Applications (2026)

| Application           | Example                            | Stack                       |
| --------------------- | ---------------------------------- | --------------------------- |
| **Customer support**  | AI handles tier-1 calls            | STT + LLM + TTS + CRM tools |
| **Voice assistants**  | Next-gen Siri/Alexa                | End-to-end multimodal       |
| **Interview bots**    | Screening candidates               | Voice agent + scoring       |
| **Healthcare**        | Patient intake, symptom checker    | Voice + medical knowledge   |
| **Language learning** | Conversational practice            | TTS + pronunciation scoring |
| **Accessibility**     | Screen readers, voice control      | STT + TTS                   |
| **Podcasting**        | AI-generated podcasts (NotebookLM) | TTS from text content       |

---

## ◆ Quick Reference

```
VOICE AI DECISION TREE:
  Need batch transcription?        → Whisper (free, open)
  Need real-time transcription?    → Deepgram Nova-3
  Need best voice quality?         → ElevenLabs
  Need lowest latency TTS?         → Cartesia Sonic
  Need full voice conversation?    → OpenAI Realtime API
  Need voice agent framework?      → ADK + Gemini Live
  Need open-source voice?          → Whisper + XTTS/Fish

KEY METRICS:
  STT WER:           < 5% is excellent
  TTS latency:       < 100ms for real-time feel
  End-to-end:        < 500ms for natural conversation
  Voice clone quality: MOS > 4.0 (out of 5.0)
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **Cascaded latency**: STT + LLM + TTS adds up. Use end-to-end models (Realtime API) for conversational applications.
- ⚠️ **Turn-taking is HARD**: Detecting when the user is done speaking vs pausing to think is a major UX challenge. VAD alone isn't enough.
- ⚠️ **Voice cloning ethics**: Cloning someone's voice without consent is illegal in many jurisdictions. Always get permission.
- ⚠️ **Accents and noise**: STT accuracy drops significantly with heavy accents, background noise, or domain jargon. Test with real users.
- ⚠️ **Cost**: Voice tokens are more expensive than text tokens. Budget carefully for voice applications.

---

## ○ Interview Angles

- **Q**: How would you build a real-time voice AI agent?
- **A**: Option 1 (simplest): OpenAI Realtime API — WebSocket-based, speech-to-speech, handles turn-taking and interruptions natively. Option 2 (customizable): Pipeline of Deepgram STT → LLM (with function calling for tools) → ElevenLabs TTS, with a VAD layer for turn management. Option 3 (Google ecosystem): ADK + Gemini Live for multi-agent voice systems. Key challenges: latency optimization, interruption handling, and graceful error recovery.

---

## ★ Connections

| Relationship | Topics                                                       |
| ------------ | ------------------------------------------------------------ |
| Builds on    | [Multimodal Ai](../multimodal/multimodal-ai.md), [Ai Agents](../techniques/ai-agents.md) |
| Leads to     | Conversational AI, Accessibility, IoT/Edge AI                |
| Compare with | Text-based chatbots, Screen-based UI                         |
| Cross-domain | Signal processing, Linguistics, UX design                    |

---

## ★ Sources

- OpenAI Realtime API — https://platform.openai.com/docs/guides/realtime
- Whisper — https://github.com/openai/whisper
- ElevenLabs — https://elevenlabs.io/docs
- Deepgram — https://deepgram.com/docs
- deeplearning.ai, "Building Live Voice Agents with Google's ADK" (2025)
