export function jsonSafeParse(raw: string) {
  // Extract JSON block
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");

  if (start === -1 || end === -1) {
    throw new Error("No JSON object detected in LLM output");
  }

  let slice = raw.slice(start, end + 1);

  // 1. Remove illegal control characters (except \n \r \t)
  slice = slice.replace(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/g, "");

  // 2. Normalize unescaped newlines inside strings
  slice = slice.replace(/(?<!\\)\n/g, "\\n");

  // 3. Fix trailing commas
  slice = slice
    .replace(/,\s*}/g, "}")
    .replace(/,\s*]/g, "]");

  try {
    return JSON.parse(slice);
  } catch (err: any) {
    throw new Error(
      `JSON parse failed after sanitization: ${err.message}`
    );
  }
}