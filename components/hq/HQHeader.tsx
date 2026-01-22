"use client";

import { useEffect, useState } from "react";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function HQHeader() {
  const { runtime } = useMissionRuntime();
  const [mounted, setMounted] = useState(false);

  // ✅ hydration guard
  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return (
      <div className="py-6 border-b border-white/10">
        <div className="text-sm text-white/40">
          Initialising Command Interface…
        </div>
      </div>
    );
  }

  return (
    <div className="py-6 border-b border-white/10">
      <div className="flex items-center justify-between">
        <div>
          <div className="text-xs tracking-[0.3em] text-white/40">
            COMMAND HQ
          </div>

          <div className="text-lg text-white mt-1">
            {runtime
              ? "Mission in progress — resume or abort."
              : "No active mission. Choose your next action."}
          </div>
        </div>
      </div>
    </div>
  );
}