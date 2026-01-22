"use client";

import type { Division } from "@/cert_intel/intake/lib/canonTypes";

/* ============================================================
   TYPES
============================================================ */

export type MissionRuntime = {
  lessonId: string;
  division: Division;
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
    localStorage.setItem("nca:missionRuntime:v1", JSON.stringify(runtime));
  } catch {}
}

function hydrate() {
  if (runtime) return;
  try {
    const raw = localStorage.getItem("nca:missionRuntime:v1");
    runtime = raw ? JSON.parse(raw) : null;
  } catch {
    runtime = null;
  }
}

/* ============================================================
   READ API
============================================================ */

export function getMissionRuntime(): MissionRuntime | null {
  hydrate();
  return runtime;
}

export function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => {
    listeners.delete(listener);
  };
}

/* ============================================================
   COMMANDS (WRITE API)
============================================================ */

export function startMission(input: {
  lessonId: string;
  division: Division;
}) {
  runtime = {
    lessonId: input.lessonId,
    division: input.division,
    stepIndex: 0,
    completedSteps: {},
    lastTouched: Date.now(),
  };
  persist();
  emit();
}

export function abortMission() {
  runtime = null;
  persist();
  emit();
}

export function touchMission() {
  if (!runtime) return;
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