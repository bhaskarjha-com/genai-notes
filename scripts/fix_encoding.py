"""
Backward-compatible entry point for repo mojibake cleanup.

Usage:
  py -3 scripts/fix_encoding.py         # scan markdown files
  py -3 scripts/fix_encoding.py --fix   # rewrite markdown files
"""
from __future__ import annotations

import sys

from fix_mojibake import main as fix_mojibake_main


def main() -> int:
    argv = ["fix_encoding.py", "scan", "--ext", "md"]
    if "--fix" in sys.argv[1:]:
        argv[1] = "apply"
    sys.argv = argv
    return fix_mojibake_main()


if __name__ == "__main__":
    raise SystemExit(main())
