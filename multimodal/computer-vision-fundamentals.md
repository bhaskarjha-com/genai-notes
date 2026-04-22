---
title: "Computer Vision Fundamentals for AI Builders"
aliases: ["Computer Vision", "CV", "CNN", "Image Classification"]
tags: [computer-vision, cv, images, vit, detection, multimodal]
type: procedure
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "multimodal-ai.md"
related: ["diffusion-models.md", "../foundations/embeddings.md", "../foundations/modern-architectures.md"]
source: "Multiple - see Sources"
created: 2026-04-12
updated: 2026-04-14
---

# Computer Vision Fundamentals for AI Builders

> âœ¨ **Bit**: You don't need to be a vision PhD to build multimodal AI â€” but you do need to understand why a ViT-L/14 processes images as 16Ã—16 patch sequences, why CLIP can search images with text, and why resolution quadruples compute cost. This note gives you that working knowledge.

---

## â˜… TL;DR

- **What**: The core concepts behind image understanding â€” CNNs, Vision Transformers, CLIP, detection, segmentation â€” that every GenAI builder needs
- **Why**: Modern AI is multimodal. GPT-4o, Gemini, and Claude all process images. Understanding how pixels become representations is now a core GenAI skill.
- **Key point**: Vision models turn pixel arrays into semantic embeddings. Those embeddings are then used for classification, retrieval, generation, or as input to language models.

---

## â˜… Overview

### Definition

**Computer vision (CV)** is the field of enabling machines to interpret and reason about visual data â€” images, video, documents, and 3D scenes.

### Scope

Covers: Core CV tasks, how images become representations, CNN vs ViT architectures, CLIP and contrastive learning, practical code for image classification and similarity search. For text-to-image generation, see [Diffusion Models](./diffusion-models.md). For the broader multimodal landscape, see [Multimodal AI](./multimodal-ai.md).

### Significance

- **Multimodal is the default**: GPT-4o, Gemini 2.5, Claude 3.5 â€” all flagship models process images natively. Vision is no longer a separate field.
- **Production use cases**: Document understanding, visual search, screenshot-aware assistants, product image analysis, medical imaging, autonomous systems
- **Interview relevance**: System design interviews increasingly include visual components ("design an image search system", "how does a multimodal model process screenshots?")

### Prerequisites

- [Multimodal AI](./multimodal-ai.md) â€” the bigger picture
- [Embeddings](../foundations/embeddings.md) â€” vector representations
- [Modern Architectures](../foundations/modern-architectures.md) â€” transformer fundamentals

---

## â˜… Deep Dive

### Core Vision Tasks

