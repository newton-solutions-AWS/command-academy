// cert_intel/intake/lib/jsonSafeParse.ts

type Ok = { ok: true; value: any };
type Fail = { ok: false; reason?: string; preview?: string };

function previewOf(s: string, n = 400) {
  const t = (s || "").replace(/\r/g, "");
  return t.length <= n ? t : t.slice(0, n) + "\n...<truncated>...";
}

/**
 * Extract the first valid JSON object from an arbitrary LLM response.
 * Handles:
 * - prose before/after JSON
 * - ```json fenced blocks
 * - multiple code blocks
 * - multiple JSON objects (takes first that parses)
 */
export function jsonSafeParse(raw: string): Ok | Fail {
  if (!raw || typeof raw !== "string") return { ok: false, reason: "raw_not_string" };

  const text = raw.trim();
  if (!text) return { ok: false, reason: "raw_empty" };

  // 1) If fenced blocks exist, try to parse inside them first (best signal)
  // Matches ```json ... ``` or ``` ... ```
  const fenceRe = /```(?:json)?\s*([\s\S]*?)\s*```/gi;
  const fencedCandidates: string[] = [];
  let m: RegExpExecArray | null;

  while ((m = fenceRe.exec(text))) {
    if (m[1]) fencedCandidates.push(m[1].trim());
  }

  for (const cand of fencedCandidates) {
    const parsed = tryParseFirstJsonObject(cand);
    if (parsed.ok) return parsed;
  }

  // 2) Fallback: parse from the whole output
  return tryParseFirstJsonObject(text);
}

function tryJsonParse(s: string): Ok | Fail {
  try {
    return { ok: true, value: JSON.parse(s) };
  } catch {
    return { ok: false };
  }
}

/**
 * Scan for the first balanced {...} region and try JSON.parse on it.
 * If it fails, keep scanning for the next balanced object.
 */
function tryParseFirstJsonObject(blob: string): Ok | Fail {
  const s = blob;
  const len = s.length;

  let start = -1;
  let depth = 0;
  let inStr = false;
  let esc = false;

  for (let i = 0; i < len; i++) {
    const ch = s[i];

    if (inStr) {
      if (esc) {
        esc = false;
      } else if (ch === "\\") {
        esc = true;
      } else if (ch === '"') {
        inStr = false;
      }
      continue;
    }

    if (ch === '"') {
      inStr = true;
      continue;
    }

    if (ch === "{") {
      if (depth === 0) start = i;
      depth++;
      continue;
    }

    if (ch === "}") {
      if (depth > 0) depth--;
      if (depth === 0 && start !== -1) {
        const candidate = s.slice(start, i + 1).trim();
        const parsed = tryJsonParse(candidate);
        if (parsed.ok) return parsed;
        // keep scanning for next object
        start = -1;
      }
    }
  }

  return { ok: false, reason: "no_valid_json_object", preview: previewOf(blob) };
}