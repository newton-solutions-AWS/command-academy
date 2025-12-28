// cert_intel/intake/lib/generate.v1.ts

import fs from "node:fs";
import path from "node:path";
import { LessonSchema } from "./schema";
import { ollamaChat } from "./ollama";
import { jsonSafeParse } from "./jsonSafeParse";
import { enforcePhoenixV2Contract } from "./validateOutput";
import { buildPhoenixV2Prompt } from "./lesson_template";
import { normalizePhoenixV2 } from "./normalizePhoenixV2";

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

export async function generateBatch(opts: GenerateBatchOpts) {
  const {
    canon,
    version,
    count,
    outputDir,
    maxAttempts,
    region,
  } = opts;

  ensureDir(outputDir);

  for (let i = 1; i <= count; i++) {
    const lessonId = `${canon}-l${String(i).padStart(3, "0")}`;
    const filePath = path.join(outputDir, `${lessonId}.json`);

    let success = false;
    let lastError: any = null;

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        const prompt = buildPhoenixV2Prompt({
          lessonId,
          lessonNumber: i,
          canon,
          version,
          archetype: "phoenix-v2-secure-cloud-operator",
          region,
        });

        const raw = await ollamaChat(prompt);

        let parsed = jsonSafeParse(raw);

        // 🔒 Auto-repair undersized fields
        parsed = normalizePhoenixV2(parsed);

        // 🧪 Schema validation
        LessonSchema.parse(parsed);

        // 🛡️ Phoenix v2 behavioral contract
        enforcePhoenixV2Contract(parsed);

        writeJson(filePath, parsed);

        console.log(`✅ Lesson written: ${lessonId}`);
        success = true;
        break;
      } catch (err) {
        lastError = err;
      }
    }

    if (!success) {
      console.error(`❌ FAILURE [${lessonId}] after ${maxAttempts} attempts`);
      console.error("❌ Fatal:", lastError);
      throw lastError;
    }
  }

  console.log("✅ Generation complete");
}