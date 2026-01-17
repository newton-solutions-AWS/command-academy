import type { CanonLesson } from "./canonTypes";

export function loadCanonLessons(
  division?: "phoenix" | "vanguard" | "sentinel"
): CanonLesson[] {
  const allLessons: CanonLesson[] = [
    {
      id: "intro-001",
      title: "Welcome to the Newton Command Academy",
      division: "phoenix",
      difficulty: "foundation",
      duration_minutes: 20,
      concept: "Orientation to the Command Academy mission and structure.",
      walkthrough: "You will be introduced to the academy systems and ranks.",
      objectives: ["Understand academy structure"],
    },
    {
      id: "linux-001",
      title: "Linux Fundamentals",
      division: "vanguard",
      difficulty: "foundation",
      duration_minutes: 45,
      concept: "Linux basics for operators.",
      walkthrough: "Learn filesystem, permissions, and CLI basics.",
      objectives: ["Navigate Linux"],
    },
    {
      id: "threat-001",
      title: "Threat Landscape",
      division: "sentinel",
      difficulty: "advanced",
      duration_minutes: 60,
      concept: "Understanding modern cyber threats.",
      walkthrough: "Analyse attacker motivations and methods.",
      objectives: ["Identify threats"],
    },
  ];

  return division
    ? allLessons.filter(l => l.division === division)
    : allLessons;
}

/** 🔒 CANON LOOKUP — THIS IS THE KEY */
export function loadLessonById(
  division: "phoenix" | "vanguard" | "sentinel",
  lessonId: string
): CanonLesson | undefined {
  return loadCanonLessons(division).find(l => l.id === lessonId);
}