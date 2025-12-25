import { z } from "zod";

/**
 * LOCKED SCHEMA v1
 * Purpose: Allow deterministic generation without retries.
 * No minimum lengths. No minimum array sizes.
 * Structure is enforced, content quality is handled by audit.
 */

const StringArray = z.array(z.string()).default([]);

export const LessonSchema = z.object({
  // --- Identity ---
  id: z.string(),
  canon: z.string(),
  version: z.string(),

  // --- Metadata ---
  title: z.string().default("Untitled Lesson"),
  objectives: StringArray,
  duration_minutes: z.number().default(30),
  tags: StringArray,

  // --- Mission ---
  mission_brief: z.object({
    situation: z.string().default(""),
    task: z.string().default(""),
    intent: z.string().default("")
  }).default({
    situation: "",
    task: "",
    intent: ""
  }),

  // --- Content ---
  content: z.object({
    concept: z.string().default(""),
    walkthrough: z.string().default(""),
    checkpoints: StringArray,
    common_mistakes: StringArray
  }).default({
    concept: "",
    walkthrough: "",
    checkpoints: [],
    common_mistakes: []
  }),

  // --- Lab ---
  lab: z.object({
    type: z.enum(["terminal-sim", "webcontainer", "guided-cli"])
      .default("guided-cli"),

    steps: StringArray,

    validate: z.object({
      command: z.string().default(""),
      expected: z.string().default("")
    }).default({
      command: "",
      expected: ""
    }),

    safety: StringArray
  }).default({
    type: "guided-cli",
    steps: [],
    validate: { command: "", expected: "" },
    safety: []
  }),

  // --- Elite Competence ---
  elite_competence: z.object({
    scenario_name: z.string().default(""),
    role_simulation: z.string().default(""),
    bug_injection: z.record(z.string(), z.any()).default({}),
    success_criteria: z.object({
      pass_conditions: StringArray,
      fail_conditions: StringArray
    }).default({
      pass_conditions: [],
      fail_conditions: []
    }),
    interrogation_questions: StringArray
  }).default({
    scenario_name: "",
    role_simulation: "",
    bug_injection: {},
    success_criteria: {
      pass_conditions: [],
      fail_conditions: []
    },
    interrogation_questions: []
  }),

  // --- Legal ---
  legal_context: z.object({
    allowed: StringArray,
    forbidden: StringArray,
    notes: z.string().default("")
  }).default({
    allowed: [],
    forbidden: [],
    notes: ""
  }),

  // --- Career ---
  resume_bullets: StringArray
});

export type Lesson = z.infer<typeof LessonSchema>;