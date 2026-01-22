#!/usr/bin/env bash
set -euo pipefail

echo "== NEWTON COMMAND ACADEMY :: NORTH STAR UI COMMANDER =="

# --- 0) Sanity check ---
if [ ! -f "package.json" ]; then
  echo "ERROR: Run this from your Next.js project root (where package.json lives)."
  exit 1
fi

# --- 1) Create canonical folders ---
mkdir -p components/ui
mkdir -p components/deck
mkdir -p lib
mkdir -p app

# --- 2) tsconfig.json (aliases + stable defaults) ---
cat > tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"],
      "@components/*": ["components/*"],
      "@lib/*": ["lib/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
JSON

# --- 3) UI State Engine ---
cat > lib/uiStore.ts <<'TS'
export type Division = "VANGUARD" | "PHOENIX" | "SENTINEL";
export type Layout = "TACTICAL" | "UNIVERSITY" | "GOVERNMENT";
export type Learning = "GAMIFIED" | "VISUAL" | "TEXT";

export interface UIState {
  division: Division;
  layout: Layout;
  learning: Learning;
}

export const defaultUIState: UIState = {
  division: "VANGUARD",
  layout: "TACTICAL",
  learning: "GAMIFIED",
};
TS

# --- 4) UI Atoms ---
cat > components/ui/CommandHeader.tsx <<'TSX'
"use client";

export default function CommandHeader() {
  return (
    <header className="mb-10">
      <div className="text-xs tracking-[0.3em] text-neutral-500">
        NEWTON COMMAND ACADEMY
      </div>
      <h1 className="mt-3 text-4xl font-semibold tracking-[0.25em]">
        COMMAND INTERFACE
      </h1>
      <p className="mt-3 text-sm text-neutral-400 max-w-xl">
        Configure operational posture before deployment.
      </p>
    </header>
  );
}
TSX

cat > components/ui/ToggleGroup.tsx <<'TSX'
"use client";

interface ToggleGroupProps<T extends string> {
  options: readonly T[];
  value: T;
  onChange: (v: T) => void;
  tone?: "green" | "amber" | "red";
}

function toneClasses(tone: "green" | "amber" | "red") {
  if (tone === "amber") return "border-amber-500/70 text-amber-300 shadow-[0_0_30px_rgba(245,158,11,0.12)]";
  if (tone === "red") return "border-red-500/70 text-red-300 shadow-[0_0_30px_rgba(239,68,68,0.12)]";
  return "border-green-500/70 text-green-300 shadow-[0_0_30px_rgba(34,197,94,0.12)]";
}

export function ToggleGroup<T extends string>({
  options,
  value,
  onChange,
  tone = "green",
}: ToggleGroupProps<T>) {
  return (
    <div className="flex flex-wrap gap-3">
      {options.map((opt) => {
        const active = value === opt;
        return (
          <button
            key={opt}
            type="button"
            onClick={() => onChange(opt)}
            className={[
              "toggle",
              active ? `toggle-active ${toneClasses(tone)}` : "toggle-idle",
            ].join(" ")}
          >
            {opt}
          </button>
        );
      })}
    </div>
  );
}
TSX

# --- 5) Decks (Sections) ---
cat > components/deck/DivisionDeck.tsx <<'TSX'
"use client";

import { ToggleGroup } from "@components/ui/ToggleGroup";
import type { Division } from "@lib/uiStore";

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
TSX

cat > components/deck/LayoutDeck.tsx <<'TSX'
"use client";

import { ToggleGroup } from "@components/ui/ToggleGroup";
import type { Layout } from "@lib/uiStore";

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
TSX

cat > components/deck/LearningDeck.tsx <<'TSX'
"use client";

import { ToggleGroup } from "@components/ui/ToggleGroup";
import type { Learning } from "@lib/uiStore";

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
TSX

cat > components/deck/SystemStatusDeck.tsx <<'TSX'
"use client";

import type { UIState } from "@lib/uiStore";

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
TSX

# --- 6) Page (Source of Truth) ---
cat > app/page.tsx <<'TSX'
"use client";

import { useMemo, useState } from "react";

import CommandHeader from "@components/ui/CommandHeader";
import DivisionDeck from "@components/deck/DivisionDeck";
import LayoutDeck from "@components/deck/LayoutDeck";
import LearningDeck from "@components/deck/LearningDeck";
import SystemStatusDeck from "@components/deck/SystemStatusDeck";

import { defaultUIState } from "@lib/uiStore";

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
TSX

# --- 7) Layout + Globals ---
# If you already have app/layout.tsx, we won't overwrite it unless you want.
# But we DO ensure globals.css exists and is imported by your layout.
if [ ! -f "app/layout.tsx" ] && [ ! -f "app/layout.jsx" ] && [ ! -f "app/layout.js" ]; then
cat > app/layout.tsx <<'TSX'
import "./globals.css";

export const metadata = {
  title: "Newton Command Academy",
  description: "Newton Command Academy // Command Interface",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
TSX
fi

cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

/* --- NEWTON COMMAND :: NORTH STAR THEME --- */
:root {
  --bg: #050505;
  --panel: rgba(0,0,0,0.55);
  --border: rgba(255,255,255,0.09);
  --text: rgba(255,255,255,0.92);
  --muted: rgba(255,255,255,0.55);
}

html, body {
  height: 100%;
  background: var(--bg);
  color: var(--text);
}

body {
  margin: 0;
}

.mono {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
}

.screen {
  min-height: 100vh;
  position: relative;
  overflow: hidden;
  background: radial-gradient(1200px 700px at 40% 10%, rgba(34,197,94,0.12), transparent 55%),
              radial-gradient(900px 600px at 80% 30%, rgba(34,197,94,0.08), transparent 55%),
              linear-gradient(180deg, #050505, #07070a);
}

.screen-noise {
  pointer-events: none;
  position: absolute;
  inset: -20%;
  opacity: 0.05;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='120' height='120'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.8' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='120' height='120' filter='url(%23n)' opacity='.7'/%3E%3C/svg%3E");
  transform: rotate(8deg);
}

.screen-glow {
  pointer-events: none;
  position: absolute;
  inset: 0;
  opacity: 1;
  filter: blur(80px);
}

.wrap {
  position: relative;
  z-index: 2;
  max-width: 1100px;
  margin: 0 auto;
  padding: 64px 32px;
}

.panel {
  position: relative;
  border-radius: 14px;
  border: 1px solid var(--border);
  background: linear-gradient(180deg, rgba(0,0,0,0.68), rgba(0,0,0,0.35));
  backdrop-filter: blur(10px);
  padding: 26px;
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.04),
    0 30px 90px rgba(0,0,0,0.55);
}

.panel:before {
  content: "";
  position: absolute;
  left: 24px;
  right: 24px;
  top: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.18), transparent);
}

