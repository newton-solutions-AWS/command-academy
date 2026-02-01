#!/usr/bin/env bash
set -e

echo "🧠 RESTORING CORE MISSION RUNTIME (NO SIDE EFFECTS)"

# Restore missionRuntimeStore (pure data only)
cat > lib/missionRuntimeStore.ts << 'EOF'
type ActiveMission = {
  lessonId: string;
  division: string;
  completedSteps: Record<number, boolean>;
  stepIndex: number;
};

let state: { active: ActiveMission | null } = {
  active: null,
};

export function getMissionRuntimeState() {
  return state;
}

export function startMission(lessonId: string, division: string) {
  state.active = {
    lessonId,
    division,
    completedSteps: {},
    stepIndex: 0,
  };
}

export function abortMission() {
  state.active = null;
}

export function toggleStepComplete(step: number) {
  if (!state.active) return;
  state.active.completedSteps[step] = !state.active.completedSteps[step];
}

export function setStepIndex(step: number) {
  if (!state.active) return;
  state.active.stepIndex = step;
}
EOF

# Restore SAFE hook (read-only render)
cat > lib/useMissionRuntime.ts << 'EOF'
"use client";

import { useSyncExternalStore } from "react";
import {
  getMissionRuntimeState,
  startMission,
  abortMission,
} from "./missionRuntimeStore";

export function useMissionRuntime() {
  const runtime = useSyncExternalStore(
    () => () => {},
    () => getMissionRuntimeState()
  );

  return {
    runtime,
    startMission,
    abortMission,
  };
}
EOF

rm -rf .next

echo "✅ Core mission runtime restored"
echo "🚀 Run: npm run dev"