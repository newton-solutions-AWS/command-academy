"use client";

import { useEffect, useState } from "react";
import {
  getMissionRuntime,
  subscribe,
  startMission,
  abortMission,
  touchMission,
  setStepIndex,
  toggleStepComplete,
  addMissionNote,
} from "./missionRuntimeStore";

import type { MissionRuntime } from "./missionRuntimeStore";

export function useMissionRuntime() {
  const [runtime, setRuntime] = useState<MissionRuntime | null>(null);

  useEffect(() => {
    // initial read
    setRuntime(getMissionRuntime());

    // subscribe to store updates
    const unsubscribe = subscribe(() => {
      setRuntime(getMissionRuntime());
    });

    return unsubscribe;
  }, []);

  return {
    runtime,

    // commands (re-exported for components)
    startMission,
    abortMission,
    touchMission,
    setStepIndex,
    toggleStepComplete,
    addMissionNote,
  };
}