"""Parsing AMFI NAV files.

Two formats exist and their columns are in different orders:
  NAVAll.txt (today):  Scheme Code;ISIN...;ISIN...;Scheme Name;Plan;Option;Net Asset Value;Date
  NAV history report:  Scheme Code;NAV Name;Plan;Option;ISIN...;ISIN...;Net Asset Value;Date
Columns are therefore located by header name. Category lines look like
"Open Ended Schemes(Equity Scheme - Large Cap Fund)" (spacing varies).
"""

from __future__ import annotations

import re
from collections import Counter
from dataclasses import dataclass
from datetime import date, datetime

TODAY_URL = "https://portal.amfiindia.com/spages/NAVAll.txt"
HISTORY_URL = "https://portal.amfiindia.com/DownloadNAVHistoryReport_Po.aspx?frmdt={d}&todt={d}"

_CATEGORY_RE = re.compile(r"^\s*(Open Ended|Close Ended|Interval Fund) Schemes\s*\((.*)\)\s*$")


@dataclass(frozen=True)
class NavRecord:
    code: str
    name: str
    plan: str
    option: str
    nav: float
    nav_date: date
    category: str  # raw AMFI category text, e.g. "Equity Scheme - Large Cap Fund"
    open_ended: bool

    @property
    def _text(self) -> str:
        return f"{self.plan} {self.option} {self.name}".lower()

    @property
    def is_payout_variant(self) -> bool:
        return any(w in self._text for w in ("idcw", "dividend", "bonus", "payout",
                                             "reinvest", "segregated", "unclaimed"))

    @property
    def is_direct_growth(self) -> bool:
        t = self._text
        return "direct" in t and "growth" in t and not self.is_payout_variant


def _col(header: list[str], *names: str) -> int | None:
    lowered = [h.strip().lower() for h in header]
    for n in names:
        if n.lower() in lowered:
            return lowered.index(n.lower())
    return None


def parse_date(s: str) -> date:
    return datetime.strptime(s.strip(), "%d-%b-%Y").date()


def amfi_date(d: date) -> str:
    return d.strftime("%d-%b-%Y")


def parse(text: str) -> list[NavRecord]:
    lines = text.splitlines()
    header_idx = next((i for i, l in enumerate(lines) if l.lower().startswith("scheme code")), None)
    if header_idx is None:
        raise ValueError("not an AMFI NAV file: header not found")
    header = lines[header_idx].split(";")
    i_code = _col(header, "Scheme Code")
    i_name = _col(header, "Scheme Name", "NAV Name")
    i_plan = _col(header, "Plan")
    i_opt = _col(header, "Option")
    i_nav = _col(header, "Net Asset Value")
    i_date = _col(header, "Date")
    if None in (i_code, i_name, i_nav, i_date):
        raise ValueError(f"unexpected AMFI header: {header}")

    records: list[NavRecord] = []
    category, open_ended = "", False
    for line in lines[header_idx + 1:]:
        m = _CATEGORY_RE.match(line)
        if m:
            open_ended = m.group(1) == "Open Ended"
            category = re.sub(r"\s+", " ", m.group(2)).strip()
            continue
        if ";" not in line:
            continue  # blank line or fund-house name
        f = line.split(";")
        if len(f) < len(header) or not f[i_code].strip().isdigit():
            continue
        try:
            nav = float(f[i_nav])
            d = parse_date(f[i_date])
        except ValueError:
            continue  # "N.A." and similar
        if nav <= 0:
            continue
        records.append(NavRecord(
            code=f[i_code].strip(),
            name=f[i_name].strip(),
            plan=f[i_plan].strip() if i_plan is not None else "",
            option=f[i_opt].strip() if i_opt is not None else "",
            nav=nav,
            nav_date=d,
            category=category,
            open_ended=open_ended,
        ))
    return records


def snapshot_date(records: list[NavRecord]) -> date:
    """The date most NAVs in the file are for."""
    if not records:
        raise ValueError("empty NAV file")
    return Counter(r.nav_date for r in records).most_common(1)[0][0]


def nav_by_code(records: list[NavRecord]) -> dict[str, float]:
    return {r.code: r.nav for r in records}
