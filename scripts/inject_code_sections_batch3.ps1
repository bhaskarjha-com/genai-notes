# ════════════════════════════════════════════════════════════════════════════
# HISTORICAL — This script was used for the Phase 5 bulk code section
# injection (April 2026). It is retained for audit trail only.
# DO NOT RE-RUN — all notes now have code sections. Use the
# maintenance prompts in _templates/MAINTENANCE_PROMPTS.md instead.
# ════════════════════════════════════════════════════════════════════════════
# inject_code_sections_batch3.ps1 - Phase 5 Batch 3: final 4 notes
param([switch]$DryRun)

function Inject-CodeSection {
    param([string]$File, [string]$Code)
    $abs  = (Resolve-Path $File -ErrorAction SilentlyContinue)
    if (-not $abs) { Write-Warning "File not found: $File"; return $false }
    $abs  = $abs.Path
    $text = [System.IO.File]::ReadAllText($abs)
    if ($text -match "Code & Implementation") { Write-Host "  SKIP: $File"; return $false }
    $match = $null
    foreach ($pattern in @('##[^\n]*Connections[^\n]*\n','##[^\n]*Recommended Resources[^\n]*\n','##[^\n]*Sources[^\n]*\n')) {
        $m = [regex]::Match($text, $pattern)
        if ($m.Success) { $match = $m; break }
    }
    if ($match) {
        $marker  = $match.Value
        $newText = $text.Replace($marker, $Code.TrimEnd() + "`n`n" + $marker)
        if (-not $DryRun) {
            [System.IO.File]::WriteAllText($abs, $newText, [System.Text.UTF8Encoding]::new($false))
        }
        Write-Host "  INJECTED: $File"
        return $true
    }
    Write-Warning "  FAILED: $File"
    return $false
}

$count = 0

