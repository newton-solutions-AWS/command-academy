import path from "path";
import fs from "fs";

export function ensureDir(p: string) {
  fs.mkdirSync(p, { recursive: true });
}

export function canonRoot(org: string, canon: string, version: string) {
  return path.resolve("cert_intel/canon", org, canon, version);
}

export function lessonDir(org: string, canon: string, version: string) {
  return path.join(canonRoot(org, canon, version), "lessons");
}

export function labDir(org: string, canon: string, version: string) {
  return path.join(canonRoot(org, canon, version), "labs");
}

export function guidesDir(org: string, canon: string, version: string) {
  return path.join(canonRoot(org, canon, version), "field_guides");
}

export function cheatsDir(org: string, canon: string, version: string) {
  return path.join(canonRoot(org, canon, version), "cheat_sheets");
}
