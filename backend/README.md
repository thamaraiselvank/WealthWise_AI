# WealthWise AI backend

Thin, stateless FastAPI service for Cloud Run. It holds **no user database**.

| Endpoint | What it does |
|---|---|
| `POST /v1/chat` | Gemini (Vertex AI) with guardrails. Calculations run **on the phone**: the model asks for a function, this server returns `type: "tool_calls"`, the app runs the Dart engine and calls back with `role: "tool"` results, and the model explains them. |
| `GET /v1/market` | Latest dated market snapshot written by `jobs/market_data`. |
| `GET /v1/config` | Default assumptions, disclaimer, suggested questions (`app/remote_config.json`). |
| `GET /healthz` | Liveness. |

Function declarations live in `../shared/assistant_tools.json`, which both this
service and the app's tool runner test against.

## Safety and privacy

- The profile is a **strict whitelist** of numbers/enums (`chat/schemas.py`). Names, emails, goal names and loan labels are rejected, and 422 responses don't echo input back.
- The system prompt (`chat/prompts.py`) forbids inventing numbers and naming schemes or stocks. The output guard (`chat/guard.py`) checks for fund-house, scheme and stock names: it regenerates the answer once, then falls back to a safe message.
- Logs contain only method, path, status and latency. Bodies are never logged.
- Prod refuses to start unless Vertex, Firebase Auth and App Check are all on (`Settings.validate_for_prod`).
- Quotas: one question is counted when its final answer is returned. The in-memory store is per-instance, so **replace it with a Firestore-backed `QuotaStore` before launch**.

## Run locally (no cloud needed)

```bash
# from the repo root
python -m venv .venv && .venv/Scripts/pip install -r backend/requirements-dev.txt
cd backend
../.venv/Scripts/python -m pytest -q
../.venv/Scripts/python -m uvicorn app.main:serve --factory --reload --port 8080
```

The default `WW_LLM_PROVIDER=fake` is a rule-based offline model that still
exercises the tool round trip. To try real Gemini locally:
`gcloud auth application-default login`, then set `WW_LLM_PROVIDER=vertex` and
`WW_GCP_PROJECT=<project>`.

The Android emulator reaches your PC at `http://10.0.2.2:8080`.

## Configuration (env vars, prefix `WW_`)

| Var | Default | Notes |
|---|---|---|
| `WW_ENV` | `dev` | `prod` enables the safety checks and hides `/docs` |
| `WW_LLM_PROVIDER` | `fake` | `vertex` in prod |
| `WW_GCP_PROJECT`, `WW_GCP_LOCATION` | – / `asia-south1` | |
| `WW_CHAT_MODEL`, `WW_RESEARCH_MODEL` | `gemini-2.5-flash` / `gemini-2.5-pro` | Update to the newest models available in your region |
| `WW_REQUIRE_AUTH`, `WW_REQUIRE_APP_CHECK` | `false` | `true` in prod |
| `WW_FIREBASE_PROJECT` | GCP project | |
| `WW_MONTHLY_QUESTION_LIMIT` | `100` | Hard server ceiling; tier limits come later |
| `WW_MARKET_SOURCE` | `../jobs/market_data/out` | `gs://<bucket>/market` in prod |

## One-time Google Cloud setup (when the project ID is ready)

```bash
PROJECT=<project-id>; REGION=asia-south1; BUCKET=$PROJECT-market-data
gcloud config set project $PROJECT
gcloud services enable run.googleapis.com aiplatform.googleapis.com \
  cloudbuild.googleapis.com artifactregistry.googleapis.com \
  cloudscheduler.googleapis.com storage.googleapis.com firebaseappcheck.googleapis.com
gcloud artifacts repositories create wealthwise --repository-format=docker --location=$REGION
gcloud storage buckets create gs://$BUCKET --location=$REGION --uniform-bucket-level-access

# Service account for the API: Vertex AI + read market data + verify Firebase tokens
gcloud iam service-accounts create wealthwise-api
SA=wealthwise-api@$PROJECT.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:$SA --role=roles/aiplatform.user
gcloud storage buckets add-iam-policy-binding gs://$BUCKET --member=serviceAccount:$SA --role=roles/storage.objectViewer
gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:$SA --role=roles/firebaseappcheck.tokenVerifier

# Build + deploy (from the repo root)
gcloud builds submit --config backend/cloudbuild.yaml --substitutions=_REGION=$REGION,_MARKET_BUCKET=$BUCKET .
```

Firebase: add the project to Firebase, enable **Anonymous** sign-in, register
the Android app (`applicationId` in `app/android/app/build.gradle.kts`), and
enable **App Check with Play Integrity**.
