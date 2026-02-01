#!/usr/bin/env bash
set -euo pipefail

echo "🧹 CANON PURGE & LOCK — NEWTON COMMAND ACADEMY"
ROOT="$(pwd)"
CANON_FILE="cert_intel/intake/lib/canonTypes.ts"

echo "📍 Repo: $ROOT"
echo "📌 Canon file: $CANON_FILE"
echo ""

# ------------------------------------------------------------
# 1) Remove legacy CanonLesson type files
# ------------------------------------------------------------
echo "🗑 Removing legacy canon type files..."

rm -f cert_intel/intake/lib/lessonTypes.ts || true
rm -f cert_intel/intake/lib/types.ts || true

# ------------------------------------------------------------
# 2) Remove CanonLesson definitions from runtime files (safety)
# ------------------------------------------------------------
echo "🧼 Scrubbing runtime files for shadow definitions..."

grep -R --exclude-dir=commanders \
       --exclude="$CANON_FILE" \
       -l "export .*CanonLesson" . \
| while read -r file; do
    echo "  • Removing CanonLesson from $file"
    sed -i '' '/export .*CanonLesson {/,/}/d' "$file" || true
  done

# ------------------------------------------------------------
# 3) Enforce SINGLE CanonLesson (ignore commanders)
# ------------------------------------------------------------
echo ""
echo "🔎 Verifying canon uniqueness (runtime only)..."

MATCHES=$(grep -R --exclude-dir=commanders \
                 --line-number \
                 "export .*CanonLesson" . || true)

COUNT=$(echo "$MATCHES" | grep -c "CanonLesson" || true)

if [[ "$COUNT" -ne 1 ]]; then
  echo "❌ CANON VIOLATION — Expected exactly 1 CanonLesson"
  echo ""
  echo "$MATCHES"
  exit 1
fi

if ! echo "$MATCHES" | grep -q "$CANON_FILE"; then
  echo "❌ CanonLesson exists outside canonTypes.ts"
  echo ""
  echo "$MATCHES"
  exit 1
fi

# ------------------------------------------------------------
# 4) Final build verification
# ------------------------------------------------------------
echo ""
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo ""
echo "🔒 CANON LOCKED — THIS CANNOT DRIFT AGAIN"
echo "⭐ NORTH STAR FOUNDATION SECURED"