import type { GuardianSignal } from "./guardianIntel";

export type GuardianEvent = {
  lessonId: string;
  signal: GuardianSignal;
  at: string;
};

const KEY = "nca:guardian:log";

export function logGuardianEvent(event: GuardianEvent) {
  if (typeof window === "undefined") return;

  const raw = localStorage.getItem(KEY);
  const events = raw ? JSON.parse(raw) : [];
  events.push(event);
  localStorage.setItem(KEY, JSON.stringify(events));
}
