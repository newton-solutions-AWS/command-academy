#!/usr/bin/env bash
set -euo pipefail

echo "💀 KILLSHOT :: UNIFY MISSION RUNTIME (ONE API, ONE STORE)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p lib components/hq components/command components/guardian commanders

# ------------------------------------------------------------
# 1) SINGLE SOURCE OF TRUTH STORE
# ------------------------------------------------------------
cat > lib/missionRuntimeStore.ts <<'TS'
"use client";

import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type ActiveMission = {
  lessonId: string;
  division: Division;
  startedAt: number;
  lastSeenAt: number;
  stepIndex: number;
  completedSteps: Record<number, boolean>;
  notes?: string;
};

export type MissionRuntimeState = {
  active: ActiveMission | null;
};

type Listener = () => void;

const STORAGE_KEY = "nca:missionRuntime:v1";

let state: MissionRuntimeState = { active: null };
const listeners = new Set<Listener>();
let hydrated = false;

function emit() {
  for (const l of listeners) l();
}

function safeParse(raw: string | null): any {
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function persist() {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // ignore
  }
}

function hydrateOnce() {
  if (typeof window === "undefined") return;
  const raw = safeParse(window.localStorage.getItem(STORAGE_KEY));
  if (raw && typeof raw === "object") {
    state = { active: raw.active ?? null };
  }
}

function ensureHydrated() {
  if (hydrated) return;
  hydrated = true;
  hydrateOnce();
}

export function getMissionRuntimeState(): MissionRuntimeState {
  ensureHydrated();
  return state;
}

