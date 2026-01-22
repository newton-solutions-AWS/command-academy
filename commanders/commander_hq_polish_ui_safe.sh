#!/usr/bin/env bash
set -euo pipefail

echo "🎛️ NCA COMMANDER :: HQ POLISH (UI SAFE MODE)"
echo "-----------------------------------------"

# ------------------------------------------------------------
# 1) HQ HEADER (STATUS + CONTEXT)
# ------------------------------------------------------------
mkdir -p components/hq

cat > components/hq/HQHeader.tsx <<'TSX'
"use client";

import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function HQHeader() {
  const { runtime } = useMissionRuntime();

  return (
    <div className="flex items-center justify-between mb-6">
      <div>
        <div className="text-xs tracking-[0.3em] text-white/40">
          NEWTON COMMAND ACADEMY
        </div>
        <h1 className="text-2xl font-semibold text-white mt-2">
          Command HQ
        </h1>
        <p className="text-white/60 mt-1 text-sm">
          {runtime
            ? "Mission in progress — resume or abort."
            : "No active mission. Choose your next action."}
        </p>
      </div>

      <div className="flex items-center gap-3">
        <span
          className={[
            "px-3 py-1 rounded-full text-xs border",
            runtime
              ? "border-emerald-400/30 text-emerald-300 bg-emerald-400/10"
              : "border-white/20 text-white/50",
          ].join(" ")}
        >
          {runtime ? "ACTIVE" : "IDLE"}
        </span>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 2) ACTIVE MISSION CARD (POLISHED)
# ------------------------------------------------------------
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { runtime, abortMission } = useMissionRuntime();

  if (!runtime) return null;

  const href = `/academy/${runtime.division}/${runtime.lessonId}`;

  return (
    <div className="rounded-2xl border border-emerald-400/20 bg-emerald-400/5 p-5 mb-6 shadow-lg">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-xs tracking-[0.25em] text-emerald-300">
            ACTIVE MISSION
          </div>
          <div className="text-lg text-white mt-1">
            {runtime.lessonId}
          </div>
          <div className="text-sm text-white/60 mt-1">
            Division: {runtime.division}
          </div>
        </div>

        <div className="flex gap-3">
          <button
            onClick={() => router.push(href)}
            className="px-4 py-2 rounded-xl bg-emerald-500 text-black text-sm font-medium hover:bg-emerald-400 transition"
          >
            Resume
          </button>
          <button
            onClick={abortMission}
            className="px-4 py-2 rounded-xl border border-white/20 text-white/70 text-sm hover:bg-white/10 transition"
          >
            Abort
          </button>
        </div>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 3) MISSION LAUNCHER (CLEAN CTA)
# ------------------------------------------------------------
cat > components/hq/MissionLauncher.tsx <<'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export default function MissionLauncher() {
  const router = useRouter();
  const { runtime, startMission } = useMissionRuntime();

  if (runtime) return null;

  const lessonId = "intro-001";
  const division: Division = "phoenix";

  function launch() {
    startMission({ lessonId, division });
    router.push(`/academy/${division}/${lessonId}`);
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/30 p-6">
      <div className="text-xs tracking-[0.25em] text-white/40">
        QUICK START
      </div>
      <h3 className="text-lg text-white mt-2">
        Begin your next mission
      </h3>
      <p className="text-white/60 text-sm mt-1">
        Launch directly into the Academy onboarding mission.
      </p>

      <button
        onClick={launch}
        className="mt-4 px-5 py-2.5 rounded-xl bg-white text-black text-sm font-medium hover:bg-white/90 transition"
      >
        Launch Mission
      </button>
    </div>
  );
}
TSX

# ------------------------------------------------------------
# 4) HQ PAGE ASSEMBLY
# ------------------------------------------------------------
cat > app/hq/page.tsx <<'TSX'
import HQHeader from "@/components/hq/HQHeader";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import MissionLauncher from "@/components/hq/MissionLauncher";

export default function HQPage() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-10">
      <HQHeader />
      <ActiveMissionCard />
      <MissionLauncher />
    </main>
  );
}
TSX

# ------------------------------------------------------------
# 5) BUILD CHECK
# ------------------------------------------------------------
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ HQ POLISH COMPLETE — UI ONLY"
echo "🚀 Run: npm run dev"
