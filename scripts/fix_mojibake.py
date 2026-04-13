#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

import ftfy


DEFAULT_EXTENSIONS = {
    ".md",
    ".txt",
    ".yml",
    ".yaml",
    ".ps1",
    ".py",
    ".json",
    ".tsv",
    ".csv",
}

DEFAULT_EXCLUDED_DIRS = {
    ".git",
    ".venv",
    "__pycache__",
    "docs",
    "node_modules",
    "site",
}


def utf8_as_latin1(text: str) -> str:
    return text.encode("utf-8").decode("latin-1")


REPO_REPLACEMENTS = (
    (utf8_as_latin1("\u2014"), "\u2014"),
    (utf8_as_latin1("\u2013"), "\u2013"),
    (utf8_as_latin1("\u2019"), "\u2019"),
    (utf8_as_latin1("\u201c"), "\u201c"),
    (utf8_as_latin1("\u201d"), "\u201d"),
    (utf8_as_latin1("\u2018"), "\u2018"),
    (utf8_as_latin1("\u2026"), "\u2026"),
    (utf8_as_latin1("\u2192"), "\u2192"),
    (utf8_as_latin1("\u2190"), "\u2190"),
    (utf8_as_latin1("\u2605"), "\u2605"),
    (utf8_as_latin1("\u25c6"), "\u25c6"),
    (utf8_as_latin1("\u25cb"), "\u25cb"),
    (utf8_as_latin1("\u25a1"), "\u25a1"),
    (utf8_as_latin1("\u25bc"), "\u25bc"),
    (utf8_as_latin1("\u25b6"), "\u25b6"),
    (utf8_as_latin1("\u2591"), "\u2591"),
    (utf8_as_latin1("\u2588"), "\u2588"),
    (utf8_as_latin1("\u2728"), "\u2728"),
    (utf8_as_latin1("\u2705"), "\u2705"),
    (utf8_as_latin1("\u274c"), "\u274c"),
    (utf8_as_latin1("\u26a0\ufe0f"), "\u26a0\ufe0f"),
    (utf8_as_latin1("\u26aa"), "\u26aa"),
    (utf8_as_latin1("\u26ab"), "\u26ab"),
    (utf8_as_latin1("\u2502"), "\u2502"),
    (utf8_as_latin1("\u2500"), "\u2500"),
    (utf8_as_latin1("\u250c"), "\u250c"),
    (utf8_as_latin1("\u2510"), "\u2510"),
    (utf8_as_latin1("\u2514"), "\u2514"),
    (utf8_as_latin1("\u2518"), "\u2518"),
    (utf8_as_latin1("\u251c"), "\u251c"),
    (utf8_as_latin1("\u2524"), "\u2524"),
    (utf8_as_latin1("\u2551"), "\u2551"),
    (utf8_as_latin1("\u2550"), "\u2550"),
    (utf8_as_latin1("\u2554"), "\u2554"),
    (utf8_as_latin1("\u2557"), "\u2557"),
    (utf8_as_latin1("\u255a"), "\u255a"),
    (utf8_as_latin1("\u255d"), "\u255d"),
    (utf8_as_latin1("\u2563"), "\u2563"),
)

SUSPECT_MARKERS = tuple(
    chr(codepoint)
    for codepoint in (0x00C3, 0x00C2, 0x00E2, 0x00F0, 0x00C5, 0x00CB, 0x017D, 0x00CF)
)


@dataclass
class FileResult:
    path: Path
    changed: bool
    suspect_markers_before: int
    suspect_markers_after: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan or fix mojibake across repo text files using ftfy."
    )
    parser.add_argument(
        "mode",
        choices=("scan", "check", "apply"),
        nargs="?",
        default="scan",
        help="scan shows candidate files, check exits non-zero if issues exist, apply rewrites files.",
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="Repo root to scan. Defaults to the parent of scripts/.",
    )
    parser.add_argument(
        "--ext",
        action="append",
        dest="extensions",
        default=None,
        help="File extension to include. Can be passed multiple times. Defaults to common text formats.",
    )
    parser.add_argument(
        "--exclude-dir",
        action="append",
        dest="exclude_dirs",
        default=None,
        help="Directory name to exclude. Can be passed multiple times.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=0,
        help="Only print the first N changed files. 0 means no limit.",
    )
    return parser.parse_args()


