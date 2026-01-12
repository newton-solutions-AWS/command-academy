import Link from "next/link";
import { notFound } from "next/navigation";
import { loadLessonById, toRenderBlocks } from "@/lib/lessonloader";

export const dynamic = "force-dynamic";

type Props = { params: { lessonId: string } };

const CANON = "vanguard-protocol-architecture-operator";
const VERSION = "v2";

function Section({ title, items }: { title: string; items: string[] }) {
  if (!items.length) return null;
  return (
    <section className="mt-8">
      <h2 className="text-xs uppercase tracking-[0.35em] text-white/50">{title}</h2>
      <div className="mt-3 rounded-xl border border-white/10 bg-black/40 p-5">
        <ul className="list-disc pl-5 text-sm text-white/75 space-y-2">
          {items.map((x, i) => (
            <li key={`${title}-${i}`} className="leading-relaxed">{x}</li>
          ))}
        </ul>
      </div>
    </section>
  );
}

export default function VanguardLessonPage({ params }: Props) {
  const lesson = loadLessonById({ canon: CANON, version: VERSION, lessonId: params.lessonId });
  if (!lesson) return notFound();

  const blocks = toRenderBlocks(lesson);

  return (
    <div className="mx-auto max-w-5xl px-6 py-14">
      <div className="flex items-center justify-between gap-4">
        <p className="text-xs uppercase tracking-[0.35em] text-white/50">
          Vanguard Division · Canon Lesson
        </p>

        <Link
          href="/academy/vanguard"
          className="rounded-xl border border-white/15 bg-white/5 px-4 py-2 text-sm text-white hover:bg-white/10"
        >
          ← Back to Vanguard
        </Link>
      </div>

      <h1 className="mt-4 text-3xl font-semibold leading-tight">{lesson.title}</h1>
      {lesson.description ? <p className="mt-4 text-white/70">{lesson.description}</p> : null}

      {lesson.mission ? (
        <section className="mt-10">
          <h2 className="text-xs uppercase tracking-[0.35em] text-white/50">Mission</h2>
          <div className="mt-3 rounded-xl border border-white/10 bg-black/40 p-5">
            <p className="text-sm text-white/75 leading-relaxed">{lesson.mission}</p>
          </div>
        </section>
      ) : null}

      <Section title="Objectives" items={blocks.objectives} />
      <Section title="Prerequisites" items={blocks.prerequisites} />
      <Section title="Steps" items={blocks.steps} />
      <Section title="Commands" items={blocks.commands} />
      <Section title="Validation" items={blocks.validation} />
      <Section title="Notes" items={blocks.notes} />

      <section className="mt-10">
        <h2 className="text-xs uppercase tracking-[0.35em] text-white/50">Raw Canon Payload</h2>
        <div className="mt-3 rounded-xl border border-white/10 bg-black/40 p-5 text-xs text-white/60">
          <pre className="overflow-x-auto">{JSON.stringify(lesson, null, 2)}</pre>
        </div>
      </section>
    </div>
  );
}