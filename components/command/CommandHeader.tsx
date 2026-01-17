"use client";

import { useEffect, useState } from "react";

export default function CommandHeader({
  atilsOnline,
  noiseReduction,
  operatorMode,
}: {
  atilsOnline?: boolean;
  noiseReduction?: boolean;
  operatorMode?: string;
}) {
  const [clock, setClock] = useState<string>("");

  // Hydration-safe: time only exists on client
  useEffect(() => {
    const tick = () => {
      const now = new Date();
      const dd = String(now.getDate()).padStart(2, "0");
      const mm = String(now.getMonth() + 1).padStart(2, "0");
      const yyyy = now.getFullYear();
      const hh = String(now.getHours()).padStart(2, "0");
      const min = String(now.getMinutes()).padStart(2, "0");
      setClock(`${dd}/${mm}/${yyyy} ${hh}:${min}`);
    };

    tick();
    const id = window.setInterval(tick, 1000 * 15);
    return () => window.clearInterval(id);
  }, []);

  return (
    <header className="mb-12">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3 text-xs tracking-widest text-neutral-500">
          <span className="text-neutral-400">NEWTON</span>
          <span className="text-green-400">COMMAND</span>
          <span className="text-neutral-600">•</span>
          <span className="flex items-center gap-2">
            <span className="inline-block h-2 w-2 rounded-full bg-green-400 shadow-[0_0_20px_rgba(0,255,65,0.35)]" />
            <span className={atilsOnline ? "text-neutral-400" : "text-neutral-600"}>
              ATILS ONLINE
            </span>
          </span>
        </div>

        <div className="flex items-center gap-3">
          <Pill label={`NOISE REDUCTION: ${noiseReduction ? "ON" : "OFF"}`} />
          <Pill label={operatorMode ?? "STANDARD OPERATOR MODE"} />
        </div>
      </div>

      <div className="mt-10 flex items-start justify-between gap-10">
        <div>
          <p className="text-xs tracking-widest text-neutral-500">
            NEWTON COMMAND ACADEMY
          </p>

          <h1 className="mt-3 text-5xl font-semibold tracking-[0.22em] text-neutral-100">
            COMMAND INTERFACE
          </h1>

          <p className="mt-3 text-sm text-neutral-400">
            Configure operational posture before deployment.
          </p>
        </div>

        <div className="hidden md:block">
          <div className="rounded-xl border border-neutral-800 bg-black/40 px-5 py-4 min-w-[320px]">
            <div className="text-[11px] tracking-widest text-neutral-500 mb-2">
              SYSTEM TIME (LOCAL)
            </div>
            <div
              className="text-sm text-neutral-200"
              suppressHydrationWarning
            >
              {clock || "—"}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}

function Pill({ label }: { label: string }) {
  return (
    <div className="px-3 py-1 rounded-full border border-neutral-700 text-[11px] tracking-widest text-neutral-300 bg-black/30">
      {label}
    </div>
  );
}