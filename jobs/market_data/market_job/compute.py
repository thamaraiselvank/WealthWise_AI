"""Category-level return statistics. The output never contains scheme names
or codes: the app explains categories, not products."""

from __future__ import annotations

import statistics
from datetime import date, datetime, timezone
from typing import Any

from .amfi import NavRecord
from .categories import CATEGORIES, Category, classify

PERIODS = {"1y": 1, "3y": 3, "5y": 5}
MIN_SCHEMES = 5  # publish a statistic only with at least this many schemes
# NAV ratios (now / then) outside this band are treated as data artefacts
# (unit splits, mergers, NAV resets) and left out of the statistics.
PLAUSIBLE_RATIO = (0.25, 10.0)

SOURCE = {
    "name": "AMFI India (daily NAVs)",
    "url": "https://www.amfiindia.com/net-asset-value",
    "method": "Direct-plan growth options of open-ended schemes (ETFs: their single "
              "plan). Annualised point-to-point returns per scheme, summarised per "
              "category as the median and the middle 50% range. Computed by WealthWise AI.",
}

DISCLAIMER = ("Past returns of a category are not a promise of future returns. "
              "Individual funds differ widely. For education only.")


def eligible(records: list[NavRecord]) -> dict[str, list[NavRecord]]:
    """Today's schemes grouped by our category key."""
    groups: dict[str, list[NavRecord]] = {c.key: [] for c in CATEGORIES}
    for r in records:
        if not r.open_ended:
            continue
        cat = classify(r.category)
        if cat is None:
            continue
        ok = (not r.is_payout_variant) if cat.etf else r.is_direct_growth
        if ok:
            groups[cat.key].append(r)
    return groups


def _quantile(xs: list[float], q: float) -> float:
    xs = sorted(xs)
    if len(xs) == 1:
        return xs[0]
    pos = (len(xs) - 1) * q
    lo, hi = int(pos), min(int(pos) + 1, len(xs) - 1)
    return xs[lo] + (xs[hi] - xs[lo]) * (pos - lo)


def period_stats(today: list[NavRecord], past_navs: dict[str, float], today_date: date,
                 past_date: date) -> dict[str, Any] | None:
    years = (today_date - past_date).days / 365.25
    if years <= 0:
        return None
    rets = []
    for r in today:
        then = past_navs.get(r.code)
        if then and then > 0:
            ratio = r.nav / then
            if PLAUSIBLE_RATIO[0] <= ratio <= PLAUSIBLE_RATIO[1]:
                rets.append(ratio ** (1 / years) - 1)
    if len(rets) < MIN_SCHEMES:
        return None
    return {
        "median": round(statistics.median(rets), 4),
        "p25": round(_quantile(rets, 0.25), 4),
        "p75": round(_quantile(rets, 0.75), 4),
        "schemes": len(rets),
        "from": past_date.isoformat(),
        "to": today_date.isoformat(),
    }


def build_snapshot(today_records: list[NavRecord], today_date: date,
                   history: dict[str, tuple[date, dict[str, float]]],
                   reference_rates: dict[str, Any] | None = None,
                   generated_at: datetime | None = None) -> dict[str, Any]:
    """`history` maps period key ("1y") to (actual date, NAV by scheme code)."""
    groups = eligible(today_records)
    categories = []
    for cat in CATEGORIES:
        schemes = groups[cat.key]
        if not schemes:
            continue
        returns = {}
        for key in PERIODS:
            if key in history:
                d, navs = history[key]
                s = period_stats(schemes, navs, today_date, d)
                if s:
                    returns[key] = s
        categories.append(_category_json(cat, len(schemes), returns))

    return {
        "schema": 1,
        "as_of": today_date.isoformat(),
        "generated_at": (generated_at or datetime.now(timezone.utc)).isoformat(timespec="seconds"),
        "source": SOURCE,
        "categories": categories,
        "reference_rates": reference_rates or {},
        "disclaimer": DISCLAIMER,
    }


def _category_json(cat: Category, count: int, returns: dict[str, Any]) -> dict[str, Any]:
    return {
        "key": cat.key,
        "label": cat.label,
        "asset_class": cat.asset_class,
        "about": cat.about,
        "schemes_tracked": count,
        "returns": returns,
    }
