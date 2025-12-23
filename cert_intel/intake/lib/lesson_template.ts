export const LESSON_TEMPLATE = {
  id: "",
  canon: "",
  version: "",
  title: "",

  objectives: ["", "", ""],
  prerequisites: [],
  duration_minutes: 45,

  tags: ["security", "cloud", "operations"],

  mission_brief: {
    shadow_corp: "Aegis Logistics",
    briefing: "",
    rules_of_engagement: ["", "", ""],
  },

  content: {
    concept: "",
    walkthrough: "",
    checkpoints: ["", "", ""],
    common_mistakes: ["", "", ""],
  },

  lab: {
    type: "guided-cli",
    setup: "",
    steps: ["", "", "", "", ""],
    validate: {
      command: "",
      expected: "",
    },
    safety: ["", "", ""],
  },

  elite_competence: {
    scenario_name: "",
    role_simulation: "",
    bug_injection: {
      description: "",
      bad_state: "",
    },
    success_criteria: {
      verification_command: "",
      expected_output: "",
    },
    interrogation_questions: ["", "", ""],
  },

  legal_context: {
    jurisdiction: "UK",
    laws: ["UK GDPR", "Computer Misuse Act 1990"],
    compliance_focus: ["data protection", "least privilege"],
    operator_duties: [
      "Protect sensitive data",
      "Operate within authorised access boundaries",
    ],
  },

  accessibility: {
    reading_level: "standard",
    dyslexia_friendly: true,
    alt_text_summary: "",
  },

  resume_bullets: ["", "", ""],
};