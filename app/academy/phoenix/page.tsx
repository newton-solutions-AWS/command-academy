import { loadLessons } from "@/lib/lessons";

export default function PhoenixAcademyPage() {
  const lessons = loadLessons({
    org: "atils",
    canon: "phoenix-protocol-secure-cloud-operator",
    version: "v1"
  });

  return (
    <div>
      <h1>Phoenix Division</h1>
      <p>Live lessons from the ATILS engine.</p>

      <ul>
        {lessons.map(l => (
          <li key={l.id}>
            {l.title}
          </li>
        ))}
      </ul>
    </div>
  );
}