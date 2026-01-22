#!/usr/bin/env bash
set -euo pipefail

echo "💀 KILLSHOT — FULL ACADEMY RUNTIME (MINUS LESSON EXPANSION)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

# ------------------------------------------------------------
# 0) Folders
# ------------------------------------------------------------
mkdir -p commanders
mkdir -p app/hq
mkdir -p app/academy
mkdir -p app/academy/[division]
mkdir -p app/academy/[division]/[lessonId]
mkdir -p app/academy/phoenix
mkdir -p app/academy/vanguard
mkdir -p app/academy/sentinel
mkdir -p app/academy/phoenix/[lessonId]
mkdir -p app/academy/vanguard/[lessonId]
mkdir -p app/academy/sentinel/[lessonId]
mkdir -p components/ui
mkdir -p components/hq
mkdir -p components/command
mkdir -p components/guardian
mkdir -p lib
mkdir -p cert_intel/intake/lib

# ------------------------------------------------------------
# 1) CANON TYPES (single source of truth)
# ------------------------------------------------------------
cat > cert_intel/intake/lib/canonTypes.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";
export type Difficulty = "foundation" | "intermediate" | "advanced" | "elite";

export type CanonLesson = {
  id: string;
  title: string;
  division: Division;
  difficulty: Difficulty;

  concept: string;
  walkthrough: string;
  objectives: string[];

  duration_minutes: number;
  steps?: string[];
};
TS

# Remove known duplicate canon lesson definition files if they exist
rm -f cert_intel/intake/lib/lessonTypes.ts cert_intel/intake/lib/types.ts || true

# ------------------------------------------------------------
# 2) LESSON LOADER (minimal canon lessons; NOT expanding content)
# ------------------------------------------------------------
cat > cert_intel/intake/lib/lessonloader.ts <<'TS'
import type { CanonLesson, Division } from "./canonTypes";

function deriveSteps(lesson: CanonLesson): string[] {
  if (lesson.steps && Array.isArray(lesson.steps) && lesson.steps.length > 0) return lesson.steps;

  const lines = (lesson.walkthrough || "")
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);

  const numbered = lines.filter((l) => /^\d+\)/.test(l) || /^\d+\./.test(l));
  const base = numbered.length ? numbered : lines;

  const trimmed = base.slice(0, 12);
  if (trimmed.length) return trimmed;

  return [
    "Confirm your division and interface posture.",
    "Open HQ and review mission status.",
    "Read the concept block once, slowly.",
    "Execute the walkthrough steps in order.",
    "Tick off objectives, then debrief.",
  ];
}

export function loadCanonLessons(division?: Division): CanonLesson[] {
  const allLessons: CanonLesson[] = [
    {
      id: "intro-001",
      title: "Welcome to the Newton Command Academy",
      division: "phoenix",
      difficulty: "foundation",
      duration_minutes: 12,
      concept:
        "This is your induction. The Academy runs as missions, not lectures. The Guardian Angel keeps you moving, step-by-step.",
      walkthrough: [
        "1) Confirm your division and layout.",
        "2) Open HQ.",
        "3) Enter the Mission Simulator.",
        "4) Complete the first objective and log your progress.",
        "5) Debrief and unlock the next door.",
      ].join("\n"),
      objectives: [
        "Understand the division model (Phoenix/Vanguard/Sentinel)",
        "Understand HQ ↔ Lesson mission handshake",
        "Complete a clean first mission cycle",
      ],
    },
    {
      id: "linux-001",
      title: "Linux Foundations: Terminal Dominance",
      division: "vanguard",
      difficulty: "foundation",
      duration_minutes: 22,
      concept:
        "The terminal is your weapon system. You will learn navigation, inspection, permissions, and safe execution discipline.",
      walkthrough: [
        "1) Open a terminal and print your working directory.",
        "2) List files with detail.",
        "3) Create a folder structure for ops.",
        "4) Create a file, inspect it, and delete it safely.",
        "5) Debrief: explain what changed and why.",
      ].join("\n"),
      objectives: [
        "Move around the filesystem with intent",
        "Use ls/cat/touch/mkdir/rm safely",
        "Adopt a clean operational workflow",
      ],
    },
    {
      id: "threat-001",
      title: "Sentinel Ops: Threat Modelling 101",
      division: "sentinel",
      difficulty: "intermediate",
      duration_minutes: 28,
      concept:
        "Threat modelling is how professionals stop guessing. You map assets, entry points, controls, and adversary paths.",
      walkthrough: [
        "1) Define the system boundary.",
        "2) List assets.",
        "3) Enumerate threats.",
        "4) Rank by impact/likelihood.",
        "5) Propose mitigations.",
        "6) Debrief.",
      ].join("\n"),
      objectives: [
        "Create a basic threat model",
        "Identify assets and trust boundaries",
        "Propose mitigations aligned to risk",
      ],
    },
  ];

  const normalized = allLessons.map((l) => ({ ...l, steps: deriveSteps(l) }));
  if (!division) return normalized;
  return normalized.filter((l) => l.division === division);
}

