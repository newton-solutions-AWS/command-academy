// cert_intel/intake/lib/phoenixLessons.ts
import type { CanonLesson } from "./canonTypes";

export const phoenixLessons: Record<string, CanonLesson> = {
  "phoenix-boot-001": {
    id: "phoenix-boot-001",
    title: "Phoenix Induction: Mission Zero",
    division: "phoenix",
    difficulty: "foundation",
    concept:
      "Transition from a service mindset to a cyber operator mindset. Establish identity, confidence, and mission structure.",
    objectives: [
      "Understand Phoenix Division doctrine",
      "Understand how missions operate",
      "Adopt the operator mindset",
    ],
    walkthrough:
      "You are entering the Newton Command Academy as a Phoenix operator. This mission introduces how lessons, missions, and progression work.",
    steps: [
      "Read Phoenix doctrine",
      "Understand mission structure",
      "Acknowledge your transition role",
    ],
    duration_minutes: 20,
  },
};