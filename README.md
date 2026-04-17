# claude-setup

> A versioned, reproducible personal [Claude Code](https://claude.com/claude-code) workflow for solo full-stack builders.

One `bash install.sh` gives you: safety permissions, session side-channel hooks, 10 domain agents, 5 per-stack project templates, and a curated 15-skill sprint methodology adapted from [gstack](https://github.com/garrytan/gstack). Everything is a git-tracked symlink, so your `~/.claude/` becomes reproducible across machines and reversible via one command.

---

## Why this exists

Your `~/.claude/` grows organically: skills pile up, agent files collect duplicates, settings drift, and nothing is versioned. `claude-setup` makes it a repo:

- **Reproducible** — every file in `~/.claude/` that matters is a symlink into this repo.
- **Reversible** — `install.sh` backs up everything it touches; `uninstall.sh` restores.
- **Opinionated** — ships an actual *workflow* (Think → Plan → Build → Review → Test → Ship → Reflect), not just configuration.
- **Safe by default** — permission rules block destructive bash; Stop hook routes session status to a side channel instead of cluttering the agent context.

## Features

| Layer | What you get |
|---|---|
| **Safety rails** | `permissions.deny` for `rm -rf /`, force-push to main; `permissions.ask` for publish/deploy commands |
| **Sprint methodology** | 15 curated gstack skills: `/office-hours`, `/autoplan`, `/investigate`, `/review`, `/qa`, `/cso`, `/ship`, `/land-and-deploy`, `/canary`, `/retro`, `/guard`, `/freeze`, `/pair-agent`, `/codex`, `/plan-*-review` |
| **Domain agents** | 10 agents covering frontend, backend, databases, deployment, plus 4 new: `golang-pro`, `nodejs-backend`, `supabase-expert`, `typescript-pro` |
| **Project templates** | Starter `CLAUDE.md` for Next.js+Vercel, Python+FastAPI, Go services, Node.js APIs, Next.js+Supabase fullstack |
| **Side-channel notifications** | Stop hook appends to `~/.claude/handoffs/YYYY-MM-DD.md` (claw-code pattern — status stays out of agent context) |
| **Idempotent installer** | Symlinks, jq-merges `settings.json`, archives duplicates, full per-file backup |

## Prerequisites

- macOS or Linux with `bash`, `git`, and `jq` (`brew install jq` on macOS).
- [Claude Code](https://claude.com/claude-code) installed.
- *(Optional)* `bun` for gstack's `/qa` browser binary — skip unless you need real-browser UI testing.

## Quick start

```bash
git clone https://github.com/khanh-vu/claude-setup.git ~/code/claude-setup
cd ~/code/claude-setup
bash install.sh
bash scripts/verify.sh
```

Expected output of `verify.sh`:

```
Verifying /Users/you/.claude...
  OK  CLAUDE.md symlink resolves
  OK  claude.json symlink resolves
  OK  settings.json exists
  OK  permissions.deny present
  OK  permissions.ask present
  OK  Stop hook registered
  OK  handoff-on-stop.sh exists
  OK  gstack present
  OK  golang-pro agent linked
  OK  nodejs-backend agent linked
  OK  supabase-expert agent linked
  OK  typescript-pro agent linked
  OK  no duplicate "* 2.md" agent files
  OK  non-agent files archived
All checks passed.
```

Open Claude Code and try `/office-hours` — if gstack resolved, you're done.

## Daily workflow

```
New feature  →  /office-hours → /autoplan → implement → /review → /qa → /ship → /land-and-deploy
Bug fix      →  /investigate → fix → /review → /ship
Security PR  →  add /cso before /review
Production   →  /guard on; /review + /codex; /ship; /canary
Weekly       →  /retro on Friday
```

See [`docs/workflow.md`](docs/workflow.md) for when to pair agents with skills, when to escalate to `/codex`, and handoff etiquette.

## Using a project template

When starting a new project:

```bash
# e.g. a Next.js + Supabase app
cp ~/code/claude-setup/templates/fullstack-supabase.CLAUDE.md ./CLAUDE.md
# then edit to taste
```

Templates available: `nextjs-vercel`, `python-fastapi`, `go-service`, `nodejs-api`, `fullstack-supabase`.

## Architecture

```
~/.claude/                           (live — symlinks point here)
├── CLAUDE.md                ──→  claude-setup/global/CLAUDE.md
├── claude.json              ──→  claude-setup/global/claude.json
├── settings.json                   (jq-merged from patch)
├── scripts/handoff-on-stop.sh ──→  claude-setup/global/scripts/…
├── agents/
│   ├── golang-pro.md        ──→  claude-setup/agents/golang-pro.md
│   ├── nodejs-backend.md    ──→  claude-setup/agents/…
│   ├── supabase-expert.md   ──→  claude-setup/agents/…
│   └── typescript-pro.md    ──→  claude-setup/agents/…
└── skills/gstack/                  (cloned, not symlinked)

claude-setup/                       (source of truth)
├── install.sh              # idempotent installer
├── uninstall.sh            # restore from latest backup
├── global/                 # → symlinks into ~/.claude/
├── agents/                 # → symlinks into ~/.claude/agents/
├── templates/              # copy into each new project's CLAUDE.md
├── scripts/                # install-gstack, backup-current, verify
└── docs/                   # workflow, gstack-integration, injection notes
```

## Install options

```bash
bash install.sh                   # full install
bash install.sh --dry-run         # preview actions, change nothing
bash install.sh --no-gstack       # skip gstack clone
```

## Rollback

Per-file rollback (latest install):

```bash
bash uninstall.sh
```

Full rollback to pre-install snapshot (tar created before first run):

```bash
tar -xf ~/claude-bak-YYYY-MM-DD.tar -C $HOME
```

Remove gstack specifically:

```bash
rm -rf ~/.claude/skills/gstack
```

## FAQ

**Does this conflict with my existing skills and plugins?**  
No. gstack installs under `~/.claude/skills/gstack/` (namespaced). Your existing flat skills at `~/.claude/skills/<name>/` are untouched. Plugins in `settings.json` are preserved — the installer *merges*, never overwrites.

**What if I already have a `~/.claude/CLAUDE.md`?**  
The installer backs it up to `~/.claude/backups/<timestamp>/CLAUDE.md` before replacing with a symlink. Run `uninstall.sh` to restore.

**Is gstack's telemetry enabled?**  
No. gstack telemetry is opt-in; you'd have to run `gstack-config set telemetry anonymous` to enable. The default is off.

**Why curate 15 skills instead of installing all 23+?**  
Design-related skills (`/design-shotgun`, `/design-consultation`, `/design-html`) overlap with the `frontend-design` plugin. `/browse`, `/benchmark`, `/setup-browser-cookies` are niche. `/document-release`, `/setup-deploy` duplicate what your agents already do. See [`docs/gstack-integration.md`](docs/gstack-integration.md) for the full reasoning.

**What about claw-code?**  
[`ultraworkers/claw-code`](https://github.com/ultraworkers/claw-code) is a community Rust CLI harness, **not** leaked Claude source. The borrowed pattern is the side-channel notification model (Stop hook → handoffs file). See [`docs/claw-code-insights.md`](docs/claw-code-insights.md).

## Further reading

- [`CLAUDE.md`](CLAUDE.md) — instructions for Claude agents editing this repo.
- [`docs/workflow.md`](docs/workflow.md) — daily workflow cheatsheet.
- [`docs/gstack-integration.md`](docs/gstack-integration.md) — why these 15 skills.
- [`docs/prompt-injection-notes.md`](docs/prompt-injection-notes.md) — injection patterns seen in the wild.
- [`docs/claw-code-insights.md`](docs/claw-code-insights.md) — what we borrowed and why.

## Credits & inspiration

- [gstack](https://github.com/garrytan/gstack) by Garry Tan — sprint methodology and [ETHOS](https://github.com/garrytan/gstack/blob/main/ETHOS.md) (Boil the Lake / Search Before Building / User Sovereignty).
- [claw-code](https://github.com/ultraworkers/claw-code) by ultraworkers — side-channel coordination pattern.

## License

MIT. See [`LICENSE`](LICENSE).

## Not affiliated with Anthropic, gstack's author, or the claw-code project.
