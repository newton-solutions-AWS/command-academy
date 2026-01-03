import fs from "fs";
import path from "path";

type Lesson = {
  id: string;
  title: string;
  duration_minutes: number;
};

export default function PhoenixPage() {
  const labsDir = path.join(
    process.cwd(),
    "cert_intel",
    "canon",
    "atils",
    "phoenix-protocol-secure-cloud-operator",
    "v2",
    "labs"
  );

  let lessons: Lesson[] = [];

  if (fs.existsSync(labsDir)) {
    const files = fs.readdirSync(labsDir).filter(f => f.endsWith(".json"));

    lessons = files.map(file => {
      const raw = fs.readFileSync(path.join(labsDir, file), "utf8");
      const json = JSON.parse(raw);
      return {
        id: json.id,
        title: json.title,
        duration_minutes: json.duration_minutes
      };
    });
  }

  return (
    <main style={{ padding: "2rem", color: "#e5e5e5" }}>
      <h1 style={{ fontSize: "2rem", marginBottom: "1rem" }}>
        🔥 Phoenix Protocol — v2
      </h1>

      <p style={{ opacity: 0.8, marginBottom: "2rem" }}>
        Deterministic, audit-safe cloud operator training.
      </p>

      {lessons.length === 0 && (
        <p>No Phoenix v2 lessons found.</p>
      )}

      <ul style={{ listStyle: "none", padding: 0 }}>
        {lessons.map(lesson => (
          <li
            key={lesson.id}
            style={{
              border: "1px solid #333",
              borderRadius: "8px",
              padding: "1rem",
              marginBottom: "1rem"
            }}
          >
            <strong>{lesson.title}</strong>
            <div style={{ fontSize: "0.9rem", opacity: 0.8 }}>
              ID: {lesson.id}
            </div>
            <div style={{ fontSize: "0.9rem", opacity: 0.8 }}>
              Duration: {lesson.duration_minutes} minutes
            </div>

            <a
              href={`/phoenix/${lesson.id}`}
              style={{ color: "#60a5fa", marginTop: "0.5rem", display: "inline-block" }}
            >
              View lesson JSON →
            </a>
          </li>
        ))}
      </ul>
    </main>
  );
}