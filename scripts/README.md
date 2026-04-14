# Scripts

Utility scripts for maintaining and building the GenAI Notes repository.

## Available Scripts

| Script | Purpose | When to Run |
|--------|---------|-------------|
| `generate_learning_assets.ps1` | Regenerates all downloadable learning assets: Anki flashcard TSVs, progress checklists, topic-role matrix, knowledge graph data | After adding or modifying any note |
| `verify_repo.ps1` | Full repository verification: frontmatter validation, link checking, structure checks, and consistency tests | Before every commit |
| `check_links.ps1` | Checks all internal markdown links for broken references | After renaming, moving, or deleting files |
| `markdown_quality_check.ps1` | Lints markdown files for formatting, heading hierarchy, and style consistency | During content review |
| `check_freshness.ps1` | Flags notes with stale content based on `updated` frontmatter date. Fast-moving topics (agents, models, tools) flagged after 6 months; stable topics after 12 months | Monthly maintenance |
| `fix_mojibake.py` | Detects and fixes Unicode encoding issues (mojibake) in markdown files | One-time cleanup; run if encoding issues appear |

## Running Scripts

All scripts can be run from the repo root via the `Makefile`:

```bash
make verify         # Run full verification
make lint           # Markdown quality checks
make check-links    # Broken link detection
make check-freshness # Stale content detection
make generate       # Regenerate learning assets
```

Or directly via PowerShell:

```powershell
pwsh scripts/verify_repo.ps1
pwsh scripts/check_freshness.ps1
```

## Requirements

- **PowerShell Core** (`pwsh`) — cross-platform, v7.0+
- **Python 3.10+** — for `fix_mojibake.py` only
- **mkdocs** — installed via `requirements-docs.txt`
