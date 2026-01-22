const http = require("http");

const TARGETS = [
  "/",
  "/academy",
  "/academy/phoenix",
  "/academy/phoenix/phoenix-boot-001",
];

const HOST = "localhost";
const PORT = 3000;
const REQUESTS = 500;

function hit(path) {
  return new Promise((resolve) => {
    const req = http.get(
      { hostname: HOST, port: PORT, path },
      (res) => {
        res.resume();
        resolve(res.statusCode);
      }
    );
    req.on("error", () => resolve("ERR"));
  });
}

(async () => {
  console.log("🔥 Local Academy Stress Test Started");
  const start = Date.now();

  const jobs = [];
  for (let i = 0; i < REQUESTS; i++) {
    const path = TARGETS[i % TARGETS.length];
    jobs.push(hit(path));
  }

  const results = await Promise.all(jobs);
  const duration = Date.now() - start;

  const ok = results.filter((r) => r === 200).length;
  const err = results.length - ok;

  console.log("──────────────");
  console.log("Requests:", REQUESTS);
  console.log("200 OK:", ok);
  console.log("Errors:", err);
  console.log("Time:", duration + "ms");
})();