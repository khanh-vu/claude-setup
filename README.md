# claude-setup

Personal Claude Code workflow — a versioned, reproducible `~/.claude/` for a solo full-stack builder.

**Stack coverage**: TypeScript/Next.js/Vercel frontend · Python/Go/Node.js backends · Supabase/Postgres · Docker/CI.

**Methodology**: curated subset of [gstack](https://github.com/garrytan/gstack)'s sprint workflow (*Think → Plan → Build → Review → Test → Ship → Reflect*) wired together with 10 domain agents, per-stack project templates, and safety rails.

## Quick start

```bash
bash install.sh            # back up, symlink, merge settings, install gstack
bash scripts/verify.sh     # confirm everything resolves
```

Uninstall with `bash uninstall.sh`. See `CLAUDE.md` for layout and `docs/workflow.md` for daily usage.

## Not affiliated with Anthropic or gstack's author.
