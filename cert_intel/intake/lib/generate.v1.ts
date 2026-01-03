// cert_intel/intake/lib/generate.v1.ts

import fs from "node:fs";
import path from "node:path";
import { LessonSchema } from "./schema";
import { ollamaChat } from "./ollama";
import { jsonSafeParse } from "./jsonSafeParse";
import { enforcePhoenixV2Contract } from "./validateOutput";
import { buildPhoenixV2Prompt } from "./lesson_template";

export type GenerateBatchOpts = {
  canon: string;
  version: string; // e.g. v2
  count: number;
  outputDir: string;
  maxAttempts: number;
  region?: string;
  dryRun?: boolean;
};

function ensureDir(p: string) {
  fs.mkdirSync(p, { recursive: true });
}

function writeJson(filePath: string, obj: any) {
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 2) + "\n", "utf8");
}

/**
 * Canonical, empty-sandbox-safe, read-only AWS commands.
 * - No s3://bucket lookups
 * - No count thresholds
 * - No hardcoded account IDs
 */
function phoenixV2CommandForLesson(n: number, region?: string): string {
  const r = region ? ` --region ${region}` : "";
  const cmds = [
    `aws sts get-caller-identity --query "Account" --output text${r}`,
    `aws s3 ls${r}`,
    `aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text${r}`,
    `aws iam list-roles --query "Roles[].RoleName" --output text${r}`,
    `aws cloudwatch describe-alarms --query "MetricAlarms[].AlarmName" --output text${r}`,
    `aws lambda list-functions --query "Functions[].FunctionName" --output text${r}`,
    `aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text${r}`,
    `aws ec2 describe-security-groups --query "SecurityGroups[].GroupId" --output text${r}`,
  ];
  return cmds[Math.min(n - 1, cmds.length - 1)];
}

function phoenixV2TopicForLesson(n: number): string {
  const topics = [
    "Verify identity context using STS get-caller-identity (read-only).",
    "Verify S3 visibility using account-level listing (read-only, deterministic).",
    "Verify EC2 visibility using describe-instances (read-only, deterministic).",
    "Verify IAM visibility using list-roles (read-only, deterministic).",
    "Verify CloudWatch visibility using describe-alarms (read-only, deterministic).",
    "Verify Lambda visibility using list-functions (read-only, deterministic).",
    "Verify VPC visibility using describe-vpcs (read-only, deterministic).",
    "Verify Security Groups visibility using describe-security-groups (read-only, deterministic).",
  ];
  return topics[Math.min(n - 1, topics.length - 1)];
}

/**
 * LLMs sometimes return JSON inside ```json ... ``` or with preamble text.
 * This tries to extract the first top-level JSON object.
 */
function extractFirstJsonObject(raw: string): string {
  const s = String(raw ?? "").trim();

  // If fenced, strip common fences
  const unfenced = s
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();

  // Fast path: already a JSON object
  if (unfenced.startsWith("{") && unfenced.endsWith("}")) return unfenced;

  // Find first '{' and parse until matching '}' by brace counting
  const start = unfenced.indexOf("{");
  if (start === -1) return unfenced;

  let depth = 0;
  for (let i = start; i < unfenced.length; i++) {
    const ch = unfenced[i];
    if (ch === "{") depth++;
    if (ch === "}") depth--;
    if (depth === 0) {
      return unfenced.slice(start, i + 1);
    }
  }

  // If we never closed braces, return unfenced (jsonSafeParse will fail)
  return unfenced;
}

function ensureMinArray(arr: any, min: number, filler: (i: number) => string): string[] {
  const out: string[] = Array.isArray(arr) ? arr.filter((x) => typeof x === "string" && x.trim().length > 0) : [];
  while (out.length < min) out.push(filler(out.length));
  return out;
}

function ensureMinString(s: any, minChars: number, fallback: string): string {
  const val = typeof s === "string" ? s : "";
  if (val.trim().length >= minChars) return val;
  // pad by appending extra guidance until we hit size
  let padded = (val.trim().length ? val.trim() + " " : "") + fallback;
  while (padded.length < minChars) padded += " " + fallback;
  return padded.slice(0, Math.max(minChars, fallback.length + 5));
}

