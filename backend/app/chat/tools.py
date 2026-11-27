"""Functions Gemini may ask for. They are executed ON THE PHONE by the Dart
finance engine (the single source of truth for numbers); this server only
declares them and relays calls and results.

Keep in sync with app/lib/features/assistant/tool_runner.dart. The shared
contract test (tests/test_tools.py) checks the names against
shared/assistant_tools.json, which the Dart tests also read.
"""

import json
from pathlib import Path
from typing import Any

_CONTRACT = Path(__file__).resolve().parents[3] / "shared" / "assistant_tools.json"


def load_declarations() -> list[dict[str, Any]]:
    """Function declarations in Gemini's OpenAPI-subset schema format."""
    with _CONTRACT.open(encoding="utf-8") as f:
        return json.load(f)["functions"]


TOOL_DECLARATIONS: list[dict[str, Any]] = load_declarations()
TOOL_NAMES: frozenset[str] = frozenset(d["name"] for d in TOOL_DECLARATIONS)

# Upper bound on tool round trips in one answer, to stop loops.
MAX_TOOL_ROUNDS = 4
