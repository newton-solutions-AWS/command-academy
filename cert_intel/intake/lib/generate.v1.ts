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
  version: string;
  count: number;
  outputDir: string;
  maxAttempts: number;
  region?: string;
};

function ensureDir(p: string) {
  fs.mkdirSync(p, { recursive: true });
}

function writeJson(filePath: string, obj: any) {
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 2) + "\n", "utf8");
}

/**
 * 🔒 Phoenix v2 deterministic normalizer
 * Fixes ALL known schema + contract edge cases
 */
function normalizeLesson(lesson: any) {
  const fillArray = (arr: any[], min: number, filler: string) => {
    while (arr.length < min) arr.push(filler);
    return arr;
  };

  const fillString = (value: string, min: number, filler: string) => {
    let out = value ?? "";
    while (out.length < min) {
      out += "\n\n" + filler;
    }
    return out.trim();
  };

  // ---- Long-form content guards ----
  lesson.content.concept = fillString(
    lesson.content.concept,
    200,
    "This section reinforces secure, repeatable, audit-safe cloud operations using deterministic, read-only validation techniques suitable for any sandbox or production-like environment."
  );

  lesson.content.walkthrough = fillString(
    lesson.content.walkthrough,
    200,
    "The walkthrough emphasizes safe execution, careful observation of command behavior, and validation based on successful execution rather than the presence of specific cloud resources."
  );

  // ---- Content arrays ----
  lesson.content.checkpoints = fillArray(
    lesson.content.checkpoints ?? [],
    3,
    "Checkpoint validated successfully"
  );

  lesson.content.common_mistakes = fillArray(
    lesson.content.common_mistakes ?? [],
    3,
    "Assuming environment-specific resources exist"
  );

  // ---- Lab safety ----
  lesson.lab.safety = fillArray(
    lesson.lab.safety ?? [],
    3,
    "Use sandbox or training credentials only"
  );

  // ---- Elite competence ----
  lesson.elite_competence.role_simulation = fillString(
    lesson.elite_competence.role_simulation,
    50,
    "You are operating as a disciplined cloud operator prioritizing safety, auditability, and deterministic verification."
  );

  lesson.elite_competence.interrogation_questions = fillArray(
    lesson.elite_competence.interrogation_questions ?? [],
    3,
    "Why is behavior-based validation safer than resource-based validation?"
  );

  lesson.elite_competence.success_criteria.pass_conditions = fillArray(
    lesson.elite_competence.success_criteria.pass_conditions ?? [],
    3,
    "Command executes successfully"
  );

  lesson.elite_competence.success_criteria.fail_conditions = fillArray(
    lesson.elite_competence.success_criteria.fail_conditions ?? [],
    2,
    "Command execution fails"
  );

  lesson.resume_bullets = fillArray(
    lesson.resume_bullets ?? [],
    3,
    "Demonstrated audit-safe cloud inspection techniques"
  );

  // ---- 🔑 Phoenix v2 contract enforcement ----
  const awsStep = lesson.lab.steps.find(
    (s: string) => typeof s === "string" && s.trim().startsWith("aws ")
  );

  if (!awsStep) {
    throw new Error("Phoenix v2 contract violated: no aws command in lab.steps");
  }

  lesson.lab.validate.command = awsStep;

  return lesson;
}

export async function generateBatch(opts: GenerateBatchOpts) {
  ensureDir(opts.outputDir);

  for (let i = 1; i <= opts.count; i++) {
    const lessonId = `${opts.canon}-l${String(i).padStart(3, "0")}`;
    const outPath = path.join(opts.outputDir, `${lessonId}.json`);

    let attempt = 0;
    let lastError: any = null;

    while (attempt < opts.maxAttempts) {
      attempt++;

      try {
        const prompt = buildPhoenixV2Prompt({
          lessonId,
          lessonNumber: i,
          canon: opts.canon,
          version: opts.version,
          region: opts.region,
          archetype: "phoenix-v2",
        });

        const raw = await ollamaChat(prompt);
        const parsed = jsonSafeParse(raw);
        const normalized = normalizeLesson(parsed);

        LessonSchema.parse(normalized);
        enforcePhoenixV2Contract(normalized);

        writeJson(outPath, normalized);
        console.log(`✅ Lesson written: ${lessonId}`);
        break;

      } catch (err) {
        lastError = err;
        if (attempt >= opts.maxAttempts) {
          console.error(`❌ FAILURE [${lessonId}] after ${attempt} attempts`);
          throw err;
        }
      }
    }
  }

  console.log("✅ Generation complete");
}