export type Division = "phoenix" | "vanguard" | "sentinel";
export type Difficulty = "foundation" | "intermediate" | "advanced" | "elite";

export type CanonLesson = {
  id: string;
  title: string;
  division: Division;
  difficulty: Difficulty;

  concept: string;
  walkthrough: string;
  objectives: string[];

  duration_minutes: number;
  steps?: string[];
};