export function loadLessonById(lessonId: string): CanonLesson | undefined {
  const all = loadCanonLessons();
  return all.find((l) => l.id === lessonId);
}
TS

# ------------------------------------------------------------
# 3) ACCESS MODEL (canon lock: Phoenix full; Vanguard excludes Sentinel; Sentinel add-on)
# ------------------------------------------------------------
cat > lib/access.ts <<'TS'
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type UserDivision = "phoenix" | "vanguard";
export type AddOns = { sentinel?: boolean };

export type AccessProfile = {
  userDivision: UserDivision;
  addons: AddOns;
};

export function canAccessDivision(profile: AccessProfile, target: Division): boolean {
  if (profile.userDivision === "phoenix") return true; // Phoenix: full unrestricted (includes Vanguard + Sentinel)
  if (target === "phoenix") return false; // Vanguard users cannot access Phoenix
  if (target === "vanguard") return true;
  if (target === "sentinel") return !!profile.addons.sentinel; // Vanguard needs Sentinel add-on
  return false;
}
TS

cat > lib/useAccessProfile.ts <<'TS'
"use client";

import { useEffect, useState } from "react";
import type { AccessProfile, UserDivision } from "@/lib/access";

const KEY = "nca:accessProfile:v1";

const DEFAULT: AccessProfile = { userDivision: "phoenix", addons: { sentinel: true } };

function safeParse(raw: string | null): AccessProfile | null {
  if (!raw) return null;
  try {
    const v = JSON.parse(raw);
    if (!v || typeof v !== "object") return null;
    const userDivision = (v.userDivision as UserDivision) || "phoenix";
    const addons = (v.addons && typeof v.addons === "object") ? v.addons : {};
    return { userDivision, addons };
  } catch {
    return null;
  }
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

# ------------------------------------------------------------
# 4) MISSION RUNTIME STORE (single source of truth)
# ------------------------------------------------------------
cat > lib/missionRuntimeStore.ts <<'TS'
"use client";

import { useSyncExternalStore } from "react";
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

const STORAGE_KEY = "newton.mission.runtime.v1";

let state: MissionRuntimeState = { active: null };
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
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {}
}

function hydrateOnce() {
  if (typeof window === "undefined") return;
  const raw = safeParse(window.localStorage.getItem(STORAGE_KEY));
  if (raw && typeof raw === "object") {
    state = { active: raw.active ?? null };
  }
}

let hydrated = false;
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
  return () => listeners.delete(listener);
}

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
  state = { active: { ...state.active, lastSeenAt: Date.now() } };
  persist();
  emit();
}

export function setStepIndex(stepIndex: number) {
  ensureHydrated();
  if (!state.active) return;
  state = {
    active: { ...state.active, stepIndex: Math.max(0, stepIndex), lastSeenAt: Date.now() },
  };
  persist();
  emit();
}

export function toggleStepComplete(step: number) {
  ensureHydrated();
  if (!state.active) return;
  const completedSteps = { ...(state.active.completedSteps ?? {}) };
  completedSteps[step] = !completedSteps[step];
  state = { active: { ...state.active, completedSteps, lastSeenAt: Date.now() } };
  persist();
  emit();
}

