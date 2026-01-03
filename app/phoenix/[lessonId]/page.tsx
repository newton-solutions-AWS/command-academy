import fs from "fs";
import path from "path";

type Props = {
  params: {
    lessonId: string;
  };
};

export default function PhoenixLessonPage({ params }: Props) {
  const filePath = path.join(
    process.cwd(),
    "cert_intel",
    "canon",
    "atils",
    "phoenix-protocol-secure-cloud-operator",
    "v2",
    "labs",
    `${params.lessonId}.json`
  );

  if (!fs.existsSync(filePath)) {
    return (
      <main style={{ padding: "2rem", color: "#e5e5e5" }}>
        <h1>Lesson not found</h1>
      </main>
    );
  }

  const raw = fs.readFileSync(filePath, "utf8");

  return (
    <main style={{ padding: "2rem", color: "#e5e5e5" }}>
      <h1 style={{ marginBottom: "1rem" }}>📄 {params.lessonId}</h1>
      <pre
        style={{
          background: "#0a0a0a",
          padding: "1rem",
          borderRadius: "8px",
          overflowX: "auto",
          fontSize: "0.85rem"
        }}
      >
        {raw}
      </pre>
    </main>
  );
}