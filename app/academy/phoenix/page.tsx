import Link from "next/link";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function PhoenixPage() {
  const lessons = loadCanonLessons("phoenix");

  return (
    <div style={{ padding: 40 }}>
      <h1>Phoenix Protocol · Lessons</h1>

      {lessons.length === 0 && <p>No lessons detected</p>}

      <ul style={{ marginTop: 20 }}>
        {lessons.map((l) => (
          <li key={l.id} style={{ marginBottom: 10 }}>
            <Link
              href={`/academy/phoenix/${l.id}`}
              style={{ color: "#00ff88", textDecoration: "underline" }}
            >
              {l.title}
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}