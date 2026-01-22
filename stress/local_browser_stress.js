import fetch from "node-fetch";

const BASE = "http://localhost:3000";
const LESSON = "/academy/phoenix/phoenix-boot-001";

async function hit() {
  const res = await fetch(BASE + LESSON);
  await res.text();
}

async function run() {
  console.log("🔥 Browser-style stress test started");

  const tasks = [];
  for (let i = 0; i < 200; i++) {
    tasks.push(hit());
  }

  await Promise.all(tasks);
  console.log("✅ Stress test complete");
}

run();