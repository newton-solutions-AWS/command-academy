#!/usr/bin/env bash
set -euo pipefail

echo "🎖️ PHASE 10 — RANK & CLEARANCE ENGINE"
echo "📍 Repo: $(pwd)"

# ------------------------------------------------------------
# 1) Canon: Rank & Clearance Model (SINGLE SOURCE)
# ------------------------------------------------------------
mkdir -p lib

cat > lib/rankCanon.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";

export type Rank =
  | "recruit"
  | "operator"
  | "specialist"
  | "veteran"
  | "sentinel";

export type Clearance =
  | "public"
  | "restricted"
  | "classified"
  | "black";

export const RankOrder: Rank[] = [
  "recruit",
  "operator",
  "specialist",
  "veteran",
  "sentinel",
];

export const ClearanceOrder: Clearance[] = [
  "public",
  "restricted",
  "classified",
  "black",
];

export type AccessProfile = {
  division: Division;
  rank: Rank;
  clearance: Clearance;
  phoenixOverride: boolean;
};

export function rankAtLeast(a: Rank, b: Rank): boolean {
  return RankOrder.indexOf(a) >= RankOrder.indexOf(b);
}

export function clearanceAtLeast(a: Clearance, b: Clearance): boolean {
  return ClearanceOrder.indexOf(a) >= ClearanceOrder.indexOf(b);
}
TS

# ------------------------------------------------------------
# 2) Runtime Access Resolver (Phoenix Override baked in)
# ------------------------------------------------------------
cat > lib/useAccessProfile.ts <<'TS'
import { AccessProfile, rankAtLeast, clearanceAtLeast } from "./rankCanon";

/**
 * TEMP PROFILE
 * Later this will come from auth / service record / transcript.
 */
export function getAccessProfile(): AccessProfile {
  return {
    division: "phoenix",
    rank: "veteran",
    clearance: "black",
    phoenixOverride: true,
  };
}

type Gate = {
  minRank?: "recruit" | "operator" | "specialist" | "veteran" | "sentinel";
  minClearance?: "public" | "restricted" | "classified" | "black";
};

export function canAccess(gate: Gate): boolean {
  const profile = getAccessProfile();

  // Phoenix override = full access
  if (profile.phoenixOverride) return true;

  if (gate.minRank && !rankAtLeast(profile.rank, gate.minRank)) {
    return false;
  }

  if (
    gate.minClearance &&
    !clearanceAtLeast(profile.clearance, gate.minClearance)
  ) {
    return false;
  }

  return true;
}
TS

# ------------------------------------------------------------
# 3) Access Gate Component (Hard Gate — content disappears)
# ------------------------------------------------------------
mkdir -p components/command

cat > components/command/AccessGate.tsx <<'TSX'
import { ReactNode } from "react";
import { canAccess } from "@/lib/useAccessProfile";

type Props = {
  minRank?: "recruit" | "operator" | "specialist" | "veteran" | "sentinel";
  minClearance?: "public" | "restricted" | "classified" | "black";
  children: ReactNode;
};

export default function AccessGate({
  minRank,
  minClearance,
  children,
}: Props) {
  const allowed = canAccess({ minRank, minClearance });

  if (!allowed) {
    return (
      <div className="mx-auto max-w-4xl mt-20 rounded-2xl border border-red-500/30 bg-black/40 p-8 text-center">
        <div className="text-xs tracking-[0.3em] text-red-400">
          ACCESS DENIED
        </div>
        <div className="mt-3 text-white/80">
          This content is above your current clearance.
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
TSX

# ------------------------------------------------------------
# 4) Enforce Gating on Lesson Shell (North Star rule)
# ------------------------------------------------------------
cat > components/command/LessonShell.tsx <<'TSX'
import GuardianAngelPanel from "@/components/guardian/GuardianAngelPanel";
import AccessGate from "@/components/command/AccessGate";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lesson: CanonLesson;
};

export default function LessonShell({ lesson }: Props) {
  return (
    <AccessGate
      minRank={
        lesson.difficulty === "elite"
          ? "sentinel"
          : lesson.difficulty === "advanced"
          ? "veteran"
          : lesson.difficulty === "intermediate"
          ? "specialist"
          : "recruit"
      }
      minClearance={
        lesson.division === "sentinel"
          ? "classified"
          : lesson.division === "vanguard"
          ? "restricted"
          : "public"
      }
    >
      <main className="mx-auto max-w-6xl px-6 pb-16">
        <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
          <div className="px-8 py-7 border-b border-white/10">
            <div className="text-xs tracking-[0.28em] text-white/50">
              NEWTON COMMAND ACADEMY
            </div>
            <h1 className="text-3xl font-semibold text-white mt-3">
              {lesson.title}
            </h1>

            <div className="mt-3 flex flex-wrap gap-2 items-center text-sm text-white/60">
              <span>ID: {lesson.id}</span>
              <span>•</span>
              <span>{lesson.duration_minutes} mins</span>
              <span>•</span>
              <span>{lesson.division.toUpperCase()}</span>
              <span>•</span>
              <span>{lesson.difficulty.toUpperCase()}</span>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-8">
            <div className="lg:col-span-2 space-y-6">
              <section className="rounded-2xl border border-white/10 bg-black/20">
                <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                  CONCEPT
                </div>
                <div className="px-6 py-5 text-white/80 leading-relaxed">
                  {lesson.concept}
                </div>
              </section>

              <section className="rounded-2xl border border-white/10 bg-black/20">
                <div className="px-6 py-4 border-b border-white/10 text-xs tracking-[0.24em] text-white/45">
                  WALKTHROUGH
                </div>
                <div className="px-6 py-5 text-white/80 leading-relaxed whitespace-pre-line">
                  {lesson.walkthrough}
                </div>
              </section>
            </div>

            <div>
              <GuardianAngelPanel
                lessonId={lesson.id}
                division={lesson.division}
                steps={lesson.steps ?? []}
              />
            </div>
          </div>
        </div>
      </main>
    </AccessGate>
  );
}
TSX

# ------------------------------------------------------------
# 5) Build Check (Lock it)
# ------------------------------------------------------------
echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 10 COMPLETE — RANK & CLEARANCE LIVE"
echo "🚀 Run: npm run dev"
