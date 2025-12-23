import { z } from "zod";

export const CompletionSchema = z.object({
  learner_id: z.string().min(3),
  org: z.string(),
  canon: z.string(),
  version: z.string(),
  lesson_id: z.string(),
  engine_version: z.string(),
  completed_at: z.string().datetime()
});