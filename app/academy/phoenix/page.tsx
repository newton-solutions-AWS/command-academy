import Link from "next/link";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const revalidate = 0;

export default async function PhoenixAcademyPage() {
  // Force runtime execution boundary
  const lessons = await Promise.resolve(
    loadCanonLessons({
      canon: "phoenix-protocol-secure-cloud-operator",
      version: "v2",
    })
  );

  return (
    <div className="mx-auto max-w-6xl px-6 py-12">
      {/* Header */}
      <div className="mb-10">
        <p className="text-xs uppercase tracking-[0.4em] text-white/50">
          Phoenix Division · Audited Canon
        </p>
        <h1 className="mt-3 text-4xl font-semibold tracking-tight">
          Secure Cloud Operator
        </h1>
        <p className="mt-2 max-w-3xl text-white/70">
          Deterministic execution doctrine. Read-only AWS CLI. Empty-sandbox
          safe. Every lesson is canon-validated.
        </p>
      </div>

      {/* Lessons */}
      <div className="grid gap-4">
        {lessons.map((lesson, idx) => (
          <Link
            key={lesson.id}
            href={`/academy/phoenix/${lesson.id}`}
            className="group rounded-xl border border-white/10 bg-white/[0.03] p-5 transition hover:border-white/25 hover:bg-white/[0.05]"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs tracking-widest text-white/40">
                  LESSON {String(idx + 1).padStart(2, "0")}
                </p>
                <h3 className="mt-1 text-lg font-medium">
                  {lesson.title}
                </h3>
              </div>
              <span className="text-xs text-white/40 group-hover:text-white">
                Enter →
              </span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}