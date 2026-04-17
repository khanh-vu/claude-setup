#!/usr/bin/env bash
# Claude Code Stop hook — appends a one-line summary to ~/.claude/handoffs/YYYY-MM-DD.md
# Keeps session status out of the agent context window (claw-code side-channel pattern).

set -euo pipefail

HANDOFFS_DIR="$HOME/.claude/handoffs"
mkdir -p "$HANDOFFS_DIR"

DATE="$(date +%F)"
TIME="$(date +%H:%M:%S)"
OUTFILE="$HANDOFFS_DIR/$DATE.md"
CWD="$(pwd)"

INPUT=""
if [ ! -t 0 ]; then
  INPUT="$(cat)"
fi

SESSION_ID=""
TRANSCRIPT_PATH=""
if [ -n "$INPUT" ] && command -v jq >/dev/null 2>&1; then
  SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)"
  TRANSCRIPT_PATH="$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || true)"
fi

{
  printf '## %s\n' "$TIME"
  printf '- cwd: %s\n' "$CWD"
  [ -n "$SESSION_ID" ] && printf '- session: %s\n' "$SESSION_ID"
  [ -n "$TRANSCRIPT_PATH" ] && printf '- transcript: %s\n' "$TRANSCRIPT_PATH"
  printf '\n'
} >> "$OUTFILE"

exit 0
