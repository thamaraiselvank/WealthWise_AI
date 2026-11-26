# WealthWise AI

**An AI-powered personal financial planning and wealth-education app for people new to saving and investing in India.**

WealthWise AI helps users answer one question:

> *"Given my current financial situation, what should I do with my money to build a better financial future?"*

Users enter their age, income, expenses, savings, loans, goals and risk comfort. The app analyses their financial health, builds a goal-based plan, explains investment **categories** with an illustrative asset allocation, and (in later phases) answers questions through an AI assistant and tracks progress.

> ⚠️ WealthWise AI is an **educational tool**, not an investment adviser. It does not sell products, execute trades or recommend specific schemes. All projections are illustrative and based on stated assumptions.

---

## What makes it different

| Typical investment apps | WealthWise AI |
|---|---|
| Help you transact | Help you **understand and decide** |
| Show products | Explain investment **categories** |
| Track portfolio value | Track **financial health** and goal progress |
| Assume investment knowledge | Built for **complete beginners** |
| Earn from selling products | No conflict of interest |
| Black-box numbers | **Shows every calculation and assumption** |
| Data on company servers | **Local-first**: your data stays on your phone |

Core principle: **AI explains, the engine calculates.** Every number comes from a deterministic, unit-tested finance engine, never from an AI guess.

---

## Modules

| # | Module | Status |
|---|---|---|
| 0 | Onboarding & profile | ✅ Phase 1 |
| 1 | Financial health analyzer: score, savings rate, emergency fund, debt load, next steps | ✅ Phase 1 |
| 2 | Goal-based planner: FI / retirement + custom goals, inflation-adjusted SIPs, "show the math", what-if | ✅ Phase 1 |
| 3 | Investment education & allocation: risk profile, illustrative mix, learn cards | ✅ Phase 1 |
| 4 | AI financial assistant (Gemini, grounded in your numbers) | ⏳ Phase 2 |
| 5 | Progress tracker: check-ins, goal progress, net worth | ⏳ Phase 3 |
| ⚙️ | Settings: edit profile, retake risk quiz, edit goals, export data, delete all data | ✅ Phase 1 |

---

## Architecture

```
Flutter app (on the phone, ~80% of the product)
  ├─ UI + charts
  ├─ finance_engine (Dart): all calculations
  └─ Encrypted local SQLite (drift + SQLite3MultipleCiphers)
          │ HTTPS: only for AI chat, research and market data
          ▼
Python backend on Google Cloud Run (thin proxy, no user database)   [Phase 2]
  ├─ /chat   → Gemini (Vertex AI) + guardrails + function calling
  └─ /market → cached, dated market data (daily job: AMFI / RBI)
```

---

## Repository layout

```
WealthWise_AI/
├── app/                        # Flutter app (Android + iOS)
│   └── lib/
│       ├── state/              # Riverpod state
│       ├── util/               # Formatting helpers (₹, lakh/crore)
│       ├── widgets/            # Shared UI (charts, cards, disclaimer)
│       └── features/           # onboarding, health, goals, invest, home
├── packages/
│   └── finance_engine/         # Pure Dart calculation engine + tests
├── .claude/CLAUDE.md           # Project context for AI-assisted development
└── README.md
```

---

## Getting started

**Requirements:** Flutter 3.50+ (Dart 3.14+), Android Studio with an emulator or a device.

```bash
# Run the finance engine tests
cd packages/finance_engine
dart pub get
dart test

# Run the app
cd ../../app
flutter pub get
dart run build_runner build   # only needed after changing database tables
flutter run
```

On the first screen, tap **"Just exploring? Try with sample data"** to see a full plan instantly.

```bash
# App checks
cd app
flutter analyze
flutter test
```

---

## Privacy & data

- All personal data is stored **only on the phone**, in a SQLite database encrypted with [SQLite3MultipleCiphers](https://utelle.github.io/SQLite3MultipleCiphers/).
- The 256-bit key is generated on the device and kept in the Android Keystore / iOS Keychain (`flutter_secure_storage`).
- Android cloud backup and device-to-device transfer are disabled for app data, so the encrypted file is never separated from its key.
- Users can **export** their data as JSON and **delete everything** from Settings.

## Default assumptions

Illustrative only, shown to users on every plan:

| Assumption | Value |
|---|---|
| Inflation | 6% |
| Emergency fund | 6 × monthly expenses (incl. EMIs) |
| FI / retirement corpus | 25 × annual expenses |
| Equity / Debt / Gold / Cash returns | 11% / 6.5% / 7.5% / 3.5% |
| SIP timing | Start of each month |

---

## Roadmap

- **Phase 1:** Finance engine, onboarding, health, goals, allocation, learn, encrypted local storage, settings, export / delete data. *Next: polish (expense breakdown, app icon, accessibility).*
- **Phase 2:** Python backend on Cloud Run, AI assistant (Gemini), daily market-data job.
- **Phase 3:** Progress tracker, backup, PDF reports.
- **Phase 4:** Free / Pro / Premium tiers.

---

## Disclaimer

WealthWise AI provides financial **education** and illustrative scenarios only. It is not investment, tax or legal advice. Returns are assumptions, not guarantees. For personalised advice, consult a SEBI-registered investment adviser.
