export type Division = "phoenix" | "vanguard" | "sentinel";
export type Difficulty = "foundation" | "intermediate" | "advanced";

export interface CanonLesson {
  id: string;
  title: string;
  division: Division;
  difficulty: Difficulty;
  duration_minutes: number;
  concept: string;
  walkthrough: string;
  objectives: string[];
}
