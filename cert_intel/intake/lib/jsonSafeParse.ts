// cert_intel/intake/lib/jsonSafeParse.ts

export function jsonSafeParse(raw: string): any {
  if (!raw || typeof raw !== "string") {
    throw new Error("Empty or non-string model output");
  }

  // HARD STRIP everything before first {
  const firstBrace = raw.indexOf("{");
  const lastBrace = raw.lastIndexOf("}");

  if (firstBrace === -1 || lastBrace === -1 || lastBrace <= firstBrace) {
    throw new Error("No valid JSON object boundaries found in model output");
  }

  const jsonSlice = raw.slice(firstBrace, lastBrace + 1);

  try {
    return JSON.parse(jsonSlice);
  } catch (err) {
    throw new Error(
      "Invalid JSON after sanitization:\n" +
        jsonSlice.slice(0, 500)
    );
  }
}