const http = require("http");

const TARGET = "http://localhost:3000";
const REQUESTS = 500;

let completed = 0;

for (let i = 0; i < REQUESTS; i++) {
  http.get(TARGET + "/academy/phoenix/phoenix-boot-001", (res) => {
    res.on("data", () => {});
    res.on("end", () => {
      completed++;
      if (completed === REQUESTS) {
        console.log("HTTP stress test complete");
      }
    });
  }).on("error", (err) => {
    console.error("Request error:", err.message);
  });
}