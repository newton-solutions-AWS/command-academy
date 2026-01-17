import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

interface Props {
  params: { division: Division; lessonId: string };
}

export default function LessonPage({ params }: Props) {
  const lesson = loadLessonById(params.lessonId);

  if (!lesson || lesson.division !== params.division) {
    return (
      <Shell>
        <CommandHeader title="Lesson not found" division={params.division} />
        <div className="mt-8">
          <Panel
            title="NO LESSON FOUND"
            subtitle={`Requested: ${params.division}/${params.lessonId}`}
            variant="restricted"
          >
            <a className="underline text-blue-300" href={`/academy/${params.division}`}>
              Back to division index
            </a>
          </Panel>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <CommandHeader title={lesson.title} division={lesson.division} subtitle={`ID: ${lesson.id} • ${lesson.duration_minutes} mins`} />
      <div className="grid gap-4 mt-8">
        <Panel title="CONCEPT" variant="active">
          <p className="text-white/75 whitespace-pre-wrap">{lesson.concept}</p>
        </Panel>
        <Panel title="WALKTHROUGH">
          <p className="text-white/75 whitespace-pre-wrap">{lesson.walkthrough}</p>
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
