import Link from "next/link";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function PhoenixPage() {
  const lessons = loadCanonLessons({
    canon: "phoenix-protocol-secure-cloud-operator",
    version: "v2",
  });

  return (
    <main className="p-10 text-white">
      <h1 className="text-3xl font-bold mb-6">Phoenix Division</h1>

      <ul className="space-y-4">
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
    </main>
  );
}