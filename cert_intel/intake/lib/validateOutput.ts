// cert_intel/intake/lib/validateOutput.ts
import { z } from "zod";

/**
 * Phoenix v2 hard constraints
 * These are NON-NEGOTIABLE audit rules.
 */

const FORBIDDEN_PATTERNS = [
  /s3:\/\/[a-z0-9\-]+/i,                // named S3 buckets
  /\b\d{12}\b/,                         // 12-digit AWS account IDs
  /arn:aws:/i,                          // hardcoded ARNs
  /at least\s+\d+/i,                    // quantity assumptions
  />=\s*\d+/i,
  /more than\s+\d+/i,
];

const ALLOWED_AWS_PREFIX = /^aws\s+(sts|get|s3 ls|ec2 describe|iam list|lambda list|cloudwatch describe|ec2 describe-security-groups|ec2 describe-vpcs)/i;

export function enforcePhoenixV2Contract(lesson: any) {
  // 1. Ensure at least one AWS command exists
  const awsSteps = lesson.lab?.steps?.filter((s: string) =>
    s.trim().toLowerCase().startsWith("aws ")
  );

  if (!awsSteps || awsSteps.length === 0) {
    throw new Error(
      "Phoenix v2 contract violated: lab.steps must include at least one 'aws ...' command"
    );
  }

  // 2. Validate each AWS command
  for (const step of awsSteps) {
    if (!ALLOWED_AWS_PREFIX.test(step)) {
      throw new Error(`Forbidden AWS command detected: ${step}`);
    }

    for (const pattern of FORBIDDEN_PATTERNS) {
      if (pattern.test(step)) {
        throw new Error(`Forbidden pattern in lab step: ${step}`);
      }
    }
  }

  // 3. Validation command MUST match executed command
  if (lesson.lab?.validate?.command !== awsSteps[0]) {
    throw new Error(
      "Phoenix v2 contract violated: validate.command must equal the lab aws command"
    );
  }

  // 4. Success criteria must be execution-based ONLY
  const successText = JSON.stringify(lesson.elite_competence?.success_criteria || {});
  for (const pattern of FORBIDDEN_PATTERNS) {
    if (pattern.test(successText)) {
      throw new Error(
        "Phoenix v2 contract violated: success criteria must not assume resource existence or quantity"
      );
    }
  }

  return true;
}