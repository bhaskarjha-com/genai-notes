---
title: "Voice AI & Speech"
aliases: ["Voice AI", "Speech", "TTS", "STT", "Text-to-Speech"]
tags: [voice-ai, tts, stt, text-to-speech, speech-to-text, realtime-api, whisper, genai]
type: concept
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "../genai.md"
related: ["../multimodal/multimodal-ai.md", "../agents/ai-agents.md", "../agents/agentic-protocols.md", "conversational-ai.md"]
source: "Multiple â€” see Sources"
created: 2026-03-22
updated: 2026-04-12
---

# Voice AI & Speech

> âœ¨ **Bit**: In 2024, talking to AI felt like talking to Siri â€” robotic and frustrating. By 2026, voice AI agents do customer support calls, conduct job interviews, and have natural conversations with sub-300ms latency. The interface is disappearing â€” you just talk.

---

## â˜… TL;DR

- **What**: AI systems that understand speech (STT), generate speech (TTS), and enable real-time voice conversations
- **Why**: Voice is the most natural human interface. Voice AI agents are the fastest-growing GenAI application vertical. deeplearning.ai has a dedicated course on it.
- **Key point**: Modern voice AI isn't just STTâ†’LLMâ†’TTS glued together. End-to-end models process speech directly, achieving human-like latency and expressiveness.

---

## â˜… Overview

### Definition

- **STT (Speech-to-Text)**: Converting spoken audio to text (also called ASR â€” Automatic Speech Recognition)
- **TTS (Text-to-Speech)**: Converting text to natural-sounding audio
- **Voice Agent**: An AI agent that converses in real-time via voice, handling turn-taking, interruptions, and context

### Scope

Covers the voice AI stack for GenAI applications. For the broader dialogue-systems view, see [Conversational AI & Dialogue Systems](./conversational-ai.md). For general multimodal AI (images, video), see [Multimodal Ai](../multimodal/multimodal-ai.md).

Last verified for provider and product examples in this note: 2026-04.

---

## â˜… Deep Dive

### Voice AI Architecture

```
TRADITIONAL PIPELINE (cascaded):
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  STT   â”‚â”€â”€â”€â–¶â”‚   LLM   â”‚â”€â”€â”€â–¶â”‚  TTS   â”‚
  â”‚(Whisperâ”‚    â”‚(GPT-5.4)â”‚    â”‚(ElevenLabs)
  â”‚ V4)   â”‚    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”˜
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”˜
  Audio â†’ Text â†’ Text â†’ Audio

  Latency: STT(300ms) + LLM(500ms) + TTS(200ms) = ~1000ms
  âŒ Loses tone, emotion, context from audio
  âŒ Error compounds across stages

MODERN END-TO-END (speech-to-speech):
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  MULTIMODAL MODEL                â”‚
  â”‚  (GPT-5.4, Gemini 3.1 Live)      â”‚
  â”‚                                  â”‚
  â”‚  Audio IN â”€â”€â”€â”€â”€â”€â–¶ Audio OUT     â”‚
  â”‚  (understands tone, emotion,    â”‚
  â”‚   generates expressive speech)  â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

  Latency: ~250-400ms (one model, no pipeline)
  âœ… Preserves audio context
  âœ… Natural turn-taking and interruptions
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
  WER (Word Error Rate) â€” lower is better, top models < 5%
  Diarization â€” who said what ("Speaker 1: ... Speaker 2: ...")
  VAD (Voice Activity Detection) â€” detect when someone is speaking
  Streaming vs Batch â€” real-time transcription vs file processing
  Code-switching â€” handling mid-sentence language switches
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
  Voice cloning â€” reproduce a specific voice from seconds of audio
  Emotional tags â€” <happy>, <serious>, <whisper> control
  SSML â€” Speech Synthesis Markup Language (pauses, emphasis)
  Prosody â€” rhythm, stress, intonation patterns
  Streaming â€” start playing audio before the full response is ready
  Zero-shot â€” generate believable voice from minutes of sample
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
    User speaks â†’ WebSocket â†’ GPT-5.4 processes audio â†’
    Generates audio response â†’ Streams back â†’ User hears

GOOGLE GEMINI 3.1 LIVE:
  - Multimodal real-time: voice + video + screen
  - ADK integration for building voice agents
  - 3-tier thinking for adaptive complexity

VOICE AGENT ARCHITECTURE:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚  VAD: Is there speech? Start listening.        â”‚
  â”‚       â”‚                                       â”‚
  â”‚       â–¼                                       â”‚
  â”‚  STT/End-to-end: Transcribe or process audio  â”‚
  â”‚       â”‚                                       â”‚
  â”‚       â–¼                                       â”‚
  â”‚  LLM: Understand intent, generate response    â”‚
  â”‚       â”‚ â† Tools: calendar, CRM, database      â”‚
  â”‚       â–¼                                       â”‚
  â”‚  TTS: Generate natural speech response         â”‚
  â”‚       â”‚                                       â”‚
  â”‚       â–¼                                       â”‚
  â”‚  Turn management: Handle interruptions,        â”‚
  â”‚  silence, back-channeling ("uh-huh")          â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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

## â—† Quick Reference

```
VOICE AI DECISION TREE:
  Need batch transcription?        â†’ Whisper (free, open)
  Need real-time transcription?    â†’ Deepgram Nova-3
  Need best voice quality?         â†’ ElevenLabs
  Need lowest latency TTS?         â†’ Cartesia Sonic
  Need full voice conversation?    â†’ OpenAI Realtime API
  Need voice agent framework?      â†’ ADK + Gemini Live
  Need open-source voice?          â†’ Whisper + XTTS/Fish

