import type { UiState } from "./uiTypes";

export const DEFAULT_UI: UiState = {
  division: "phoenix",
  interfaceMode: "operator",
  learningMode: "gamified",
  layoutMode: "north-star",
};

const KEY = "newton-command-ui";

export function loadUi(): UiState {
  if (typeof window === "undefined") return DEFAULT_UI;
  try {
    const raw = window.localStorage.getItem(KEY);
    if (!raw) return DEFAULT_UI;
    const parsed = JSON.parse(raw) as Partial<UiState>;
    return { ...DEFAULT_UI, ...parsed };
  } catch {
    return DEFAULT_UI;
  }
}

export function saveUi(next: UiState) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(KEY, JSON.stringify(next));
}
