#!/usr/bin/env bash
echo "🧩 Final Assembly..."

cat << 'EOF' > app/page.tsx
"use client";

import CommandHeader from "@/components/ui/CommandHeader";
import DivisionDeck from "@/components/deck/DivisionDeck";
import LayoutDeck from "@/components/deck/LayoutDeck";
import LearningDeck from "@/components/deck/LearningDeck";
import SystemStatusDeck from "@/components/deck/SystemStatusDeck";
import Oracle from "@/components/ui/Oracle";

export default function HomePage() {
  return (
    <main className="min-h-screen px-8 py-10 space-y-10">
      <CommandHeader />

      <section className="max-w-5xl space-y-8">
        <DivisionDeck />
        <LayoutDeck />
        <LearningDeck />
        <SystemStatusDeck />
      </section>

      <Oracle />
    </main>
  );
}
EOF

echo "🚀 North Star UI fully assembled"
npm run dev