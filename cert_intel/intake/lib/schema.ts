// cert_intel/intake/lib/schema.ts
import { z } from "zod";

/**
 * Phoenix Protocol v2 — Canonical Lesson Schema
 * Deterministic, audit-safe, runtime-safe
 */

export const LessonSchema = z.object({
  id: z.string().min(5),
  canon: z.string().min(3),
  version: z.string().min(2),

  title: z.string().min(10),

  objectives: z.array(z.string().min(5)).min(3),

  duration_minutes: z.number().min(5),

  tags: z.array(z.string().min(2)).min(1),

  mission_brief: z.object({
    situation: z.string().min(30),
    mission: z.string().min(30),
    execution: z.string().min(30),
  }),

  prerequisites: z.array(z.string().min(5)).min(1),

  content: z.object({
    concept: z.string().min(200),
    walkthrough: z.string().min(200),
    checkpoints: z.array(z.string().min(5)).min(3),
    common_mistakes: z.array(z.string().min(10)).min(3),
  }),

  lab: z.object({
    type: z.literal("guided-cli"),
    setup: z.string().min(10),

    steps: z
      .array(z.string().min(5))
      .min(1)
      .refine(
        steps => steps.some(s => s.trim().startsWith("aws ")),
        { message: "lab.steps must include at least one 'aws ...' command" }
      ),

    safety: z.array(z.string().min(5)).min(3),

    validate: z.object({
      command: z.string().min(5),
      expected: z.literal(""),
      match: z.literal("contains"),
    }),
  }),

  elite_competence: z.object({
    scenario_name: z.string().min(10),
    role_simulation: z.string().min(50),

    bug_injection: z.object({
      bug: z.string().min(10),
      symptom: z.string().min(10),
      fix: z.string().min(10),
    }),

    success_criteria: z.object({
      pass_conditions: z.array(z.string().min(5)).min(3),
      fail_conditions: z.array(z.string().min(5)).min(2),
    }),

    interrogation_questions: z.array(z.string().min(10)).min(3),
  }),

  /**
   * IMPORTANT:
   * Phoenix v2 uses STRING legal context
   * (Gemini audit approved)
   */
  legal_context: z.object({
    allowed: z.string().min(20),
    prohibited: z.string().min(20),
  }),

  resume_bullets: z.array(z.string().min(10)).min(3),
});

export type Lesson = z.infer<typeof LessonSchema>;