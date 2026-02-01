#!/usr/bin/env bash
set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧭 NEWTON COMMAND ACADEMY"
echo "🔒 CANON TYPE ENFORCEMENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CANON_PATH="@/cert_intel/intake/lib/canonTypes"

echo "�� Scanning for CanonLesson imports..."

FILES=$(grep -R --line-number --fixed-strings "CanonLesson" . \
  | grep -E "\.(ts|tsx)$" \
  | cut -d: -f1 \
  | sort -u)

if [ -z "$FILES" ]; then
  echo "✅ No CanonLesson imports found."
  exit 0
fi

echo "�� Files to process:"
echo "$FILES"
echo ""

for FILE in $FILES; do
  echo "🛠 Fixing $FILE"

  # Remove any existing CanonLesson import
  sed -i '' \
    -E '/import .*CanonLesson.*from/d' \
    "$FILE"

  # Insert canonical import at top (after shebang or 'use client')
  awk -v canon="import { CanonLesson } from \"$CANON_PATH\";" '
    BEGIN { inserted=0 }
    {
      print $0
      if (!inserted && ($0 ~ /^"use client"/ || NR==1)) {
        print canon
        inserted=1
      }
    }
  ' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

done

echo ""
echo "✅ CanonLesson imports unified."
echo "🔒 Shadow types eliminated."
echo ""
echo "⚠️ Clearing build cache…"
rm -rf .next node_modules/.cache

echo "🏗 Running build…"
npm run build

echo ""
echo "🎉 CANON TYPE ENFORCEMENT COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
