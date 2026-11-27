import base64
import json

import pytest
from fastapi.testclient import TestClient

from app.chat import guard
from app.chat.llm import FakeLlm, LlmResult, from_gemini_response, to_gemini_contents
from app.chat.schemas import Message, Source, ToolCall
from app.chat.tools import TOOL_NAMES
from app.main import create_app
from app.market import MarketStore
from app.quota import InMemoryQuota
from app.settings import Settings

PROFILE = {"age": 25, "monthly_income": 40000, "monthly_expenses": 25000,
           "savings": 80000, "risk_profile": "moderate", "fi_target_age": 45,
           "goals": [{"type": "house", "today_cost": 1500000, "years": 8}]}


def make_client(tmp_path, llm=None, **overrides):
    settings = Settings(market_source=str(tmp_path), **overrides)
    llm = llm or FakeLlm()
    app = create_app(settings, llm=llm, quota=InMemoryQuota(),
                     market=MarketStore(settings))
    return TestClient(app), llm


def ask(client, messages, profile=PROFILE, mode="chat"):
    return client.post("/v1/chat", json={"mode": mode, "profile": profile, "messages": messages})


def test_healthz_and_config(tmp_path):
    client, _ = make_client(tmp_path)
    assert client.get("/healthz").json() == {"status": "ok"}
    cfg = client.get("/v1/config").json()
    assert cfg["assumptions"]["inflation"] == 0.06
    assert "_comment" not in cfg


def test_plain_answer_has_disclaimer_and_quota(tmp_path):
    client, _ = make_client(tmp_path, monthly_question_limit=3)
    r = ask(client, [{"role": "user", "text": "What is an emergency fund?"}])
    assert r.status_code == 200
    body = r.json()
    assert body["type"] == "answer"
    assert "emergency fund" in body["text"].lower()
    assert "not investment advice" in body["disclaimer"]
    assert body["remaining_questions"] == 2


def test_tool_round_trip(tmp_path):
    client, llm = make_client(tmp_path)
    first = ask(client, [{"role": "user", "text": "Can I retire at 50?"}]).json()
    assert first["type"] == "tool_calls"
    call = first["tool_calls"][0]
    assert call["name"] == "plan_independence"
    assert call["args"] == {"target_age": 50}

    # The app runs the engine and sends the result back.
    second = ask(client, [
        {"role": "user", "text": "Can I retire at 50?"},
        {"role": "model", "tool_calls": [call]},
        {"role": "tool", "tool_results": [{"id": call["id"], "name": call["name"],
                                            "result": {"required_sip": 41000, "corpus": 30000000}}]},
    ]).json()
    assert second["type"] == "answer"
    assert "required_sip=41000" in second["text"]
    # Only the new question counted, not the tool continuation.
    assert second["remaining_questions"] == 99

    # The profile reached the system prompt, and only as numbers.
    system = llm.calls[0]["system"]
    assert '"monthly_income": 40000' in system
    assert "Never name or recommend a specific mutual fund" in system


def test_quota_exhausted(tmp_path):
    client, _ = make_client(tmp_path, monthly_question_limit=1)
    assert ask(client, [{"role": "user", "text": "hi"}]).status_code == 200
    r = ask(client, [{"role": "user", "text": "hi again"}])
    assert r.status_code == 429


@pytest.mark.parametrize("profile", [
    {"name": "Asha"},
    {"email": "a@b.c"},
    {"goals": [{"type": "house", "today_cost": 1, "years": 1, "name": "My flat in Pune"}]},
    {"loans": [{"type": "home", "outstanding": 1, "label": "SBI loan"}]},
    {"age": -1},
])
def test_profile_whitelist_rejects_personal_or_bad_fields(tmp_path, profile):
    client, _ = make_client(tmp_path)
    r = ask(client, [{"role": "user", "text": "hi"}], profile=profile)
    assert r.status_code == 422
    # The rejected input is not echoed back.
    assert "Asha" not in r.text and "Pune" not in r.text and "a@b.c" not in r.text


