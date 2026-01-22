#!/usr/bin/env bash
set -euo pipefail

echo "🔒 CANON LOCK — SAFE MODE"
ROOT="$(pwd)"
CANON_FILE="cert_intel/intake/lib/canonTypes.ts"

echo "📍 Repo: $ROOT"
echo "📌 Canon file: $CANON_FILE"
echo ""

# ------------------------------------------------------------
# 1) Verify canon file exists
# ------------------------------------------------------------
if [[ ! -f "$CANON_FILE" ]]; then
  echo "❌ Canon file missing: $CANON_FILE"
  exit 1
fi

# ------------------------------------------------------------
# 2) Find CanonLesson DEFINITIONS only (runtime TS files)
# ------------------------------------------------------------
echo "🔎 Scanning for CanonLesson DEFINITIONS (not usage)..."

MATCHES=$(grep -R \
  --include="*.ts" \
  --include="*.tsx" \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude-dir=.git \
  -nE "export (type|interface) CanonLesson" . || true)

COUNT=$(echo "$MATCHES" | grep -c "CanonLesson" || true)

if [[ "$COUNT" -ne 1 ]]; then
  echo "❌ CANON VIOLATION — Expected exactly 1 CanonLesson definition"
  echo ""
  echo "$MATCHES"
  exit 1
fi

if ! echo "$MATCHES" | grep -q "$CANON_FILE"; then
  echo "❌ CanonLesson is not defined in canonTypes.ts"
  echo ""
  echo "$MATCHES"
  exit 1
fi

# ------------------------------------------------------------
# 3) Build verification
# ------------------------------------------------------------
echo ""
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo ""
echo "✅ CANON LOCKED — SAFE & STABLE"
echo "⭐ NORTH STAR FOUNDATION CONFIRMED"