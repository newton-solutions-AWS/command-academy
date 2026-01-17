#!/usr/bin/env bash
set -e

echo "🔒 LOCKING CANON BASELINE — NEWTON COMMAND ACADEMY"

# Safety: commanders must NEVER be part of build
if grep -R "commanders" tsconfig.json >/dev/null; then
  echo "✅ Commanders excluded from build"
else
  echo "❌ commanders/ NOT excluded from tsconfig.json"
  exit 1
fi

rm -rf .next
npm run build

git add \
  app \
  components \
  lib \
  cert_intel \
  postcss.config.js \
  tailwind.config.js \
  tsconfig.json \
  package.json \
  package-lock.json

echo ""
echo "=== CANON STATUS ==="
git status --short

read -p "Proceed with CANON COMMIT? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "❌ Aborted by operator."
  exit 1
fi

git commit -m "canon: lock green baseline (academy runtime stable)"

echo "✅ CANON BASELINE LOCKED"