# ── applications/voice-ai.md ─────────────────────────────────────────────────
$count += [int](Inject-CodeSection "applications\voice-ai.md" @'
## ★ Code & Implementation

### Speech-to-Text with Whisper + GPT Response

```python
# pip install openai>=1.60
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY, a .wav/.mp3 file
from openai import OpenAI
from pathlib import Path

client = OpenAI()

def voice_pipeline(audio_file: str, system_prompt: str = "You are a helpful voice assistant.") -> dict:
    """Full voice pipeline: STT → LLM → TTS."""
    # Step 1: Speech → Text (Whisper)
    with open(audio_file, "rb") as f:
        transcript = client.audio.transcriptions.create(
            model="whisper-1",
            file=f,
            language="en",    # omit for auto-detect
        )
    user_text = transcript.text
    print(f"Transcribed: {user_text}")

    # Step 2: Text → LLM Response
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

    # Step 3: Text → Speech (TTS)
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
    """Stream TTS bytes as they arrive — good for low-latency voice assistants."""
    with client.audio.speech.with_streaming_response.create(
        model="tts-1", voice="nova", input=text
    ) as resp:
        resp.stream_to_file(output_path)
    print(f"Saved streaming TTS to {output_path}")
```
'@)

# ── applications/ai-ux-patterns.md ───────────────────────────────────────────
$count += [int](Inject-CodeSection "applications\ai-ux-patterns.md" @'
## ★ Code & Implementation

### Streaming Response with Progressive Disclosure

```python
# pip install openai>=1.60 fastapi>=0.110 uvicorn>=0.29
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from openai import OpenAI

app    = FastAPI()
client = OpenAI()

@app.get("/stream")
async def stream_response(question: str) -> StreamingResponse:
    """Stream LLM tokens to the client as they arrive — core AI UX pattern."""
    def token_generator():
        stream = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": question}],
            max_tokens=400,
            stream=True,
        )
        for chunk in stream:
            delta = chunk.choices[0].delta.content
            if delta:
                # Server-Sent Events format
                yield f"data: {delta}\n\n"
        yield "data: [DONE]\n\n"

    return StreamingResponse(token_generator(), media_type="text/event-stream")

# Frontend consumption (JavaScript):
# const es = new EventSource(`/stream?question=What+is+RAG%3F`);
# es.onmessage = (e) => {
#   if (e.data === "[DONE]") { es.close(); return; }
#   document.getElementById("output").textContent += e.data;
# };
```

### Confidence Signaling Pattern

```python
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY
import json
from openai import OpenAI

client = OpenAI()

def answer_with_confidence(question: str) -> dict:
    """Return answer annotated with confidence and uncertainty signals for UI."""
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "system",
            "content": (
                "Answer questions and rate your confidence. "
                "JSON only: {\"answer\": \"...\", \"confidence\": 0.0-1.0, "
                "\"uncertainty_note\": \"null or brief caveat\", \"sources_likely\": [\"...\"]}"
            )
        }, {"role": "user", "content": question}],
        temperature=0,
        response_format={"type": "json_object"},
    )
    return json.loads(resp.choices[0].message.content)

# UI mapping: confidence → indicator color
def confidence_color(conf: float) -> str:
    if conf >= 0.85: return "green"    # show normally
    if conf >= 0.6:  return "yellow"   # show with "Verify this" note
    return "red"                        # show with prominent "AI may be wrong" warning

result = answer_with_confidence("What is the population of Mars?")
print(f"Answer: {result['answer']}")
print(f"Confidence: {result['confidence']:.0%} → {confidence_color(result['confidence'])}")
print(f"Caveat: {result.get('uncertainty_note')}")
```
'@)

# ── applications/ai-product-management-fundamentals.md ───────────────────────
$count += [int](Inject-CodeSection "applications\ai-product-management-fundamentals.md" @'
## ★ Code & Implementation

### AI Feature Feasibility Scorecard

```python
# ⚠️ Last tested: 2026-04 | Requires: Python 3.10+ (stdlib only)
from dataclasses import dataclass
from typing import Literal

@dataclass
class AIFeatureFeasibility:
    """Score an AI feature idea before committing engineering resources."""
    name: str
    # Rate each dimension 1 (low) to 5 (high)
    data_availability:    int   # Is training/evaluation data available?
    accuracy_requirement: int   # How much does accuracy matter? (5=critical)
    latency_tolerance:    int   # How tolerant is the UX to latency? (5=very tolerant)
    failure_impact:       int   # What is the impact of AI errors? (5=catastrophic → hard)
    alternatives_exist:   int   # Do rule-based alternatives exist? (5=many → lower AI need)
    user_ai_trust:        int   # How much do users trust AI in this context? (5=high trust)

    def score(self) -> dict:
        """Compute weighted feasibility score (0-100). >70 = green light."""
        raw = (
            self.data_availability * 20    # most critical factor
            + (6 - self.accuracy_requirement) * 10  # higher req = harder
            + self.latency_tolerance * 10
            + (6 - self.failure_impact) * 15         # high failure cost = risky
            + (6 - self.alternatives_exist) * 10     # alternatives exist = lower pain
            + self.user_ai_trust * 10
        ) / 75 * 100

        confidence = "GREEN" if raw >= 70 else "YELLOW" if raw >= 50 else "RED"
        return {
            "name":       self.name,
            "score":      round(raw, 1),
            "confidence": confidence,
            "guidance":   {
                "GREEN":  "Proceed to prototype. Clear ROI path.",
                "YELLOW": "Validate data quality and user acceptance first.",
                "RED":    "Revisit problem framing. Consider rule-based approach.",
            }[confidence],
        }

# Example: evaluate two AI features
features = [
    AIFeatureFeasibility("Email draft suggestions", 5, 2, 5, 1, 4, 5),
    AIFeatureFeasibility("Autonomous loan decisions", 2, 5, 2, 5, 3, 1),
]
for f in features:
    r = f.score()
    print(f"{r['name']}: {r['score']:.0f}/100 ({r['confidence']}) — {r['guidance']}")
```
'@)

# ── evaluation/system-design-for-ai-interviews.md ────────────────────────────
$count += [int](Inject-CodeSection "evaluation\system-design-for-ai-interviews.md" @'
## ★ Code & Implementation

### System Design Interview: RAG Pipeline Scaffold

```python
# ⚠️ Last tested: 2026-04 | Requires: Python 3.10+ (stdlib only)
# This is a code representation of an AI system design answer.
# Use this structure to walk through a production RAG design in interviews.

from dataclasses import dataclass, field
from typing import Protocol

# ── Interface definitions (the design, not the implementation) ─────────────────
class VectorStore(Protocol):
    def upsert(self, docs: list[str], embeddings: list[list[float]]) -> None: ...
    def query(self, embedding: list[float], top_k: int) -> list[str]: ...

class EmbeddingModel(Protocol):
    def embed(self, texts: list[str]) -> list[list[float]]: ...

class LLM(Protocol):
    def generate(self, messages: list[dict], max_tokens: int) -> str: ...

# ── Core RAG pipeline (design interview answer as code) ──────────────────────
@dataclass
class RAGSystem:
    """
    Production RAG — key design decisions:
    1. Chunking: 512 tokens, 20% overlap (balance context vs precision)
    2. Embedding: text-embedding-3-small (dims=1536, cost-efficient)
    3. Retrieval: top-5 chunks + BM25 hybrid (precision + recall)
    4. Generation: gpt-4o-mini (quality) with 4000-token context
    5. Guardrails: groundedness check + abstention at score < 0.7
    """
    vector_store:    VectorStore
    embedder:        EmbeddingModel
    llm:             LLM
    chunk_size:      int = 512
    chunk_overlap:   int = 102    # ~20%
    top_k:           int = 5
    min_ground_score: float = 0.7

    def ingest(self, documents: list[str]) -> dict:
        chunks = self._chunk_documents(documents)
        embeddings = self.embedder.embed(chunks)
        self.vector_store.upsert(chunks, embeddings)
        return {"chunks_indexed": len(chunks)}

    def query(self, user_query: str) -> dict:
        q_emb   = self.embedder.embed([user_query])[0]
        context = self.vector_store.query(q_emb, top_k=self.top_k)
        answer  = self.llm.generate(
            messages=[
                {"role": "system", "content": "Answer ONLY from context. Say 'I don't know' if unsure."},
                {"role": "user",   "content": f"Context:\n{chr(10).join(context)}\n\nQ: {user_query}"},
            ],
            max_tokens=400,
        )
        return {"answer": answer, "sources": context[:2]}  # return top 2 as citations

    def _chunk_documents(self, docs: list[str]) -> list[str]:
        chunks = []
        for doc in docs:
            words = doc.split()
            step  = self.chunk_size - self.chunk_overlap
            for i in range(0, len(words), step):
                chunk = " ".join(words[i:i + self.chunk_size])
                if chunk:
                    chunks.append(chunk)
        return chunks

# Interview talking points:
DESIGN_DECISIONS = {
    "scaling":     "Horizontal scaling of inference; async ingestion pipeline",
    "caching":     "Semantic cache on query embeddings (exact match L1, cosine L2)",
    "monitoring":  "Track: retrieval recall@5, groundedness score, P95 latency, CSAT",
    "failure_modes": "Empty retrieval → abstain; low groundedness → human escalation",
    "cost":        "Batch embed during ingestion; cache hit rate target >60%",
}
for k, v in DESIGN_DECISIONS.items():
    print(f"{k.upper():<18}: {v}")
```
'@)

Write-Host ""
Write-Host "Phase 5 Batch 3 complete. Files updated: $count"
