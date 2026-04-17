# Installation Guide

Step-by-step walkthrough of `install.sh`, its verification, common issues, and rollback. For the short version, see [`README.md#quick-start`](../README.md#quick-start).

## Prerequisites

| Tool | Check | Install (macOS) |
|---|---|---|
| `bash` 3.2+ | `bash --version` | preinstalled |
| `git` | `git --version` | `xcode-select --install` or `brew install git` |
| `jq` | `jq --version` | `brew install jq` |
| Claude Code | `claude --version` | https://claude.com/claude-code |
| `bun` *(optional, for gstack `/qa` browser)* | `bun --version` | `curl -fsSL https://bun.sh/install \| bash` |

Linux: use your distro's package manager for `git`, `jq`, `bash`.

## Clone the repo

```bash
git clone https://github.com/khanh-vu/claude-setup.git ~/code/claude-setup
cd ~/code/claude-setup
```

You can clone anywhere — `install.sh` reads its own location and installs symlinks pointing back to wherever it lives. If you move the repo, rerun `install.sh` to refresh symlinks.

## Step 1 — Full-tree backup (recommended)

`install.sh` backs up every file it *touches*, but a full-tree snapshot is cheap insurance:

```bash
bash scripts/backup-current.sh
# → ~/claude-bak-YYYY-MM-DD.tar
```

## Step 2 — Install

```bash
bash install.sh
```

What happens, in order:

1. **Creates**: `~/.claude/backups/<timestamp>/`, `~/.claude/scripts/`, `~/.claude/agents/_archive/`, `~/.claude/handoffs/`.
2. **Symlinks**: `~/.claude/CLAUDE.md` and `~/.claude/claude.json` → files in `global/`.
3. **Merges** `global/settings.json.patch` into `~/.claude/settings.json` via `jq -s '.[0] * .[1]'`. Existing keys (your `enabledPlugins`, `alwaysThinkingEnabled`, etc.) are preserved.
4. **Symlinks** `~/.claude/scripts/handoff-on-stop.sh` → `global/scripts/handoff-on-stop.sh`.
5. **Symlinks** each `agents/*.md` into `~/.claude/agents/`. Collisions get backed up and replaced.
6. **Removes** `backend-architect 2.md` and `python-expert 2.md` duplicates (backed up first).
7. **Archives** loose non-agent files (`commands.md`, `context_session_1.md`, `scorecard.md`, `task.md`) into `~/.claude/agents/_archive/`.
8. **Clones** gstack into `~/.claude/skills/gstack/` if absent.

Dry run first if you want to preview:

```bash
bash install.sh --dry-run
```

Skip gstack entirely (e.g., on a minimal machine):

```bash
bash install.sh --no-gstack
```

## Step 3 — Verify

```bash
bash scripts/verify.sh
```

Expected: 14 checks pass. Any FAIL indicates a problem — see Troubleshooting below.

## Step 4 — First run in Claude Code

Open Claude Code in any project and run:

```
/office-hours
```

If gstack is wired up, you'll see the six forcing questions. If not, check that `~/.claude/skills/gstack/office-hours/SKILL.md` exists.

## Step 5 — Optional: gstack's browser binary

gstack's `/qa` skill uses a real Chromium via a Bun-compiled binary. The installer skips this build because it's heavy; run it yourself when you need it:

```bash
cd ~/.claude/skills/gstack
bun install
./setup
```

Without `./setup`, everything except `/qa`'s real-browser mode still works — the skill files are plain markdown.

## Troubleshooting

### `FAIL  CLAUDE.md symlink resolves`

The symlink target is missing. Usually means you moved or deleted the repo. Fix:

```bash
cd <wherever claude-setup lives now>
bash install.sh
```

### `FAIL  permissions.deny present`

`jq` merge didn't take. Check that `/usr/bin/jq` exists and that `~/.claude/settings.json` is valid JSON (`jq . ~/.claude/settings.json`). Recover the pre-install version from `~/.claude/backups/<timestamp>/settings.json` if corrupted.

### Stop hook prints `printf: - : invalid option`

macOS bash 3.2 reads a leading `-` in a `printf` format string as a flag. If you edited `handoff-on-stop.sh`, move the dash into the argument: `printf '%s\n' "- text"` instead of `printf '- %s\n' "text"`.

### Agents not showing up in Claude Code

1. Confirm the symlink: `ls -la ~/.claude/agents/<name>.md` — should show `→ ...claude-setup/agents/<name>.md`.
2. Confirm the router: `jq '.agents' ~/.claude/claude.json` — should list the name with an absolute path.
3. Restart Claude Code — agent discovery happens at session start.

### gstack skill not recognized

1. `ls ~/.claude/skills/gstack/<skill>/SKILL.md` — should exist.
2. If missing, clone likely failed: `rm -rf ~/.claude/skills/gstack && bash scripts/install-gstack.sh`.

### "Permission denied" on a bash command

`permissions.deny` / `permissions.ask` in `settings.json` is doing its job. Either:
- Rephrase the command to avoid the pattern (recommended when a guard triggers correctly).
- Edit `global/settings.json.patch`, rerun `install.sh`, if the rule is too strict.

## Uninstall

```bash
bash uninstall.sh
```

Restores files from the most recent `~/.claude/backups/<timestamp>/` and removes any symlink that points into this repo. gstack is left in place — remove with `rm -rf ~/.claude/skills/gstack` if desired.

For a complete rollback:

```bash
tar -xf ~/claude-bak-YYYY-MM-DD.tar -C $HOME
```

## Uninstalling and re-installing on a new machine

1. `git clone https://github.com/khanh-vu/claude-setup.git ~/code/claude-setup`
2. Install prerequisites (`jq`, `bun` if you want `/qa`).
3. `cd ~/code/claude-setup && bash install.sh && bash scripts/verify.sh`

Your whole workflow — agents, templates, safety rules, gstack methodology — reconstitutes from the repo.

## Next steps

- Read [`docs/workflow.md`](workflow.md) for daily usage patterns.
- Skim the 5 templates in [`templates/`](../templates/) before starting your next project.
- If you customize `global/CLAUDE.md` or add a new agent, commit and push so it syncs to your other machines.
