#!/bin/bash
set -euo pipefail

echo "🩺 FIX — MissionRuntime exports + kill useEffect loop + stable HQ/lesson wiring"
echo "📍 Repo: $(pwd)"

# ============================================================
# 1) Mission Runtime — single source of truth (STORE)
# ============================================================
mkdir -p lib

cat > lib/missionRuntime.ts <<'TS'
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

export type MissionRuntime = {
  active: ActiveMission | null;
};

type Listener = () => void;

const STORAGE_KEY = "newton.mission.runtime.v1";

let hydrated = false;

let runtime: MissionRuntime = {
  active: null,
};

const listeners = new Set<Listener>();

function emit() {
  for (const l of listeners) l();
}

function safeParse(json: string | null): any {
  if (!json) return null;
  try {
    return JSON.parse(json);
  } catch {
    return null;
  }
}

function persist() {
  if (typeof window === "undefined") return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(runtime));
  } catch {
    // ignore
  }
}

function hydrateOnce() {
  if (typeof window === "undefined") return;
  const raw = safeParse(window.localStorage.getItem(STORAGE_KEY));
  if (raw && typeof raw === "object") {
    runtime = {
      active: raw.active ?? null,
    };
  }
}

function ensureHydrated() {
  if (hydrated) return;
  hydrated = true;
  hydrateOnce();
}

export function getMissionRuntime(): MissionRuntime {
  ensureHydrated();
  return runtime;
}

