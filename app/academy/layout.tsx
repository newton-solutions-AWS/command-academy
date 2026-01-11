// app/academy/layout.tsx
import Image from "next/image";
import Link from "next/link";

function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white/[0.04] px-4 py-2 text-sm text-white/85 transition hover:border-white/25 hover:bg-white/[0.06]"
    >
      {children}
    </Link>
  );
}

export default function AcademyLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative min-h-screen overflow-hidden bg-black">

      {/* ========================= */}
      {/* BACKGROUND WATERMARK CREST */}
      {/* ========================= */}
      <div className="pointer-events-none absolute inset-0 z-0 flex items-center justify-center">
        <Image
          src="/crests/academy/academy.png"
          alt="Newton Command Academy Watermark"
          width={900}
          height={900}
          className="
            opacity-[0.035]
            max-w-[85vw]
            h-auto
            object-contain
            blur-[0.3px]
          "
          priority={false}
        />
      </div>

      {/* ========================= */}
      {/* ATMOSPHERIC GRID + GRAIN */}
      {/* ========================= */}
      <div className="pointer-events-none absolute inset-0 z-0">
        <div className="absolute inset-0 opacity-[0.08]
          [background-image:linear-gradient(to_right,rgba(255,255,255,0.10)_1px,transparent_1px),
          linear-gradient(to_bottom,rgba(255,255,255,0.10)_1px,transparent_1px)]
          [background-size:120px_120px]" />
        <div
          className="absolute inset-0 opacity-[0.10] mix-blend-overlay"
          style={{
            backgroundImage:
              "repeating-linear-gradient(0deg, rgba(255,255,255,0.10) 0px, rgba(255,255,255,0.10) 1px, transparent 1px, transparent 6px)",
          }}
        />
      </div>

      {/* ========================= */}
      {/* COMMAND BAND / HEADER */}
      {/* ========================= */}
      <header className="relative z-10 border-b border-white/15 bg-black/60 backdrop-blur-sm">
        <div className="mx-auto max-w-6xl px-6 py-7">
          <div className="flex items-center justify-between gap-6">

            {/* HQ CREST + TITLE */}
            <div className="flex items-center gap-6">
              <div className="relative">
                {/* Halo */}
                <div className="pointer-events-none absolute inset-[-28px] rounded-[44px] bg-white/10 blur-3xl" />

                <div className="relative grid h-[104px] w-[104px] place-items-center rounded-[36px]
                  border border-white/25 bg-black/60
                  shadow-[0_60px_200px_rgba(0,0,0,0.95)]"
                >
                  <Image
                    src="/crests/academy/academy.png"
                    alt="Newton Command Academy Crest"
                    width={96}
                    height={96}
                    className="h-[76px] w-[76px] object-contain"
                    priority
                  />
                </div>
              </div>

              <div>
                <div className="text-[11px] tracking-[0.38em] text-white/55">
                  NEWTON SOLUTIONS
                </div>
                <div className="mt-1 text-2xl font-semibold tracking-tight">
                  Command Academy
                </div>

                {/* Canon badges */}
                <div className="mt-3 flex flex-wrap gap-2">
                  <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/70">
                    PHOENIX v2 • AUDITED
                  </span>
                  <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/70">
                    EXECUTABLE REALITY
                  </span>
                  <span className="rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/70">
                    IMMUTABLE CANON
                  </span>
                </div>
              </div>
            </div>

            {/* NAV */}
            <nav className="hidden items-center gap-3 md:flex">
              <NavLink href="/academy">HQ</NavLink>
              <NavLink href="/academy#divisions">Divisions</NavLink>
              <NavLink href="/academy#canon">Canon</NavLink>
              <NavLink href="/">Exit →</NavLink>
            </nav>
          </div>
        </div>

        {/* Canon divider */}
        <div className="h-px w-full bg-gradient-to-r from-transparent via-white/25 to-transparent" />
      </header>

      {/* ========================= */}
      {/* DOCTRINE STRIP */}
      {/* ========================= */}
      <div className="relative z-10 border-b border-white/10 bg-black/70">
        <div className="mx-auto max-w-6xl px-6 py-3 text-center">
          <p className="text-[11px] uppercase tracking-[0.45em] text-white/55">
            Executable Reality · Deterministic Doctrine · Immutable Canon
          </p>
        </div>
      </div>

      {/* ========================= */}
      {/* PAGE CONTENT */}
      {/* ========================= */}
      <main className="relative z-10">
        {children}
      </main>
    </div>
  );
}