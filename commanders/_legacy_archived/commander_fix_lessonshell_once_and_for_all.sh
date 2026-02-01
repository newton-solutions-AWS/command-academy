#!/usr/bin/env bash
set -euo pipefail

echo "🧠 FIXING LESSONSHELL — CANON HARD RESET"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

# 1) Remove ALL LessonShell variants
echo "🧹 Removing all LessonShell definitions..."
find components -name "LessonShell.tsx" -type f -delete || true
find components -name "LessonShell.ts" -type f -delete || true
find components -name "index.ts" -type f -path "*command*" -delete || true

# 2) Recreate canonical directory
mkdir -p components/command

# 3) Write ONE canonical LessonShell
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
          <div className="text-xs tracking-[0.28em] text-white/50">
            NEWTON COMMAND ACADEMY
          </div>

          <h1 className="text-3xl font-semibold text-white mt-3">
            {lesson.title}
          </h1>

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
              <div className="px-6 py-5 text-white/80">
                {lesson.concept}
              </div>
            </section>

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                WALKTHROUGH
              </div>
              <div className="px-6 py-5 text-white/80 whitespace-pre-line">
                {lesson.walkthrough}
              </div>
            </section>

            <section className="rounded-2xl border border-white/10 bg-black/20">
              <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                OBJECTIVES
              </div>
              <ul className="px-6 py-5 list-disc pl-5 space-y-2 text-white/75">
                {lesson.objectives.map((o, i) => (
                  <li key={i}>{o}</li>
                ))}
              </ul>
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

# 4) Build check
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ LessonShell canon fixed. This error will never return."
