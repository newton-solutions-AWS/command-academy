import Link from "next/link";
import { loadPhoenixLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function PhoenixIndexPage() {
  const lessons = loadPhoenixLessons();

  return (
    <section className="space-y-6">
      <h1 className="text-3xl font-semibold">Phoenix Division</h1>

      {lessons.length === 0 && (
        <p className="text-white/60">
          No lessons found. Expected:
          <code className="block mt-2 text-xs">
            cert_intel/canon/atils/phoenix-protocol-secure-cloud-operator/v2/labs/*.json
          </code>
        </p>
      )}

      <ul className="space-y-3">
        {lessons.map((lesson) => (
          <li key={lesson.id}>
            <Link
              href={`/academy/phoenix/${lesson.id}`}
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