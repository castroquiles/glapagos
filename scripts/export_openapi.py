#!/usr/bin/env python3
"""Export the GLAPAGOS Platform API OpenAPI schema to ``docs/api/openapi.json``.

FastAPI generates the OpenAPI document at runtime (served at ``/openapi.json``),
but a committed artifact lets contributors, client generators, and reviewers see
the API contract without running the server. Regenerate after changing any route:

    python scripts/export_openapi.py

The committed file is verified against the live app in
``tests/unit/test_openapi.py`` so it can never silently drift.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO_ROOT))

from src.api.main import app  # noqa: E402  (path set up above)

OUTPUT_PATH = REPO_ROOT / "docs" / "api" / "openapi.json"


def main() -> None:
    schema = app.openapi()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(
        json.dumps(schema, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"Wrote {OUTPUT_PATH.relative_to(Path.cwd())}")


if __name__ == "__main__":
    main()
