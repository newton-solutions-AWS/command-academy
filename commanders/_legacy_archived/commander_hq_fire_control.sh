#!/usr/bin/env bash
set -e

echo "🚀 HQ FIRE CONTROL — ARMING LAUNCH PATH"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

# -------------------------------
# Mission Launcher Component
# -------------------------------
mkdir -p components/hq

cat > components/hq/MissionLauncher.tsx << 'TSX'
"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/runtime/missionRuntime";

export default function MissionLauncher() {
  const router = useRouter();
  const { startMission } = useMissionRuntime();

  const launch = () => {
    startMission({
      lessonId: "001",
      division: "phoenix",
    });
    router.push("/academy/phoenix/001");
  };

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 p-6">
      <div className="text-xs tracking-widest text-white/50 mb-2">
        MISSION CONTROL
      </div>
      <button
        onClick={launch}
        className="rounded-xl bg-emerald-600 px-5 py-3 text-sm font-semibold hover:bg-emerald-500 transition"
      >
        Launch Mission 001 (Phoenix)
      </button>
    </div>
  );
}
TSX

# -------------------------------
# HQ Page (authoritative)
# -------------------------------
mkdir -p app/hq

cat > app/hq/page.tsx << 'TSX'
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import MissionLauncher from "@/components/hq/MissionLauncher";

export default function HQPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-12 space-y-8">
      <h1 className="text-2xl font-semibold">Operator HQ</h1>

      <MissionLauncher />
      <ActiveMissionCard />

      <div className="rounded-2xl border border-white/10 bg-black/30 p-6 text-white/70">
        HQ is the command surface. Missions are launched and resumed here.
      </div>
    </main>
  );
}
TSX

# -------------------------------
# Build Check
# -------------------------------
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ HQ FIRE CONTROL ONLINE"
echo "🚀 Run: npm run dev"
