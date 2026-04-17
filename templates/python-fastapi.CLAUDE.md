# Python + FastAPI Project — Claude Instructions

## Stack
- Python 3.12+. `uv` for deps (no pip, no poetry).
- FastAPI + Pydantic v2. No Flask, no Django for new services.
- DB: Postgres via SQLAlchemy 2.0 async + Alembic migrations.
- Queue: Arq or Celery (pick at project start). Redis for both.
- Deploy: Docker → Fly.io, Railway, or Vercel (Python runtime beta).

## Non-negotiables
- Test: pytest + pytest-asyncio. Integration tests hit a real Postgres in CI.
- Lint: `ruff check --fix`. Format: `ruff format`.
- Type: `mypy --strict` on `src/`. No `Any` without a `# type: ignore` justification.
- Coverage floor: 80% on new code. `pytest --cov --cov-fail-under=80`.

## File conventions
- `src/<package>/` — one package per domain (not one per layer).
- `src/<package>/api/` — FastAPI routes.
- `src/<package>/domain/` — pure business logic, no HTTP or DB types.
- `src/<package>/infra/` — DB, external APIs, queues.
- `tests/` mirrors `src/`.

## Workflow hooks
- `/cso` required on any change to `auth/`, `payments/`, or a migration.
- `/review` required before any PR.

## Known gotchas
- Pydantic v2 validators behave differently from v1. Never copy v1 validator code into a v2 model.
- FastAPI + async SQLAlchemy: one session per request via `Depends`. Sharing sessions across requests is a silent bug factory.
- `uv run` and `pytest` disagree about `PYTHONPATH` — always use `uv run pytest`.

## Reuse
- Agents: `python-expert`, `backend-architect`, `database-architect`, `supabase-expert` (if Supabase).
- Skills: `/office-hours`, `/autoplan`, `/plan-eng-review`, `/investigate`, `/review`, `/cso`, `/ship`.
