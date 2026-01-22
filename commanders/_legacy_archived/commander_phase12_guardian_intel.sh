#!/usr/bin/env bash
set -euo pipefail

echo "🧠 PHASE 12 — GUARDIAN ANGEL INTELLIGENCE"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 1) Guardian Intelligence Engine
# ------------------------------------------------------------
mkdir -p lib

cat > lib/guardianIntel.ts <<'TS'
export type GuardianSignal =
  | "STALLING"
  | "SKIP_DETECTED"
  | "RAPID_TOGGLE"
  | "MISSION_COMPLETE"
  | "CLEAN_RUN";

export type GuardianAssessment = {
  signal: GuardianSignal;
  message: string;
};

export function assessMission(
  steps: string[],
  completed: Record<number, boolean>,
  timestamps: number[]
): GuardianAssessment {
  const total = steps.length;
  const done = Object.keys(completed).length;

  // Completed clean
  if (done === total) {
    return {
      signal: "MISSION_COMPLETE",
      message: "Mission complete. Log service record and proceed.",
    };
  }

  // Stalling: nothing done for a while
  const now = Date.now();
  const last = timestamps[timestamps.length - 1] ?? 0;
  if (now - last > 1000 * 60 * 4) {
    return {
      signal: "STALLING",
      message:
        "You’ve been idle. Re-read the current step and execute deliberately.",
    };
  }

  // Skip detection
  for (let i = 0; i < done; i++) {
    if (!completed[i]) {
      return {
        signal: "SKIP_DETECTED",
        message:
          "You’ve skipped a step. Complete steps in order for a clean run.",
      };
    }
  }

  // Rapid toggling (panic clicking)
  if (timestamps.length >= 4) {
    const delta =
      timestamps[timestamps.length - 1] -
      timestamps[timestamps.length - 4];
    if (delta < 4000) {
      return {
        signal: "RAPID_TOGGLE",
        message:
          "Slow down. This is not speed-based. Execute one step properly.",
      };
    }
  }

  return {
    signal: "CLEAN_RUN",
    message: "Proceed methodically. You are on track.",
  };
}
TS

# ------------------------------------------------------------
# 2) Intervention Log (Black Box compatible)
# ------------------------------------------------------------
cat > lib/guardianLog.ts <<'TS'
import type { GuardianSignal } from "./guardianIntel";

export type GuardianEvent = {
  lessonId: string;
  signal: GuardianSignal;
  at: string;
};

const KEY = "nca:guardian:log";

export function logGuardianEvent(event: GuardianEvent) {
  if (typeof window === "undefined") return;

  const raw = localStorage.getItem(KEY);
  const events = raw ? JSON.parse(raw) : [];
  events.push(event);
  localStorage.setItem(KEY, JSON.stringify(events));
}
TS

# ------------------------------------------------------------
# 3) Upgrade GuardianAngelPanel with intelligence
# ------------------------------------------------------------
cat > components/guardian/GuardianAngelPanel.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import { getMissionState, toggleStepComplete, resetMission } from "@/lib/missionStore";
import { assessMission } from "@/lib/guardianIntel";
import { logGuardianEvent } from "@/lib/guardianLog";

type Props = {
  lessonId: string;
  division: "phoenix" | "vanguard" | "sentinel";
  steps: string[];
};

export default function GuardianAngelPanel({ lessonId, division, steps }: Props) {
  const storageKey = useMemo(() => `${division}:${lessonId}`, [division, lessonId]);

  const [completed, setCompleted] = useState<Record<number, boolean>>({});
  const [timestamps, setTimestamps] = useState<number[]>([]);
  const [intel, setIntel] = useState<string>("Awaiting execution.");

  useEffect(() => {
    const state = getMissionState(storageKey);
    setCompleted(state.completedSteps ?? {});
  }, [storageKey]);

  useEffect(() => {
    const assessment = assessMission(steps, completed, timestamps);
    setIntel(assessment.message);

    logGuardianEvent({
      lessonId,
      signal: assessment.signal,
      at: new Date().toISOString(),
    });
  }, [completed, timestamps, steps, lessonId]);

  function onToggleStep(i: number) {
    const next = toggleStepComplete(storageKey, i);
    setCompleted(next.completedSteps ?? {});
    setTimestamps((t) => [...t, Date.now()]);
  }

  function onReset() {
    resetMission(storageKey);
    setCompleted({});
    setTimestamps([]);
    setIntel("Mission reset. Begin again clean.");
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl">
      <div className="px-5 py-4 border-b border-white/10">
        <div className="text-xs tracking-[0.28em] text-white/50">GUARDIAN ANGEL</div>
        <div className="text-sm text-white/70 mt-2">{intel}</div>
      </div>

      <div className="p-5 space-y-2">
        {steps.map((s, i) => (
          <button
            key={i}
            onClick={() => onToggleStep(i)}
            className={[
              "w-full text-left rounded-lg px-4 py-3 border",
              completed[i]
                ? "border-emerald-400/40 bg-emerald-500/10 text-emerald-300"
                : "border-white/10 bg-black/20 text-white/70",
            ].join(" ")}
          >
            <span className="mr-2 opacity-50">{i + 1}.</span>
            {s}
          </button>
        ))}

        <button
          onClick={onReset}
          className="w-full mt-4 rounded-lg border border-white/10 bg-black/30 px-4 py-2 text-xs text-white/50 hover:text-white/80"
        >
          Reset Mission
        </button>
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

echo "✅ PHASE 12 COMPLETE — GUARDIAN ANGEL INTELLIGENT"
echo "🚀 Run: npm run dev"
