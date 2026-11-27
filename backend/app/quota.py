"""Per-user monthly question limits.

Only an anonymous Firebase uid (hashed) and a counter are kept: no profile,
no messages. The in-memory store is per Cloud Run instance, so with several
instances the limit is approximate. Swap in a Firestore-backed store (same
interface) before launch; see backend/README.md.
"""

import hashlib
import threading
from datetime import datetime, timezone
from typing import Protocol


class QuotaStore(Protocol):
    def consume(self, user_id: str, limit: int) -> int | None:
        """Uses one question. Returns questions left, or None if over the limit."""

    def remaining(self, user_id: str, limit: int) -> int: ...


def _month() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m")


def _key(user_id: str) -> str:
    return hashlib.sha256(user_id.encode()).hexdigest()[:32]


class InMemoryQuota:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._counts: dict[tuple[str, str], int] = {}

    def consume(self, user_id: str, limit: int) -> int | None:
        k = (_key(user_id), _month())
        with self._lock:
            used = self._counts.get(k, 0)
            if used >= limit:
                return None
            self._counts[k] = used + 1
            return limit - used - 1

    def remaining(self, user_id: str, limit: int) -> int:
        with self._lock:
            return max(0, limit - self._counts.get((_key(user_id), _month()), 0))
