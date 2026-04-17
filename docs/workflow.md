# Daily Workflow Cheatsheet

## Sprint order (gstack methodology)

```
Think → Plan → Build → Review → Test → Ship → Reflect
```

## Canonical chains

| Situation | Chain |
|---|---|
| New feature (non-trivial) | `/office-hours` → `/autoplan` → implement → `/review` → `/qa` → `/ship` → `/land-and-deploy` |
| Small feature | `/autoplan` → implement → `/review` → `/ship` |
| Bug fix | `/investigate` → fix → `/review` → `/ship` |
| Security-sensitive change | add `/cso` before `/review` |
| Risky production change | `/guard` on; `/review` + `/codex`; `/ship`; `/canary` |
| Weekly reflection | `/retro` on Friday |

## When to pair agents with skills

- Invoke **`frontend-architect`** *inside* `/autoplan`'s design-review pass — it produces concrete component plans, not just prose.
- Invoke **`supabase-expert`** before `/cso` for any auth/RLS-touching work — lets `/cso` audit an informed design rather than a blank slate.
- Invoke **`code-reviewer`** after `/review` when the change is large — staff-engineer audit + specialist audit catch different classes of bugs.

## When to escalate to `/codex`

- Auth, payments, migrations, or anything regulated (PCI, HIPAA, GDPR).
- Anything where a single reviewer's blind spot would be expensive.
- Never for speed-over-quality CRUD work — it burns tokens for no signal.

## When to branch to `/pair-agent`

- When `/review` flags something that needs independent verification from a different model vendor.
- When a decision has multiple defensible answers and you want both sides argued before picking.

## Handoff etiquette

- **Session start**: read `~/.claude/handoffs/YYYY-MM-DD.md` (today's file) to see what last session touched.
- **Session end**: the Stop hook writes one line automatically. If something non-obvious needs a note, append it before `exit`.
- **Long-running work**: when spawning a background Agent, tell it to append a status line to the handoff file every N minutes rather than reporting into the main context.

## Skill overrides per project

Set in that project's `CLAUDE.md`:

```
## Skill overrides
- `/qa`: skip for library-only repos (no UI).
- `/cso`: required for any PR touching `src/auth/` or `src/payments/`.
- `/canary`: use only after `land-and-deploy` to production, not staging.
```
