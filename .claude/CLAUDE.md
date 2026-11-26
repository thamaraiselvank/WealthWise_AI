# WealthWise AI — Project Context

> Read this first in every session. It describes what we are building, why, and the decisions already made.
> Status (2026-11-26): **Phase 1, slice 1 done.** Finance engine (31 tests) + Flutter app with onboarding, health dashboard, goals (FI + custom, with "show the math" and target-age what-if), invest & learn. State is **in-memory only**.
> Next: slice 2 = encrypted local persistence (drift + SQLCipher), edit profile, settings (export / delete data).

## 0. Working conventions

- Run tests: `cd packages/finance_engine && dart test` · `cd app && flutter analyze && flutter test`
- Flutter 3.50: import **`package:material_ui/material_ui.dart`**, never `package:flutter/material.dart` (it is deprecated, and its types clash with material_ui's).
- All numbers come from `packages/finance_engine`. UI code must not do financial math itself. Add engine tests for any new calculation.
- App structure: `app/lib/{state, util, widgets, features/<module>}`. State uses Riverpod `Notifier`s in `state/app_state.dart`.
- Every screen with projections or allocations shows the `Disclaimer` widget.

## 1. What WealthWise AI is

An **AI-powered personal financial planning and wealth-education app** for people in India who are new to saving and investing.

It answers one question for the user:
> "Given my current financial situation, what should I do with my money to build a better financial future?"

The user enters age, income, expenses, savings, loans, dependents, current investments, goals and risk preference. The app analyses their finances, builds a goal-based roadmap, explains investment **categories** and illustrative asset allocation, answers questions through an AI assistant, and tracks progress over time.

### What it is NOT
- Not a broker or distributor: no custody of money, no trade execution, no selling mutual funds.
- Not a stock-tip or "buy this fund" app: it never names specific schemes or securities.
- Not a generic chatbot: AI answers are grounded in the user's structured profile and real calculations.

## 2. What makes it unique

| Typical investment apps | WealthWise AI |
|---|---|
| Help users invest / transact | Help users **understand** their finances and decide |
| Show products | Explain investment **categories** (index fund, debt fund, gold, FD, PPF, NPS…) |
| Track portfolio value | Track **financial health** and goal progress |
| Assume investment knowledge | Built for **complete beginners**, plain language |
| Earn from selling products | Earns from subscriptions, so no conflict of interest |
| Black-box numbers | **Shows every calculation and assumption** |
| Data stored on company servers | **Local-first**: user data stays on the phone |

Core principle: **AI explains, the engine calculates.** The AI must never invent returns, rates or projections. All numbers come from the deterministic finance engine or dated market data.

## 3. The five modules (+ onboarding & settings)

0. **Onboarding & Profile**: welcome + privacy promise, basic info, money details, risk questionnaire (Conservative / Moderate / Aggressive, adjusted for time horizon), goal picker.
1. **Financial Health Analyzer**: health score (0–100), savings rate, emergency-fund cover and gap, debt-to-income, insurance check, expense breakdown, top 3 action items.
2. **Goal-Based Planner**: goals (house, car, retirement, education, passive income, wealth creation, financial independence); today's cost → inflation-adjusted cost → required monthly SIP; feasibility; what-if sliders (retire later, save more, annual SIP step-up). Math always visible.
3. **Investment Education & Allocation**: illustrative allocation (equity / debt / gold / cash) by risk profile and horizon, overall and per goal, with a "why" for each; learn library; fund-category explorer with dated historical ranges.
4. **AI Financial Assistant**: chat grounded in the user profile; suggested questions; answers show calculations, sources and dates; research mode for market/news explanations.
5. **Financial Progress Tracker**: monthly check-ins, planned vs actual, net worth over time, review nudges.
- **Settings**: edit profile, backup/export, delete all data, subscription, disclaimers.

## 4. Architecture

```
Flutter app (phone, ~80% of the product)
  - UI, charts
  - Dart finance engine (all calculations)
  - Local encrypted SQLite (profile, goals, check-ins, chat history)
        |
        | HTTPS (only for AI chat, research, market data)
        v
Python backend on Google Cloud Run (thin proxy, NO user database)
  - /chat   -> Gemini (Vertex AI) with guardrail system prompt + function calling
  - /market -> serves cached, dated market data
  - /config -> allocation rules, disclaimers (or Firebase Remote Config)
        ^
Daily job (Cloud Scheduler -> Cloud Run job, Python)
  - Fetches AMFI / RBI / FD-rate data -> Cloud Storage as dated JSON
```

Key decisions:
- **The calculation engine lives only in Dart** (`packages/finance_engine`). Single source of truth.
- **AI tool calls run on the phone.** Gemini asks for a function (e.g. `calculate_goal`), the backend passes the call back to the app, the Dart engine runs it, and the result goes back to Gemini for the explanation. The backend never duplicates the math.
- If a Python copy of any calculation is ever needed, both versions must pass a shared `test_cases.json`.
- **The API key never ships in the app.** All AI calls go through the backend.
- Send the AI **only the numbers it needs** (no name, phone or email). Get user consent before the first AI use. Do not log request bodies on the server.
- Research uses Gemini **Grounding with Google Search**. Always show sources and dates.

## 5. Tech stack

**App (Flutter / Dart)**
- State: Riverpod · Navigation: go_router · HTTP: dio · Charts: fl_chart
- Local DB: drift (SQLite) + sqlcipher_flutter_libs (encryption); key in flutter_secure_storage
- Firebase: App Check (Play Integrity), Anonymous Auth, Remote Config, Crashlytics

**Backend & cloud (Google Cloud, existing subscription)**
- Python + FastAPI on Cloud Run (scales to zero)
- Gemini via Vertex AI: Flash for everyday chat, Pro for deeper research
- Cloud Scheduler + Cloud Run jobs for daily data; Cloud Storage for data JSON; Secret Manager for keys

**Planned repo layout**
```
WealthWise AI/
├── app/                      # Flutter app
├── packages/finance_engine/  # Pure Dart: SIP, inflation, corpus, health score, allocation (no Flutter deps, fully unit-tested)
├── backend/                  # Python FastAPI -> Cloud Run
└── jobs/                     # Python daily data fetch
```

## 6. Tiers (draft, to be validated with users)

Rule: **core planning is free** (builds trust and habit). Charge for AI, depth and convenience. **No ads ever.**

| Feature | Free | Pro (~₹99/mo) | Premium (~₹249/mo) |
|---|---|---|---|
| Onboarding + health score | ✅ | ✅ | ✅ |
| Goals | 2 | Unlimited | Unlimited |
| Allocation | Overall | Per goal | Per goal + rebalancing alerts |
| Learn library | Basic | Full | Full |
| AI assistant | ~5 questions/mo | ~100/mo | High limit + research mode |
| Market data | Monthly snapshot | Daily | Daily + AI monthly market explainer |
| Tracker | Manual check-in | Charts + net worth | + AI monthly review |
| Backup | File export | Google Drive backup | Google Drive backup |
| Reports | None | PDF plan | PDF + yearly review |
| Family profiles | None | None | ✅ |

Possible future **Premium+**: access to a SEBI-registered investment adviser (RIA) through a partnership.

## 7. Build phases

1. **Phase 1 (free core, no backend):** Flutter project, Dart finance engine + tests, onboarding, health analyzer, goal planner, basic allocation, learn cards, local DB.
2. **Phase 2:** Python backend on Cloud Run, AI assistant with on-phone function calling, daily market-data job.
3. **Phase 3:** progress tracker, backup/export, PDF reports.
4. **Phase 4:** subscriptions and tier gating (Play Billing), tier tuning based on usage.

## 8. Rules for compliance, safety and content (must follow)

- Frame all output as **education and illustrative scenarios**: "people with a profile like yours often consider…", never "you should buy X".
- **Never name specific mutual fund schemes, stocks or securities.** Categories only.
- Every projection shows its **assumptions** (inflation, return rate, time) and a disclaimer.
- Market data always carries its **source and date**.
- India regulation: SEBI Investment Adviser Regulations (personalised advice needs RIA registration), and the DPDP Act 2023 for personal data. A legal review is required before public launch.
- Privacy: data minimisation, encryption at rest, easy "delete all my data".

## 9. Defaults and assumptions for calculations (editable later via config)

- Inflation: 6% · Emergency fund: 6 × monthly expenses
- Retirement / FI corpus: 25× annual expenses (show 30–33× as a conservative option for India)
- Illustrative returns (scenarios, not promises): equity ~10–12%, debt ~6–7%, gold ~7–8%
- Worked example: age 25, income ₹40k, expenses ₹25k, savings ₹80k, FI at 45 → surplus ₹15k/mo, emergency gap ₹70k, future expenses ≈ ₹80k/mo, corpus ≈ ₹2.4 Cr, flat SIP needed ≈ ₹27k/mo at 11%. Result: show the gap and the levers (step-up SIP, later age, lower expenses).