def normalize_extensions(raw_extensions: list[str] | None) -> set[str]:
    if not raw_extensions:
        return set(DEFAULT_EXTENSIONS)

    normalized: set[str] = set()
    for extension in raw_extensions:
        extension = extension.strip()
        if not extension:
            continue
        if not extension.startswith("."):
            extension = f".{extension}"
        normalized.add(extension.lower())

    return normalized or set(DEFAULT_EXTENSIONS)


def normalize_dir_names(raw_names: list[str] | None) -> set[str]:
    if not raw_names:
        return set(DEFAULT_EXCLUDED_DIRS)
    return {name.strip() for name in raw_names if name.strip()}


def iter_candidate_files(
    root: Path, extensions: set[str], excluded_dir_names: set[str]
) -> Iterable[Path]:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() not in extensions:
            continue
        if any(part in excluded_dir_names for part in path.parts):
            continue
        yield path


def read_text(path: Path) -> str:
    with path.open("r", encoding="utf-8", newline="") as handle:
        return handle.read()


def write_text(path: Path, text: str) -> None:
    with path.open("w", encoding="utf-8", newline="") as handle:
        handle.write(text)


def count_suspect_markers(text: str) -> int:
    return sum(text.count(marker) for marker in SUSPECT_MARKERS)


def fix_text(text: str) -> str:
    fixed = ftfy.fix_text(text)
    if fixed != text:
        fixed = ftfy.fix_text(fixed)

    for bad, good in REPO_REPLACEMENTS:
        fixed = fixed.replace(bad, good)

    return fixed


def process_file(path: Path, root: Path, apply_changes: bool) -> FileResult:
    original = read_text(path)
    suspect_markers_before = count_suspect_markers(original)
    if suspect_markers_before == 0:
        return FileResult(
            path=path.relative_to(root),
            changed=False,
            suspect_markers_before=0,
            suspect_markers_after=0,
        )

    fixed = fix_text(original)
    suspect_markers_after = count_suspect_markers(fixed)
    changed = fixed != original and suspect_markers_after < suspect_markers_before

    if changed and apply_changes:
        write_text(path, fixed)

    return FileResult(
        path=path.relative_to(root),
        changed=changed,
        suspect_markers_before=suspect_markers_before,
        suspect_markers_after=suspect_markers_after,
    )


def main() -> int:
    args = parse_args()
    root = args.root.resolve()
    extensions = normalize_extensions(args.extensions)
    excluded_dir_names = normalize_dir_names(args.exclude_dirs)
    apply_changes = args.mode == "apply"

    if not root.exists():
        print(f"Root does not exist: {root}", file=sys.stderr)
        return 2

    results: list[FileResult] = []
    for path in iter_candidate_files(root, extensions, excluded_dir_names):
        try:
            results.append(process_file(path, root, apply_changes))
        except UnicodeDecodeError:
            continue

    changed_results = [result for result in results if result.changed]
    total_before = sum(result.suspect_markers_before for result in changed_results)
    total_after = sum(result.suspect_markers_after for result in changed_results)

    action_word = {
        "scan": "fixable",
        "check": "fixable",
        "apply": "updated",
    }[args.mode]

    print("Mojibake cleanup summary")
    print("------------------------")
    print(f"Root: {root}")
    print(f"Files scanned: {len(results)}")
    print(f"Files {action_word}: {len(changed_results)}")
    print(f"Suspicious markers before: {total_before}")
    print(f"Suspicious markers after: {total_after}")

    if changed_results:
        print("")
        print(f"Files {action_word}:")
        visible_results = changed_results
        if args.limit > 0:
            visible_results = changed_results[: args.limit]

        for result in visible_results:
            print(
                f"- {result.path} "
                f"(markers {result.suspect_markers_before} -> {result.suspect_markers_after})"
            )

        if args.limit > 0 and len(changed_results) > args.limit:
            remaining = len(changed_results) - args.limit
            print(f"- ... and {remaining} more")

    if args.mode == "check" and changed_results:
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
