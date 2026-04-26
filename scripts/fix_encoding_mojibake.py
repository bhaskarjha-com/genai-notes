#!/usr/bin/env python3
"""
fix_encoding_mojibake.py
========================

Purpose
-------
Repair text files that were damaged by an encoding mismatch, especially the
common Windows/PowerShell failure mode where UTF-8 text is accidentally read as
cp1252 or latin-1 and then saved again. The visible result is "mojibake":

    â€”   instead of —
    â†’   instead of →
    Ã¢â‚¬â€ instead of —
    âˆš   instead of √
    nÂ²   instead of n²

This script is intentionally conservative:

1. It scans only text-like files.
2. It scores how suspicious a file/segment looks before attempting a repair.
3. It only writes changes when the repaired version clearly reduces that
   suspicion score.

Why this exists
---------------
This repo previously had multiple overlapping encoding-fix scripts. They were
useful during cleanup, but too easy to forget or misunderstand later. This file
is the single long-term tool to keep.

Typical usage
-------------
Scan markdown files only:

    py -3 scripts/fix_encoding_mojibake.py

Apply markdown fixes:

    py -3 scripts/fix_encoding_mojibake.py apply --ext md

Check a broader set of text assets and fail in CI if anything is fixable:

    py -3 scripts/fix_encoding_mojibake.py check --ext md --ext py --ext json
"""
from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


# File types worth scanning. The script is aimed at repo text, not binaries.
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


# Directories that should never be traversed during normal cleanup.
DEFAULT_EXCLUDED_DIRS = {
    ".git",
    ".tmp",
    ".venv",
    "__pycache__",
    "node_modules",
    "site",
}


# Strong signals of UTF-8 bytes being misread as cp1252/latin-1. These are the
# characters that tend to show up in broken text like "â€”" or "Ã¢â‚¬â€".
STRONG_MARKERS = tuple(
    chr(codepoint)
    for codepoint in (
        0x00C2,  # Â
        0x00C3,  # Ã
        0x00C5,  # Å
        0x00CB,  # Ë
        0x00CF,  # Ï
        0x00D0,  # Ð
        0x00E2,  # â
        0x00F0,  # ð
        0x0152,  # Œ
        0x017D,  # Ž
    )
)


