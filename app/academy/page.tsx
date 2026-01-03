// app/academy/page.tsx

import Link from "next/link";

export default function AcademyHomePage() {
  return (
    <main className="p-8 max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-4">
        Command Academy
      </h1>

      <p className="text-lg text-gray-600 mb-8">
        Welcome to the Command Academy. Select a division to begin structured,
        audit-safe, real-world training.
      </p>

      <div className="grid gap-6 md:grid-cols-3">
        <Link
          href="/academy/phoenix"
          className="border rounded-lg p-6 hover:bg-gray-50 transition"
        >
          <h2 className="text-xl font-semibold mb-2">
            🔥 Phoenix Division
          </h2>
          <p className="text-gray-600">
            Secure Cloud Operator training. Identity, visibility, and operational
            confidence in live AWS environments.
          </p>
        </Link>

        <Link
          href="/academy/sentinel"
          className="border rounded-lg p-6 hover:bg-gray-50 transition"
        >
          <h2 className="text-xl font-semibold mb-2">
            🛡 Sentinel Division
          </h2>
          <p className="text-gray-600">
            Defensive security, detection engineering, and operational monitoring.
          </p>
        </Link>

        <Link
          href="/academy/vanguard"
          className="border rounded-lg p-6 hover:bg-gray-50 transition"
        >
          <h2 className="text-xl font-semibold mb-2">
            ⚔️ Vanguard Division
          </h2>
          <p className="text-gray-600">
            Advanced architecture, systems design, and strategic cloud engineering.
          </p>
        </Link>
      </div>
    </main>
  );
}