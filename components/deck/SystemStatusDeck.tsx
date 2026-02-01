import React from "react";
import Panel from "@/components/ui/Panel";
import Badge from "@/components/ui/Badge";

export default function SystemStatusDeck({
  lessonCount,
}: {
  lessonCount: number;
}) {
  return (
    <Panel title="SYSTEM STATUS" subtitle="Engine online. Gates active. Content canon locked.">
      <div className="flex flex-wrap gap-2">
        <Badge variant="blue">UI: GREEN</Badge>
        <Badge variant="blue">ROUTING: GREEN</Badge>
        <Badge variant="blue">ATILS ENGINE: ONLINE</Badge>
        <Badge variant="default">LESSONS: {lessonCount}</Badge>
        <Badge variant="default">MODE: SIMULATOR</Badge>
      </div>
      <div className="text-white/55 text-sm mt-4">
        Next step: expand canon lessons + wire Guardian Angel mission simulator loops.
      </div>
    </Panel>
  );
}
