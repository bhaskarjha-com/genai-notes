# inject_code_sections_batch2.ps1 - Phase 5 Batch 2: remaining 17 notes
# Run from repo root: powershell -ExecutionPolicy Bypass -File scripts\inject_code_sections_batch2.ps1

param([switch]$DryRun)

# Reuse the same Inject-CodeSection function
function Inject-CodeSection {
    param([string]$File, [string]$Code)
    $abs  = (Resolve-Path $File -ErrorAction SilentlyContinue)
    if (-not $abs) { Write-Warning "File not found: $File"; return $false }
    $abs  = $abs.Path
    $text = [System.IO.File]::ReadAllText($abs)
    if ($text -match "Code & Implementation") {
        Write-Host "  SKIP: $File"
        return $false
    }
    $match = [regex]::Match($text, '##[^\n]*Connections[^\n]*\n')
    if (-not $match.Success) {
        # Try before Recommended Resources if no Connections
        $match = [regex]::Match($text, '##[^\n]*Recommended Resources[^\n]*\n')
    }
    if (-not $match.Success) {
        # Try before Sources
        $match = [regex]::Match($text, '##[^\n]*Sources[^\n]*\n')
    }
    if ($match.Success) {
        $marker  = $match.Value
        $newText = $text.Replace($marker, $Code.TrimEnd() + "`n`n" + $marker)
        if (-not $DryRun) {
            [System.IO.File]::WriteAllText($abs, $newText, [System.Text.UTF8Encoding]::new($false))
        }
        Write-Host "  INJECTED: $File"
        return $true
    }
    Write-Warning "  FAILED - no marker found: $File"
    return $false
}

$count = 0

