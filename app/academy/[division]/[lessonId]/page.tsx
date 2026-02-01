// app/academy/[division]/[lessonId]/page.tsx
import LessonShell from "@/components/command/LessonShell";
import { getLesson } from "@/cert_intel/intake/lib/lessonRegistry";
import { notFound } from "next/navigation";

type Props = {
  params: {
    division: string;
    lessonId: string;
  };
};

export default function LessonPage({ params }: Props) {
  const lesson = getLesson(params.division, params.lessonId);

  if (!lesson) {
    notFound();
  }

  return <LessonShell lesson={lesson} />;
}