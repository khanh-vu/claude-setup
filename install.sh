#!/usr/bin/env bash
# Idempotent installer: links claude-setup repo files into ~/.claude/
# Backs up any existing file that would be overwritten into ~/.claude/backups/<timestamp>/
# Never touches user data outside ~/.claude/.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$CLAUDE_HOME/backups/$TS"

DRY_RUN=0
NO_GSTACK=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --no-gstack) NO_GSTACK=1 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--dry-run] [--no-gstack]
  --dry-run    Print actions without executing.
  --no-gstack  Skip gstack clone + ./setup.
EOF
      exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'DRY: %s\n' "$*"
  else
    "$@"
  fi
}

say() { printf '==> %s\n' "$*"; }

say "Installing from $REPO into $CLAUDE_HOME"
run mkdir -p "$BACKUP" "$CLAUDE_HOME/scripts" "$CLAUDE_HOME/agents/_archive" "$CLAUDE_HOME/handoffs"

# 1. Symlink global files (CLAUDE.md, claude.json). Back up any existing non-symlink.
for f in CLAUDE.md claude.json; do
  src="$REPO/global/$f"
  dst="$CLAUDE_HOME/$f"
  [ -f "$src" ] || { echo "missing: $src" >&2; continue; }
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    run cp "$dst" "$BACKUP/$f"
  fi
  run ln -sfn "$src" "$dst"
done

# 2. Merge settings.json via jq — never overwrite.
PATCH="$REPO/global/settings.json.patch"
CURRENT="$CLAUDE_HOME/settings.json"
if [ -f "$PATCH" ]; then
  if [ -f "$CURRENT" ]; then
    run cp "$CURRENT" "$BACKUP/settings.json"
    if [ "$DRY_RUN" -eq 0 ]; then
      jq -s '.[0] * .[1]' "$CURRENT" "$PATCH" > "$CURRENT.new"
      mv "$CURRENT.new" "$CURRENT"
    else
      echo "DRY: jq -s '.[0] * .[1]' $CURRENT $PATCH > $CURRENT"
    fi
  else
    run cp "$PATCH" "$CURRENT"
  fi
fi

# 3. Symlink Stop-hook script.
run ln -sfn "$REPO/global/scripts/handoff-on-stop.sh" "$CLAUDE_HOME/scripts/handoff-on-stop.sh"
run chmod +x "$REPO/global/scripts/handoff-on-stop.sh"

# 4. Symlink new agent files. Back up any colliding file.
for f in "$REPO"/agents/*.md; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  dst="$CLAUDE_HOME/agents/$name"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    run mv "$dst" "$BACKUP/agent-$name"
  fi
  run ln -sfn "$f" "$dst"
done

# 5. Remove duplicate agent files (names ending in " 2.md").
for dup in "$CLAUDE_HOME/agents/backend-architect 2.md" "$CLAUDE_HOME/agents/python-expert 2.md"; do
  if [ -f "$dup" ]; then
    run cp "$dup" "$BACKUP/$(basename "$dup")"
    run rm "$dup"
  fi
done

# 6. Archive non-agent files that were loose in ~/.claude/agents/.
for nonagent in commands.md context_session_1.md scorecard.md task.md; do
  src="$CLAUDE_HOME/agents/$nonagent"
  if [ -f "$src" ] && [ ! -L "$src" ]; then
    run mv "$src" "$CLAUDE_HOME/agents/_archive/$nonagent"
  fi
done

# 7. Install gstack (skills/gstack/) unless --no-gstack.
if [ "$NO_GSTACK" -eq 0 ]; then
  if [ ! -d "$CLAUDE_HOME/skills/gstack" ]; then
    run bash "$REPO/scripts/install-gstack.sh"
  else
    say "gstack already present at $CLAUDE_HOME/skills/gstack — skipping."
  fi
fi

say "Done. Backup: $BACKUP"
say "Run: bash $REPO/scripts/verify.sh"
