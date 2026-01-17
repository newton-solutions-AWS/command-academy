import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { lessonHref } from "@/lib/nav";

export default function PhoenixIndex() {
  const lessons = loadCanonLessons("phoenix");
  return (
    <Shell>
      <CommandHeader title="Phoenix Lessons" division="phoenix" />
      <div className="grid gap-4 mt-8">
        {lessons.map((l) => (
          <Panel key={l.id} title={l.id} subtitle={l.title}>
            <a className="underline text-blue-300" href={lessonHref("phoenix", l.id)}>
              Open lesson
            </a>
          </Panel>
        ))}
      </div>
    </Shell>
  );
}
