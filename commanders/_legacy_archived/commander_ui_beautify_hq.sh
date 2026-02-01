#!/usr/bin/env bash
set -euo pipefail

echo "🎛️  UI BEAUTIFY — HQ NORTH STAR (HYBRID C)"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 0) Sanity check
# ------------------------------------------------------------
if [ ! -f "package.json" ]; then
  echo "❌ ERROR: Run this from the repo root (where package.json is)."
  exit 1
fi

mkdir -p components/hq
mkdir -p lib

# ------------------------------------------------------------
# 1) Fix Panel: allow variant prop (removes your DivisionDeck TS error)
# ------------------------------------------------------------
if [ -f "components/ui/Panel.tsx" ]; then
  echo "🧱 Updating components/ui/Panel.tsx (add variant support)"
  cat > components/ui/Panel.tsx <<'TSX'
import React from "react";

type Variant = "default" | "active" | "muted" | "danger";

type Props = {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
  right?: React.ReactNode;
  variant?: Variant;
  className?: string;
};

function variantClasses(v: Variant) {
  switch (v) {
    case "active":
      return "border-emerald-400/30 bg-black/35 shadow-[0_0_0_1px_rgba(16,185,129,0.15),0_20px_60px_rgba(0,0,0,0.6)]";
    case "muted":
      return "border-white/10 bg-black/25";
    case "danger":
      return "border-red-500/30 bg-black/35";
    case "default":
    default:
      return "border-white/10 bg-black/30";
  }
}

export default function Panel({
  title,
  subtitle,
  children,
  right,
  variant = "default",
  className = "",
}: Props) {
  return (
    <section
      className={[
        "rounded-3xl border backdrop-blur-xl overflow-hidden",
        variantClasses(variant),
        className,
      ].join(" ")}
    >
      <header className="px-7 py-6 border-b border-white/10 flex items-start justify-between gap-4">
        <div>
          <div className="text-xs tracking-[0.25em] text-white/55">PANEL</div>
          <h2 className="mt-2 text-lg font-semibold text-white">{title}</h2>
          {subtitle ? (
            <p className="mt-1 text-sm text-white/60 leading-relaxed">{subtitle}</p>
          ) : null}
        </div>
        {right ? <div className="pt-1">{right}</div> : null}
      </header>
      <div className="px-7 py-6">{children}</div>
    </section>
  );
}
TSX
else
  echo "⚠️  Skipping Panel.tsx update (file not found)."
fi

# ------------------------------------------------------------
# 2) Fix LessonShell: make children optional (fixes build break)
# ------------------------------------------------------------
if [ -f "components/command/LessonShell.tsx" ]; then
  echo "🛠️  Fixing components/command/LessonShell.tsx (children optional)"
  cat > components/command/LessonShell.tsx <<'TSX'
"use client";

import React, { useMemo } from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import type { CanonLesson, Division } from "@/cert_intel/intake/lib/canonTypes";

// If your project already has a MissionHandshake component, keep using it.
// This import path matches what your error log showed.
import MissionHandshake from "@/components/command/MissionHandshake";

type Props = {
  lesson: CanonLesson;
  children?: React.ReactNode; // ✅ optional now
};

function stepsFromLesson(lesson: CanonLesson): string[] {
  // prefer explicit steps if present
  const anyLesson = lesson as any;
  if (Array.isArray(anyLesson.steps) && anyLesson.steps.length) return anyLesson.steps;
  const lines = String(lesson.walkthrough ?? "")
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);
  const numbered = lines.filter((l) => /^\d+\)/.test(l) || /^\d+\./.test(l));
  const base = numbered.length ? numbered : lines;
  return base.slice(0, 12);
}

