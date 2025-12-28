// cert_intel/intake/lib/lesson_template.ts

export type PhoenixV2PromptInput = {
  lessonId: string;
  lessonNumber: number;
  canon: string;
  version: string;
  archetype: string;
  region?: string;
};

export function buildPhoenixV2Prompt(input: PhoenixV2PromptInput): string {
  const {
    lessonId,
    lessonNumber,
    canon,
    version,
    archetype,
    region,
  } = input;

  return `
You are generating a SINGLE Phoenix Protocol v2 lesson artifact.

THIS OUTPUT MUST BE VALID JSON.
NO MARKDOWN.
NO COMMENTS.
NO TEXT OUTSIDE JSON.
DO NOT EXPLAIN.

========================
HARD CONSTRAINTS (MANDATORY)
========================

1. Every string minimum MUST be met or exceeded.
2. Arrays MUST meet minimum lengths.
3. lab.steps MUST contain at least ONE real aws CLI command.
4. validate.command MUST EXACTLY MATCH the aws command in lab.steps.
5. Validation must be deterministic (expected: "").
6. Read-only AWS commands ONLY.
7. Sandbox safe.
8. No fictional tools. No fake repos.

========================
MINIMUM LENGTH RULES
========================

- content.concept:      ≥ 200 characters
- content.walkthrough:  ≥ 200 characters
- elite_competence.role_simulation: ≥ 50 characters

If you are unsure, WRITE MORE.

========================
STRUCTURE REQUIRED
========================

{
  "id": string,
  "canon": string,
  "version": string,
  "title": string,
  "objectives": [string, string, string],
  "duration_minutes": number,
  "tags": [string, string, string],
  "mission_brief": {
    "situation": string,
    "mission": string,
    "execution": string
  },
  "prerequisites": [string],
  "content": {
    "concept": string,
    "walkthrough": string,
    "checkpoints": [string, string, string],
    "common_mistakes": [string, string, string]
  },
  "lab": {
    "type": "guided-cli",
    "setup": string,
    "steps": [string],
    "safety": [string, string, string],
    "validate": {
      "command": string,
      "expected": "",
      "match": "contains"
    }
  },
  "elite_competence": {
    "scenario_name": string,
    "role_simulation": string,
    "bug_injection": {
      "bug": string,
      "symptom": string,
      "fix": string
    },
    "success_criteria": {
      "pass_conditions": [string, string, string],
      "fail_conditions": [string, string]
    },
    "interrogation_questions": [string, string, string]
  },
  "legal_context": {
    "allowed": string,
    "prohibited": string
  },
  "resume_bullets": [string, string, string]
}

========================
LESSON CONTEXT
========================

Lesson ID: ${lessonId}
Canon: ${canon}
Version: ${version}
Lesson Number: ${lessonNumber}
Archetype: ${archetype}
AWS Region: ${region ?? "us-east-1"}

========================
CONTENT GUIDANCE
========================

- Focus on **verification and visibility**, not creation.
- Use commands like:
  - aws sts get-caller-identity
  - aws s3 ls
  - aws ec2 describe-instances
- The walkthrough must be detailed, explanatory, and instructional.
- The role_simulation must describe a realistic operator scenario in depth.

========================
FINAL RULE
========================

If ANY minimum is not met, the lesson FAILS.

Generate the JSON now.
`;
}