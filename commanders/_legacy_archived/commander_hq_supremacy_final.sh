#!/usr/bin/env bash
set -euo pipefail

echo "🎯 HQ SUPREMACY FINAL — Mission Runtime + HQ↔Lesson Handshake"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 0) Preconditions
# ------------------------------------------------------------
if [ ! -f package.json ]; then
  echo "❌ ERROR: package.json not found. Run from repo root."
  exit 1
fi

mkdir -p lib
mkdir -p components/hq
mkdir -p components/command
mkdir -p app/hq

# ------------------------------------------------------------
# 1) Mission Runtime Store (single source of truth)
# ------------------------------------------------------------
cat > lib/missionRuntime.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";

export type MissionRuntime = {
  active: boolean;
  division: Division;
  lessonId: string;
  startedAt: number;      // epoch ms
  updatedAt: number;      // epoch ms
  stepIndex: number;      // guardian step pointer (0..n)
  notes?: string;         // optional debrief scratchpad
};

const KEY = "nca:missionRuntime:v1";

const DEFAULT: MissionRuntime = {
  active: false,
  division: "phoenix",
  lessonId: "intro-001",
  startedAt: Date.now(),
  updatedAt: Date.now(),
  stepIndex: 0,
};

function isBrowser() {
  return typeof window !== "undefined" && typeof localStorage !== "undefined";
}

export function loadMissionRuntime(): MissionRuntime {
  if (!isBrowser()) return DEFAULT;
  try {
    const raw = localStorage.getItem(KEY);
    if (!raw) return DEFAULT;
    const parsed = JSON.parse(raw) as Partial<MissionRuntime>;
    return {
      ...DEFAULT,
      ...parsed,
      // harden types
      active: Boolean(parsed.active),
      division: (parsed.division as Division) || DEFAULT.division,
      lessonId: typeof parsed.lessonId === "string" ? parsed.lessonId : DEFAULT.lessonId,
      startedAt: typeof parsed.startedAt === "number" ? parsed.startedAt : DEFAULT.startedAt,
      updatedAt: typeof parsed.updatedAt === "number" ? parsed.updatedAt : Date.now(),
      stepIndex: typeof parsed.stepIndex === "number" ? parsed.stepIndex : 0,
      notes: typeof parsed.notes === "string" ? parsed.notes : undefined,
    };
  } catch {
    return DEFAULT;
  }
}

export function saveMissionRuntime(rt: MissionRuntime): void {
  if (!isBrowser()) return;
  try {
    localStorage.setItem(KEY, JSON.stringify(rt));
  } catch {
    // ignore storage failures
  }
}

export function startMission(division: Division, lessonId: string): MissionRuntime {
  const now = Date.now();
  const rt: MissionRuntime = {
    active: true,
    division,
    lessonId,
    startedAt: now,
    updatedAt: now,
    stepIndex: 0,
  };
  saveMissionRuntime(rt);
  return rt;
}

export function abortMission(): MissionRuntime {
  const now = Date.now();
  const prev = loadMissionRuntime();
  const rt: MissionRuntime = {
    ...prev,
    active: false,
    updatedAt: now,
    stepIndex: 0,
    notes: prev.notes,
  };
  saveMissionRuntime(rt);
  return rt;
}

export function setStepIndex(stepIndex: number): MissionRuntime {
  const now = Date.now();
  const prev = loadMissionRuntime();
  const rt: MissionRuntime = {
    ...prev,
    stepIndex: Math.max(0, stepIndex),
    updatedAt: now,
  };
  saveMissionRuntime(rt);
  return rt;
}

export function setNotes(notes: string): MissionRuntime {
  const now = Date.now();
  const prev = loadMissionRuntime();
  const rt: MissionRuntime = {
    ...prev,
    notes,
    updatedAt: now,
  };
  saveMissionRuntime(rt);
  return rt;
}
TS

# ------------------------------------------------------------
# 2) Client hook wrapper for runtime store
# ------------------------------------------------------------
cat > lib/useMissionRuntime.ts <<'TS'
"use client";

import { useEffect, useMemo, useState } from "react";
import type { Division, MissionRuntime } from "./missionRuntime";
import {
  abortMission,
  loadMissionRuntime,
  saveMissionRuntime,
  setNotes,
  setStepIndex,
  startMission,
} from "./missionRuntime";