```
INPUT: Image (H Ã— W Ã— C pixel array)
         â”‚
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   VISION TASKS                            â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                           â”‚
â”‚  CLASSIFICATION        "This is a cat"                    â”‚
â”‚  Image â†’ single label                                    â”‚
â”‚                                                           â”‚
â”‚  DETECTION            "Cat at (x1,y1,x2,y2)"            â”‚
â”‚  Image â†’ bounding boxes + labels                         â”‚
â”‚                                                           â”‚
â”‚  SEGMENTATION         "These pixels are cat"             â”‚
â”‚  Image â†’ per-pixel labels                                â”‚
â”‚                                                           â”‚
â”‚  OCR / DOCUMENT AI    "Invoice #1234, Total: $500"       â”‚
â”‚  Image â†’ structured text extraction                      â”‚
â”‚                                                           â”‚
â”‚  IMAGE-TEXT MATCHING   "How similar is this image         â”‚
â”‚  (CLIP, SigLIP)        to 'a sunset over mountains'?"   â”‚
â”‚                                                           â”‚
â”‚  VISUAL QA            "How many people are in             â”‚
â”‚  (VLMs)                this photo?" â†’ "Three"             â”‚
â”‚                                                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

| Task | Input | Output | Key Models (2026) |
|------|-------|--------|-------------------|
| **Classification** | Image | Label(s) + confidence | ViT, EfficientNet, ConvNeXt |
| **Object Detection** | Image | Bounding boxes + labels | YOLO v9/v10, DETR, RT-DETR |
| **Segmentation** | Image | Per-pixel mask | SAM 2, Mask2Former |
| **OCR / Document AI** | Image | Structured text | PaddleOCR, Tesseract, DocTR |
| **Image-Text Matching** | Image + Text | Similarity score | CLIP, SigLIP, EVA-CLIP |
| **Visual QA** | Image + Question | Answer text | GPT-4o, Gemini, LLaVA |

### From Pixels to Representations

```
RAW IMAGE                    FEATURE EXTRACTION              SEMANTIC EMBEDDING
                           
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”            â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ â–‘â–‘â–“â–“â–ˆâ–ˆâ–‘â–‘â–“â–“â–ˆâ–ˆ  â”‚          â”‚  Edges â†’ Shapes  â”‚            â”‚ [0.23, -0.1, â”‚
â”‚ â–‘â–‘â–“â–“â–ˆâ–ˆâ–‘â–‘â–“â–“â–ˆâ–ˆ  â”‚  â”€CNNâ”€â–º  â”‚  Shapes â†’ Parts  â”‚  â”€Poolâ”€â–º   â”‚  0.87, 0.45, â”‚
â”‚ â–ˆâ–ˆâ–‘â–‘â–“â–“â–ˆâ–ˆâ–‘â–‘â–“â–“  â”‚  or ViT  â”‚  Parts â†’ Objects â”‚            â”‚  ..., -0.33] â”‚
â”‚ â–ˆâ–ˆâ–‘â–‘â–“â–“â–ˆâ–ˆâ–‘â–‘â–“â–“  â”‚          â”‚  Objects â†’ Scene â”‚            â”‚              â”‚
â”‚                â”‚          â”‚                  â”‚            â”‚  768-dim vec  â”‚
â”‚ HÃ—WÃ—3 tensor   â”‚          â”‚  Feature maps    â”‚            â”‚              â”‚
â”‚ (e.g. 224Ã—224Ã—3)â”‚         â”‚                  â”‚            â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
        â”‚                                                          â”‚
        â”‚              Resolution matters:                          â”‚
        â”‚              224Ã—224 = 150K pixels                        â”‚
        â”‚              512Ã—512 = 786K pixels (5Ã— more compute)     â”‚
        â”‚              1024Ã—1024 = 3.1M pixels (20Ã— more compute)  â”‚
```

### CNN vs Vision Transformer (ViT)

| Aspect | CNN (ConvNet) | Vision Transformer (ViT) |
|--------|:-------------|:------------------------|
| **How it works** | Slides learned filters across image, building local â†’ global features | Splits image into patches, treats each as a "token", processes with transformer |
| **Key operation** | Convolution (local receptive field) | Self-attention (global receptive field) |
| **Inductive bias** | Translation invariance, locality | Minimal â€” learns spatial relationships from data |
| **Data efficiency** | Better with small datasets (built-in priors) | Needs large datasets or pretraining |
| **Scale behavior** | Diminishing returns past ~500M params | Scales well to billions of parameters |
| **Integration with LLMs** | Requires adapter/projection layer | Natural fit â€” same architecture family |
| **Current status** | Still excellent for edge/mobile (EfficientNet, MobileNet) | Dominant for research and multimodal (ViT, SigLIP) |

**How ViT works (the key idea)**:

```
Image (224Ã—224)
      â”‚
      â–¼
Split into patches: 14Ã—14 grid of 16Ã—16 pixel patches = 196 patches
      â”‚
      â–¼
Flatten each patch: 16Ã—16Ã—3 = 768 values per patch
      â”‚
      â–¼
Linear projection: 768 â†’ D (embedding dimension)
      â”‚
      â–¼
Add position embeddings: Tell the model where each patch is
      â”‚
      â–¼
Prepend [CLS] token: Will hold the aggregate image representation
      â”‚
      â–¼
Process through Transformer encoder (same as BERT/GPT!)
      â”‚
      â–¼
