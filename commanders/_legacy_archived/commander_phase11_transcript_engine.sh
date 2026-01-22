#!/usr/bin/env bash
set -euo pipefail

echo "📜 PHASE 11 — TRANSCRIPT & SERVICE RECORD ENGINE"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 1) Transcript Canon (SINGLE SOURCE)
# ------------------------------------------------------------
mkdir -p lib

cat > lib/transcriptCanon.ts <<'TS'
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type TranscriptEntry = {
  lessonId: string;
  title: string;
  division: Division;
  completedAt: string;
  durationMinutes: number;
};

export type Transcript = {
  learnerId: string;
  generatedAt: string;
  entries: TranscriptEntry[];
};
TS

# ------------------------------------------------------------
# 2) Transcript Store (localStorage, deterministic)
# ------------------------------------------------------------
cat > lib/transcriptStore.ts <<'TS'
import type { Transcript, TranscriptEntry } from "./transcriptCanon";

const KEY = "nca:transcript";

function load(): Transcript {
  if (typeof window === "undefined") {
    return { learnerId: "local", generatedAt: "", entries: [] };
  }

  const raw = localStorage.getItem(KEY);
  if (!raw) {
    return {
      learnerId: "local",
      generatedAt: new Date().toISOString(),
      entries: [],
    };
  }

  try {
    return JSON.parse(raw);
  } catch {
    return {
      learnerId: "local",
      generatedAt: new Date().toISOString(),
      entries: [],
    };
  }
}

function save(t: Transcript) {
  localStorage.setItem(KEY, JSON.stringify(t));
}

export function recordLesson(entry: TranscriptEntry) {
  const t = load();

  // Prevent duplicates
  if (t.entries.find(e => e.lessonId === entry.lessonId)) return;

  t.entries.push(entry);
  save(t);
}

export function getTranscript(): Transcript {
  return load();
}
TS

# ------------------------------------------------------------
# 3) Hook lesson completion into Guardian flow
# ------------------------------------------------------------
cat > components/command/CompleteLessonButton.tsx <<'TSX'
"use client";

import { recordLesson } from "@/lib/transcriptStore";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lesson: CanonLesson;
};

export default function CompleteLessonButton({ lesson }: Props) {
  function onComplete() {
    recordLesson({
      lessonId: lesson.id,
      title: lesson.title,
      division: lesson.division,
      completedAt: new Date().toISOString(),
      durationMinutes: lesson.duration_minutes,
    });

    alert("✅ Lesson recorded in service transcript.");
  }

  return (
    <button
      onClick={onComplete}
      className="mt-6 w-full rounded-xl border border-emerald-400/30 bg-emerald-500/10 px-4 py-3 text-emerald-300 hover:bg-emerald-500/20"
    >
      Complete Mission & Log Service Record
    </button>
  );
}
TSX

# ------------------------------------------------------------
# 4) Inject completion button into LessonShell
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
import GuardianAngelPanel from "@/components/guardian/GuardianAngelPanel";
import AccessGate from "@/components/command/AccessGate";
import CompleteLessonButton from "@/components/command/CompleteLessonButton";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lesson: CanonLesson;
};

export default function LessonShell({ lesson }: Props) {
  return (
    <AccessGate
      minRank={
        lesson.difficulty === "elite"
          ? "sentinel"
          : lesson.difficulty === "advanced"
          ? "veteran"
          : lesson.difficulty === "intermediate"
          ? "specialist"
          : "recruit"
      }
      minClearance={
        lesson.division === "sentinel"
          ? "classified"
          : lesson.division === "vanguard"
          ? "restricted"
          : "public"
      }
    >
      <main className="mx-auto max-w-6xl px-6 pb-16">
        <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
          <div className="px-8 py-7 border-b border-white/10">
            <div className="text-xs tracking-[0.28em] text-white/50">
              NEWTON COMMAND ACADEMY
            </div>
            <h1 className="text-3xl font-semibold text-white mt-3">
              {lesson.title}
            </h1>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-8">
            <div className="lg:col-span-2 space-y-6">
              <section className="rounded-2xl border border-white/10 bg-black/20 px-6 py-5 text-white/80">
                {lesson.concept}
              </section>

              <section className="rounded-2xl border border-white/10 bg-black/20 px-6 py-5 whitespace-pre-line text-white/80">
                {lesson.walkthrough}
              </section>

              <CompleteLessonButton lesson={lesson} />
            </div>

            <div>
              <GuardianAngelPanel
                lessonId={lesson.id}
                division={lesson.division}
                steps={lesson.steps ?? []}
              />
            </div>
          </div>
        </div>
      </main>
    </AccessGate>
  );
}
TSX

# ------------------------------------------------------------
# 5) HQ Transcript Page
# ------------------------------------------------------------
mkdir -p app/hq/transcript

cat > app/hq/transcript/page.tsx <<'TSX'
"use client";

import { getTranscript } from "@/lib/transcriptStore";

export default function TranscriptPage() {
  const t = getTranscript();

  return (
    <main className="mx-auto max-w-5xl px-6 py-16">
      <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl p-8">
        <div className="text-xs tracking-[0.3em] text-white/50">
          SERVICE TRANSCRIPT
        </div>

        <h1 className="text-3xl text-white mt-4">Operational Record</h1>

        <div className="mt-8 space-y-4">
          {t.entries.length === 0 && (
            <div className="text-white/60">No completed missions yet.</div>
          )}

          {t.entries.map((e, i) => (
            <div
              key={i}
              className="rounded-xl border border-white/10 bg-black/20 p-5"
            >
              <div className="text-white font-medium">{e.title}</div>
              <div className="text-sm text-white/50 mt-1">
                {e.division.toUpperCase()} • {e.durationMinutes} mins •{" "}
                {new Date(e.completedAt).toLocaleString()}
              </div>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 6) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 11 COMPLETE — TRANSCRIPT LIVE"
echo "🚀 Visit: /hq/transcript"
