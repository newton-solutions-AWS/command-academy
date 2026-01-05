// app/academy/phoenix/page.tsx

import Link from "next/link";

export default function PhoenixAcademyPage() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-16 space-y-12">
      <header className="space-y-4">
        <h1 className="text-3xl font-bold">Phoenix Division</h1>
        <p className="text-neutral-400 max-w-3xl">
          Phoenix Division establishes operational foundations for secure cloud
          operators. This division is governed by Phoenix Protocol v2 —
          fully audited, deterministic, and immutable.
        </p>
        <p className="text-emerald-400 text-sm">
          🔒 Phoenix Protocol v2 — Audited & Immutable
        </p>
      </header>

      <section className="space-y-4">
        <h2 className="text-xl font-semibold">Available Protocols</h2>
        <ul className="list-disc list-inside text-neutral-400 space-y-2">
          <li>Secure Cloud Operator — Phoenix Protocol v2</li>
        </ul>
        <Link
          href="/phoenix"
          className="inline-block text-sm font-medium text-emerald-400 hover:underline"
        >
          Enter Phoenix Lessons →
        </Link>
      </section>
    </main>
  );
}