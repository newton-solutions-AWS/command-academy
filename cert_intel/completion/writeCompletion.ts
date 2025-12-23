import fs from "fs";
import path from "path";
import { CompletionSchema } from "./schema";
import type { CompletionRecord } from "./types";

export function writeCompletion(record: CompletionRecord) {
  const validated = CompletionSchema.parse(record);

  const dir = path.join(
    "cert_intel",
    "completion",
    validated.learner_id,
    validated.canon,
    validated.version
  );

  fs.mkdirSync(dir, { recursive: true });

  const file = path.join(dir, `${validated.lesson_id}.json`);
  fs.writeFileSync(file, JSON.stringify(validated, null, 2));

  return file;
}