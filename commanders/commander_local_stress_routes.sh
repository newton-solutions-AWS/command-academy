#!/usr/bin/env bash
set -e

BASE_URL="http://localhost:3000"
LESSONS=(
  "phoenix-boot-001"
)

echo "🔥 LOCAL ROUTE STRESS — NEWTON COMMAND ACADEMY"
echo "--------------------------------------------"
echo "Target: $BASE_URL"
echo ""

for i in {1..100}; do
  for lesson in "${LESSONS[@]}"; do
    curl -s "$BASE_URL/academy/phoenix/$lesson" > /dev/null &
  done
done

wait
echo "✅ Route hammer complete"