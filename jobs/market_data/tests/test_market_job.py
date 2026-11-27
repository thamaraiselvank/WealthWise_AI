import json
from datetime import date

import pytest

from market_job import amfi, main
from market_job.categories import classify
from market_job.compute import build_snapshot, eligible, period_stats

TODAY = """\
Scheme Code;ISIN Div Payout/ ISIN Growth;ISIN Div Reinvestment;Scheme Name;Plan;Option;Net Asset Value;Date

Open Ended Schemes(Equity Scheme - Large Cap Fund)

Alpha Mutual Fund

{large}
1999;INF1;-;Alpha Large Cap Fund;Direct Plan;IDCW;50.0;26-Nov-2026
1998;INF2;-;Alpha Large Cap Fund;Regular Plan;Growth;100.0;26-Nov-2026

Open Ended Schemes(Equity Scheme - Large & Mid Cap Fund)

Alpha Mutual Fund

2001;INF3;-;Alpha Large & Mid Cap Fund;Direct Plan;Growth;10.0;26-Nov-2026

Open Ended Schemes(Exchange Traded Funds (ETFs) - Gold ETF)

Beta Mutual Fund

{gold}

Close Ended Schemes(Equity Scheme - Large Cap Fund)

Gamma Mutual Fund

3001;INF4;-;Gamma Closed Large Cap Fund;Direct Plan;Growth;99.0;26-Nov-2026
4001;INF5;-;Broken Fund;Direct Plan;Growth;N.A.;26-Nov-2026
"""

HISTORY = """\
Scheme Code;NAV Name;Plan;Option;ISIN Div Payout/ISIN Growth;ISIN Div Reinvestment;Net Asset Value;Date

Open Ended Schemes ( Equity Scheme - Large Cap Fund )


Alpha Mutual Fund
{rows}
"""


def large_rows(n=6, nav=121.0):
    return "\n".join(f"{1000 + i};INF;-;Alpha Large Cap {i} Fund;Direct Plan;Growth;{nav + i};26-Nov-2026"
                     for i in range(n))


def gold_rows(n=6):
    return "\n".join(f"{5000 + i};INF;-;Beta Gold ETF {i};;;{60 + i};26-Nov-2026" for i in range(n))


def history_text(codes, nav, d="26-Nov-2025"):
    return HISTORY.format(rows="\n".join(
        f"{c};Fund {c} - Direct Growth;Direct Plan;Growth;INF;;{nav};{d}" for c in codes))


def test_parse_today_format():
    recs = amfi.parse(TODAY.format(large=large_rows(), gold=gold_rows()))
    assert len(recs) == 6 + 2 + 1 + 6 + 1  # "N.A." row dropped
    r = next(x for x in recs if x.code == "1000")
    assert (r.name, r.plan, r.option, r.nav) == ("Alpha Large Cap 0 Fund", "Direct Plan", "Growth", 121.0)
    assert r.category == "Equity Scheme - Large Cap Fund" and r.open_ended
    assert r.is_direct_growth
    assert not next(x for x in recs if x.code == "1999").is_direct_growth
    assert not next(x for x in recs if x.code == "1998").is_direct_growth
    assert not next(x for x in recs if x.code == "3001").open_ended
    assert amfi.snapshot_date(recs) == date(2026, 11, 26)


def test_parse_history_format_with_spaced_category():
    recs = amfi.parse(history_text(["1000", "1001"], 100.0))
    assert recs[0].category == "Equity Scheme - Large Cap Fund"
    assert recs[0].name.startswith("Fund 1000")
    assert amfi.nav_by_code(recs) == {"1000": 100.0, "1001": 100.0}


def test_eligible_keeps_open_ended_direct_growth_only():
    groups = eligible(amfi.parse(TODAY.format(large=large_rows(), gold=gold_rows())))
    assert sorted(r.code for r in groups["large_cap"]) == [str(1000 + i) for i in range(6)]
    assert len(groups["gold_etf"]) == 6


def test_parse_rejects_non_amfi():
    with pytest.raises(ValueError):
        amfi.parse("<html>error</html>")


