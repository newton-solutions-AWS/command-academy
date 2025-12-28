// cert_intel/intake/lib/validateOutput.ts

export function enforcePhoenixV2Contract(lesson: any) {
  const steps: string[] = lesson?.lab?.steps ?? [];

  const awsCommands = steps.filter(
    (s) => typeof s === "string" && s.trim().startsWith("aws ")
  );

  if (awsCommands.length === 0) {
    throw new Error(
      "Phoenix v2 contract violated: lab.steps must include at least one 'aws ...' command"
    );
  }

  const bannedPatterns = ["git clone", "curl ", "wget ", "psco", "pscop"];

  for (const step of steps) {
    for (const banned of bannedPatterns) {
      if (step.includes(banned)) {
        throw new Error(
          `Phoenix v2 contract violated: banned tool detected (${banned})`
        );
      }
    }
  }

  const validate = lesson?.lab?.validate;

  if (!validate) {
    throw new Error("Phoenix v2 contract violated: missing lab.validate block");
  }

  if (validate.command !== awsCommands[0]) {
    throw new Error(
      "Phoenix v2 contract violated: validate.command must equal the lab aws command"
    );
  }

  if (validate.expected !== "") {
    throw new Error(
      "Phoenix v2 contract violated: validate.expected must be empty string"
    );
  }

  if (validate.match !== "contains") {
    throw new Error(
      "Phoenix v2 contract violated: validate.match must be 'contains'"
    );
  }
}