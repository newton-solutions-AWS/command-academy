#!/usr/bin/env bash
set -e

export LC_ALL=C
export LANG=C

echo "🔒 LOCKING CANON TYPES"

CANON_FILE="cert_intel/intake/lib/canonTypes.ts"

if [ ! -f "$CANON_FILE" ]; then
  echo "❌ Canon file missing: $CANON_FILE"
  exit 1
fi

echo "🧹 Removing shadow CanonLesson definitions..."

FILES=$(grep -R "export interface CanonLesson" . \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude=canonTypes.ts \
  --exclude=*.sh \
  | cut -d: -f1 | sort -u)

for f in $FILES; do
  echo "  ➤ Purging $f"
  sed -i '' '/export interface CanonLesson {/,/}/d' "$f"
done

echo "🔎 Verifying uniqueness..."

COUNT=$(grep -R "interface CanonLesson" . \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude=*.sh \
  | wc -l | tr -d ' ')

if [ "$COUNT" -ne 1 ]; then
  echo "❌ CanonLesson violation detected ($COUNT found)"
  exit 1
fi

echo "✅ CanonLesson locked to single source"
