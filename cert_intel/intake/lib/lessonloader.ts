import fs from "fs";
import path from "path";

export interface CanonLesson {
  id: string;
  title: string;
  canon: string;
  version: string;
  path: string;
  description?: string;
}

interface LoadCanonLessonsInput {
  canon: string;
  version: string;
}

export function loadLessons(input: LoadCanonLessonsInput): CanonLesson[] {
  const { canon, version } = input;

  const labsDir = path.join(
    process.cwd(),
    "cert_intel",
    "canon",
    "atils",
    canon,
    version,
    "labs"
  );

  if (!fs.existsSync(labsDir)) return [];

  const files = fs
    .readdirSync(labsDir)
    .filter((f) => f.endsWith(".json"));

  return files.map((file) => {
    const fullPath = path.join(labsDir, file);
    const raw = JSON.parse(fs.readFileSync(fullPath, "utf-8"));

    return {
      id: raw.id ?? file.replace(".json", ""),
      title: raw.title ?? raw.name ?? "Untitled Lesson",
      canon,
      version,
      path: fullPath,
      description: raw.description,
    };
  });
}

/**
 * Alias used by Next.js routes
 * DO NOT REMOVE
 */
export const loadCanonLessons = loadLessons;