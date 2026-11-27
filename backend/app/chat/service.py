"""One chat turn: validate, check quota, call the model, guard the output."""

from datetime import date

from fastapi import HTTPException, status

from ..quota import QuotaStore
from ..settings import Settings
from . import guard
from .llm import Llm, LlmResult
from .prompts import DISCLAIMER, system_instruction
from .schemas import ChatRequest, ChatResponse, Message
from .tools import MAX_TOOL_ROUNDS, TOOL_NAMES

NO_ANSWER = "Sorry, I couldn't put an answer together. Could you rephrase the question?"


def _bad_request(detail: str) -> HTTPException:
    return HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, detail=detail)


def _validate_conversation(req: ChatRequest, settings: Settings) -> None:
    if len(req.messages) > settings.max_messages:
        raise _bad_request(f"conversation too long (max {settings.max_messages} messages)")
    pending: set[str] = set()
    for m in req.messages:
        if m.role == "user" and len(m.text or "") > settings.max_message_chars:
            raise _bad_request(f"message too long (max {settings.max_message_chars} characters)")
        if m.role == "model":
            for c in m.tool_calls:
                if c.name not in TOOL_NAMES:
                    raise _bad_request(f"unknown tool {c.name!r}")
            pending = {c.id for c in m.tool_calls}
        elif m.role == "tool":
            ids = {r.id for r in m.tool_results}
            if not ids or not ids <= pending:
                raise _bad_request("tool results must answer the preceding tool calls")
            pending = set()
        else:
            pending = set()


def _tool_rounds_since_question(messages: list[Message]) -> int:
    rounds = 0
    for m in reversed(messages):
        if m.role == "user":
            break
        if m.role == "tool":
            rounds += 1
    return rounds


def handle_chat(req: ChatRequest, *, user_id: str, llm: Llm, quota: QuotaStore,
                settings: Settings, today: date | None = None) -> ChatResponse:
    _validate_conversation(req, settings)

    new_question = req.messages[-1].role == "user"
    limit = settings.monthly_question_limit
    if new_question and quota.remaining(user_id, limit) <= 0:
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS,
                            detail="monthly question limit reached")

    research = req.mode == "research"
    allow_tools = not research and _tool_rounds_since_question(req.messages) < MAX_TOOL_ROUNDS
    today_s = (today or date.today()).isoformat()
    system = system_instruction(req.profile, research=research, today=today_s)

    result = llm.generate(system=system, messages=req.messages, research=research,
                          allow_tools=allow_tools)

    calls = [c for c in result.tool_calls if c.name in TOOL_NAMES] if allow_tools else []
    if calls:
        # Not a finished answer yet: the app runs these and calls back.
        return ChatResponse(type="tool_calls", tool_calls=calls, model=result.model,
                            as_of=today_s)

    result = _guarded(result, llm=llm, system=system, messages=req.messages, research=research)

    # A question counts once, when its final answer is returned (whether or
    # not tool round trips happened on the way).
    remaining = quota.consume(user_id, limit)
    if remaining is None:  # used up by parallel requests meanwhile
        remaining = 0

    return ChatResponse(
        type="answer",
        text=result.text or NO_ANSWER,
        sources=result.sources,
        model=result.model,
        as_of=today_s,
        disclaimer=DISCLAIMER,
        remaining_questions=remaining,
    )


def _guarded(result: LlmResult, *, llm: Llm, system: str, messages: list[Message],
             research: bool) -> LlmResult:
    if not guard.find_product_mentions(result.text):
        return result
    retry_messages = [
        *messages,
        Message(role="model", text=result.text),
        Message(role="user", text=guard.RETRY_INSTRUCTION),
    ]
    second = llm.generate(system=system, messages=retry_messages, research=research,
                          allow_tools=False)
    if second.text and not guard.find_product_mentions(second.text):
        if not second.sources:
            second.sources = result.sources
        return second
    return LlmResult(text=guard.SAFE_FALLBACK, sources=[], model=result.model)
