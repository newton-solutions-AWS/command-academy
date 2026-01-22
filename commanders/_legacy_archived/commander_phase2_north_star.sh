#!/usr/bin/env bash
set -euo pipefail

echo "🧭 PHASE 2 — NORTH STAR (Guardian Angel + Mission Shell)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p components/guardian
mkdir -p components/command
mkdir -p lib
mkdir -p commanders

# ------------------------------------------------------------
# 1) Guardian Angel client panel (tracks steps per lessonId)
# ------------------------------------------------------------
cat > components/guardian/GuardianAngelPanel.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import { getMissionState, toggleStepComplete, resetMission } from "@/lib/missionStore";

type Props = {
  lessonId: string;
  division: "phoenix" | "vanguard" | "sentinel";
  steps: string[];
};

export default function GuardianAngelPanel({ lessonId, division, steps }: Props) {
  const storageKey = useMemo(() => `${division}:${lessonId}`, [division, lessonId]);

  const [completed, setCompleted] = useState<Record<number, boolean>>({});
  const [open, setOpen] = useState(true);

  useEffect(() => {
    const state = getMissionState(storageKey);
    setCompleted(state.completedSteps ?? {});
    setOpen(state.panelOpen ?? true);
  }, [storageKey]);

  const doneCount = Object.values(completed).filter(Boolean).length;
  const total = steps.length || 1;
  const pct = Math.round((doneCount / total) * 100);

  function onToggleStep(i: number) {
    const next = toggleStepComplete(storageKey, i);
    setCompleted(next.completedSteps ?? {});
  }

  function onReset() {
    const next = resetMission(storageKey);
    setCompleted(next.completedSteps ?? {});
  }

  function onTogglePanel() {
    const state = getMissionState(storageKey);
    const nextOpen = !state.panelOpen;
    localStorage.setItem(`nca:mission:${storageKey}`, JSON.stringify({ ...state, panelOpen: nextOpen }));
    setOpen(nextOpen);
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]">
      <div className="flex items-center justify-between gap-3 px-5 py-4 border-b border-white/10">
        <div>
          <div className="text-xs tracking-[0.28em] text-white/50">GUARDIAN ANGEL</div>
          <div className="text-sm text-white/80 mt-1">
            Step-by-step mission guidance • <span className="text-white/60">{division.toUpperCase()}</span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-xs text-white/60 tabular-nums">{doneCount}/{steps.length} • {pct}%</div>
          <button
            onClick={onTogglePanel}
            className="px-3 py-1.5 text-xs rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/80"
          >
            {open ? "Collapse" : "Expand"}
          </button>
        </div>
      </div>

      {open && (
        <div className="p-5">
          <div className="flex items-center justify-between gap-3 mb-4">
            <div className="text-sm text-white/70">
              Don’t rush. Complete the steps in order. If you stall, hit reset and re-run clean.
            </div>
            <button
              onClick={onReset}
              className="px-3 py-1.5 text-xs rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/80"
            >
              Reset
            </button>
          </div>

          <ol className="space-y-2">
            {steps.map((s, i) => {
              const isDone = !!completed[i];
              return (
                <li
                  key={i}
                  className="flex items-start gap-3 rounded-xl border border-white/10 bg-white/5 hover:bg-white/7 px-4 py-3"
                >
                  <button
                    onClick={() => onToggleStep(i)}
                    className={[
                      "mt-0.5 h-5 w-5 rounded-md border flex items-center justify-center",
                      isDone ? "border-emerald-400/40 bg-emerald-500/10" : "border-white/20 bg-black/30",
                    ].join(" ")}
                    aria-label={isDone ? "Mark incomplete" : "Mark complete"}
                    title={isDone ? "Mark incomplete" : "Mark complete"}
                  >
                    {isDone ? <span className="text-emerald-300 text-xs">✓</span> : <span className="text-white/30 text-xs">•</span>}
                  </button>

                  <div className="flex-1">
                    <div className="text-xs tracking-[0.22em] text-white/40">STEP {String(i + 1).padStart(2, "0")}</div>
                    <div className={["text-sm mt-1", isDone ? "text-white/85" : "text-white/70"].join(" ")}>
                      {s}
                    </div>
                  </div>
                </li>
              );
            })}
          </ol>

          <div className="mt-5 rounded-xl border border-white/10 bg-black/30 p-4">
            <div className="text-xs tracking-[0.24em] text-white/45">GUARDIAN PROMPT</div>
            <div className="text-sm text-white/70 mt-2">
              If you want me to coach in real-time, paste your current step number + what you see on-screen.
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 2) Mission state store (localStorage)
# ------------------------------------------------------------
cat > lib/missionStore.ts <<'TS'
export type MissionState = {
  completedSteps: Record<number, boolean>;
  panelOpen: boolean;
};

const prefix = "nca:mission:";

function safeParse(raw: string | null): MissionState | null {
  if (!raw) return null;
  try {
    const v = JSON.parse(raw);
    if (!v || typeof v !== "object") return null;
    return {
      completedSteps: (v.completedSteps ?? {}) as Record<number, boolean>,
      panelOpen: typeof v.panelOpen === "boolean" ? v.panelOpen : true,
    };
  } catch {
    return null;
  }
}

export function getMissionState(key: string): MissionState {
  if (typeof window === "undefined") {
    return { completedSteps: {}, panelOpen: true };
  }
  const state = safeParse(localStorage.getItem(prefix + key));
  return state ?? { completedSteps: {}, panelOpen: true };
}

export function toggleStepComplete(key: string, stepIndex: number): MissionState {
  const state = getMissionState(key);
  const next: MissionState = {
    ...state,
    completedSteps: { ...state.completedSteps, [stepIndex]: !state.completedSteps[stepIndex] },
  };
  localStorage.setItem(prefix + key, JSON.stringify(next));
  return next;
}

export function resetMission(key: string): MissionState {
  const next: MissionState = { completedSteps: {}, panelOpen: true };
  if (typeof window !== "undefined") {
    localStorage.setItem(prefix + key, JSON.stringify(next));
  }
  return next;
}
TS

# ------------------------------------------------------------
# 3) Canon types (optional steps + duration)
# ------------------------------------------------------------
mkdir -p cert_intel/intake/lib

cat > cert_intel/intake/lib/canonTypes.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";
export type Difficulty = "foundation" | "intermediate" | "advanced" | "elite";

export type CanonLesson = {
  id: string;
  title: string;
  division: Division;
  difficulty: Difficulty;

  // North Star content blocks
  concept: string;
  walkthrough: string;
  objectives: string[];

  // UI metadata
  duration_minutes: number;

  // Optional: mission steps (if not present we derive from walkthrough)
  steps?: string[];
};
TS

# ------------------------------------------------------------
# 4) Lesson loader — guarantees steps exist + provides loadLessonById(id)
#     (DO NOT change your routing contracts again)
# ------------------------------------------------------------
cat > cert_intel/intake/lib/lessonloader.ts <<'TS'
import type { CanonLesson, Division } from "./canonTypes";

function deriveSteps(lesson: CanonLesson): string[] {
  // If explicit steps exist, use them.
  if (lesson.steps && Array.isArray(lesson.steps) && lesson.steps.length > 0) return lesson.steps;

  // Otherwise derive from walkthrough lines.
  const lines = (lesson.walkthrough || "")
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);

  // If numbered steps exist, prefer them. Otherwise fallback.
  const numbered = lines.filter((l) => /^\d+\)/.test(l) || /^\d+\./.test(l));
  const base = numbered.length ? numbered : lines;

  const trimmed = base.slice(0, 12); // keep it tight
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
        "Understand Guardian Angel step tracking",
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
# 5) Shared lesson shell (North Star UI consistency)
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
import GuardianAngelPanel from "@/components/guardian/GuardianAngelPanel";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lesson: CanonLesson;
};

