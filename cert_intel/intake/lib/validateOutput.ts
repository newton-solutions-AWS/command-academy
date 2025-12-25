export function validateJsonStructure(
  output: any,
  expected: { must_have_paths: string[] }
): boolean {
  for (const path of expected.must_have_paths) {
    const keys = path.split(".");
    let cursor = output;

    for (const key of keys) {
      if (cursor === null || typeof cursor !== "object" || !(key in cursor)) {
        return false;
      }
      cursor = cursor[key];
    }
  }
  return true;
}