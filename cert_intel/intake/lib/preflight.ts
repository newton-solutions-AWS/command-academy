// cert_intel/intake/lib/preflight.ts

export function enforcePhoenixV2Preflight(obj: any) {
  const errors: string[] = [];

  // ---- Rule 1: No named S3 buckets ----
  const steps: string[] = obj?.lab?.steps || [];
  for (const step of steps) {
    if (/aws s3 ls s3:\/\//i.test(step)) {
      errors.push(
        "Forbidden: referencing named S3 buckets (aws s3 ls s3://...). Use account-level aws s3 ls only."
      );
    }
  }

  // ---- Rule 2: No hardcoded AWS Account IDs ----
  const serialized = JSON.stringify(obj);
  if (/\d{12}/.test(serialized)) {
    errors.push(
      "Forbidden: hardcoded 12-digit AWS Account ID detected. Use sts get-caller-identity instead."
    );
  }

  // ---- Rule 3: No quantity assumptions ----
  const success = obj?.elite_competence?.success_criteria;
  if (success) {
    const text = JSON.stringify(success).toLowerCase();
    if (
      text.includes("at least") ||
      text.includes("minimum") ||
      text.includes("count") ||
      text.includes("greater than")
    ) {
      errors.push(
        "Forbidden: quantity-based success criteria. Empty sandboxes may contain zero resources."
      );
    }
  }

  // ---- Rule 4: Validate command mirrors lab command ----
  const validateCmd = obj?.lab?.validate?.command;
  const awsSteps = steps.filter((s) => s.trim().startsWith("aws "));
  if (awsSteps.length > 0 && validateCmd !== awsSteps[awsSteps.length - 1]) {
    errors.push(
      "Invalid: lab.validate.command must exactly match the executed AWS command."
    );
  }

  // ---- Rule 5: Enforce discovery-only archetype ----
  if (obj?.archetype && obj.archetype !== "discovery") {
    errors.push(
      "Invalid archetype: Phoenix v2 lessons must be discovery-only."
    );
  }

  if (errors.length > 0) {
    const message =
      "Phoenix v2 preflight validation failed:\n\n" +
      errors.map((e) => `• ${e}`).join("\n");
    throw new Error(message);
  }
}
