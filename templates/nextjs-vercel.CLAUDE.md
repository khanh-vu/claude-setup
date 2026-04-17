# Next.js + Vercel Project — Claude Instructions

## Stack
- Next.js 15+, App Router, Server Actions, React Server Components
- TypeScript strict. `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`.
- UI: shadcn/ui + Tailwind. No other component library.
- State: Server state via RSC + server actions; client state via Zustand for anything non-trivial.
- Auth: NextAuth.js v5 or Clerk (pick one at project start; don't mix).
- Deploy: Vercel. Edge runtime where possible; Node runtime when a dep requires it.

## Non-negotiables
- Test: Vitest (unit) + Playwright (e2e). `/qa` after every feature.
- Lint: `eslint --max-warnings=0`. Format: `prettier --check`.
- Type: `tsc --noEmit` runs clean on every PR.
- Core Web Vitals: LCP < 2.5s, CLS < 0.1. Regressions block merge.

## File conventions
- `src/app/` — routes only. Business logic lives in `src/lib/`.
- `src/components/ui/` — shadcn primitives (never edit these).
- `src/components/<feature>/` — feature components (safe to edit).
- `src/server/actions/` — server actions; one file per feature.

## Workflow hooks
- `/qa` required on any feature touching `src/app/` or `src/components/`.
- `/cso` required on any change to `src/server/auth/`, `src/server/payments/`, or `src/server/db/`.
- `/canary` required after `/land-and-deploy` to production.

## Known gotchas
- `"use client"` + Server Actions can silently hydrate-mismatch. Always test the SSR pass.
- Edge runtime doesn't support Node APIs (fs, child_process). Check dep compat early.
- Vercel free-tier functions timeout at 10s. Long work goes to Vercel Queues or an external worker.

## Reuse
- Agents: `frontend-architect`, `ui-components-expert`, `typescript-pro`, `deployment-integration-expert`.
- Skills: `/office-hours`, `/autoplan`, `/plan-eng-review`, `/review`, `/qa`, `/ship`, `/land-and-deploy`, `/canary`.
