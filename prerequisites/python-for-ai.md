---
title: "Python for AI"
tags: [python, numpy, pytorch, huggingface, environment, genai-prerequisite]
type: procedure
difficulty: beginner
status: published
parent: "[[../genai]]"
related: ["[[neural-networks]]", "[[linear-algebra-for-ai]]", "[[deep-learning-fundamentals]]"]
source: "PyTorch docs, NumPy docs, HuggingFace docs"
created: 2026-03-18
updated: 2026-03-18
---

# Python for AI

> ✨ **Bit**: Python is slow. But nobody cares because the actual computation happens in C++/CUDA underneath. Python is just the steering wheel — the engine is written in C.

---

## ★ TL;DR

- **What**: The Python libraries, patterns, and setup needed for GenAI development
- **Why**: Python is the universal language of AI. Every framework, every model, every tool speaks Python.
- **Key point**: You need: NumPy (arrays), PyTorch (tensors + GPU), HuggingFace (models), and package management.

---

## ★ Overview

### Definition

This document covers the essential Python ecosystem for GenAI — not Python basics, but the specific libraries, patterns, and environment setup that matter for working with LLMs, training models, and building AI applications.

### Scope

Assumes basic Python knowledge (variables, functions, classes, loops). Focuses on AI-specific libraries and patterns.

---

## ★ Deep Dive

### The AI Python Ecosystem Map

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR CODE                             │
├─────────────────────────────────────────────────────────┤
│  APPLICATION LAYER                                      │
│  LangChain │ LlamaIndex │ Gradio │ Streamlit            │
├─────────────────────────────────────────────────────────┤
│  MODEL LAYER                                            │
│  🤗 Transformers │ PEFT │ TRL │ Diffusers               │
├──────────────────────┬──────────────────────────────────┤
│  COMPUTE FRAMEWORK   │  DATA TOOLS                      │
│  PyTorch │ JAX       │  Pandas │ Datasets               │
├──────────────────────┴──────────────────────────────────┤
│  FOUNDATION                                             │
│  NumPy │ SciPy │ Matplotlib                             │
├─────────────────────────────────────────────────────────┤
│  RUNTIME                                                │
│  Python 3.10+ │ CUDA │ pip/conda                        │
└─────────────────────────────────────────────────────────┘
```

### 1. NumPy — The Foundation

```python
import numpy as np

# Arrays (like lists but FAST — 50-100x faster than Python lists)
a = np.array([1, 2, 3, 4, 5])
b = np.array([10, 20, 30, 40, 50])

# Element-wise operations (no loops needed!)
c = a + b        # [11, 22, 33, 44, 55]
d = a * b        # [10, 40, 90, 160, 250]
e = a ** 2       # [1, 4, 9, 16, 25]

# Dot product (most important operation)
similarity = np.dot(a, b)  # 1×10 + 2×20 + 3×30 + 4×40 + 5×50 = 550

# Matrix operations
W = np.random.randn(768, 3072)   # Weight matrix (like in a Transformer)
x = np.random.randn(32, 768)     # Batch of 32 embeddings
output = x @ W                    # Matrix multiply → (32, 3072)

# Reshaping (happens ALL THE TIME in AI)
img = np.random.randn(224, 224, 3)  # Image: H × W × channels
flat = img.reshape(-1)               # Flatten: 224*224*3 = 150528
batch = img.reshape(1, 3, 224, 224)  # Reshape for PyTorch: B × C × H × W

# Broadcasting (NumPy magic)
matrix = np.random.randn(32, 768)
bias = np.random.randn(768)         # 1D
result = matrix + bias               # Bias is auto-broadcast to each row!
```

### 2. PyTorch — The AI Framework

```python
import torch
import torch.nn as nn

# Tensors (like NumPy arrays but with GPU support + auto-differentiation)
x = torch.randn(32, 768)                           # Random tensor
x_gpu = x.to("cuda")                                # Move to GPU!
x_back = x_gpu.to("cpu")                            # Move back

# Automatic differentiation (THE magic of PyTorch)
w = torch.randn(3, requires_grad=True)   # Track gradients
x = torch.tensor([1.0, 2.0, 3.0])
y = (w * x).sum()                         # Forward pass
y.backward()                              # Compute all gradients
print(w.grad)                             # ∂y/∂w = x = [1, 2, 3]

