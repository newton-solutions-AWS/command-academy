#!/usr/bin/env bash
set -euo pipefail

echo "💀 KILLSHOT — RUNTIME PATH FIX"
echo "�� Repo: $(pwd)"

# ------------------------------------------------------------
# 1) DELETE GHOST RUNTIME PATH
# ------------------------------------------------------------
echo "🧹 Removing dead runtime paths..."
rm -rf lib/runtime || true

# ------------------------------------------------------------
# 2) WRITE SINGLE CANONICAL MISSION RUNTIME
# ------------------------------------------------------------
mkdir -p lib

cat > lib/missionRuntime.ts <<'TS'
"use client";

import { useSyncExternalStore } from "react";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type ActiveMission = {
  lessonId: string;
  division: Division;
  startedAt: number;
};

type RuntimeState = {
  activeMission: ActiveMission | null;
};

const STORAGE_KEY = "nca:mission:runtime:v1";

let state: RuntimeState = { activeMission: null };
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((l) => l());
}

function persist() {
  if (typeof window !== "undefined") {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }
}

function hydrate() {
  if (typeof window === "undefined") return;
  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw) state = JSON.parse(raw);
}

hydrate();

export function startMission(input: { lessonId: string; division: Division }) {
  state = {
    activeMission: {
      lessonId: input.lessonId,
      division: input.division,
      startedAt: Date.now(),
    },
  };
  persist();
  emit();
}

export function clearMission() {
  state = { activeMission: null };
  persist();
  emit();
}

export function useMissionRuntime() {
  const snapshot = () => state;
  const subscribe = (l: () => void) => {
    listeners.add(l);
    return () => listeners.delete(l);
  };

  const s = useSyncExternalStore(subscribe, snapshot, snapshot);

  return {
    activeMission: s.activeMission,
    startMission,
    clearMission,
  };
}
TS

# ------------------------------------------------------------
# 3) REWRITE ALL BAD IMPORTS (AUTOMATIC)
# ------------------------------------------------------------
echo "🔧 Rewriting stale imports..."
grep -rl "@/lib/runtime/missionRuntime" . \
  | xargs sed -i '' 's@@/lib/runtime/missionRuntime@/lib/missionRuntime@g' || true

# ------------------------------------------------------------
# 4) BUILD CHECK
# ------------------------------------------------------------
echo "�� BUILD CHECK"
rm -rf .next
npm run build

echo "✅ KILLSHOT COMPLETE — RUNTIME CANONICAL"
echo "🚀 Run: npm run dev"
