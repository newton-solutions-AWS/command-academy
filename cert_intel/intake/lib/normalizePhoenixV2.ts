// cert_intel/intake/lib/normalizePhoenixV2.ts

type Ctx = {
  lessonId: string;
  canon: string;
  version: string;
  region?: string;
  topic: string;
};

function asString(x: any, fallback = ""): string {
  if (typeof x === "string") return x;
  if (x == null) return fallback;
  try {
    return String(x);
  } catch {
    return fallback;
  }
}

function asStringArray(x: any, min = 0, filler?: string): string[] {
  const out: string[] = [];

  if (Array.isArray(x)) {
    for (const item of x) {
      if (typeof item === "string") out.push(item);
      else if (item && typeof item === "object" && "text" in item) out.push(asString((item as any).text));
      else if (item != null) out.push(asString(item));
    }
  } else if (typeof x === "string") {
    // if model returns a single string where array expected
    out.push(x);
  }

  while (out.length < min) out.push(filler ?? "Checkpoint: Command executed successfully.");
  return out;
}

function ensureMinChars(s: string, min: number, filler: string): string {
  const t = (s ?? "").trim();
  if (t.length >= min) return t;
  const pad = `\n\n${filler}\n\n${filler}`;
  return (t + pad).trim();
}

function stripCodeFences(raw: any): any {
  // In case jsonSafeParse returned a string-ish chunk (rare) or model nested stuff
  if (typeof raw !== "string") return raw;
  return raw
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```$/i, "")
    .trim();
}

function pickAwsCommandFromSteps(steps: any[]): string | null {
  for (const s of steps) {
    const line = typeof s === "string" ? s : s?.command;
    if (typeof line === "string" && line.trim().startsWith("aws ")) return line.trim();
  }
  return null;
}

function isForbiddenSpecificS3(line: string): boolean {
  return /\baws\s+s3\s+ls\s+s3:\/\//i.test(line); // named bucket anti-pattern
}

function hasHardcodedAccountId(line: string): boolean {
  return /\b\d{12}\b/.test(line) || /arn:aws:iam::\d{12}:/i.test(line);
}

function safeDefaultAwsForTopic(topic: string, region?: string): string {
  const r = region ? ` --region ${region}` : "";
  const t = topic.toLowerCase();

  if (t.includes("sts") || t.includes("identity")) return `aws sts get-caller-identity --query "Account" --output text`;
  if (t.includes("s3")) return `aws s3 ls`;
  if (t.includes("ec2")) return `aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text${r}`;
  if (t.includes("iam")) return `aws iam list-roles --query "Roles[].RoleName" --output text`;
  if (t.includes("cloudwatch")) return `aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text${r}`;
  if (t.includes("lambda")) return `aws lambda list-functions --query "Functions[].FunctionName" --output text${r}`;
  if (t.includes("vpc")) return `aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text${r}`;
  if (t.includes("security group")) return `aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --output text${r}`;

  return `aws sts get-caller-identity --query "Account" --output text`;
}

export function normalizePhoenixV2Lesson(modelObj: any, ctx: Ctx) {
  const cleaned = typeof modelObj === "string" ? stripCodeFences(modelObj) : modelObj;
  const obj = (cleaned && typeof cleaned === "object") ? cleaned : {};

  // Base shell (ensures required top-level keys exist)
  const out: any = {
    id: ctx.lessonId,
    canon: ctx.canon,
    version: ctx.version,
    title: asString(obj.title, ctx.topic).trim() || ctx.topic,
    objectives: asStringArray(obj.objectives, 3, "Demonstrate deterministic, read-only CLI validation."),
    duration_minutes: Number(obj.duration_minutes ?? 30) || 30,
    tags: asStringArray(obj.tags, 1, "phoenix"),

    mission_brief: obj.mission_brief && typeof obj.mission_brief === "object"
      ? {
          situation: ensureMinChars(asString(obj.mission_brief.situation, "You are operating in a controlled sandbox environment."), 40,
            "Operate as a secure cloud operator where actions must be repeatable and auditable."),
          mission: ensureMinChars(asString(obj.mission_brief.mission, "Validate access safely using standard AWS CLI."), 40,
            "Validate capability without assuming resource existence."),
          execution: ensureMinChars(asString(obj.mission_brief.execution, "Use deterministic commands and stable output patterns."), 40,
            "Use --query and --output text to avoid unstable identifiers."),
        }
      : {
          situation: "You are operating in a controlled sandbox environment where actions must be repeatable and auditable.",
          mission: "Validate cloud visibility and access safely using standard AWS CLI commands only.",
          execution: "Run read-only commands, interpret empty output safely, and validate behavior rather than resource presence.",
        },

    prerequisites: asStringArray(obj.prerequisites, 1, "AWS CLI installed and configured OR use AWS CloudShell."),

    content: {
      concept: ensureMinChars(
        asString(obj.content?.concept, ""),
        200,
        "This lesson follows the Phoenix v2 operating pattern: read-only inspection, deterministic output, and behavior-based validation. You are not proving that resources exist; you are proving that your access works safely. Empty output is valid in a clean sandbox. Always avoid named resources and dynamic IDs, and validate only stable fields."
      ),
      walkthrough: ensureMinChars(
        asString(obj.content?.walkthrough, ""),
        200,
        "Run the listed AWS CLI command exactly as provided. Prefer `--query` to extract stable fields and `--output text` for deterministic output. If the command returns empty output, treat that as a valid clean-sandbox result. If it errors (AccessDenied / missing region), correct configuration and rerun. Your goal is successful execution with safe interpretation, not finding specific assets."
      ),
      checkpoints: asStringArray(obj.content?.checkpoints, 3, "Command executes successfully without errors."),
      common_mistakes: asStringArray(obj.content?.common_mistakes, 3, "Assuming resources exist in a clean sandbox and hardcoding names/IDs."),
    },

    lab: {
      type: "guided-cli",
      setup: ensureMinChars(
        asString(obj.lab?.setup, "Use a sandbox/training AWS account. Never run destructive commands in production."),
        50,
        "Use CloudShell if local AWS CLI is not configured; keep all actions read-only."
      ),
      steps: [] as string[],
      safety: asStringArray(obj.lab?.safety, 3, "Sandbox account only."),
      validate: {
        command: "",
        expected: "",
        match: "contains",
      },
    },

    elite_competence: {
      scenario_name: asString(obj.elite_competence?.scenario_name, "Deterministic Cloud Operations"),
      role_simulation: ensureMinChars(
        asString(obj.elite_competence?.role_simulation, ""),
        50,
        "You are responsible for ensuring every action can be audited and repeated reliably. You must validate capability without relying on fragile assumptions like resource existence, hardcoded IDs, or unstable output fields."
      ),
      bug_injection: {
        bug: asString(obj.elite_competence?.bug_injection?.bug, "Validation relied on a non-existent or hardcoded resource."),
        symptom: asString(obj.elite_competence?.bug_injection?.symptom, "Learners fail even when they run the command correctly in a clean sandbox."),
        fix: asString(obj.elite_competence?.bug_injection?.fix, "Remove named resources / hardcoded IDs and validate only successful execution and stable fields."),
      },
      success_criteria: {
        pass_conditions: asStringArray(obj.elite_competence?.success_criteria?.pass_conditions, 3, "Deterministic output with --query/--output text where applicable."),
        fail_conditions: asStringArray(obj.elite_competence?.success_criteria?.fail_conditions, 2, "Uses named resources or hardcoded identifiers."),
      },
      interrogation_questions: asStringArray(
        obj.elite_competence?.interrogation_questions,
        3,
        "Why is empty output not a failure in a clean sandbox?"
      ),
    },

    legal_context: obj.legal_context && typeof obj.legal_context === "object"
      ? {
          allowed: asString(obj.legal_context.allowed, "Executing read-only AWS CLI commands in an authorized sandbox or training account."),
          prohibited: asString(obj.legal_context.prohibited, "Creating, deleting, or modifying resources without explicit authorization."),
        }
      : {
          allowed: "Executing read-only AWS CLI commands in an authorized sandbox or training account.",
          prohibited: "Creating, deleting, or modifying resources without explicit authorization.",
        },

    resume_bullets: asStringArray(obj.resume_bullets, 3, "Applied deterministic, audit-aligned AWS CLI validation in a sandbox environment."),
  };

  // ----- Normalize lab.steps into strings -----
  const rawSteps = Array.isArray(obj.lab?.steps) ? obj.lab.steps : [];
  const stepStrings: string[] = [];

  for (const s of rawSteps) {
    if (typeof s === "string") stepStrings.push(s.trim());
    else if (s && typeof s === "object" && typeof s.command === "string") stepStrings.push(s.command.trim());
    else if (s != null) stepStrings.push(asString(s).trim());
  }

  // Remove forbidden patterns & placeholders
  const filtered = stepStrings
    .filter(Boolean)
    .filter((line) => !isForbiddenSpecificS3(line))
    .filter((line) => !hasHardcodedAccountId(line))
    .map((line) => line.replace(/your-bucket-name|my-bucket|MyBucket/gi, "").trim())
    .filter(Boolean);

  out.lab.steps = filtered;

  // Ensure at least one aws command exists in steps
  let awsCmd = pickAwsCommandFromSteps(out.lab.steps as any[]);
  if (!awsCmd) {
    awsCmd = safeDefaultAwsForTopic(ctx.topic, ctx.region);
    out.lab.steps.unshift(awsCmd);
  }

  // Contract: validate.command MUST equal the lab aws command
  out.lab.validate.command = awsCmd;
  out.lab.validate.expected = ""; // Phoenix v2 deterministic empty-string pattern
  out.lab.validate.match = "contains";

  // Make checkpoints safer: don’t require counts / assets
  out.content.checkpoints = (out.content.checkpoints as string[]).slice(0, 3);
  while (out.content.checkpoints.length < 3) out.content.checkpoints.push("Output is deterministic and interpreted safely.");

  // Make sure tags include phoenix + aws (helps search/filtering)
  const tagSet = new Set((out.tags as string[]).map((t) => t.toLowerCase()));
  tagSet.add("phoenix");
  tagSet.add("aws");
  out.tags = Array.from(tagSet).slice(0, 8);

  return out;
}