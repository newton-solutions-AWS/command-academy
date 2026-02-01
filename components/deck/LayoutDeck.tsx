import React from "react";
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";
import type { LayoutMode } from "@/lib/uiTypes";

export default function LayoutDeck({
  layoutMode,
  setLayoutMode,
}: {
  layoutMode: LayoutMode;
  setLayoutMode: (m: LayoutMode) => void;
}) {
  return (
    <Panel title="LAYOUT MODE" subtitle="Your interface skin. Same standards, different vibe.">
      <ToggleGroup
        label="Layout"
        value={layoutMode}
        onChange={setLayoutMode}
        options={[
          { value: "north-star", label: "North Star", hint: "Blue doctrine. Command clean." },
          { value: "cod-hq", label: "COD HQ", hint: "Gamified ops dashboard." },
          { value: "intel-brief", label: "Intel Brief", hint: "Govt dossier / briefing." },
        ]}
      />
    </Panel>
  );
}
