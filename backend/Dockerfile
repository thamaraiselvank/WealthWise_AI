# Build from the REPO ROOT (the image needs shared/assistant_tools.json):
#   gcloud builds submit --config backend/cloudbuild.yaml .
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /srv/backend
COPY backend/requirements.txt .
RUN pip install -r requirements.txt

COPY shared/ /srv/shared/
COPY backend/app/ ./app/

RUN useradd --uid 10001 --no-create-home appuser
USER appuser

# Cloud Run provides $PORT.
CMD exec uvicorn app.main:serve --factory --host 0.0.0.0 --port ${PORT:-8080} \
    --no-access-log --proxy-headers --forwarded-allow-ips='*'