[CLS] output = image embedding (768-dim or 1024-dim vector)
```

**Why this matters for GenAI builders**: ViT produces patch-level and image-level embeddings that can be directly consumed by language models. This is how multimodal models like LLaVA and GPT-4o work â€” a ViT encodes the image, a projection layer maps visual tokens into the LLM's embedding space, and the LLM processes visual + text tokens together.

### CLIP: The Bridge Between Vision and Language

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                     CLIP ARCHITECTURE                         â”‚
â”‚                                                               â”‚
â”‚   IMAGE                              TEXT                     â”‚
â”‚   "photo of a cat"                   "a photo of a cat"      â”‚
â”‚        â”‚                                   â”‚                  â”‚
â”‚        â–¼                                   â–¼                  â”‚
â”‚   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”            â”‚
â”‚   â”‚  Image   â”‚                       â”‚  Text    â”‚            â”‚
â”‚   â”‚  Encoder â”‚                       â”‚  Encoder â”‚            â”‚
â”‚   â”‚  (ViT)   â”‚                       â”‚ (Transf) â”‚            â”‚
â”‚   â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜                       â””â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜            â”‚
â”‚        â”‚                                   â”‚                  â”‚
â”‚        â–¼                                   â–¼                  â”‚
â”‚   [Image Embedding]              [Text Embedding]            â”‚
â”‚   768-dim vector                 768-dim vector               â”‚
â”‚        â”‚                                   â”‚                  â”‚
â”‚        â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                  â”‚
â”‚                    â–¼   â–¼                                      â”‚
â”‚              Cosine Similarity                                â”‚
â”‚              (maximize for matching pairs)                    â”‚
â”‚                                                               â”‚
â”‚   Training: 400M image-text pairs from the internet          â”‚
â”‚   Result: Shared embedding space for images AND text         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜

What CLIP enables:
  - Zero-shot image classification (no task-specific training!)
  - Image search with natural language queries
  - Image-text similarity scoring
  - Foundation for multimodal models (LLaVA, etc.)
```

### How Multimodal LLMs Process Images

```
The architecture behind GPT-4o / Gemini / LLaVA:

Image â”€â”€â–º [Vision Encoder (ViT)] â”€â”€â–º [Projection Layer] â”€â”€â–º Visual Tokens
                                                                â”‚
                                                          â”Œâ”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”
                                                          â”‚           â”‚
Text  â”€â”€â–º [Tokenizer] â”€â”€â–º Text Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º â”‚    LLM    â”‚
                                                          â”‚  Decoder  â”‚
                                                          â”‚           â”‚
                                                          â””â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”˜
                                                                â”‚
                                                          Generated Text

Key insight: The vision encoder produces "visual tokens" that are
concatenated with text tokens. The LLM processes them together.

Image tokens per image (examples):
  - LLaVA: 576 tokens (24Ã—24 grid)
  - GPT-4o: ~170 tokens (low detail) to ~1105 tokens (high detail)
  - Gemini: Variable, up to ~3000 tokens

More tokens = better detail but higher cost and latency
```

### Object Detection & Segmentation (Quick Tour)

| Model Family | Task | Speed | Key Innovation |
|-------------|------|:-----:|----------------|
| **YOLO v9/v10** | Detection | âš¡ Real-time (< 10ms) | Single-pass prediction, optimized for edge |
| **RT-DETR** | Detection | âš¡ Real-time | Transformer-based, no NMS needed |
| **DETR** | Detection | ðŸ¢ Slower | End-to-end transformer detection |
| **SAM 2** (Meta) | Segmentation | âš¡ Fast | Segment anything â€” zero-shot, prompt-based |
| **Mask2Former** | Segmentation | ðŸ¢ Medium | Unified architecture for all segmentation types |

---

## â˜… Code & Implementation

### Image Classification with a Pretrained ViT

```python
# pip install transformers>=4.40 torch>=2.0 pillow>=10.0
# âš ï¸ Last tested: 2026-04 | Requires: transformers>=4.40

from transformers import ViTForImageClassification, ViTImageProcessor
from PIL import Image
import torch

# Load pretrained ViT (ImageNet-21k â†’ ImageNet-1k fine-tuned)
model_name = "google/vit-base-patch16-224"
processor = ViTImageProcessor.from_pretrained(model_name)
model = ViTForImageClassification.from_pretrained(model_name)

# Classify an image
image = Image.open("photo.jpg")  # Any image
inputs = processor(images=image, return_tensors="pt")

with torch.no_grad():
    outputs = model(**inputs)
    logits = outputs.logits
    predicted_class = logits.argmax(-1).item()

label = model.config.id2label[predicted_class]
confidence = torch.softmax(logits, dim=-1).max().item()
print(f"Prediction: {label} ({confidence:.1%})")

# Expected output: Prediction: golden_retriever (94.3%)
```