export function subscribeMissionRuntime(listener: Listener) {
  ensureHydrated();
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

/* ----------------------------------------
   COMMANDS (THE ONLY COMMAND SET)
---------------------------------------- */
export function startMission(input: { lessonId: string; division: Division }) {
  ensureHydrated();
  const now = Date.now();

  state = {
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
  ensureHydrated();
  if (!state.active) return;

  state = {
    active: {
      ...state.active,
      lastSeenAt: Date.now(),
    },
  };

  persist();
  emit();
}

export function setStepIndex(stepIndex: number) {
  ensureHydrated();
  if (!state.active) return;

  state = {
    active: {
      ...state.active,
      stepIndex: Math.max(0, stepIndex),
      lastSeenAt: Date.now(),
    },
  };

  persist();
  emit();
}

export function toggleStepComplete(step: number) {
  ensureHydrated();
  if (!state.active) return;

  const completedSteps = { ...(state.active.completedSteps ?? {}) };
  completedSteps[step] = !completedSteps[step];

  state = {
    active: {
      ...state.active,
      completedSteps,
      lastSeenAt: Date.now(),
    },
  };

  persist();
  emit();
}

export function addMissionNote(notes: string) {
  ensureHydrated();
  if (!state.active) return;

  state = {
    active: {
      ...state.active,
      notes,
      lastSeenAt: Date.now(),
    },
  };

  persist();
  emit();
}

export function clearMission() {
  ensureHydrated();
  state = { active: null };
  persist();
  emit();
}
TS

# ------------------------------------------------------------
# 2) THE ONLY HOOK (exports useMissionRuntime)
# ------------------------------------------------------------
cat > lib/useMissionRuntime.ts <<'TS'
"use client";

import { useSyncExternalStore } from "react";
import type { MissionRuntimeState } from "@/lib/missionRuntimeStore";
import {
  getMissionRuntimeState,
  subscribeMissionRuntime,
  startMission,
  touchMission,
  setStepIndex,
  toggleStepComplete,
  addMissionNote,
  clearMission,
} from "@/lib/missionRuntimeStore";

function snapshot(): MissionRuntimeState {
  return getMissionRuntimeState();
}

function serverSnapshot(): MissionRuntimeState {
  return { active: null };
}

export function useMissionRuntime() {
  const state = useSyncExternalStore(subscribeMissionRuntime, snapshot, serverSnapshot);

  return {
    runtime: state.active,
    startMission,
    touchMission,
    setStepIndex,
    toggleStepComplete,
    addMissionNote,
    clearMission,
  };
}
TS

# ------------------------------------------------------------
# 3) FIX MISSION HANDSHAKE (NO activeMission)
# ------------------------------------------------------------
cat > components/command/MissionHandshake.tsx <<'TSX'
"use client";

import { useEffect } from "react";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

type Props = { lessonId: string; division: Division };

export default function MissionHandshake({ lessonId, division }: Props) {
  const { runtime, startMission, touchMission } = useMissionRuntime();

  useEffect(() => {
    // Ensure mission exists + matches this lesson
    if (!runtime || runtime.lessonId !== lessonId || runtime.division !== division) {
      startMission({ lessonId, division });
      return;
    }

    // Keep it fresh
    touchMission();
  }, [lessonId, division, runtime, startMission, touchMission]);

  return null;
}
TSX

# ------------------------------------------------------------
# 4) FIX GUARDIAN ANGEL (binds to runtime store)
# ------------------------------------------------------------
cat > components/guardian/GuardianAngelPanel.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import { getMissionRuntimeState, toggleStepComplete, setStepIndex } from "@/lib/missionRuntimeStore";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lessonId: string;
  division: Division;
  steps: string[];
};

export default function GuardianAngelPanel({ lessonId, division, steps }: Props) {
  const storageKey = useMemo(() => `${division}:${lessonId}`, [division, lessonId]);

  const [mounted, setMounted] = useState(false);
  const [completed, setCompleted] = useState<Record<number, boolean>>({});
  const [open, setOpen] = useState(true);

  useEffect(() => {
    setMounted(true);
    const st = getMissionRuntimeState();
    const active = st.active;
    if (active && `${active.division}:${active.lessonId}` === storageKey) {
      setCompleted(active.completedSteps ?? {});
    } else {
      setCompleted({});
    }
  }, [storageKey]);

  if (!mounted) return null;

  const doneCount = Object.values(completed).filter(Boolean).length;
  const total = steps.length || 1;
  const pct = Math.round((doneCount / total) * 100);

  function onToggleStep(i: number) {
    toggleStepComplete(i);
    const st = getMissionRuntimeState();
    setCompleted(st.active?.completedSteps ?? {});
    setStepIndex(i);
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]">
      <div className="flex items-center justify-between gap-3 px-5 py-4 border-b border-white/10">
        <div>
          <div className="text-xs tracking-[0.28em] text-white/50">GUARDIAN ANGEL</div>
          <div className="text-sm text-white/80 mt-1">Step-by-step mission support</div>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-xs text-white/60 tabular-nums">
            {doneCount}/{steps.length} • {pct}%
          </div>
          <button
            onClick={() => setOpen(!open)}
            className="px-3 py-1.5 text-xs rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/80"
          >
            {open ? "Collapse" : "Expand"}
          </button>
        </div>
      </div>

      {open && (
        <div className="p-5">
          <ol className="space-y-2">
            {steps.map((s, i) => {
              const isDone = !!completed[i];
              return (
                <li key={i} className="flex items-start gap-3 rounded-xl border border-white/10 bg-white/5 px-4 py-3">
                  <button
                    onClick={() => onToggleStep(i)}
                    className={[
                      "mt-0.5 h-5 w-5 rounded-md border flex items-center justify-center",
                      isDone ? "border-emerald-400/40 bg-emerald-500/10" : "border-white/20 bg-black/30",
                    ].join(" ")}
                    aria-label={isDone ? "Mark incomplete" : "Mark complete"}
                  >
                    {isDone ? (
                      <span className="text-emerald-300 text-xs">✓</span>
                    ) : (
                      <span className="text-white/30 text-xs">•</span>
                    )}
                  </button>

                  <div className="flex-1">
                    <div className="text-xs tracking-[0.22em] text-white/40">
                      STEP {String(i + 1).padStart(2, "0")}
                    </div>
                    <div className={["text-sm mt-1", isDone ? "text-white/85" : "text-white/70"].join(" ")}>
                      {s}
                    </div>
                  </div>
                </li>
              );
            })}
          </ol>
        </div>
      )}
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 5) FIX HQ COMPONENTS (NO activeMission)
# ------------------------------------------------------------
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { runtime, clearMission } = useMissionRuntime();

  if (!runtime) return null;

  const href = `/academy/${runtime.division}/${runtime.lessonId}`;

  return (
    <div className="rounded-2xl border border-white/10 bg-black/35 backdrop-blur-xl p-5">
      <div className="text-xs tracking-[0.28em] text-white/50">ACTIVE MISSION</div>

      <div className="mt-3 text-white/80">
        Lesson: <span className="text-white">{runtime.lessonId}</span>
      </div>
      <div className="text-white/60 text-sm mt-1">Division: {runtime.division}</div>

      <div className="mt-4 flex gap-2">
        <button
          onClick={() => router.push(href)}
          className="px-4 py-2 text-sm rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white"
        >
          Resume
        </button>
        <button
          onClick={() => clearMission()}
          className="px-4 py-2 text-sm rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white/80"
        >
          Abort
        </button>
      </div>
    </div>
  );
}
TSX

cat > components/hq/MissionLauncher.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function MissionLauncher() {
  const router = useRouter();
  const { runtime, startMission, clearMission } = useMissionRuntime();

  const defaultLessonId = "intro-001";
  const defaultDivision: Division = "phoenix";

  function launch() {
    startMission({ lessonId: defaultLessonId, division: defaultDivision });
    router.push(`/academy/${defaultDivision}/${defaultLessonId}`);
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/35 backdrop-blur-xl p-5">
      <div className="text-xs tracking-[0.28em] text-white/50">MISSION LAUNCHER</div>

      {runtime ? (
        <div className="mt-3 text-white/70">
          Mission already active:{" "}
          <span className="text-white">{runtime.division}/{runtime.lessonId}</span>
          <div className="mt-3 flex gap-2">
            <button
              onClick={() => router.push(`/academy/${runtime.division}/${runtime.lessonId}`)}
              className="px-4 py-2 text-sm rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white"
            >
              Resume
            </button>
            <button
              onClick={() => clearMission()}
              className="px-4 py-2 text-sm rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white/80"
            >
              Abort
            </button>
          </div>
        </div>
      ) : (
        <div className="mt-4">
          <button
            onClick={launch}
            className="px-4 py-2 text-sm rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 text-white"
          >
            Start Phoenix Golden Path
          </button>
        </div>
      )}
    </div>
  );
}
TSX

