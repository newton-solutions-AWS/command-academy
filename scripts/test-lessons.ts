// scripts/test-lessons.ts

const lessonLoader = require("../cert_intel/intake/lib/lessonloader");

if (!lessonLoader || typeof lessonLoader !== "object") {
  console.error("lessonloader module not found or invalid");
  process.exit(1);
}

const loadLessons =
  lessonLoader.loadLessons ||
  lessonLoader.default ||
  lessonLoader;

if (typeof loadLessons !== "function") {
  console.error("❌ loadLessons is NOT a function");
  console.log("Exports:", Object.keys(lessonLoader));
  process.exit(1);
}

const lessons = loadLessons({
  canon: "phoenix-protocol-secure-cloud-operator",
  version: "v2",
});

console.log("LESSON COUNT:", lessons.length);

for (const lesson of lessons) {
  console.log(`- ${lesson.id}: ${lesson.title}`);
}