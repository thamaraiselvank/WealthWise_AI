"""Runtime configuration, read from environment variables (Cloud Run sets them).

Nothing secret lives in code. On Cloud Run the service account provides
Vertex AI and Cloud Storage access, so no API key is needed at all.
"""

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="WW_", env_file=".env", extra="ignore")

    env: Literal["dev", "prod"] = "dev"

    # --- AI ---------------------------------------------------------------
    # "fake" runs a deterministic offline model (local dev and tests).
    llm_provider: Literal["vertex", "fake"] = "fake"
    gcp_project: str = ""
    gcp_location: str = "asia-south1"
    # Model ids are configuration: update them as newer Gemini models ship.
    chat_model: str = "gemini-2.5-flash"
    research_model: str = "gemini-2.5-pro"
    max_output_tokens: int = 1024
    temperature: float = 0.3

    # --- Abuse protection ---------------------------------------------------
    # Verify Firebase ID tokens (anonymous auth) and App Check tokens.
    require_auth: bool = False
    require_app_check: bool = False
    firebase_project: str = ""
    # Questions per user per calendar month (tier limits live in the app/config
    # later; this is the hard server-side ceiling).
    monthly_question_limit: int = 100
    max_messages: int = 30
    max_message_chars: int = 2000

    # --- Market data -------------------------------------------------------
    # gs://bucket/prefix in prod, or a local directory in dev.
    market_source: str = "../jobs/market_data/out"
    market_cache_seconds: int = 600

    def validate_for_prod(self) -> None:
        """Fail fast on unsafe production settings."""
        if self.env != "prod":
            return
        problems = []
        if self.llm_provider != "vertex":
            problems.append("WW_LLM_PROVIDER must be 'vertex' in prod")
        if not self.gcp_project:
            problems.append("WW_GCP_PROJECT is required in prod")
        if not self.require_auth or not self.require_app_check:
            problems.append("WW_REQUIRE_AUTH and WW_REQUIRE_APP_CHECK must be true in prod")
        if not self.market_source.startswith("gs://"):
            problems.append("WW_MARKET_SOURCE must be a gs:// path in prod")
        if problems:
            raise RuntimeError("; ".join(problems))


@lru_cache
def get_settings() -> Settings:
    s = Settings()
    s.validate_for_prod()
    return s
