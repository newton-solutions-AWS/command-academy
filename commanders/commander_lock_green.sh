#!/usr/bin/env bash
set -e

echo "🔒 LOCKING GREEN STATE"

rm -rf .next
npm run build

echo "✅ BUILD GREEN — STATE LOCKED"

git status
