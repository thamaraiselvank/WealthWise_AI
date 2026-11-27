# Build from this directory:  gcloud builds submit --tag <image> jobs/market_data
FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1
WORKDIR /job
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY reference_rates.json .
COPY market_job/ ./market_job/
RUN useradd --uid 10001 --no-create-home jobuser
USER jobuser
# Output location comes from WW_MARKET_OUT (gs://bucket/market).
CMD exec python -m market_job.main --out "${WW_MARKET_OUT:-out}"
