import fs from "fs";
import path from "path";

export type SourceRegistry = Record<string, any>;

export function loadRegistry() {
  const registryPath = path.resolve("cert_intel/source_registry.json");
  if (!fs.existsSync(registryPath)) throw new Error("source_registry.json not found");
  return JSON.parse(fs.readFileSync(registryPath, "utf-8")) as SourceRegistry;
}

export function requireCanon(registry: SourceRegistry, org: string, canon: string) {
  if (!registry[org]) throw new Error(`Org not found in registry: ${org}`);
  if (!registry[org][canon]) throw new Error(`Canon not found in registry: ${org}.${canon}`);
  return registry[org][canon];
}
