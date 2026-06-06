"""
Build script for the GLAPAGOS static dashboard.

Reads data/initiatives.json and injects it into src/dashboard/index.html,
producing a fully self-contained static page at dist/index.html.

Run:
    python3 scripts/build_dashboard.py
"""

import json
import os
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_FILE = ROOT / "data" / "initiatives.json"
TEMPLATE = ROOT / "src" / "dashboard" / "index.html"
DIST = ROOT / "dist"


def build() -> None:
    DIST.mkdir(exist_ok=True)

    with open(DATA_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    with open(TEMPLATE, "r", encoding="utf-8") as f:
        html = f.read()

    injected = json.dumps(data, ensure_ascii=False)
    output = html.replace("__INITIATIVES_DATA__", injected)

    out_file = DIST / "index.html"
    with open(out_file, "w", encoding="utf-8") as f:
        f.write(output)

    print(f"Built: {out_file}")
    print(f"  Initiatives: {len(data['initiatives'])}")
    print(f"  Size: {out_file.stat().st_size / 1024:.1f} KB")


if __name__ == "__main__":
    build()
