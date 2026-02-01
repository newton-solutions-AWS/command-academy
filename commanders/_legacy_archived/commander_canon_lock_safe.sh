#!/usr/bin/env bash
set -euo pipefail

echo "🔒 CANON LOCK — SAFE MODE"
echo "📍 Repo: $(pwd)"
echo "🔎 Scanning for CanonLesson DEFINITIONS (not usage)..."

# find "export type CanonLesson" or "export interface CanonLesson" in real source files only
defs="$(grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=commanders \
  -E 'export (type|interface) CanonLesson' . || true)"

count="$(printf "%s" "$defs" | grep -c 'export ' || true)"

# If grep found nothing, count will be 0 (but grep -c on empty prints 0 and exits 1; handled by || true).
if [ "${count:-0}" -eq 0 ]; then
  echo "❌ ERROR: No CanonLesson definition found. There must be EXACTLY ONE."
  exit 1
fi

if [ "${count:-0}" -gt 1 ]; then
  echo "❌ ERROR: Multiple CanonLesson definitions detected!"
  echo
  printf "%s\n" "$defs"
  echo
  echo "🛑 Canon violation. There must be EXACTLY ONE CanonLesson."
  exit 1
fi

echo "✅ CanonLesson single definition confirmed."
