#!/usr/bin/env bash
set -euo pipefail

echo "== NEWTON COMMAND ACADEMY :: HQ DECK COMMANDER =="

# --- Folders ---
mkdir -p components/deck
mkdir -p app/hq

# --- ORACLE DECK ---
cat > components/deck/OracleDeck.tsx <<'TSX'
"use client";

export default function OracleDeck() {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">ORACLE AI</div>
          <div className="panel-sub">Suggestion Engine</div>
        </div>
      </div>

      <div className="mono text-sm text-neutral-300 leading-6">
        Try:
        <ul className="mt-2 list-disc list-inside text-neutral-400">
          <li>"Open AWS track"</li>
          <li>"Go to lesson 3"</li>
          <li>"Explain this like I'm new"</li>
        </ul>
      </div>

      <div className="mt-4 flex gap-3">
        <button className="toggle toggle-active border-green-500/60 text-green-300">
          Open Oracle
        </button>
        <button className="toggle toggle-idle">
          Voice (soon)
        </button>
      </div>
    </section>
  );
}
TSX

# --- DIVISION STATUS ---
cat > components/deck/DivisionStatusDeck.tsx <<'TSX'
"use client";

const divisions = [
  { name: "AWS", status: "Online" },
  { name: "Azure", status: "Online" },
  { name: "GCP", status: "Online" },
  { name: "Security", status: "Online" },
  { name: "DevOps", status: "Online" },
];

export default function DivisionStatusDeck() {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">DIVISION STATUS</div>
          <div className="panel-sub">Operational Readiness</div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 text-sm">
        {divisions.map((d) => (
          <div
            key={d.name}
            className="flex justify-between rounded-md border border-white/10 px-3 py-2"
          >
            <span className="text-neutral-300">{d.name}</span>
            <span className="text-green-400">{d.status}</span>
          </div>
        ))}
      </div>
    </section>
  );
}
TSX

# --- HQ DECK ---
cat > components/deck/HQDeck.tsx <<'TSX'
"use client";

import OracleDeck from "./OracleDeck";
import DivisionStatusDeck from "./DivisionStatusDeck";

export default function HQDeck() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
      <div className="md:col-span-2">
        <OracleDeck />
      </div>
      <DivisionStatusDeck />
    </div>
  );
}
TSX

# --- HQ PAGE ---
cat > app/hq/page.tsx <<'TSX'
import HQDeck from "@components/deck/HQDeck";

export default function HQPage() {
  return (
    <main className="screen">
      <div className="screen-noise" />
      <div className="screen-glow bg-green-500/10" />

      <div className="wrap">
        <div className="mb-10">
          <div className="text-xs tracking-[0.3em] text-neutral-500">
            NEWTON COMMAND ACADEMY
          </div>
          <h1 className="mt-3 text-4xl font-semibold">
            HQ DASHBOARD
          </h1>
          <p className="mt-3 text-sm text-neutral-400 max-w-xl">
            Command overview · Oracle access · Division readiness
          </p>
        </div>

        <HQDeck />
      </div>
    </main>
  );
}
TSX

echo
echo "== HQ DECK DEPLOYED =="
echo "Visit: http://localhost:3000/hq"
