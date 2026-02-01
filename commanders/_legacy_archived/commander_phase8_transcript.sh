#!/usr/bin/env bash
set -euo pipefail

echo "🧾 PHASE 8 — TRANSCRIPT & SERVICE RECORD"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p lib/transcript
mkdir -p app/hq/transcript
mkdir -p components/transcript

# ------------------------------------------------------------
# 1) Transcript Types
# ------------------------------------------------------------
cat > lib/transcript/types.ts <<'TS'
import type { Division, Difficulty } from "@/cert_intel/intake/lib/canonTypes";

export type TranscriptEntry = {
  lessonId: string;
  title: string;
  division: Division;
  difficulty: Difficulty;
  duration_minutes: number;

  startedAt: number;
  finishedAt: number;
  verdict: "PASS" | "FAIL" | "RETAKE";
};

export type Transcript = {
  learnerId: string;
  generatedAt: number;
  entries: TranscriptEntry[];
};
TS

# ------------------------------------------------------------
# 2) Transcript Builder (reads Black Box attempts)
# ------------------------------------------------------------
cat > lib/transcript/buildTranscript.ts <<'TS'
import type { Transcript, TranscriptEntry } from "./types";
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";

type BlackBoxAttempt = {
  lessonId: string;
  startedAt: number;
  finishedAt?: number;
  verdict?: "PASS" | "FAIL" | "RETAKE";
};

const PREFIX = "nca:blackbox:";

export function buildTranscript(learnerId: string): Transcript {
  if (typeof window === "undefined") {
    throw new Error("Transcript build must run client-side");
  }

  const entries: TranscriptEntry[] = [];

  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (!key || !key.startsWith(PREFIX)) continue;

    const raw = localStorage.getItem(key);
    if (!raw) continue;

    let attempt: BlackBoxAttempt;
    try {
      attempt = JSON.parse(raw);
    } catch {
      continue;
    }

    if (!attempt.verdict || !attempt.finishedAt) continue;

    const lesson = loadLessonById(attempt.lessonId);
    if (!lesson) continue;

    entries.push({
      lessonId: lesson.id,
      title: lesson.title,
      division: lesson.division,
      difficulty: lesson.difficulty,
      duration_minutes: lesson.duration_minutes,
      startedAt: attempt.startedAt,
      finishedAt: attempt.finishedAt,
      verdict: attempt.verdict,
    });
  }

  return {
    learnerId,
    generatedAt: Date.now(),
    entries: entries.sort((a, b) => a.finishedAt - b.finishedAt),
  };
}
TS

# ------------------------------------------------------------
# 3) CV Formatter
# ------------------------------------------------------------
cat > lib/transcript/formatCV.ts <<'TS'
import type { Transcript } from "./types";

export function formatForCV(t: Transcript): string[] {
  return t.entries
    .filter((e) => e.verdict === "PASS")
    .map(
      (e) =>
        `Completed ${e.title} (${e.division.toUpperCase()}, ${e.difficulty}) — ${e.duration_minutes} mins`
    );
}
TS

# ------------------------------------------------------------
# 4) Transcript Viewer (HQ)
# ------------------------------------------------------------
cat > components/transcript/TranscriptPanel.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import { buildTranscript } from "@/lib/transcript/buildTranscript";
import { formatForCV } from "@/lib/transcript/formatCV";
import type { Transcript } from "@/lib/transcript/types";

type Props = {
  learnerId: string;
};

export default function TranscriptPanel({ learnerId }: Props) {
  const [transcript, setTranscript] = useState<Transcript | null>(null);

  useEffect(() => {
    try {
      setTranscript(buildTranscript(learnerId));
    } catch {}
  }, [learnerId]);

  if (!transcript) {
    return (
      <div className="text-white/60">No transcript available.</div>
    );
  }

  const cvLines = formatForCV(transcript);

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 p-6 space-y-6">
      <div>
        <div className="text-xs tracking-[0.3em] text-white/50">
          SERVICE RECORD
        </div>
        <div className="text-sm text-white/70 mt-1">
          Learner ID: {transcript.learnerId}
        </div>
      </div>

      <div className="space-y-2">
        {transcript.entries.map((e, i) => (
          <div
            key={i}
            className="flex justify-between items-center rounded-xl border border-white/10 bg-black/30 px-4 py-3"
          >
            <div>
              <div className="text-sm text-white/85">{e.title}</div>
              <div className="text-xs text-white/50">
                {e.division.toUpperCase()} • {e.difficulty} • {e.duration_minutes} mins
              </div>
            </div>
            <div
              className={[
                "text-sm font-semibold",
                e.verdict === "PASS"
                  ? "text-emerald-400"
                  : e.verdict === "RETAKE"
                  ? "text-amber-400"
                  : "text-red-400",
              ].join(" ")}
            >
              {e.verdict}
            </div>
          </div>
        ))}
      </div>

      <div className="rounded-xl border border-white/10 bg-black/30 p-4">
        <div className="text-xs tracking-[0.28em] text-white/50">
          CV EXPORT (PASSED ONLY)
        </div>
        <ul className="mt-3 list-disc pl-5 space-y-1 text-sm text-white/75">
          {cvLines.length ? cvLines.map((l, i) => <li key={i}>{l}</li>) : (
            <li>No passed certifications yet.</li>
          )}
        </ul>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 5) HQ Transcript Page
# ------------------------------------------------------------
cat > app/hq/transcript/page.tsx <<'TSX'
import TranscriptPanel from "@/components/transcript/TranscriptPanel";

export default function TranscriptPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-16">
      <TranscriptPanel learnerId="FOUNDER-0001" />
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

echo "✅ PHASE 8 COMPLETE — TRANSCRIPT ONLINE"
echo "🚀 Visit: /hq/transcript"
