import React from "react";
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";
import type { LearningMode, InterfaceMode } from "@/lib/uiTypes";

export default function LearningDeck({
  interfaceMode,
  setInterfaceMode,
  learningMode,
  setLearningMode,
}: {
  interfaceMode: InterfaceMode;
  setInterfaceMode: (m: InterfaceMode) => void;
  learningMode: LearningMode;
  setLearningMode: (m: LearningMode) => void;
}) {
  return (
    <Panel title="COGNITIVE STACK" subtitle="Layout and learning style are independent.">
      <div className="space-y-6">
        <ToggleGroup
          label="Interface tone"
          value={interfaceMode}
          onChange={setInterfaceMode}
          options={[
            { value: "operator", label: "Operator", hint: "Command energy. Tactical." },
            { value: "scholar", label: "Scholar", hint: "University calm. Deep theory." },
            { value: "classified", label: "Classified", hint: "Intel dossier style." },
          ]}
        />
        <ToggleGroup
          label="Learning mode"
          value={learningMode}
          onChange={setLearningMode}
          options={[
            { value: "gamified", label: "Gamified", hint: "Missions + XP + unlocks." },
            { value: "socratic", label: "Socratic", hint: "Questions drive mastery." },
            { value: "visual", label: "Visual", hint: "Diagrams + breakdowns." },
            { value: "video", label: "Video-led", hint: "Briefings + replays." },
            { value: "text", label: "Text-first", hint: "Manuals + docs." },
            { value: "exam-cram", label: "Exam Cram", hint: "Newton crams by objective." },
          ]}
        />
      </div>
    </Panel>
  );
}
