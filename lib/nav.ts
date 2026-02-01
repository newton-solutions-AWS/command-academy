import type { Division } from "./uiTypes";

export function lessonHref(division: Division, lessonId: string) {
  return `/academy/${division}/${lessonId}`;
}
