// lib/lessons.ts
import fs from "fs";
import path from "path";

export type Lesson = {
  id: string;
  title: string;
  canon: string;
  version: string;
};

const CANON_ROOT = path.join(
  process.cwd(),
  "cert_intel",
  "canon",
  "atils"
);

/**
 * Safely read lessons for a division (phoenix / sentinel / vanguard)
 * Returns [] if nothing exists (Vercel-safe, empty-sandbox safe)
 */
export function getLessonsByDivision(division: string): Lesson[] {
  try {
    const divisionPath = path.join(CANON_ROOT, division);

    if (!fs.existsSync(divisionPath)) return [];

    const versions = fs.readdirSync(divisionPath);
    const lessons: Lesson[] = [];

    for (const version of versions) {
      const labsPath = path.join(divisionPath, version, "labs");

      if (!fs.existsSync(labsPath)) continue;

      const files = fs
        .readdirSync(labsPath)
        .filter((f) => f.endsWith(".json"));

      for (const file of files) {
        const fullPath = path.join(labsPath, file);
        const raw = fs.readFileSync(fullPath, "utf8");
        const json = JSON.parse(raw);

        lessons.push({
          id: json.id,
          title: json.title,
          canon: json.canon,
          version: json.version,
        });
      }
    }

    return lessons;
  } catch (err) {
    console.error("Lesson load failure:", err);
    return [];
  }
}
