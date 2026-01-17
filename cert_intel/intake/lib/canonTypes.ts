export type Division = "phoenix" | "vanguard" | "sentinel";
export type Difficulty = "foundation" | "intermediate" | "advanced";

export interface CanonLesson {
  id: string;
  title: string;
  division: Division;
  difficulty: Difficulty;
  duration_minutes: number;

  // CORE DOCTRINAL REQUIREMENTS
  concept: string;
  walkthrough: string;

  // OPTIONAL EXTENSIONS
  labs?: string[];
  objectives?: string[];
}