"""LLM adapters. Routes depend only on the `Llm` protocol, so tests and local
development use `FakeLlm` and need no cloud access."""

from __future__ import annotations

import base64
import re
import uuid
from dataclasses import dataclass, field
from typing import Any, Protocol

from .schemas import Message, Source, ToolCall


@dataclass
class LlmResult:
    text: str | None = None
    tool_calls: list[ToolCall] = field(default_factory=list)
    sources: list[Source] = field(default_factory=list)
    model: str = ""


class Llm(Protocol):
    def generate(
        self,
        *,
        system: str,
        messages: list[Message],
        research: bool,
        allow_tools: bool,
    ) -> LlmResult: ...


# ---------------------------------------------------------------------------
# Vertex AI (Gemini)
# ---------------------------------------------------------------------------


class VertexGemini:
    """Gemini on Vertex AI via the google-genai SDK.

    Credentials come from the Cloud Run service account (ADC); no API key.
    Chat mode declares the engine functions. Research mode uses Grounding
    with Google Search instead (the two are not combined in one request).
    """

    def __init__(self, *, project: str, location: str, chat_model: str,
                 research_model: str, max_output_tokens: int, temperature: float,
                 tool_declarations: list[dict[str, Any]]):
        from google import genai  # imported lazily: not needed for tests

        self._client = genai.Client(vertexai=True, project=project, location=location)
        self._chat_model = chat_model
        self._research_model = research_model
        self._max_tokens = max_output_tokens
        self._temperature = temperature
        self._declarations = tool_declarations

    def generate(self, *, system: str, messages: list[Message], research: bool,
                 allow_tools: bool) -> LlmResult:
        from google.genai import types

        if research:
            tools = [types.Tool(google_search=types.GoogleSearch())]
            model = self._research_model
        else:
            tools = [types.Tool(function_declarations=[
                types.FunctionDeclaration(**d) for d in self._declarations
            ])]
            model = self._chat_model

        config = types.GenerateContentConfig(
            system_instruction=system,
            tools=tools,
            temperature=self._temperature,
            max_output_tokens=self._max_tokens,
            automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
        )
        if not research and not allow_tools:
            config.tool_config = types.ToolConfig(
                function_calling_config=types.FunctionCallingConfig(mode="NONE"))

        response = self._client.models.generate_content(
            model=model, contents=to_gemini_contents(messages), config=config)
        return from_gemini_response(response, model)


def to_gemini_contents(messages: list[Message]) -> list[Any]:
    from google.genai import types

    contents = []
    for m in messages:
        if m.role == "user":
            contents.append(types.Content(role="user", parts=[types.Part(text=m.text)]))
        elif m.role == "model":
            parts = []
            if m.text:
                parts.append(types.Part(text=m.text))
            for c in m.tool_calls:
                parts.append(types.Part(
                    function_call=types.FunctionCall(id=c.id, name=c.name, args=c.args),
                    thought_signature=base64.b64decode(c.signature) if c.signature else None,
                ))
            contents.append(types.Content(role="model", parts=parts))
        else:  # tool results go back as a user turn of function responses
            contents.append(types.Content(role="user", parts=[
                types.Part(function_response=types.FunctionResponse(
                    id=r.id, name=r.name, response=r.result))
                for r in m.tool_results
            ]))
    return contents


def from_gemini_response(response: Any, model: str) -> LlmResult:
    result = LlmResult(model=model)
    candidates = getattr(response, "candidates", None) or []
    if not candidates:
        return result
    cand = candidates[0]
    texts: list[str] = []
    for part in (cand.content.parts if cand.content and cand.content.parts else []):
        if getattr(part, "thought", False):
            continue
        if part.function_call:
            fc = part.function_call
            sig = getattr(part, "thought_signature", None)
            result.tool_calls.append(ToolCall(
                id=fc.id or f"call_{uuid.uuid4().hex[:12]}",
                name=fc.name,
                args=dict(fc.args or {}),
                signature=base64.b64encode(sig).decode() if sig else None,
            ))
        elif part.text:
            texts.append(part.text)
    result.text = "".join(texts).strip() or None

    meta = getattr(cand, "grounding_metadata", None)
    seen = set()
    for chunk in (getattr(meta, "grounding_chunks", None) or []):
        web = getattr(chunk, "web", None)
        if web and web.uri and web.uri not in seen:
            seen.add(web.uri)
            result.sources.append(Source(title=web.title or web.domain or web.uri, url=web.uri))
    return result


# ---------------------------------------------------------------------------
# Fake (offline, deterministic)
# ---------------------------------------------------------------------------


class FakeLlm:
    """Rule-based stand-in for local development and tests.

    - A question mentioning retire/independence/goal/health asks the app to run
      the matching engine function (exercises the tool round trip).
    - Once tool results are present, it answers by quoting them.
    """

    model = "fake-llm"

    def __init__(self, scripted: list[LlmResult] | None = None):
        self._scripted = list(scripted or [])
        self.calls: list[dict[str, Any]] = []

    def generate(self, *, system: str, messages: list[Message], research: bool,
                 allow_tools: bool) -> LlmResult:
        self.calls.append({"system": system, "messages": messages,
                           "research": research, "allow_tools": allow_tools})
        if self._scripted:
            return self._scripted.pop(0)

        last = messages[-1]
        if last.role == "tool":
            summary = "; ".join(
                f"{r.name}: " + ", ".join(f"{k}={v}" for k, v in list(r.result.items())[:4])
                for r in last.tool_results)
            return LlmResult(text=f"Here is what the calculation shows. {summary}",
                             model=self.model)

        q = (last.text or "").lower()
        if research:
            return LlmResult(
                text="(offline research mode) I would search the web here and cite sources.",
                sources=[Source(title="Example source", url="https://example.com")],
                model=self.model)
        if allow_tools:
            call = None
            m = re.search(r"retire\w*\s+(?:at\s+)?(\d{2})", q)
            if m or "independen" in q:
                call = ("plan_independence", {"target_age": int(m.group(1)) if m else 55})
            elif "health" in q or "how am i doing" in q:
                call = ("get_health_report", {})
            elif "goal" in q or "house" in q:
                call = ("plan_goal", {"today_cost": 1500000, "years": 8})
            if call:
                return LlmResult(tool_calls=[ToolCall(
                    id=f"call_{uuid.uuid4().hex[:8]}", name=call[0], args=call[1])],
                    model=self.model)
        return LlmResult(
            text="An emergency fund is money kept aside for surprises, usually "
                 "a few months of expenses in a savings account or liquid fund.",
            model=self.model)
