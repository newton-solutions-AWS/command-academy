#!/usr/bin/env bash
set -euo pipefail

echo "🏅 PHASE 9 — RANK & CLEARANCE GATES"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p lib/rank
mkdir -p components/guard

# ------------------------------------------------------------
# 1) Rank & Clearance Canon
# ------------------------------------------------------------
cat > lib/rank/rankTypes.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";

export type Rank =
  | "RECRUIT"
  | "OPERATOR"
  | "SPECIALIST"
  | "SENTINEL";

export const RankOrder: Rank[] = [
  "RECRUIT",
  "OPERATOR",
  "SPECIALIST",
  "SENTINEL",
];

export function rankGTE(a: Rank, b: Rank): boolean {
  return RankOrder.indexOf(a) >= RankOrder.indexOf(b);
}
TS

# ------------------------------------------------------------
# 2) Rank Resolver (Transcript → Rank)
# ------------------------------------------------------------
cat > lib/rank/resolveRank.ts <<'TS'
import type { Rank } from "./rankTypes";
import type { Transcript } from "@/lib/transcript/types";

export function resolveRank(
  division: "phoenix" | "vanguard" | "sentinel",
  transcript: Transcript
): Rank {
  // Phoenix doctrine: service credit
  if (division === "phoenix") {
    return "OPERATOR";
  }

  const passed = transcript.entries.filter(
    (e) => e.verdict === "PASS"
  ).length;

  if (passed >= 6) return "SENTINEL";
  if (passed >= 3) return "SPECIALIST";
  if (passed >= 1) return "OPERATOR";

  return "RECRUIT";
}
TS

# ------------------------------------------------------------
# 3) Clearance Guard (Client)
# ------------------------------------------------------------
cat > components/guard/ClearanceGate.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import { buildTranscript } from "@/lib/transcript/buildTranscript";
import { resolveRank } from "@/lib/rank/resolveRank";
import { rankGTE } from "@/lib/rank/rankTypes";
import type { Rank } from "@/lib/rank/rankTypes";

type Props = {
  learnerId: string;
  division: "phoenix" | "vanguard" | "sentinel";
  minRank: Rank;
  children: React.ReactNode;
};

export default function ClearanceGate({
  learnerId,
  division,
  minRank,
  children,
}: Props) {
  const [allowed, setAllowed] = useState(false);
  const [currentRank, setCurrentRank] = useState<Rank | null>(null);

  useEffect(() => {
    try {
      const transcript = buildTranscript(learnerId);
      const rank = resolveRank(division, transcript);
      setCurrentRank(rank);
      setAllowed(rankGTE(rank, minRank));
    } catch {
      setAllowed(false);
    }
  }, [learnerId, division, minRank]);

  if (!allowed) {
    return (
      <div className="rounded-2xl border border-red-500/30 bg-red-500/5 p-6">
        <div className="text-xs tracking-[0.3em] text-red-400">
          ACCESS DENIED
        </div>
        <div className="mt-2 text-white/80">
          Required Rank: <strong>{minRank}</strong>
        </div>
        <div className="mt-1 text-white/60">
          Your Rank: {currentRank ?? "UNVERIFIED"}
        </div>
        <div className="mt-4 text-sm text-white/50">
          Complete missions and pass assessments to advance.
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
TSX

# ------------------------------------------------------------
# 4) Example: Sentinel Page Gate
# ------------------------------------------------------------
cat > app/academy/sentinel/page.tsx <<'TSX'
import ClearanceGate from "@/components/guard/ClearanceGate";

export default function SentinelPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-16">
      <ClearanceGate
        learnerId="FOUNDER-0001"
        division="vanguard"
        minRank="SENTINEL"
      >
        <div className="rounded-2xl border border-white/10 bg-black/40 p-8">
          <div className="text-xs tracking-[0.3em] text-white/50">
            SENTINEL CLEARANCE
          </div>
          <h1 className="mt-4 text-3xl font-semibold text-white">
            Advanced Operations Unlocked
          </h1>
          <p className="mt-3 text-white/70">
            You have crossed the threshold. This content is not instructional —
            it is operational.
          </p>
        </div>
      </ClearanceGate>
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

echo "✅ PHASE 9 COMPLETE — RANK & CLEARANCE LIVE"
echo "🚀 NORTH STAR CORE COMPLETE"
