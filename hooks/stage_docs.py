from __future__ import annotations

import os
import shutil
import stat
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
STAGING_DIR = REPO_ROOT / "docs"

PUBLIC_FILE_MAP = (
    ("CHANGELOG.md", "CHANGELOG.md"),
    ("CONTRIBUTING.md", "CONTRIBUTING.md"),
    ("genai.md", "genai.md"),
    ("index.md", "index.md"),
    ("LEARNING_PATH.md", "LEARNING_PATH.md"),
    ("LICENSE", "LICENSE"),
    ("README.md", "repo-readme.md"),
    ("tags.md", "tags.md"),
)

PUBLIC_DIRS = (
    "applications",
    "assets",
    "career",
    "downloads",
    "ethics-and-safety",
    "evaluation",
    "foundations",
    "generated",
    "image-generation",
    "inference",
    "learner-tools",
    "llms",
    "multimodal",
    "prerequisites",
    "production",
    "research-frontiers",
    "techniques",
    "tools-and-infra",
)

WATCH_PATHS = tuple(source for source, _ in PUBLIC_FILE_MAP) + PUBLIC_DIRS + ("mkdocs.yml", "hooks")
STALE_ROOT_PATHS = (
    "README.md",
    "README.copy.md",
)


def _reset_staging_dir() -> None:
    STAGING_DIR.mkdir(exist_ok=True)

    for relative_path in STALE_ROOT_PATHS:
        candidate = STAGING_DIR / relative_path
        if candidate.exists():
            os.chmod(candidate, stat.S_IWRITE)
            candidate.unlink()


def _copy_path(source_relative_path: str, destination_relative_path: str | None = None) -> None:
    destination_relative_path = destination_relative_path or source_relative_path
    source = REPO_ROOT / source_relative_path
    destination = STAGING_DIR / destination_relative_path

    if source.is_dir():
        shutil.copytree(source, destination, dirs_exist_ok=True)
        return

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def _stage_public_docs() -> None:
    _reset_staging_dir()

    for source_relative_path, destination_relative_path in PUBLIC_FILE_MAP:
        _copy_path(source_relative_path, destination_relative_path)

    for relative_path in PUBLIC_DIRS:
        _copy_path(relative_path)


def on_pre_build(*args, **kwargs) -> None:
    _stage_public_docs()


def on_serve(server, config, builder, *args, **kwargs):
    _stage_public_docs()

    for relative_path in WATCH_PATHS:
        server.watch(str(REPO_ROOT / relative_path), builder)

    return server
