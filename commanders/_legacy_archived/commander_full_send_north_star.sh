#!/usr/bin/env bash
set -euo pipefail

echo "🚀 FULL SEND — NORTH STAR FINAL"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 0) Guardrails / folders
# ------------------------------------------------------------
mkdir -p commanders
mkdir -p lib
mkdir -p components/hq
mkdir -p components/command

# ------------------------------------------------------------
# 1) Mission Runtime Store (single source of truth)
#    - No deps. LocalStorage-backed. useSyncExternalStore hook.
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

type MissionRuntimeState = {
  active: ActiveMission | null;
};

type Listener = () => void;

const STORAGE_KEY = "newton.mission.runtime.v1";

let state: MissionRuntimeState = {
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
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // ignore
  }
}

function hydrateOnce() {
  if (typeof window === "undefined") return;
  const raw = safeParse(window.localStorage.getItem(STORAGE_KEY));
  if (raw && typeof raw === "object") {
    state = {
      active: raw.active ?? null,
    };
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

function snapshot() {
  return getMissionRuntimeState();
}

function serverSnapshot(): MissionRuntimeState {
  return { active: null };
}

export function useMissionRuntime() {
  const s = useSyncExternalStore(subscribeMissionRuntime, snapshot, serverSnapshot);

  return {
    state: s,
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
# 2) Division Access Logic (canonical)
# ------------------------------------------------------------
cat > lib/access.ts <<'TS'
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

/**
 * Canon access model (locked):
 * - Phoenix: full unrestricted access to ALL (includes Vanguard + Sentinel)
 * - Vanguard: paid civilian access EXCLUDING Sentinel unless upgraded
 * - Sentinel: elite add-on for Vanguard; full access (all content)
 *
 * NOTE: today we treat "viewerDivision" as current entitlement posture.
 */
export function canAccess(viewerDivision: Division, contentDivision: Division): boolean {
  if (viewerDivision === "phoenix") return true;

  if (viewerDivision === "sentinel") {
    // Sentinel is elite: can see everything
    return true;
  }

  // Vanguard cannot see Sentinel content unless upgraded
  if (viewerDivision === "vanguard") {
    return contentDivision !== "sentinel";
  }

  // Safe fallback
  return false;
}
TS

# ------------------------------------------------------------
# 3) HQ Active Mission Card (exact component)
# ------------------------------------------------------------
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import React, { useMemo } from "react";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

function formatTime(ms: number) {
  try {
    return new Date(ms).toLocaleString();
  } catch {
    return String(ms);
  }
}

export default function ActiveMissionCard() {
  const { state, clearMission } = useMissionRuntime();

  const href = useMemo(() => {
    const m = state.active;
    if (!m) return null;
    return `/academy/${m.division}/${m.lessonId}`;
  }, [state.active]);

  if (!state.active) {
    return (
      <div className="rounded-3xl border border-white/10 bg-black/35 backdrop-blur-xl p-6">
        <div className="text-xs tracking-[0.3em] text-white/50">ACTIVE MISSION</div>
        <div className="mt-2 text-lg font-semibold text-white">No mission running</div>
        <div className="mt-1 text-sm text-white/60">
          Start a lesson to initialize the runtime. HQ becomes your command layer.
        </div>
      </div>
    );
  }

  const m = state.active;

  const completedCount = Object.values(m.completedSteps ?? {}).filter(Boolean).length;

  return (
    <div className="rounded-3xl border border-white/10 bg-black/35 backdrop-blur-xl overflow-hidden">
      <div className="px-6 py-5 border-b border-white/10 flex items-center justify-between gap-4">
        <div>
          <div className="text-xs tracking-[0.3em] text-white/50">ACTIVE MISSION</div>
          <div className="mt-1 text-lg font-semibold text-white">
            {m.lessonId} <span className="text-white/50">/</span> {m.division.toUpperCase()}
          </div>
          <div className="mt-1 text-sm text-white/60">
            Started: {formatTime(m.startedAt)} · Last seen: {formatTime(m.lastSeenAt)}
          </div>
        </div>

        <div className="flex items-center gap-2">
          {href && (
            <a
              href={href}
              className="rounded-2xl border border-blue-400/30 bg-blue-500/10 hover:bg-blue-500/15 px-4 py-2 text-sm text-white"
            >
              Resume Mission
            </a>
          )}
          <button
            onClick={() => clearMission()}
            className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/55 px-4 py-2 text-sm text-white/80"
          >
            Clear
          </button>
        </div>
      </div>

      <div className="px-6 py-5 grid gap-3">
        <div className="grid grid-cols-2 gap-3">
          <div className="rounded-2xl border border-white/10 bg-black/30 p-4">
            <div className="text-xs tracking-[0.3em] text-white/50">STEP INDEX</div>
            <div className="mt-1 text-2xl font-semibold text-white">{m.stepIndex}</div>
          </div>
          <div className="rounded-2xl border border-white/10 bg-black/30 p-4">
            <div className="text-xs tracking-[0.3em] text-white/50">COMPLETED</div>
            <div className="mt-1 text-2xl font-semibold text-white">{completedCount}</div>
          </div>
        </div>

        {m.notes ? (
          <div className="rounded-2xl border border-white/10 bg-black/30 p-4">
            <div className="text-xs tracking-[0.3em] text-white/50">OPERATOR NOTE</div>
            <div className="mt-2 text-sm text-white/75 whitespace-pre-wrap">{m.notes}</div>
          </div>
        ) : null}
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) Lesson ↔ HQ handshake wiring (MissionHandshake)
#     IMPORTANT: Your current LessonShell expects <MissionHandshake lesson={lesson} />
# ------------------------------------------------------------
cat > components/command/MissionHandshake.tsx <<'TSX'
"use client";

import React, { useEffect, useMemo, useState } from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

export default function MissionHandshake({ lesson }: { lesson: CanonLesson }) {
  const { state, startMission, touchMission, setStepIndex, toggleStepComplete, addMissionNote } =
    useMissionRuntime();

  const isThisMission = useMemo(() => {
    return (
      state.active?.lessonId === lesson.id &&
      state.active?.division === lesson.division
    );
  }, [state.active, lesson.id, lesson.division]);

  const [note, setNote] = useState("");

  useEffect(() => {
    // Start mission when lesson screen opens (if not already active)
    if (!state.active || !isThisMission) {
      startMission({ lessonId: lesson.id, division: lesson.division });
    } else {
      touchMission();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lesson.id, lesson.division]);

  useEffect(() => {
    if (isThisMission) touchMission();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isThisMission]);

  if (!state.active) return null;

  return (
    <div className="mt-6 rounded-3xl border border-white/10 bg-black/35 backdrop-blur-xl overflow-hidden">
      <div className="px-6 py-5 border-b border-white/10 flex items-start justify-between gap-4">
        <div>
          <div className="text-xs tracking-[0.3em] text-white/50">MISSION RUNTIME</div>
          <div className="mt-1 text-base font-semibold text-white">
            {state.active.lessonId} · {state.active.division.toUpperCase()}
          </div>
          <div className="mt-1 text-sm text-white/60">
            Step index: <span className="text-white">{state.active.stepIndex}</span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={() => setStepIndex(Math.max(0, state.active!.stepIndex - 1))}
            className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/55 px-4 py-2 text-sm text-white/80"
          >
            Prev
          </button>
          <button
            onClick={() => setStepIndex(state.active!.stepIndex + 1)}
            className="rounded-2xl border border-blue-400/30 bg-blue-500/10 hover:bg-blue-500/15 px-4 py-2 text-sm text-white"
          >
            Next
          </button>
          <button
            onClick={() => toggleStepComplete(state.active!.stepIndex)}
            className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/55 px-4 py-2 text-sm text-white/80"
          >
            Toggle Complete
          </button>
        </div>
      </div>

      <div className="px-6 py-5 grid gap-3">
        <div className="rounded-2xl border border-white/10 bg-black/30 p-4">
          <div className="text-xs tracking-[0.3em] text-white/50">GUARDIAN ANGEL NOTE</div>
          <div className="mt-2 flex gap-2">
            <input
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder="Drop a mission note for HQ…"
              className="w-full rounded-2xl border border-white/10 bg-black/50 px-4 py-2 text-sm text-white placeholder:text-white/30 outline-none"
            />
            <button
              onClick={() => {
                addMissionNote(note.trim());
                setNote("");
              }}
              className="rounded-2xl border border-blue-400/30 bg-blue-500/10 hover:bg-blue-500/15 px-4 py-2 text-sm text-white"
            >
              Save
            </button>
          </div>
          <div className="mt-2 text-xs text-white/50">
            This persists into HQ Active Mission Card. HQ becomes your “resume anywhere” layer.
          </div>
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 5) Fix LessonShell (your current TypeScript error)
#    - Your build error: MissionHandshake was being called with lessonId/division props.
#    - We enforce the correct prop: { lesson: CanonLesson }
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
"use client";

import React from "react";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import MissionHandshake from "@/components/command/MissionHandshake";

export default function LessonShell({ lesson, children }: { lesson: CanonLesson; children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-black text-white">
      <header className="border-b border-white/10 bg-black/60 backdrop-blur-xl">
        <div className="mx-auto max-w-6xl px-6 py-6">
          <div className="text-xs tracking-[0.35em] text-white/50">MISSION SCREEN</div>
          <div className="mt-2 text-2xl font-semibold">
            {lesson.id} — {lesson.title}
          </div>
          <div className="mt-1 text-sm text-white/60">
            Division: <span className="text-white">{lesson.division.toUpperCase()}</span>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-6 pb-16">
        <MissionHandshake lesson={lesson} />

        <div className="mt-8 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
          <div className="px-8 py-7 border-b border-white/10">
            <div className="text-xs tracking-[0.35em] text-white/50">MISSION CONTENT</div>
            <div className="mt-2 text-sm text-white/70">
              Lessons are execution screens. HQ is command. Guardian Angel supports runtime.
            </div>
          </div>
          <div className="px-8 py-7">{children}</div>
        </div>
      </main>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 6) HQ Page hard-orient: HQ is the app (supremacy)
# ------------------------------------------------------------
cat > app/hq/page.tsx <<'TSX'
"use client";

import React, { useEffect, useMemo, useState } from "react";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import { DEFAULT_UI, loadUi, saveUi } from "@/lib/uiStore";
import type { UiState } from "@/lib/uiTypes";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { canAccess } from "@/lib/access";

export default function HQPage() {
  const [ui, setUi] = useState<UiState>(DEFAULT_UI);

  useEffect(() => setUi(loadUi()), []);
  useEffect(() => saveUi(ui), [ui]);

  const all = useMemo(() => loadCanonLessons(), []);
  const visible = useMemo(() => {
    // “HQ posture filter” (ui.division) acts as current entitlement posture for now.
    return all.filter((l) => canAccess(ui.division, l.division));
  }, [all, ui.division]);

  const first = visible[0] ?? null;

  return (
    <div className="min-h-screen bg-black text-white">
      <header className="border-b border-white/10 bg-black/70 backdrop-blur-xl">
        <div className="mx-auto max-w-6xl px-6 py-8">
          <div className="text-xs tracking-[0.35em] text-white/50">OPERATOR HQ</div>
          <div className="mt-2 text-3xl font-semibold">North Star Command Layer</div>
          <div className="mt-1 text-sm text-white/60">
            HQ is the app. Lessons are execution screens. Divisions are posture filters.
          </div>

          <div className="mt-4 flex flex-wrap gap-2">
            {(["phoenix", "vanguard", "sentinel"] as const).map((d) => (
              <button
                key={d}
                onClick={() => setUi((p) => ({ ...p, division: d }))}
                className={[
                  "rounded-2xl px-4 py-2 text-sm border",
                  ui.division === d
                    ? "border-blue-400/40 bg-blue-500/10 text-white"
                    : "border-white/10 bg-black/40 text-white/70 hover:bg-black/55",
                ].join(" ")}
              >
                {d.toUpperCase()}
              </button>
            ))}
            <a
              href="/academy"
              className="rounded-2xl border border-white/10 bg-black/40 hover:bg-black/55 px-4 py-2 text-sm text-white/80"
            >
              Academy Directory
            </a>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-6xl px-6 py-10 grid gap-6">
        <ActiveMissionCard />

        <div className="rounded-3xl border border-white/10 bg-black/35 backdrop-blur-xl overflow-hidden">
          <div className="px-6 py-5 border-b border-white/10">
            <div className="text-xs tracking-[0.3em] text-white/50">GOLDEN PATH (PHOENIX)</div>
            <div className="mt-2 text-sm text-white/70">
              Phoenix is unrestricted. This is the end-to-end “start mission → runtime → resume from HQ” loop.
            </div>
          </div>

          <div className="px-6 py-6 grid gap-3">
            <ol className="list-decimal pl-6 text-sm text-white/75 space-y-2">
              <li>Set division to <span className="text-white">PHOENIX</span>.</li>
              <li>Open Academy Directory and start any mission.</li>
              <li>Mission Runtime initializes automatically on lesson screen.</li>
              <li>Return to HQ — Active Mission Card shows the live runtime.</li>
              <li>Hit <span className="text-white">Resume Mission</span> from HQ at any time.</li>
            </ol>

            {first ? (
              <a
                href={`/academy/${first.division}/${first.id}`}
                className="mt-2 inline-flex items-center justify-center rounded-2xl border border-blue-400/30 bg-blue-500/10 hover:bg-blue-500/15 px-5 py-3 text-sm text-white"
              >
                Start Suggested Mission: {first.id} — {first.title}
              </a>
            ) : (
              <div className="text-sm text-white/60">
                No visible lessons for current posture. (This should only happen if content is missing.)
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 7) Hard-lock CanonLesson (definitions only)
#    - EXACTLY ONE definition allowed in source (excluding commanders/.next/node_modules/.git)
# ------------------------------------------------------------
cat > commanders/commander_canon_lock_safe.sh <<'BASH2'
#!/usr/bin/env bash
set -euo pipefail

echo "🔒 CANON LOCK — SAFE MODE"
echo "📍 Repo: $(pwd)"
echo "🔎 Scanning for CanonLesson DEFINITIONS (not usage)..."

# find "export type CanonLesson" or "export interface CanonLesson" in real source files only
defs="$(grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next --exclude-dir=commanders \
  -E 'export (type|interface) CanonLesson' . || true)"

count="$(printf "%s" "$defs" | grep -c 'export ' || true)"

# If grep found nothing, count will be 0 (but grep -c on empty prints 0 and exits 1; handled by || true).
if [ "${count:-0}" -eq 0 ]; then
  echo "❌ ERROR: No CanonLesson definition found. There must be EXACTLY ONE."
  exit 1
fi

if [ "${count:-0}" -gt 1 ]; then
  echo "❌ ERROR: Multiple CanonLesson definitions detected!"
  echo
  printf "%s\n" "$defs"
  echo
  echo "🛑 Canon violation. There must be EXACTLY ONE CanonLesson."
  exit 1
fi

echo "✅ CanonLesson single definition confirmed."
BASH2
chmod +x commanders/commander_canon_lock_safe.sh

# ------------------------------------------------------------
# 8) Freeze system marker (so you know this is the spine)
# ------------------------------------------------------------
cat > .north_star.lock <<'TXT'
NEWTON COMMAND ACADEMY — NORTH STAR LOCK
HQ is the app.
Lessons are execution screens.
Divisions are posture filters.
Guardian Angel is mission support.
MissionRuntimeStore is single source of truth.
CanonLesson must remain single-definition.
TXT

# ------------------------------------------------------------
# 9) Build check (green)
# ------------------------------------------------------------
echo "🧪 CANON CHECK"
./commanders/commander_canon_lock_safe.sh

echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ FULL SEND COMPLETE — NORTH STAR LOCKED"
echo "🚀 Run: npm run dev"