cat > components/hq/StatusStrip.tsx <<'TSX'
"use client";

import { useMemo } from "react";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

function Pill({ label }: { label: string }) {
  return (
    <div className="px-3 py-1.5 rounded-full border border-white/10 bg-white/5 text-xs text-white/75">
      {label}
    </div>
  );
}

export default function StatusStrip() {
  const { runtime } = useMissionRuntime();

  const label = useMemo(() => {
    if (!runtime) return "MISSION: IDLE";
    return `MISSION: ACTIVE • ${runtime.division.toUpperCase()} • ${runtime.lessonId}`;
  }, [runtime]);

  return (
    <div className="flex flex-wrap gap-2 items-center">
      <Pill label={label} />
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 6) FIX LESSON SHELL (NO description, no activeMission)
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
"use client";

import { useEffect, useRef } from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import MissionHandshake from "@/components/command/MissionHandshake";
import GuardianAngelPanel from "@/components/guardian/GuardianAngelPanel";

export default function LessonShell({ lesson }: { lesson: CanonLesson }) {
  const { runtime, startMission, touchMission } = useMissionRuntime();
  const didInit = useRef(false);

  useEffect(() => {
    if (!didInit.current) {
      if (!runtime || runtime.lessonId !== lesson.id || runtime.division !== lesson.division) {
        startMission({ lessonId: lesson.id, division: lesson.division });
      }
      didInit.current = true;
    }
    touchMission();
  }, [lesson.id, lesson.division, runtime, startMission, touchMission]);

  return (
    <main className="mx-auto max-w-6xl px-6 pb-16">
      <MissionHandshake lessonId={lesson.id} division={lesson.division} />

      <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
        <div className="px-8 py-7 border-b border-white/10">
          <div className="text-xs tracking-[0.28em] text-white/50">NEWTON COMMAND ACADEMY</div>
          <h1 className="text-3xl font-semibold text-white mt-3">{lesson.title}</h1>

          <div className="mt-3 flex flex-wrap gap-2 items-center text-sm text-white/60">
            <span>Lesson ID: {lesson.id}</span>
            <span className="text-white/20">•</span>
            <span>{lesson.duration_minutes} mins</span>
            <span className="text-white/20">•</span>
            <span>{lesson.division.toUpperCase()}</span>
            <span className="text-white/20">•</span>
            <span>{lesson.difficulty.toUpperCase()}</span>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-8">
          <div className="lg:col-span-2 space-y-6">
            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                CONCEPT
              </div>
              <div className="px-6 py-5 text-white/80 leading-relaxed">{lesson.concept}</div>
            </section>

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                WALKTHROUGH
              </div>
              <div className="px-6 py-5 text-white/80 leading-relaxed whitespace-pre-line">{lesson.walkthrough}</div>
            </section>

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                OBJECTIVES
              </div>
              <div className="px-6 py-5">
                <ul className="list-disc pl-5 space-y-2 text-white/75">
                  {lesson.objectives.map((o, i) => (
                    <li key={i}>{o}</li>
                  ))}
                </ul>
              </div>
            </section>
          </div>

          <div className="lg:col-span-1">
            <GuardianAngelPanel lessonId={lesson.id} division={lesson.division} steps={lesson.steps ?? []} />
          </div>
        </div>
      </div>
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 7) DELETE DUPLICATE RUNTIME FILES THAT KEEP RESURRECTING activeMission
# ------------------------------------------------------------
echo "🧹 Removing duplicate runtime modules (if present)..."
rm -f lib/missionRuntime.ts || true
rm -f cert_intel/intake/lib/missionRuntime.ts || true
rm -f cert_intel/intake/lib/useMissionRuntime.ts || true

# ------------------------------------------------------------
# 8) QUICK IMPORT SANITY: if anything still imports missionRuntime, fail loudly
# ------------------------------------------------------------
echo "🔎 Import sanity scan..."
if rg -n "from \"@/lib/missionRuntime\"|from \"./missionRuntime\"|from \"@/cert_intel/intake/lib/missionRuntime\"" . >/dev/null; then
  echo "❌ Found imports still pointing at old missionRuntime modules."
  rg -n "from \"@/lib/missionRuntime\"|from \"./missionRuntime\"|from \"@/cert_intel/intake/lib/missionRuntime\"" .
  echo "🛑 Fix those imports to use:"
  echo "   - '@/lib/useMissionRuntime' (hook)"
  echo "   - '@/lib/missionRuntimeStore' (commands/state only)"
  exit 1
else
  echo "✅ No old missionRuntime imports detected."
fi

# ------------------------------------------------------------
# 9) BUILD CHECK
# ------------------------------------------------------------
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ KILLSHOT COMPLETE — RUNTIME API UNIFIED"
echo "🚀 Run: npm run dev"
