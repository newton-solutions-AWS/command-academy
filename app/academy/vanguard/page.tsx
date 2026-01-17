import Link from "next/link";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function VanguardAcademyPage() {
  const lessons = loadCanonLessons("vanguard");

  return (
    <div className="max-w-5xl mx-auto p-8 space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-white">
          Vanguard Division
        </h1>
        <p className="text-slate-400 mt-2">
          Civilian operational training · Cloud · Infrastructure · Security
        </p>
      </div>

      {/* Lesson List */}
      <div className="grid gap-4">
        {lessons.map((l) => (
          <Link
            key={l.id}
            href={`/academy/vanguard/${l.id}`}
            className="block rounded-lg border border-white/10 bg-black/40 p-4 hover:border-blue-400/40 transition"
          >
            <div className="text-lg font-semibold text-white">
              {l.title}
            </div>

            <div className="text-sm text-slate-400 mt-1">
              Difficulty: {l.difficulty}
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}