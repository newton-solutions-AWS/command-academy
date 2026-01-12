import fs from "fs";
import path from "path";

export type LoadCanonLessonsInput = {
  canon: string;   // e.g. "phoenix-protocol-secure-cloud-operator"
  version: string; // e.g. "v2"
};

export type CanonLesson = {
  id: string;
  canon: string;
  title: string;
  description?: string;
  version: string;
  path: string;
  order: number;

  // Optional extended fields (render if present in JSON)
  mission?: string;
  objectives?: string[] | string;
  prerequisites?: string[] | string;
  commands?: string[] | string;
  steps?: string[] | string;
  validation?: string[] | string;
  notes?: string[] | string;
  links?: Array<{ title?: string; url: string }> | string[];
};

function canonLabsDir({ canon, version }: LoadCanonLessonsInput) {
  // Canon files live here (runtime reads from disk):
  // cert_intel/canon/atils/<canon>/<version>/labs/*.json
  return path.join(process.cwd(), "cert_intel", "canon", "atils", canon, version, "labs");
}

function safeArray(value: unknown): string[] {
  if (!value) return [];
  if (Array.isArray(value)) return value.map((v) => String(v));
  if (typeof value === "string") return [value];
  return [String(value)];
}

export function loadLessons(input: LoadCanonLessonsInput): CanonLesson[] {
  const baseDir = canonLabsDir(input);

  if (!fs.existsSync(baseDir)) {
    console.warn("[lessonloader] Missing labs dir:", baseDir);
    return [];
  }

  const files = fs
    .readdirSync(baseDir)
    .filter((f) => f.endsWith(".json"))
    .sort();

  return files.map((file, index) => {
    const fullPath = path.join(baseDir, file);
    const raw = JSON.parse(fs.readFileSync(fullPath, "utf-8"));

    return {
      id: String(raw.id ?? ""),
      title: String(raw.title ?? file.replace(/\.json$/, "")),
      description: raw.description ? String(raw.description) : undefined,

      canon: input.canon,
      version: input.version,
      path: fullPath,
      order: index + 1,

      mission: raw.mission ? String(raw.mission) : undefined,
      objectives: raw.objectives,
      prerequisites: raw.prerequisites,
      commands: raw.commands,
      steps: raw.steps,
      validation: raw.validation,
      notes: raw.notes,
      links: raw.links,
    } satisfies CanonLesson;
  }).filter((l) => l.id);
}

/**
 * Alias used by app routes (keep this name stable).
 * DO NOT REMOVE.
 */
export const loadCanonLessons = loadLessons;

export function loadLessonById(input: LoadCanonLessonsInput & { lessonId: string }): CanonLesson | null {
  const lessons = loadLessons(input);
  return lessons.find((l) => l.id === input.lessonId) ?? null;
}

export function toRenderBlocks(lesson: CanonLesson) {
  // Converts unknown JSON shapes into safe arrays for rendering.
  return {
    objectives: safeArray(lesson.objectives),
    prerequisites: safeArray(lesson.prerequisites),
    commands: safeArray(lesson.commands),
    steps: safeArray(lesson.steps),
    validation: safeArray(lesson.validation),
    notes: safeArray(lesson.notes),
  };
}