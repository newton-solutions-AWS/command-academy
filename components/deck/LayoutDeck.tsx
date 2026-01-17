"use client";

import { ToggleGroup } from "@/components/ui/ToggleGroup";
import type { Layout } from "@/lib/uiStore";

export default function LayoutDeck({
  value,
  onChange,
}: {
  value: Layout;
  onChange: (v: Layout) => void;
}) {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">INTERFACE LAYOUT</div>
          <div className="panel-sub">Reality Filter</div>
        </div>
      </div>

      <ToggleGroup
        tone="green"
        options={["TACTICAL", "UNIVERSITY", "GOVERNMENT"]}
        value={value}
        onChange={onChange}
      />
    </section>
  );
}
