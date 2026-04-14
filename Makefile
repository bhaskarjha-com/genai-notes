# GenAI Notes — Cross-platform task runner
# Usage: make <target>
# Requires: mkdocs, pwsh (PowerShell Core)

.PHONY: serve build generate verify lint check-freshness help

## Development ─────────────────────────────

serve:  ## Start local MkDocs dev server
	mkdocs serve

build:  ## Build static site with strict mode
	mkdocs build --strict

## Quality ─────────────────────────────────

verify:  ## Run full repo verification
	pwsh scripts/verify_repo.ps1

lint:  ## Run markdown quality checks
	pwsh scripts/markdown_quality_check.ps1

check-links:  ## Check for broken internal links
	pwsh scripts/check_links.ps1

check-freshness:  ## Flag notes with stale content
	pwsh scripts/check_freshness.ps1

## Generation ──────────────────────────────

generate:  ## Regenerate all learning assets (Anki, checklists, matrix)
	pwsh scripts/generate_learning_assets.ps1

## Help ────────────────────────────────────

help:  ## Show this help
	@echo Available targets:
	@echo   serve            - Start local MkDocs dev server
	@echo   build            - Build static site (strict mode)
	@echo   verify           - Run full repo verification
	@echo   lint             - Run markdown quality checks
	@echo   check-links      - Check for broken links
	@echo   check-freshness  - Flag stale content
	@echo   generate         - Regenerate all learning assets
