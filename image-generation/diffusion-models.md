---
title: "Diffusion Models"
tags: [diffusion, image-generation, stable-diffusion, dall-e, genai]
type: concept
difficulty: advanced
status: published
parent: "[[../genai]]"
related: ["[[../foundations/transformers]]", "[[../llms/llms-overview]]"]
source: "Ho et al., 2020 (DDPM) + latest developments"
created: 2026-03-18
updated: 2026-04-11
---

# Diffusion Models

> âœ¨ **Bit**: Diffusion models literally learn to un-destroy images â€” start with pure noise, progressively denoise until an image emerges. It's like teaching AI to reverse entropy.

---

## â˜… TL;DR

- **What**: Generative models that create images by learning to reverse a gradual noise-addition process
- **Why**: Surpassed GANs in image quality and stability. Power Stable Diffusion, DALL-E, Midjourney
- **Key point**: Forward process = add noise step by step until pure noise. Reverse process = learn to denoise step by step.

---

## â˜… Overview

### Definition

**Diffusion Models** (specifically Denoising Diffusion Probabilistic Models â€” DDPMs) are generative models that learn to generate data by reversing a gradual noising process. Training teaches the model to denoise slightly noisy images at each step; generation starts from pure noise and iteratively denoises.

### Scope

Covers diffusion model theory, architecture, and key models. For practical image generation tools, see individual model pages.

### Significance

- Replaced GANs as the dominant image generation architecture (2022+)
- Power: Stable Diffusion, DALL-E 2/3, Midjourney, Imagen
- Extended to: Video (Sora, Veo), Audio, 3D, and even molecular design
- More stable training than GANs (no mode collapse)

### Prerequisites

- [Transformers](../foundations/transformers.md) â€” U-Net and attention are used inside diffusion models
- Basic probability concepts

---

## â˜… Deep Dive

### The Core Idea

```
FORWARD PROCESS (Training â€” add noise):

  Clean Image â†’ Slightly Noisy â†’ More Noisy â†’ ... â†’ Pure Gaussian Noise
  xâ‚€           xâ‚               xâ‚‚              xâ‚œ

  Each step: xâ‚œ = âˆš(Î±â‚œ)Â·xâ‚œâ‚‹â‚ + âˆš(1-Î±â‚œ)Â·Îµ    (Îµ ~ Normal(0,1))

REVERSE PROCESS (Generation â€” remove noise):

  Pure Noise â†’ Slightly Less Noisy â†’ ... â†’ Clean Image!
  xâ‚œ          xâ‚œâ‚‹â‚                    xâ‚€

  The model learns: "Given noisy image xâ‚œ, predict the noise Îµ"
  Then subtract that predicted noise to get xâ‚œâ‚‹â‚

                      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€ FORWARD (destroy) â”€â”€â”€â”€â”€â”€â”€â”€â”
                      â”‚                                    â”‚
  [Clean Image] â†’ [Noisy] â†’ [Noisier] â†’ ... â†’ [Pure Noise]
  [Clean Image] â† [Noisy] â† [Noisier] â† ... â† [Pure Noise]
                      â”‚                                    â”‚
                      â””â”€â”€â”€â”€â”€â”€â”€â”€ REVERSE (create) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Architecture: U-Net + Attention

```
Diffusion Model Architecture:

  Noisy Image â”€â”€â–º [U-Net with Attention] â”€â”€â–º Predicted Noise
       +
  Time Step t  â”€â”€â–º (embedded and injected)
       +
  Text Prompt  â”€â”€â–º (cross-attention with text encoder output)

U-Net Structure:
  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
  â”‚ Encoder                           â”‚
  â”‚  â†“ Downsample + Attention blocks  â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚ Bottleneck (Attention)            â”‚
  â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
  â”‚ Decoder                           â”‚
  â”‚  â†‘ Upsample + Skip connections    â”‚
  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Text-to-Image Pipeline (Stable Diffusion)

```
"A cat astronaut on Mars"
    â”‚
    â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚ Text       â”‚    â”‚ Diffusion     â”‚    â”‚ VAE      â”‚
â”‚ Encoder    â”‚ â†’  â”‚ U-Net         â”‚ â†’  â”‚ Decoder  â”‚ â†’ Image!
â”‚ (CLIP)     â”‚    â”‚ (in latent    â”‚    â”‚ (latent  â”‚
â”‚            â”‚    â”‚  space, not   â”‚    â”‚  â†’ pixel)â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚  pixel space) â”‚    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                  Runs ~20-50 denoising steps
```

**Latent Diffusion** (the key innovation in Stable Diffusion): Instead of denoising in pixel space (512Ã—512Ã—3 = huge), work in a compressed latent space (64Ã—64Ã—4 = much smaller). Massively reduces compute.

### Key Concepts

