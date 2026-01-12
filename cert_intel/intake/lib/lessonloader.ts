import fs from "fs";
import path from "path";

export type LoadCanonLessonsInput = {
  canon: string;
  version: string;
};

export type CanonLesson = {
  id: string;
  title?: string;
  canon: string;
  version: string;
  path: string;
};

/**
 * Canonical lesson loader (filesystem-backed).
 * Node-only. Deterministic. No caching.
 */
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

  if (!fs.existsSync(labsDir)) {
    return [];
  }

  const files = fs
    .readdirSync(labsDir)
    .filter((f) => f.endsWith(".json"))
    .sort();

  return files.map((file) => {
    const fullPath = path.join(labsDir, file);
    const raw = JSON.parse(fs.readFileSync(fullPath, "utf8"));

    return {
      id: raw.id,
      title: raw.title,
      canon,
      version,
      path: fullPath,
    };
  });
}

/**
 * Alias used by Next.js app routes.
 * DO NOT REMOVE — this is what Phoenix imports.
 */
export const loadCanonLessons = loadLessons;