import LessonShell from "@/components/command/LessonShell";
import { phoenixLessons } from "@/cert_intel/intake/lib/lessons";
import type { CanonLesson } from "@/cert_intel/intake/lib/canonTypes";
import { notFound } from "next/navigation";

type Props = {
  params: {
    lessonId: string;
  };
};

export default function PhoenixLessonPage({ params }: Props) {
  const lesson: CanonLesson | undefined =
    phoenixLessons[params.lessonId];

  if (!lesson) {
    notFound();
  }

  return <LessonShell lesson={lesson} />;
}