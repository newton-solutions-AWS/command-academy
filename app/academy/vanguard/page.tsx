import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";

interface PageProps {
  params: {
    lessonId: string;
  };
}

export default function VanguardLessonPage({ params }: PageProps) {
  const lesson = loadLessonById(params.lessonId);

  if (!lesson || lesson.division !== "vanguard") {
    return (
      <Shell>
        <CommandHeader title="Lesson not found" division="vanguard" />
        <div className="mt-8">
          <Panel title="INVALID LESSON" variant="restricted">
            <a className="underline text-blue-300" href="/academy/vanguard">
              Back to Vanguard lessons
            </a>
          </Panel>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <CommandHeader
        title={lesson.title}
        subtitle={`Lesson ID: ${lesson.id} • ${lesson.duration_minutes} mins`}
        division="vanguard"
      />

      <div className="grid gap-4 mt-8">
        <Panel title="CONCEPT" variant="active">
          <p className="text-white/75 whitespace-pre-wrap">
            {lesson.concept}
          </p>
        </Panel>

        <Panel title="WALKTHROUGH">
          <p className="text-white/75 whitespace-pre-wrap">
            {lesson.walkthrough}
          </p>
        </Panel>

        <Panel title="OBJECTIVES">
          <ul className="list-disc pl-5 text-white/75 space-y-2">
            {lesson.objectives.map((o) => (
              <li key={o}>{o}</li>
            ))}
          </ul>
        </Panel>
      </div>
    </Shell>
  );
}