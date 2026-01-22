export type GuardianSignal =
  | "STALLING"
  | "SKIP_DETECTED"
  | "RAPID_TOGGLE"
  | "MISSION_COMPLETE"
  | "CLEAN_RUN";

export type GuardianAssessment = {
  signal: GuardianSignal;
  message: string;
};

export function assessMission(
  steps: string[],
  completed: Record<number, boolean>,
  timestamps: number[]
): GuardianAssessment {
  const total = steps.length;
  const done = Object.keys(completed).length;

  // Completed clean
  if (done === total) {
    return {
      signal: "MISSION_COMPLETE",
      message: "Mission complete. Log service record and proceed.",
    };
  }

  // Stalling: nothing done for a while
  const now = Date.now();
  const last = timestamps[timestamps.length - 1] ?? 0;
  if (now - last > 1000 * 60 * 4) {
    return {
      signal: "STALLING",
      message:
        "You’ve been idle. Re-read the current step and execute deliberately.",
    };
  }

  // Skip detection
  for (let i = 0; i < done; i++) {
    if (!completed[i]) {
      return {
        signal: "SKIP_DETECTED",
        message:
          "You’ve skipped a step. Complete steps in order for a clean run.",
      };
    }
  }

  // Rapid toggling (panic clicking)
  if (timestamps.length >= 4) {
    const delta =
      timestamps[timestamps.length - 1] -
      timestamps[timestamps.length - 4];
    if (delta < 4000) {
      return {
        signal: "RAPID_TOGGLE",
        message:
          "Slow down. This is not speed-based. Execute one step properly.",
      };
    }
  }

  return {
    signal: "CLEAN_RUN",
    message: "Proceed methodically. You are on track.",
  };
}
