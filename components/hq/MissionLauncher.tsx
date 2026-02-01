"use client";

import { useRouter } from "next/navigation";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export default function MissionLauncher() {
  const router = useRouter();
  const { runtime, startMission } = useMissionRuntime();

  if (runtime) return null;

  const lessonId = "intro-001";
  const division: Division = "phoenix";

  function launch() {
    startMission({ lessonId, division });
    router.push(`/academy/${division}/${lessonId}`);
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/30 p-6">
      <div className="text-xs tracking-[0.25em] text-white/40">
        QUICK START
      </div>
      <h3 className="text-lg text-white mt-2">
        Begin your next mission
      </h3>
      <p className="text-white/60 text-sm mt-1">
        Launch directly into the Academy onboarding mission.
      </p>

      <button
        onClick={launch}
        className="mt-4 px-5 py-2.5 rounded-xl bg-white text-black text-sm font-medium hover:bg-white/90 transition"
      >
        Launch Mission
      </button>
    </div>
  );
}
