"use client";

import type { Division } from "@/cert_intel/intake/lib/canonTypes";

/* ============================================================
   CANON
============================================================ */

export const DEFAULT_MISSION = {
  lessonId: "phoenix-mission-zero",
  division: "PHOENIX" as Division,
  title: "Phoenix Induction: Mission Zero",
  status: "ACTIVE" as const,
};

/* ============================================================
   TYPES
============================================================ */

export type MissionRuntime = {
  lessonId: string;
  division: Division;
  title: string;
  status: "ACTIVE" | "COMPLETED" | "ABORTED";
  stepIndex: number;
  completedSteps: Record<number, boolean>;
  notes?: string;
  lastTouched: number;
};

/* ============================================================
   INTERNAL STATE
============================================================ */

let runtime: MissionRuntime | null = null;
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((l) => l());
}

function persist() {
  try {
    localStorage.setItem("nca:missionRuntime:v2", JSON.stringify(runtime));
  } catch {}
}

function hydrate() {
  if (runtime) return;

  try {
    const raw = localStorage.getItem("nca:missionRuntime:v2");
    runtime = raw ? JSON.parse(raw) : null;
  } catch {
    runtime = null;
  }

  // 🔒 SELF-HEAL — NEVER ALLOW UNDEFINED STATE
  if (!runtime) {
    runtime = {
      ...DEFAULT_MISSION,
      stepIndex: 0,
      completedSteps: {},
      lastTouched: Date.now(),
    };
    persist();
  }
}

/* ============================================================
   READ API
============================================================ */

export function getMissionRuntime(): MissionRuntime {
  hydrate();
  return runtime!;
}

export function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

/* ============================================================
   COMMANDS (WRITE API)
============================================================ */

export function startMission(input: {
  lessonId: string;
  division: Division;
  title: string;
}) {
  runtime = {
    lessonId: input.lessonId,
    division: input.division,
    title: input.title,
    status: "ACTIVE",
    stepIndex: 0,
    completedSteps: {},
    lastTouched: Date.now(),
  };
  persist();
  emit();
}

export function completeMission() {
  if (!runtime) return;
  runtime.status = "COMPLETED";
  runtime.lastTouched = Date.now();
  persist();
  emit();
}

export function abortMission() {
  if (!runtime) return;
  runtime.status = "ABORTED";
  runtime.lastTouched = Date.now();
  persist();
  emit();
}

export function setStepIndex(index: number) {
  if (!runtime) return;
  runtime.stepIndex = index;
  runtime.lastTouched = Date.now();
  persist();
  emit();
}

export function toggleStepComplete(step: number) {
  if (!runtime) return;
  runtime.completedSteps[step] = !runtime.completedSteps[step];
  runtime.lastTouched = Date.now();
  persist();
  emit();
}

export function addMissionNote(note: string) {
  if (!runtime) return;
  runtime.notes = note;
  runtime.lastTouched = Date.now();
  persist();
  emit();
}