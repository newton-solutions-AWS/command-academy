#!/usr/bin/env bash
set -euo pipefail

echo "🧠 PHASE 6 — GUARDIAN ANGEL INTELLIGENCE"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p lib/guardian
mkdir -p components/guardian

# ------------------------------------------------------------
# 1) Guardian Intelligence Engine
# ------------------------------------------------------------
cat > lib/guardian/guardianIntel.ts <<'TS'
export type GuardianSignal =
  | "idle"
  | "progress"
  | "stall"
  | "regression"
  | "complete";

export type GuardianAssessment = {
  signal: GuardianSignal;
  message: string;
};

const STALL_MINUTES = 6;
const REGRESSION_THRESHOLD = 2;

export function assessGuardianState(
  lastActionAt: number,
  completedSteps: Record<number, boolean>,
  resetCount: number
): GuardianAssessment {
  const now = Date.now();
  const minutesIdle = (now - lastActionAt) / 60000;
  const completed = Object.values(completedSteps).filter(Boolean).length;

  if (completed === 0 && minutesIdle < STALL_MINUTES) {
    return {
      signal: "idle",
      message: "Mission standing by. Begin when ready.",
    };
  }

  if (resetCount >= REGRESSION_THRESHOLD) {
    return {
      signal: "regression",
      message:
        "You’ve reset multiple times. Pause. Re-read the concept block before proceeding.",
    };
  }

  if (minutesIdle >= STALL_MINUTES) {
    return {
      signal: "stall",
      message:
        "You’ve been idle for a while. Don’t guess — re-run the current step carefully.",
    };
  }

  if (completed > 0) {
    return {
      signal: "progress",
      message: "Good pace. Maintain discipline and proceed step-by-step.",
    };
  }

  return {
    signal: "idle",
    message: "Standing by.",
  };
}
TS

# ------------------------------------------------------------
# 2) Upgrade Mission Store to track time + resets
# ------------------------------------------------------------
cat > lib/missionStore.ts <<'TS'
export type MissionState = {
  completedSteps: Record<number, boolean>;
  panelOpen: boolean;
  lastActionAt: number;
  resetCount: number;
};

const prefix = "nca:mission:";

function now() {
  return Date.now();
}

function safeParse(raw: string | null): MissionState | null {
  if (!raw) return null;
  try {
    const v = JSON.parse(raw);
    return {
      completedSteps: v.completedSteps ?? {},
      panelOpen: typeof v.panelOpen === "boolean" ? v.panelOpen : true,
      lastActionAt: v.lastActionAt ?? now(),
      resetCount: v.resetCount ?? 0,
    };
  } catch {
    return null;
  }
}

export function getMissionState(key: string): MissionState {
  if (typeof window === "undefined") {
    return {
      completedSteps: {},
      panelOpen: true,
      lastActionAt: now(),
      resetCount: 0,
    };
  }

  const state = safeParse(localStorage.getItem(prefix + key));
  return (
    state ?? {
      completedSteps: {},
      panelOpen: true,
      lastActionAt: now(),
      resetCount: 0,
    }
  );
}

export function toggleStepComplete(
  key: string,
  stepIndex: number
): MissionState {
  const state = getMissionState(key);
  const next: MissionState = {
    ...state,
    completedSteps: {
      ...state.completedSteps,
      [stepIndex]: !state.completedSteps[stepIndex],
    },
    lastActionAt: now(),
  };
  localStorage.setItem(prefix + key, JSON.stringify(next));
  return next;
}

export function resetMission(key: string): MissionState {
  const state = getMissionState(key);
  const next: MissionState = {
    completedSteps: {},
    panelOpen: true,
    lastActionAt: now(),
    resetCount: state.resetCount + 1,
  };
  localStorage.setItem(prefix + key, JSON.stringify(next));
  return next;
}
TS

# ------------------------------------------------------------
# 3) Upgrade Guardian Angel Panel (Intel-aware)
# ------------------------------------------------------------
cat > components/guardian/GuardianAngelPanel.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import {
  getMissionState,
  toggleStepComplete,
  resetMission,
} from "@/lib/missionStore";
import {
  assessGuardianState,
} from "@/lib/guardian/guardianIntel";

type Props = {
  lessonId: string;
  division: "phoenix" | "vanguard" | "sentinel";
  steps: string[];
};

export default function GuardianAngelPanel({
  lessonId,
  division,
  steps,
}: Props) {
  const storageKey = useMemo(
    () => `${division}:${lessonId}`,
    [division, lessonId]
  );

  const [state, setState] = useState(getMissionState(storageKey));

  useEffect(() => {
    setState(getMissionState(storageKey));
  }, [storageKey]);

  const assessment = assessGuardianState(
    state.lastActionAt,
    state.completedSteps,
    state.resetCount
  );

  function onToggleStep(i: number) {
    setState(toggleStepComplete(storageKey, i));
  }

  function onReset() {
    setState(resetMission(storageKey));
  }

  const doneCount = Object.values(state.completedSteps).filter(Boolean).length;

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl">
      <div className="px-5 py-4 border-b border-white/10">
        <div className="text-xs tracking-[0.28em] text-white/50">
          GUARDIAN ANGEL
        </div>
        <div className="text-sm text-white/80 mt-1">
          {assessment.message}
        </div>
      </div>

      <div className="p-5 space-y-3">
        {steps.map((s, i) => {
          const isDone = !!state.completedSteps[i];
          return (
            <div
              key={i}
              className="flex gap-3 items-start rounded-xl border border-white/10 bg-white/5 px-4 py-3"
            >
              <button
                onClick={() => onToggleStep(i)}
                className={[
                  "h-5 w-5 rounded-md border flex items-center justify-center mt-0.5",
                  isDone
                    ? "border-emerald-400/40 bg-emerald-500/10"
                    : "border-white/20 bg-black/30",
                ].join(" ")}
              >
                {isDone ? "✓" : ""}
              </button>

              <div className="text-sm text-white/75">{s}</div>
            </div>
          );
        })}

        <button
          onClick={onReset}
          className="mt-3 text-xs px-3 py-1.5 rounded-full border border-white/10 bg-white/5 text-white/70 hover:bg-white/10"
        >
          Reset Mission
        </button>

        <div className="text-xs text-white/40 pt-2">
          Completed: {doneCount}/{steps.length}
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 6 COMPLETE — GUARDIAN ANGEL INTELLIGENT"
echo "🚀 Run: npm run dev"
