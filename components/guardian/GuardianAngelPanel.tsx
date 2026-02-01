"use client";

import { useEffect, useMemo, useState } from "react";
import {
  getMissionRuntime,
  toggleStepComplete,
  setStepIndex,
} from "@/lib/missionRuntimeStore";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lessonId: string;
  division: Division;
  steps: string[];
};

export default function GuardianAngelPanel({
  lessonId,
  division,
  steps,
}: Props) {
  const storageKey = useMemo(
    () => `${division}:${lessonId}`,
    [division, lessonId]
  );

  const [mounted, setMounted] = useState(false);
  const [completed, setCompleted] = useState<Record<number, boolean>>({});
  const [open, setOpen] = useState(true);

  useEffect(() => {
    setMounted(true);

    const rt = getMissionRuntime();
    if (
      rt &&
      `${rt.division}:${rt.lessonId}` === storageKey
    ) {
      setCompleted(rt.completedSteps ?? {});
    } else {
      setCompleted({});
    }
  }, [storageKey]);

  if (!mounted) return null;

  const doneCount = Object.values(completed).filter(Boolean).length;
  const total = steps.length || 1;
  const pct = Math.round((doneCount / total) * 100);

  function onToggleStep(i: number) {
    toggleStepComplete(i);
    const rt = getMissionRuntime();
    setCompleted(rt?.completedSteps ?? {});
    setStepIndex(i);
  }

  return (
    <div className="rounded-2xl border border-white/10 bg-black/40 backdrop-blur-xl shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_60px_rgba(0,0,0,0.55)]">
      <div className="flex items-center justify-between gap-3 px-5 py-4 border-b border-white/10">
        <div>
          <div className="text-xs tracking-[0.28em] text-white/50">
            GUARDIAN ANGEL
          </div>
          <div className="text-sm text-white/80 mt-1">
            Step-by-step mission support
          </div>
        </div>

        <div className="flex items-center gap-2">
          <div className="text-xs text-white/60 tabular-nums">
            {doneCount}/{steps.length} • {pct}%
          </div>
          <button
            onClick={() => setOpen(!open)}
            className="px-3 py-1.5 text-xs rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/80"
          >
            {open ? "Collapse" : "Expand"}
          </button>
        </div>
      </div>

      {open && (
        <div className="p-5">
          <ol className="space-y-2">
            {steps.map((s, i) => {
              const isDone = !!completed[i];
              return (
                <li
                  key={i}
                  className="flex items-start gap-3 rounded-xl border border-white/10 bg-white/5 px-4 py-3"
                >
                  <button
                    onClick={() => onToggleStep(i)}
                    className={[
                      "mt-0.5 h-5 w-5 rounded-md border flex items-center justify-center",
                      isDone
                        ? "border-emerald-400/40 bg-emerald-500/10"
                        : "border-white/20 bg-black/30",
                    ].join(" ")}
                    aria-label={
                      isDone ? "Mark incomplete" : "Mark complete"
                    }
                  >
                    {isDone ? (
                      <span className="text-emerald-300 text-xs">✓</span>
                    ) : (
                      <span className="text-white/30 text-xs">•</span>
                    )}
                  </button>

                  <div className="flex-1">
                    <div className="text-xs tracking-[0.22em] text-white/40">
                      STEP {String(i + 1).padStart(2, "0")}
                    </div>
                    <div
                      className={[
                        "text-sm mt-1",
                        isDone ? "text-white/85" : "text-white/70",
                      ].join(" ")}
                    >
                      {s}
                    </div>
                  </div>
                </li>
              );
            })}
          </ol>
        </div>
      )}
    </div>
  );
}