export default function LessonShell({ lesson, children }: Props) {
  const steps = useMemo(() => stepsFromLesson(lesson), [lesson]);

  return (
    <Shell>
      <div className="mx-auto max-w-6xl px-6 pb-16">
        {/* ✅ Lesson ↔ HQ handshake (this is runtime wiring, not UI fluff) */}
        <MissionHandshake lessonId={lesson.id} division={lesson.division as Division} />

        <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
          <div className="px-8 py-7 border-b border-white/10">
            <div className="text-xs tracking-[0.25em] text-white/55">
              MISSION EXECUTION SCREEN
            </div>
            <h1 className="mt-2 text-3xl font-semibold text-white">{lesson.title}</h1>
            {lesson.concept ? (
              <p className="mt-3 text-white/65 leading-relaxed">{lesson.concept}</p>
            ) : null}
          </div>

          <div className="px-8 py-7 grid gap-6 lg:grid-cols-5">
            <div className="lg:col-span-3">
              {children ? (
                children
              ) : (
                <Panel
                  title="WALKTHROUGH"
                  subtitle="Execute in order. Report completion. Debrief."
                  variant="active"
                >
                  <ol className="space-y-3 text-sm text-white/75 list-decimal pl-5">
                    {steps.length ? (
                      steps.map((s, i) => <li key={i}>{s}</li>)
                    ) : (
                      <li>Open HQ, confirm mission state, then run the objective sequence.</li>
                    )}
                  </ol>
                </Panel>
              )}
            </div>

            <div className="lg:col-span-2 space-y-4">
              <Panel title="OBJECTIVES" subtitle="What success looks like.">
                <ul className="space-y-2 text-sm text-white/75 list-disc pl-5">
                  {(lesson.objectives ?? []).map((o, i) => (
                    <li key={i}>{o}</li>
                  ))}
                  {(!lesson.objectives || lesson.objectives.length === 0) && (
                    <li>Complete the walkthrough and log the debrief.</li>
                  )}
                </ul>
              </Panel>

              <Panel title="POSTURE" subtitle="Division filters are posture, not separate worlds." variant="muted">
                <div className="text-sm text-white/70 space-y-2">
                  <div>
                    <span className="text-white/50">Division:</span>{" "}
                    <span className="text-white">{lesson.division}</span>
                  </div>
                  <div>
                    <span className="text-white/50">Difficulty:</span>{" "}
                    <span className="text-white">{lesson.difficulty}</span>
                  </div>
                  <div>
                    <span className="text-white/50">Duration:</span>{" "}
                    <span className="text-white">{lesson.duration_minutes}m</span>
                  </div>
                </div>
              </Panel>
            </div>
          </div>
        </div>
      </div>
    </Shell>
  );
}
TSX
else
  echo "⚠️  Skipping LessonShell fix (components/command/LessonShell.tsx not found)."
fi

# ------------------------------------------------------------
# 3) Create MissionRuntimeStore ONLY if missing (non-invasive)
# ------------------------------------------------------------
if [ ! -f "lib/missionRuntimeStore.ts" ]; then
  echo "🧠 Creating lib/missionRuntimeStore.ts (only because it was missing)"
  cat > lib/missionRuntimeStore.ts <<'TS'
"use client";

import { useEffect, useMemo, useSyncExternalStore } from "react";

export type Division = "phoenix" | "vanguard" | "sentinel";

export type ActiveMission = {
  division: Division;
  lessonId: string;
  title?: string;
  startedAt: number;
  lastTouchedAt: number;
  stepIndex: number;
};

type State = {
  active?: ActiveMission;
};

const KEY = "nca:missionRuntime:v1";

function read(): State {
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return {};
    return JSON.parse(raw) as State;
  } catch {
    return {};
  }
}

function write(s: State) {
  try {
    localStorage.setItem(KEY, JSON.stringify(s));
  } catch {
    // ignore
  }
}

let memory: State = {};
const listeners = new Set<() => void>();

function emit() {
  for (const l of listeners) l();
}

export function getState(): State {
  if (typeof window === "undefined") return {};
  if (!Object.keys(memory).length) memory = read();
  return memory;
}

export function setActiveMission(m: ActiveMission) {
  const next: State = { active: m };
  memory = next;
  write(next);
  emit();
}

export function clearActiveMission() {
  const next: State = {};
  memory = next;
  write(next);
  emit();
}

export function touchMission(partial: Partial<ActiveMission>) {
  const current = getState().active;
  if (!current) return;
  const nextMission: ActiveMission = {
    ...current,
    ...partial,
    lastTouchedAt: Date.now(),
  };
  setActiveMission(nextMission);
}

