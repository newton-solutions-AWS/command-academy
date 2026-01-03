// cert_intel/intake/lib/lesson_template.ts

export type PhoenixV2PromptInput = {
  lessonId: string;
  lessonNumber: number;
  canon: string;
  version: string;
  archetype: "discovery";
  region?: string;
  topic: string;
};

export function buildPhoenixV2Prompt(input: PhoenixV2PromptInput): string {
  return `
You are generating a SINGLE Phoenix Protocol v2 lesson.

ABSOLUTE RULES (VIOLATION = FAILURE):
- Output RAW JSON ONLY
- DO NOT use markdown
- DO NOT wrap output in \`\`\`
- DO NOT explain anything
- DO NOT include comments
- DO NOT include shell interpolation
- DO NOT use echo, $(), backticks, or variables
- lab.steps MUST contain ONLY valid AWS CLI commands
- Commands MUST be read-only
- Commands MUST be empty-sandbox safe
- NEVER reference specific resource names
- NEVER require resources to exist
- NEVER use counts as success criteria
- validate.command MUST EXACTLY MATCH the AWS CLI command
- validate.expected MUST be an empty string ""
- validate.match MUST be "contains"

LESSON METADATA:
- id: ${input.lessonId}
- canon: ${input.canon}
- version: ${input.version}
- archetype: discovery
- topic: ${input.topic}

REQUIRED AWS COMMAND PATTERN (choose ONE):
- aws sts get-caller-identity --output json
- aws s3 ls
- aws ec2 describe-instances --output json
- aws iam list-roles --output json
- aws lambda list-functions --output json
- aws ec2 describe-vpcs --output json
- aws ec2 describe-security-groups --output json

SCHEMA REQUIREMENTS:
- objectives: >= 3 strings
- content.concept: >= 200 characters
- content.walkthrough: >= 200 characters
- content.checkpoints: >= 3 strings
- content.common_mistakes: >= 3 strings
- lab.safety: >= 3 strings
- elite_competence.role_simulation: >= 50 characters
- elite_competence.success_criteria.pass_conditions: >= 3
- elite_competence.success_criteria.fail_conditions: >= 2
- elite_competence.interrogation_questions: >= 3
- resume_bullets: >= 3

OUTPUT EXACTLY ONE VALID JSON OBJECT.
`;
}