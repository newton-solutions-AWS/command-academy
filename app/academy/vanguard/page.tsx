import Link from "next/link";
import { loadVanguardLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function VanguardIndexPage() {
  const lessons = loadVanguardLessons();

  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-semibold">
        Advanced Cloud Architecture
      </h1>

      <ul className="space-y-3">
        {lessons.map((lesson) => (
          <li key={lesson.id}>
            <Link
              href={`/academy/vanguard/${lesson.id}`}
              className="text-blue-400 hover:underline"
            >
              {lesson.title}
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}