import Link from "next/link";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lesson: CanonLesson;
  status: "locked" | "available" | "complete";
};

export default function MissionCard({ lesson, status }: Props) {
  const locked = status === "locked";

  return (
    <div
      className={[
        "relative rounded-2xl border p-5 transition",
        "bg-black/30 backdrop-blur-xl",
        locked
          ? "border-white/5 opacity-40"
          : "border-white/10 hover:border-white/25 hover:bg-black/40",
      ].join(" ")}
    >
      <div className="flex items-center justify-between mb-3">
        <div className="text-xs tracking-[0.28em] text-white/45">
          {lesson.difficulty.toUpperCase()}
        </div>

        <div
          className={[
            "text-xs px-2 py-1 rounded-full border",
            status === "complete"
              ? "border-emerald-400/40 text-emerald-300 bg-emerald-500/10"
              : status === "available"
              ? "border-sky-400/40 text-sky-300 bg-sky-500/10"
              : "border-white/10 text-white/40 bg-white/5",
          ].join(" ")}
        >
          {status.toUpperCase()}
        </div>
      </div>

      <h3 className="text-lg text-white/90 mb-2">{lesson.title}</h3>

      <div className="text-sm text-white/60 mb-4 line-clamp-3">
        {lesson.concept}
      </div>

      <div className="flex items-center justify-between text-xs text-white/50">
        <span>{lesson.duration_minutes} mins</span>

        {!locked && (
          <Link
            href={`/academy/${lesson.division}/${lesson.id}`}
            className="text-white/80 hover:text-white"
          >
            Enter Mission →
          </Link>
        )}
      </div>
    </div>
  );
}
