"use client";

import { useMemo } from "react";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

function Pill({ label }: { label: string }) {
  return (
    <div className="px-3 py-1.5 rounded-full border border-white/10 bg-white/5 text-xs text-white/75">
      {label}
    </div>
  );
}

export default function StatusStrip() {
  const { runtime } = useMissionRuntime();

  const label = useMemo(() => {
    if (!runtime) return "MISSION: IDLE";
    return `MISSION: ACTIVE • ${runtime.division.toUpperCase()} • ${runtime.lessonId}`;
  }, [runtime]);

  return (
    <div className="flex flex-wrap gap-2 items-center">
      <Pill label={label} />
    </div>
  );
}
