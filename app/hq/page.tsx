"use client";

import { useEffect, useState } from "react";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import MissionLauncher from "@/components/hq/MissionLauncher";

export default function HQPage() {
  /**
   * Page-level hydration gate
   * Server + first client render MUST match
   */
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // ✅ Stable SSR output
  if (!mounted) {
    return (
      <main className="mx-auto max-w-6xl px-6 py-10">
        <div className="rounded-2xl border border-white/10 bg-black/30 p-6">
          <div className="text-white/50 text-sm">
            Initialising HQ…
          </div>
        </div>
      </main>
    );
  }

  // ✅ Client-only HQ
  return (
    <main className="mx-auto max-w-6xl px-6 py-10 space-y-6">
      <ActiveMissionCard />
      <MissionLauncher />
    </main>
  );
}