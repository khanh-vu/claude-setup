# Next.js + Supabase Fullstack Project — Claude Instructions

## Stack
- Frontend: Next.js 15+ App Router + TypeScript strict + shadcn/ui + Tailwind. Deployed on Vercel.
- Backend: Supabase (Postgres + Auth + Storage + Edge Functions + Realtime).
- Client: `@supabase/supabase-js` (browser) + `@supabase/ssr` (server, SSR-safe).
- Deploy: Vercel (frontend) + Supabase cloud (backend). No self-hosting.

## Non-negotiables
- **RLS is always on.** Every table gets `ENABLE ROW LEVEL SECURITY` in the same migration. No exceptions.
- `/cso` required before any PR touching `supabase/migrations/`, `src/server/auth/`, or RLS policies.
- Auth flows use cookies, never localStorage. SSR-safe client server-side.
- Test: Vitest + Playwright. RLS policies get positive + negative tests with two impersonated users.
- Migrations: `supabase db diff` output read line-by-line before accepting. No blind applies.

## File conventions
- `supabase/migrations/` — SQL migrations. One logical change per file.
- `supabase/functions/<name>/` — Edge Functions (Deno runtime).
- `src/lib/supabase/{server,client}.ts` — typed clients.
- `src/app/` — routes; business logic stays in `src/server/`.
- `src/server/` — server actions, API routes, Supabase queries.

## Workflow hooks
- `/cso` on every auth / RLS / payments PR. Non-negotiable.
- `/qa` on every UI feature.
- `/canary` after `/land-and-deploy` to prod.

## Known gotchas
- RLS + Realtime = data leak if SELECT policies are broad. Narrow them before enabling Realtime.
- `supabase-js` in RSC: must use the server client with cookies; the browser client silently fails auth SSR.
- Edge Functions have a 50MB memory ceiling and 2s cold-start. Offload heavy work to a dedicated worker.
- Storage bucket policies live on `storage.objects`, not on the bucket. Common source of "why is this public" bugs.

## Reuse
- Agents: `frontend-architect`, `ui-components-expert`, `supabase-expert`, `database-architect`, `typescript-pro`, `deployment-integration-expert`.
- Skills: `/office-hours`, `/autoplan`, `/plan-eng-review`, `/cso`, `/review`, `/qa`, `/ship`, `/land-and-deploy`, `/canary`.
