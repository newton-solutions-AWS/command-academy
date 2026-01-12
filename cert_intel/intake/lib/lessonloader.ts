import fs from "fs";
import path from "path";

export type LoadCanonLessonsInput = {
  canon: string;
  version: string;
};

export type CanonLesson = {
  id: string;
  canon: string;
  title: string;
  description?: string;
  version: string;
  path: string;
  order?: number;
};

export function loadLessons({
  canon,
  version,
}: LoadCanonLessonsInput): CanonLesson[] {
  const baseDir = path.join(
    process.cwd(),
    "cert_intel",
    "canon",
    "atils",
    canon,
    version,
    "labs"
  );

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
      id: raw.id,
      title: raw.title,
      description: raw.description ?? "",
      canon,
      version,
      path: fullPath,
      order: index + 1,
    };
  });
}

/**
 * Alias used by Next.js app routes
 * DO NOT REMOVE
 */
export const loadCanonLessons = loadLessons;