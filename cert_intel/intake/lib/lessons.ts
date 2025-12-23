import fs from "fs";
import path from "path";

export type LessonMeta = {
  id: string;
  title: string;
};

export function loadLessons(opts: {
  org: string;
  canon: string;
  version: string;
}): LessonMeta[] {
  const dir = path.join(
    process.cwd(),
    "cert_intel",
    "canon",
    opts.org,
    opts.canon,
    opts.version,
    "lessons"
  );

  if (!fs.existsSync(dir)) return [];

  return fs
    .readdirSync(dir)
    .filter(f => f.endsWith(".json"))
    .map(f => {
      const full = JSON.parse(fs.readFileSync(path.join(dir, f), "utf8"));
      return {
        id: full.id,
        title: full.title || full.id
      };
    });
}