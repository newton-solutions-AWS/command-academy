#!/usr/bin/env bash
set -euo pipefail

echo "🔒 LOCKING GREEN STATE — NEWTON COMMAND ACADEMY"

rm -rf .next
npm run build

echo "✅ BUILD GREEN — STATE LOCKED"

git status