export type LessonContent = {
  concept: string;
  walkthrough: string;
  checkpoints: string[];
  common_mistakes?: string[]; // optional
};

export type CanonLesson = {
  id: string;
  title: string;
  division: "phoenix" | "vanguard" | "sentinel";
  content?: LessonContent; // 🔑 OPTIONAL ON PURPOSE
};