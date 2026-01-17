import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";

export default function AcademyIndex() {
  return (
    <Shell>
      <CommandHeader
        title="Academy Directory"
        subtitle="Choose your division."
        division="phoenix"
      />

      <div className="grid gap-4 mt-8 lg:grid-cols-3">
        <Panel title="PHOENIX">
          <a className="underline text-blue-300" href="/academy/phoenix">
            Open Phoenix Lessons
          </a>
        </Panel>
        <Panel title="VANGUARD">
          <a className="underline text-blue-300" href="/academy/vanguard">
            Open Vanguard Lessons
          </a>
        </Panel>
        <Panel title="SENTINEL">
          <a className="underline text-blue-300" href="/academy/sentinel">
            Open Sentinel Lessons
          </a>
        </Panel>
      </div>
    </Shell>
  );
}
