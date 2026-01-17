import type { CanonLesson } from "./canonTypes";

const LESSONS: CanonLesson[] = [
  {
    id: "intro-001",
    title: "Welcome to Newton Command Academy",
    division: "phoenix",
    difficulty: "foundation",
    duration_minutes: 12,
    concept:
      "This is your induction. The Academy runs as missions, not lectures. The Guardian Angel keeps you moving, step-by-step.",
    walkthrough:
      "1) Confirm your division and layout.\n2) Open HQ.\n3) Enter the Mission Simulator.\n4) Complete the first objective and log your progress.\n5) Debrief and unlock the next door.",
    objectives: [
      "Understand the division model (Phoenix/Vanguard/Sentinel)",
      "Understand Interface Mode vs Learning Mode",
      "Run your first mission loop",
    ],
  },
  {
    id: "linux-001",
    title: "Linux Foundations: Terminal Dominance",
    division: "vanguard",
    difficulty: "foundation",
    duration_minutes: 22,
    concept:
      "Linux is the spine of cloud and security. You don’t learn it by reading — you learn it by command, repetition, and missions.",
    walkthrough:
      "1) Identify your shell.\n2) Learn pwd/ls/cd.\n3) Create directories, move files.\n4) Read logs.\n5) Pass the checkpoint drill.",
    objectives: ["Navigate a filesystem", "Edit and view files", "Understand basic permissions"],
  },
  {
    id: "threat-001",
    title: "Sentinel Ops: Threat Modelling 101",
    division: "sentinel",
    difficulty: "intermediate",
    duration_minutes: 28,
    concept:
      "Threat modelling is how professionals stop guessing. You map assets, entry points, controls, and adversary paths.",
    walkthrough:
      "1) Define system boundary.\n2) List assets.\n3) Enumerate threats.\n4) Rank by impact/likelihood.\n5) Propose mitigations.\n6) Debrief.",
    objectives: ["Model threats clearly", "Communicate risk", "Choose practical mitigations"],
  },
];

export function loadCanonLessons(division?: "phoenix" | "vanguard" | "sentinel"): CanonLesson[] {
  if (!division) return LESSONS;
  return LESSONS.filter((l) => l.division === division);
}

export function loadLessonById(lessonId: string): CanonLesson | null {
  return LESSONS.find((l) => l.id === lessonId) ?? null;
}
