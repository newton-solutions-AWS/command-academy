import Link from "next/link";
import { loadCanonLessons } from "@/lib/lessonloader";

export const dynamic = "force-dynamic";

const CANON = "vanguard-protocol-architecture-operator";
const VERSION = "v2";

export default function VanguardIndexPage() {
  const lessons = loadCanonLessons({ canon: CANON, version: VERSION });

  return (
    <div className="mx-auto max-w-5xl px-6 py-14">
      <p className="text-xs uppercase tracking-[0.35em] text-white/50">
        Vanguard Division · Canon Index
      </p>

      <h1 className="mt-4 text-3xl font-semibold leading-tight">
        Vanguard Protocol · Lessons
      </h1>

      <p className="mt-4 text-white/70">
        Commercial route (gating later). Version: <span className="text-white">{VERSION}</span>
      </p>

      <div className="mt-10 rounded-2xl border border-white/10 bg-black/40">
        <div className="border-b border-white/10 px-6 py-4 text-sm text-white/70">
          {lessons.length} lessons detected
        </div>

        <ul className="divide-y divide-white/10">
          {lessons.map((l) => (
            <li key={l.id} className="px-6 py-5">
              <div className="flex items-start justify-between gap-6">
                <div className="min-w-0">
                  <p className="text-xs uppercase tracking-[0.25em] text-white/40">
                    Lesson {l.order}
                  </p>
                  <h2 className="mt-2 text-lg font-semibold text-white">{l.title}</h2>
                  {l.description ? <p className="mt-2 text-sm text-white/65">{l.description}</p> : null}
                  <p className="mt-2 text-xs text-white/40 break-all">{l.id}</p>
                </div>

                <Link
                  href={`/academy/vanguard/${encodeURIComponent(l.id)}`}
                  className="shrink-0 rounded-xl border border-white/15 bg-white/5 px-4 py-2 text-sm text-white hover:bg-white/10"
                >
                  Open →
                </Link>
              </div>
            </li>
          ))}
        </ul>

        {lessons.length === 0 ? (
          <div className="px-6 py-10 text-sm text-white/60">
            No lessons found. Expected folder:
            <pre className="mt-3 overflow-x-auto rounded-xl border border-white/10 bg-black/50 p-4 text-xs text-white/60">
              {`cert_intel/canon/atils/${CANON}/${VERSION}/labs/*.json`}
            </pre>
          </div>
        ) : null}
      </div>
    </div>
  );
}