.panel-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 18px;
}

.panel-kicker {
  font-size: 11px;
  letter-spacing: 0.22em;
  color: rgba(255,255,255,0.58);
}

.panel-sub {
  margin-top: 6px;
  font-size: 12px;
  color: rgba(255,255,255,0.42);
}

.toggle {
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.12);
  padding: 10px 16px;
  font-size: 12px;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  transition: transform 120ms ease, border-color 120ms ease, box-shadow 120ms ease, color 120ms ease;
}

.toggle-idle {
  background: rgba(0,0,0,0.4);
  color: rgba(255,255,255,0.55);
}

.toggle-idle:hover {
  transform: translateY(-1px);
  border-color: rgba(255,255,255,0.18);
  color: rgba(255,255,255,0.75);
}

.toggle-active {
  background: rgba(0,0,0,0.65);
}

CSS

# --- 8) Tailwind + PostCSS (JS configs) ---
cat > tailwind.config.js <<'JS'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {}
  },
  plugins: []
};
JS

cat > postcss.config.js <<'JS'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {}
  }
};
JS

echo
echo "== DONE =="
echo "Next:"
echo "  1) rm -rf .next"
echo "  2) npm run dev"
echo
echo "If VSCode highlights @tailwind as unknown at-rule, that's lint-only. The build is fine."
