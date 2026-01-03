// app/academy/phoenix/page.tsx
import { loadLessons } from "@/lib/lessons";

export default function PhoenixAcademyPage() {
  const lessons = loadLessons({
    canon: "phoenix-protocol-secure-cloud-operator",
    version: "v2",
  });

  return (
    <main style={{ padding: "2rem" }}>
      <h1>Phoenix Division</h1>
      <p>Secure Cloud Operator Track</p>

      <ul>
        {lessons.map((lesson) => (
          <li key={lesson.id}>
            {lesson.title}
          </li>
        ))}
      </ul>
    </main>
  );
}