export function addMissionNote(notes: string) {
  ensureHydrated();
  if (!state.active) return;
  state = { active: { ...state.active, notes, lastSeenAt: Date.now() } };
  persist();
  emit();
}

export function clearMission() {
  ensureHydrated();
  state = { active: null };
  persist();
  emit();
}

function snapshot() {
  return getMissionRuntimeState();
}

function serverSnapshot(): MissionRuntimeState {
  return { active: null };
}

export function useMissionRuntime() {
  const s = useSyncExternalStore(subscribeMissionRuntime, snapshot, serverSnapshot);
  return { state: s, startMission, touchMission, setStepIndex, toggleStepComplete, addMissionNote, clearMission };
}
TS

# ------------------------------------------------------------
# 5) UI PRIMITIVES (Panel w/ variant support)
# ------------------------------------------------------------
cat > components/ui/Panel.tsx <<'TSX'
import type { ReactNode } from "react";

type Variant = "default" | "active" | "warn";

type Props = {
  title: string;
  subtitle?: string;
  variant?: Variant;
  children: ReactNode;
};

function variantClass(v: Variant) {
  if (v === "active") return "border-emerald-400/20 shadow-[0_0_0_1px_rgba(16,185,129,0.08),0_20px_60px_rgba(0,0,0,0.55)]";
  if (v === "warn") return "border-amber-400/20 shadow-[0_0_0_1px_rgba(245,158,11,0.08),0_20px_60px_rgba(0,0,0,0.55)]";
  return "border-white/10 shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]";
}

export default function Panel({ title, subtitle, variant = "default", children }: Props) {
  return (
    <section className={["rounded-2xl border bg-black/30 backdrop-blur-xl", variantClass(variant)].join(" ")}>
      <div className="px-5 py-4 border-b border-white/10">
        <div className="text-xs tracking-[0.28em] text-white/50">{title}</div>
        {subtitle ? <div className="text-sm text-white/70 mt-2">{subtitle}</div> : null}
      </div>
      <div className="p-5">{children}</div>
    </section>
  );
}
TSX

# ------------------------------------------------------------
# 6) GUARDIAN ANGEL PANEL (step tracker)
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
          <div className="text-xs text-white/60 tabular-nums">{doneCount}/{steps.length} • {pct}%</div>
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
                    {isDone ? <span className="text-emerald-300 text-xs">✓</span> : <span className="text-white/30 text-xs">•</span>}
                  </button>

                  <div className="flex-1">
                    <div className="text-xs tracking-[0.22em] text-white/40">STEP {String(i + 1).padStart(2, "0")}</div>
                    <div className={["text-sm mt-1", isDone ? "text-white/85" : "text-white/70"].join(" ")}>{s}</div>
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
# 7) LESSON ↔ HQ HANDSHAKE (client-only, no hydration issues)
# ------------------------------------------------------------
cat > components/command/MissionHandshake.tsx <<'TSX'
"use client";

import { useEffect } from "react";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

type Props = { lessonId: string; division: Division };

export default function MissionHandshake({ lessonId, division }: Props) {
  const { state, startMission, touchMission } = useMissionRuntime();

  useEffect(() => {
    const active = state.active;
    if (!active) {
      startMission({ lessonId, division });
      return;
    }
    if (active.lessonId !== lessonId || active.division !== division) {
      startMission({ lessonId, division });
      return;
    }
    touchMission();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lessonId, division]);

  return null;
}
TSX

# ------------------------------------------------------------
# 8) LESSON SHELL (North Star lesson execution screen)
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
import type { ReactNode } from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import GuardianAngelPanel from "@/components/guardian/GuardianAngelPanel";
import MissionHandshake from "@/components/command/MissionHandshake";

type Props = {
  lesson: CanonLesson;
  children?: ReactNode;
};