def test_rejects_unknown_tools_and_orphan_results(tmp_path):
    client, _ = make_client(tmp_path)
    bad_tool = ask(client, [
        {"role": "user", "text": "x"},
        {"role": "model", "tool_calls": [{"id": "1", "name": "send_money", "args": {}}]},
        {"role": "tool", "tool_results": [{"id": "1", "name": "send_money", "result": {}}]},
    ])
    assert bad_tool.status_code == 422
    orphan = ask(client, [
        {"role": "user", "text": "x"},
        {"role": "tool", "tool_results": [{"id": "9", "name": "get_health_report", "result": {}}]},
    ])
    assert orphan.status_code == 422


def test_last_message_cannot_be_model(tmp_path):
    client, _ = make_client(tmp_path)
    r = ask(client, [{"role": "user", "text": "x"}, {"role": "model", "text": "y"}])
    assert r.status_code == 422


def test_message_and_conversation_limits(tmp_path):
    client, _ = make_client(tmp_path, max_message_chars=10, max_messages=3)
    assert ask(client, [{"role": "user", "text": "x" * 11}]).status_code == 422
    msgs = [{"role": "user", "text": "a"}, {"role": "model", "text": "b"}] * 2
    msgs.append({"role": "user", "text": "c"})
    assert ask(client, msgs).status_code == 422


def test_tool_loop_is_capped(tmp_path):
    llm = FakeLlm()
    client, _ = make_client(tmp_path, llm=llm)
    msgs = [{"role": "user", "text": "how is my health"}]
    for i in range(4):
        call = {"id": f"c{i}", "name": "get_health_report", "args": {}}
        msgs += [{"role": "model", "tool_calls": [call]},
                 {"role": "tool", "tool_results": [{"id": f"c{i}", "name": "get_health_report",
                                                    "result": {"score": 70}}]}]
    r = ask(client, msgs).json()
    assert r["type"] == "answer"
    assert llm.calls[-1]["allow_tools"] is False


def test_product_names_are_regenerated_then_replaced(tmp_path):
    llm = FakeLlm(scripted=[
        LlmResult(text="Try the HDFC Flexi Cap Fund.", model="m"),
        LlmResult(text="A flexi-cap fund spreads money across company sizes.", model="m"),
    ])
    client, _ = make_client(tmp_path, llm=llm)
    r = ask(client, [{"role": "user", "text": "which fund?"}]).json()
    assert r["text"].startswith("A flexi-cap fund")
    assert llm.calls[1]["messages"][-1].text == guard.RETRY_INSTRUCTION

    llm2 = FakeLlm(scripted=[LlmResult(text="Buy Reliance shares.", model="m"),
                             LlmResult(text="Still: buy Reliance.", model="m")])
    client2, _ = make_client(tmp_path, llm=llm2)
    r2 = ask(client2, [{"role": "user", "text": "which stock?"}]).json()
    assert r2["text"] == guard.SAFE_FALLBACK


def test_research_mode_returns_sources_and_no_tools(tmp_path):
    client, llm = make_client(tmp_path)
    r = ask(client, [{"role": "user", "text": "What did RBI do with rates?"}], mode="research").json()
    assert r["type"] == "answer"
    assert r["sources"][0]["url"].startswith("https://")
    assert llm.calls[0]["research"] is True
    assert "RESEARCH MODE" in llm.calls[0]["system"]


def test_llm_failure_is_502_without_details(tmp_path):
    class Boom(FakeLlm):
        def generate(self, **kw):
            raise RuntimeError("secret internal detail")

    client, _ = make_client(tmp_path, llm=Boom())
    r = ask(client, [{"role": "user", "text": "hi"}])
    assert r.status_code == 502
    assert "secret" not in r.text


