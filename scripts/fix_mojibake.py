#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


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
    "node_modules",
    "site",
}

SUSPECT_MARKERS = tuple(
    chr(codepoint)
    for codepoint in (0x00C3, 0x00C2, 0x00E2, 0x00F0, 0x00C5, 0x00CB, 0x017D, 0x00CF)
)

# These are the visible Unicode characters produced when bytes 0x80-0x9F are
# decoded as Windows-1252 instead of UTF-8.
CP1252_PUNCTUATION = {
    0x20AC,
    0x201A,
    0x0192,
    0x201E,
    0x2026,
    0x2020,
    0x2021,
    0x02C6,
    0x2030,
    0x0160,
    0x2039,
    0x0152,
    0x017D,
    0x2018,
    0x2019,
    0x201C,
    0x201D,
    0x2022,
    0x2013,
    0x2014,
    0x02DC,
    0x2122,
    0x0161,
    0x203A,
    0x0153,
    0x017E,
    0x0178,
}


@dataclass
class FileResult:
    path: Path
    changed: bool
    suspect_markers_before: int
    suspect_markers_after: int


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan or fix mojibake across repo text files without external dependencies."
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


def mojibake_badness(text: str) -> int:
    total = 0
    for ch in text:
        codepoint = ord(ch)
        if codepoint in CP1252_PUNCTUATION or 0x80 <= codepoint <= 0x9F:
            total += 1
        elif ch in SUSPECT_MARKERS:
            total += 1
    return total


def to_single_byte(ch: str) -> int | None:
    codepoint = ord(ch)
    if codepoint <= 0xFF:
        return codepoint

    try:
        encoded = ch.encode("cp1252")
    except UnicodeEncodeError:
        return None

    if len(encoded) != 1:
        return None

    return encoded[0]


def fix_segment(segment: str) -> str:
    best = segment
    best_badness = mojibake_badness(segment)
    current = segment

    for _ in range(3):
        raw_bytes = bytearray()
        for ch in current:
            byte = to_single_byte(ch)
            if byte is None:
                return best
            raw_bytes.append(byte)

        try:
            candidate = raw_bytes.decode("utf-8")
        except UnicodeDecodeError:
            return best

        candidate_badness = mojibake_badness(candidate)
        if candidate == current or candidate_badness > best_badness:
            return best

        best = candidate
        best_badness = candidate_badness
        current = candidate

    return best


def fix_text(text: str) -> str:
    fixed_parts: list[str] = []
    buffer: list[str] = []

    def flush_buffer() -> None:
        if not buffer:
            return

        segment = "".join(buffer)
        if mojibake_badness(segment) > 0:
            fixed_parts.append(fix_segment(segment))
        else:
            fixed_parts.append(segment)
        buffer.clear()

    for ch in text:
        if to_single_byte(ch) is not None:
            buffer.append(ch)
        else:
            flush_buffer()
            fixed_parts.append(ch)

    flush_buffer()
    return "".join(fixed_parts)


def process_file(path: Path, root: Path, apply_changes: bool) -> FileResult:
    original = read_text(path)
    suspect_markers_before = mojibake_badness(original)
    if suspect_markers_before == 0:
        return FileResult(
            path=path.relative_to(root),
            changed=False,
            suspect_markers_before=0,
            suspect_markers_after=0,
        )

    fixed = fix_text(original)
    suspect_markers_after = mojibake_badness(fixed)
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