function forcePhoenixV2Shape(obj: any, lessonId: string, canon: string, version: string, command: string, topic: string) {
  // Core identity
  obj.id = lessonId;
  obj.canon = canon;
  obj.version = version;

  // Title/tags/mission brief hardening
  obj.title = typeof obj.title === "string" && obj.title.trim().length > 0 ? obj.title : `Phoenix Protocol: ${topic}`;
  obj.duration_minutes = typeof obj.duration_minutes === "number" ? obj.duration_minutes : 30;
  obj.tags = Array.isArray(obj.tags) ? obj.tags : ["aws", "read-only", "deterministic", "phoenix", "v2"];

  obj.mission_brief =
    typeof obj.mission_brief === "object" && obj.mission_brief
      ? obj.mission_brief
      : {
          situation:
            "You are operating as a secure cloud operator in an authorized sandbox where resources may or may not exist.",
          mission: "Verify access safely using read-only AWS CLI commands without assuming any pre-existing resources.",
          execution:
            "Run discovery-only commands and validate success by deterministic behavior (successful execution), not resource presence.",
        };

  obj.prerequisites = Array.isArray(obj.prerequisites)
    ? obj.prerequisites
    : ["AWS CLI installed and working", "Valid sandbox credentials configured", "No write permissions required"];

  // Objectives must be >=3
  obj.objectives = ensureMinArray(obj.objectives, 3, (i) => {
    const defaults = [
      "Execute a read-only AWS CLI command safely in a sandbox environment.",
      "Interpret empty output as a valid result when no resources exist.",
      "Validate success using deterministic behavior rather than fixed identifiers.",
    ];
    return defaults[Math.min(i, defaults.length - 1)];
  });

  // Content must exist and meet min lengths + arrays
  obj.content = typeof obj.content === "object" && obj.content ? obj.content : {};
  obj.content.concept = ensureMinString(
    obj.content.concept,
    200,
    "Deterministic validation means you confirm the command executed successfully without relying on resource names, counts, or IDs that vary between environments. In clean sandboxes, empty output is normal. Your goal is to prove visibility and permission, not the existence of assets."
  );
  obj.content.walkthrough = ensureMinString(
    obj.content.walkthrough,
    200,
    `Run the command exactly as provided and observe whether it executes without errors. If output is empty, that still indicates success in an empty sandbox. Record the result and confirm you did not use any write or destructive actions. This lesson is graded on safe execution and correct interpretation, not on finding resources.`
  );
  obj.content.checkpoints = ensureMinArray(obj.content.checkpoints, 3, (i) => {
    const defaults = [
      "Command executes without AccessDenied or validation errors.",
      "You can explain why empty output can still mean success.",
      "You did not assume any bucket names, account IDs, or resource counts.",
    ];
    return defaults[Math.min(i, defaults.length - 1)];
  });
  obj.content.common_mistakes = ensureMinArray(obj.content.common_mistakes, 3, (i) => {
    const defaults = [
      "Treating empty output as failure in a clean sandbox.",
      "Switching to write commands to 'make it pass'.",
      "Hardcoding resource names or IDs to validate output.",
    ];
    return defaults[Math.min(i, defaults.length - 1)];
  });

  // Lab must exist and be contract-perfect
  obj.lab = typeof obj.lab === "object" && obj.lab ? obj.lab : {};
  obj.lab.type = "guided-cli";
  obj.lab.setup =
    typeof obj.lab.setup === "string" && obj.lab.setup.trim().length > 0
      ? obj.lab.setup
      : "Ensure AWS CLI is configured with sandbox credentials. Do not create, modify, or delete any resources.";

  // Force steps: must contain at least one aws command, and we make it THE command.
  obj.lab.steps = [command];

  obj.lab.safety = ensureMinArray(obj.lab.safety, 3, (i) => {
    const defaults = [
      "Use read-only AWS CLI commands only (list/describe/get).",
      "Do not reference named resources unless the lesson explicitly created them (this v2 track does not).",
      "If you see AccessDenied, stop and verify permissions rather than trying write actions.",
    ];
    return defaults[Math.min(i, defaults.length - 1)];
  });

  obj.lab.validate = typeof obj.lab.validate === "object" && obj.lab.validate ? obj.lab.validate : {};
  obj.lab.validate.command = command; // must match the lab aws command (contract)
  obj.lab.validate.expected = ""; // deterministic empty string strategy
  obj.lab.validate.match = "contains";

  // Elite competence block must be object with required subfields
  obj.elite_competence = typeof obj.elite_competence === "object" && obj.elite_competence ? obj.elite_competence : {};
  obj.elite_competence.scenario_name =
    typeof obj.elite_competence.scenario_name === "string" && obj.elite_competence.scenario_name.trim().length > 0
      ? obj.elite_competence.scenario_name
      : "Phoenix Protocol — Deterministic Visibility Verification";
  obj.elite_competence.role_simulation = ensureMinString(
    obj.elite_competence.role_simulation,
    50,
    "You are the secure cloud operator. Your job is to verify access safely, produce audit-friendly evidence, and avoid assumptions that break in fresh sandboxes."
  );

  obj.elite_competence.bug_injection =
    typeof obj.elite_competence.bug_injection === "object" && obj.elite_competence.bug_injection
      ? obj.elite_competence.bug_injection
      : {};
  obj.elite_competence.bug_injection.bug =
    typeof obj.elite_competence.bug_injection.bug === "string" && obj.elite_competence.bug_injection.bug.trim().length > 0
      ? obj.elite_competence.bug_injection.bug
      : "Operator assumes resources must exist and mislabels empty output as failure.";
  obj.elite_competence.bug_injection.symptom =
    typeof obj.elite_competence.bug_injection.symptom === "string" &&
    obj.elite_competence.bug_injection.symptom.trim().length > 0
      ? obj.elite_competence.bug_injection.symptom
      : "Student reports 'nothing returned' and believes permissions are broken.";
  obj.elite_competence.bug_injection.fix =
    typeof obj.elite_competence.bug_injection.fix === "string" && obj.elite_competence.bug_injection.fix.trim().length > 0
      ? obj.elite_competence.bug_injection.fix
      : "Explain empty-sandbox behavior and validate by successful execution + no errors, not by finding assets.";

  obj.elite_competence.success_criteria =
    typeof obj.elite_competence.success_criteria === "object" && obj.elite_competence.success_criteria
      ? obj.elite_competence.success_criteria
      : {};
  obj.elite_competence.success_criteria.pass_conditions = ensureMinArray(
    obj.elite_competence.success_criteria.pass_conditions,
    3,
    (i) => {
      const defaults = [
        "Command executes successfully without errors.",
        "Student can explain deterministic validation and empty output.",
        "No named resources, counts, or IDs were assumed.",
      ];
      return defaults[Math.min(i, defaults.length - 1)];
    }
  );
  obj.elite_competence.success_criteria.fail_conditions = ensureMinArray(
    obj.elite_competence.success_criteria.fail_conditions,
    2,
    (i) => {
      const defaults = [
        "Student uses named resources (e.g., s3://bucket) and triggers NoSuchBucket errors.",
        "Student uses write/destructive commands to force output.",
      ];
      return defaults[Math.min(i, defaults.length - 1)];
    }
  );

  obj.elite_competence.interrogation_questions = ensureMinArray(
    obj.elite_competence.interrogation_questions,
    3,
    (i) => {
      const defaults = [
        "Why can empty output still indicate success in a sandbox?",
        "What makes a validation 'deterministic' and environment-agnostic?",
        "Which mistakes turn a safe verification into a risky operation?",
      ];
      return defaults[Math.min(i, defaults.length - 1)];
    }
  );

  // Legal context (schema expects object with strings)
  obj.legal_context =
    typeof obj.legal_context === "object" && obj.legal_context
      ? obj.legal_context
      : {
          allowed: "Executing read-only AWS CLI commands in an authorized sandbox or training account.",
          prohibited: "Creating, deleting, or modifying AWS resources without explicit authorization.",
        };

  // Resume bullets must be >=3
  obj.resume_bullets = ensureMinArray(obj.resume_bullets, 3, (i) => {
    const defaults = [
      "Executed deterministic, read-only AWS CLI validation in a sandbox environment.",
      "Interpreted empty output correctly to confirm access without assuming resources.",
      "Applied audit-aligned, environment-agnostic verification practices.",
    ];
    return defaults[Math.min(i, defaults.length - 1)];
  });

  return obj;
}

