"""
fix_encoding.py - Fix mojibake in genai-notes markdown files.
All string patterns are expressed as escape sequences to avoid encoding issues.
Usage:
  py -3 scripts/fix_encoding.py         # scan only
  py -3 scripts/fix_encoding.py --fix   # apply fixes
"""
import sys
import re
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent

SCAN_DIRS = [
    "foundations","techniques","llms","agents","production","inference",
    "evaluation","multimodal","applications","ethics-and-safety",
    "tools-and-infra","research-frontiers","prerequisites",
]
SCAN_FILES = ["CHANGELOG.md","CONTRIBUTING.md","README.md"]

# Common mojibake sequences (UTF-8 bytes read as cp1252, as Python unicode escapes)
# \u00e2\u02dc\u2026 = â˜… = ★ broken
MOJIBAKE_MARKERS = [
    "\u00e2\u02dc\u2026",  # star
    "\u00e2\u20ac\u201c",  # em-dash
    "\u00e2\u20ac\u2122",  # right-single-quote
    "\u00e2\u20ac\u0153",  # left-double-quote
    "\u00e2\u2014\u2020",  # diamond
    "\u00e2\u2014\u2039",  # circle
    "\u00e2\u02da\u00a0",  # warning
    "\u00e2\u2020\u2019",  # arrow
    "\u00f0\u009f",        # emoji prefix (ded-style)
    "\u00c3\u00a2",        # generic latin corruption prefix Ã¢
]

def is_corrupted(text: str) -> bool:
    return any(m in text for m in MOJIBAKE_MARKERS)

# Manual substitution table (bad -> good), all expressed as unicode escapes
SUBS = [
    ("\u00e2\u02dc\u2026", "\u2605"),          # ★
    ("\u00e2\u20ac\u201c", "\u2014"),          # —
    ("\u00e2\u20ac\u2122", "\u2019"),          # '
    ("\u00e2\u20ac\u0153", "\u201c"),          # "
    ("\u00e2\u20ac\u009d", "\u201d"),          # "
    ("\u00e2\u2014\u2020", "\u25c6"),          # ◆
    ("\u00e2\u2014\u2039", "\u25cb"),          # ○
    ("\u00e2\u02da\u00a0\u00ef\u00b8\u008f", "\u26a0\ufe0f"),  # ⚠️
    ("\u00e2\u02da\u00a0", "\u26a0"),          # ⚠
    ("\u00e2\u2020\u2019", "\u2192"),          # →
    ("\u00e2\u0153\u2026", "\u2705"),          # ✅
    ("\u00e2\u0153\u00a8", "\u2728"),          # ✨
    ("\u00e2\u00ad\u0090", "\u2b50"),          # ⭐
    # Emoji sequences (ð sequences — 4-byte UTF-8 as 4 cp1252 chars)
    ("\u00f0\u009f\u0094\u0098", "\U0001f4d8"),  # 📘
    ("\u00f0\u009f\u0094\u00a7", "\U0001f527"),  # 🔧
    ("\u00f0\u009f\u008e\u0093", "\U0001f393"),  # 🎓
    ("\u00f0\u009f\u008e\u00a5", "\U0001f3a5"),  # 🎥
    ("\u00f0\u009f\u0094\u0084", "\U0001f504"),  # 🔄
    ("\u00f0\u009f\u0090\u009b", "\U0001f41b"),  # 🐛
    ("\u00f0\u009f\u0086\u0095", "\U0001f195"),  # 🆕
    ("\u00f0\u009f\u0093\u009d", "\U0001f4dd"),  # 📝
    ("\u00f0\u009f\u0093\u009a", "\U0001f4da"),  # 📚
    ("\u00f0\u009f\u0094\u008d", "\U0001f50d"),  # 🔍
    ("\u00f0\u009f\u0092\u00a1", "\U0001f4a1"),  # 💡
    ("\u00f0\u009f\u0091\u0089", "\U0001f449"),  # 👉
    ("\u00f0\u009f\u008e\u00af", "\U0001f3af"),  # 🎯
    ("\u00f0\u009f\u009a\u00aa", "\U0001f6aa"),  # 🚪
    ("\u00f0\u009f\u009b\u0082", "\U0001f6c2"),  # 🛂
    ("\u00f0\u009f\u0097\u0082", "\U0001f5c2"),  # 🗂
    ("\u00f0\u009f\u0094\u00b4", "\U0001f534"),  # 🔴 
    ("\u00e2\u009c\u2026", "\u2705"),            # another ✅ variant
    ("\u00e2\u009c\u0085", "\u2705"),
    ("\u00e2\u009c\u00a8", "\u2728"),
]

def fix_text(text: str) -> str:
    for bad, good in SUBS:
        text = text.replace(bad, good)
    return text

def collect_files():
    files = []
    for d in SCAN_DIRS:
        p = REPO_ROOT / d
        if p.exists():
            files.extend(p.rglob("*.md"))
    for f in SCAN_FILES:
        p = REPO_ROOT / f
        if p.exists():
            files.append(p)
    return files

def main():
    apply_fix = "--fix" in sys.argv
    files = collect_files()
    corrupted = []

    for f in files:
        try:
            text = f.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"ERROR reading {f}: {e}")
            continue
        if not is_corrupted(text):
            continue
        corrupted.append(f)
        if apply_fix:
            fixed = fix_text(text)
            if fixed != text:
                f.write_text(fixed, encoding="utf-8")
                print(f"  FIXED: {f.relative_to(REPO_ROOT)}")
            else:
                print(f"  NO-CHANGE (patterns found but no sub matched): {f.relative_to(REPO_ROOT)}")

    print(f"\n{'='*55}")
    print(f"Files with encoding issues: {len(corrupted)}")
    for f in corrupted:
        print(f"  - {f.relative_to(REPO_ROOT)}")
    if apply_fix:
        print("Fixes applied.")
    else:
        print("Run with --fix to apply corrections.")

if __name__ == "__main__":
    main()
