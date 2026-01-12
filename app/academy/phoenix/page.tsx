import Link from "next/link";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export const dynamic = "force-dynamic";

export default function PhoenixIndexPage() {
  const lessons = loadCanonLessons({
    canon: "phoenix-protocol-secure-cloud-operator",
    version: "v2",
  });

  return (
    <div className="mx-auto max-w-4xl px-6 py-14">
      <h1 className="text-3xl font-semibold">Phoenix Division · Canon</h1>

      <ul className="mt-6 space-y-3">
        {lessons.map((lesson) => (
          <li key={lesson.id}>
            <Link
              href={`/academy/phoenix/${lesson.id}`}
              className="text-white/80 hover:text-white underline"
            >
              {lesson.order}. {lesson.title}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}