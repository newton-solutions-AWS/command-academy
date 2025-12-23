import { loadLessons } from "@/lib/lessons";

export default function VanguardAcademyPage() {
  const lessons = loadLessons({
    org: "atils",
    canon: "vanguard-protocol-advanced-architecture",
    version: "v1"
  });

  return (
    <div>
      <h1>Vanguard Division</h1>
      <p>Architecture, systems leadership, and forefront engineering.</p>

      <ul>
        {lessons.map(l => (
          <li key={l.id}>{l.title}</li>
        ))}
      </ul>
    </div>
  );
}