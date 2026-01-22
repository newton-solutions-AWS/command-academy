#!/usr/bin/env bash
set -euo pipefail

echo "🧨 PHASE 7 — BLACK BOX MODE (EXAM DOCTRINE)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p lib/blackbox
mkdir -p components/blackbox
mkdir -p app/academy/blackbox/[lessonId]

# ------------------------------------------------------------
# 1) Black Box State Store (local, auditable)
# ------------------------------------------------------------
cat > lib/blackbox/blackBoxStore.ts <<'TS'
export type BlackBoxAttempt = {
  lessonId: string;
  startedAt: number;
  finishedAt?: number;
  objectivesMet: boolean[];
  verdict?: "PASS" | "FAIL" | "RETAKE";
};

const prefix = "nca:blackbox:";

export function startAttempt(lessonId: string, objectivesCount: number): BlackBoxAttempt {
  const attempt: BlackBoxAttempt = {
    lessonId,
    startedAt: Date.now(),
    objectivesMet: Array(objectivesCount).fill(false),
  };
  localStorage.setItem(prefix + lessonId, JSON.stringify(attempt));
  return attempt;
}

export function loadAttempt(lessonId: string): BlackBoxAttempt | null {
  const raw = localStorage.getItem(prefix + lessonId);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as BlackBoxAttempt;
  } catch {
    return null;
  }
}

export function markObjective(
  lessonId: string,
  index: number,
  met: boolean
): BlackBoxAttempt {
  const attempt = loadAttempt(lessonId);
  if (!attempt) throw new Error("No attempt in progress");
  attempt.objectivesMet[index] = met;
  localStorage.setItem(prefix + lessonId, JSON.stringify(attempt));
  return attempt;
}

export function finalizeAttempt(lessonId: string): BlackBoxAttempt {
  const attempt = loadAttempt(lessonId);
  if (!attempt) throw new Error("No attempt in progress");

  const passed = attempt.objectivesMet.every(Boolean);
  attempt.finishedAt = Date.now();
  attempt.verdict = passed ? "PASS" : "RETAKE";

  localStorage.setItem(prefix + lessonId, JSON.stringify(attempt));
  return attempt;
}
TS

# ------------------------------------------------------------
# 2) Black Box UI (No coaching, no hints)
# ------------------------------------------------------------
cat > components/blackbox/BlackBoxPanel.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import {
  startAttempt,
  loadAttempt,
  markObjective,
  finalizeAttempt,
} from "@/lib/blackbox/blackBoxStore";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lesson: CanonLesson;
};

export default function BlackBoxPanel({ lesson }: Props) {
  const [attempt, setAttempt] = useState(() =>
    typeof window !== "undefined"
      ? loadAttempt(lesson.id)
      : null
  );

  useEffect(() => {
    if (!attempt) {
      setAttempt(startAttempt(lesson.id, lesson.objectives.length));
    }
  }, [attempt, lesson]);

  if (!attempt) return null;

  function toggleObjective(i: number) {
    setAttempt(markObjective(lesson.id, i, !attempt.objectivesMet[i]));
  }

  function finish() {
    setAttempt(finalizeAttempt(lesson.id));
  }

  return (
    <div className="rounded-2xl border border-red-500/30 bg-black/50">
      <div className="px-6 py-4 border-b border-red-500/20">
        <div className="text-xs tracking-[0.32em] text-red-400">
          BLACK BOX MODE
        </div>
        <div className="text-sm text-white/70 mt-1">
          No guidance. Objectives only. This is an evaluation.
        </div>
      </div>

      <div className="p-6 space-y-3">
        {lesson.objectives.map((o, i) => (
          <label
            key={i}
            className="flex gap-3 items-start rounded-xl border border-white/10 bg-black/40 px-4 py-3"
          >
            <input
              type="checkbox"
              checked={attempt.objectivesMet[i]}
              onChange={() => toggleObjective(i)}
              className="mt-1"
            />
            <div className="text-sm text-white/80">{o}</div>
          </label>
        ))}

        {!attempt.verdict && (
          <button
            onClick={finish}
            className="mt-4 w-full rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-red-300 hover:bg-red-500/20"
          >
            FINALISE ATTEMPT
          </button>
        )}

        {attempt.verdict && (
          <div className="mt-4 rounded-xl border border-white/10 bg-black/60 px-4 py-4 text-center">
            <div className="text-xs tracking-[0.3em] text-white/50">
              VERDICT
            </div>
            <div
              className={[
                "mt-2 text-2xl font-semibold",
                attempt.verdict === "PASS"
                  ? "text-emerald-400"
                  : "text-amber-400",
              ].join(" ")}
            >
              {attempt.verdict}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 3) Black Box Lesson Route
# ------------------------------------------------------------
cat > app/academy/blackbox/[lessonId]/page.tsx <<'TSX'
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import BlackBoxPanel from "@/components/blackbox/BlackBoxPanel";

type PageProps = { params: { lessonId: string } };

export default function BlackBoxLessonPage({ params }: PageProps) {
  const lesson = loadLessonById(params.lessonId);

  if (!lesson) {
    return (
      <main className="mx-auto max-w-5xl px-6 py-16 text-red-300">
        Lesson not found.
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-5xl px-6 py-16 space-y-6">
      <div className="rounded-2xl border border-white/10 bg-black/30 px-6 py-5">
        <div className="text-xs tracking-[0.28em] text-white/50">
          CERTIFICATION ATTEMPT
        </div>
        <h1 className="mt-2 text-2xl font-semibold text-white">
          {lesson.title}
        </h1>
      </div>

      <BlackBoxPanel lesson={lesson} />
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 4) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 7 COMPLETE — BLACK BOX MODE LIVE"
echo "🚀 Run: npm run dev"
