"""Daily job: fetch AMFI NAVs, compute category statistics, publish JSON.

    python -m market_job.main --out out                 # local directory
    python -m market_job.main --out gs://bucket/market  # Cloud Storage

Writes `latest.json` and `<as_of>.json`. Runs as a Cloud Run job triggered
by Cloud Scheduler (see README).
"""

from __future__ import annotations

import argparse
import json
import logging
import sys
import time
from datetime import date, timedelta
from pathlib import Path
from typing import Any, Callable

import httpx

from . import amfi
from .compute import PERIODS, build_snapshot
from .storage import write_outputs

log = logging.getLogger("market_job")

REFERENCE_RATES = Path(__file__).resolve().parent.parent / "reference_rates.json"
MIN_ROWS = 1000  # a real all-schemes file has thousands of rows
LOOKBACK_DAYS = 7  # holidays/weekends: try earlier days


def fetch_text(url: str, *, attempts: int = 3) -> str:
    last: Exception | None = None
    for i in range(attempts):
        try:
            r = httpx.get(url, timeout=120, follow_redirects=True,
                          headers={"User-Agent": "WealthWiseAI-market-job/1.0"})
            r.raise_for_status()
            return r.text
        except httpx.HTTPError as e:
            last = e
            time.sleep(2 ** i)
    raise RuntimeError(f"failed to fetch {url}: {last}")


def fetch_history(target: date, fetch: Callable[[str], str]) -> tuple[date, dict[str, float]] | None:
    """NAVs on `target`, or the closest earlier day that has a full file."""
    for back in range(LOOKBACK_DAYS):
        d = target - timedelta(days=back)
        try:
            records = amfi.parse(fetch(amfi.HISTORY_URL.format(d=amfi.amfi_date(d))))
        except (RuntimeError, ValueError) as e:
            log.warning("history %s: %s", d, e)
            continue
        if len(records) >= MIN_ROWS:
            return amfi.snapshot_date(records), amfi.nav_by_code(records)
    return None


def load_reference_rates(path: Path = REFERENCE_RATES) -> dict[str, Any]:
    """Manually maintained rates; entries without a value are left out."""
    data = json.loads(path.read_text(encoding="utf-8"))
    return {k: v for k, v in data.get("rates", {}).items()
            if isinstance(v, dict) and v.get("value") is not None}


def run(out: str, fetch: Callable[[str], str] = fetch_text) -> dict[str, Any]:
    today_records = amfi.parse(fetch(amfi.TODAY_URL))
    if len(today_records) < MIN_ROWS:
        raise RuntimeError(f"today's NAV file looks incomplete ({len(today_records)} rows)")
    today = amfi.snapshot_date(today_records)
    log.info("NAVs for %s: %d rows", today, len(today_records))

    history = {}
    for key, years in PERIODS.items():
        target = today.replace(year=today.year - years) if not (today.month == 2 and today.day == 29) \
            else today - timedelta(days=365 * years)
        h = fetch_history(target, fetch)
        if h:
            history[key] = h
            log.info("%s history from %s: %d schemes", key, h[0], len(h[1]))
        else:
            log.warning("no %s history found near %s", key, target)

    snapshot = build_snapshot(today_records, today, history, load_reference_rates())
    write_outputs(out, snapshot)
    log.info("wrote %d categories to %s", len(snapshot["categories"]), out)
    return snapshot


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--out", default="out", help="local directory or gs://bucket/prefix")
    args = p.parse_args(argv)
    try:
        run(args.out)
    except Exception:  # noqa: BLE001 - non-zero exit makes Cloud Run retry/alert
        log.exception("market job failed")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
