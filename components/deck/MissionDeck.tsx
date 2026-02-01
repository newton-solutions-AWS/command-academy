import MissionCard from "./MissionCard";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  title: string;
  lessons: CanonLesson[];
};

export default function MissionDeck({ title, lessons }: Props) {
  return (
    <main className="mx-auto max-w-7xl px-6 pb-16">
      <div className="mt-10 mb-8">
        <div className="text-xs tracking-[0.28em] text-white/45">
          NEWTON COMMAND ACADEMY
        </div>
        <h1 className="text-3xl font-semibold text-white mt-3">{title}</h1>
        <p className="text-white/60 mt-2">
          Missions unlock sequentially. Complete cleanly.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        {lessons.map((lesson, index) => {
          // 🔒 Simple linear gating (future hook)
          const status = index === 0 ? "available" : "locked";

          return (
            <MissionCard
              key={lesson.id}
              lesson={lesson}
              status={status}
            />
          );
        })}
      </div>
    </main>
  );
}
