import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { notFound } from "next/navigation";

export const dynamic = "force-dynamic";

type Props = {
  params: { lessonId: string };
};

export default function VanguardLessonPage({ params }: Props) {
  const lessons = loadCanonLessons({
    canon: "vanguard-protocol-advanced-architecture",
    version: "v1",
  });

  const lesson = lessons.find((l) => l.id === params.lessonId);

  if (!lesson) return notFound();

  return (
    <div className="mx-auto max-w-4xl px-6 py-14">
      <p className="text-xs uppercase tracking-[0.35em] text-white/50">
        Vanguard Division · Canon Module
      </p>

      <h1 className="mt-4 text-3xl font-semibold leading-tight">
        {lesson.title}
      </h1>

      {lesson.description && (
        <p className="mt-4 text-white/70">
          {lesson.description}
        </p>
      )}

      <div className="mt-10 rounded-xl border border-white/10 bg-black/40 p-6 text-xs text-white/60">
        <pre className="overflow-x-auto">
          {JSON.stringify(lesson, null, 2)}
        </pre>
      </div>
    </div>
  );
}