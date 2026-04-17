#!/usr/bin/env bash
# Clones gstack into ~/.claude/skills/gstack, runs its setup, opts out of telemetry.

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
GSTACK_DIR="$CLAUDE_HOME/skills/gstack"

if [ -d "$GSTACK_DIR" ]; then
  echo "gstack already installed at $GSTACK_DIR — skipping clone."
else
  echo "Cloning gstack into $GSTACK_DIR..."
  mkdir -p "$CLAUDE_HOME/skills"
  git clone --depth 1 --single-branch https://github.com/garrytan/gstack.git "$GSTACK_DIR"
fi

if [ -x "$GSTACK_DIR/setup" ]; then
  echo "Running gstack ./setup..."
  ( cd "$GSTACK_DIR" && ./setup )
else
  echo "warn: $GSTACK_DIR/setup not executable or missing — skipping." >&2
fi

if [ -x "$GSTACK_DIR/bin/gstack-analytics" ]; then
  echo "Opting out of gstack telemetry..."
  "$GSTACK_DIR/bin/gstack-analytics" opt-out || echo "warn: telemetry opt-out returned non-zero; verify manually." >&2
fi

echo "gstack install complete."