export default function LessonShell({ lesson }: Props) {
  return (
    <main className="mx-auto max-w-6xl px-6 pb-16">
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
              <div className="px-6 py-5 text-white/80 leading-relaxed whitespace-pre-line">
                {lesson.walkthrough}
              </div>
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
            <GuardianAngelPanel
              lessonId={lesson.id}
              division={lesson.division}
              steps={lesson.steps ?? []}
            />
          </div>
        </div>
      </div>
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 6) Rewrite the 3 lesson route pages to use LessonShell
# ------------------------------------------------------------
mkdir -p app/academy/phoenix/[lessonId]
mkdir -p app/academy/vanguard/[lessonId]
mkdir -p app/academy/[division]/[lessonId]

cat > app/academy/phoenix/[lessonId]/page.tsx <<'TSX'
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import LessonShell from "@/components/command/LessonShell";

type PageProps = { params: { lessonId: string } };

export default function PhoenixLessonPage({ params }: PageProps) {
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

cat > app/academy/vanguard/[lessonId]/page.tsx <<'TSX'
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import LessonShell from "@/components/command/LessonShell";

type PageProps = { params: { lessonId: string } };

export default function VanguardLessonPage({ params }: PageProps) {
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

cat > app/academy/[division]/[lessonId]/page.tsx <<'TSX'
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import LessonShell from "@/components/command/LessonShell";

type PageProps = { params: { division: string; lessonId: string } };

export default function DivisionLessonPage({ params }: PageProps) {
  // We still keep this dynamic route for future expansion.
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

# ------------------------------------------------------------
# 7) Root wrapper scripts so you never “lose” commanders again
# ------------------------------------------------------------
cat > commander_lock_green.sh <<'BASH2'
#!/usr/bin/env bash
set -euo pipefail
exec ./commanders/commander_lock_green.sh "$@"
BASH2
chmod +x commander_lock_green.sh || true

cat > commander_verify.sh <<'BASH3'
#!/usr/bin/env bash
set -euo pipefail
exec ./commanders/commander_verify.sh "$@"
BASH3
chmod +x commander_verify.sh || true

echo "✅ Phase 2 files written."

echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "🚀 DONE. Run: npm run dev"