### Zero-Shot Image Classification with CLIP

```python
# pip install transformers>=4.40 torch>=2.0 pillow>=10.0
# âš ï¸ Last tested: 2026-04 | Requires: transformers>=4.40

from transformers import CLIPModel, CLIPProcessor
from PIL import Image
import torch

# Load CLIP
model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

# Zero-shot classification â€” no training needed!
image = Image.open("product.jpg")
candidate_labels = [
    "a photograph of a laptop",
    "a photograph of a coffee mug",
    "a photograph of a smartphone",
    "a photograph of a book",
]

inputs = processor(
    text=candidate_labels,
    images=image,
    return_tensors="pt",
    padding=True,
)

with torch.no_grad():
    outputs = model(**inputs)
    probs = outputs.logits_per_image.softmax(dim=1)[0]

for label, prob in sorted(zip(candidate_labels, probs), key=lambda x: -x[1]):
    print(f"  {prob:.1%}  {label}")

# Expected output:
#   72.3%  a photograph of a laptop
#   15.1%  a photograph of a smartphone
#    8.2%  a photograph of a book
#    4.4%  a photograph of a coffee mug
```

### Image Similarity Search (Visual Retrieval)

```python
# pip install transformers>=4.40 torch>=2.0 pillow>=10.0 numpy>=1.24
# âš ï¸ Last tested: 2026-04 | Requires: transformers>=4.40

from transformers import CLIPModel, CLIPProcessor
from PIL import Image
import torch
import numpy as np

model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

def get_image_embedding(image_path: str) -> np.ndarray:
    """Get CLIP image embedding for similarity search."""
    image = Image.open(image_path)
    inputs = processor(images=image, return_tensors="pt")
    with torch.no_grad():
        embedding = model.get_image_features(**inputs)
    # Normalize for cosine similarity
    embedding = embedding / embedding.norm(dim=-1, keepdim=True)
    return embedding.numpy()[0]

def get_text_embedding(text: str) -> np.ndarray:
    """Get CLIP text embedding for cross-modal search."""
    inputs = processor(text=[text], return_tensors="pt", padding=True)
    with torch.no_grad():
        embedding = model.get_text_features(**inputs)
    embedding = embedding / embedding.norm(dim=-1, keepdim=True)
    return embedding.numpy()[0]

# Build a visual search index
image_paths = ["img1.jpg", "img2.jpg", "img3.jpg"]
embeddings = np.array([get_image_embedding(p) for p in image_paths])

# Search with text query (cross-modal!)
query = "a red sports car on a highway"
query_emb = get_text_embedding(query)

# Cosine similarity (embeddings are already normalized)
similarities = embeddings @ query_emb
best_match_idx = similarities.argmax()
print(f"Best match: {image_paths[best_match_idx]} (similarity: {similarities[best_match_idx]:.3f})")

# Expected output: Best match: img2.jpg (similarity: 0.312)
# In production, use a vector DB (Pinecone, Qdrant) for scale
```

---

## â—† Quick Reference

```
CV TASK DECISION GUIDE:
  "What is in this image?"              â†’ Classification (ViT, EfficientNet)
  "Where are the objects?"              â†’ Detection (YOLO, RT-DETR)
  "Which pixels belong to what?"        â†’ Segmentation (SAM 2, Mask2Former)
  "What does this document say?"        â†’ OCR (PaddleOCR, DocTR)
  "Find images similar to this text"    â†’ CLIP / SigLIP embedding search
  "Answer questions about this image"   â†’ VLM (GPT-4o, Gemini, LLaVA)

RESOLUTION vs COMPUTE TRADE-OFF:
  224Ã—224:   Baseline (1Ã—) â€” standard classification
  384Ã—384:   2.9Ã— compute â€” better detail, common for ViT-L
  512Ã—512:   5.3Ã— compute â€” detection / segmentation
  1024Ã—1024: 21Ã— compute  â€” high-res analysis

MODEL SIZE REFERENCE (ViT family):
  ViT-B/16:   86M params, 768-dim embedding
  ViT-L/14:  304M params, 1024-dim embedding
  ViT-H/14:  632M params, 1280-dim embedding
  EVA-CLIP:    1B+ params, SOTA image-text alignment
```

