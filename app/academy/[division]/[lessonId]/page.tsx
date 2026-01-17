import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";

interface LessonPageProps {
  params: {
    division: "phoenix" | "vanguard" | "sentinel";
    lessonId: string;
  };
}

export default function LessonPage({ params }: LessonPageProps) {
  const lesson = loadLessonById(params.division, params.lessonId);

  if (!lesson) {
    return (
      <div className="p-8 text-red-400">
        ❌ No lesson found for {params.division}/{params.lessonId}
      </div>
    );
  }

  return (
    <div className="p-8 space-y-6">
      <h1 className="text-2xl font-bold">{lesson.title}</h1>
      <p className="text-slate-300">{lesson.concept}</p>
      <p className="text-slate-400">{lesson.walkthrough}</p>
    </div>
  );
}