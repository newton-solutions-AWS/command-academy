import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

interface Props {
  params: { lessonId: string };
}

export default function PhoenixLessonPage({ params }: Props) {
  const lessons = loadCanonLessons({
    canon: "phoenix-protocol-secure-cloud-operator",
    version: "v2",
  });

  const lesson = lessons.find((l) => l.id === params.lessonId);

  if (!lesson) {
    return <div className="p-10 text-white">Lesson not found.</div>;
  }

  return (
    <main className="p-10 text-white">
      <h1 className="text-3xl font-bold">{lesson.title}</h1>

      {lesson.description && (
        <p className="mt-4 text-white/70">{lesson.description}</p>
      )}

      <div className="mt-10 rounded-xl border border-white/10 bg-black/40 p-6 text-xs">
        <pre className="overflow-x-auto">
          {JSON.stringify(lesson, null, 2)}
        </pre>
      </div>
    </main>
  );
}