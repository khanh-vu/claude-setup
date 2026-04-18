#!/usr/bin/env bash
# Post-install verification. Exit non-zero if any check fails.

set -uo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
FAIL=0

check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf '  OK  %s\n' "$name"
  else
    printf 'FAIL  %s\n' "$name"
    FAIL=1
  fi
}

echo "Verifying $CLAUDE_HOME..."

check "CLAUDE.md symlink resolves"     test -L "$CLAUDE_HOME/CLAUDE.md" -a -e "$CLAUDE_HOME/CLAUDE.md"
check "claude.json symlink resolves"   test -L "$CLAUDE_HOME/claude.json" -a -e "$CLAUDE_HOME/claude.json"
check "settings.json exists"           test -f "$CLAUDE_HOME/settings.json"
check "permissions.deny present"       jq -e '.permissions.deny | length > 0' "$CLAUDE_HOME/settings.json"
check "permissions.ask present"        jq -e '.permissions.ask   | length > 0' "$CLAUDE_HOME/settings.json"
check "Stop hook registered"           jq -e '.hooks.Stop | length > 0'        "$CLAUDE_HOME/settings.json"
check "handoff-on-stop.sh exists"      test -x "$CLAUDE_HOME/scripts/handoff-on-stop.sh"
check "gstack present"                 test -d "$CLAUDE_HOME/skills/gstack"
check "golang-pro agent linked"        test -L "$CLAUDE_HOME/agents/golang-pro.md"
check "nodejs-backend agent linked"    test -L "$CLAUDE_HOME/agents/nodejs-backend.md"
check "supabase-expert agent linked"   test -L "$CLAUDE_HOME/agents/supabase-expert.md"
check "typescript-pro agent linked"    test -L "$CLAUDE_HOME/agents/typescript-pro.md"
check "llm-registry-expert linked"     test -L "$CLAUDE_HOME/agents/llm-registry-expert.md"
check "deployment-integration-expert symlinked (v2)" test -L "$CLAUDE_HOME/agents/deployment-integration-expert.md"

# No duplicate-suffix agent files
if ls "$CLAUDE_HOME/agents/"*\ 2.md >/dev/null 2>&1; then
  printf 'FAIL  no duplicate "* 2.md" agent files\n'
  FAIL=1
else
  printf '  OK  no duplicate "* 2.md" agent files\n'
fi

# Non-agent files archived
for f in commands.md context_session_1.md scorecard.md task.md; do
  if [ -f "$CLAUDE_HOME/agents/$f" ]; then
    printf 'FAIL  agents/%s still loose (should be in _archive/)\n' "$f"
    FAIL=1
  fi
done
[ "$FAIL" -eq 0 ] && printf '  OK  non-agent files archived\n'

if [ "$FAIL" -eq 0 ]; then
  echo "All checks passed."
else
  echo "Some checks failed." >&2
  exit 1
fi
