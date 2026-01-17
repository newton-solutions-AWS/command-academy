"use client";

import { useMemo, useState } from "react";

import CommandHeader from "@/components/ui/CommandHeader";
import DivisionDeck from "@/components/deck/DivisionDeck";
import LayoutDeck from "@/components/deck/LayoutDeck";
import LearningDeck from "@/components/deck/LearningDeck";
import SystemStatusDeck from "@/components/deck/SystemStatusDeck";

import { defaultUIState } from "@/lib/uiStore";

export default function Page() {
  const [ui, setUI] = useState(defaultUIState);

  const glow = useMemo(() => {
    // deterministic (based on state only)
    if (ui.division === "PHOENIX") return "bg-amber-500/10";
    if (ui.division === "SENTINEL") return "bg-red-500/10";
    return "bg-green-500/10";
  }, [ui.division]);

  return (
    <main className="screen">
      <div className="screen-noise" />
      <div className={`screen-glow ${glow}`} />

      <div className="wrap">
        <CommandHeader />

        <div className="grid gap-8">
          <DivisionDeck
            value={ui.division}
            onChange={(division) => setUI((p) => ({ ...p, division }))}
          />

          <LayoutDeck
            value={ui.layout}
            onChange={(layout) => setUI((p) => ({ ...p, layout }))}
          />

          <LearningDeck
            value={ui.learning}
            onChange={(learning) => setUI((p) => ({ ...p, learning }))}
          />

          <SystemStatusDeck ui={ui} />
        </div>
      </div>
    </main>
  );
}
