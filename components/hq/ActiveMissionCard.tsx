"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";

export default function ActiveMissionCard() {
  const router = useRouter();
  const { runtime, abortMission } = useMissionRuntime();

  const [mounted, setMounted] = useState(false);

  // ✅ hydration guard
  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;
  if (!runtime) return null;

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl p-5 shadow-[0_20px_60px_rgba(0,0,0,0.6)]">
      <div className="text-xs tracking-[0.3em] text-white/50">
        ACTIVE MISSION
      </div>

      <div className="mt-2 text-lg text-white">
        {runtime.lessonId}
      </div>

      <div className="mt-1 text-sm text-white/60">
        Division: {runtime.division}
      </div>

      <div className="mt-4 flex gap-2">
        <button
          onClick={() =>
            router.push(
              `/academy/${runtime.division}/${runtime.lessonId}`
            )
          }
          className="px-4 py-2 text-sm rounded-lg bg-white/10 hover:bg-white/20 text-white"
        >
          Resume
        </button>

        <button
          onClick={abortMission}
          className="px-4 py-2 text-sm rounded-lg bg-red-500/20 hover:bg-red-500/30 text-red-300"
        >
          Abort
        </button>
      </div>
    </div>
  );
}