import { loadCanonLessons } from "../cert_intel/intake/lib/lessonloader";

console.log("=== ALL LESSONS ===");
console.log(
  loadCanonLessons().map(l => ({
    id: l.id,
    division: l.division
  }))
);

console.log("\n=== PHOENIX ===");
console.log(loadCanonLessons("phoenix").map(l => l.id));

console.log("\n=== VANGUARD ===");
console.log(loadCanonLessons("vanguard").map(l => l.id));

console.log("\n=== SENTINEL ===");
console.log(loadCanonLessons("sentinel").map(l => l.id));