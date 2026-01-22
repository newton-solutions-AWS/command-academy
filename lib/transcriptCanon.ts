import type { Division } from "@/cert_intel/intake/lib/canonTypes";

export type TranscriptEntry = {
  lessonId: string;
  title: string;
  division: Division;
  completedAt: string;
  durationMinutes: number;
};

export type Transcript = {
  learnerId: string;
  generatedAt: string;
  entries: TranscriptEntry[];
};