export function useMissionRuntime() {
  const subscribe = (cb: () => void) => {
    listeners.add(cb);
    return () => listeners.delete(cb);
  };

  const getSnapshot = () => getState();

  const state = useSyncExternalStore(subscribe, getSnapshot, () => ({}));

  useEffect(() => {
    // keep in sync across tabs
    const onStorage = (e: StorageEvent) => {
      if (e.key === KEY) {
        memory = read();
        emit();
      }
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const active = (state as State).active;

  return useMemo(
    () => ({
      active,
      setActiveMission,
      clearActiveMission,
      touchMission,
    }),
    [active]
  );
}
TS
else
  echo "✅ MissionRuntimeStore exists — leaving it untouched."
fi

# ------------------------------------------------------------
# 4) HQ UI: Command Stack Layout (North Star)
# ------------------------------------------------------------
echo "🏛️  Writing HQ components (ActiveMissionCard + StatusStrip) and HQ page"

cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import React from "react";
import Panel from "@/components/ui/Panel";
import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

function fmtAgo(ts: number) {
  const s = Math.max(0, Math.floor((Date.now() - ts) / 1000));
  if (s < 60) return `${s}s ago`;
  const m = Math.floor(s / 60);
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  return `${h}h ago`;
}

export default function ActiveMissionCard() {
  const router = useRouter();
  const { active, clearActiveMission } = useMissionRuntime();

  if (!active) {
    return (
      <Panel
        title="ACTIVE MISSION"
        subtitle="No mission is live. HQ is waiting for a lesson handshake."
        variant="muted"
      >
        <div className="text-sm text-white/70 leading-relaxed">
          Start a mission from <span className="text-white/85">/academy</span>, or use the
          Quick Deploy route. HQ will auto-capture the runtime state.
        </div>
      </Panel>
    );
  }

  return (
    <Panel
      title="ACTIVE MISSION"
      subtitle="This is the single source of truth. Resume is instant."
      variant="active"
      right={
        <div className="flex items-center gap-2">
          <button
            onClick={() => router.push(`/academy/${active.division}/${active.lessonId}`)}
            className="rounded-xl border border-emerald-400/30 bg-black/30 hover:bg-black/45 px-4 py-2 text-sm text-white"
          >
            Resume
          </button>
          <button
            onClick={() => clearActiveMission()}
            className="rounded-xl border border-white/10 bg-black/20 hover:bg-black/35 px-4 py-2 text-sm text-white/80"
          >
            Clear
          </button>
        </div>
      }
      className="shadow-[0_35px_120px_rgba(0,0,0,0.75)]"
    >
      <div className="grid gap-4 lg:grid-cols-5">
        <div className="lg:col-span-3">
          <div className="text-xs tracking-[0.25em] text-white/55">MISSION ID</div>
          <div className="mt-2 text-2xl font-semibold text-white">{active.lessonId}</div>
          {active.title ? (
            <div className="mt-2 text-white/70">{active.title}</div>
          ) : (
            <div className="mt-2 text-white/70">
              Title not recorded yet (non-fatal). Resume will still work.
            </div>
          )}
        </div>

        <div className="lg:col-span-2 space-y-3">
          <div className="rounded-2xl border border-white/10 bg-black/20 p-4">
            <div className="text-xs tracking-[0.25em] text-white/55">POSTURE</div>
            <div className="mt-2 text-sm text-white/80">
              Division: <span className="text-white">{active.division}</span>
            </div>
            <div className="mt-1 text-sm text-white/70">
              Step Index: <span className="text-white/90">{active.stepIndex}</span>
            </div>
          </div>

          <div className="rounded-2xl border border-white/10 bg-black/20 p-4">
            <div className="text-xs tracking-[0.25em] text-white/55">LAST TOUCH</div>
            <div className="mt-2 text-sm text-white/80">{fmtAgo(active.lastTouchedAt)}</div>
            <div className="mt-1 text-xs text-white/55">
              Started: {new Date(active.startedAt).toLocaleString()}
            </div>
          </div>
        </div>
      </div>
    </Panel>
  );
}
TSX

cat > components/hq/StatusStrip.tsx <<'TSX'
"use client";

import React, { useMemo } from "react";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

type ChipProps = {
  label: string;
  value: string;
  state?: "ok" | "warn" | "bad";
};

function Chip({ label, value, state = "ok" }: ChipProps) {
  const cls =
    state === "ok"
      ? "border-emerald-400/20 text-white/85"
      : state === "warn"
      ? "border-amber-400/25 text-white/85"
      : "border-red-500/25 text-white/85";

  return (
    <div className={`rounded-2xl border ${cls} bg-black/20 px-4 py-3`}>
      <div className="text-[10px] tracking-[0.25em] text-white/55">{label}</div>
      <div className="mt-1 text-sm">{value}</div>
    </div>
  );
}

export default function StatusStrip() {
  const { active } = useMissionRuntime();

  const missionState = useMemo(() => {
    if (!active) return { value: "IDLE", state: "warn" as const };
    return { value: "LIVE", state: "ok" as const };
  }, [active]);

  return (
    <div className="grid gap-3 md:grid-cols-4">
      <Chip label="HQ" value="NORTH STAR" state="ok" />
      <Chip label="MISSION" value={missionState.value} state={missionState.state} />
      <Chip label="CANON" value="LOCKED" state="ok" />
      <Chip label="GUARDIAN" value="ONLINE" state="ok" />
    </div>
  );
}
TSX

# HQ page: command stack layout (no grids fighting for attention)
mkdir -p app/hq
cat > app/hq/page.tsx <<'TSX'
"use client";

import React, { useEffect, useMemo, useState } from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import StatusStrip from "@/components/hq/StatusStrip";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { lessonHref } from "@/lib/nav";
import { DEFAULT_UI, loadUi, saveUi } from "@/lib/uiStore";
import type { UiState } from "@/lib/uiTypes";

function nowStamp() {
  return new Date().toLocaleString(undefined, {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default function HQPage() {
  const [ui, setUi] = useState<UiState>(DEFAULT_UI);
  const [stamp, setStamp] = useState(nowStamp());

  useEffect(() => setUi(loadUi()), []);
  useEffect(() => saveUi(ui), [ui]);

  useEffect(() => {
    const t = setInterval(() => setStamp(nowStamp()), 15_000);
    return () => clearInterval(t);
  }, []);

  const lessonCount = useMemo(() => loadCanonLessons().length, []);
  const previewLesson = useMemo(() => {
    const pool = loadCanonLessons(ui.division);
    return pool[0] ?? null;
  }, [ui.division]);

  return (
    <Shell>
      <div className="mx-auto max-w-6xl px-6 pb-16">
        {/* COMMAND HEADER */}
        <div className="mt-10 rounded-3xl border border-white/10 bg-black/35 backdrop-blur-xl overflow-hidden">
          <div className="px-8 py-7 border-b border-white/10">
            <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
              <div>
                <div className="text-xs tracking-[0.35em] text-white/55">
                  NEWTON COMMAND ACADEMY • HQ
                </div>
                <h1 className="mt-3 text-3xl font-semibold text-white">
                  North Star Command Room
                </h1>
                <p className="mt-2 text-white/65 leading-relaxed">
                  HQ is the app. Lessons are execution screens. Divisions are posture filters.
                </p>
              </div>

              <div className="rounded-2xl border border-white/10 bg-black/25 px-5 py-4">
                <div className="text-[10px] tracking-[0.35em] text-white/55">TIME</div>
                <div className="mt-1 text-sm text-white/85">{stamp}</div>
                <div className="mt-2 text-[11px] text-white/55">
                  Canon Lessons: <span className="text-white/85">{lessonCount}</span>
                </div>
              </div>
            </div>
          </div>

          {/* STATUS STRIP */}
          <div className="px-8 py-6 border-b border-white/10">
            <StatusStrip />
          </div>

          {/* QUICK DEPLOY */}
          <div className="px-8 py-6">
            <div className="grid gap-3 md:grid-cols-3">
              <a
                className="rounded-2xl border border-white/10 bg-black/25 hover:bg-black/40 px-5 py-4"
                href="/academy"
              >
                <div className="text-[10px] tracking-[0.35em] text-white/55">DEPLOY</div>
                <div className="mt-1 text-sm text-white/85">Enter Academy Directory</div>
                <div className="mt-2 text-xs text-white/55">
                  Browse missions by division posture.
                </div>
              </a>

              <a
                className="rounded-2xl border border-white/10 bg-black/25 hover:bg-black/40 px-5 py-4"
                href="/"
              >
                <div className="text-[10px] tracking-[0.35em] text-white/55">HOME</div>
                <div className="mt-1 text-sm text-white/85">Return to North Star Home</div>
                <div className="mt-2 text-xs text-white/55">Deck controls remain centralized.</div>
              </a>

              {previewLesson ? (
                <a
                  className="rounded-2xl border border-emerald-400/25 bg-black/25 hover:bg-black/40 px-5 py-4"
                  href={lessonHref(ui.division, previewLesson.id)}
                >
                  <div className="text-[10px] tracking-[0.35em] text-white/55">GOLDEN PATH</div>
                  <div className="mt-1 text-sm text-white/85">
                    Start: {previewLesson.id}
                  </div>
                  <div className="mt-2 text-xs text-white/55">{previewLesson.title}</div>
                </a>
              ) : (
                <div className="rounded-2xl border border-white/10 bg-black/20 px-5 py-4">
                  <div className="text-[10px] tracking-[0.35em] text-white/55">GOLDEN PATH</div>
                  <div className="mt-1 text-sm text-white/60">No preview lesson available.</div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* ACTIVE MISSION — DOMINANT PANEL */}
        <div className="mt-6">
          <ActiveMissionCard />
        </div>

        {/* DOCTRINE — QUIET, BUT PRESENT */}
        <div className="mt-6">
          <Panel title="DOCTRINE" subtitle="Locked canon. No dilution. HQ supremacy is permanent." variant="muted">
            <ul className="text-sm text-white/70 space-y-2 list-disc pl-5">
              <li>Phoenix has full unrestricted access (includes Vanguard + Sentinel).</li>
              <li>Vanguard is paid access; Sentinel is an elite add-on unless Phoenix.</li>
              <li>Same content universe for all — gated by rank/division/competence.</li>
              <li>Interface Mode ≠ Learning Mode (independent toggles).</li>
            </ul>
          </Panel>
        </div>
      </div>
    </Shell>
  );
}
TSX

# ------------------------------------------------------------
# 5) Build Check
# ------------------------------------------------------------
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ UI BEAUTIFY COMPLETE — HQ NORTH STAR (HYBRID C) LIVE"
echo "🚀 Run: npm run dev"
