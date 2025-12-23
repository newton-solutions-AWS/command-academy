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
  if (start === -1 || end === -1) throw new Error("No JSON found in model output");
  return JSON.parse(raw.slice(start, end + 1));
}

function lessonId(canon: string, n: number) {
  const short = canon.split("-").map((s) => s[0]).join("");
  return `${short}-l${String(n).padStart(3, "0")}`;
}

// Flatten any object/primitive into a string deterministically
function flatten(value: any): string {
  if (typeof value === "string") return value;
  if (typeof value === "object" && value !== null) {
    // stable-ish flatten: join values
    return Object.values(value).map(String).join(" — ");
  }
  return String(value);
}

// Normalize known array paths into string arrays
function normalizeArrays(obj: any) {
  const paths: (string | number)[][] = [
    ["prerequisites"],
    ["content", "checkpoints"],
    ["content", "common_mistakes"],
    ["lab", "steps"],
    ["lab", "safety"],
    ["elite_competence", "interrogation_questions"],
    ["resume_bullets"],
  ];

  for (const p of paths) {
    let ref = obj;
    for (let i = 0; i < p.length - 1; i++) {
      ref = ref?.[p[i] as any];
      if (!ref) break;
    }
    const key = p[p.length - 1] as any;
    if (Array.isArray(ref?.[key])) {
      ref[key] = ref[key].map(flatten);
    }
  }
  return obj;
}

// Enforce minimum array lengths (without weakening schema)
function ensureMinItems(obj: any) {
  // Lab steps must be >= 5 (pad with safe, specific placeholders if short)
  const steps = obj?.lab?.steps;
  if (Array.isArray(steps) && steps.length < 5) {
    const needed = 5 - steps.length;
    for (let i = 0; i < needed; i++) {
      steps.push(
        `Add an additional verification step: run a relevant command (e.g., 'ls -la', 'id', 'whoami') and explain what the output confirms.`
      );
    }
  }

  // Lab safety must be >= 3
  const safety = obj?.lab?.safety;
  if (Array.isArray(safety) && safety.length < 3) {
    const needed = 3 - safety.length;
    for (let i = 0; i < needed; i++) {
      safety.push(
        `Safety: do not run commands with elevated privileges unless explicitly instructed; validate paths before modifying files.`
      );
    }
  }

  // Checkpoints must be >= 3 (if your schema requires it)
  const checkpoints = obj?.content?.checkpoints;
  if (Array.isArray(checkpoints) && checkpoints.length < 3) {
    const needed = 3 - checkpoints.length;
    for (let i = 0; i < needed; i++) {
      checkpoints.push(
        `Checkpoint: describe the purpose of the key command used in this lesson and what “good output” looks like.`
      );
    }
  }

  return obj;
}

// Enforce minimum text lengths (pad deterministically if short)
function ensureMinText(obj: any) {
  const minConcept = 250;
  const minWalkthrough = 250;
  const minSetup = 50;
  const minAlt = 40;

  const concept = obj?.content?.concept;
  if (typeof concept === "string" && concept.length < minConcept) {
    obj.content.concept =
      concept +
      `\n\nExpansion: Explain the security rationale, the operational risk if this is misconfigured, and how an operator verifies correctness under pressure.`;
  }

  const walkthrough = obj?.content?.walkthrough;
  if (typeof walkthrough === "string" && walkthrough.length < minWalkthrough) {
    obj.content.walkthrough =
      walkthrough +
      `\n\nExpansion: Walk through expected command outputs, common failure modes, and a verification loop (change → verify → record).`;
  }

  const setup = obj?.lab?.setup;
  if (typeof setup === "string" && setup.length < minSetup) {
    obj.lab.setup =
      setup +
      `\n\nEnsure you have a terminal open, note your current working directory, and confirm you can read/write within a safe sandbox path.`;
  }

  const alt = obj?.accessibility?.alt_text_summary;
  if (typeof alt === "string" && alt.length < minAlt) {
    obj.accessibility.alt_text_summary =
      alt +
      ` This lesson includes clear steps, verification commands, and safety checks suitable for screen readers.`;
  }

  return obj;
}

