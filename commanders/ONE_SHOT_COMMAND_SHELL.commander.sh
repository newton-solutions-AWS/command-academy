#!/usr/bin/env bash
set -e

echo "🧠 COMMAND SHELL ONE-SHOT — ENFORCING SINGLE SOURCE OF TRUTH"

SEARCH_DIRS="app components lib"

ILLEGAL_STRINGS=(
  'useState("GOV"'
  'useState("TAC"'
  'useState("UNI"'
  'useState("VANGUARD"'
  'useState("PHOENIX"'
  'useState("SENTINEL"'
  'useState("EASY"'
  'useState("PRO"'
  'useState("ELITE"'
)

echo "🔍 Scanning for illegal local command state..."

FOUND=0

for str in "${ILLEGAL_STRINGS[@]}"; do
  MATCHES=$(rg --fixed-strings "$str" $SEARCH_DIRS || true)
  if [ -n "$MATCHES" ]; then
    echo ""
    echo "❌ ILLEGAL COMMAND STATE FOUND:"
    echo "$MATCHES"
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo ""
  echo "🛑 COMMAND SHELL VIOLATION"
  echo "👉 No component may own command state"
  echo "👉 Use commandShellStore ONLY"
  echo ""
  exit 1
fi

echo "✅ No illegal command state found"
echo "🔒 Command Shell integrity intact"