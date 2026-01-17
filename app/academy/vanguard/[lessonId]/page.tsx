import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";

export default function VanguardPage() {
  const lessons = loadCanonLessons("vanguard");

  return (
    <div>
      <h1>Vanguard Protocol · Lessons</h1>

      {lessons.length === 0 && (
        <p>0 lessons detected</p>
      )}

      {lessons.map((l) => (
        <div key={l.id}>{l.title}</div>
      ))}
    </div>
  );
}