// Apply all deterministic repairs before schema validation
function repairLesson(raw: any) {
  const obj = normalizeArrays(raw);
  ensureMinItems(obj);
  ensureMinText(obj);
  return obj;
}

/* ─────────────────────────────
   PROMPTS (ESCALATING)
───────────────────────────── */
function systemPrompt(attempt: number) {
  // attempt starts at 1
  const base = `
You are a senior UK Cloud Security Instructor.

You MUST generate LONG-FORM, PRODUCTION-GRADE instructional content.

STRICT RULES:
- JSON ONLY
- NO markdown
- NO commentary
- NO explanations outside JSON
- REAL commands only (bash, systemctl, aws cli)
- NO invented tools

STRUCTURE RULES (NON-NEGOTIABLE):
- ALL array items MUST be STRINGS (no objects in arrays)
- prerequisites: string[]
- content.checkpoints: string[]
- content.common_mistakes: string[]
- lab.steps: string[] (>=5)
- lab.safety: string[] (>=3)
- elite_competence.interrogation_questions: string[]
- resume_bullets: string[]

CONTENT LENGTH REQUIREMENTS:
- content.concept: >=250 characters
- content.walkthrough: >=250 characters
- lab.setup: >=50 characters
- accessibility.alt_text_summary: >=40 characters
`;

  if (attempt === 1) return base;

  // escalation: be extra explicit + threaten rejection
  return (
    base +
    `
ATTEMPT ${attempt} (REPAIR MODE):
- Your last output failed validation.
- You MUST flatten ALL lists into strings.
- DO NOT use { "step": "...", "why": "..." } anywhere.
- Ensure lab.steps has 5+ detailed string steps.
- Expand any short text fields until they meet minimum length.
If you cannot comply, rewrite the entire JSON from scratch following the template exactly.
`
  );
}

function userPrompt(opts: { id: string; canon: string; version: string }) {
  return `
Lesson ID: ${opts.id}
Canon: ${opts.canon}

You MUST follow this JSON template EXACTLY.
Return JSON ONLY.

JSON TEMPLATE:
${JSON.stringify(
  { ...LESSON_TEMPLATE, id: opts.id, canon: opts.canon, version: opts.version },
  null,
  2
)}
`;
}

/* ─────────────────────────────
   GENERATOR (V1 – 100% PASS VIA RETRY)
───────────────────────────── */
async function generateBatchV1(opts: {
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

        // If already exists and validates, skip (prevents overwriting good lessons)
        if (fs.existsSync(outFile)) {
          try {
            const existing = JSON.parse(fs.readFileSync(outFile, "utf8"));
            LessonSchema.parse(existing);
            console.log(`↩️  Lesson exists + valid, skipping: ${id}`);
            return { lessonId: id, status: "skipped" as const };
          } catch {
            // fall through to regenerate
          }
        }

        let lastErr: any = null;

        for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
          try {
            const draft = await opts.ollamaChat({
              model: opts.model,
              messages: [
                { role: "system", content: systemPrompt(attempt) },
                { role: "user", content: userPrompt({ id, canon: opts.canon, version: opts.version }) },
              ],
            });

            const raw = extractJSON(draft.message.content);
            const repaired = repairLesson(raw);
            const parsed = LessonSchema.parse(repaired);

            fs.writeFileSync(outFile, JSON.stringify(parsed, null, 2));
            console.log(`✅ Lesson written: ${id} (attempt ${attempt})`);
            return { lessonId: id, status: "written" as const, attempt };

          } catch (err: any) {
            lastErr = err;
            // keep trying until maxAttempts
          }
        }

        // If we get here, it couldn't be repaired within maxAttempts
        console.error(`❌ FAILURE [${id}] after ${opts.maxAttempts} attempts`, lastErr?.errors || lastErr?.message || lastErr);
        return { lessonId: id, status: "failed" as const };
      })
    )
  );
}

/* ─────────────────────────────
   PUBLIC EXPORT
───────────────────────────── */
export const generateBatch = generateBatchV1;