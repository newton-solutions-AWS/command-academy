#!/usr/bin/env bash
set -euo pipefail

echo "🧭 PHASE 4 — PROGRESSION & GATING"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p lib/progression
mkdir -p components/deck

# ------------------------------------------------------------
# 1) Progression Store (localStorage, per division)
# ------------------------------------------------------------
cat > lib/progression/progressStore.ts <<'TS'
export type LessonProgress = {
  completed: boolean;
  completedAt?: string;
};

export type DivisionProgress = {
  [lessonId: string]: LessonProgress;
};

const prefix = "nca:progress:";

function safeParse(raw: string | null): DivisionProgress {
  if (!raw) return {};
  try {
    return JSON.parse(raw) ?? {};
  } catch {
    return {};
  }
}

export function getDivisionProgress(division: string): DivisionProgress {
  if (typeof window === "undefined") return {};
  return safeParse(localStorage.getItem(prefix + division));
}

export function markLessonComplete(division: string, lessonId: string): DivisionProgress {
  const progress = getDivisionProgress(division);
  const next: DivisionProgress = {
    ...progress,
    [lessonId]: {
      completed: true,
      completedAt: new Date().toISOString(),
    },
  };
  localStorage.setItem(prefix + division, JSON.stringify(next));
  return next;
}

export function isLessonComplete(
  division: string,
  lessonId: string
): boolean {
  const progress = getDivisionProgress(division);
  return !!progress[lessonId]?.completed;
}
TS

# ------------------------------------------------------------
# 2) Mission Order Helper (canon sequence)
# ------------------------------------------------------------
cat > lib/progression/missionOrder.ts <<'TS'
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

export function isUnlocked(
  lessons: CanonLesson[],
  index: number,
  isComplete: (id: string) => boolean
): boolean {
  if (index === 0) return true;
  const prev = lessons[index - 1];
  return isComplete(prev.id);
}
TS

# ------------------------------------------------------------
# 3) Mission Deck Card (Locked / Active / Complete)
# ------------------------------------------------------------
cat > components/deck/MissionCard.tsx <<'TSX'
"use client";

import Link from "next/link";
import clsx from "clsx";

type Props = {
  id: string;
  title: string;
  href: string;
  state: "locked" | "active" | "complete";
};

export default function MissionCard({ id, title, href, state }: Props) {
  return (
    <div
      className={clsx(
        "rounded-2xl border p-5 backdrop-blur-xl transition",
        state === "locked" &&
          "border-white/5 bg-black/20 opacity-40",
        state === "active" &&
          "border-blue-400/40 bg-blue-500/10 shadow-[0_0_40px_rgba(59,130,246,0.25)]",
        state === "complete" &&
          "border-emerald-400/40 bg-emerald-500/10"
      )}
    >
      <div className="text-xs tracking-[0.28em] text-white/50">
        {state.toUpperCase()}
      </div>

      <div className="mt-2 text-lg text-white">{title}</div>

      <div className="mt-4">
        {state === "locked" ? (
          <span className="text-sm text-white/40">
            Complete previous mission to unlock
          </span>
        ) : (
          <Link
            href={href}
            className="inline-flex items-center rounded-full px-4 py-2 text-sm border border-white/10 bg-white/5 hover:bg-white/10 text-white"
          >
            {state === "complete" ? "Review Mission" : "Enter Mission"}
          </Link>
        )}
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) Wire Guardian Angel completion → progression
# ------------------------------------------------------------
cat > lib/progression/completeLesson.ts <<'TS'
import { markLessonComplete } from "./progressStore";

export function completeLesson(
  division: string,
  lessonId: string
) {
  return markLessonComplete(division, lessonId);
}
TS

# ------------------------------------------------------------
# 5) Patch LessonShell to expose completion button
# ------------------------------------------------------------
cat > components/command/LessonCompletionBar.tsx <<'TSX'
"use client";

import { completeLesson } from "@/lib/progression/completeLesson";

type Props = {
  division: string;
  lessonId: string;
};

export default function LessonCompletionBar({ division, lessonId }: Props) {
  function onComplete() {
    completeLesson(division, lessonId);
    alert("Mission complete. Return to HQ.");
  }

  return (
    <div className="mt-8 flex justify-end">
      <button
        onClick={onComplete}
        className="rounded-full px-6 py-3 text-sm border border-emerald-400/40 bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-300"
      >
        Complete Mission
      </button>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 6) Inject completion bar into LessonShell
# ------------------------------------------------------------
sed -i '' '/<\/main>/i\
\
    <LessonCompletionBar division={lesson.division} lessonId={lesson.id} />\
' components/command/LessonShell.tsx

sed -i '' '1i\
import LessonCompletionBar from "@/components/command/LessonCompletionBar";\
' components/command/LessonShell.tsx

# ------------------------------------------------------------
# 7) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 4 COMPLETE — PROGRESSION LIVE"
echo "🚀 Run: npm run dev"