type API = {
  rt: MissionRuntime;
  refresh: () => void;

  // commands
  start: (division: Division, lessonId: string) => void;
  abort: () => void;
  step: (idx: number) => void;
  notes: (txt: string) => void;
};

export function useMissionRuntime(): API {
  const [rt, setRt] = useState<MissionRuntime>(() => loadMissionRuntime());

  const refresh = () => setRt(loadMissionRuntime());

  // keep state synced if storage changes in another tab
  useEffect(() => {
    const onStorage = (e: StorageEvent) => {
      if (!e.key) return;
      if (e.key.includes("nca:missionRuntime")) refresh();
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const api = useMemo<API>(() => {
    return {
      rt,
      refresh,
      start: (division, lessonId) => setRt(startMission(division, lessonId)),
      abort: () => setRt(abortMission()),
      step: (idx) => setRt(setStepIndex(idx)),
      notes: (txt) => setRt(setNotes(txt)),
    };
  }, [rt]);

  // persist any local mutations that come from future expansions
  useEffect(() => {
    saveMissionRuntime(rt);
  }, [rt]);

  return api;
}
TS

# ------------------------------------------------------------
# 3) Division enforcement helper (doctrine)
# ------------------------------------------------------------
cat > lib/access.ts <<'TS'
import type { Division } from "./missionRuntime";

/**
 * Doctrine (locked):
 * - Phoenix: full unrestricted access to all (Phoenix + Vanguard + Sentinel)
 * - Vanguard: paid civilian access; excludes Sentinel unless upgraded
 * - Sentinel: elite add-on; can access Vanguard + Sentinel
 * - Phoenix-only content remains Phoenix-only (others can't open Phoenix lessons)
 */
export function canAccess(userDivision: Division, contentDivision: Division): boolean {
  if (userDivision === "phoenix") return true;

  if (contentDivision === "phoenix") return false;

  if (userDivision === "vanguard") {
    return contentDivision === "vanguard";
  }

  // userDivision === "sentinel"
  return contentDivision === "vanguard" || contentDivision === "sentinel";
}
TS

# ------------------------------------------------------------
# 4) Ensure nav helper exists: lessonHref(division, lessonId)
# ------------------------------------------------------------
if [ ! -f lib/nav.ts ]; then
  cat > lib/nav.ts <<'TS'
import type { Division } from "./missionRuntime";

export function lessonHref(division: Division, lessonId: string): string {
  return `/academy/${division}/${lessonId}`;
}

export function academyDivisionHref(division: Division): string {
  return `/academy/${division}`;
}

export function hqHref(): string {
  return `/hq`;
}
TS
else
  # append lessonHref only if missing
  if ! grep -q "export function lessonHref" lib/nav.ts; then
    cat >> lib/nav.ts <<'TS'

export function lessonHref(division: any, lessonId: string): string {
  return `/academy/${division}/${lessonId}`;
}
TS
  fi
fi

# ------------------------------------------------------------
# 5) MissionHandshake component (Lesson → HQ registration)
# ------------------------------------------------------------
cat > components/command/MissionHandshake.tsx <<'TSX'
"use client";

import { useEffect } from "react";
import type { Division } from "@/lib/missionRuntime";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

/**
 * Drop-in wiring:
 * - When a lesson screen loads, it asserts/refreshes runtime mission state.
 * - HQ can always resume the last active mission.
 */
export default function MissionHandshake(props: { lessonId: string; division: Division }) {
  const { rt, start } = useMissionRuntime();

  useEffect(() => {
    // If different mission is open, register it as the active mission.
    if (!rt.active || rt.lessonId !== props.lessonId || rt.division !== props.division) {
      start(props.division, props.lessonId);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [props.lessonId, props.division]);

  return null;
}
TSX

# ------------------------------------------------------------
# 6) HQ ActiveMissionCard component (resume/abort/debrief)
# ------------------------------------------------------------
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useMemo } from "react";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import { lessonHref } from "@/lib/nav";

export default function ActiveMissionCard() {
  const { rt, abort, notes, step } = useMissionRuntime();

  const resumeHref = useMemo(() => {
    return lessonHref(rt.division as any, rt.lessonId);
  }, [rt.division, rt.lessonId]);

  return (
    <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
      <div className="px-6 py-5 border-b border-white/10 flex items-center justify-between">
        <div>
          <div className="text-xs tracking-widest text-white/60">ACTIVE MISSION</div>
          <div className="text-lg font-semibold text-white">
            {rt.active ? `${rt.lessonId}` : "No mission live"}
          </div>
          <div className="text-sm text-white/60">
            {rt.active ? `Division: ${rt.division.toUpperCase()} • Step ${rt.stepIndex + 1}` : "Launch a lesson to begin runtime tracking."}
          </div>
        </div>

        <div className="flex gap-2">
          {rt.active ? (
            <>
              <a
                href={resumeHref}
                className="rounded-xl px-4 py-2 border border-blue-400/40 bg-black/40 hover:bg-black/60 text-white text-sm"
              >
                Resume
              </a>
              <button
                onClick={() => abort()}
                className="rounded-xl px-4 py-2 border border-white/10 bg-black/40 hover:bg-black/60 text-white/90 text-sm"
              >
                Abort
              </button>
            </>
          ) : (
            <a
              href="/academy"
              className="rounded-xl px-4 py-2 border border-white/10 bg-black/40 hover:bg-black/60 text-white/90 text-sm"
            >
              Open Academy
            </a>
          )}
        </div>
      </div>

      <div className="px-6 py-5 grid gap-4">
        <div className="grid gap-2">
          <div className="text-xs tracking-widest text-white/60">DEBRIEF NOTES</div>
          <textarea
            value={rt.notes ?? ""}
            onChange={(e) => notes(e.target.value)}
            placeholder="Debrief goes here. What did you do, what did you learn, what’s next?"
            className="w-full min-h-[96px] rounded-2xl border border-white/10 bg-black/40 p-4 text-white/90 placeholder:text-white/30 outline-none"
          />
        </div>

        {rt.active && (
          <div className="flex items-center gap-2">
            <button
              onClick={() => step(Math.max(0, rt.stepIndex - 1))}
              className="rounded-xl px-3 py-2 border border-white/10 bg-black/40 hover:bg-black/60 text-white/80 text-sm"
            >
              Prev Step
            </button>
            <button
              onClick={() => step(rt.stepIndex + 1)}
              className="rounded-xl px-3 py-2 border border-white/10 bg-black/40 hover:bg-black/60 text-white/80 text-sm"
            >
              Next Step
            </button>
            <div className="ml-auto text-xs text-white/50">
              Updated: {new Date(rt.updatedAt).toLocaleString()}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 7) HQ North Star page (centres around Active Mission)
# ------------------------------------------------------------
cat > app/hq/page.tsx <<'TSX'
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";

export default function HQPage() {
  return (
    <div className="mx-auto max-w-6xl px-6 py-10">
      <div className="mb-6">
        <div className="text-xs tracking-widest text-white/60">NEWTON COMMAND ACADEMY</div>
        <h1 className="text-3xl font-semibold text-white mt-1">HQ — North Star Command</h1>
        <p className="text-white/60 mt-2">
          HQ is the app. Lessons are execution screens. Divisions are posture filters. Guardian Angel is mission support.
        </p>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="lg:col-span-2">
          <ActiveMissionCard />
        </div>

        <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
          <div className="px-6 py-5 border-b border-white/10">
            <div className="text-xs tracking-widest text-white/60">QUICK DEPLOY</div>
            <div className="text-lg font-semibold text-white">Jump Points</div>
            <div className="text-sm text-white/60">Move like a real unit.</div>
          </div>

          <div className="px-6 py-5 grid gap-2">
            <a className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/60 p-4 text-white" href="/academy">
              Academy Directory
            </a>
            <a className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/60 p-4 text-white" href="/">
              North Star Home
            </a>
            <a className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/60 p-4 text-white" href="/academy/phoenix">
              Phoenix Track
            </a>
            <a className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/60 p-4 text-white" href="/academy/vanguard">
              Vanguard Track
            </a>
            <a className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/60 p-4 text-white" href="/academy/sentinel">
              Sentinel Track
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 8) Fix LessonShell: children OPTIONAL + handshake in the shell
#    (kills your current build error immediately)
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
import type { ReactNode } from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import MissionHandshake from "@/components/command/MissionHandshake";

export default function LessonShell(props: { lesson: CanonLesson; children?: ReactNode }) {
  const { lesson, children } = props;

  return (
    <div className="mx-auto max-w-6xl px-6 py-10">
      {/* LESSON ↔ HQ HANDSHAKE (runtime mission registration) */}
      <MissionHandshake lessonId={lesson.id} division={lesson.division as any} />

      <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
        <div className="px-8 py-7 border-b border-white/10">
          <div className="text-xs tracking-widest text-white/60">MISSION EXECUTION</div>
          <h1 className="text-2xl font-semibold text-white mt-1">{lesson.title}</h1>
          <p className="text-white/60 mt-2">{lesson.concept}</p>

          <div className="mt-4 flex flex-wrap gap-2">
            <span className="rounded-full border border-white/10 bg-black/40 px-3 py-1 text-xs text-white/70">
              {lesson.division.toUpperCase()}
            </span>
            <span className="rounded-full border border-white/10 bg-black/40 px-3 py-1 text-xs text-white/70">
              {lesson.difficulty.toUpperCase()}
            </span>
            <span className="rounded-full border border-white/10 bg-black/40 px-3 py-1 text-xs text-white/70">
              {lesson.duration_minutes} mins
            </span>
          </div>
        </div>

        <div className="px-8 py-7 grid gap-6">
          {children ? (
            children
          ) : (
            <>
              <div>
                <div className="text-xs tracking-widest text-white/60">OBJECTIVES</div>
                <ul className="mt-3 space-y-2 text-white/80 list-disc pl-5">
                  {lesson.objectives?.map((o, i) => (
                    <li key={i}>{o}</li>
                  ))}
                </ul>
              </div>

              <div>
                <div className="text-xs tracking-widest text-white/60">WALKTHROUGH</div>
                <pre className="mt-3 whitespace-pre-wrap rounded-2xl border border-white/10 bg-black/40 p-5 text-white/80">
{lesson.walkthrough}
                </pre>
              </div>

              {Array.isArray((lesson as any).steps) && (lesson as any).steps.length > 0 && (
                <div>
                  <div className="text-xs tracking-widest text-white/60">GUARDIAN STEPS</div>
                  <ol className="mt-3 space-y-2 text-white/80 list-decimal pl-5">
                    {(lesson as any).steps.map((s: string, i: number) => (
                      <li key={i}>{s}</li>
                    ))}
                  </ol>
                </div>
              )}

              <div className="flex gap-2 pt-2">
                <a
                  href="/hq"
                  className="rounded-2xl px-4 py-3 border border-blue-400/30 bg-black/40 hover:bg-black/60 text-white"
                >
                  Return to HQ
                </a>
                <a
                  href="/academy"
                  className="rounded-2xl px-4 py-3 border border-white/10 bg-black/40 hover:bg-black/60 text-white/90"
                >
                  Academy Directory
                </a>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 9) Academy lesson page stays SIMPLE (LessonShell no longer requires children)
# ------------------------------------------------------------
# We won't overwrite if you already customized it heavily; but we will fix the exact error safely.
LESSON_PAGE="app/academy/[division]/[lessonId]/page.tsx"
if [ -f "$LESSON_PAGE" ]; then
  # if it contains <LessonShell lesson={lesson} /> it will now compile because children is optional.
  echo "✅ Detected $LESSON_PAGE — leaving as-is (LessonShell fixed to accept no children)."
else
  mkdir -p app/academy/\[division\]/\[\lessonId\] 2>/dev/null || true
fi

# ------------------------------------------------------------
# 10) Freeze marker (explicit baseline lock)
# ------------------------------------------------------------
cat > .northstar_freeze <<'TXT'
NORTH STAR FREEZE — HQ SUPREMACY BASELINE
- Mission runtime store: lib/missionRuntime.ts
- HQ active mission card: components/hq/ActiveMissionCard.tsx
- Lesson ↔ HQ handshake: components/command/MissionHandshake.tsx + LessonShell integration
- Division access doctrine helper: lib/access.ts
- LessonShell children optional: fixed build break + standard mission layout
TXT

# ------------------------------------------------------------
# 11) GREEN BUILD CHECK
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ HQ SUPREMACY FINAL COMPLETE — Green build confirmed"
echo "🚀 Run: npm run dev"
echo "⭐ HQ: http://localhost:3000/hq"
