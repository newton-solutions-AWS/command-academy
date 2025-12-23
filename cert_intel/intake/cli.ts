#!/usr/bin/env ts-node

import { generateBatch } from "./lib/generate";
import { createOllamaChat } from "./lib/ollama";

/* ─────────────────────────────
   ARGUMENT PARSING
───────────────────────────── */
const [, , cmd, org, canon, version, countArg] = process.argv;

if (cmd !== "gen") {
  console.error("Usage: gen <org> <canon> <version> <count>");
  process.exit(1);
}

if (!org || !canon || !version) {
  console.error("Missing required arguments.");
  process.exit(1);
}

const count = Number(countArg || 1);

/* ─────────────────────────────
   ENV CONFIG
───────────────────────────── */
const MODEL = process.env.MODEL || "llama3.1";
const CONCURRENCY = Number(process.env.CONCURRENCY || 1);
const MAX_ATTEMPTS = Number(process.env.MAX_ATTEMPTS || 6);

console.log(`🧠 MODEL=${MODEL} CONCURRENCY=${CONCURRENCY} MAX_ATTEMPTS=${MAX_ATTEMPTS}`);

/* ─────────────────────────────
   MODEL FACTORY
───────────────────────────── */
const ollamaChat = createOllamaChat();

/* ─────────────────────────────
   EXECUTION (FIXES TOP-LEVEL AWAIT)
───────────────────────────── */
async function main() {
  await generateBatch({
    org,
    canon,
    version,
    count,
    model: MODEL,
    concurrency: CONCURRENCY,
    maxAttempts: MAX_ATTEMPTS,
    ollamaChat
  });

  console.log("✅ Generation complete");
}

main().catch(err => {
  console.error("❌ Fatal error:", err);
  process.exit(1);
});