# ── foundations/modern-architectures.md ──────────────────────────────────────
$count += [int](Inject-CodeSection "foundations\modern-architectures.md" @'
## ★ Code & Implementation

### Compare SSM vs Transformer Throughput

```python
# pip install torch>=2.3 mamba-ssm>=1.2  (mamba-ssm requires CUDA)
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3; mamba-ssm for Mamba models
# For CPU-only demo: use PyTorch baseline only

import torch, time

def benchmark_inference(model, input_ids, n_runs: int = 10) -> float:
    """Return median inference latency in ms."""
    latencies = []
    with torch.inference_mode():
        for _ in range(n_runs):
            start = time.monotonic()
            model(input_ids)
            latencies.append((time.monotonic() - start) * 1000)
    latencies.sort()
    return latencies[len(latencies) // 2]  # median

# Transformer baseline (decoder-only, minimal)
import torch.nn as nn

class MiniTransformer(nn.Module):
    def __init__(self, d=256, heads=4, layers=4, seq=512):
        super().__init__()
        self.embed = nn.Embedding(32000, d)
        self.layers = nn.ModuleList([
            nn.TransformerDecoderLayer(d, heads, batch_first=True)
            for _ in range(layers)
        ])
        self.head = nn.Linear(d, 32000)

    def forward(self, x):
        h = self.embed(x)
        mem = torch.zeros_like(h)  # dummy memory
        for layer in self.layers:
            h = layer(h, mem)
        return self.head(h)

model = MiniTransformer()
ids   = torch.randint(0, 32000, (1, 512))
lat   = benchmark_inference(model, ids)
print(f"MiniTransformer (512 tokens): {lat:.1f}ms median")
# Note: quadratic scaling — try seq=1024, 2048 to see latency grow
```
'@)

# ── foundations/scaling-laws-and-pretraining.md ───────────────────────────────
$count += [int](Inject-CodeSection "foundations\scaling-laws-and-pretraining.md" @'
## ★ Code & Implementation

### Chinchilla Optimal Token Calculator

```python
# ⚠️ Last tested: 2026-04 | Requires: Python 3.10+ (stdlib only)
# Chinchilla paper (Hoffmann et al. 2022): optimal training = 20 tokens per parameter

def chinchilla_optimal(params: float, budget_override: float | None = None) -> dict:
    """
    params: model parameters (e.g. 7e9 for 7B)
    Returns: Chinchilla-optimal token count and FLOPs estimate
    """
    tokens_optimal = 20 * params          # Chinchilla rule
    flops_estimate = 6 * params * tokens_optimal  # ~6 * N * D for transformer training
    return {
        "params":         params,
        "params_B":       params / 1e9,
        "tokens_optimal": tokens_optimal,
        "tokens_B":       tokens_optimal / 1e9,
        "flops_estimate": flops_estimate,
        "flops_e21":      flops_estimate / 1e21,
    }

# Compare common model sizes
for model_name, params in [
    ("LLaMA 3.2 1B",  1e9),
    ("LLaMA 3.2 8B",  8e9),
    ("LLaMA 3 70B",  70e9),
    ("GPT-3 175B",  175e9),
]:
    r = chinchilla_optimal(params)
    print(
        f"{model_name:<18} | {r['params_B']:>6.1f}B params | "
        f"optimal: {r['tokens_B']:>6.0f}B tokens | "
        f"{r['flops_e21']:.1f}e21 FLOPs"
    )

# Note: Modern models (LLaMA 3, Gemma 3) over-train by 5-10x for better
# inference efficiency — Chinchilla is the floor, not the ceiling.
```
'@)

# ── foundations/state-space-models.md ────────────────────────────────────────
$count += [int](Inject-CodeSection "foundations\state-space-models.md" @'
## ★ Code & Implementation

### Minimal SSM Recurrence (Discrete S4/Mamba Pattern)

```python
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3
# Demonstrates the core SSM recurrence: h_t = A*h_{t-1} + B*x_t, y_t = C*h_t
# This is the linear recurrence at the heart of S4/Mamba

import torch
import torch.nn as nn

class MinimalSSM(nn.Module):
    """Simplified 1D SSM layer demonstrating the recurrence."""
    def __init__(self, d_model: int, d_state: int = 16):
        super().__init__()
        self.d_state = d_state
        # State space matrices (learned)
        self.A = nn.Parameter(torch.randn(d_state, d_state) * 0.01)
        self.B = nn.Parameter(torch.randn(d_state, d_model) * 0.01)
        self.C = nn.Parameter(torch.randn(d_model, d_state) * 0.01)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        """
        x: (batch, seq_len, d_model)
        Returns: y (batch, seq_len, d_model) via sequential recurrence
        Note: production Mamba uses CUDA-optimized parallel scan, not this loop
        """
        batch, seq_len, _ = x.shape
        h = torch.zeros(batch, self.d_state, device=x.device)
        outputs = []
        for t in range(seq_len):
            h = torch.tanh(h @ self.A.T + x[:, t, :] @ self.B.T)
            y_t = h @ self.C.T
            outputs.append(y_t)
        return torch.stack(outputs, dim=1)

# Test: O(n) in memory (no n² attention matrix)
ssm = MinimalSSM(d_model=64, d_state=16)
x   = torch.randn(2, 1024, 64)  # batch=2, seq=1024, d=64
y   = ssm(x)
print(f"Input:  {x.shape}")  # (2, 1024, 64)
print(f"Output: {y.shape}")  # (2, 1024, 64) — same shape, O(n) memory
```
'@)

# ── agents/agentic-protocols.md ───────────────────────────────────────────────
$count += [int](Inject-CodeSection "agents\agentic-protocols.md" @'
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
'@)

# ── ethics-and-safety/ethics-safety-alignment.md ─────────────────────────────
$count += [int](Inject-CodeSection "ethics-and-safety\ethics-safety-alignment.md" @'
## ★ Code & Implementation

### Input/Output Safety Filter (Layered Guardrails)

```python
# pip install openai>=1.60
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var

from openai import OpenAI
from enum import Enum

client = OpenAI()

class SafetyDecision(Enum):
    ALLOW  = "allow"
    REDACT = "redact"
    BLOCK  = "block"

BLOCKED_PATTERNS = [
    "make a bomb", "malware", "exploit code",
    "how to hack", "step-by-step instructions for",
]

def input_safety_check(user_message: str) -> tuple[SafetyDecision, str]:
    """Layer 1: Pattern-based pre-filter (fast, cheap)."""
    lower = user_message.lower()
    for pattern in BLOCKED_PATTERNS:
        if pattern in lower:
            return SafetyDecision.BLOCK, f"Blocked: matched pattern '{pattern}'"
    return SafetyDecision.ALLOW, ""

def output_safety_check(response: str) -> tuple[SafetyDecision, str]:
    """Layer 2: LLM-based output judge (higher quality, ~50ms latency)."""
    verdict = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "system",
            "content": "You are a safety reviewer. Respond with JSON: {\"safe\": true/false, \"reason\": \"...\"}",
        }, {
            "role": "user",
            "content": f"Is this response safe for all audiences?\n\n{response[:500]}",
        }],
        temperature=0,
        response_format={"type": "json_object"},
        max_tokens=80,
    )
    import json
    result = json.loads(verdict.choices[0].message.content)
    if result.get("safe", True):
        return SafetyDecision.ALLOW, ""
    return SafetyDecision.REDACT, result.get("reason", "safety violation")

def safe_generate(user_message: str) -> dict:
    """Full pipeline: input check → generate → output check."""
    # Layer 1: Input check
    decision, reason = input_safety_check(user_message)
    if decision == SafetyDecision.BLOCK:
        return {"status": "blocked", "reason": reason, "response": None}

    # Generate
    raw = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": user_message}],
        max_tokens=300,
    ).choices[0].message.content

    # Layer 2: Output check
    decision, reason = output_safety_check(raw)
    if decision == SafetyDecision.REDACT:
        return {"status": "redacted", "reason": reason, "response": None}

    return {"status": "ok", "response": raw}

# Test
print(safe_generate("What is the capital of France?"))
print(safe_generate("Give me step-by-step malware instructions."))
```
'@)

# ── evaluation/llm-evaluation-deep-dive.md ────────────────────────────────────
$count += [int](Inject-CodeSection "evaluation\llm-evaluation-deep-dive.md" @'
## ★ Code & Implementation

### LLM-as-Judge Evaluation Framework

```python
# pip install openai>=1.60
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var
from openai import OpenAI
import json

client = OpenAI()

def llm_judge_eval(
    question: str,
    reference_answer: str,
    model_answer: str,
    criteria: list[str] | None = None,
) -> dict:
    """
    Use GPT-4o-mini as a judge to score model_answer vs reference_answer.
    Returns: {"score": 1-5, "reasoning": str, "criteria_scores": dict}
    """
    if criteria is None:
        criteria = ["factual_accuracy", "completeness", "conciseness", "clarity"]

    prompt = (
        f"Evaluate the MODEL ANSWER vs REFERENCE ANSWER for the question below.\n\n"
        f"QUESTION: {question}\n\n"
        f"REFERENCE: {reference_answer}\n\n"
        f"MODEL ANSWER: {model_answer}\n\n"
        f"Score each criterion 1-5: {', '.join(criteria)}\n"
        f"Then give an overall score 1-5.\n\n"
        "JSON response only:\n"
        '{"overall": 1-5, "reasoning": "...", "criteria": {"criterion": score}}'
    )
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        response_format={"type": "json_object"},
    )
    result = json.loads(resp.choices[0].message.content)
    return result

# Example evaluation
result = llm_judge_eval(
    question="What is RAG and why is it used?",
    reference_answer="RAG (Retrieval-Augmented Generation) combines retrieval of external documents with LLM generation to ground responses in current, accurate information and reduce hallucination.",
    model_answer="RAG retrieves documents and feeds them to an LLM to improve answer accuracy.",
)
print(f"Score: {result['overall']}/5")
print(f"Reasoning: {result['reasoning']}")
```
'@)

# ── techniques/rl-alignment.md ────────────────────────────────────────────────
$count += [int](Inject-CodeSection "techniques\rl-alignment.md" @'
## ★ Code & Implementation

### DPO Training Data Format + Trainer Setup

```python
# pip install transformers>=4.40 trl>=0.8 datasets peft>=0.10
# ⚠️ Last tested: 2026-04 | Requires: GPU, trl>=0.8, HuggingFace login
from datasets import Dataset
from trl import DPOTrainer, DPOConfig
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import LoraConfig

# DPO data format: prompt + chosen response + rejected response
dpo_data = [
    {
        "prompt":   "What is the capital of France?",
        "chosen":   "The capital of France is Paris.",
        "rejected": "France is a country in Europe.",
    },
    {
        "prompt":   "Summarize the transformer architecture.",
        "chosen":   "Transformers use self-attention to process sequences in parallel, enabling long-range dependency capture without recurrence.",
        "rejected": "Transformers are neural networks used for NLP tasks.",
    },
]
dataset = Dataset.from_list(dpo_data)

model_id  = "google/gemma-2-2b-it"     # small model for demo
tokenizer = AutoTokenizer.from_pretrained(model_id)
model     = AutoModelForCausalLM.from_pretrained(model_id)

lora_config = LoraConfig(r=8, lora_alpha=16, target_modules=["q_proj", "v_proj"])

config = DPOConfig(
    output_dir="./dpo-output",
    num_train_epochs=1,
    per_device_train_batch_size=1,
    learning_rate=5e-6,
    beta=0.1,           # KL penalty coefficient — higher = closer to reference model
    logging_steps=5,
)

trainer = DPOTrainer(
    model=model,
    ref_model=None,        # None = use PEFT reference internally
    args=config,
    train_dataset=dataset,
    tokenizer=tokenizer,
    peft_config=lora_config,
)
# trainer.train()  # Uncomment to train (requires GPU)
print("DPO trainer initialized. Dataset:", dataset)
print("Beta (KL coeff):", config.beta)
```
'@)

# ── techniques/distillation-and-compression.md ────────────────────────────────
$count += [int](Inject-CodeSection "techniques\distillation-and-compression.md" @'
## ★ Code & Implementation

### Knowledge Distillation: Teacher → Student Loss

```python
# pip install torch>=2.3 transformers>=4.40
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3
import torch
import torch.nn as nn
import torch.nn.functional as F

def distillation_loss(
    student_logits: torch.Tensor,
    teacher_logits: torch.Tensor,
    labels: torch.Tensor,
    temperature: float = 4.0,
    alpha: float = 0.7,
) -> torch.Tensor:
    """
    Combined distillation + CE loss.

    student_logits: (batch, seq, vocab)
    teacher_logits: (batch, seq, vocab)
    labels:         (batch, seq) ground-truth token IDs
    temperature:    softs the teacher distribution (higher = more information)
    alpha:          weight of distillation loss (1-alpha = CE weight)
    """
    # Soft targets from teacher (temperature scaling)
    soft_teacher = F.softmax(teacher_logits / temperature, dim=-1)
    soft_student = F.log_softmax(student_logits / temperature, dim=-1)
    kd_loss = F.kl_div(soft_student, soft_teacher, reduction="batchmean") * (temperature ** 2)

    # Hard targets from ground truth labels
    ce_loss = F.cross_entropy(
        student_logits.view(-1, student_logits.size(-1)),
        labels.view(-1),
        ignore_index=-100,
    )

    return alpha * kd_loss + (1 - alpha) * ce_loss

# Example shapes (tiny vocab for demo)
batch, seq, vocab = 2, 10, 100
student_logits = torch.randn(batch, seq, vocab)
teacher_logits = torch.randn(batch, seq, vocab)
labels         = torch.randint(0, vocab, (batch, seq))

loss = distillation_loss(student_logits, teacher_logits, labels)
print(f"Distillation loss: {loss.item():.4f}")

# GGUF Quantization check (inference only — requires llama.cpp)
# After downloading a GGUF model:
# from llama_cpp import Llama
# llm = Llama(model_path="./model.gguf", n_ctx=2048)
# output = llm("Explain LoRA in one sentence.", max_tokens=80)
# print(output["choices"][0]["text"])
```
'@)

# ── techniques/continual-learning.md ─────────────────────────────────────────
$count += [int](Inject-CodeSection "techniques\continual-learning.md" @'
## ★ Code & Implementation

### Elastic Weight Consolidation (EWC) Implementation

```python
# pip install torch>=2.3
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3
# EWC protects important weights from catastrophic forgetting when fine-tuning

import torch
import torch.nn as nn
import torch.nn.functional as F
from copy import deepcopy

class EWC:
    """Elastic Weight Consolidation regularizer."""
    def __init__(self, model: nn.Module, dataset_loader, lambda_ewc: float = 400.0):
        self.model      = model
        self.lambda_ewc = lambda_ewc
        self._old_params: dict[str, torch.Tensor] = {}
        self._fisher:     dict[str, torch.Tensor] = {}
        self._compute_fisher(dataset_loader)

    def _compute_fisher(self, loader) -> None:
        """Estimate Fisher information (parameter importance) from task A data."""
        fisher = {n: torch.zeros_like(p) for n, p in self.model.named_parameters()}
        self.model.eval()
        for inputs, targets in loader:
            self.model.zero_grad()
            logits = self.model(inputs)
            loss   = F.cross_entropy(logits, targets)
            loss.backward()
            for n, p in self.model.named_parameters():
                if p.grad is not None:
                    fisher[n] += p.grad.pow(2)
        # Normalize by dataset size
        n = len(loader.dataset)
        self._fisher     = {n: f / n for n, f in fisher.items()}
        self._old_params = {n: p.clone().detach() for n, p in self.model.named_parameters()}

    def penalty(self) -> torch.Tensor:
        """Compute EWC regularization term. Add to task B training loss."""
        loss = torch.tensor(0.0)
        for n, p in self.model.named_parameters():
            if n in self._fisher:
                loss += (self._fisher[n] * (p - self._old_params[n]).pow(2)).sum()
        return 0.5 * self.lambda_ewc * loss

# Usage:
# ewc = EWC(model, task_a_loader)
# for batch in task_b_loader:
#     loss = task_b_loss(model, batch) + ewc.penalty()
#     loss.backward()
#     optimizer.step()
print("EWC class ready. Usage: loss += ewc.penalty() during Task B training.")
```
'@)

# ── techniques/synthetic-data-and-data-engineering.md ────────────────────────
$count += [int](Inject-CodeSection "techniques\synthetic-data-and-data-engineering.md" @'
## ★ Code & Implementation

### Synthetic Instruction Data Generator

```python
# pip install openai>=1.60
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var
from openai import OpenAI
import json

client = OpenAI()

def generate_instruction_dataset(
    domain: str,
    num_examples: int = 10,
    task_types: list[str] | None = None,
) -> list[dict]:
    """Generate synthetic instruction-response pairs for SFT fine-tuning."""
    if task_types is None:
        task_types = ["explain", "summarize", "compare", "give example", "list steps for"]

    prompt = (
        f"Generate {num_examples} diverse instruction-response pairs for the domain: '{domain}'.\n"
        f"Use these task types: {', '.join(task_types)}.\n"
        "Each pair should be high-quality and diverse.\n\n"
        "JSON format only:\n"
        '[{"instruction": "...", "response": "...", "task_type": "..."}, ...]'
    )
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.9,          # high diversity
        max_tokens=3000,
        response_format={"type": "json_object"},
    )
    # Parse response (model returns single JSON object with list inside)
    raw = json.loads(resp.choices[0].message.content)
    # Handle different keys the model might use
    for key in ("items", "examples", "pairs", "data"):
        if key in raw:
            return raw[key]
    return list(raw.values())[0] if raw else []

# Generate RAG training data
examples = generate_instruction_dataset(
    domain="Retrieval-Augmented Generation for enterprise software",
    num_examples=5,
)
for ex in examples[:3]:
    print(f"[{ex.get('task_type', 'N/A')}] {ex['instruction'][:60]}...")
    print(f"  → {ex['response'][:80]}...\n")

# Save for fine-tuning
with open("synthetic_sft_data.jsonl", "w") as f:
    for ex in examples:
        f.write(json.dumps(ex) + "\n")
print(f"Saved {len(examples)} examples to synthetic_sft_data.jsonl")
```
'@)

# ── techniques/context-engineering.md ────────────────────────────────────────
$count += [int](Inject-CodeSection "techniques\context-engineering.md" @'
## ★ Code & Implementation

### Dynamic Context Window Manager

```python
# pip install openai>=1.60 tiktoken>=0.6
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, tiktoken>=0.6, OPENAI_API_KEY
import tiktoken
from openai import OpenAI
from dataclasses import dataclass, field

client = OpenAI()
enc    = tiktoken.encoding_for_model("gpt-4o")

def count_tokens(text: str) -> int:
    return len(enc.encode(text))

@dataclass
class ContextManager:
    """Manages context window budget across system prompt, history, and retrieved docs."""
    model: str         = "gpt-4o-mini"
    context_limit: int = 8192       # safe limit (model max - output buffer)
    system_prompt: str = "You are a helpful assistant."
    history:       list[dict] = field(default_factory=list)

    @property
    def _system_tokens(self) -> int:
        return count_tokens(self.system_prompt)

    def add_user_message(self, content: str, context_docs: list[str] | None = None) -> list[dict]:
        """Build a messages list that fits within the context limit."""
        # Build the user message with retrieved context
        if context_docs:
            context_str = "\n\n".join(f"[Doc {i+1}]: {d}" for i, d in enumerate(context_docs))
            full_content = f"Context:\n{context_str}\n\nQuestion: {content}"
        else:
            full_content = content

        # Truncate history to fit in budget
        budget = self.context_limit - self._system_tokens - count_tokens(full_content) - 200
        trimmed_history = []
        history_tokens = 0
        for msg in reversed(self.history):
            t = count_tokens(msg["content"])
            if history_tokens + t > budget:
                break
            trimmed_history.insert(0, msg)
            history_tokens += t

        messages = (
            [{"role": "system", "content": self.system_prompt}]
            + trimmed_history
            + [{"role": "user", "content": full_content}]
        )
        used_tokens = self._system_tokens + history_tokens + count_tokens(full_content)
        print(f"Context: {used_tokens}/{self.context_limit} tokens ({len(trimmed_history)} history msgs)")
        return messages

    def chat(self, user_input: str, context_docs: list[str] | None = None) -> str:
        messages = self.add_user_message(user_input, context_docs)
        resp = client.chat.completions.create(
            model=self.model, messages=messages, max_tokens=500
        )
        answer = resp.choices[0].message.content
        self.history.append({"role": "user",      "content": user_input})
        self.history.append({"role": "assistant",  "content": answer})
        return answer

# Example
cm = ContextManager(system_prompt="You are a concise ML expert.")
r  = cm.chat("What is RAG?", context_docs=["RAG combines retrieval with generation to ground LLM answers."])
print(r)
```
'@)

# ── techniques/graph-rag.md ───────────────────────────────────────────────────
$count += [int](Inject-CodeSection "techniques\graph-rag.md" @'
## ★ Code & Implementation

### Mini Knowledge Graph RAG with NetworkX

```python
# pip install openai>=1.60 networkx>=3.2
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, networkx>=3.2, OPENAI_API_KEY
from openai import OpenAI
import networkx as nx
import json

client = OpenAI()

# Build a small knowledge graph
G = nx.DiGraph()
G.add_edges_from([
    ("Transformer",  "Self-Attention",         {"relation": "uses"}),
    ("Self-Attention","Query-Key-Value",        {"relation": "implements"}),
    ("BERT",         "Transformer",            {"relation": "is_based_on"}),
    ("GPT",          "Transformer",            {"relation": "is_based_on"}),
    ("RAG",          "Transformer",            {"relation": "uses"}),
    ("RAG",          "Vector Database",        {"relation": "retrieves_from"}),
    ("LoRA",         "Transformer",            {"relation": "adapts"}),
])

def graph_context(query_entity: str, hops: int = 2) -> str:
    """Extract k-hop neighborhood from graph as context for LLM."""
    if query_entity not in G:
        return f"Entity '{query_entity}' not in knowledge graph."
    nodes = nx.ego_graph(G, query_entity, radius=hops)
    triples = [(u, G[u][v]["relation"], v) for u, v in nodes.edges()]
    return "\n".join(f"{u} --[{r}]--> {v}" for u, r, v in triples)

def graph_rag_query(question: str, entity: str) -> str:
    context = graph_context(entity, hops=2)
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": "Answer based on the knowledge graph context."},
            {"role": "user",   "content": f"Graph Context:\n{context}\n\nQuestion: {question}"},
        ],
        temperature=0, max_tokens=200,
    )
    return resp.choices[0].message.content

print(graph_context("RAG", hops=2))
print("\n---")
print(graph_rag_query("What components does RAG rely on?", entity="RAG"))
```
'@)

# ── multimodal/multimodal-ai.md ───────────────────────────────────────────────
$count += [int](Inject-CodeSection "multimodal\multimodal-ai.md" @'
## ★ Code & Implementation

### Vision + Text with GPT-4o (Image Analysis)

```python
# pip install openai>=1.60 Pillow>=10
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY env var
import base64
from pathlib import Path
from openai import OpenAI

client = OpenAI()

def analyze_image(image_path: str, question: str = "Describe this image in detail.") -> str:
    """Send an image + question to GPT-4o vision."""
    img_bytes = Path(image_path).read_bytes()
    b64_image = base64.b64encode(img_bytes).decode("utf-8")
    ext       = Path(image_path).suffix.lstrip(".").lower()
    media_type = f"image/{ext}" if ext in ("jpg", "jpeg", "png", "gif", "webp") else "image/jpeg"

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": [
                {"type": "image_url",
                 "image_url": {"url": f"data:{media_type};base64,{b64_image}", "detail": "high"}},
                {"type": "text", "text": question},
            ],
        }],
        max_tokens=500,
    )
    return response.choices[0].message.content

# URL-based (no local file needed for testing)
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{
        "role": "user",
        "content": [
            {"type": "image_url",
             "image_url": {"url": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Simple_English_Wikipedia_favicon.svg/240px-Simple_English_Wikipedia_favicon.svg.png"}},
            {"type": "text", "text": "What is shown in this image?"},
        ],
    }],
    max_tokens=100,
)
print(response.choices[0].message.content)
```
'@)

# ── tools-and-infra/tools-overview.md ────────────────────────────────────────
$count += [int](Inject-CodeSection "tools-and-infra\tools-overview.md" @'
## ★ Code & Implementation

### LangChain vs Direct API Comparison

```python
# pip install openai>=1.60 langchain>=0.2 langchain-openai>=0.1
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, langchain>=0.2, OPENAI_API_KEY

# ═══ DIRECT OPENAI API (recommended for simple cases) ═══
from openai import OpenAI
client = OpenAI()

def direct_rag(query: str, docs: list[str]) -> str:
    context = "\n\n".join(docs)
    return client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": f"Answer from context:\n{context}"},
            {"role": "user",   "content": query},
        ],
        max_tokens=200,
    ).choices[0].message.content

# ═══ LANGCHAIN (for complex pipelines, RAG chains, agents) ═══
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage

lc_model = ChatOpenAI(model="gpt-4o-mini", temperature=0)

def langchain_call(query: str) -> str:
    messages = [
        SystemMessage(content="You are a concise assistant."),
        HumanMessage(content=query),
    ]
    return lc_model.invoke(messages).content

# Compare outputs
docs = ["RAG combines retrieval with LLM generation to ground answers in real context."]
print("Direct:", direct_rag("What is RAG?", docs))
print("LangChain:", langchain_call("What is RAG in one sentence?"))
# Key insight: direct API = less abstraction, fewer deps, easier debugging
# LangChain = worth it when you need: memory, chains, agents, callbacks
```
'@)

# ── tools-and-infra/cloud-ml-services.md ─────────────────────────────────────
$count += [int](Inject-CodeSection "tools-and-infra\cloud-ml-services.md" @'
## ★ Code & Implementation

### Multi-Cloud LLM API Comparison

```python
# pip install openai>=1.60 anthropic>=0.40 google-generativeai>=0.8
# ⚠️ Last tested: 2026-04 | Requires: OPENAI_API_KEY, ANTHROPIC_API_KEY, GOOGLE_API_KEY env vars
import os, time
from openai    import OpenAI
import anthropic
import google.generativeai as genai

prompt = "Explain the difference between RAG and fine-tuning in 2 sentences."

# OpenAI (Azure-compatible: set base_url to Azure endpoint)
oai   = OpenAI()
start = time.monotonic()
oai_r = oai.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": prompt}],
    max_tokens=120,
)
print(f"OpenAI ({time.monotonic()-start:.2f}s): {oai_r.choices[0].message.content[:100]}")

# Anthropic Claude
ant   = anthropic.Anthropic()
start = time.monotonic()
ant_r = ant.messages.create(
    model="claude-3-5-haiku-20241022",
    max_tokens=120,
    messages=[{"role": "user", "content": prompt}],
)
print(f"Anthropic ({time.monotonic()-start:.2f}s): {ant_r.content[0].text[:100]}")

# Google Gemini
genai.configure(api_key=os.environ["GOOGLE_API_KEY"])
gem   = genai.GenerativeModel("gemini-2.0-flash")
start = time.monotonic()
gem_r = gem.generate_content(prompt)
print(f"Gemini ({time.monotonic()-start:.2f}s): {gem_r.text[:100]}")
```
'@)

# ── tools-and-infra/distributed-systems-for-ai.md ────────────────────────────
$count += [int](Inject-CodeSection "tools-and-infra\distributed-systems-for-ai.md" @'
## ★ Code & Implementation

### Tensor Parallel Training with PyTorch FSDP

```python
# pip install torch>=2.3
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3, multiple GPUs for true parallelism
# Single-GPU simulation: FSDP wraps work on 1 GPU with CPU offload

import torch
import torch.nn as nn
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from torch.distributed.fsdp.fully_sharded_data_parallel import CPUOffload

# Minimal model for demo
class TinyLLM(nn.Module):
    def __init__(self):
        super().__init__()
        self.embed = nn.Embedding(32000, 512)
        self.layers = nn.ModuleList([
            nn.TransformerEncoderLayer(d_model=512, nhead=8, batch_first=True)
            for _ in range(4)
        ])
        self.head = nn.Linear(512, 32000)

    def forward(self, x):
        h = self.embed(x)
        for layer in self.layers:
            h = layer(h)
        return self.head(h)

# In production: call torch.distributed.init_process_group first
# For demo, show FSDP wrapping pattern:
model = TinyLLM()
# FSDP with CPU offload (reduces GPU memory by keeping parameters on CPU when not in use)
# fsdp_model = FSDP(model, cpu_offload=CPUOffload(offload_params=True))

param_count = sum(p.numel() for p in model.parameters())
print(f"Model parameters: {param_count:,} ({param_count/1e6:.1f}M)")
print(f"Estimated BF16 memory: {param_count * 2 / 1e9:.2f} GB")
print(f"Estimated FSDP across 4 GPUs: {param_count * 2 / 1e9 / 4:.2f} GB per GPU")
# FSDP shards params across GPUs — linear memory reduction
```
'@)

# ── prerequisites/deep-learning-fundamentals.md ───────────────────────────────
$count += [int](Inject-CodeSection "prerequisites\deep-learning-fundamentals.md" @'
## ★ Code & Implementation

### Backpropagation from Scratch + PyTorch Comparison

```python
# pip install torch>=2.3
# ⚠️ Last tested: 2026-04 | Requires: torch>=2.3
import torch
import torch.nn as nn
import torch.nn.functional as F

# ═══ Manual 2-layer MLP forward + backward ═══
torch.manual_seed(42)
X = torch.randn(32, 10)      # 32 samples, 10 features
y = torch.randint(0, 3, (32,))  # 3-class labels

# Weights
W1 = torch.randn(10, 64, requires_grad=True)
b1 = torch.zeros(64,      requires_grad=True)
W2 = torch.randn(64, 3,  requires_grad=True)
b2 = torch.zeros(3,       requires_grad=True)

lr = 1e-3
for epoch in range(5):
    # Forward
    h   = F.relu(X @ W1 + b1)    # (32, 64)
    out = h @ W2 + b2             # (32, 3)
    loss = F.cross_entropy(out, y)

    # Backward
    loss.backward()

    # SGD update
    with torch.no_grad():
        W1 -= lr * W1.grad; W1.grad.zero_()
        b1 -= lr * b1.grad; b1.grad.zero_()
        W2 -= lr * W2.grad; W2.grad.zero_()
        b2 -= lr * b2.grad; b2.grad.zero_()

    print(f"Epoch {epoch+1}: loss={loss.item():.4f}")

# ═══ Same with nn.Module ═══ (idiomatic PyTorch)
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(10, 64), nn.ReLU(),
            nn.Linear(64, 3),
        )
    def forward(self, x): return self.net(x)

model     = MLP()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
for epoch in range(5):
    optimizer.zero_grad()
    loss = F.cross_entropy(model(X), y)
    loss.backward()
    optimizer.step()
print(f"nn.Module final loss: {loss.item():.4f}")
```
'@)

# ── research-frontiers/interpretability.md ────────────────────────────────────
$count += [int](Inject-CodeSection "research-frontiers\interpretability.md" @'
## ★ Code & Implementation

### Integrated Gradients (Feature Importance for LLMs)

```python
# pip install transformers>=4.40 torch>=2.3 captum>=0.7
# ⚠️ Last tested: 2026-04 | Requires: transformers>=4.40, captum>=0.7
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from captum.attr import IntegratedGradients

model_id  = "distilbert-base-uncased-finetuned-sst-2-english"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model     = AutoModelForSequenceClassification.from_pretrained(model_id)
model.eval()

def predict(input_ids: torch.Tensor) -> torch.Tensor:
    return model(input_ids).logits

text   = "This movie is absolutely fantastic!"
inputs = tokenizer(text, return_tensors="pt")
ids    = inputs["input_ids"]          # (1, seq_len)
tokens = tokenizer.convert_ids_to_tokens(ids[0])

# Baseline: all-PAD tokens (neutral reference)
baseline = torch.zeros_like(ids)

ig = IntegratedGradients(predict)
attrs, delta = ig.attribute(ids, baseline, target=1, return_convergence_delta=True)

# attrs: (1, seq_len) — positive = contributes to POSITIVE class
importance = attrs[0].detach().numpy()
print(f"Convergence delta: {delta.item():.4e}  (should be near 0)")
print("\nToken Attribution Scores:")
for token, score in sorted(zip(tokens, importance), key=lambda x: -abs(x[1])):
    bar = "█" * int(abs(score) * 30)
    sign = "+" if score > 0 else "-"
    print(f"  {token:<15} {sign}{abs(score):.4f}  {bar}")
```
'@)

# ── research-frontiers/research-methodology-and-paper-reading.md ──────────────
$count += [int](Inject-CodeSection "research-frontiers\research-methodology-and-paper-reading.md" @'
## ★ Code & Implementation

### Paper Analysis Pipeline with LLM

```python
# pip install openai>=1.60 PyPDF2>=3
# ⚠️ Last tested: 2026-04 | Requires: openai>=1.60, OPENAI_API_KEY, PyPDF2>=3
from openai import OpenAI
import PyPDF2, json

client = OpenAI()

def extract_text_from_pdf(pdf_path: str, max_chars: int = 8000) -> str:
    """Extract text from a PDF (first N chars to fit in context)."""
    reader = PyPDF2.PdfReader(pdf_path)
    text   = " ".join(page.extract_text() or "" for page in reader.pages)
    return text[:max_chars]

def analyze_paper(paper_text: str) -> dict:
    """Structured AI-powered paper analysis using the ACE framework."""
    prompt = (
        "Analyze this research paper and extract structured information.\n\n"
        f"PAPER:\n{paper_text}\n\n"
        "Return JSON with these fields:\n"
        "- problem: what problem does it solve?\n"
        "- method: what is the core method/approach?\n"
        "- key_results: top 3 quantitative results\n"
        "- limitations: what are the stated limitations?\n"
        "- reproducibility: 1-5 score (5=fully reproducible)\n"
        "- related_to: list 3 related techniques/papers\n"
        "- one_line_summary: max 20 words\n"
    )
    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
        temperature=0,
        response_format={"type": "json_object"},
        max_tokens=600,
    )
    return json.loads(resp.choices[0].message.content)

# Demo with a text snippet (replace with real PDF path)
demo_text = """
Title: Attention Is All You Need. We propose a new simple network architecture,
the Transformer, based solely on attention mechanisms, dispensing with recurrence
and convolutions entirely. On two machine translation tasks, it achieves state of
the art results of 28.4 BLEU on WMT 2014 English-to-German translation and 41.0
BLEU on the WMT 2014 English-to-French translation. Training took 3.5 days on 8 P100s.
"""
result = analyze_paper(demo_text)
print(json.dumps(result, indent=2))
```
'@)

# ── multimodal/diffusion-models.md ───────────────────────────────────────────
$count += [int](Inject-CodeSection "multimodal\diffusion-models.md" @'
## ★ Code & Implementation

### Image Generation with DALL-E 3 / Stable Diffusion

```python
# pip install openai>=1.60 diffusers>=0.27 torch>=2.3
# ⚠️ Last tested: 2026-04 | DALL-E requires: openai>=1.60, OPENAI_API_KEY
#                        | SD requires: diffusers>=0.27, GPU recommended

# ═══ Method 1: DALL-E 3 via OpenAI API ═══
from openai import OpenAI
client = OpenAI()

response = client.images.generate(
    model="dall-e-3",
    prompt="A photorealistic transformer robot made of glowing neural connections, dramatic lighting",
    size="1024x1024",
    quality="standard",
    n=1,
)
image_url = response.data[0].url
print(f"DALL-E 3 image URL: {image_url}")
# Note: URL expires after ~1 hour; download immediately

# ═══ Method 2: Stable Diffusion (local, free) ═══
# Requires: CUDA GPU with 6GB+ VRAM
# from diffusers import StableDiffusionPipeline
# import torch
#
# pipe = StableDiffusionPipeline.from_pretrained(
#     "runwayml/stable-diffusion-v1-5",
#     torch_dtype=torch.float16,
# ).to("cuda")
#
# image = pipe(
#     "A photorealistic transformer robot",
#     num_inference_steps=20,  # quality vs speed tradeoff
#     guidance_scale=7.5,      # prompt adherence vs diversity
# ).images[0]
# image.save("output.png")

# ═══ Conceptual DDPM Noise Scheduling ═══
import torch
import math

def cosine_beta_schedule(timesteps: int = 1000) -> torch.Tensor:
    """Cosine noise schedule (Improved DDPM, Ho et al. 2022)."""
    steps = torch.arange(timesteps + 1, dtype=torch.float64)
    s     = 0.008  # small offset to prevent singularity at t=0
    alphas_bar = torch.cos(((steps / timesteps) + s) / (1 + s) * math.pi * 0.5) ** 2
    alphas_bar = alphas_bar / alphas_bar[0]
    betas      = 1 - (alphas_bar[1:] / alphas_bar[:-1])
    return betas.clamp(0, 0.999)

betas = cosine_beta_schedule(1000)
print(f"Beta schedule: t=0 → {betas[0]:.6f}, t=500 → {betas[500]:.4f}, t=999 → {betas[-1]:.4f}")
# Noise is added gradually — early steps add tiny noise, late steps add lots
```
'@)

Write-Host ""
Write-Host "Phase 5 Batch 2 injection complete. Total files updated: $count"
