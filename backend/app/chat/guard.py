"""Output checks. The system prompt is the first line of defence; this is the
second: answers that name a specific fund house, scheme or stock are
regenerated once, and replaced with a safe message if they still do."""

import re

# Fund houses (AMCs) operating in India. Matching only when followed by a
# product word keeps "an SBI savings account" or "Tata group" from tripping it
# while catching "HDFC Flexi Cap Fund" or "Axis MF".
_AMCS = [
    "360 ONE", "Aditya Birla", "Axis", "Bajaj Finserv", "Bandhan", "Bank of India",
    "Baroda BNP Paribas", "Canara Robeco", "DSP", "Edelweiss", "Franklin", "Groww",
    "HDFC", "Helios", "HSBC", "ICICI", "Invesco", "ITI", "JM Financial", "Kotak",
    "LIC", "Mahindra Manulife", "Mirae", "Motilal Oswal", "Navi", "Nippon",
    "NJ", "Parag Parikh", "PGIM", "PPFAS", "Quantum",
    "Samco", "SBI", "Shriram", "Sundaram", "Tata", "Taurus",
    "UTI", "WhiteOak", "Zerodha", "Unifi", "Jio BlackRock", "Angel One",
]
# Names that are also everyday words: flagged only as "<name> Mutual Fund/MF/AMC".
_AMBIGUOUS_AMCS = ["Quant", "quant", "Trust", "Union", "Choice", "Old Bridge"]
_PRODUCT_WORDS = r"(?:fund|funds|mf|mutual fund|amc|etf|fof|scheme|bluechip|flexi ?cap|" \
                 r"large ?cap|mid ?cap|small ?cap|elss|tax ?saver|index|nifty|sensex|" \
                 r"hybrid|liquid|gilt|bond|balanced advantage|value|focused|contra)"
# Brand names are matched case-sensitively (as written in product names);
# product words are case-insensitive.
_AMC_RE = re.compile(
    r"\b(?:" + "|".join(re.escape(a) for a in _AMCS) + r")\b[\w\s&'\-]{0,30}?\b(?i:" + _PRODUCT_WORDS + r")\b"
    r"|\b(?:" + "|".join(re.escape(a) for a in _AMBIGUOUS_AMCS) + r")\s+(?i:mutual fund|mf|amc)\b",
)

# Large listed companies, flagged when presented as a share to buy/hold.
_STOCKS = [
    "Reliance", "TCS", "Infosys", "HDFC Bank", "ICICI Bank", "Bharti Airtel",
    "ITC", "Larsen", "L&T", "Hindustan Unilever", "HUL", "Wipro", "Adani",
    "Bajaj Finance", "Maruti", "Tata Motors", "Tata Steel", "Asian Paints",
    "Titan", "Sun Pharma", "Zomato", "Eternal", "Paytm", "Nykaa", "Kotak Mahindra Bank",
    "Axis Bank", "State Bank of India", "Coal India", "ONGC", "NTPC", "IRFC", "HAL",
]
_STOCK_NAMES = "|".join(re.escape(x) for x in _STOCKS)
_STOCK_RE = re.compile(
    r"\b(?:" + _STOCK_NAMES + r")\b[\w\s&'\-]{0,20}?\b(?i:shares?|stocks?)\b"
    r"|\b(?i:buy|sell|accumulate|invest in)\s+(?:" + _STOCK_NAMES + r")\b",
)

RETRY_INSTRUCTION = (
    "Your previous draft named a specific fund house, scheme or company. "
    "Rewrite the answer using investment categories only (for example "
    "'a large-cap index fund' or 'a liquid fund'), with no brand or company names."
)

SAFE_FALLBACK = (
    "I can't point to specific funds, stocks or companies, but I can explain "
    "the categories people with a profile like yours often consider, such as "
    "index funds, debt funds, gold or PPF, and how each fits your goals. "
    "Which goal would you like to look at?"
)


def find_product_mentions(text: str | None) -> list[str]:
    if not text:
        return []
    return [m.group(0).strip() for m in _AMC_RE.finditer(text)] + \
        [m.group(0).strip() for m in _STOCK_RE.finditer(text)]
