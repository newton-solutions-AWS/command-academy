import fs from "fs";
import path from "path";
import { canonRoot, lessonDir, labDir, guidesDir, cheatsDir, ensureDir } from "./paths";

export function writeCanonSkeleton(org: string, canon: string, version: string, label: string) {
  const root = canonRoot(org, canon, version);
  ensureDir(root);
  ensureDir(lessonDir(org, canon, version));
  ensureDir(labDir(org, canon, version));
  ensureDir(guidesDir(org, canon, version));
  ensureDir(cheatsDir(org, canon, version));

  const manifestPath = path.join(root, "manifest.json");
  const indexPath = path.join(root, "index.json");
  const trackPath = path.join(root, "tracks.json");

  const manifest = {
    org,
    canon,
    version,
    label,
    generated_at: new Date().toISOString(),
    status: "CANON READY",
    structure: ["lessons", "labs", "field_guides", "cheat_sheets"],
  };

  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));

  // empty indexes for now (filled by generator)
  fs.writeFileSync(indexPath, JSON.stringify({ lessons: [], labs: [] }, null, 2));
  fs.writeFileSync(trackPath, JSON.stringify({
    tracks: [
      { id: "core", name: "Core Track", lesson_ids: [] }
    ]
  }, null, 2));

  return { root, manifestPath, indexPath, trackPath };
}
