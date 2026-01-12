import fs from "fs";
import { notFound } from "next/navigation";
import { loadPhoenixLessons } from "@/cert_intel/intake/lib/lessonloader";

type Props = {
  params: { lessonId: string };
};

export default function PhoenixLessonPage({ params }: Props) {
  const lessons = loadPhoenixLessons();
  const lesson = lessons.find((l) => l.id === params.lessonId);

  if (!lesson || !fs.existsSync(lesson.path)) {
    notFound();
  }

  const data = JSON.parse(fs.readFileSync(lesson.path, "utf-8"));

  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-semibold">{data.title}</h1>

      {data.description && (
        <p className="text-white/70">{data.description}</p>
      )}

      <pre className="rounded-xl border border-white/10 bg-black/40 p-4 text-xs overflow-x-auto">
        {JSON.stringify(data, null, 2)}
      </pre>
    </section>
  );
}