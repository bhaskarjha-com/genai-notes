# Techniques

> Prompting, RAG, fine-tuning, function calling, context engineering, and adaptation methods.

## Notes in This Directory

| Note | Difficulty | Description |
|------|:----------:|-------------|
| [Advanced Fine-Tuning for LLM Adaptation](advanced-fine-tuning.md) | Expert | Fine-tuning techniques beyond standard SFT - preference optimization (DPO, ORPO, KTO), RL-style training (GRPO, PPO), continued pretraining, and efficient training stacks (QLoRA, Unsloth) |
| [Context Engineering & Long Context](context-engineering.md) | Intermediate | The art and science of deciding WHAT information goes into an LLM's context window, and using long context + caching to do it efficiently |
| [Continual Learning & Lifelong AI](continual-learning.md) | Advanced | Training AI models to learn new knowledge/tasks without forgetting what they already know |
| [Knowledge Distillation & Model Compression](distillation-and-compression.md) | Advanced | Techniques to create smaller, faster, cheaper models that retain the capabilities of larger ones |
| [Embedding Fine-Tuning](embedding-fine-tuning.md) | Advanced | Training or adapting embedding models on domain-specific data to improve retrieval quality for RAG and search systems |
| [Fine-Tuning LLMs](fine-tuning.md) | Advanced | Adapting a pre-trained LLM's weights on your specific data to change its behavior, style, or domain expertise |
| [Function Calling, Structured Output & Tool Use](function-calling-and-structured-output.md) | Intermediate | Mechanisms for LLMs to (1) call external functions/APIs and (2) return data in strict schemas (JSON, Pydantic) |
| [Graph RAG & Advanced Retrieval](graph-rag.md) | Advanced | RAG enhanced with knowledge graphs for structured reasoning and multi-hop retrieval |
| [Long-Context Engineering](long-context-engineering.md) | Advanced | Techniques for effectively using large context windows (128K-2M tokens) - structuring input, managing retrieval vs context stuffing, and handling the "lost in the middle" problem |
| [Prompt Engineering](prompt-engineering.md) | Beginner | Crafting inputs (prompts) to get desired outputs from LLMs without changing the model |
| [Retrieval-Augmented Generation (RAG)](rag.md) | Intermediate | A pattern that retrieves relevant external documents and feeds them to an LLM as context before generation |
| [Reinforcement Learning for LLM Alignment](rl-alignment.md) | Advanced | Techniques that align LLM behavior with human preferences using reinforcement learning or preference optimization |
| [Synthetic Data & Data Engineering for LLMs](synthetic-data-and-data-engineering.md) | Intermediate | Generating artificial training data using LLMs and curating/filtering real data for training |

---

For the full curriculum, see [LEARNING_PATH.md](../LEARNING_PATH.md).

