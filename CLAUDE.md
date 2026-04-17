# claude-setup

Versioned personal Claude Code workflow. This repo is the source of truth for your `~/.claude/` configuration: global instructions, settings patches, agent definitions, project templates, and the sprint methodology (curated gstack).

## Install

```bash
bash install.sh            # backs up, symlinks, merges settings, installs gstack
bash scripts/verify.sh     # run the checklist
```

The installer is idempotent. Running it twice does nothing the second time except refresh the timestamp.

Flags:
- `--dry-run` — print actions without executing.
- `--no-gstack` — skip gstack clone + `./setup`.

## Uninstall

```bash
bash uninstall.sh          # restores from most recent ~/.claude/backups/<timestamp>/
```

## Layout

```
claude-setup/
├── install.sh              # idempotent installer
├── uninstall.sh            # restore from latest backup
├── global/                 # → symlinks into ~/.claude/
│   ├── CLAUDE.md           # your personal global instructions
│   ├── settings.json.patch # merged into ~/.claude/settings.json via jq
│   ├── claude.json         # global agent router (absolute paths)
│   └── scripts/
│       └── handoff-on-stop.sh
├── agents/                 # → symlinks into ~/.claude/agents/
│   ├── golang-pro.md
│   ├── nodejs-backend.md
│   ├── supabase-expert.md
│   └── typescript-pro.md
├── templates/              # copy into each new project's CLAUDE.md
│   ├── nextjs-vercel.CLAUDE.md
│   ├── python-fastapi.CLAUDE.md
│   ├── go-service.CLAUDE.md
│   ├── nodejs-api.CLAUDE.md
│   └── fullstack-supabase.CLAUDE.md
├── scripts/
│   ├── install-gstack.sh   # clone + setup + telemetry opt-out
│   ├── backup-current.sh   # standalone tar snapshot of ~/.claude/
│   └── verify.sh           # post-install checklist
└── docs/
    ├── workflow.md
    ├── gstack-integration.md
    ├── prompt-injection-notes.md
    └── claw-code-insights.md
```

## Philosophy

Three principles (from the [gstack ETHOS](https://github.com/garrytan/gstack/blob/main/ETHOS.md)):
1. **Boil the Lake** — do the complete thing; marginal cost of completeness is near-zero.
2. **Search Before Building** — check existing skills/agents before inventing.
3. **User Sovereignty** — recommend, don't act.

One pattern (from the [claw-code PHILOSOPHY](https://github.com/ultraworkers/claw-code/blob/main/PHILOSOPHY.md)):
4. **Route notifications outside the agent context window** — Stop hook writes to `~/.claude/handoffs/` instead of the prompt tail.

## Daily workflow

See `docs/workflow.md`. TL;DR:

```
New feature → /office-hours → /autoplan → implement → /review → /qa → /ship → /land-and-deploy
Bug fix     → /investigate → fix → /review → /ship
Security    → /cso before any auth/payment/data PR
Weekly      → /retro on Friday
```

## What this repo is not

- Not a copy of Claude Code source.
- Not a Claude Code plugin (though it installs some via `settings.json`).
- Not multi-user — personal workflow only.