KEY METRICS:
  STT WER:           < 5% is excellent
  TTS latency:       < 100ms for real-time feel
  End-to-end:        < 500ms for natural conversation
  Voice clone quality: MOS > 4.0 (out of 5.0)
```

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **Cascaded latency**: STT + LLM + TTS adds up. Use end-to-end models (Realtime API) for conversational applications.
- âš ï¸ **Turn-taking is HARD**: Detecting when the user is done speaking vs pausing to think is a major UX challenge. VAD alone isn't enough.
- âš ï¸ **Voice cloning ethics**: Cloning someone's voice without consent is illegal in many jurisdictions. Always get permission.
- âš ï¸ **Accents and noise**: STT accuracy drops significantly with heavy accents, background noise, or domain jargon. Test with real users.
- âš ï¸ **Cost**: Voice tokens are more expensive than text tokens. Budget carefully for voice applications.

---

## â—‹ Interview Angles

- **Q**: How would you build a real-time voice AI agent?
- **A**: Option 1 (simplest): OpenAI Realtime API â€” WebSocket-based, speech-to-speech, handles turn-taking and interruptions natively. Option 2 (customizable): Pipeline of Deepgram STT â†’ LLM (with function calling for tools) â†’ ElevenLabs TTS, with a VAD layer for turn management. Option 3 (Google ecosystem): ADK + Gemini Live for multi-agent voice systems. Key challenges: latency optimization, interruption handling, and graceful error recovery.

---

## â˜… Code & Implementation

### Speech-to-Text with Whisper + GPT Response

```python
# pip install openai>=1.60
# âš ï¸ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY, a .wav/.mp3 file
from openai import OpenAI
from pathlib import Path

client = OpenAI()

