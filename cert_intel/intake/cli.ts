// cert_intel/intake/cli.ts
import path from "node:path";
import { generateBatch } from "./lib/generate.v1";

function usage() {
  console.log(`Usage:
  npx ts-node cert_intel/intake/cli.ts gen <canon> <version> <count>

Env:
  MODEL=llama3.1:latest
  MAX_ATTEMPTS=10
  AWS_REGION=us-east-1
  DRY_RUN=true|false
`);
}

async function main() {
  const [cmd, canon, version, countStr] = process.argv.slice(2);

  if (cmd !== "gen" || !canon || !version || !countStr) {
    usage();
    process.exit(1);
  }

  const count = Number(countStr);
  if (!Number.isFinite(count) || count < 1) {
    console.error("❌ count must be a positive integer");
    process.exit(1);
  }

  const org = "atils"; // fixed for your repo layout
  const outputDir = path.join("cert_intel", "canon", org, canon, version, "labs");

  const maxAttempts = Number(process.env.MAX_ATTEMPTS || "10");
  const region = process.env.AWS_REGION;

  const dryRun = String(process.env.DRY_RUN || "false").toLowerCase() === "true";

  console.log(`🧠 MODEL=${process.env.MODEL || "unset"} MAX_ATTEMPTS=${maxAttempts}`);
  console.log(`🛡️ Factory Online → ${outputDir}`);
  if (dryRun) console.log(`🧪 DRY-RUN ENABLED`);

  await generateBatch({
    canon,
    version,
    count,
    outputDir,
    maxAttempts,
    region,
    dryRun,
  });
}

main().catch((e) => {
  console.error("❌ Fatal:", e?.message || e);
  process.exit(1);
});