# These punctuation characters can legitimately exist in healthy Unicode text.
# They become suspicious only when they appear alongside strong markers or C1
# control characters (0x80-0x9F) that leaked into decoded text.
CP1252_PUNCTUATION = {
    0x20AC,  # €
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


# Small cleanup rules that are safe after a successful decode pass.
COMMON_REPAIRS = (
    ("\u00a0", " "),  # non-breaking space often rides along with damage
)


@dataclass
class FileResult:
    """Summary of one file after scanning or repair."""

    path: Path
    changed: bool
    issue_score_before: int
    issue_score_after: int


def parse_args() -> argparse.Namespace:
    """Define the command-line interface."""
    parser = argparse.ArgumentParser(
        description=(
            "Scan or repair mojibake caused by UTF-8 text being decoded as "
            "cp1252/latin-1 or re-encoded multiple times."
        )
    )
    parser.add_argument(
        "mode",
        choices=("scan", "check", "apply"),
        nargs="?",
        default="scan",
        help=(
            "scan prints candidate files, check exits non-zero if issues exist, "
            "apply rewrites files in place."
        ),
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
        help=(
            "File extension to include. Can be passed multiple times. "
            "Defaults to common text formats."
        ),
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
    """Normalize `--ext` values into a lowercase dotted extension set."""
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
    """Normalize directory exclusions from the CLI."""
    if not raw_names:
        return set(DEFAULT_EXCLUDED_DIRS)
    return {name.strip() for name in raw_names if name.strip()}


def iter_candidate_files(
    root: Path, extensions: set[str], excluded_dir_names: set[str]
) -> Iterable[Path]:
    """Yield files under `root` that match the chosen extensions."""
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() not in extensions:
            continue
        if any(part in excluded_dir_names for part in path.parts):
            continue
        yield path


def read_text(path: Path) -> str:
    """Read a UTF-8 text file without altering newlines."""
    with path.open("r", encoding="utf-8", newline="") as handle:
        return handle.read()


def write_text(path: Path, text: str) -> None:
    """Write a UTF-8 text file without newline normalization."""
    with path.open("w", encoding="utf-8", newline="") as handle:
        handle.write(text)


def to_single_byte(ch: str) -> int | None:
    """
    Convert a character back to its original single-byte value when possible.

    This is the key trick that lets us reverse "UTF-8 bytes decoded as cp1252"
    style corruption. If a character cannot be represented as a single cp1252
    byte, we treat it as a hard boundary and do not try to decode across it.
    """
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


def strong_marker_count(text: str) -> int:
    """Count obvious mojibake indicators in text."""
    total = sum(text.count(marker) for marker in STRONG_MARKERS)
    total += text.count("\ufffd")  # replacement character
    total += sum(1 for ch in text if 0x80 <= ord(ch) <= 0x9F)
    return total


def cp1252_punctuation_count(text: str) -> int:
    """Count cp1252 punctuation that often appears near mojibake."""
    return sum(1 for ch in text if ord(ch) in CP1252_PUNCTUATION)


def issue_score(text: str) -> int:
    """
    Score how likely text is to be mojibake.

    Valid Unicode punctuation like em-dashes should not trigger by itself. We
    only consider it suspicious when strong markers are already present.
    """
    strong = strong_marker_count(text)
    if strong == 0:
        return 0
    return strong * 10 + cp1252_punctuation_count(text)


def should_attempt_segment_repair(segment: str) -> bool:
    """
    Decide whether a segment is suspicious enough to attempt repair.

    The goal is to avoid "fixing" already-correct Unicode while still catching
    broken runs of text that are bounded by clean characters.
    """
    if issue_score(segment) > 0:
        return True

    cp_count = cp1252_punctuation_count(segment)
    if cp_count < 2:
        return False
    return any(ch in segment for ch in STRONG_MARKERS)


def decode_bytes_once(text: str, output_encoding: str = "utf-8") -> str | None:
    """
    Rebuild bytes from a suspicious text segment and decode them once.

    Example:
        "â€”" -> b"\\xe2\\x80\\x94" -> "—"
    """
    raw_bytes = bytearray()
    for ch in text:
        byte = to_single_byte(ch)
        if byte is None:
            return None
        raw_bytes.append(byte)

    try:
        return raw_bytes.decode(output_encoding)
    except UnicodeDecodeError:
        return None


def repair_common_artifacts(text: str) -> str:
    """Apply tiny safe post-processing repairs after a decode pass."""
    for bad, good in COMMON_REPAIRS:
        text = text.replace(bad, good)
    return text


def iter_repair_candidates(text: str) -> Iterable[str]:
    """
    Generate increasingly repaired candidates for the same segment.

    Some damage is single-pass ("â€”"), while other damage is double-encoded
    ("Ã¢â‚¬â€"). We explore up to three rounds and let scoring choose the best.
    """
    seen = {text}
    frontier = [text]

    for _ in range(3):
        next_frontier: list[str] = []
        for current in frontier:
            candidate = decode_bytes_once(current)
            if candidate is None:
                continue
            candidate = repair_common_artifacts(candidate)
            if candidate in seen:
                continue
            seen.add(candidate)
            next_frontier.append(candidate)
            yield candidate
        frontier = next_frontier
        if not frontier:
            break


def choose_best_repair(text: str) -> str:
    """Pick the lowest-suspicion candidate produced by repair passes."""
    best = text
    best_score = issue_score(text)

    for candidate in iter_repair_candidates(text):
        candidate_score = issue_score(candidate)
        if candidate_score < best_score:
            best = candidate
            best_score = candidate_score
            if candidate_score == 0:
                break

    return best


def fix_text(text: str) -> str:
    """
    Repair suspicious regions while leaving clearly clean Unicode untouched.

    We split on characters that cannot be represented as a single cp1252 byte,
    because those act as safe boundaries around the damaged runs.
    """
    fixed_parts: list[str] = []
    buffer: list[str] = []

    def flush_buffer() -> None:
        if not buffer:
            return

        segment = "".join(buffer)
        if should_attempt_segment_repair(segment):
            fixed_parts.append(choose_best_repair(segment))
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
    """Scan one file and optionally rewrite it if repair is clearly better."""
    original = read_text(path)
    score_before = issue_score(original)
    if score_before == 0:
        return FileResult(
            path=path.relative_to(root),
            changed=False,
            issue_score_before=0,
            issue_score_after=0,
        )

    fixed = fix_text(original)
    score_after = issue_score(fixed)
    changed = fixed != original and score_after < score_before

    if changed and apply_changes:
        write_text(path, fixed)

    return FileResult(
        path=path.relative_to(root),
        changed=changed,
        issue_score_before=score_before,
        issue_score_after=score_after,
    )


def main() -> int:
    """Entry point used by both humans and CI."""
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
            # Skip files that claim to be text but are not valid UTF-8 inputs.
            continue

    changed_results = [result for result in results if result.changed]
    total_before = sum(result.issue_score_before for result in changed_results)
    total_after = sum(result.issue_score_after for result in changed_results)

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
    print(f"Issue score before: {total_before}")
    print(f"Issue score after: {total_after}")

    if changed_results:
        print("")
        print(f"Files {action_word}:")
        visible_results = changed_results
        if args.limit > 0:
            visible_results = changed_results[: args.limit]

        for result in visible_results:
            print(
                f"- {result.path} "
                f"(score {result.issue_score_before} -> {result.issue_score_after})"
            )

        if args.limit > 0 and len(changed_results) > args.limit:
            remaining = len(changed_results) - args.limit
            print(f"- ... and {remaining} more")

    if args.mode == "check" and changed_results:
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
