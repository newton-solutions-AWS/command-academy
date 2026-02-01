#!/usr/bin/env bash
set -euo pipefail

echo "🧭 PHASE 3 — MISSION DECKS (NORTH STAR)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

# ------------------------------------------------------------
# Folders
# ------------------------------------------------------------
mkdir -p components/deck
mkdir -p app/academy/phoenix
mkdir -p app/academy/vanguard
mkdir -p app/academy/sentinel

# ------------------------------------------------------------
# MissionCard
# ------------------------------------------------------------
cat > components/deck/MissionCard.tsx <<'TSX'
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
TSX

# ------------------------------------------------------------
# MissionDeck
# ------------------------------------------------------------
cat > components/deck/MissionDeck.tsx <<'TSX'
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
TSX

# ------------------------------------------------------------
# Academy pages
# ------------------------------------------------------------
cat > app/academy/phoenix/page.tsx <<'TSX'
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import MissionDeck from "@/components/deck/MissionDeck";

export default function PhoenixAcademyPage() {
  const lessons = loadCanonLessons("phoenix");
  return <MissionDeck title="Phoenix Division" lessons={lessons} />;
}
TSX

cat > app/academy/vanguard/page.tsx <<'TSX'
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import MissionDeck from "@/components/deck/MissionDeck";

export default function VanguardAcademyPage() {
  const lessons = loadCanonLessons("vanguard");
  return <MissionDeck title="Vanguard Division" lessons={lessons} />;
}
TSX

cat > app/academy/sentinel/page.tsx <<'TSX'
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import MissionDeck from "@/components/deck/MissionDeck";

export default function SentinelAcademyPage() {
  const lessons = loadCanonLessons("sentinel");
  return <MissionDeck title="Sentinel Division" lessons={lessons} />;
}
TSX

# ------------------------------------------------------------
# Root wrapper (never lose commanders)
# ------------------------------------------------------------
cat > commander_phase3_mission_decks.sh <<'BASH2'
#!/usr/bin/env bash
set -euo pipefail
exec ./commanders/commander_phase3_mission_decks.sh "$@"
BASH2
chmod +x commander_phase3_mission_decks.sh || true

echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "🚀 PHASE 3 COMPLETE — RUN: npm run dev"