def test_market_endpoint(tmp_path):
    client, _ = make_client(tmp_path)
    assert client.get("/v1/market").status_code == 503
    (tmp_path / "latest.json").write_text(json.dumps({"as_of": "2026-11-26", "categories": []}))
    client, _ = make_client(tmp_path)
    assert client.get("/v1/market").json()["as_of"] == "2026-11-26"


def test_auth_required_when_enabled(tmp_path):
    client, _ = make_client(tmp_path, require_auth=True)
    r = ask(client, [{"role": "user", "text": "hi"}])
    assert r.status_code == 401


def test_prod_settings_must_be_safe():
    with pytest.raises(RuntimeError, match="WW_LLM_PROVIDER"):
        Settings(env="prod").validate_for_prod()
    Settings(env="prod", llm_provider="vertex", gcp_project="p", require_auth=True,
             require_app_check=True, market_source="gs://b/market").validate_for_prod()


# --- Guard -------------------------------------------------------------------

@pytest.mark.parametrize("text", [
    "Consider the HDFC Flexi Cap Fund",
    "Axis MF has a good one",
    "SBI Bluechip is popular",
    "Parag Parikh Flexi Cap",
    "buy Infosys",
    "TCS shares look cheap",
    "the Quant Mutual Fund range",
])
def test_guard_flags_products(text):
    assert guard.find_product_mentions(text)


@pytest.mark.parametrize("text", [
    "A large-cap index fund tracks the Nifty 50.",
    "Keep your emergency fund in a savings account, for example at your own bank.",
    "Many people trust index funds for long-term goals.",
    "Quant funds use rules-based models.",
    "Union budget changes can affect debt fund taxation.",
    "Gold ETFs and sovereign gold bonds are two ways to hold gold.",
])
def test_guard_allows_categories(text):
    assert guard.find_product_mentions(text) == []


# --- Gemini conversion ----------------------------------------------------------

def test_gemini_contents_round_trip_signature():
    sig = base64.b64encode(b"\x01\x02sig").decode()
    contents = to_gemini_contents([
        Message(role="user", text="hi"),
        Message(role="model", tool_calls=[ToolCall(id="c1", name="get_health_report",
                                                   args={}, signature=sig)]),
        Message(role="tool", tool_results=[{"id": "c1", "name": "get_health_report",
                                            "result": {"score": 70}}]),
    ])
    assert [c.role for c in contents] == ["user", "model", "user"]
    assert contents[1].parts[0].thought_signature == b"\x01\x02sig"
    assert contents[2].parts[0].function_response.response == {"score": 70}


def test_from_gemini_response_extracts_calls_text_and_sources():
    from google.genai import types

    resp = types.GenerateContentResponse(candidates=[types.Candidate(
        content=types.Content(role="model", parts=[
            types.Part(text="thinking", thought=True),
            types.Part(text="Answer."),
            types.Part(function_call=types.FunctionCall(name="plan_goal",
                                                        args={"today_cost": 1, "years": 2}),
                       thought_signature=b"abc"),
        ]),
        grounding_metadata=types.GroundingMetadata(grounding_chunks=[
            types.GroundingChunk(web=types.GroundingChunkWeb(uri="https://rbi.org.in/x", title="RBI")),
            types.GroundingChunk(web=types.GroundingChunkWeb(uri="https://rbi.org.in/x", title="RBI")),
        ]),
    )])
    r = from_gemini_response(resp, "gemini-x")
    assert r.text == "Answer."
    assert r.tool_calls[0].name == "plan_goal"
    assert base64.b64decode(r.tool_calls[0].signature) == b"abc"
    assert r.sources == [Source(title="RBI", url="https://rbi.org.in/x")]


def test_tool_contract_is_loaded():
    assert TOOL_NAMES == {"get_health_report", "get_assumptions", "plan_goal",
                          "plan_independence", "suggest_allocation", "sip_projection",
                          "loan_payoff"}
