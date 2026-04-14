---
title: "Document Parsing & Extraction"
tags: [document-parsing, pdf, ocr, extraction, rag, chunking, production]
type: procedure
difficulty: intermediate
status: published
last_verified: 2026-04
parent: "[[llmops]]"
related: ["[[../techniques/rag]]", "[[../techniques/context-engineering]]", "[[../tools-and-infra/vector-databases]]"]
source: "Multiple — see Sources"
created: 2026-04-14
updated: 2026-04-14
---

# Document Parsing & Extraction

> ✨ **Bit**: RAG is only as good as its parsed documents. If your PDF parser turns a table into gibberish or loses headings, no embedding model or LLM can recover that information. Document parsing is the unglamorous foundation that makes or breaks retrieval quality.

---

## ★ TL;DR

- **What**: The pipeline for extracting structured text from unstructured documents (PDFs, Word, HTML, scans) for use in RAG and AI systems
- **Why**: 90% of enterprise data lives in documents. Poor parsing → poor chunks → poor retrieval → hallucinations. Garbage in, garbage out.
- **Key point**: There is no universal document parser. Choose your parser based on document type (text PDF, scanned PDF, tables, multi-column layouts) and test on real samples from your data.

---

## ★ Overview

### Definition

**Document parsing** converts unstructured documents (PDFs, DOCX, HTML, images) into clean, structured text suitable for chunking and embedding in RAG pipelines.

### Scope

Covers: Parsing strategies for common document types, chunking approaches, table extraction, OCR for scanned documents, and production code. For retrieval architecture, see [RAG](../techniques/rag.md).

### Prerequisites

- [RAG](../techniques/rag.md) — retrieval pipeline this feeds into
- [Embeddings](../foundations/embeddings.md) — how parsed text gets vectorized

---

## ★ Deep Dive

### The Document Parsing Pipeline

```
RAW DOCUMENTS (PDF, DOCX, HTML, images)
     │
     ▼
┌──────────────────────────────────────┐
│  1. FORMAT DETECTION                  │
│     What type of document is this?    │
│     Text PDF? Scanned? Table-heavy?   │
└───────────────┬──────────────────────┘
                │
                ▼
┌──────────────────────────────────────┐
│  2. TEXT EXTRACTION                   │
│     Text PDF → PyMuPDF, pdfplumber   │
│     Scanned  → OCR (Tesseract, etc.) │
│     DOCX     → python-docx           │
│     HTML     → BeautifulSoup         │
└───────────────┬──────────────────────┘
                │
                ▼
┌──────────────────────────────────────┐
│  3. STRUCTURE PRESERVATION           │
│     Keep headings, lists, tables     │
│     Maintain section hierarchy       │
│     Preserve metadata (page, source) │
└───────────────┬──────────────────────┘
                │
                ▼
┌──────────────────────────────────────┐
│  4. CHUNKING                         │
│     Split into retrieval-sized pieces│
│     Respect section boundaries       │
│     Add overlap for continuity       │
└───────────────┬──────────────────────┘
                │
                ▼
┌──────────────────────────────────────┐
│  5. METADATA ENRICHMENT              │
│     Source file, page number         │
│     Section heading, document title  │
│     Chunk index, overlap info        │
└──────────────────────────────────────┘
                │
                ▼
           EMBED & INDEX
```

### Parser Selection Guide

| Document Type | Best Parser | Fallback | Accuracy |
|--------------|------------|----------|:--------:|
| **Text PDF** (digital) | PyMuPDF (fitz), pdfplumber | PyPDF2 | High |
| **Scanned PDF** (images) | Tesseract + layout detection | Cloud OCR APIs | Medium |
| **Tables in PDF** | pdfplumber, Camelot | LLM-based extraction | Medium |
| **DOCX / Word** | python-docx | mammoth | High |
| **HTML / Web** | BeautifulSoup, markdownify | trafilatura | High |
| **Complex layouts** | Unstructured.io, DocTR | LlamaParse | Medium-High |

### Chunking Strategies

| Strategy | How It Works | Best For | Chunk Size |
|----------|-------------|----------|:----------:|
| **Fixed-size** | Split every N tokens with overlap | Simple documents | 200-500 tokens |
| **Recursive** | Split by paragraph → sentence → token | General purpose | 200-1000 tokens |
| **Semantic** | Split at topic boundaries using embeddings | Long documents | Variable |
| **Document-aware** | Split at section headings | Structured docs | Section-sized |
| **Sliding window** | Overlapping windows across text | Dense technical docs | 300-500 tokens |

---

## ★ Code & Implementation

### Production Document Parsing Pipeline