| Concept                  | Explanation                                                                             |
| ------------------------ | --------------------------------------------------------------------------------------- |
| **Noise Schedule**       | How quickly noise is added (linear, cosine, etc.). Affects image quality.               |
| **Guidance Scale (CFG)** | How strongly to follow the text prompt. Higher = more prompt-adherent but less diverse. |
| **Sampling Steps**       | Number of denoising steps. More = better quality, slower. 20-50 is typical.             |
| **Negative Prompt**      | What to avoid: "blurry, low quality, distorted"                                         |
| **Inpainting**           | Replace part of an image (mask + prompt for new content)                                |
| **ControlNet**           | Add spatial control (pose, edges, depth maps) to guide generation                       |
| **LoRA (for images)**    | Train small adapters to add specific styles/characters to Stable Diffusion              |

### Major Models

| Model                     | Company           | Key Feature                                    |
| ------------------------- | ----------------- | ---------------------------------------------- |
| **Stable Diffusion XL/3** | Stability AI      | Open-source, customizable, LoRA ecosystem      |
| **DALL-E 3**              | OpenAI            | Integrated with ChatGPT, best prompt following |
| **Midjourney v6+**        | Midjourney        | Highest aesthetic quality, artistic            |
| **Imagen 3**              | Google            | Google's best, integrated in Gemini            |
| **Flux**                  | Black Forest Labs | Open, high quality, by ex-Stability AI team    |

---

## â—† Formulas & Equations

| Name                     | Formula                                                                                  | Variables                               | Use                      |
| ------------------------ | ---------------------------------------------------------------------------------------- | --------------------------------------- | ------------------------ |
| Forward Process          | $$q(x_t \mid x_{t-1}) = \mathcal{N}(x_t; \sqrt{\alpha_t}x_{t-1}, (1-\alpha_t)I)$$        | Î±â‚œ = noise schedule, I = identity       | Add noise at step t      |
| Training Objective       | $$L = \mathbb{E}_{t,x_0,\epsilon}\left[\|\epsilon - \epsilon_\theta(x_t, t)\|^2\right]$$ | Îµ = actual noise, Îµ_Î¸ = predicted noise | Train the denoiser       |
| Classifier-Free Guidance | $$\hat{\epsilon} = \epsilon_{uncond} + s(\epsilon_{cond} - \epsilon_{uncond})$$          | s = guidance scale (typically 7-15)     | Control prompt adherence |

---

## â—† Comparison

| Aspect              | Diffusion Models        | GANs                      | VAEs          |
| ------------------- | ----------------------- | ------------------------- | ------------- |
| **Training**        | Stable (MSE loss)       | Unstable (adversarial)    | Stable (ELBO) |
| **Quality**         | Excellent               | Excellent (when it works) | Blurry        |
| **Diversity**       | High (no mode collapse) | Mode collapse risk        | High          |
| **Speed**           | Slow (many steps)       | Fast (one forward pass)   | Fast          |
| **Controllability** | High (CFG, ControlNet)  | Limited                   | Limited       |
| **Status (2026)**   | **Dominant**            | Declining for images      | Niche         |

---

## â—† Strengths vs Limitations

| âœ… Strengths                                         | âŒ Limitations                                   |
| --------------------------------------------------- | ----------------------------------------------- |
| Best image quality currently                        | Slow generation (20-50 steps)                   |
| Stable training (no mode collapse)                  | High compute for training                       |
| Highly controllable (CFG, ControlNet, LoRA)         | Memory-intensive                                |
| Works in multiple domains (image, video, audio, 3D) | Theory is mathematically complex                |
| Strong open-source ecosystem (Stable Diffusion)     | Can reproduce copyrighted styles (legal issues) |

---

## â—‹ Interview Angles

- **Q**: How do diffusion models generate images?
- **A**: During training, the model learns to predict noise added to images at various levels. During generation, start from pure noise and iteratively denoise over many steps, guided by a text prompt using classifier-free guidance.

- **Q**: Why did diffusion models replace GANs?
- **A**: More stable training (no adversarial min-max game), no mode collapse, higher diversity, better controllability (CFG, ControlNet), and the quality caught up and surpassed GANs.

- **Q**: What is classifier-free guidance?
- **A**: During training, randomly drop the text condition. At inference, run both conditional and unconditional passes, then amplify the difference. This lets you control how strongly the model follows the prompt (guidance scale parameter).

---

## â˜… Connections

| Relationship | Topics                                                                    |
| ------------ | ------------------------------------------------------------------------- |
| Builds on    | [Transformers](../foundations/transformers.md) (attention in U-Net), VAEs (latent space) |
| Leads to     | Video generation (Sora), 3D generation, Audio diffusion                   |
| Compare with | GANs (adversarial), VAEs (variational), Autoregressive image models       |
| Cross-domain | Physics (thermodynamic diffusion), Stochastic processes                   |

---

## â˜… Sources

- Ho et al., "Denoising Diffusion Probabilistic Models" (DDPM, 2020)
- Rombach et al., "High-Resolution Image Synthesis with Latent Diffusion Models" (2022) â€” Stable Diffusion paper
- "The Illustrated Stable Diffusion" by Jay Alammar
- Stability AI documentation â€” https://stability.ai
