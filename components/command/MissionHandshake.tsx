"use client";

import { useEffect, useRef } from "react";
import { useMissionRuntime } from "@/lib/useMissionRuntime";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

type Props = {
  lessonId: string;
  division: Division;
};

export default function MissionHandshake({ lessonId, division }: Props) {
  const { runtime, startMission, touchMission } = useMissionRuntime();
  const didInit = useRef(false);

  useEffect(() => {
    if (!didInit.current) {
      if (!runtime || runtime.lessonId !== lessonId) {
        startMission({ lessonId, division });
      }
      didInit.current = true;
    }

    // keep mission warm (SAFE throttled)
    touchMission();
    // ⚠️ NO runtime deps — intentional
  }, [lessonId, division]);

  return null;
}