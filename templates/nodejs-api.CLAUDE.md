# Node.js API Project — Claude Instructions

## Stack
- Node 20+ LTS. TypeScript strict. ESM.
- Framework: Hono (edge-friendly) or Fastify (pure Node). Pick at project start; don't mix.
- Validation: Zod at every HTTP boundary.
- DB: Drizzle or Kysely + pg/pglite. No Prisma on hot paths (cold-start cost).
- Deploy: Docker → Railway / Fly; or Cloudflare Workers / Vercel Edge for Hono.

## Non-negotiables
- Test: Vitest + supertest. Integration tests hit a real Postgres (Testcontainers).
- Lint: `eslint --max-warnings=0`. Format: `prettier --check`.
- Type: `tsc --noEmit` runs clean.
- Obs: pino structured logs + OpenTelemetry traces + `/healthz` + `/readyz` from day 1.

## File conventions
- `src/routes/` — route handlers only.
- `src/services/` — business logic; no HTTP or DB types leak here.
- `src/db/` — Drizzle/Kysely schemas + queries.
- `src/lib/` — pure utilities.
- `tests/` mirrors `src/`.

## Workflow hooks
- `/cso` required on auth/payment handlers.
- `/review` required before every PR.

## Known gotchas
- ESM + CommonJS interop: stick to ESM. If a dep is CJS-only, isolate it behind a wrapper.
- pnpm workspaces: `workspace:*` vs `workspace:^` matters for publishable libs.
- Top-level `await` in ESM + tsx can stall cold starts. Prefer lazy init.

## Reuse
- Agents: `nodejs-backend`, `typescript-pro`, `backend-architect`, `database-architect`.
- Skills: `/office-hours`, `/autoplan`, `/plan-eng-review`, `/review`, `/cso`, `/ship`.
