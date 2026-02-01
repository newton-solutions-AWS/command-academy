// cert_intel/intake/lib/canonLessonStub.ts
import type { CanonLesson } from "./canonTypes";

export function createCanonLessonStub(
  id: string,
  division: string
): CanonLesson {
  return {
    id,
    title: "System Bootstrap Lesson",
    division: division as any,
    difficulty: "foundation",
    concept: "System bootstrap lesson",
    objectives: [],
    walkthrough: "This lesson is a placeholder.",
    steps: [],
    duration_minutes: 10,
  };
}