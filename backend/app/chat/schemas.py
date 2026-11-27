"""Wire format between the app and /v1/chat.

The server is stateless: the app sends the whole conversation each time
(including earlier tool calls and their results) and stores it on the phone.

Privacy: the profile is a strict whitelist of numbers and enums. Names,
phone numbers, emails, free-text goal names and loan labels are never
accepted (`extra="forbid"` rejects unknown fields).
"""

import json
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

Money = float  # rupees


class _Strict(BaseModel):
    model_config = ConfigDict(extra="forbid")


GoalType = Literal[
    "house", "car", "retirement", "education", "passiveIncome",
    "wealthCreation", "financialIndependence", "other",
]
LoanType = Literal["home", "vehicle", "personal", "education", "creditCard", "gold", "other"]
AssumptionKey = Literal[
    "inflation", "equityReturn", "debtReturn", "goldReturn", "cashReturn",
    "sipStepUp", "emergencyFundMonths", "corpusMultiple",
]


class GoalSummary(_Strict):
    type: GoalType
    today_cost: Money = Field(ge=0, le=1e11)
    years: float = Field(ge=0, le=80)
    already_saved: Money = Field(default=0, ge=0, le=1e11)


class LoanSummary(_Strict):
    type: LoanType
    outstanding: Money = Field(ge=0, le=1e11)
    emi: Money = Field(default=0, ge=0, le=1e9)
    annual_rate: float | None = Field(default=None, ge=0, le=1)


class ProfileSummary(_Strict):
    """Only the numbers the assistant needs. All optional."""

    age: int | None = Field(default=None, ge=0, le=120)
    dependents: int | None = Field(default=None, ge=0, le=30)
    monthly_income: Money | None = Field(default=None, ge=0, le=1e10)
    monthly_expenses: Money | None = Field(default=None, ge=0, le=1e10)
    monthly_emi: Money | None = Field(default=None, ge=0, le=1e10)
    monthly_surplus: Money | None = Field(default=None, ge=-1e10, le=1e10)
    savings: Money | None = Field(default=None, ge=0, le=1e12)
    investments: Money | None = Field(default=None, ge=0, le=1e12)
    property_value: Money | None = Field(default=None, ge=0, le=1e12)
    loans_total: Money | None = Field(default=None, ge=0, le=1e12)
    net_worth: Money | None = Field(default=None, ge=-1e12, le=1e12)
    has_health_insurance: bool | None = None
    has_term_insurance: bool | None = None
    risk_profile: Literal["conservative", "moderate", "aggressive"] | None = None
    fi_target_age: int | None = Field(default=None, ge=0, le=120)
    health_score: int | None = Field(default=None, ge=0, le=100)
    goals: list[GoalSummary] = Field(default_factory=list, max_length=20)
    loans: list[LoanSummary] = Field(default_factory=list, max_length=20)
    assumptions: dict[AssumptionKey, float] = Field(default_factory=dict)


class ToolCall(_Strict):
    id: str = Field(max_length=100)
    name: str = Field(max_length=64)
    args: dict[str, Any] = Field(default_factory=dict)
    # Opaque Gemini "thought signature" (base64). The app echoes it back
    # unchanged so multi-step function calling keeps working.
    signature: str | None = Field(default=None, max_length=20000)


MAX_TOOL_RESULT_BYTES = 8000


class ToolResult(_Strict):
    id: str = Field(max_length=100)
    name: str = Field(max_length=64)
    result: dict[str, Any]

    @field_validator("result")
    @classmethod
    def _small(cls, v: dict[str, Any]) -> dict[str, Any]:
        if len(json.dumps(v, ensure_ascii=False)) > MAX_TOOL_RESULT_BYTES:
            raise ValueError("tool result too large")
        return v


class Message(_Strict):
    role: Literal["user", "model", "tool"]
    text: str | None = Field(default=None, max_length=8000)
    tool_calls: list[ToolCall] = Field(default_factory=list, max_length=8)
    tool_results: list[ToolResult] = Field(default_factory=list, max_length=8)

    @model_validator(mode="after")
    def _shape(self) -> "Message":
        if self.role == "user" and not (self.text and self.text.strip()):
            raise ValueError("user messages need text")
        if self.role == "user" and (self.tool_calls or self.tool_results):
            raise ValueError("user messages cannot carry tool data")
        if self.role == "tool" and not self.tool_results:
            raise ValueError("tool messages need tool_results")
        if self.role == "model" and not (self.text or self.tool_calls):
            raise ValueError("model messages need text or tool_calls")
        return self


class ChatRequest(_Strict):
    mode: Literal["chat", "research"] = "chat"
    profile: ProfileSummary = Field(default_factory=ProfileSummary)
    messages: list[Message] = Field(min_length=1)

    @model_validator(mode="after")
    def _last_is_user_or_tool(self) -> "ChatRequest":
        if self.messages[-1].role == "model":
            raise ValueError("the last message must be from the user or a tool")
        return self


class Source(BaseModel):
    title: str
    url: str


class ChatResponse(BaseModel):
    type: Literal["answer", "tool_calls"]
    text: str | None = None
    tool_calls: list[ToolCall] = Field(default_factory=list)
    sources: list[Source] = Field(default_factory=list)
    model: str
    # ISO date the answer was produced (research answers are time-sensitive).
    as_of: str
    disclaimer: str | None = None
    remaining_questions: int | None = None
