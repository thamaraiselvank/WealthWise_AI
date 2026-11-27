"""Which AMFI categories the app explains, and how raw category text maps to
them. AMFI's wording varies ("Equity Scheme" / "Equity Schemes", spacing),
so matching is on the part after " - ", case-insensitive."""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class Category:
    key: str
    label: str
    asset_class: str  # equity | debt | hybrid | gold
    about: str
    # All must appear in the lower-cased AMFI sub-category text...
    match: tuple[str, ...]
    # ...and none of these.
    exclude: tuple[str, ...] = ()
    # ETFs have a single plan, so names don't say "Direct ... Growth".
    etf: bool = False


CATEGORIES: list[Category] = [
    Category("large_cap", "Large-cap funds", "equity",
             "Invest in India's 100 biggest listed companies.", ("large cap fund",), ("mid",)),
    Category("mid_cap", "Mid-cap funds", "equity",
             "Invest in companies ranked 101–250 by size: more growth potential, bigger swings.",
             ("mid cap fund",), ("large",)),
    Category("small_cap", "Small-cap funds", "equity",
             "Invest in smaller companies: highest potential and the deepest falls.",
             ("small cap fund",)),
    Category("flexi_cap", "Flexi-cap funds", "equity",
             "The manager can invest across company sizes.", ("flexi cap",)),
    Category("elss", "ELSS (tax-saver) funds", "equity",
             "Equity funds with a 3-year lock-in that qualify for a tax deduction under the old regime.",
             ("elss",)),
    Category("equity_index", "Equity index funds", "equity",
             "Track an index such as the Nifty 50 at low cost, without a manager picking stocks.",
             ("index funds - equity",)),
    Category("aggressive_hybrid", "Aggressive hybrid funds", "hybrid",
             "Mostly equity (65–80%) with the rest in debt.", ("aggressive hybrid",)),
    Category("balanced_advantage", "Balanced advantage funds", "hybrid",
             "Shift between equity and debt based on market levels.",
             ("balanced advantage",)),
    Category("multi_asset", "Multi-asset funds", "hybrid",
             "Hold equity, debt and gold in one fund.", ("multi asset",)),
    Category("arbitrage", "Arbitrage funds", "hybrid",
             "Low-risk, debt-like returns with equity taxation.", ("arbitrage",)),
    Category("liquid", "Liquid funds", "debt",
             "Very short-term debt: a common home for an emergency fund.", ("liquid fund",)),
    Category("short_duration", "Short-duration debt funds", "debt",
             "Debt of 1–3 years: for money needed in a few years.",
             ("short duration",), ("ultra",)),
    Category("corporate_bond", "Corporate bond funds", "debt",
             "Mostly high-rated company bonds.", ("corporate bond",)),
    Category("banking_psu", "Banking & PSU debt funds", "debt",
             "Bonds from banks and public-sector companies.", ("banking and psu",)),
    Category("gilt", "Gilt funds", "debt",
             "Government securities: no credit risk, but prices move with interest rates.",
             ("gilt fund",), ("10-year", "constant maturity")),
    Category("gold_etf", "Gold ETFs", "gold",
             "Track the price of gold; held in a demat account.", ("gold etf",), etf=True),
]


def classify(amfi_category: str) -> Category | None:
    sub = amfi_category.partition(" - ")[2].lower() if " - " in amfi_category else amfi_category.lower()
    full = amfi_category.lower()
    for c in CATEGORIES:
        text = full if c.key == "equity_index" else sub
        if all(m in text for m in c.match) and not any(x in text for x in c.exclude):
            return c
    return None