# Building models
class MyModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.linear = nn.Linear(768, 10)
        self.relu = nn.ReLU()
    
    def forward(self, x):
        return self.relu(self.linear(x))

model = MyModel()
model.to("cuda")   # Entire model to GPU

# Common patterns you'll see everywhere
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-4)
scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=1000)
loss_fn = nn.CrossEntropyLoss()
```

### 3. HuggingFace — The Model Hub

```python
# ═══ Using a pre-trained LLM ═══
from transformers import AutoTokenizer, AutoModelForCausalLM

model_name = "meta-llama/Llama-3.2-1B"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name)

inputs = tokenizer("The future of AI is", return_tensors="pt")
outputs = model.generate(**inputs, max_new_tokens=50)
print(tokenizer.decode(outputs[0]))

# ═══ Using embeddings ═══
from sentence_transformers import SentenceTransformer
model = SentenceTransformer("BAAI/bge-m3")
embeddings = model.encode(["Hello world", "Hi there"])

# ═══ Using pipelines (simplest API) ═══
from transformers import pipeline
classifier = pipeline("sentiment-analysis")
result = classifier("I love building AI systems!")
# → [{'label': 'POSITIVE', 'score': 0.9998}]
```

### 4. Environment Setup

```bash
# Option A: Conda (recommended for AI — manages CUDA)
conda create -n genai python=3.11
conda activate genai
conda install pytorch pytorch-cuda=12.1 -c pytorch -c nvidia
pip install transformers accelerate langchain

# Option B: pip + venv
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows
pip install torch transformers langchain

# Check GPU availability
python -c "import torch; print(torch.cuda.is_available())"
```

---

## ◆ Quick Reference

```
LIBRARY MAP:
  NumPy          → Arrays, math operations, foundation
  PyTorch        → Tensors, GPU, autograd, model training
  Transformers   → Pre-trained models (HuggingFace)
  PEFT           → LoRA/QLoRA fine-tuning
  TRL            → RLHF/DPO training
  Datasets       → Loading/processing datasets (HuggingFace)
  LangChain      → RAG, chains, agents
  LlamaIndex     → Data indexing, RAG
  Gradio         → Quick ML demos/UIs
  Streamlit      → Data apps / dashboards
  Matplotlib     → Plotting / visualization
  Pandas         → Tabular data manipulation

COMMON IMPORTS:
  import torch
  import torch.nn as nn
  import torch.nn.functional as F
  from transformers import AutoTokenizer, AutoModel
  import numpy as np

GPU QUICK CHECK:
  torch.cuda.is_available()        → True/False
  torch.cuda.device_count()        → Number of GPUs
  torch.cuda.get_device_name(0)    → GPU name
  tensor.to("cuda")                → Move to GPU
  tensor.to("cpu")                 → Move to CPU
```

---

## ○ Gotchas & Common Mistakes

- ⚠️ **CPU vs GPU tensors**: Can't do operations on tensors on different devices. Always check `.device`.
- ⚠️ **`pip install torch` ≠ GPU support**: You need the CUDA-enabled version from pytorch.org, not generic pip.
- ⚠️ **Memory leaks in training**: Keep `loss.item()` for logging (not `loss` — that holds the entire computation graph).
- ⚠️ **Version conflicts**: Pin your versions. `transformers==4.45.0` not just `transformers`.
- ⚠️ **`model.eval()` for inference**: Always set this — disables dropout and batch norm training behavior.

---

## ★ Connections

| Relationship | Topics                                                                |
| ------------ | --------------------------------------------------------------------- |
| Builds on    | Python basics, [[linear-algebra-for-ai]]                              |
| Leads to     | [[neural-networks]], [[deep-learning-fundamentals]], all GenAI topics |
| Compare with | JavaScript (emerging for AI), Rust (for performance-critical tools)   |
| Cross-domain | Software engineering, DevOps (deployment), Data engineering           |

---

## ★ Sources

- PyTorch documentation — https://pytorch.org/docs/
- NumPy documentation — https://numpy.org/doc/
- HuggingFace documentation — https://huggingface.co/docs
- Conda documentation — https://docs.conda.io
