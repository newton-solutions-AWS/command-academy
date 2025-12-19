#!/usr/bin/env node
import fs from "fs";
import path from "path";
import { loadRegistry, requireCanon } from "./lib/registry";
import { writeCanonSkeleton } from "./lib/skeleton";
import { generateBatch } from "./lib/generate";

// Minimal Ollama client (no deps)
async function ollamaChat(args: {
  model: string;
  messages: { role: string; content: string }[];
}) {
  const res = await fetch("http://localhost:11434/api/chat", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({
      model: args.model,
      messages: args.messages,
      stream: false,
    }),
  });
  if (!res.ok) {
    throw new Error(`Ollama error: ${res.status} ${await res.text()}`);
  }
  return (await res.json()) as { message: { content: string } };
}

function usage() {
  console.log(`
ATILS FACTORY CLI

Create canon skeleton:
  npx ts-node cert_intel/intake/cli.ts canon <org> <canon> <version>

Generate lessons:
  MODEL=llama3.1 CONCURRENCY=1 MAX_ATTEMPTS=8 \\
  npx ts-node cert_intel/intake/cli.ts gen <org> <canon> <version> <count>
`);
}

async function main() {
  const [, , cmd, org, canon, version, countStr] = process.argv;
  if (!cmd || !org || !canon || !version) {
    usage();
    process.exit(1);
  }

  const registry = loadRegistry();
  const canonNode = requireCanon(registry, org, canon);
  const label =
    canonNode?.[version]?.label ?? `${org} ${canon} ${version}`;

  if (cmd === "canon") {
    const out = writeCanonSkeleton(org, canon, version, label);
    console.log(`✅ Canon skeleton ready: ${out.root}`);
    console.log(`✅ Manifest: ${out.manifestPath}`);
    process.exit(0);
  }

  if (cmd === "gen") {
    if (!countStr) throw new Error("Missing count");
    const count = Number(countStr);
    if (!Number.isFinite(count) || count <= 0) {
      throw new Error("Count must be positive");
    }

    const root = path.resolve(
      "cert_intel/canon",
      org,
      canon,
      version
    );
    if (!fs.existsSync(root)) {
      writeCanonSkeleton(org, canon, version, label);
    }

    const model = process.env.MODEL || "llama3.1";
    const concurrency = Number(process.env.CONCURRENCY || "1");
    const maxAttempts = Number(process.env.MAX_ATTEMPTS || "8");

    console.log(
      `🧠 MODEL=${model} CONCURRENCY=${concurrency} MAX_ATTEMPTS=${maxAttempts}`
    );
    console.log(
      `🏭 Generating ${count} lesson(s) for ${org}.${canon}.${version}...`
    );

    const results = await generateBatch({
      org,
      canon,
      version,
      count,
      model,
      concurrency,
      maxAttempts,
      ollamaChat,
    });

    const summary = results.reduce((acc, r) => {
      acc[r.status] = (acc[r.status] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    console.log("✅ Batch complete:", summary);
    process.exit(0);
  }

  usage();
  process.exit(1);
}

main().catch((e) => {
  console.error("❌ Factory error:", e?.message || e);
  process.exit(1);
});