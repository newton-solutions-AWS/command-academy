import { CanonLesson } from "./canonTypes";

export function validateLesson(lesson: CanonLesson): void {
  if (!lesson.id) throw new Error("Lesson missing id");
  if (!lesson.title) throw new Error(`Lesson ${lesson.id} missing title`);
  if (!lesson.division) throw new Error(`Lesson ${lesson.id} missing division`);

  if (!lesson.concept || lesson.concept.trim().length < 20) {
    throw new Error(`Lesson ${lesson.id} has weak concept section`);
  }

  if (!lesson.walkthrough || lesson.walkthrough.trim().length < 40) {
    throw new Error(`Lesson ${lesson.id} has weak walkthrough section`);
  }
}