import fs from "fs";
import path from "path";

export type CanonLesson = {
  id: string;
  title: string;
  canon: string;
  version: "v2";
  path: string;
};

const CANON_ROOT = path.join(
  process.cwd(),
  "cert_intel",
  "canon",
  "atils"
);

function loadCanonLessons(canon: string): CanonLesson[] {
  const labsDir = path.join(CANON_ROOT, canon, "v2", "labs");

  if (!fs.existsSync(labsDir)) {
    console.warn(`[CANON] Missing labs dir: ${labsDir}`);
    return [];
  }

  return fs
    .readdirSync(labsDir)
    .filter((f) => f.endsWith(".json"))
    .map((file) => {
      const fullPath = path.join(labsDir, file);
      const raw = JSON.parse(fs.readFileSync(fullPath, "utf-8"));

      return {
        id: raw.id,
        title: raw.title,
        canon,
        version: "v2",
        path: fullPath,
      };
    });
}

/* ───────────────────────────────────────────── */
/* DIVISION EXPORTS — DO NOT DRIFT FROM THESE     */
/* ───────────────────────────────────────────── */

export function loadPhoenixLessons() {
  return loadCanonLessons("phoenix-protocol-secure-cloud-operator");
}

export function loadVanguardLessons() {
  return loadCanonLessons("vanguard-protocol-advanced-architecture");
}

export function loadSentinelLessons() {
  return loadCanonLessons("sentinel-protocol-defensive-operations");
}