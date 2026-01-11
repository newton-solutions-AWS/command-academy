// app/academy/layout.tsx
import Image from "next/image";
import Link from "next/link";

function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white/[0.04] px-4 py-2 text-sm text-white/85 shadow-[0_0_0_1px_rgba(255,255,255,0.03)] transition hover:border-white/25 hover:bg-white/[0.06]"
    >
      {children}
    </Link>
  );
}

function DoctrineStrip() {
  return (
    <div className="border-t border-white/10 bg-black/60">
      <div className="mx-auto max-w-6xl px-6 py-3">
        <p className="text-center text-[11px] uppercase tracking-[0.45em] text-white/55">
          Executable reality · Deterministic doctrine · Immutable canon
        </p>
      </div>
    </div>
  );
}

export default function AcademyLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative min-h-screen overflow-hidden">
      {/* HQ Background */}
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute inset-0 opacity-[0.10] [background-image:linear-gradient(to_right,rgba(255,255,255,0.10)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.10)_1px,transparent_1px)] [background-size:120px_120px]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_18%_12%,rgba(255,255,255,0.10),transparent_55%)]" />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_82%_18%,rgba(255,255,255,0.07),transparent_55%)]" />
        <div className="absolute inset-0 opacity-[0.10] mix-blend-overlay"
          style={{
            backgroundImage:
              "repeating-linear-gradient(0deg, rgba(255,255,255,0.10) 0px, rgba(255,255,255,0.10) 1px, transparent 1px, transparent 6px)",
          }}
        />
      </div>

      {/* COMMAND BAND */}
      <header className="relative border-b border-white/15 bg-black/50">
        <div className="mx-auto max-w-6xl px-6 py-7">
          <div className="flex items-center justify-between gap-6">
            {/* Crest dominance */}
            <div className="flex items-center gap-5">
              <div className="relative">
                {/* halo */}
                <div className="pointer-events-none absolute inset-[-26px] rounded-[44px] bg-white/10 blur-3xl" />
                <div className="relative grid h-[96px] w-[96px] place-items-center rounded-[34px] border border-white/25 bg-black/55 shadow-[0_55px_180px_rgba(0,0,0,0.90)]">
                  <Image
                    src="/crests/academy/academy.png"
                    alt="Newton Command Academy Crest"
                    width={96}
                    height={96}
                    className="h-[74px] w-[74px] object-contain"
                    priority
                  />
                </div>
              </div>

              <div className="min-w-0">
                <div className="text-[11px] tracking-[0.34em] text-white/55">
                  NEWTON SOLUTIONS • COMMAND ACADEMY HQ
                </div>
                <div className="mt-1 text-2xl font-semibold tracking-tight">
                  Academy Command Interface
                </div>

                {/* Canon divider line */}
                <div className="mt-3 flex flex-wrap items-center gap-2">
                  <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/70">
                    PHOENIX v2 • AUDITED
                  </span>
                  <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/70">
                    EXECUTION-VALIDATED
                  </span>
                  <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/70">
                    IMMUTABLE CANON
                  </span>
                </div>
              </div>
            </div>

            {/* Nav */}
            <div className="hidden items-center gap-3 md:flex">
              <NavLink href="/academy">HQ</NavLink>
              <NavLink href="/academy#divisions">Divisions</NavLink>
              <NavLink href="/academy#canon">Canon</NavLink>
              <NavLink href="/">Exit →</NavLink>
            </div>
          </div>
        </div>

        {/* Canon Divider */}
        <div className="h-px w-full bg-gradient-to-r from-transparent via-white/20 to-transparent" />
      </header>

      <DoctrineStrip />

      {/* Content */}
      <main className="relative">{children}</main>
    </div>
  );
}