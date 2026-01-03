// cert_intel/intake/lib/ollama.ts

import { spawn } from "node:child_process";

/**
 * Execute Ollama with a single prompt and return RAW MODEL OUTPUT
 * This function is intentionally dumb: it just runs the model and captures stdout.
 */
function runOllama(prompt: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const model = process.env.MODEL || "llama3.1:latest";

    const proc = spawn("ollama", ["run", model], {
      stdio: ["pipe", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";

    proc.stdout.on("data", (d) => (stdout += d.toString()));
    proc.stderr.on("data", (d) => (stderr += d.toString()));

    proc.on("error", (err) => reject(err));

    proc.on("close", (code) => {
      if (code !== 0) {
        reject(
          new Error(
            `Ollama exited with code ${code}\n${stderr || stdout}`
          )
        );
      } else {
        resolve(stdout.trim());
      }
    });

    proc.stdin.write(prompt);
    proc.stdin.end();
  });
}

/**
 * Extract the FIRST valid JSON object from arbitrary text.
 * This survives:
 * - prose before/after JSON
 * - ```json fences
 * - markdown explanations
 * - multi-object rambles
 */
function extractFirstJson(text: string): string {
  const cleaned = text
    .replace(/```json/gi, "")
    .replace(/```/g, "")
    .trim();

  let depth = 0;
  let start = -1;

  for (let i = 0; i < cleaned.length; i++) {
    const c = cleaned[i];

    if (c === "{") {
      if (depth === 0) start = i;
      depth++;
    } else if (c === "}") {
      depth--;
      if (depth === 0 && start !== -1) {
        return cleaned.slice(start, i + 1);
      }
    }
  }

  throw new Error(
    "Invalid JSON returned from model\n--- RAW ---\n" + text
  );
}

/**
 * Main exported function.
 * Always returns a STRING containing VALID JSON.
 * NEVER returns prose.
 */
export async function ollamaChat(prompt: string): Promise<string> {
  const raw = await runOllama(prompt);

  if (!raw || raw.length < 2) {
    throw new Error("Empty response from Ollama");
  }

  const json = extractFirstJson(raw);

  // Final sanity check (do not trust the model)
  try {
    JSON.parse(json);
  } catch (e) {
    throw new Error(
      "Model returned malformed JSON\n--- RAW ---\n" + raw
    );
  }

  return json;
}