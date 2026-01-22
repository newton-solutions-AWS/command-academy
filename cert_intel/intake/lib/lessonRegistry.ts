// cert_intel/intake/lib/lessonRegistry.ts
import type { CanonLesson } from "./canonTypes";
import { phoenixLessons } from "./phoenixLessons";

export function getLesson(
  division: string,
  lessonId: string
): CanonLesson | null {
  if (division === "phoenix") {
    return phoenixLessons[lessonId] ?? null;
  }

  return null;
}