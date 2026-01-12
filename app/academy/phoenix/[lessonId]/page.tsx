import { notFound } from "next/navigation";
import { loadLessons } from "@/cert_intel/intake/lib/lessonloader";

export const dynamic = "force-dynamic";

type Props = {
  params: { lessonId: string };
};

export default function PhoenixLessonPage({ params }: Props) {
  const lessons = loadLessons({
    canon: "phoenix-protocol-secure-cloud-operator",
    version: "v2",
  });

  const lesson = lessons.find((l) => l.id === params.lessonId);

  if (!lesson) notFound();

  return (
    <div className="mx-auto max-w-4xl px-6 py-12">
      <p className="text-xs uppercase tracking-[0.4em] text-white/50">
        Phoenix Division · Canon Lesson
      </p>

      <h1 className="mt-3 text-3xl font-semibold">
        {lesson.title ?? lesson.id}
      </h1>

      {lesson.description && (
        <p className="mt-4 text-white/70">{lesson.description}</p>
      )}

      <pre className="mt-8 rounded-xl border border-white/10 bg-black/50 p-4 text-sm text-white/80 overflow-auto">
        {JSON.stringify(lesson, null, 2)}
      </pre>
    </div>
  );
}