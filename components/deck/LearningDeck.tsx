"use client";

import { ToggleGroup } from "@/components/ui/ToggleGroup";
import type { Learning } from "@/lib/uiStore";

export default function LearningDeck({
  value,
  onChange,
}: {
  value: Learning;
  onChange: (v: Learning) => void;
}) {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">LEARNING MODE</div>
          <div className="panel-sub">Cognitive Style</div>
        </div>
      </div>

      <ToggleGroup
        tone="green"
        options={["GAMIFIED", "VISUAL", "TEXT"]}
        value={value}
        onChange={onChange}
      />
    </section>
  );
}
