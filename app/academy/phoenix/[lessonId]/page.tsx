import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import Link from "next/link";

export default function PhoenixIndex() {
  const lessons = loadCanonLessons("phoenix");

  return (
    <main className="max-w-5xl mx-auto px-6 py-12">
      <h1 className="text-3xl font-semibold mb-6">
        Phoenix Protocol · Lessons
      </h1>

      {lessons.length === 0 && (
        <p className="text-white/60">0 lessons detected</p>
      )}

      <ul className="space-y-4">
        {lessons.map((l) => (
          <li key={l.id} className="border border-white/10 rounded-xl p-4">
            <Link href={`/academy/phoenix/${l.id}`}>
              <div className="text-lg">{l.title}</div>
              {l.description && (
                <p className="text-white/60 text-sm mt-1">
                  {l.description}
                </p>
              )}
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}