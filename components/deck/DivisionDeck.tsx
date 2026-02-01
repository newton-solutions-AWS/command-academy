import React from "react";
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";
import type { Division } from "@/lib/uiTypes";

export default function DivisionDeck({
  division,
  setDivision,
}: {
  division: Division;
  setDivision: (d: Division) => void;
}) {
  return (
    <Panel
      title="DIVISION SELECT"
      subtitle="Phoenix has full access. Vanguard paid access. Sentinel elite add-on unless Phoenix."
      variant="active"
    >
      <ToggleGroup
        label="Division"
        value={division}
        onChange={setDivision}
        options={[
          { value: "phoenix", label: "Phoenix", hint: "Service → Cyber. Full access." },
          { value: "vanguard", label: "Vanguard", hint: "Civilian paid. No Sentinel unless upgraded." },
          { value: "sentinel", label: "Sentinel", hint: "Elite ops. Hard gates." },
        ]}
      />
    </Panel>
  );
}