export default function LessonShell({ lesson, children }: Props) {
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
            {children ? (
              <section className="rounded-2xl border border-white/10 bg-black/20 p-6">{children}</section>
            ) : null}

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">CONCEPT</div>
              <div className="px-6 py-5 text-white/80 leading-relaxed">{lesson.concept}</div>
            </section>

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">WALKTHROUGH</div>
              <div className="px-6 py-5 text-white/80 leading-relaxed whitespace-pre-line">{lesson.walkthrough}</div>
            </section>

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">OBJECTIVES</div>
              <div className="px-6 py-5">
                <ul className="list-disc pl-5 space-y-2 text-white/75">
                  {lesson.objectives.map((o, i) => <li key={i}>{o}</li>)}
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
# 9) HQ COMPONENTS (ActiveMissionCard + StatusStrip + Launcher)
# ------------------------------------------------------------
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import Panel from "@/components/ui/Panel";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { state, clearMission } = useMissionRuntime();

  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  const active = state.active;

  if (!mounted || !active) {
    return (
      <Panel title="ACTIVE MISSION" subtitle="No mission running">
        <div className="text-sm text-white/50">Idle.</div>
      </Panel>
    );
  }

  return (
    <Panel
      title="ACTIVE MISSION"
      subtitle={`${active.lessonId.toUpperCase()} • ${active.division.toUpperCase()}`}
      variant="active"
    >
      <div className="space-y-3">
        <div className="text-sm text-white/70">Step {active.stepIndex + 1}</div>

        <div className="flex gap-2">
          <button
            className="px-3 py-1.5 rounded-md bg-white/10 hover:bg-white/20 text-sm"
            onClick={() => router.push(`/academy/${active.division}/${active.lessonId}`)}
          >
            Resume
          </button>

          <button
            className="px-3 py-1.5 rounded-md border border-red-500/30 text-red-300 hover:bg-red-500/10 text-sm"
            onClick={clearMission}
          >
            Abort
          </button>
        </div>
      </div>
    </Panel>
  );
}
TSX

cat > components/hq/StatusStrip.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

export default function StatusStrip() {
  const { state } = useMissionRuntime();

  const [mounted, setMounted] = useState(false);
  useEffect(() => setMounted(true), []);

  const active = state.active;

  const missionState = useMemo(() => {
    if (!active) return { value: "IDLE", state: "warn" as const };
    return { value: "ACTIVE", state: "ok" as const };
  }, [active]);

  if (!mounted) return null;

  return (
    <div className="flex flex-wrap gap-3 text-xs">
      <span className="px-2 py-1 rounded-full bg-black/40 border border-white/10">
        MISSION:{" "}
        <span className={missionState.state === "ok" ? "text-emerald-400" : "text-amber-400"}>
          {missionState.value}
        </span>
      </span>

      <span className="px-2 py-1 rounded-full bg-black/40 border border-white/10 text-white/60">
        ATILS ENGINE: ONLINE
      </span>

      <span className="px-2 py-1 rounded-full bg-black/40 border border-white/10 text-white/60">
        CANON: LOCKED
      </span>
    </div>
  );
}
TSX

cat > components/hq/MissionLauncher.tsx <<'TSX'
"use client";

import Panel from "@/components/ui/Panel";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { useRouter } from "next/navigation";
import { useAccessProfile } from "@/lib/useAccessProfile";
import { canAccessDivision } from "@/lib/access";

export default function MissionLauncher() {
  const router = useRouter();
  const { mounted, profile } = useAccessProfile();

  const lessons = loadCanonLessons();

  if (!mounted) {
    return (
      <Panel title="MISSION LAUNCHER" subtitle="Loading profile...">
        <div className="text-sm text-white/50">...</div>
      </Panel>
    );
  }

  const visible = lessons.filter((l) => canAccessDivision(profile, l.division));

  return (
    <Panel title="MISSION LAUNCHER" subtitle="Start a mission from HQ (HQ is the app).">
      <div className="space-y-3">
        {visible.map((l) => (
          <button
            key={l.id}
            onClick={() => router.push(`/academy/${l.division}/${l.id}`)}
            className="w-full text-left rounded-xl border border-white/10 bg-white/5 hover:bg-white/10 px-4 py-3"
          >
            <div className="text-xs tracking-[0.22em] text-white/45">{l.division.toUpperCase()}</div>
            <div className="text-sm text-white/85 mt-1">{l.title}</div>
            <div className="text-xs text-white/50 mt-1">{l.id} • {l.duration_minutes} mins</div>
          </button>
        ))}

        {visible.length === 0 ? (
          <div className="text-sm text-white/50">No missions available for your access posture.</div>
        ) : null}
      </div>
    </Panel>
  );
}
TSX

