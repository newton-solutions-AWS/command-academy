#!/usr/bin/env bash
set -euo pipefail

echo "☢️  NCA COMMANDER :: ARCHIVE LEGACY RUNTIME COMMANDERS"
echo "----------------------------------------------------"

ARCHIVE_DIR="commanders/_legacy_archived"
mkdir -p "$ARCHIVE_DIR"

KEEP=(
  "commander_killshot_runtime_unify.sh"
)

echo "📦 Archiving old commanders that reference deprecated APIs..."

for file in commanders/*.sh; do
  name="$(basename "$file")"

  # Skip archive dir itself
  [[ "$name" == "_legacy_archived" ]] && continue

  keep=false
  for k in "${KEEP[@]}"; do
    [[ "$name" == "$k" ]] && keep=true
  done

  if [[ "$keep" == false ]]; then
    echo "  → Archiving $name"
    mv "$file" "$ARCHIVE_DIR/$name"
  else
    echo "  ✓ Keeping $name"
  fi
done

echo ""
echo "🔒 Runtime commander surface is now LOCKED"
echo "📂 Archived commanders moved to: $ARCHIVE_DIR"
echo "✅ No legacy APIs can resurrect activeMission"
