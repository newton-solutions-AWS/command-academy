#!/usr/bin/env bash
set -euo pipefail

echo "🧭 PHASE 5 — HQ COMMAND DECK"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p app/hq
mkdir -p components/hq
mkdir -p lib/rank

# ------------------------------------------------------------
# 1) Rank + Clearance Engine
# ------------------------------------------------------------
cat > lib/rank/rankEngine.ts <<'TS'
import { getDivisionProgress } from "@/lib/progression/progressStore";

export type Rank =
  | "RECRUIT"
  | "OPERATOR"
  | "SPECIALIST"
  | "SENIOR"
  | "COMMAND";

export function calculateRank(): Rank {
  if (typeof window === "undefined") return "RECRUIT";

  const phoenix = Object.values(getDivisionProgress("phoenix")).filter(p => p.completed).length;
  const vanguard = Object.values(getDivisionProgress("vanguard")).filter(p => p.completed).length;
  const sentinel = Object.values(getDivisionProgress("sentinel")).filter(p => p.completed).length;

  const total = phoenix + vanguard + sentinel;

  if (total >= 10) return "COMMAND";
  if (total >= 6) return "SENIOR";
  if (total >= 3) return "SPECIALIST";
  if (total >= 1) return "OPERATOR";
  return "RECRUIT";
}

export function calculateClearance(): "PHOENIX" | "VANGUARD" | "SENTINEL" {
  if (typeof window === "undefined") return "PHOENIX";

  const vanguardDone = Object.values(getDivisionProgress("vanguard")).some(p => p.completed);
  const sentinelDone = Object.values(getDivisionProgress("sentinel")).some(p => p.completed);

  if (sentinelDone) return "SENTINEL";
  if (vanguardDone) return "VANGUARD";
  return "PHOENIX";
}
TS

# ------------------------------------------------------------
# 2) HQ Status Card
# ------------------------------------------------------------
cat > components/hq/HQStatus.tsx <<'TSX'
"use client";

import { calculateRank, calculateClearance } from "@/lib/rank/rankEngine";

export default function HQStatus() {
  const rank = calculateRank();
  const clearance = calculateClearance();

  return (
    <div className="rounded-2xl border border-white/10 bg-black/30 p-6">
      <div className="text-xs tracking-[0.28em] text-white/50">OPERATOR STATUS</div>

      <div className="mt-4 grid grid-cols-2 gap-4">
        <div>
          <div className="text-xs text-white/40">RANK</div>
          <div className="text-xl text-white mt-1">{rank}</div>
        </div>

        <div>
          <div className="text-xs text-white/40">CLEARANCE</div>
          <div className="text-xl text-white mt-1">{clearance}</div>
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 3) HQ Mission Overview
# ------------------------------------------------------------
cat > components/hq/HQMissionOverview.tsx <<'TSX'
"use client";

import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { getDivisionProgress } from "@/lib/progression/progressStore";
import MissionCard from "@/components/deck/MissionCard";
import { isUnlocked } from "@/lib/progression/missionOrder";

export default function HQMissionOverview() {
  const divisions: ("phoenix" | "vanguard" | "sentinel")[] = [
    "phoenix",
    "vanguard",
    "sentinel",
  ];

  return (
    <div className="space-y-10">
      {divisions.map((division) => {
        const lessons = loadCanonLessons(division);
        const progress = getDivisionProgress(division);

        return (
          <section key={division}>
            <div className="mb-4 text-sm tracking-[0.28em] text-white/50">
              {division.toUpperCase()} DIVISION
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {lessons.map((l, i) => {
                const completed = !!progress[l.id]?.completed;
                const unlocked = isUnlocked(
                  lessons,
                  i,
                  (id) => !!progress[id]?.completed
                );

                const state = completed
                  ? "complete"
                  : unlocked
                  ? "active"
                  : "locked";

                return (
                  <MissionCard
                    key={l.id}
                    id={l.id}
                    title={l.title}
                    href={`/academy/${division}/${l.id}`}
                    state={state}
                  />
                );
              })}
            </div>
          </section>
        );
      })}
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) HQ Page
# ------------------------------------------------------------
cat > app/hq/page.tsx <<'TSX'
import HQStatus from "@/components/hq/HQStatus";
import HQMissionOverview from "@/components/hq/HQMissionOverview";

export default function HQPage() {
  return (
    <main className="mx-auto max-w-7xl px-6 py-12 space-y-10">
      <div>
        <div className="text-xs tracking-[0.28em] text-white/50">
          NEWTON COMMAND ACADEMY
        </div>
        <h1 className="text-4xl text-white mt-3">Headquarters</h1>
        <p className="text-white/60 mt-3 max-w-2xl">
          This is your operational overview. Rank, clearance, and mission access
          update automatically as you progress.
        </p>
      </div>

      <HQStatus />
      <HQMissionOverview />
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 5) Build Check
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 5 COMPLETE — HQ ONLINE"
echo "🚀 Run: npm run dev"
