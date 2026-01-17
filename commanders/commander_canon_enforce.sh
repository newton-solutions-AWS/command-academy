#!/usr/bin/env bash
set -e

echo "🔒 ENFORCING CANON TYPES"

grep -R "interface CanonLesson" . \
  | grep -v "canonTypes.ts" \
  && echo "❌ Shadow CanonLesson found" && exit 1

grep -R "type CanonLesson" . \
  | grep -v "canonTypes.ts" \
  && echo "❌ Shadow CanonLesson found" && exit 1

echo "✅ CanonLesson is singular"
