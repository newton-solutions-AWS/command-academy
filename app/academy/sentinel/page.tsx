import { loadLessons } from "@/lib/lessons";

export default function SentinelAcademyPage() {
  const lessons = loadLessons({
    org: "atils",
    canon: "sentinel-protocol-defensive-operations",
    version: "v1",
  });

  return (
    <div>
      <h1>Sentinel Division</h1>
      <p>Defensive security, authority, and operational judgement.</p>

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