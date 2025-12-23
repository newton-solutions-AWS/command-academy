import { z } from "zod";

/* ─────────────────────────────
   ELITE COMPETENCE — BROKEN ARROW
───────────────────────────── */
export const EliteCompetenceSchema = z.object({
  scenario_name: z.string().min(5),
  role_simulation: z.string().min(10),

  bug_injection: z.object({
    description: z.string().min(10),
    file_path: z.string().optional(),
    bad_state: z.string().min(10),
  }),

  success_criteria: z.object({
    verification_command: z.string().min(1),
    expected_output: z.string().min(1),
    max_time_minutes: z.number().optional(),
  }),

  interrogation_questions: z.array(z.string().min(10)).min(3),
});

/* ─────────────────────────────
   LEGAL CONTEXT (UK DEFAULT)
───────────────────────────── */
export const LegalContextSchema = z.object({
  jurisdiction: z.string().default("UK"),
  laws: z.array(z.string().min(5)).min(2),
  compliance_focus: z.array(z.string().min(5)).min(2),
  operator_duties: z.array(z.string().min(10)).min(2),
});

/* ─────────────────────────────
   CORE LESSON SCHEMA
───────────────────────────── */
export const LessonSchema = z.object({
  id: z.string().min(3),
  canon: z.string().min(3),
  version: z.string().min(1),
  title: z.string().min(5),

  objectives: z.array(z.string().min(10)).min(3),
  prerequisites: z.array(z.string().min(3)).default([]),
  duration_minutes: z.number().min(5).max(240),

  tags: z.array(z.string().min(3)).min(3),

  mission_brief: z.object({
    shadow_corp: z.string().default("Aegis Logistics"),
    briefing: z.string().min(50),
    rules_of_engagement: z.array(z.string().min(10)).min(3),
  }),

  content: z.object({
    concept: z.string().min(200),
    walkthrough: z.string().min(200),
    checkpoints: z.array(z.string().min(10)).min(3),
    common_mistakes: z.array(z.string().min(10)).min(3),
  }),

  lab: z.object({
    type: z.enum(["terminal-sim", "webcontainer", "guided-cli"]),
    setup: z.string().min(20),
    steps: z.array(z.string().min(10)).min(5),
    validate: z.object({
      command: z.string().min(1),
      expected: z.string().min(1),
    }),
    safety: z.array(z.string().min(10)).min(3),
  }),

  elite_competence: EliteCompetenceSchema,
  legal_context: LegalContextSchema,

  accessibility: z.object({
    reading_level: z.enum(["simple", "standard", "advanced"]).default("standard"),
    dyslexia_friendly: z.boolean().default(true),
    alt_text_summary: z.string().min(30),
  }),

  resume_bullets: z.array(z.string().min(15)).min(3),
});

export type Lesson = z.infer<typeof LessonSchema>;