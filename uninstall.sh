#!/usr/bin/env bash
# Reverses install.sh: removes symlinks pointing into this repo and restores from the
# most recent backup in ~/.claude/backups/.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
LATEST="$(ls -1d "$CLAUDE_HOME"/backups/* 2>/dev/null | sort | tail -1 || true)"

if [ -z "$LATEST" ]; then
  echo "No backups found in $CLAUDE_HOME/backups/. Aborting." >&2
  exit 1
fi

echo "Restoring from: $LATEST"

# Restore global files if backed up.
for f in CLAUDE.md claude.json settings.json; do
  if [ -f "$LATEST/$f" ]; then
    dst="$CLAUDE_HOME/$f"
    [ -L "$dst" ] && rm "$dst"
    cp "$LATEST/$f" "$dst"
    echo "restored $f"
  elif [ -L "$CLAUDE_HOME/$f" ]; then
    target="$(readlink "$CLAUDE_HOME/$f")"
    case "$target" in
      "$REPO"/*) rm "$CLAUDE_HOME/$f"; echo "removed symlink $f (no prior backup)" ;;
    esac
  fi
done

# Restore duplicate agents.
for a in "backend-architect 2.md" "python-expert 2.md"; do
  if [ -f "$LATEST/$a" ]; then
    cp "$LATEST/$a" "$CLAUDE_HOME/agents/$a"
    echo "restored agents/$a"
  fi
done

# Remove agent symlinks that point into this repo.
for link in "$CLAUDE_HOME"/agents/*.md; do
  if [ -L "$link" ]; then
    target="$(readlink "$link")"
    case "$target" in
      "$REPO"/agents/*) rm "$link"; echo "removed symlink $(basename "$link")" ;;
    esac
  fi
done

# Remove Stop-hook script symlink.
if [ -L "$CLAUDE_HOME/scripts/handoff-on-stop.sh" ]; then
  target="$(readlink "$CLAUDE_HOME/scripts/handoff-on-stop.sh")"
  case "$target" in
    "$REPO"/*) rm "$CLAUDE_HOME/scripts/handoff-on-stop.sh"; echo "removed handoff-on-stop.sh symlink" ;;
  esac
fi

echo "Uninstall complete. gstack (if installed) is left in place — remove manually with: rm -rf $CLAUDE_HOME/skills/gstack"
