#!/usr/bin/env bash
set -euo pipefail

echo "🛰️  NCA COMMANDER :: FIX MISSION RUNTIME v1"
echo "------------------------------------------------------------"
echo "This commander will overwrite:"
echo " - lib/missionRuntimeStore.ts"
echo " - lib/useMissionRuntime.ts"
echo " - components/hq/MissionLauncher.tsx"
echo " - components/hq/ActiveMissionCard.tsx"
echo " - components/command/LessonShell.tsx"
echo "------------------------------------------------------------"

# ------------------------------------------------------------
# 1) lib/missionRuntimeStore.ts
# ------------------------------------------------------------
cat > lib/missionRuntimeStore.ts <<'TS'
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type MissionRuntime = {
  lessonId: string;
  division: Division;
  stepIndex: number;
  completedSteps: Record<number, boolean>;
  lastTouched: number;
};

type State = { active: MissionRuntime | null };

let runtime: MissionRuntime | null = null;
const listeners = new Set<() => void>();

const STORAGE_KEY = "nca:missionRuntime:v1";

function isBrowser() {
  return typeof window !== "undefined";
}

function notify() {
  for (const l of listeners) l();
}

function readStorage(): MissionRuntime | null {
  if (!isBrowser()) return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as MissionRuntime;
    if (!parsed || typeof parsed.lessonId !== "string") return null;
    return parsed;
  } catch {
    return null;
  }
}

function writeStorage(next: MissionRuntime | null) {
  if (!isBrowser()) return;
  try {
    if (!next) window.localStorage.removeItem(STORAGE_KEY);
    else window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
  } catch {
    // ignore storage failures
  }
}

function ensureHydrated() {
  // One-time hydration (client only)
  if (!isBrowser()) return;
  if (runtime !== null) return;
  const fromStorage = readStorage();
  runtime = fromStorage;
}

export function subscribeMissionRuntime(cb: () => void) {
  listeners.add(cb);
  return () => listeners.delete(cb);
}

export function getMissionRuntimeState(): State {
  ensureHydrated();
  return { active: runtime };
}

/* ----------------------------------------
   COMMANDS (single source of truth)
---------------------------------------- */

export function startMission(input: { lessonId: string; division: Division }) {
  ensureHydrated();
  runtime = {
    lessonId: input.lessonId,
    division: input.division,
    stepIndex: 0,
    completedSteps: {},
    lastTouched: Date.now(),
  };
  writeStorage(runtime);
  notify();
}

export function abortMission() {
  ensureHydrated();
  runtime = null;
  writeStorage(null);
  notify();
}

export function touchMission() {
  ensureHydrated();
  if (!runtime) return;
  runtime = { ...runtime, lastTouched: Date.now() };
  writeStorage(runtime);
  notify();
}

export function setStepIndex(index: number) {
  ensureHydrated();
  if (!runtime) return;
  if (runtime.stepIndex === index) return; // guard
  runtime = { ...runtime, stepIndex: index, lastTouched: Date.now() };
  writeStorage(runtime);
  notify();
}

export function toggleStepComplete(step: number) {
  ensureHydrated();
  if (!runtime) return;

  const prev = !!runtime.completedSteps?.[step];
  const nextCompleted = { ...(runtime.completedSteps || {}), [step]: !prev };

  runtime = {
    ...runtime,
    completedSteps: nextCompleted,
    lastTouched: Date.now(),
  };

  writeStorage(runtime);
  notify();
}
TS

# ------------------------------------------------------------
# 2) lib/useMissionRuntime.ts
#    (NO useSyncExternalStore, NO getServerSnapshot issues)
# ------------------------------------------------------------
cat > lib/useMissionRuntime.ts <<'TS'
"use client";

import { useEffect, useMemo, useState } from "react";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";
import {
  abortMission,
  getMissionRuntimeState,
  setStepIndex,
  startMission,
  subscribeMissionRuntime,
  toggleStepComplete,
  touchMission,
  type MissionRuntime,
} from "@/lib/missionRuntimeStore";

export type API = {
  runtime: MissionRuntime | null;

  // aliases the UI expects
  activeMission: MissionRuntime | null;
  clearMission: () => void;

  // commands
  startMission: (input: { lessonId: string; division: Division }) => void;
  abortMission: () => void;
  touchMission: () => void;
  setStepIndex: (index: number) => void;
  toggleStepComplete: (step: number) => void;
};

export function useMissionRuntime(): API {
  const [active, setActive] = useState<MissionRuntime | null>(null);

  useEffect(() => {
    // initial read
    setActive(getMissionRuntimeState().active);

    // subscribe to store updates
    const unsub = subscribeMissionRuntime(() => {
      setActive(getMissionRuntimeState().active);
    });

    return () => unsub();
  }, []);

  return useMemo(
    () => ({
      runtime: active,
      activeMission: active,
      clearMission: () => abortMission(),
      startMission,
      abortMission,
      touchMission,
      setStepIndex,
      toggleStepComplete,
    }),
    [active]
  );
}
TS

