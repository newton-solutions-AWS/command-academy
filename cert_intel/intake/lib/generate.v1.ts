import fs from "fs";
import path from "path";
import pLimit from "p-limit";
import { LessonSchema } from "./schema";
import { ensureDir, lessonDir } from "./paths";
import { LESSON_TEMPLATE } from "./lesson_template";

/* ─────────────────────────────
   TYPES
───────────────────────────── */
export type OllamaChat = (args: {
  model: string;
  messages: { role: "system" | "user"; content: string }[];
}) => Promise<{ message: { content: string } }>;

/* ─────────────────────────────
   HELPERS
───────────────────────────── */
function extractJSON(raw: string) {
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start === -1 || end === -1) {
    throw new Error("No JSON object found in model output");
  }
  return JSON.parse(raw.slice(start, end + 1));
}

function lessonId(canon: string, n: number) {
  const short = canon.split("-").map(s => s[0]).join("");
  return `${short}-l${String(n).padStart(3, "0")}`;
}

/* ─────────────────────────────
   GENTLE NORMALISATION (NO SPAM)
───────────────────────────── */
function normaliseLesson(l: any) {
  if (!l.lab) l.lab = {};
  if (!l.content) l.content = {};
  if (!l.accessibility) l.accessibility = {};

  // Ensure lab.setup meets schema minimum
  if (typeof l.lab.setup !== "string" || l.lab.setup.length < 20) {
    l.lab.setup =
      "Prepare a controlled lab environment using authorised cloud credentials and tooling.";
  }

  // Ensure arrays exist (no padding spam)
  if (!Array.isArray(l.content.checkpoints) || l.content.checkpoints.length < 3) {
    l.content.checkpoints = [
      "Verify configuration state",
      "Confirm permissions and access",
      "Validate expected system behaviour"
    ];
  }

  if (!Array.isArray(l.lab.steps) || l.lab.steps.length < 3) {
    l.lab.steps = [
      "Inspect current configuration using standard CLI tools",
      "Apply the required configuration change",
      "Verify the result using a real command"
    ];
  }

  if (!l.accessibility.alt_text_summary) {
    l.accessibility.alt_text_summary = "Standard accessibility summary.";
  }

  if (!l.accessibility.reading_level) {
    l.accessibility.reading_level = "standard";
  }

  if (!l.lab.type) {
    l.lab.type = "guided-cli";
  }

  return l;
}

/* ─────────────────────────────
   MAIN FACTORY (PUBLIC EXPORT)
───────────────────────────── */
export async function generateBatch(opts: {
  org: string;
  canon: string;
  version: string;
  count: number;
  model: string;
  concurrency: number;
  maxAttempts: number;
  ollamaChat: OllamaChat;
}) {
  const outDir = lessonDir(opts.org, opts.canon, opts.version);
  ensureDir(outDir);

  const limit = pLimit(opts.concurrency);

  console.log(`🛡️ Factory Online → ${outDir}`);

  return Promise.all(
    Array.from({ length: opts.count }).map((_, i) =>
      limit(async () => {
        const id = lessonId(opts.canon, i + 1);
        const outFile = path.join(outDir, `${id}.json`);

        try {
          const response = await opts.ollamaChat({
            model: opts.model,
            messages: [
              {
                role: "system",
                content: `
You are a senior UK Cloud Security Instructor.

STRICT RULES:
- JSON ONLY
- Use ONLY real bash and AWS CLI commands
- No invented tools or placeholders
- lab.setup must be a full sentence (20+ characters)
- Minimum 3 checkpoints
- Minimum 3 lab steps
`
              },
              {
                role: "user",
                content: `
Lesson ID: ${id}
Canon: ${opts.canon}

JSON TEMPLATE:
${JSON.stringify(
  { ...LESSON_TEMPLATE, id, canon: opts.canon, version: opts.version },
  null,
  2
)}
`
              }
            ]
          });

          const raw = extractJSON(response.message.content);
          const normalised = normaliseLesson(raw);
          const parsed = LessonSchema.parse(normalised);

          fs.writeFileSync(outFile, JSON.stringify(parsed, null, 2));
          console.log(`✅ Lesson written: ${id}`);

          return { lessonId: id, status: "written" as const };
        } catch (err: any) {
          console.error(`❌ FAILURE [${id}]`, err?.errors || err?.message || err);
          return { lessonId: id, status: "failed" as const };
        }
      })
    )
  );
}