```python
# pip install pymupdf>=1.24 pdfplumber>=0.11 langchain-text-splitters>=0.3
# ⚠️ Last tested: 2026-04 | Requires: pymupdf>=1.24

import fitz  # PyMuPDF
import pdfplumber
from dataclasses import dataclass

@dataclass
class ParsedChunk:
    content: str
    metadata: dict  # source, page, section, chunk_index

def parse_pdf(file_path: str, method: str = "pymupdf") -> list[dict]:
    """Extract text from PDF with metadata."""
    pages = []
    
    if method == "pymupdf":
        doc = fitz.open(file_path)
        for i, page in enumerate(doc):
            text = page.get_text("text")
            pages.append({"text": text, "page": i + 1, "source": file_path})
        doc.close()
    
    elif method == "pdfplumber":
        with pdfplumber.open(file_path) as pdf:
            for i, page in enumerate(pdf.pages):
                text = page.extract_text() or ""
                # Also extract tables
                tables = page.extract_tables()
                table_text = ""
                for table in tables:
                    for row in table:
                        table_text += " | ".join(str(cell or "") for cell in row) + "\n"
                pages.append({
                    "text": text,
                    "tables": table_text,
                    "page": i + 1,
                    "source": file_path,
                })
    
    return pages

def chunk_document(
    pages: list[dict],
    chunk_size: int = 400,
    chunk_overlap: int = 50,
) -> list[ParsedChunk]:
    """Chunk parsed pages into retrieval-sized pieces."""
    from langchain_text_splitters import RecursiveCharacterTextSplitter
    
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        separators=["\n\n", "\n", ". ", " ", ""],
    )
    
    chunks = []
    for page in pages:
        text = page["text"]
        if page.get("tables"):
            text += "\n\n[TABLE]\n" + page["tables"]
        
        splits = splitter.split_text(text)
        for j, split in enumerate(splits):
            chunks.append(ParsedChunk(
                content=split.strip(),
                metadata={
                    "source": page["source"],
                    "page": page["page"],
                    "chunk_index": j,
                    "total_chunks": len(splits),
                },
            ))
    
    return [c for c in chunks if len(c.content) > 20]  # Filter empty chunks

# Usage
pages = parse_pdf("report.pdf", method="pdfplumber")
chunks = chunk_document(pages, chunk_size=400, chunk_overlap=50)
print(f"Parsed {len(pages)} pages into {len(chunks)} chunks")
for chunk in chunks[:3]:
    print(f"  Page {chunk.metadata['page']}, chunk {chunk.metadata['chunk_index']}: "
          f"{chunk.content[:80]}...")
# Expected: Clean chunks with preserved metadata for RAG indexing
```

---

## ◆ Production Failure Modes

| Failure | Symptoms | Root Cause | Mitigation |
|---------|----------|------------|------------|
| **Table extraction failure** | RAG can't answer table-based questions | PDF tables extracted as garbled text | Use pdfplumber for tables, or LLM-based table extraction |
| **Lost document structure** | Chunks span unrelated sections | Parser ignores headings, splits mid-section | Use document-aware chunking that respects section boundaries |
| **OCR errors** | Misspelled words, wrong numbers | Scanned PDF with low resolution or poor scan quality | Pre-process images, use higher-quality OCR (Cloud Vision, DocTR) |
| **Chunk too big / too small** | Retrieval misses or returns irrelevant content | Fixed chunk size doesn't match document structure | Tune chunk size per document type, use semantic chunking |

---

## ○ Interview Angles

- **Q**: How would you build a document processing pipeline for a RAG system?
- **A**: I'd build a 5-stage pipeline. (1) Format detection to route PDFs, DOCX, HTML to appropriate parsers. (2) Text extraction — PyMuPDF for digital PDFs, pdfplumber for table-heavy PDFs, Tesseract+layout detection for scans. (3) Structure preservation — keep headings, lists, and table structure using markdown formatting. (4) Document-aware chunking — split at section boundaries with 200-500 token chunks and 50-token overlap, keeping section headers as metadata. (5) Metadata enrichment — attach source file, page number, section heading to each chunk. I'd evaluate quality by sampling 50 chunks and manually checking if they preserve the meaning of the original content.

---

## ◆ Hands-On Exercises

### Exercise 1: Compare PDF Parsers

**Goal**: Evaluate parsing quality across 3 tools
**Time**: 30 minutes
**Steps**:
1. Pick a complex PDF with tables, headers, and multi-column layout
2. Parse with PyMuPDF, pdfplumber, and Unstructured.io
3. Compare: text quality, table accuracy, structure preservation
4. Chunk the best output and manually verify 10 chunks
**Expected Output**: Parser comparison matrix with quality scores

---

## ★ Connections

| Relationship | Topics |
|---|---|
| Builds on | [RAG](../techniques/rag.md), [Embeddings](../foundations/embeddings.md) |
| Leads to | [Retrieval Evaluation](../evaluation/retrieval-evaluation.md), production RAG pipelines |
| Compare with | LLM-based document understanding (GPT-4V for visual docs) |
| Cross-domain | Document management, ETL pipelines, OCR |

---

## ★ Recommended Resources

| Type | Resource | Why |
|------|----------|-----|
| 🔧 Hands-on | [Unstructured.io](https://unstructured.io/) | Best multi-format document parsing framework |
| 🔧 Hands-on | [LlamaParse](https://cloud.llamaindex.ai/) | LLM-powered document parsing API |
| 🔧 Hands-on | [pdfplumber](https://github.com/jsvine/pdfplumber) | Best open-source PDF table extraction |
| 📘 Book | "AI Engineering" by Chip Huyen (2025), Ch 3 | Document processing for RAG pipelines |

---

## ★ Sources

- PyMuPDF Documentation — https://pymupdf.readthedocs.io/
- pdfplumber Documentation — https://github.com/jsvine/pdfplumber
- Unstructured.io — https://unstructured.io/
- [RAG](../techniques/rag.md)