def voice_pipeline(audio_file: str, system_prompt: str = "You are a helpful voice assistant.") -> dict:
    """Full voice pipeline: STT â†’ LLM â†’ TTS."""
    # Step 1: Speech â†’ Text (Whisper)
    with open(audio_file, "rb") as f:
        transcript = client.audio.transcriptions.create(
            model="whisper-1",
            file=f,
            language="en",    # omit for auto-detect
        )
    user_text = transcript.text
    print(f"Transcribed: {user_text}")

    # Step 2: Text â†’ LLM Response
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user",   "content": user_text},
        ],
        max_tokens=200,
    )
    answer_text = response.choices[0].message.content
    print(f"LLM Answer: {answer_text}")

    # Step 3: Text â†’ Speech (TTS)
    speech = client.audio.speech.create(
        model="tts-1",          # tts-1-hd for higher quality
        voice="nova",           # alloy|echo|fable|onyx|nova|shimmer
        input=answer_text,
        response_format="mp3",
    )
    output_path = "response.mp3"
    speech.stream_to_file(output_path)
    return {"transcript": user_text, "answer": answer_text, "audio_file": output_path}

# Streaming TTS (lower latency for real-time)
def streaming_tts(text: str, output_path: str = "stream_output.mp3") -> None:
    """Stream TTS bytes as they arrive â€” good for low-latency voice assistants."""
    with client.audio.speech.with_streaming_response.create(
        model="tts-1", voice="nova", input=text
    ) as resp:
        resp.stream_to_file(output_path)
    print(f"Saved streaming TTS to {output_path}")
```

## â˜… Connections

| Relationship | Topics                                                                               |
| ------------ | ------------------------------------------------------------------------------------ |
| Builds on    | [Multimodal Ai](../multimodal/multimodal-ai.md), [Ai Agents](../agents/ai-agents.md) |
| Leads to     | Conversational AI, Accessibility, IoT/Edge AI                                        |
| Compare with | Text-based chatbots, Screen-based UI                                                 |
| Cross-domain | Signal processing, Linguistics, UX design                                            |


---

## â—† Production Failure Modes

| Failure                     | Symptoms                                                 | Root Cause                                      | Mitigation                                                 |
| --------------------------- | -------------------------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| **Latency kills UX**        | Users hang up or disengage during voice interaction      | STT + LLM + TTS pipeline too slow               | Streaming STT/TTS, edge processing, speculative responses  |
| **Accent/dialect failures** | System fails on non-standard English or regional accents | STT trained on limited accent diversity         | Accent-specific models, preprocessing, user adaptation     |
| **Turn-taking confusion**   | System talks over user or has awkward pauses             | No barge-in detection, fixed silence thresholds | Voice activity detection (VAD), adaptive silence detection |

---

## â—† Hands-On Exercises

### Exercise 1: Build a Voice-to-Voice Pipeline

**Goal**: Create an end-to-end voice conversation system
**Time**: 45 minutes
**Steps**:
1. Set up STT (Whisper or Deepgram)
2. Connect to an LLM for response generation
3. Add TTS (ElevenLabs or Coqui) for audio output
4. Measure end-to-end latency for 5 conversation turns
**Expected Output**: Working voice pipeline with latency measurements per stage
---


## â˜… Recommended Resources

| Type       | Resource                                                            | Why                                                   |
| ---------- | ------------------------------------------------------------------- | ----------------------------------------------------- |
| ðŸ”§ Hands-on | [OpenAI Audio API](https://platform.openai.com/docs/guides/audio)   | Production speech-to-text and text-to-speech          |
| ðŸ”§ Hands-on | [ElevenLabs Documentation](https://elevenlabs.io/docs)              | State-of-the-art voice synthesis                      |
| ðŸ“„ Paper    | [Radford et al. "Whisper" (2022)](https://arxiv.org/abs/2212.04356) | Robust speech recognition via large-scale supervision |

## â˜… Sources

- OpenAI Realtime API â€” https://platform.openai.com/docs/guides/realtime
- Whisper â€” https://github.com/openai/whisper
- ElevenLabs â€” https://elevenlabs.io/docs
- Deepgram â€” https://deepgram.com/docs
- deeplearning.ai, "Building Live Voice Agents with Google's ADK" (2025)
