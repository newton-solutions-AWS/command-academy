// app/page.tsx
import Image from "next/image";
import Link from "next/link";

function Pill({ children }: { children: React.ReactNode }) {
  return (
    <span className="inline-flex items-center rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/65">
      {children}
    </span>
  );
}

export default function HomePage() {
  return (
    <main className="relative min-h-screen overflow-hidden">
      {/* Background */}
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute inset-0 opacity-[0.08] [background-image:linear-gradient(to_right,rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.12)_1px,transparent_1px)] [background-size:120px_120px]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_20%_15%,rgba(255,255,255,0.10),transparent_55%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_80%_20%,rgba(255,255,255,0.07),transparent_55%)]" />
      </div>

      <div className="relative mx-auto max-w-6xl px-6 py-14">
        {/* Crest header */}
        <div className="flex items-center justify-between gap-6">
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="pointer-events-none absolute inset-[-18px] rounded-[28px] bg-white/10 blur-2xl" />
              <div className="relative grid h-[84px] w-[84px] place-items-center rounded-[28px] border border-white/20 bg-black/50 shadow-[0_40px_140px_rgba(0,0,0,0.85)]">
                <Image
                  src="/crests/academy/academy.png"
                  alt="Newton Command Academy"
                  width={84}
                  height={84}
                  className="h-[64px] w-[64px] object-contain"
                  priority
                />
              </div>
            </div>

            <div>
              <div className="text-[11px] tracking-[0.30em] text-white/55">
                NEWTON SOLUTIONS
              </div>
              <div className="mt-1 text-2xl font-semibold tracking-tight">
                Command Academy
              </div>
              <div className="mt-2 flex flex-wrap gap-2">
                <Pill>EXECUTABLE REALITY</Pill>
                <Pill>DETERMINISTIC</Pill>
                <Pill>IMMUTABLE CANON</Pill>
              </div>
            </div>
          </div>

          <Link
            href="/academy"
            className="hidden rounded-2xl border border-white/15 bg-white px-5 py-3 text-sm font-semibold text-black shadow-[0_18px_70px_rgba(0,0,0,0.65)] transition hover:translate-y-[-1px] hover:shadow-[0_24px_90px_rgba(0,0,0,0.75)] md:inline-flex"
          >
            Enter Academy →
          </Link>
        </div>

        {/* Hero */}
        <section className="mt-14 grid gap-10 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
          <div>
            <div className="inline-flex items-center gap-3 rounded-full border border-white/10 bg-white/[0.03] px-4 py-2">
              <span className="h-2 w-2 rounded-full bg-emerald-400/90 shadow-[0_0_18px_rgba(16,185,129,0.35)]" />
              <span className="text-[12px] tracking-[0.12em] text-white/70">
                Phoenix Protocol v2 — Audited • Deterministic • Deployable
              </span>
            </div>

            <h1 className="mt-6 text-5xl font-semibold tracking-tight md:text-6xl">
              Command Academy is
              <span className="block text-white/55">not courseware.</span>
            </h1>

            <p className="mt-5 max-w-xl text-sm leading-relaxed text-white/70 md:text-base">
              A doctrine-first training runtime. We don’t assume resources exist.
              We validate execution success. If it can’t run in a clean sandbox —
              it doesn’t ship.
            </p>

            <div className="mt-7 flex flex-wrap items-center gap-3">
              <Link
                href="/academy"
                className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white px-6 py-3 text-sm font-semibold text-black shadow-[0_18px_70px_rgba(0,0,0,0.65)] transition hover:translate-y-[-1px]"
              >
                Enter Academy →
              </Link>

              <Link
                href="/academy#canon"
                className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white/[0.04] px-6 py-3 text-sm text-white/85 transition hover:border-white/25 hover:bg-white/[0.06]"
              >
                View Canon Standard
              </Link>
            </div>

            <div className="mt-10 text-[12px] tracking-[0.28em] text-white/40">
              FOR SERVING PERSONNEL & SERVICE LEAVERS • CIVILIAN ROUTE AVAILABLE VIA VANGUARD
            </div>
          </div>

          <div className="rounded-[32px] border border-white/10 bg-white/[0.03] p-7 shadow-[0_0_0_1px_rgba(255,255,255,0.03),0_30px_130px_rgba(0,0,0,0.65)]">
            <div className="text-[11px] tracking-[0.30em] text-white/55">
              RUNTIME SIGNAL
            </div>
            <pre className="mt-4 whitespace-pre-wrap rounded-2xl border border-white/10 bg-black/40 p-4 text-xs leading-relaxed text-white/70">
{`MODEL=llama3.1:latest AWS_REGION=us-east-1
MAX_ATTEMPTS=10
npx ts-node cert_intel/intake/cli.ts gen phoenix-protocol-secure-cloud-operator v2 8`}
            </pre>

            <div className="mt-5 border-t border-white/10 pt-5 text-[11px] tracking-[0.35em] text-white/45">
              EXECUTABLE REALITY • DETERMINISTIC DOCTRINE • IMMUTABLE CANON
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}