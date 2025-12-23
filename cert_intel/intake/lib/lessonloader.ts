import fs from "fs";
import path from "path";

export function loadLessonById(id: string) {
  const base = path.join(process.cwd(), "cert_intel", "canon", "atils");

  const divisions = [
    "phoenix-protocol-secure-cloud-operator",
    "sentinel-protocol-defensive-operations",
    "vanguard-protocol-advanced-architecture"
  ];

  for (const canon of divisions) {
    const lessonPath = path.join(base, canon, "v1", "lessons", `${id}.json`);
    if (fs.existsSync(lessonPath)) {
      return JSON.parse(fs.readFileSync(lessonPath, "utf8"));
    }
  }

  return null;
}