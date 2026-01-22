import { phoenixLessons } from "@/cert_intel/intake/lib/lessons";

console.log("🧠 MEMORY STRESS — LESSON OBJECTS");

const copies = [];

for (let i = 0; i < 10000; i++) {
  copies.push({ ...phoenixLessons["phoenix-boot-001"] });
}

console.log("Loaded lesson copies:", copies.length);

// Keep process alive
setTimeout(() => {
  console.log("Memory held for inspection");
}, 60000);