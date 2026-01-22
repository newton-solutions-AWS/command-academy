// components/command/LessonShell.tsx
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

export default function LessonShell({
  lesson,
}: {
  lesson: CanonLesson;
}) {
  return (
    <div className="relative p-6 max-w-4xl mx-auto">
      <h1 className="text-3xl font-semibold text-white">
        {lesson.title}
      </h1>

      <p className="text-white/60 mt-2">
        {lesson.concept}
      </p>

      <div className="mt-6 space-y-4">
        <div>
          <div className="text-xs tracking-widest text-white/40">
            OBJECTIVES
          </div>
          <ul className="mt-2 list-disc list-inside text-white/80">
            {lesson.objectives.map((o) => (
              <li key={o}>{o}</li>
            ))}
          </ul>
        </div>

        <div>
          <div className="text-xs tracking-widest text-white/40">
            WALKTHROUGH
          </div>
          <p className="mt-2 text-white/80">
            {lesson.walkthrough}
          </p>
        </div>

        <div>
          <div className="text-xs tracking-widest text-white/40">
            STEPS
          </div>
          <ol className="mt-2 list-decimal list-inside text-white/80">
            {lesson.steps.map((s) => (
              <li key={s}>{s}</li>
            ))}
          </ol>
        </div>
      </div>
    </div>
  );
}