#!/usr/bin/env bash
# Standalone snapshot of ~/.claude/ to ~/claude-bak-<date>.tar
# Run this before any risky change you don't trust install.sh's per-file backups to cover.

set -euo pipefail

DATE="$(date +%F)"
OUT="$HOME/claude-bak-$DATE.tar"

if [ -f "$OUT" ]; then
  OUT="$HOME/claude-bak-$(date +%F-%H%M%S).tar"
fi

echo "Creating $OUT..."
tar -cf "$OUT" -C "$HOME" .claude
ls -lh "$OUT"
echo "Done. Restore with: tar -xf $OUT -C \$HOME"
