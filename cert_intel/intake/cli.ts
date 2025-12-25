#!/usr/bin/env ts-node

import path from "path";
import { generateBatchV1 } from "./lib/generate.v1";

async function main() {
  const [, , command, canon, track, version, countRaw] = process.argv;

  if (command !== "gen") {
    console.error("❌ Usage: gen <canon> <track> <version> <count>");
    process.exit(1);
  }

  if (!canon || !track || !version || !countRaw) {
    console.error("❌ Missing required arguments");
    process.exit(1);
  }

  const count = Number(countRaw);
  if (Number.isNaN(count) || count <= 0) {
    console.error("❌ Count must be a positive number");
    process.exit(1);
  }

  const model = process.env.MODEL ?? "llama3.1:latest";
  const maxAttempts = Number(process.env.MAX_ATTEMPTS ?? 3);

  const outDir = path.join(
    "cert_intel",
    "canon",
    canon,
    track,
    version,
    "lessons"
  );

  console.log(
    `🧠 MODEL=${model} CONCURRENCY=1 MAX_ATTEMPTS=${maxAttempts}`
  );
  console.log(`🛡️ Factory Online → ${outDir}`);

  await generateBatchV1({
    canon,
    track,
    version,
    count,
    model,
    outDir,
    maxAttempts,
  });
}

main().catch((err) => {
  console.error("❌ Fatal error:", err);
  process.exit(1);
});