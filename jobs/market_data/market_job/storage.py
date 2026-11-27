"""Writes the snapshot to a local directory or a gs:// prefix."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def write_outputs(out: str, snapshot: dict[str, Any]) -> None:
    body = json.dumps(snapshot, ensure_ascii=False, indent=1)
    names = [f"{snapshot['as_of']}.json", "latest.json"]  # dated copy first
    if out.startswith("gs://"):
        from google.cloud import storage

        bucket_name, _, prefix = out.removeprefix("gs://").partition("/")
        bucket = storage.Client().bucket(bucket_name)
        for name in names:
            blob = bucket.blob(f"{prefix.strip('/')}/{name}".lstrip("/"))
            blob.cache_control = "public, max-age=600" if name == "latest.json" else "public, max-age=86400"
            blob.upload_from_string(body, content_type="application/json")
        return
    d = Path(out)
    d.mkdir(parents=True, exist_ok=True)
    for name in names:
        tmp = d / f".{name}.tmp"
        tmp.write_text(body, encoding="utf-8")
        tmp.replace(d / name)