cat > components/hq/HQClient.tsx <<'TSX'
"use client";

import StatusStrip from "@/components/hq/StatusStrip";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import MissionLauncher from "@/components/hq/MissionLauncher";
import Panel from "@/components/ui/Panel";
import { useAccessProfile } from "@/lib/useAccessProfile";

export default function HQClient() {
  const { mounted, profile, setUserDivision, setSentinelAddOn } = useAccessProfile();

  return (
    <main className="mx-auto max-w-6xl px-6 pb-16">
      <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
        <div className="px-8 py-7 border-b border-white/10">
          <div className="text-xs tracking-[0.28em] text-white/50">NEWTON COMMAND ACADEMY</div>
          <h1 className="text-3xl font-semibold text-white mt-3">Operator HQ</h1>
          <div className="text-sm text-white/60 mt-2">HQ is the app. Lessons are execution screens. Divisions are posture filters.</div>
          <div className="mt-4">
            <StatusStrip />
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-8">
          <div className="lg:col-span-2 space-y-6">
            <MissionLauncher />

            <Panel title="ACCESS POSTURE" subtitle="Canon gating model (Phoenix full access / Vanguard paid / Sentinel add-on).">
              {!mounted ? (
                <div className="text-sm text-white/50">Loading...</div>
              ) : (
                <div className="space-y-3">
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={() => setUserDivision("phoenix")}
                      className={[
                        "px-3 py-2 rounded-xl border",
                        profile.userDivision === "phoenix"
                          ? "border-emerald-400/30 bg-emerald-500/10 text-emerald-200"
                          : "border-white/10 bg-white/5 text-white/70 hover:bg-white/10",
                      ].join(" ")}
                    >
                      Phoenix (full)
                    </button>

                    <button
                      onClick={() => setUserDivision("vanguard")}
                      className={[
                        "px-3 py-2 rounded-xl border",
                        profile.userDivision === "vanguard"
                          ? "border-sky-400/30 bg-sky-500/10 text-sky-200"
                          : "border-white/10 bg-white/5 text-white/70 hover:bg-white/10",
                      ].join(" ")}
                    >
                      Vanguard (paid)
                    </button>
                  </div>

                  <div className="flex items-center gap-2">
                    <input
                      id="sentinelAddon"
                      type="checkbox"
                      checked={!!profile.addons.sentinel}
                      onChange={(e) => setSentinelAddOn(e.target.checked)}
                      className="h-4 w-4"
                      disabled={profile.userDivision === "phoenix"}
                    />
                    <label htmlFor="sentinelAddon" className="text-sm text-white/70">
                      Sentinel add-on (auto-enabled for Phoenix)
                    </label>
                  </div>

                  <div className="text-xs text-white/50">
                    Phoenix: unrestricted (Vanguard + Sentinel included). Vanguard: Sentinel requires add-on. Phoenix lessons are gated from Vanguard.
                  </div>
                </div>
              )}
            </Panel>
          </div>

          <div className="lg:col-span-1 space-y-6">
            <ActiveMissionCard />

            <Panel title="DOCTRINE" subtitle="Immutable canon • deterministic doctrine • executable reality">
              <ul className="list-disc pl-5 space-y-2 text-sm text-white/70">
                <li>HQ is the command center.</li>
                <li>Lessons are mission terminals.</li>
                <li>Guardian Angel supports step-by-step execution.</li>
                <li>Canon types are locked (single source).</li>
              </ul>
            </Panel>
          </div>
        </div>
      </div>
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 10) HQ PAGE (server wrapper; client content inside)
# ------------------------------------------------------------
cat > app/hq/page.tsx <<'TSX'
import HQClient from "@/components/hq/HQClient";

export default function HQPage() {
  return <HQClient />;
}
TSX

# ------------------------------------------------------------
# 11) ACADEMY ROUTES (HQ supremacy + lesson execution screens)
# ------------------------------------------------------------
cat > app/academy/page.tsx <<'TSX'
export default function AcademyIndex() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-16">
      <h1 className="text-3xl font-semibold text-white">Academy</h1>
      <p className="text-white/60 mt-3">Navigate via HQ. HQ is the app.</p>
      <a className="inline-block mt-6 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white" href="/hq">
        Go to HQ
      </a>
    </main>
  );
}
TSX

