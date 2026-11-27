"""Serves the dated market-data snapshot written by jobs/market_data.

The job writes `latest.json` (plus dated copies) to Cloud Storage; this
module reads it with a short in-memory cache. Locally it reads a directory.
"""

import json
import threading
import time
from pathlib import Path
from typing import Any

from .settings import Settings


class MarketStore:
    def __init__(self, settings: Settings):
        self._source = settings.market_source
        self._ttl = settings.market_cache_seconds
        self._lock = threading.Lock()
        self._cached: tuple[float, dict[str, Any] | None] = (0.0, None)

    def latest(self) -> dict[str, Any] | None:
        with self._lock:
            fetched_at, data = self._cached
            if data is not None and time.monotonic() - fetched_at < self._ttl:
                return data
        data = self._read("latest.json")
        with self._lock:
            self._cached = (time.monotonic(), data)
        return data

    def _read(self, name: str) -> dict[str, Any] | None:
        if self._source.startswith("gs://"):
            from google.cloud import storage

            bucket_name, _, prefix = self._source.removeprefix("gs://").partition("/")
            blob = storage.Client().bucket(bucket_name).blob(f"{prefix.rstrip('/')}/{name}".lstrip("/"))
            if not blob.exists():
                return None
            return json.loads(blob.download_as_text())
        path = Path(self._source) / name
        if not path.exists():
            return None
        return json.loads(path.read_text(encoding="utf-8"))