# ------------------------------------------------------------
# 3) components/hq/MissionLauncher.tsx
#    (adds a real launch button, safe routing)
# ------------------------------------------------------------
cat > components/hq/MissionLauncher.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export default function MissionLauncher() {
  const router = useRouter();
  const { activeMission, startMission, clearMission } = useMissionRuntime();

  const defaultLessonId = "intro-001";
  const defaultDivision: Division = "PHOENIX";

  function launch() {
    startMission({ lessonId: defaultLessonId, division: defaultDivision });
    // If your lesson route differs, change THIS ONE LINE only:
    router.push(`/academy/lesson/${defaultLessonId}`);
  }

  function resume() {
    if (!activeMission) return;
    router.push(`/academy/lesson/${activeMission.lessonId}`);
  }

  if (activeMission) {
    return (
      <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl p-5 shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]">
        <div className="text-xs tracking-[0.28em] text-white/50">MISSION CONTROL</div>
        <div className="mt-2 text-white/85">
          Active mission: <span className="text-white">{activeMission.lessonId}</span>{" "}
          <span className="text-white/50">({activeMission.division})</span>
        </div>

        <div className="mt-4 flex items-center gap-2">
          <button
            onClick={resume}
            className="px-4 py-2 rounded-xl border border-white/10 bg-white/10 hover:bg-white/15 text-white/90"
          >
            Resume Mission
          </button>
          <button
            onClick={clearMission}
            className="px-4 py-2 rounded-xl border border-red-500/30 bg-red-500/10 hover:bg-red-500/15 text-red-200"
          >
            Abort
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl p-5 shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]">
      <div className="text-xs tracking-[0.28em] text-white/50">LAUNCH MISSION</div>
      <div className="mt-2 text-white/70">
        Default launch target: <span className="text-white">{defaultLessonId}</span>{" "}
        <span className="text-white/50">({defaultDivision})</span>
      </div>

      <div className="mt-4">
        <button
          onClick={launch}
          className="px-4 py-2 rounded-xl border border-emerald-500/30 bg-emerald-500/10 hover:bg-emerald-500/15 text-emerald-200"
        >
          Launch Mission
        </button>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) components/hq/ActiveMissionCard.tsx
# ------------------------------------------------------------
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { activeMission, clearMission } = useMissionRuntime();

  if (!activeMission) return null;

  function resume() {
    router.push(`/academy/lesson/${activeMission.lessonId}`);
  }

  return (
    <div className="rounded-2xl border border-emerald-500/20 bg-black/40 backdrop-blur-xl p-5 shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]">
      <div className="text-xs tracking-[0.28em] text-emerald-200/70">ACTIVE MISSION</div>

      <div className="mt-2 text-white/85">
        Lesson: <span className="text-white">{activeMission.lessonId}</span>
      </div>
      <div className="text-white/60 text-sm mt-1">Division: {activeMission.division}</div>

      <div className="mt-4 flex items-center gap-2">
        <button
          onClick={resume}
          className="px-4 py-2 rounded-xl border border-white/10 bg-white/10 hover:bg-white/15 text-white/90"
        >
          Resume Mission
        </button>
        <button
          onClick={clearMission}
          className="px-4 py-2 rounded-xl border border-red-500/30 bg-red-500/10 hover:bg-red-500/15 text-red-200"
        >
          Abort
        </button>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 5) components/command/LessonShell.tsx
#    (prevents loops; creates mission once; keeps it fresh)
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
"use client";

import { useEffect, useRef } from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function LessonShell({ lesson }: { lesson: CanonLesson }) {
  const { activeMission, startMission, touchMission } = useMissionRuntime();
  const didInit = useRef(false);

  useEffect(() => {
    // Init mission once (no loops)
    if (didInit.current) return;

    const needsMission =
      !activeMission || activeMission.lessonId !== lesson.id;

    if (needsMission) {
      // Default division for now; your AccessGate can override later.
      startMission({ lessonId: lesson.id, division: "PHOENIX" });
    }

    didInit.current = true;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lesson.id]);

  useEffect(() => {
    // Keep mission "alive" while lesson open (low frequency)
    const t = setInterval(() => touchMission(), 10_000);
    return () => clearInterval(t);
  }, [touchMission]);

  return (
    <div className="rounded-2xl border border-white/10 bg-black/30 backdrop-blur-xl p-6">
      <div className="text-xs tracking-[0.28em] text-white/50">LESSON SHELL</div>
      <div className="mt-2 text-white text-xl font-semibold">{lesson.title}</div>
      {lesson.description ? (
        <div className="mt-2 text-white/70">{lesson.description}</div>
      ) : null}
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 6) BUILD CHECK
# ------------------------------------------------------------
echo "🧱 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ MISSION RUNTIME IS STABLE"
echo "🚀 Run: npm run dev"
