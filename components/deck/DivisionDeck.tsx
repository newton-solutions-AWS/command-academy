"use client";

import { ToggleGroup } from "@/components/ui/ToggleGroup";
import type { Division } from "@/lib/uiStore";

export default function DivisionDeck({
  value,
  onChange,
}: {
  value: Division;
  onChange: (v: Division) => void;
}) {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">DIVISION CONTROL</div>
          <div className="panel-sub">Access & Identity</div>
        </div>
      </div>

      <ToggleGroup
        tone="green"
        options={["VANGUARD", "PHOENIX", "SENTINEL"]}
        value={value}
        onChange={onChange}
      />
    </section>
  );
}
