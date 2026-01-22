#!/usr/bin/env bash
set -euo pipefail

echo "🧨 FIX & FREEZE — MISSION RUNTIME (NORTH STAR CONTRACT)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

# ============================================================
# 1) HARD RESET — remove all runtime drift
# ============================================================
echo "🧹 Removing legacy / duplicate mission runtime files"
rm -f lib/useMissionRuntime.ts || true
rm -f lib/missionRuntime.store.ts || true
rm -f lib/runtimeMission.ts || true

# ============================================================
# 2) WRITE SINGLE SOURCE OF TRUTH
# ============================================================
mkdir -p lib

cat > lib/missionRuntime.ts <<'TS'
"use client";

import { useSyncExternalStore } from "react";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

/* ============================================================
   TYPES
============================================================ */
export type ActiveMission = {
  lessonId: string;
  division: Division;
  startedAt: number;
  lastSeenAt: number;
  stepIndex: number;
  completedSteps: Record<number, boolean>;
  notes?: string;
};

export type MissionRuntime = {
  active: ActiveMission | null;
};

/* ============================================================
   INTERNAL STORE
============================================================ */
const STORAGE_KEY = "nca:mission.runtime.v1";

let runtime: MissionRuntime = { active: null };
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((l) => l());
}

function persist() {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(runtime));
}

function hydrate() {
  if (typeof window === "undefined") return;
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) runtime = JSON.parse(raw);
  } catch {
    runtime = { active: null };
  }
}

/* ============================================================
   CORE ACTIONS
============================================================ */
export function startMission(input: { lessonId: string; division: Division }) {
  const now = Date.now();
  runtime = {
    active: {
      lessonId: input.lessonId,
      division: input.division,
      startedAt: now,
      lastSeenAt: now,
      stepIndex: 0,
      completedSteps: {},
    },
  };
  persist();
  emit();
}

export function touchMission() {
  if (!runtime.active) return;
  runtime.active.lastSeenAt = Date.now();
  persist();
  emit();
}

export function setStepIndex(stepIndex: number) {
  if (!runtime.active) return;
  runtime.active.stepIndex = Math.max(0, stepIndex);
  runtime.active.lastSeenAt = Date.now();
  persist();
  emit();
}

export function toggleStepComplete(step: number) {
  if (!runtime.active) return;
  runtime.active.completedSteps[step] =
    !runtime.active.completedSteps[step];
  runtime.active.lastSeenAt = Date.now();
  persist();
  emit();
}

export function addMissionNote(notes: string) {
  if (!runtime.active) return;
  runtime.active.notes = notes;
  runtime.active.lastSeenAt = Date.now();
  persist();
  emit();
}

export function clearMission() {
  runtime = { active: null };
  persist();
  emit();
}

/* ============================================================
   REACT HOOK — ONLY PUBLIC API
============================================================ */
function subscribe(cb: () => void) {
  hydrate();
  listeners.add(cb);
  return () => listeners.delete(cb);
}

function getSnapshot(): MissionRuntime {
  return runtime;
}

export function useMissionRuntime() {
  const snap = useSyncExternalStore(
    subscribe,
    getSnapshot,
    () => ({ active: null })
  );

  return {
    runtime: snap,
    startMission,
    touchMission,
    setStepIndex,
    toggleStepComplete,
    addMissionNote,
    clearMission,
  };
}
TS

# ============================================================
# 3) NORMALISE ALL CONSUMERS
# ============================================================

echo "🔧 Normalising consumers to runtime.active"

# LessonShell
cat > components/command/LessonShell.tsx <<'TSX'
"use client";

import { useEffect } from "react";
import { useMissionRuntime } from "@/lib/missionRuntime";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

export default function LessonShell({ lesson }: { lesson: CanonLesson }) {
  const { runtime, startMission, touchMission } = useMissionRuntime();

  useEffect(() => {
    if (!runtime.active) {
      startMission({ lessonId: lesson.id, division: lesson.division });
    } else {
      touchMission();
    }
  }, [lesson.id]);

  return (
    <main className="mx-auto max-w-6xl px-6 py-16 text-white">
      <h1 className="text-3xl font-semibold">{lesson.title}</h1>
      <p className="mt-4 text-white/70">{lesson.concept}</p>
    </main>
  );
}
TSX

# ActiveMissionCard
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/missionRuntime";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { runtime, clearMission } = useMissionRuntime();
  const active = runtime.active;

  if (!active) {
    return (
      <div className="rounded-xl border border-white/10 p-6 text-white/50">
        No active mission
      </div>
    );
  }

  return (
    <div className="rounded-xl border border-white/10 p-6">
      <div className="text-sm text-white/60">ACTIVE MISSION</div>
      <div className="mt-2 text-lg">{active.lessonId}</div>

      <div className="mt-4 flex gap-3">
        <button
          onClick={() =>
            router.push(`/academy/${active.division}/${active.lessonId}`)
          }
          className="px-4 py-2 rounded bg-white/10 hover:bg-white/20"
        >
          Resume
        </button>

        <button
          onClick={clearMission}
          className="px-4 py-2 rounded bg-red-500/20 hover:bg-red-500/30"
        >
          Abort
        </button>
      </div>
    </div>
  );
}
TSX

# MissionLauncher
cat > components/hq/MissionLauncher.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/missionRuntime";

export default function MissionLauncher() {
  const router = useRouter();
  const { startMission } = useMissionRuntime();

  function launch() {
    startMission({ lessonId: "intro-001", division: "phoenix" });
    router.push("/academy/phoenix/intro-001");
  }

  return (
    <button
      onClick={launch}
      className="px-6 py-3 rounded bg-emerald-500/20 hover:bg-emerald-500/30"
    >
      Launch Mission
    </button>
  );
}
TSX

# StatusStrip
cat > components/hq/StatusStrip.tsx <<'TSX'
"use client";

import { useMissionRuntime } from "@/lib/missionRuntime";

export default function StatusStrip() {
  const { runtime } = useMissionRuntime();

  return (
    <div className="text-xs text-white/50">
      {runtime.active ? "MISSION ACTIVE" : "IDLE"}
    </div>
  );
}
TSX

# ============================================================
# 4) FREEZE CONTRACT
# ============================================================
echo "🔒 Freezing missionRuntime.ts"
shasum lib/missionRuntime.ts > lib/missionRuntime.ts.sha

# ============================================================
# 5) BUILD CHECK
# ============================================================
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ MISSION RUNTIME FIXED & FROZEN"
echo "🚀 Run: npm run dev"