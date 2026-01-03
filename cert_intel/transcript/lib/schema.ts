import { z } from "zod";

export const TranscriptEventSchema = z.object({
  // core identity
  ts: z.string().min(10), // ISO timestamp
  student_id: z.string().min(1),
  canon: z.string().min(1),
  version: z.string().min(1),
  lesson_id: z.string().min(1),

  // outcome
  outcome: z.enum(["PASS", "FAIL"]),
  attempt: z.number().int().min(1).default(1),

  // provenance
  engine: z.string().min(1).default("unknown"),
  model: z.string().min(1).default("unknown"),
  region: z.string().optional(),

  // validation snapshot (what the learner actually ran)
  validate: z.object({
    command: z.string().min(1),
    expected: z.string(), // allow empty string
    match: z.enum(["exact", "contains"]).default("exact"),
  }),

  // evidence (keep simple + safe)
  stdout_preview: z.string().max(2000).default(""),
  stderr_preview: z.string().max(2000).default(""),
  exit_code: z.number().int().min(0).max(255).default(0),
});

export type TranscriptEvent = z.infer<typeof TranscriptEventSchema>;

export const TranscriptStatusSchema = z.object({
  student_id: z.string().min(1),
  canon: z.string().min(1),
  version: z.string().min(1),

  // deterministic summary
  passed_lessons: z.array(z.string()),
  failed_lessons: z.array(z.string()),
  total_events: z.number().int().min(0),

  // eligibility (you can tighten later)
  eligible_for_certificate: z.boolean(),
});

export type TranscriptStatus = z.infer<typeof TranscriptStatusSchema>;