@pytest.mark.parametrize("raw,key", [
    ("Equity Scheme - Large Cap Fund", "large_cap"),
    ("Equity Schemes - Large Cap Fund", "large_cap"),
    ("Equity Scheme - Large & Mid Cap Fund", None),
    ("Equity Scheme - Mid Cap Fund", "mid_cap"),
    ("Equity Schemes - ELSS- Tax Saver Fund", "elss"),
    ("Index Funds - Equity Funds", "equity_index"),
    ("Debt Scheme - Short Duration Fund", "short_duration"),
    ("Debt Scheme - Ultra Short Duration Fund", None),
    ("Income/Debt Oriented Schemes - 10-year Constant Maturity Gilt Fund", None),
    ("Debt Scheme - Gilt Fund", "gilt"),
    ("Exchange Traded Funds (ETFs) - Gold ETF", "gold_etf"),
    ("Hybrid Schemes - Balanced Advantage Fund/ Dynamic Asset Allocation", "balanced_advantage"),
    ("Equity Scheme - Sectoral/ Thematic", None),
])
def test_classify(raw, key):
    c = classify(raw)
    assert (c.key if c else None) == key


def test_period_stats_cagr_and_minimum():
    recs = eligible(amfi.parse(TODAY.format(large=large_rows(nav=121.0), gold="")))["large_cap"]
    past = {r.code: 100.0 for r in recs}
    s = period_stats(recs, past, date(2026, 11, 26), date(2024, 11, 26))
    # 121 -> about 10% a year over 2 years for scheme 0
    assert s["p25"] < s["median"] < s["p75"]
    assert s["schemes"] == 6
    assert abs(min((r.nav / 100) ** (1 / ((date(2026, 11, 26) - date(2024, 11, 26)).days / 365.25)) - 1
                   for r in recs) - 0.0999) < 0.001
    assert period_stats(recs[:4], past, date(2026, 11, 26), date(2024, 11, 26)) is None


def test_split_artefacts_are_ignored():
    recs = eligible(amfi.parse(TODAY.format(large=large_rows(n=7), gold="")))["large_cap"]
    past = {r.code: 100.0 for r in recs}
    past[recs[0].code] = 5000.0  # looks like a -98% crash: a unit split
    s = period_stats(recs, past, date(2026, 11, 26), date(2025, 11, 26))
    assert s["schemes"] == 6
    assert s["p25"] > 0


def test_snapshot_has_no_scheme_names_or_codes():
    recs = amfi.parse(TODAY.format(large=large_rows(), gold=gold_rows()))
    hist = amfi.parse(history_text([str(1000 + i) for i in range(6)] + [str(5000 + i) for i in range(6)], 100.0))
    snap = build_snapshot(recs, date(2026, 11, 26), {"1y": (date(2025, 11, 26), amfi.nav_by_code(hist))},
                          {"rbi_repo_rate": {"value": 0.055, "as_of": "2026-10-01"}})
    keys = [c["key"] for c in snap["categories"]]
    assert keys == ["large_cap", "gold_etf"]  # ETFs counted without "Direct Growth" in the name
    assert snap["categories"][0]["returns"]["1y"]["schemes"] == 6
    assert snap["as_of"] == "2026-11-26"
    assert snap["source"]["name"].startswith("AMFI")
    text = json.dumps(snap)
    for forbidden in ("Alpha", "Beta", "Gamma", "1000", "5000", "INF"):
        assert forbidden not in text


def test_run_end_to_end_with_fake_fetch(tmp_path):
    today = TODAY.format(large=large_rows(n=1200), gold=gold_rows())
    codes = [str(1000 + i) for i in range(1200)]

    def fetch(url):
        if url == amfi.TODAY_URL:
            return today
        if "26-Nov-2025" in url:
            return history_text(codes, 100.0, "26-Nov-2025")
        if "26-Nov-2023" in url:
            return "<html>server busy</html>"  # falls back to the day before
        if "25-Nov-2023" in url:
            return history_text(codes, 80.0, "25-Nov-2023")
        raise RuntimeError("no data")

    snap = main.run(str(tmp_path), fetch=fetch)
    large = snap["categories"][0]["returns"]
    assert set(large) == {"1y", "3y"}
    assert large["3y"]["from"] == "2023-11-25"
    assert json.loads((tmp_path / "latest.json").read_text(encoding="utf-8")) == snap
    assert (tmp_path / "2026-11-26.json").exists()


def test_incomplete_today_file_fails():
    with pytest.raises(RuntimeError, match="incomplete"):
        main.run("unused", fetch=lambda url: TODAY.format(large=large_rows(), gold=""))


def test_reference_rates_skip_empty_values(tmp_path):
    p = tmp_path / "r.json"
    p.write_text(json.dumps({"rates": {"a": {"value": None}, "b": {"value": 0.07, "as_of": "x"}}}))
    assert main.load_reference_rates(p) == {"b": {"value": 0.07, "as_of": "x"}}
    # The checked-in file must parse.
    assert isinstance(main.load_reference_rates(), dict)
