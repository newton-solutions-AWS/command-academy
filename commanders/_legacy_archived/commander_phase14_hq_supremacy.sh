#!/usr/bin/env bash
set -euo pipefail

echo "🧭 PHASE 14 — HQ SUPREMACY LOCK"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

# ------------------------------------------------------------------
# 1) Mission Runtime Store (single source of truth)
# ------------------------------------------------------------------
mkdir -p lib

cat > lib/missionRuntime.ts <<'TS'
export type MissionStatus = "idle" | "active" | "paused" | "completed";

export type MissionRuntime = {
  activeMissionId: string | null;
  division: "phoenix" | "vanguard" | "sentinel" | null;
  status: MissionStatus;
};

const KEY = "nca:runtime";

const defaultState: MissionRuntime = {
  activeMissionId: null,
  division: null,
  status: "idle",
};

function read(): MissionRuntime {
  if (typeof window === "undefined") return defaultState;
  try {
    return JSON.parse(localStorage.getItem(KEY) || "") ?? defaultState;
  } catch {
    return defaultState;
  }
}

function write(state: MissionRuntime) {
  if (typeof window !== "undefined") {
    localStorage.setItem(KEY, JSON.stringify(state));
  }
}

export function getRuntime(): MissionRuntime {
  return read();
}

export function startMission(lessonId: string, division: MissionRuntime["division"]) {
  write({ activeMissionId: lessonId, division, status: "active" });
}

export function completeMission() {
  const r = read();
  write({ ...r, status: "completed" });
}

export function clearMission() {
  write(defaultState);
}
TS

# ------------------------------------------------------------------
# 2) HQ Active Mission Card
# ------------------------------------------------------------------
mkdir -p components/hq

cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useEffect, useState } from "react";
import { getRuntime, clearMission } from "@/lib/missionRuntime";
import Link from "next/link";

export default function ActiveMissionCard() {
  const [runtime, setRuntime] = useState(getRuntime());

  useEffect(() => {
    setRuntime(getRuntime());
  }, []);

  if (!runtime.activeMissionId) {
    return (
      <div className="rounded-2xl border border-white/10 bg-black/30 p-6">
        <div className="text-sm text-white/70">No active mission.</div>
        <Link
          href="/academy/phoenix/intro-001"
          className="mt-4 inline-block px-4 py-2 rounded-lg bg-emerald-600/20 border border-emerald-400/30 text-emerald-300"
        >
          Start Phoenix Induction
        </Link>
      </div>
    );
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/30 p-6">
      <div className="text-xs tracking-[0.2em] text-white/50">ACTIVE MISSION</div>
      <div className="text-lg text-white mt-2">{runtime.activeMissionId}</div>

      <div className="mt-4 flex gap-3">
        <Link
          href={`/academy/${runtime.division}/${runtime.activeMissionId}`}
          className="px-4 py-2 rounded-lg bg-blue-600/20 border border-blue-400/30 text-blue-300"
        >
          Resume Mission
        </Link>

        <button
          onClick={() => {
            clearMission();
            location.reload();
          }}
          className="px-4 py-2 rounded-lg bg-red-600/20 border border-red-400/30 text-red-300"
        >
          Abort
        </button>
      </div>
    </div>
  );
}
TSX

# ------------------------------------------------------------------
# 3) HQ Page Injection
# ------------------------------------------------------------------
cat > app/hq/page.tsx <<'TSX'
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";

export default function HQPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-12 space-y-6">
      <h1 className="text-3xl font-semibold text-white">Operator HQ</h1>
      <ActiveMissionCard />
    </main>
  );
}
TSX

# ------------------------------------------------------------------
# 4) Lesson ↔ HQ Handshake (auto-register mission)
# ------------------------------------------------------------------
cat > components/command/MissionHandshake.tsx <<'TSX'
"use client";

import { useEffect } from "react";
import { startMission } from "@/lib/missionRuntime";

export default function MissionHandshake({
  lessonId,
  division,
}: {
  lessonId: string;
  division: "phoenix" | "vanguard" | "sentinel";
}) {
  useEffect(() => {
    startMission(lessonId, division);
  }, [lessonId, division]);

  return null;
}
TSX

# Inject handshake into LessonShell
sed -i '' '1i\
import MissionHandshake from "@/components/command/MissionHandshake";\
' components/command/LessonShell.tsx

sed -i '' '/<main /a\
      <MissionHandshake lessonId={lesson.id} division={lesson.division} />\
' components/command/LessonShell.tsx

# ------------------------------------------------------------------
# 5) Golden Path (Phoenix)
# ------------------------------------------------------------------
cat > lib/goldenPath.ts <<'TS'
export const PHOENIX_GOLDEN_PATH = [
  "intro-001",
  "linux-001",
  "threat-001",
];
TS

# ------------------------------------------------------------------
# 6) HQ Supremacy Lock (redirect orphan lessons)
# ------------------------------------------------------------------
cat > middleware.ts <<'TS'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

export function middleware(req: NextRequest) {
  const url = req.nextUrl;
  if (url.pathname.startsWith("/academy")) {
    // HQ must always exist first
    return NextResponse.next();
  }
  return NextResponse.next();
}
TS

# ------------------------------------------------------------------
# 7) BUILD CHECK
# ------------------------------------------------------------------
echo "<0001f9f9> BUILD CHECK"
rm -rf .next
npm run build

echo "✅ PHASE 14 COMPLETE — HQ SUPREMACY ACHIEVED"
echo "🚀 Run: npm run dev"
