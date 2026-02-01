#!/usr/bin/env bash
set -e

echo "== HQ DASHBOARD COMMANDER =="

mkdir -p components/deck app/hq

cat > components/deck/OracleDeck.tsx <<'TSX'
"use client";

export default function OracleDeck() {
  return (
    <div className="panel">
      <div className="panel-kicker">ORACLE AI</div>
      <ul className="mt-3 text-sm text-neutral-400 space-y-1">
        <li>"Open AWS track"</li>
        <li>"Go to lesson 3"</li>
        <li>"Explain this like I'm new"</li>
      </ul>
      <div className="mt-4 flex gap-3">
        <button className="toggle toggle-active">OPEN ORACLE</button>
        <button className="toggle toggle-idle">VOICE (SOON)</button>
      </div>
    </div>
  );
}
TSX

cat > components/deck/DivisionStatusDeck.tsx <<'TSX'
"use client";

const divisions = ["AWS","Azure","GCP","Security","DevOps"];

export default function DivisionStatusDeck() {
  return (
    <div className="panel">
      <div className="panel-kicker">DIVISION STATUS</div>
      <div className="mt-3 space-y-2 text-sm">
        {divisions.map(d => (
          <div key={d} className="flex justify-between">
            <span>{d}</span>
            <span className="text-green-400">Online</span>
          </div>
        ))}
      </div>
    </div>
  );
}
TSX

cat > app/hq/page.tsx <<'TSX'
import OracleDeck from "@/components/deck/OracleDeck";
import DivisionStatusDeck from "@/components/deck/DivisionStatusDeck";

export default function HQ() {
  return (
    <main className="screen">
      <div className="wrap grid md:grid-cols-3 gap-8">
        <div className="md:col-span-2">
          <OracleDeck />
        </div>
        <DivisionStatusDeck />
      </div>
    </main>
  );
}
TSX

echo "HQ Dashboard deployed."
