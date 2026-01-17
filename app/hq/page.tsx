import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";

export default function HQPage() {
  return (
    <Shell>
      <CommandHeader
        title="Operator HQ"
        subtitle="COD-HQ style hub. This becomes the mission launcher + progress + war room."
        division="phoenix"
      />

      <div className="grid gap-4 mt-8 lg:grid-cols-3">
        <Panel title="MISSION SIMULATOR" subtitle="Launch, run, debrief.">
          <div className="text-white/70 text-sm">
            Placeholder for mission queue, guardian angel prompts, and live objectives.
          </div>
        </Panel>

        <Panel title="CAREER WAR ROOM" subtitle="Proof of work + CV outputs.">
          <div className="text-white/70 text-sm">
            Placeholder for signed transcripts, employer trust portal, and skill decay tracking.
          </div>
        </Panel>

        <Panel title="BOARD OF INQUIRY" subtitle="Truth Engine QA + exams.">
          <div className="text-white/70 text-sm">
            Placeholder for exam crams, interrogations, and mastery checks.
          </div>
        </Panel>
      </div>
    </Shell>
  );
}
