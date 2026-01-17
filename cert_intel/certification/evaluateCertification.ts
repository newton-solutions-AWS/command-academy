import { Transcript } from "../transcript/generateTranscript";

export interface CertificationResult {
  status: "PASS" | "FAIL";
  awarded: string[];
  reason?: string;
}

export function evaluateCertification(
  transcript: Transcript
): CertificationResult {
  // Stub logic for now — correct shape enforced
  if (transcript.total_lessons_completed === 0) {
    return {
      status: "FAIL",
      awarded: [],
      reason: "No lessons completed",
    };
  }

  return {
    status: "PASS",
    awarded: transcript.completed_canons,
  };
}