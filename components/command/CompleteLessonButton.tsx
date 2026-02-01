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
