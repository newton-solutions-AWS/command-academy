export type Division = "VANGUARD" | "PHOENIX" | "SENTINEL";
export type Layout = "TACTICAL" | "UNIVERSITY" | "GOVERNMENT";
export type Learning = "GAMIFIED" | "VISUAL" | "TEXT";

export interface UIState {
  division: Division;
  layout: Layout;
  learning: Learning;
}

export const defaultUIState: UIState = {
  division: "VANGUARD",
  layout: "TACTICAL",
  learning: "GAMIFIED",
};
