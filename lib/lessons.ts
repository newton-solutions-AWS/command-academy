// lib/lessons.ts
import fs from "fs";
import path from "path";

export type LoadLessonsOpts = {
  canon: string;
  version: string;
};

export type LessonSummary = {
  id: string;
  title: string;
  duration_minutes?: number;
  tags?: string[];
};

export function loadLessons(opts: LoadLessonsOpts): LessonSummary[] {
  const basePath = path.join(
    process.cwd(),
    "cert_intel",
    "canon",
    "atils",
    opts.canon,
    opts.version,
    "labs"
  );

  if (!fs.existsSync(basePath)) {
    return [];
  }

  const files = fs
    .readdirSync(basePath)
    .filter((f) => f.endsWith(".json"));

  return files.map((file) => {
    const fullPath = path.join(basePath, file);
    const raw = fs.readFileSync(fullPath, "utf8");
    const json = JSON.parse(raw);

    return {
      id: json.id,
      title: json.title,
      duration_minutes: json.duration_minutes,
      tags: json.tags,
    };
  });
}
