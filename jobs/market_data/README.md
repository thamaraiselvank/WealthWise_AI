# Daily market-data job

Fetches AMFI's daily NAV file plus the NAVs from 1, 3 and 5 years ago, and
publishes **category-level** return statistics (median and middle-50% range
of direct-plan growth options) as dated JSON. Scheme names and codes are never
published: the app explains categories, not products.

Output (`latest.json` + `<as_of>.json`):

```json
{ "schema": 1, "as_of": "2026-11-26", "source": {...},
  "categories": [{ "key": "large_cap", "label": "Large-cap funds", "asset_class": "equity",
                   "about": "...", "schemes_tracked": 34,
                   "returns": { "5y": { "median": 0.112, "p25": 0.102, "p75": 0.124,
                                        "schemes": 27, "from": "2021-11-26", "to": "2026-11-26" } } }],
  "reference_rates": {}, "disclaimer": "..." }
```

- A statistic is published only with at least 5 schemes.
- NAV ratios outside 0.25–10× (unit splits, mergers) are ignored.
- If a history date is a holiday, up to 7 earlier days are tried.
- `reference_rates.json` holds manually maintained headline rates (repo rate,
  CPI, PPF, EPF). Entries stay unpublished until someone fills `value`, `as_of`
  and `source_url` from the official source.

## Run locally

```bash
cd jobs/market_data
../../.venv/Scripts/pip install -r requirements-dev.txt
../../.venv/Scripts/python -m pytest -q
../../.venv/Scripts/python -m market_job.main --out out   # backend dev reads ../jobs/market_data/out
```

## Deploy (when the project is ready)

```bash
PROJECT=<project-id>; REGION=asia-south1; BUCKET=$PROJECT-market-data
gcloud iam service-accounts create wealthwise-market-job
JOB_SA=wealthwise-market-job@$PROJECT.iam.gserviceaccount.com
gcloud storage buckets add-iam-policy-binding gs://$BUCKET --member=serviceAccount:$JOB_SA --role=roles/storage.objectAdmin

IMAGE=$REGION-docker.pkg.dev/$PROJECT/wealthwise/market-job
gcloud builds submit --tag $IMAGE jobs/market_data
gcloud run jobs create market-data --image=$IMAGE --region=$REGION \
  --service-account=$JOB_SA --set-env-vars=WW_MARKET_OUT=gs://$BUCKET/market \
  --max-retries=2 --task-timeout=15m --memory=1Gi

# Every day at 23:30 IST (AMFI publishes NAVs in the evening)
gcloud iam service-accounts create wealthwise-scheduler
SCHED_SA=wealthwise-scheduler@$PROJECT.iam.gserviceaccount.com
gcloud run jobs add-iam-policy-binding market-data --region=$REGION \
  --member=serviceAccount:$SCHED_SA --role=roles/run.invoker
gcloud scheduler jobs create http market-data-daily --location=$REGION \
  --schedule="30 23 * * *" --time-zone=Asia/Kolkata \
  --uri="https://run.googleapis.com/v2/projects/$PROJECT/locations/$REGION/jobs/market-data:run" \
  --http-method=POST --oauth-service-account-email=$SCHED_SA
```
