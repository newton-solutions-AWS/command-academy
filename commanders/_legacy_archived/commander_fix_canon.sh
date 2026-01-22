#!/usr/bin/env bash
set -e

echo "🧹 FIXING CANON TYPES"

CANON_FILE="cert_intel/intake/lib/canonTypes.ts"

# Ensure canon file exists
if [ ! -f "$CANON_FILE" ]; then
  echo "❌ Canon file missing: $CANON_FILE"
  exit 1
fi

echo "🔍 Removing shadow CanonLesson definitions..."

# Remove CanonLesson interfaces from known offenders
sed -i '' '/export interface CanonLesson {/,/}/d' cert_intel/intake/lib/lessonloader.ts || true
sed -i '' '/export interface CanonLesson {/,/}/d' cert_intel/intake/lib/types.ts || true

echo "🔁 Rewriting imports to canonTypes..."

grep -rl "CanonLesson" . \
  | grep -v canonTypes.ts \
  | xargs sed -i '' 's|from .*CanonLesson.*|from "@/cert_intel/intake/lib/canonTypes"|g' || true

echo "✅ Canon enforcement complete"
