#!/usr/bin/env bash
set -e

echo "== COMMAND INTERFACE COMMANDER =="

mkdir -p app

cat > app/page.tsx <<'TSX'
"use client";

import Panel from "@/components/ui/Panel";
import Toggle from "@/components/ui/Toggle";
import { useState } from "react";

export default function CommandInterface() {
  const [division, setDivision] = useState("VANGUARD");
  const [layout, setLayout] = useState("TACTICAL");
  const [learning, setLearning] = useState("GAMIFIED");

  return (
    <main className="screen">
      <div className="screen-glow bg-green-500/10" />

      <div className="wrap space-y-8">
        <header>
          <div className="text-xs tracking-[0.3em] text-neutral-500">
            NEWTON COMMAND ACADEMY
          </div>
          <h1 className="mt-3 text-4xl font-semibold">COMMAND INTERFACE</h1>
          <p className="mt-2 text-sm text-neutral-400">
            Configure operational posture before deployment.
          </p>
        </header>

        <Panel title="DIVISION CONTROL" subtitle="Access & Identity">
          <div className="flex gap-3">
            {["VANGUARD","PHOENIX","SENTINEL"].map(d => (
              <button key={d} onClick={() => setDivision(d)}>
                <Toggle active={division === d}>{d}</Toggle>
              </button>
            ))}
          </div>
        </Panel>

        <Panel title="INTERFACE LAYOUT" subtitle="Reality Filter">
          <div className="flex gap-3">
            {["TACTICAL","UNIVERSITY","GOVERNMENT"].map(l => (
              <button key={l} onClick={() => setLayout(l)}>
                <Toggle active={layout === l}>{l}</Toggle>
              </button>
            ))}
          </div>
        </Panel>

        <Panel title="LEARNING MODE" subtitle="Cognitive Style">
          <div className="flex gap-3">
            {["GAMIFIED","VISUAL","TEXT"].map(m => (
              <button key={m} onClick={() => setLearning(m)}>
                <Toggle active={learning === m}>{m}</Toggle>
              </button>
            ))}
          </div>
        </Panel>
      </div>
    </main>
  );
}
TSX

echo "Command Interface deployed."
