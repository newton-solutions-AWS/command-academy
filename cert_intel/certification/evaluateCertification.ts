import { CERTIFICATION_THRESHOLDS } from "./thresholds";

type Transcript = {
  learner_id: string;
  completed_canons: string[];
  total_lessons_completed: number;
  engine_versions: string[];
};

type CertificationResult = {
  certification_id: string;
  title: string;
  status: "certified" | "not_certified";
  evidence: {
    lessons_completed: number;
    lessons_required: number;
    engine_version: string;
  };
};

export function evaluateCertification(
  transcript: Transcript
): CertificationResult[] {
  return CERTIFICATION_THRESHOLDS.map(threshold => {
    const lessonsCompleted = transcript.completed_canons.includes(
      threshold.canon
    )
      ? transcript.total_lessons_completed
      : 0;

    const engineValid = transcript.engine_versions.includes(
      threshold.engine_version
    );

    const certified =
      lessonsCompleted >= threshold.required_lessons && engineValid;

    return {
      certification_id: threshold.id,
      title: threshold.title,
      status: certified ? "certified" : "not_certified",
      evidence: {
        lessons_completed: lessonsCompleted,
        lessons_required: threshold.required_lessons,
        engine_version: threshold.engine_version
      }
    };
  });
}


