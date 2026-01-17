#!/usr/bin/env bash

echo "🔥 NEWTON COMMANDER INITIALISING..."

# --- SAFETY CHECK ---
if [ ! -f package.json ]; then
  echo "❌ ERROR: Run this from the project root (package.json not found)"
  exit 1
fi

echo "🧹 Clearing broken UI state..."
rm -rf components/ui
rm -rf components/deck
rm -rf app/page.tsx

mkdir -p components/ui
mkdir -p components/deck
mkdir -p app

# --- GLOBALS ---
cat << 'EOF' > app/globals.css
@tailwind base;
@tailwind components;
@tailwind utilities;

html,
body {
  background: black;
}
EOF

# --- LAYOUT ---
cat << 'EOF' > app/layout.tsx
import "./globals.css";

export const metadata = {
  title: "Newton Command Academy",
  description: "Executable Reality Command Interface",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-black text-neutral-200">
        {children}
      </body>
    </html>
  );
}
EOF

# --- PAGE ---
cat << 'EOF' > app/page.tsx
"use client";

import CommandHeader from "@/components/ui/CommandHeader";
import DivisionDeck from "@/components/deck/DivisionDeck";
import LayoutDeck from "@/components/deck/LayoutDeck";
import LearningDeck from "@/components/deck/LearningDeck";

export default function HomePage() {
  return (
    <main className="min-h-screen px-8 py-10 space-y-10">
      <CommandHeader />
      <section className="max-w-5xl space-y-8">
        <DivisionDeck />
        <LayoutDeck />
        <LearningDeck />
      </section>
    </main>
  );
}
EOF

# --- UI COMPONENTS ---
cat << 'EOF' > components/ui/CommandHeader.tsx
export default function CommandHeader() {
  return (
    <header className="space-y-2">
      <p className="text-xs tracking-widest text-neutral-400">
        NEWTON COMMAND ACADEMY
      </p>
      <h1 className="text-3xl font-semibold tracking-wide">
        COMMAND INTERFACE
      </h1>
      <p className="text-sm text-neutral-400">
        Configure operational posture before deployment.
      </p>
    </header>
  );
}
EOF

cat << 'EOF' > components/ui/Panel.tsx
export default function Panel({
  title,
  subtitle,
  children,
}: {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}) {
  return (
    <section className="rounded-xl border border-neutral-800 bg-neutral-950 p-6 space-y-4">
      <div>
        <h2 className="text-sm tracking-widest text-neutral-400">{title}</h2>
        {subtitle && <p className="text-xs text-neutral-500">{subtitle}</p>}
      </div>
      {children}
    </section>
  );
}
EOF

cat << 'EOF' > components/ui/ToggleGroup.tsx
export default function ToggleGroup({
  options,
  active,
}: {
  options: string[];
  active: string;
}) {
  return (
    <div className="flex gap-2">
      {options.map((opt) => (
        <button
          key={opt}
          className={
            "px-4 py-2 rounded-md text-xs tracking-wide border " +
            (opt === active
              ? "border-green-500 text-green-400"
              : "border-neutral-700 text-neutral-400 hover:border-neutral-500")
          }
        >
          {opt}
        </button>
      ))}
    </div>
  );
}
EOF

# --- DECKS ---
cat << 'EOF' > components/deck/DivisionDeck.tsx
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";

export default function DivisionDeck() {
  return (
    <Panel title="DIVISION CONTROL" subtitle="Access & Identity">
      <ToggleGroup
        options={["VANGUARD", "PHOENIX", "SENTINEL"]}
        active="VANGUARD"
      />
    </Panel>
  );
}
EOF

cat << 'EOF' > components/deck/LayoutDeck.tsx
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";

export default function LayoutDeck() {
  return (
    <Panel title="INTERFACE LAYOUT" subtitle="Reality Filter">
      <ToggleGroup
        options={["TACTICAL", "UNIVERSITY", "GOVERNMENT"]}
        active="TACTICAL"
      />
    </Panel>
  );
}
EOF

cat << 'EOF' > components/deck/LearningDeck.tsx
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";

export default function LearningDeck() {
  return (
    <Panel title="LEARNING MODE" subtitle="Cognitive Style">
      <ToggleGroup
        options={["GAMIFIED", "VISUAL", "TEXT"]}
        active="GAMIFIED"
      />
    </Panel>
  );
}
EOF

echo "✅ NORTH STAR UI DEPLOYED"
echo "🚀 Starting dev server..."
npm run dev