---

## â—† Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Resolution mismatch** | Model misses small objects or text | Input resized to 224Ã—224, crushing fine detail | Use higher resolution models (384/512), or tile + merge strategy |
| **Domain shift** | High accuracy on ImageNet, poor on real data | Training data distribution â‰  production data (medical, industrial, satellite) | Fine-tune on domain-specific data, even 500-1000 images helps significantly |
| **CLIP hallucination** | High similarity score for wrong matches | CLIP latches onto spurious correlations (color, texture) | Use as retrieval + rerank pipeline, not sole decision maker |
| **Aspect ratio distortion** | Stretched/squished images produce wrong features | Naive resize to square causes information loss | Use padding/letterboxing, or models that handle variable aspect ratios |
| **OCR on stylized text** | Fails on handwriting, unusual fonts, curved text | OCR models trained primarily on printed text | Use specialized models (TrOCR for handwriting), or VLMs (GPT-4o) |

---

## â—‹ Gotchas & Common Mistakes

- âš ï¸ **High ImageNet accuracy â‰  production robustness**: A model with 90% on ImageNet may fail spectacularly on your specific photos (different lighting, angles, backgrounds).
- âš ï¸ **Resolution is the hidden cost multiplier**: Going from 224â†’512 resolution increases compute ~5Ã— and memory ~5Ã—. Budget this explicitly.
- âš ï¸ **CLIP is powerful but not precise**: CLIP excels at broad semantic matching but struggles with fine-grained distinctions ("two cats" vs "three cats"). Don't use it for counting or spatial reasoning.
- âš ï¸ **OCR â‰  document understanding**: Extracting text (OCR) is different from understanding layout and relationships (Document AI). Don't confuse them.
- âš ï¸ **Vision tokens are expensive in VLMs**: A single image in GPT-4o costs 85-1105 tokens. Processing 10 images per request can cost more than the text portion.

---

## â—‹ Interview Angles

- **Q**: Why are Vision Transformers important for multimodal AI?
- **A**: ViTs convert images into sequences of patch embeddings using the same transformer architecture as language models. This architectural alignment is what makes multimodal models possible â€” you can project visual patch tokens into the same embedding space as text tokens, concatenate them, and let a single transformer process both modalities together. This is exactly how models like LLaVA and GPT-4o work: a ViT encodes the image into visual tokens, a projection layer maps them into the LLM's space, and the LLM attends to both visual and text tokens. Before ViTs, integrating CNNs with transformers required more complex adapter architectures.

- **Q**: How does CLIP enable zero-shot image classification?
- **A**: CLIP trains a shared embedding space for images and text using contrastive learning on 400M image-text pairs from the internet. During training, matching image-text pairs are pulled together in embedding space while non-matching pairs are pushed apart. At inference, you encode the image with the vision encoder and encode candidate class descriptions ("a photo of a dog", "a photo of a cat") with the text encoder. The class whose text embedding is most similar to the image embedding is the prediction. No task-specific training needed â€” any text description works as a class label. The limitation is that CLIP's accuracy is lower than fine-tuned models on specific benchmarks, but its flexibility is unmatched.

- **Q**: Design an image search system for an e-commerce platform.
- **A**: I'd build a two-stage retrieval + reranking pipeline. Stage 1: Use CLIP (or SigLIP) to encode all product images into embeddings, stored in a vector database (Qdrant or Pinecone). User queries (text or uploaded image) are encoded with the same model, and top-100 candidates retrieved by cosine similarity. Stage 2: A cross-encoder reranker (or VLM) scores each candidate for relevance, considering product metadata (category, price, availability). The embedding would update nightly via batch pipeline. For latency: embedding lookup < 50ms, reranking < 200ms. For cost: CLIP encoding is ~$0.001/image. I'd also add a feedback loop â€” user clicks improve the reranker over time.

