# gstack Integration Notes

## Why these 15 skills (not all 23)

gstack ships ~23 skills + 8 power tools. We use 15. Reasons for the cuts:

| Skipped skill | Reason |
|---|---|
| `/design-shotgun`, `/design-consultation`, `/design-html` | Overlap with your `frontend-design@claude-plugins-official` plugin. Pick one. |
| `/browse`, `/benchmark` | No UI property worth perf-benchmarking yet. |
| `/setup-browser-cookies` | Useful when scraping authenticated sites; not yet relevant. |
| `/document-release` | Your release cadence doesn't warrant auto-docs. |
| `/setup-deploy` | `deployment-integration-expert` agent already covers Vercel. |
| `/gstack-upgrade` | Manual `git pull` + `./setup` in `~/.claude/skills/gstack` works. |

Revisit the skipped list every 30 days. Add any skill that keeps coming up as "I wish I had X".

## Adding a gstack skill

```bash
# Skills are already present inside the gstack/ folder; "adding" just means using them.
# To update gstack:
cd ~/.claude/skills/gstack
git fetch origin
git reset --hard origin/main
./setup
bin/gstack-analytics opt-out   # re-assert after update
```

## Replacing a gstack skill with your own

- Put your replacement at `~/.claude/skills/<name>/SKILL.md` (flat, not under `gstack/`).
- Claude Code's skill resolution preference is implementation-detail — verify which one wins after change.
- Document the override in `docs/gstack-integration.md` so it doesn't get lost.

## Telemetry

Confirmed opt-out during install. If `gstack-analytics opt-out` fails silently, check `~/.claude/skills/gstack/` for any `telemetry.json` file and set `enabled: false` manually.

## Cross-model review (`/codex`)

`/codex` requires the OpenAI Codex CLI. Install separately: https://github.com/openai/codex . Auth lives in `~/.codex/`. Use `/codex` sparingly — one second opinion per risky change, not every PR.
