import { appendTranscriptEvent, computeTranscriptStatus } from "./lib/store";

function usage() {
  console.log(`
ATILS Transcript CLI

Record an event:
  npx ts-node cert_intel/transcript/cli.ts record <PASS|FAIL> <student_id> <canon> <version> <lesson_id> \\
    --command "<cmd>" --expected "<expected>" --match <exact|contains> \\
    [--engine v2] [--model llama3.1:latest] [--region us-east-1] [--attempt 1] \\
    [--stdout "<preview>"] [--stderr "<preview>"] [--exit 0]

Show status:
  npx ts-node cert_intel/transcript/cli.ts status <student_id> <canon> <version>
`);
}

function argFlag(name: string) {
  const idx = process.argv.indexOf(name);
  if (idx === -1) return undefined;
  return process.argv[idx + 1];
}

function must(x: any, msg: string) {
  if (!x) throw new Error(msg);
  return x;
}

async function main() {
  const [,, cmd, ...rest] = process.argv;

  if (!cmd) {
    usage();
    process.exit(1);
  }

  if (cmd === "record") {
    const outcome = rest[0];
    const studentId = rest[1];
    const canon = rest[2];
    const version = rest[3];
    const lessonId = rest[4];

    must(outcome, "Missing outcome PASS|FAIL");
    must(studentId, "Missing student_id");
    must(canon, "Missing canon");
    must(version, "Missing version");
    must(lessonId, "Missing lesson_id");

    const command = must(argFlag("--command"), "Missing --command");
    const expected = must(argFlag("--expected"), "Missing --expected");
    const match = (argFlag("--match") || "exact") as "exact" | "contains";

    const engine = argFlag("--engine") || process.env.ENGINE || "unknown";
    const model = argFlag("--model") || process.env.MODEL || "unknown";
    const region = argFlag("--region") || process.env.AWS_REGION;

    const attempt = Number(argFlag("--attempt") || "1");
    const stdout_preview = argFlag("--stdout") || "";
    const stderr_preview = argFlag("--stderr") || "";
    const exit_code = Number(argFlag("--exit") || "0");

    const ev = appendTranscriptEvent({
      student_id: studentId,
      canon,
      version,
      lesson_id: lessonId,
      outcome: outcome === "PASS" ? "PASS" : "FAIL",
      attempt,
      engine,
      model,
      region,
      validate: { command, expected, match },
      stdout_preview,
      stderr_preview,
      exit_code,
    });

    console.log("✅ Transcript event recorded:");
    console.log(JSON.stringify(ev, null, 2));
    return;
  }

  if (cmd === "status") {
    const studentId = rest[0];
    const canon = rest[1];
    const version = rest[2];

    must(studentId, "Missing student_id");
    must(canon, "Missing canon");
    must(version, "Missing version");

    const status = computeTranscriptStatus({ studentId, canon, version });
    console.log("📜 Transcript status:");
    console.log(JSON.stringify(status, null, 2));
    return;
  }

  usage();
  process.exit(1);
}

main().catch((e) => {
  console.error("❌", e?.message || e);
  process.exit(1);
});