---

## â—† Hands-On Exercises

### Exercise 1: Zero-Shot Image Classification

**Goal**: Classify images into custom categories without any training
**Time**: 30 minutes
**Steps**:
1. Load CLIP using the code above
2. Choose 5 images from different categories (food, animals, landscapes, tech, fashion)
3. Define 10 candidate text labels
4. Run zero-shot classification on all 5 images
5. Evaluate: which misclassifications occur? Why?
**Expected Output**: Accuracy table, analysis of failure cases (CLIP confusion patterns)

### Exercise 2: Build a Visual Search Engine

**Goal**: Build a text-to-image search over a local image collection
**Time**: 45 minutes
**Steps**:
1. Collect 50 images (or use CIFAR-10 sample)
2. Encode all images with CLIP into a numpy matrix
3. Implement text-query search: encode query â†’ cosine similarity â†’ top-5 results
4. Test with 5 queries: one precise ("red car"), one abstract ("peaceful"), one misleading
5. Evaluate retrieval quality â€” how does query specificity affect results?
**Expected Output**: Working search system, quality analysis by query type

---

## â˜… Connections

| Relationship | Topics |
|---|---|
| Builds on | [Multimodal AI](./multimodal-ai.md), [Embeddings](../foundations/embeddings.md), [Modern Architectures](../foundations/modern-architectures.md) |
| Leads to | [Diffusion Models](./diffusion-models.md) (image generation), Document AI, Visual search systems |
| Compare with | Pure text NLP (no visual grounding), Traditional CV (pre-deep-learning, feature engineering) |
| Cross-domain | Robotics (perception), Medical imaging (radiology AI), Autonomous driving, Industrial inspection |

---

## â˜… Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| ðŸŽ“ Course | [Stanford CS231n: Deep Learning for Computer Vision](http://cs231n.stanford.edu/) | The definitive CV course â€” CNNs, detection, segmentation, attention. Watch the lectures. |
| ðŸ“„ Paper | [Dosovitskiy et al. "An Image is Worth 16Ã—16 Words" (ViT, 2020)](https://arxiv.org/abs/2010.11929) | The paper that launched Vision Transformers. Section 3 explains the patch embedding mechanism. |
| ðŸ“„ Paper | [Radford et al. "Learning Transferable Visual Models" (CLIP, 2021)](https://arxiv.org/abs/2103.00020) | How contrastive learning creates a shared vision-language embedding space |
| ðŸ”§ Hands-on | [HuggingFace Vision Transformers Tutorial](https://huggingface.co/docs/transformers/model_doc/vit) | Practical guide to using ViT for classification, feature extraction, and fine-tuning |
| ðŸ“„ Paper | [Kirillov et al. "Segment Anything" (SAM, 2023)](https://arxiv.org/abs/2304.02643) | Zero-shot segmentation â€” the CLIP of pixel-level vision |
| ðŸŽ¥ Video | [Yannic Kilcher â€” "CLIP: Connecting Text and Images"](https://www.youtube.com/watch?v=T9XSU0pKX2E) | Excellent visual explanation of contrastive learning and CLIP architecture |
| ðŸ“˜ Book | "Deep Learning for Vision Systems" by Elgendy (2020) | Practical introduction to CV with Python â€” good for building intuition |

---

## â˜… Sources

- Dosovitskiy et al. "An Image is Worth 16Ã—16 Words: Transformers for Image Recognition at Scale" (2020)
- Radford et al. "Learning Transferable Visual Models From Natural Language Supervision" (CLIP, 2021)
- Kirillov et al. "Segment Anything" (SAM, 2023)
- Stanford CS231n Lecture Notes â€” http://cs231n.stanford.edu/
- HuggingFace Transformers Documentation â€” https://huggingface.co/docs/transformers/
- [Multimodal AI](./multimodal-ai.md)
