import type { CanonLesson, Division } from "./canonTypes";

function deriveSteps(lesson: CanonLesson): string[] {
  if (lesson.steps && Array.isArray(lesson.steps) && lesson.steps.length > 0) return lesson.steps;

  const lines = (lesson.walkthrough || "")
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);

  const numbered = lines.filter((l) => /^\d+\)/.test(l) || /^\d+\./.test(l));
  const base = numbered.length ? numbered : lines;

  const trimmed = base.slice(0, 12);
  if (trimmed.length) return trimmed;

  return [
    "Confirm your division and interface posture.",
    "Open HQ and review mission status.",
    "Read the concept block once, slowly.",
    "Execute the walkthrough steps in order.",
    "Tick off objectives, then debrief.",
  ];
}

export function loadCanonLessons(division?: Division): CanonLesson[] {
  const allLessons: CanonLesson[] = [
    {
      id: "intro-001",
      title: "Welcome to the Newton Command Academy",
      division: "phoenix",
      difficulty: "foundation",
      duration_minutes: 12,
      concept:
        "This is your induction. The Academy runs as missions, not lectures. The Guardian Angel keeps you moving, step-by-step.",
      walkthrough: [
        "1) Confirm your division and layout.",
        "2) Open HQ.",
        "3) Enter the Mission Simulator.",
        "4) Complete the first objective and log your progress.",
        "5) Debrief and unlock the next door.",
      ].join("\n"),
      objectives: [
        "Understand the division model (Phoenix/Vanguard/Sentinel)",
        "Understand HQ ↔ Lesson mission handshake",
        "Complete a clean first mission cycle",
      ],
    },
    {
      id: "linux-001",
      title: "Linux Foundations: Terminal Dominance",
      division: "vanguard",
      difficulty: "foundation",
      duration_minutes: 22,
      concept:
        "The terminal is your weapon system. You will learn navigation, inspection, permissions, and safe execution discipline.",
      walkthrough: [
        "1) Open a terminal and print your working directory.",
        "2) List files with detail.",
        "3) Create a folder structure for ops.",
        "4) Create a file, inspect it, and delete it safely.",
        "5) Debrief: explain what changed and why.",
      ].join("\n"),
      objectives: [
        "Move around the filesystem with intent",
        "Use ls/cat/touch/mkdir/rm safely",
        "Adopt a clean operational workflow",
      ],
    },
    {
      id: "threat-001",
      title: "Sentinel Ops: Threat Modelling 101",
      division: "sentinel",
      difficulty: "intermediate",
      duration_minutes: 28,
      concept:
        "Threat modelling is how professionals stop guessing. You map assets, entry points, controls, and adversary paths.",
      walkthrough: [
        "1) Define the system boundary.",
        "2) List assets.",
        "3) Enumerate threats.",
        "4) Rank by impact/likelihood.",
        "5) Propose mitigations.",
        "6) Debrief.",
      ].join("\n"),
      objectives: [
        "Create a basic threat model",
        "Identify assets and trust boundaries",
        "Propose mitigations aligned to risk",
      ],
    },
  ];

  const normalized = allLessons.map((l) => ({ ...l, steps: deriveSteps(l) }));
  if (!division) return normalized;
  return normalized.filter((l) => l.division === division);
}

export function loadLessonById(lessonId: string): CanonLesson | undefined {
  const all = loadCanonLessons();
  return all.find((l) => l.id === lessonId);
}
