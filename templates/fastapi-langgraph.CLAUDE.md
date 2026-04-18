# FastAPI + LangGraph Agent Project — Claude Instructions

## Stack
- Python 3.11+. `uv` for deps (no pip, no poetry).
- FastAPI + Pydantic v2 + SQLModel/SQLAlchemy 2.0 async + Alembic.
- LangGraph for agent orchestration; LangChain for model clients.
- Postgres (local + prod) via asyncpg. SQLite **only** for tests (aiosqlite, `TESTING=True`).
- Optional: Qdrant for vector search, Redis for caching/queues, MLflow for experiment tracking.
- Deploy: Docker → GCP Cloud Run (via Terraform) or Fly.io.

## Non-negotiables
- Test: pytest + pytest-asyncio + custom markers (`uuid`, `websocket`, `database`, `integration`).
- Lint: `ruff check --fix`. Format: `ruff format`. Type: `mypy --strict` on `src/`.
- Local/prod always PostgreSQL. **Never run SQLite queries against the dev DB.**
- All LLM calls go through the LLM registry — never direct `ChatOpenAI`, `ChatAnthropic`, etc.

## LangGraph streaming rule (CRITICAL)

**Nodes do not stream. LangGraph streams from nodes.**

```python
# correct — node uses standard LLM call
async def llm_generation_node(state):
    llm = LLMRegistry.get_smart_model(streaming=True)
    result = await llm.ainvoke(prompt)
    return {"llm_response": result}

# correct — graph orchestrates streaming
async for chunk_type, chunk_data in graph.astream(input, stream_mode=["messages", "values"]):
    if chunk_type == "messages":
        message, metadata = chunk_data
        node_name = metadata.get("langgraph_node")
```

**Wrong**: custom streaming logic inside a node, node returning a generator, manual token streaming.

## Manager pattern (CRITICAL)

Business logic lives in **managers**, not routes or services.

```
Route endpoint  →  Manager  →  Service  →  Repository/External API
```

- **Managers**: coordinate business logic, handle all errors, return `{success, data?, error?}`.
- **Services**: domain operations (HTTP, WebSocket, vector search). **No try/except — fail fast.**
- **Routes**: HTTP concerns only; catch HTTP-specific exceptions, delegate the rest to managers.
- **Components/handlers**: UI feedback or response formatting only.

## Error handling rules (CRITICAL)

- `try/except` is **only** allowed in managers and route endpoints.
- Services, agents, and nodes must never swallow errors. Let them propagate.
- Managers display the original error + stack trace. No generic "the system failed {e}" wrappers.
- Only managers/endpoints may rewrite error messages for the client.

## LLM Registry usage

```python
from src.services.llm import LLMRegistry

fast     = LLMRegistry.get_fast_model(temperature=0.0)      # classification, metadata
smart    = LLMRegistry.get_smart_model(streaming=True)      # main generation, RAG
creative = LLMRegistry.get_creative_model(temperature=0.7)  # social/greetings
balanced = LLMRegistry.get_balanced_model(temperature=0.3)  # off-topic handling

# specific model when a profile doesn't fit
custom = LLMRegistry.get_model(model="openai/gpt-4o", temperature=0.1, max_tokens=4000)
```

## File conventions

- `src/api/` — FastAPI routers, WebSocket endpoints.
- `src/managers/` — one manager per domain (Conversations, Agents, Database, Audio).
- `src/services/` — pure domain operations, no error handling.
- `src/agents/<agent>/` — LangGraph nodes + graph definition.
- `src/config/` — env parsing, settings singletons.
- `alembic/versions/` — one migration per change.
- `tests/` mirrors `src/`, with custom markers per domain.

## Observability (MLflow)

- Each agent sets its own experiment name before invocation:
  ```python
  mlflow.set_experiment("oracle-agent")
  result = await oracle_astream(params)
  ```
- LangChain autologging captures traces automatically — no manual instrumentation.
- Local: `mlflow server --backend-store-uri sqlite:///mlflow.db --default-artifact-root ./mlruns`.
- Staging/prod: Cloud Run + Postgres backend + GCS artifacts (via Terraform).

## Workflow hooks
- `/cso` required on any change to auth, WebSocket token validation, or LLM-safety filters.
- `/investigate` before coding a fix for any agent bug — streaming issues often hide logic bugs.
- `/review` required before every PR.

## Known gotchas
- Pydantic v2 validators behave differently from v1 — don't port blindly.
- FastAPI + async SQLAlchemy: one session per request via `Depends`; sharing sessions across requests silently corrupts.
- `uv run pytest` vs `pytest`: the latter will miss src path without `uv run`.
- LangGraph `stream_mode="messages"` won't fire unless the node passes `streaming=True` to the LLM client.
- Cloud Run `--set-env-vars` REPLACES all env vars. Always use `--update-env-vars`.
- Qdrant + offline mode: set `FASTEMBED_CACHE_DIR` and `HF_HUB_OFFLINE=1` to prevent network calls.

## Reuse
- Agents: `python-expert`, `backend-architect`, `database-architect`, `llm-registry-expert`, `deployment-integration-expert`, `supabase-expert` (if using Supabase).
- Skills: `/office-hours`, `/autoplan`, `/plan-eng-review`, `/investigate`, `/review`, `/cso`, `/ship`, `/canary`.
- Docs: `docs/mlflow-langgraph-patterns.md`.