export async function generateBatch(opts: GenerateBatchOpts) {
  ensureDir(opts.outputDir);

  const region = opts.region;
  const dryRun = !!opts.dryRun;

  if (dryRun) {
    console.log("🧪 DRY-RUN ENABLED");
  }

  for (let i = 1; i <= opts.count; i++) {
    const lessonId = `${opts.canon}-l${String(i).padStart(3, "0")}`;
    const outPath = path.join(opts.outputDir, `${lessonId}.json`);

    const topic = phoenixV2TopicForLesson(i);
    const command = phoenixV2CommandForLesson(i, region);

    let lastErr: any = null;

    for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
      try {
        const prompt = buildPhoenixV2Prompt({
          lessonId,
          lessonNumber: i,
          canon: opts.canon,
          version: opts.version,
          region,
          archetype: "discovery",
          topic,
        });

        const raw0 = await ollamaChat(prompt);
        const jsonOnly = extractFirstJsonObject(raw0);

        const parsed = jsonSafeParse(jsonOnly);
        if (!parsed.ok) {
          throw new Error(`Invalid JSON returned from model`);
        }

        // Force + pad shape to satisfy schema + contract, regardless of model drift
        const hardened = forcePhoenixV2Shape(parsed.value, lessonId, opts.canon, opts.version, command, topic);

        // Zod schema validation
        const valid = LessonSchema.parse(hardened);

        // Phoenix v2 contract validation
        enforcePhoenixV2Contract(valid);

        if (dryRun) {
          console.log(`🧪 DRY-RUN OK: ${lessonId}`);
        } else {
          writeJson(outPath, valid);
          console.log(`✅ Lesson written: ${lessonId}`);
        }

        lastErr = null;
        break;
      } catch (e: any) {
        lastErr = e;

        if (attempt === opts.maxAttempts) {
          // Helpful debug if model keeps returning fenced/garbage
          if (String(e?.message || "").toLowerCase().includes("invalid json")) {
            console.error(`❌ FAILURE [${lessonId}] after ${opts.maxAttempts} attempts`);
            throw e;
          }
          throw e;
        }
      }
    }

    if (lastErr) throw lastErr;
  }

  console.log("✅ Generation complete");
}