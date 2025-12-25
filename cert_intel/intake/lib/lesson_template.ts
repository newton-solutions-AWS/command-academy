export const LESSON_TEMPLATE = {
  title: "",
  objectives: [],
  duration_minutes: 30,
  tags: [],

  mission_brief: {
    mission: "",
    why_it_matters: "",
    success_definition: "",
  },

  prerequisites: ["Basic CLI familiarity"],

  content: {
    concept: "",
    walkthrough: "",
    checkpoints: [],
    common_mistakes: [],
  },

  lab: {
    type: "terminal-sim",
    setup: "",
    steps: [],
    safety: [],
    validate: {
      command: "",
      expected: {
        type: "json",
        must_have_paths: ["$"],
      },
    },
  },

  elite_competence: {
    scenario_name: "",
    role_simulation: "",
    bug_injection: {
      description: "",
      hint: "",
    },
    success_criteria: {
      pass_conditions: [],
      fail_conditions: [],
    },
    interrogation_questions: [],
  },

  resume_bullets: [],

  legal_context: {
    authorized_use: "",
    prohibited_use: "",
    data_handling: "",
  },

  accessibility: {
    alt_text_summary: "",
  },
};