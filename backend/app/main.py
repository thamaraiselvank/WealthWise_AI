"""WealthWise AI backend: a thin, stateless proxy.

- POST /v1/chat    Gemini with guardrails; engine functions run on the phone
- GET  /v1/market  dated market-data snapshot (written by the daily job)
- GET  /v1/config  default assumptions, disclaimer, suggested questions
- GET  /healthz    liveness

No user database. Request bodies are never logged.
"""

import json
import logging
import time
from pathlib import Path

from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from .chat.llm import FakeLlm, Llm, VertexGemini
from .chat.schemas import ChatRequest, ChatResponse
from .chat.service import handle_chat
from .chat.tools import TOOL_DECLARATIONS
from .market import MarketStore
from .quota import InMemoryQuota, QuotaStore
from .security import Caller, verify_caller
from .settings import Settings, get_settings

log = logging.getLogger("wealthwise")

_CONFIG = json.loads((Path(__file__).parent / "remote_config.json").read_text(encoding="utf-8"))
_CONFIG.pop("_comment", None)


def build_llm(settings: Settings) -> Llm:
    if settings.llm_provider == "vertex":
        return VertexGemini(
            project=settings.gcp_project,
            location=settings.gcp_location,
            chat_model=settings.chat_model,
            research_model=settings.research_model,
            max_output_tokens=settings.max_output_tokens,
            temperature=settings.temperature,
            tool_declarations=TOOL_DECLARATIONS,
        )
    return FakeLlm()


def create_app(settings: Settings | None = None, *, llm: Llm | None = None,
               quota: QuotaStore | None = None, market: MarketStore | None = None) -> FastAPI:
    settings = settings or get_settings()
    llm = llm or build_llm(settings)
    quota = quota or InMemoryQuota()
    market = market or MarketStore(settings)

    app = FastAPI(
        title="WealthWise AI backend",
        version="0.1.0",
        docs_url="/docs" if settings.env == "dev" else None,
        redoc_url=None,
        openapi_url="/openapi.json" if settings.env == "dev" else None,
    )
    app.dependency_overrides[get_settings] = lambda: settings

    @app.middleware("http")
    async def access_log(request: Request, call_next):
        # Method, path, status and latency only: never headers or bodies.
        start = time.perf_counter()
        response = await call_next(request)
        log.info("%s %s %s %.0fms", request.method, request.url.path,
                 response.status_code, (time.perf_counter() - start) * 1000)
        return response

    @app.exception_handler(RequestValidationError)
    async def validation_error(_: Request, exc: RequestValidationError):
        # Default handler echoes the rejected input back; drop it.
        errors = [{"loc": e.get("loc"), "msg": e.get("msg")} for e in exc.errors()]
        return JSONResponse(status_code=422, content={"detail": errors})

    @app.get("/healthz")
    def healthz() -> dict[str, str]:
        return {"status": "ok"}

    @app.post("/v1/chat", response_model=ChatResponse, response_model_exclude_none=True)
    def chat(req: ChatRequest, caller: Caller = Depends(verify_caller)) -> ChatResponse:
        try:
            return handle_chat(req, user_id=caller.user_id, llm=llm, quota=quota,
                               settings=settings)
        except HTTPException:
            raise
        except Exception:  # noqa: BLE001
            log.exception("chat failed")  # stack trace only; no request content
            raise HTTPException(502, detail="the assistant is unavailable, please try again") from None

    @app.get("/v1/market")
    def market_data(response: Response, _: Caller = Depends(verify_caller)):
        data = market.latest()
        if data is None:
            raise HTTPException(503, detail="market data not available yet")
        response.headers["Cache-Control"] = "public, max-age=3600"
        return data

    @app.get("/v1/config")
    def config(response: Response):
        response.headers["Cache-Control"] = "public, max-age=3600"
        return _CONFIG

    return app


def serve() -> FastAPI:
    """Entry point: `uvicorn app.main:serve --factory`."""
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s %(message)s")
    return create_app()
