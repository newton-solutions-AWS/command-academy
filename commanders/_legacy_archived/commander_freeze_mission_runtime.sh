#!/usr/bin/env bash
set -e

echo "🧊 FREEZING MISSION RUNTIME — ISOLATION MODE"

# 1. Stub mission runtime hook
cat > lib/useMissionRuntime.ts << 'EOF'
"use client";

export function useMissionRuntime() {
  return {
    runtime: null,
    startMission: () => {},
    touchMission: () => {},
    abortMission: () => {},
  };
}
EOF

# 2. Stub mission runtime store
cat > lib/missionRuntimeStore.ts << 'EOF'
export function getMissionRuntimeState() {
  return { active: null };
}
export function toggleStepComplete() {}
export function setStepIndex() {}
EOF

# 3. Hard clean
rm -rf .next

echo "✅ Mission runtime frozen"
echo "🚀 Run: npm run dev"