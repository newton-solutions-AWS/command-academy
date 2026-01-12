import fs from "fs";
import path from "path";

export type CanonLesson = {
  id: string;
  title: string;
  module?: string;
  description?: string;
  version: string;
  division: "phoenix" | "vanguard" | "sentinel";
};

const CANON_ROOT = path.join(process.cwd(), "cert_intel", "canon", "atils");

const CANON_MAP: Record<
  CanonLesson["division"],
  { slug: string; version: string }
> = {
  phoenix: {
    slug: "phoenix-protocol-secure-cloud-operator",
    version: "v2",
  },
  vanguard: {
    slug: "vanguard-protocol-advanced-architecture",
    version: "v2",
  },
  sentinel: {
    slug: "sentinel-protocol-defensive-operations",
    version: "v2",
  },
};

export function loadCanonLessons(
  division: CanonLesson["division"]
): CanonLesson[] {
  const config = CANON_MAP[division];
  if (!config) return [];

  const labsDir = path.join(
    CANON_ROOT,
    config.slug,
    config.version,
    "labs"
  );

  if (!fs.existsSync(labsDir)) {
    console.warn(`[CANON] Missing labs dir: ${labsDir}`);
    return [];
  }

  return fs
    .readdirSync(labsDir)
    .filter((f) => f.endsWith(".json"))
    .sort()
    .map((file) => {
      const fullPath = path.join(labsDir, file);
      const raw = JSON.parse(fs.readFileSync(fullPath, "utf-8"));

      return {
        id: raw.id ?? file.replace(".json", ""),
        title: raw.title ?? "Untitled Lesson",
        module: raw.module,
        description: raw.description,
        version: config.version,
        division,
      };
    });
}