cat > app/academy/[division]/page.tsx <<'TSX'
export default function DivisionIndex() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-16">
      <h1 className="text-2xl font-semibold text-white">Division</h1>
      <p className="text-white/60 mt-3">Launch missions from HQ.</p>
      <a className="inline-block mt-6 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 text-white" href="/hq">
        Go to HQ
      </a>
    </main>
  );
}
TSX

cat > app/academy/[division]/[lessonId]/page.tsx <<'TSX'
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import LessonShell from "@/components/command/LessonShell";

type PageProps = { params: { division: string; lessonId: string } };

export default function DivisionLessonPage({ params }: PageProps) {
  const lesson = loadLessonById(params.lessonId);

  if (!lesson) {
    return (
      <main className="mx-auto max-w-6xl px-6 py-16 text-red-300">
        Lesson not found.
      </main>
    );
  }

  return <LessonShell lesson={lesson} />;
}
TSX

# Keep explicit routes as thin wrappers (stability)
cat > app/academy/phoenix/page.tsx <<'TSX'
export { default } from "@/app/academy/page";
TSX
cat > app/academy/vanguard/page.tsx <<'TSX'
export { default } from "@/app/academy/page";
TSX
cat > app/academy/sentinel/page.tsx <<'TSX'
export { default } from "@/app/academy/page";
TSX

cat > app/academy/phoenix/[lessonId]/page.tsx <<'TSX'
export { default } from "@/app/academy/[division]/[lessonId]/page";
TSX
cat > app/academy/vanguard/[lessonId]/page.tsx <<'TSX'
export { default } from "@/app/academy/[division]/[lessonId]/page";
TSX
cat > app/academy/sentinel/[lessonId]/page.tsx <<'TSX'
export { default } from "@/app/academy/[division]/[lessonId]/page";
TSX

# ------------------------------------------------------------
# 12) MINIMAL GLOBAL CSS SAFETY (only if file exists; do not nuke)
# ------------------------------------------------------------
if [ -f app/globals.css ]; then
  echo "✅ app/globals.css exists (leaving it)."
else
  cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

html, body {
  height: 100%;
}

body {
  background: #050505;
  color: rgba(255,255,255,0.9);
}
CSS
fi

# ------------------------------------------------------------
# 13) TSConfig path safety (best-effort; don't fight your existing setup)
# ------------------------------------------------------------
if [ -f tsconfig.json ]; then
  echo "✅ tsconfig.json exists (leaving it)."
fi

# ------------------------------------------------------------
# 14) ROOT WRAPPER (never lose the commander again)
# ------------------------------------------------------------
cat > commander_killshot_full_academy.sh <<'BASH2'
#!/usr/bin/env bash
set -euo pipefail
exec ./commanders/commander_killshot_full_academy.sh "$@"
BASH2
chmod +x commander_killshot_full_academy.sh || true

# ------------------------------------------------------------
# 15) CANON LOCK CHECK (definitions only)
# ------------------------------------------------------------
echo "🔎 CANON LOCK CHECK (CanonLesson definitions only)"
COUNT="$(grep -R --line-number -E 'export (type|interface) CanonLesson\\b' . 2>/dev/null | wc -l | tr -d ' ')"
if [ "$COUNT" != "1" ]; then
  echo "❌ CanonLesson must be defined exactly ONCE. Found: $COUNT"
  grep -R --line-number -E 'export (type|interface) CanonLesson\\b' . 2>/dev/null || true
  exit 1
fi
echo "✅ CanonLesson single definition confirmed."

# ------------------------------------------------------------
# 16) BUILD CHECK
# ------------------------------------------------------------
echo "🧪 BUILD CHECK"
rm -rf .next || true
npm run build

echo "✅ KILLSHOT COMPLETE — HQ SUPREMACY ONLINE"
echo "🚀 Run: npm run dev"
