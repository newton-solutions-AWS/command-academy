// app/academy/page.tsx

import Link from "next/link";

export default function AcademyLandingPage() {
  return (
    <main className="mx-auto max-w-5xl px-6 py-16 space-y-16">
      {/* HERO */}
      <section className="space-y-4">
        <h1 className="text-4xl font-bold tracking-tight">
          Command Academy
        </h1>
        <p className="text-lg text-neutral-400 max-w-3xl">
          From Service to Cyber — executed with discipline.
          <br />
          A doctrine-driven academy built for operators, engineers, and leaders.
        </p>
      </section>

      {/* DIVISIONS */}
      <section className="grid gap-8 md:grid-cols-3">
        {/* PHOENIX */}
        <div className="rounded-xl border border-neutral-800 p-6 space-y-4">
          <h2 className="text-xl font-semibold">Phoenix Division</h2>
          <p className="text-sm text-neutral-400">
            Foundation and operational readiness. Identity, cloud security,
            and disciplined execution.
          </p>
          <p className="text-sm text-emerald-400">
            🔒 Phoenix Protocol v2 — Audited & Immutable
          </p>
          <Link
            href="/academy/phoenix"
            className="inline-block text-sm font-medium text-emerald-400 hover:underline"
          >
            Enter Phoenix →
          </Link>
        </div>

        {/* SENTINEL */}
        <div className="rounded-xl border border-neutral-800 p-6 space-y-4">
          <h2 className="text-xl font-semibold">Sentinel Division</h2>
          <p className="text-sm text-neutral-400">
            Coding, automation, and cyber capability.
            Offensive and defensive skill-building.
          </p>
          <p className="text-sm text-yellow-400">
            🟡 Active Development
          </p>
          <Link
            href="/academy/sentinel"
            className="inline-block text-sm font-medium text-yellow-400 hover:underline"
          >
            View Sentinel →
          </Link>
        </div>

        {/* VANGUARD */}
        <div className="rounded-xl border border-neutral-800 p-6 space-y-4">
          <h2 className="text-xl font-semibold">Vanguard Division</h2>
          <p className="text-sm text-neutral-400">
            Architecture, systems thinking, and leadership at scale.
          </p>
          <p className="text-sm text-yellow-400">
            🟡 Active Development
          </p>
          <Link
            href="/academy/vanguard"
            className="inline-block text-sm font-medium text-yellow-400 hover:underline"
          >
            View Vanguard →
          </Link>
        </div>
      </section>

      {/* CANON NOTICE */}
      <section className="rounded-xl border border-neutral-800 bg-neutral-950 p-6 space-y-2">
        <h3 className="font-semibold">Canon Governance</h3>
        <p className="text-sm text-neutral-400">
          Phoenix Protocol v2 has passed full static audit and is frozen as
          immutable canon. Any future changes require a new protocol version.
        </p>
      </section>
    </main>
  );
}