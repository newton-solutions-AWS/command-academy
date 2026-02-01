export type Division = "phoenix" | "vanguard" | "sentinel";
export type InterfaceMode = "operator" | "scholar" | "classified";
export type LearningMode =
  | "gamified"
  | "socratic"
  | "visual"
  | "video"
  | "text"
  | "exam-cram";

export type LayoutMode = "north-star" | "cod-hq" | "intel-brief";

export interface UiState {
  division: Division;
  interfaceMode: InterfaceMode;
  learningMode: LearningMode;
  layoutMode: LayoutMode;
}
