export interface Transcript {
  learner_id: string;
  completed_canons: string[];
  total_lessons_completed: number;
  engine_versions: {
    lesson_engine: string;
    certification_engine: string;
  };
}

export function generateTranscript(learnerId: string): Transcript {
  return {
    learner_id: learnerId,
    completed_canons: [],
    total_lessons_completed: 0,
    engine_versions: {
      lesson_engine: "v1-stub",
      certification_engine: "v1-stub",
    },
  };
}