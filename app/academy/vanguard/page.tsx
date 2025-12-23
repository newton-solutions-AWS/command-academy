import { loadLessons } from "@/lib/lessons";

export default function VanguardAcademyPage() {
  const lessons = loadLessons({
    org: "atils",
    canon: "vanguard-protocol-advanced-architecture",
    version: "v1",
  });

  return (
    <div>
      <h1>Vanguard Division</h1>
      <p>Forefront architecture, systems thinking, and leadership.</p>

      <ul>
        {lessons.map((l) => (
          <li key={l.id}>
            <a href={`/lessons/${l.id}`}>{l.title}</a>
          </li>
        ))}
      </ul>
    </div>
  );
}