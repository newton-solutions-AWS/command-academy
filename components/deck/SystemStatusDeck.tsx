"use client";

import type { UIState } from "@/lib/uiStore";

export default function SystemStatusDeck({ ui }: { ui: UIState }) {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">SYSTEM STATUS</div>
          <div className="panel-sub">Deterministic readout</div>
        </div>
      </div>

      <div className="mono text-sm leading-7 text-neutral-300">
        <div>
          Division: <span className="text-green-300">{ui.division}</span>
        </div>
        <div>
          Layout: <span className="text-neutral-200">{ui.layout}</span>
        </div>
        <div>
          Learning: <span className="text-neutral-200">{ui.learning}</span>
        </div>
      </div>
    </section>
  );
}