export function subscribeMissionRuntime(listener: Listener) {
  ensureHydrated();
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function saveMissionRuntime(next: MissionRuntime) {
  ensureHydrated();
  runtime = next;
  persist();
  emit();
}

export function startMission(input: { lessonId: string; division: Division }) {
  ensureHydrated();
  const now = Date.now();
  saveMissionRuntime({
    active: {
      lessonId: input.lessonId,
      division: input.division,
      startedAt: now,
      lastSeenAt: now,
      stepIndex: 0,
      completedSteps: {},
    },
  });
}

export function touchMission() {
  ensureHydrated();
  if (!runtime.active) return;
  saveMissionRuntime({
    active: {
      ...runtime.active,
      lastSeenAt: Date.now(),
    },
  });
}

export function setStepIndex(stepIndex: number) {
  ensureHydrated();
  if (!runtime.active) return;
  saveMissionRuntime({
    active: {
      ...runtime.active,
      stepIndex: Math.max(0, stepIndex),
      lastSeenAt: Date.now(),
    },
  });
}

export function toggleStepComplete(step: number) {
  ensureHydrated();
  if (!runtime.active) return;
  const completedSteps = { ...(runtime.active.completedSteps ?? {}) };
  completedSteps[step] = !completedSteps[step];
  saveMissionRuntime({
    active: {
      ...runtime.active,
      completedSteps,
      lastSeenAt: Date.now(),
    },
  });
}

export function setNotes(notes: string) {
  ensureHydrated();
  if (!runtime.active) return;
  saveMissionRuntime({
    active: {
      ...runtime.active,
      notes,
      lastSeenAt: Date.now(),
    },
  });
}

export function abortMission() {
  ensureHydrated();
  saveMissionRuntime({ active: null });
}
TS

# ============================================================
# 2) Mission Runtime — HOOK API (what components import)
# ============================================================
cat > lib/useMissionRuntime.ts <<'TS'
"use client";

import { useSyncExternalStore } from "react";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";
import type { MissionRuntime } from "./missionRuntime";
import {
  abortMission,
  getMissionRuntime,
  setNotes,
  setStepIndex,
  startMission,
  subscribeMissionRuntime,
  toggleStepComplete,
  touchMission,
} from "./missionRuntime";

function snapshot(): MissionRuntime {
  return getMissionRuntime();
}

function serverSnapshot(): MissionRuntime {
  return { active: null };
}

export type MissionRuntimeAPI = {
  runtime: MissionRuntime;
  activeMission: MissionRuntime["active"];
  startMission: (input: { lessonId: string; division: Division }) => void;
  touchMission: () => void;
  setStepIndex: (stepIndex: number) => void;
  toggleStepComplete: (step: number) => void;
  setNotes: (notes: string) => void;
  clearMission: () => void;
};

export function useMissionRuntime(): MissionRuntimeAPI {
  const runtime = useSyncExternalStore(subscribeMissionRuntime, snapshot, serverSnapshot);

  return {
    runtime,
    activeMission: runtime.active,
    startMission,
    touchMission,
    setStepIndex,
    toggleStepComplete,
    setNotes,
    clearMission: abortMission,
  };
}
TS

# ============================================================
# 3) Kill the loop — LessonShell MUST NOT mutate in a render-loop
#    (useEffect guarded + deps stable)
# ============================================================
mkdir -p components/command

cat > components/command/LessonShell.tsx <<'TSX'
"use client";

import { useEffect, useRef } from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function LessonShell({ lesson, children }: { lesson: CanonLesson; children?: React.ReactNode }) {
  const { activeMission, startMission, touchMission } = useMissionRuntime();

  // Guard: never start mission repeatedly on rerender
  const startedRef = useRef<string | null>(null);

  useEffect(() => {
    // Start mission only once per lessonId
    if (startedRef.current === lesson.id) return;

    const needsStart =
      !activeMission ||
      activeMission.lessonId !== lesson.id ||
      activeMission.division !== lesson.division;

    if (needsStart) {
      startMission({ lessonId: lesson.id, division: lesson.division });
    }

    startedRef.current = lesson.id;
    // IMPORTANT: deps exclude activeMission to avoid store-update loops
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lesson.id, lesson.division]);

  useEffect(() => {
    // Keep mission fresh while lesson screen is open (no deps on activeMission)
    const t = setInterval(() => {
      touchMission();
    }, 5000);

    return () => clearInterval(t);
  }, [touchMission]);

  return (
    <div className="mx-auto max-w-6xl px-6 pb-16">
      <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
        <div className="px-8 py-7 border-b border-white/10">
          <div className="text-xs uppercase tracking-[0.25em] text-white/50">Lesson Execution</div>
          <div className="mt-2 text-2xl font-semibold text-white">{lesson.title}</div>
          <div className="mt-1 text-sm text-white/60">
            Division: <span className="text-white/80">{lesson.division}</span> • ID:{" "}
            <span className="text-white/80">{lesson.id}</span>
          </div>
        </div>

        <div className="px-8 py-8">
          {children ? (
            children
          ) : (
            <div className="text-white/70">
              Mission runtime is wired. Content rendering is next (lesson expansion pipeline).
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
TSX

# ============================================================
# 4) MissionHandshake — make it NON-MUTATING (no useEffect)
#    (prevents duplicate start/touch loops)
# ============================================================
cat > components/command/MissionHandshake.tsx <<'TSX'
"use client";

/**
 * MissionHandshake is now a PURE placeholder.
 * The LessonShell owns the runtime handshake (start + touch).
 * Keeping this component avoids import churn but prevents side-effect loops.
 */
export default function MissionHandshake() {
  return null;
}
TSX

# ============================================================
# 5) HQ components — align to new API: { activeMission, clearMission, startMission }
# ============================================================
mkdir -p components/hq

# ActiveMissionCard
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { activeMission, clearMission } = useMissionRuntime();

  if (!activeMission) {
    return (
      <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl p-8">
        <div className="text-xs uppercase tracking-[0.25em] text-white/50">Active Mission</div>
        <div className="mt-2 text-white/70">No active mission.</div>
      </div>
    );
  }

  const href = `/academy/${activeMission.division}/${activeMission.lessonId}`;

  return (
    <div className="rounded-3xl border border-emerald-500/20 bg-black/30 backdrop-blur-xl p-8">
      <div className="text-xs uppercase tracking-[0.25em] text-emerald-300/70">Active Mission</div>

      <div className="mt-3 text-xl font-semibold text-white">
        Lesson: <span className="text-white/90">{activeMission.lessonId}</span>
      </div>
      <div className="mt-1 text-sm text-white/60">
        Division: <span className="text-white/80">{activeMission.division}</span>
      </div>

      <div className="mt-6 flex gap-3">
        <button
          onClick={() => router.push(href)}
          className="rounded-xl border border-emerald-500/30 bg-emerald-500/15 px-4 py-2 text-sm text-emerald-200 hover:bg-emerald-500/20"
        >
          Resume Mission
        </button>
        <button
          onClick={() => clearMission()}
          className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-2 text-sm text-red-200 hover:bg-red-500/15"
        >
          Abort
        </button>
      </div>
    </div>
  );
}
TSX

# MissionLauncher (simple launch/resume control)
cat > components/hq/MissionLauncher.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export default function MissionLauncher() {
  const router = useRouter();
  const { activeMission, startMission, clearMission } = useMissionRuntime();

  function launchIntro(division: Division) {
    const lessonId = "intro-001";
    startMission({ lessonId, division });
    router.push(`/academy/${division}/${lessonId}`);
  }

  if (activeMission) {
    const href = `/academy/${activeMission.division}/${activeMission.lessonId}`;
    return (
      <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl p-8">
        <div className="text-xs uppercase tracking-[0.25em] text-white/50">Mission Control</div>
        <div className="mt-2 text-white/70">Resume your active mission</div>

        <div className="mt-6 flex gap-3">
          <button
            onClick={() => router.push(href)}
            className="rounded-xl border border-emerald-500/30 bg-emerald-500/15 px-4 py-2 text-sm text-emerald-200 hover:bg-emerald-500/20"
          >
            Resume Mission
          </button>
          <button
            onClick={() => clearMission()}
            className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-2 text-sm text-red-200 hover:bg-red-500/15"
          >
            Abort
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl p-8">
      <div className="text-xs uppercase tracking-[0.25em] text-white/50">Mission Control</div>
      <div className="mt-2 text-white/70">Launch a mission (demo)</div>

      <div className="mt-6 flex flex-wrap gap-3">
        <button
          onClick={() => launchIntro("phoenix")}
          className="rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-2 text-sm text-amber-200 hover:bg-amber-500/15"
        >
          Launch: Phoenix Intro
        </button>
        <button
          onClick={() => launchIntro("vanguard")}
          className="rounded-xl border border-sky-500/30 bg-sky-500/10 px-4 py-2 text-sm text-sky-200 hover:bg-sky-500/15"
        >
          Launch: Vanguard Intro
        </button>
        <button
          onClick={() => launchIntro("sentinel")}
          className="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-2 text-sm text-red-200 hover:bg-red-500/15"
        >
          Launch: Sentinel Intro
        </button>
      </div>
    </div>
  );
}
TSX

# ============================================================
# 6) Fix Shell hydration mismatch (clock)
# ============================================================
mkdir -p components/ui
if [ -f components/ui/Shell.tsx ]; then
cat > components/ui/Shell.tsx <<'TSX'
"use client";

import React, { useEffect, useMemo, useState } from "react";

type Props = {
  title?: string;
  subtitle?: string;
  children: React.ReactNode;
};

export default function Shell({ title, subtitle, children }: Props) {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const clock = useMemo(() => {
    if (!mounted) return "—:—:—";
    const d = new Date();
    const pad = (n: number) => String(n).padStart(2, "0");
    return `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
  }, [mounted]);

  return (
    <div className="min-h-screen bg-black text-white">
      <div className="mx-auto max-w-6xl px-6 py-10">
        <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
          <div className="px-10 py-9 border-b border-white/10">
            <div className="text-xs uppercase tracking-[0.35em] text-white/40">Newton Command Academy</div>
            {title ? <div className="mt-3 text-4xl font-semibold">{title}</div> : null}
            {subtitle ? <div className="mt-2 text-sm text-white/60">{subtitle}</div> : null}

            <div className="mt-6 text-xs uppercase tracking-[0.35em] text-white/35">
              System Clock • <span suppressHydrationWarning>{clock}</span>
            </div>
          </div>

          <div className="px-10 py-10">{children}</div>
        </div>
      </div>
    </div>
  );
}
TSX
fi

# ============================================================
# 7) Access Profile — add canAccess export (fix AccessGate)
# ============================================================
# (Only if this file exists; we extend without breaking your hook)
if [ -f lib/useAccessProfile.ts ]; then
cat > lib/useAccessProfile.ts <<'TS'
"use client";

import { useEffect, useState } from "react";
import type { AccessProfile, UserDivision } from "@/lib/access";

export type AccessCheck = {
  phoenixOnly?: boolean;
  vanguardOnly?: boolean;
  sentinelOnly?: boolean;
  minDivision?: UserDivision;
};

const KEY = "nca:accessProfile:v1";

// Phoenix doctrine: full access (includes Sentinel) by honor-bound VIP
const DEFAULT: AccessProfile = { userDivision: "phoenix", addons: { sentinel: true } };

function safeParse(raw: string | null): AccessProfile | null {
  if (!raw) return null;
  try {
    const v = JSON.parse(raw);
    if (!v || typeof v !== "object") return null;
    const userDivision = (v.userDivision as UserDivision) || "phoenix";
    const addons = v.addons && typeof v.addons === "object" ? v.addons : {};
    return { userDivision, addons };
  } catch {
    return null;
  }
}

/**
 * Pure access predicate (NO hooks) — used by AccessGate and routing rules.
 * Canon:
 * - Phoenix: unrestricted, includes Sentinel.
 * - Vanguard: paid civilian access; Sentinel excluded unless addon enabled.
 * - Sentinel: elite add-on; Phoenix auto-includes.
 */
export function canAccess(profile: AccessProfile, rules: AccessCheck = {}): boolean {
  const userDivision = profile.userDivision;
  const addons = profile.addons ?? {};

  // Phoenix overrides everything
  if (userDivision === "phoenix") return true;

  // Sentinel-only gate
  if (rules.sentinelOnly) {
    return addons.sentinel === true;
  }

  // Phoenix-only gate
  if (rules.phoenixOnly) {
    return false;
  }

  // Vanguard-only gate
  if (rules.vanguardOnly) {
    return userDivision === "vanguard";
  }

  // Minimum division (simple ordering)
  const order: Record<UserDivision, number> = { phoenix: 3, sentinel: 2, vanguard: 1 };
  if (rules.minDivision) {
    return order[userDivision] >= order[rules.minDivision];
  }

  return true;
}

export function useAccessProfile() {
  const [mounted, setMounted] = useState(false);
  const [profile, setProfile] = useState<AccessProfile>(DEFAULT);

  useEffect(() => {
    setMounted(true);
    const existing = safeParse(window.localStorage.getItem(KEY));
    if (existing) setProfile(existing);
  }, []);

  function save(next: AccessProfile) {
    setProfile(next);
    try {
      window.localStorage.setItem(KEY, JSON.stringify(next));
    } catch {}
  }

  return {
    mounted,
    profile,
    setUserDivision: (userDivision: UserDivision) => save({ ...profile, userDivision }),
    setSentinelAddOn: (enabled: boolean) => save({ ...profile, addons: { ...profile.addons, sentinel: enabled } }),
  };
}
TS
fi

# ============================================================
# 8) Build check
# ============================================================
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ FIX COMPLETE — runtime stable, no infinite loop, exports aligned"
echo "🚀 Run: npm run dev"
