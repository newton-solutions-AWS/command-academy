export type Division = "VANGUARD" | "PHOENIX" | "SENTINEL";
export type LayoutMode = "TACTICAL" | "UNIVERSITY" | "GOVERNMENT";
export type LearningMode = "GAMIFIED" | "VISUAL" | "TEXT";

export type UiState = {
  division: Division;
  layout: LayoutMode;
  learning: LearningMode;
  noiseReduction: boolean;
};