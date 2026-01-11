// app/academy/page.tsx
import Image from "next/image";
import Link from "next/link";

type Division = {
  id: "phoenix" | "vanguard" | "sentinel";
  name: string;
  routeTag: string;
  description: string;
  bullets: string[];
  ctaLabel: string;
  href: string;
  accent: "phoenix" | "vanguard" | "sentinel";
  crestSrc: string;
};

function cn(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}

function AccentBorder(accent: Division["accent"]) {
  return {
    phoenix: "border-amber-500/20",
    vanguard: "border-blue-500/20",
    sentinel: "border-rose-500/20",
  }[accent];
}

function Pill({ children }: { children: React.ReactNode }) {
  return (
    <span className="inline-flex items-center rounded-full border border-white/10 bg-white/[0.04] px-3 py-1 text-[11px] tracking-[0.18em] text-white/65">
      {children}
    </span>
  );
}

function PrimaryButton({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white px-6 py-3 text-sm font-semibold text-black shadow-[0_18px_70px_rgba(0,0,0,0.65)] transition hover:translate-y-[-1px]"
    >
      {children}
    </Link>
  );
}

function GhostButton({ href, children }: { href: string; children: React.ReactNode }) {
  return (
    <Link
      href={href}
      className="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white/[0.04] px-6 py-3 text-sm text-white/85 transition hover:border-white/25 hover:bg-white/[0.06]"
    >
      {children}
    </Link>
  );
}

function DivisionCard({ d }: { d: Division }) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-[30px] border bg-white/[0.03] p-7 shadow-[0_0_0_1px_rgba(255,255,255,0.03),0_30px_120px_rgba(0,0,0,0.65)]",
        AccentBorder(d.accent)
      )}
    >
      <div className="pointer-events-none absolute inset-0 opacity-0 transition duration-500 hover:opacity-100">
        <div className="absolute -inset-24 bg-[radial-gradient(circle_at_30%_30%,rgba(255,255,255,0.10),transparent_55%)]" />
      </div>

      <div className="relative flex items-start justify-between gap-6">
        <div className="flex items-center gap-4">
          <div className="grid h-14 w-14 place-items-center rounded-2xl border border-white/15 bg-black/40">
            <Image
              src={d.crestSrc}
              alt={`${d.name} crest`}
              width={56}
              height={56}
              className="h-11 w-11 object-contain"
            />
          </div>

          <div>
            <div className="text-[11px] tracking-[0.30em] text-white/55">{d.routeTag}</div>
            <h3 className="mt-2 text-2xl font-semibold tracking-tight">{d.name}</h3>
          </div>
        </div>

        <Pill>{d.id.toUpperCase()}</Pill>
      </div>

      <p className="relative mt-5 text-sm leading-relaxed text-white/70">{d.description}</p>

      <ul className="relative mt-5 space-y-2">
        {d.bullets.map((b) => (
          <li key={b} className="text-sm text-white/70">
            <span className="mr-2 text-white/35">•</span>
            {b}
          </li>
        ))}
      </ul>

      <div className="relative mt-7 flex items-center justify-between gap-4">
        <Link
          href={d.href}
          className="inline-flex items-center gap-2 rounded-2xl border border-white/15 bg-white/[0.05] px-5 py-3 text-sm font-semibold text-white/90 transition hover:border-white/25 hover:bg-white/[0.07]"
        >
          {d.ctaLabel} <span className="text-white/70">→</span>
        </Link>

        <span className="text-[11px] tracking-[0.30em] text-white/45">
          EXECUTABLE • AUDITED • DETERMINISTIC
        </span>
      </div>
    </div>
  );
}

function SentinelTheatre({ d }: { d: Division }) {
  return (
    <section className="mt-10">
      <div
        className={cn(
          "relative overflow-hidden rounded-[36px] border bg-white/[0.025] p-9 shadow-[0_0_0_1px_rgba(255,255,255,0.03),0_45px_180px_rgba(0,0,0,0.72)]",
          AccentBorder("sentinel")
        )}
      >
        <div className="pointer-events-none absolute inset-0">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_70%_10%,rgba(255,255,255,0.09),transparent_55%)]" />
          <div className="absolute inset-0 opacity-[0.07] [background-image:linear-gradient(to_right,rgba(255,255,255,0.12)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.12)_1px,transparent_1px)] [background-size:140px_140px]" />
        </div>

        <div className="relative grid gap-9 lg:grid-cols-[1.2fr_0.8fr] lg:items-center">
          <div>
            <div className="flex flex-wrap items-center gap-3">
              <Pill>PRESTIGE ADD-ON</Pill>
              <span className="text-[11px] tracking-[0.30em] text-white/55">
                CLEARANCE-GATED • ADVANCED OPERATIONAL DIVISION
              </span>
            </div>

            <h2 className="mt-5 text-4xl font-semibold tracking-tight">
              Sentinel Division
            </h2>

            <p className="mt-4 max-w-2xl text-sm leading-relaxed text-white/70">
              The specialist edge: detection, response, and elite competence signals.
              Not “more lessons” — <span className="text-white/85">authority</span>.
            </p>

            <div className="mt-6 grid gap-3 sm:grid-cols-2">
              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-4">
                <div className="text-[11px] tracking-[0.30em] text-white/55">PHOENIX PERSONNEL</div>
                <div className="mt-2 text-sm text-white/80">Included by service privilege</div>
              </div>
              <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-4">
                <div className="text-[11px] tracking-[0.30em] text-white/55">VANGUARD PERSONNEL</div>
                <div className="mt-2 text-sm text-white/80">Paid add-on • clearance gated</div>
              </div>
            </div>

            <div className="mt-7 flex flex-wrap items-center gap-3">
              <PrimaryButton href={d.href}>Unlock Sentinel →</PrimaryButton>
              <GhostButton href="#canon">View Canon Standard</GhostButton>
            </div>
          </div>

          <div className="relative grid place-items-center">
            <div className="relative grid place-items-center rounded-[34px] border border-white/10 bg-black/35 p-10">
              <Image
                src={d.crestSrc}
                alt="Sentinel crest"
                width={300}
                height={300}
                className="h-44 w-44 object-contain drop-shadow-[0_40px_120px_rgba(0,0,0,0.9)]"
              />
              <div className="mt-7 w-full rounded-2xl border border-white/10 bg-white/[0.03] p-4">
                <div className="text-[11px] tracking-[0.30em] text-white/55">SENTINEL SIGNAL</div>
                <div className="mt-2 text-sm text-white/75">
                  Prestige tier • immutable once locked • operate at the edge
                </div>
              </div>
            </div>

            <div className="pointer-events-none absolute -inset-14 rounded-[60px] bg-[radial-gradient(circle_at_center,rgba(255,255,255,0.08),transparent_60%)]" />
          </div>
        </div>
      </div>
    </section>
  );
}

function CanonStandard() {
  return (
    <section id="canon" className="mt-12">
      <div className="rounded-[36px] border border-white/10 bg-white/[0.03] p-9 shadow-[0_0_0_1px_rgba(255,255,255,0.03),0_30px_140px_rgba(0,0,0,0.65)]">
        <h3 className="text-2xl font-semibold tracking-tight">
          The Command Academy Standard
        </h3>
        <p className="mt-3 max-w-3xl text-sm leading-relaxed text-white/70">
          Most courses teach. Command Academy proves. We validate execution success,
          not “state assumptions”. If it can’t run in a clean sandbox — it doesn’t ship.
        </p>

        <div className="mt-7 grid gap-3 md:grid-cols-2">
          {[
            "Read-only CLI doctrine",
            "Empty-sandbox safe execution",
            "No named resources (no s3://my-bucket)",
            "No hardcoded account IDs",
            "No quantity assumptions",
            "Behavior-based validation",
          ].map((x) => (
            <div
              key={x}
              className="rounded-2xl border border-white/10 bg-black/25 px-5 py-4 text-sm text-white/75"
            >
              {x}
            </div>
          ))}
        </div>

        <div className="mt-7 flex flex-wrap items-center gap-2">
          <Pill>IMMUTABLE CANON</Pill>
          <Pill>DETERMINISTIC DOCTRINE</Pill>
          <Pill>EXECUTABLE REALITY</Pill>
        </div>
      </div>
    </section>
  );
}

export default function AcademyPage() {
  const divisions: Division[] = [
    {
      id: "phoenix",
      name: "Phoenix Division",
      routeTag: "SERVICE ROUTE • SENTINEL INCLUDED",
      description:
        "Secure Cloud Operator doctrine. Audited, read-only execution that works in empty sandboxes. Built for serving personnel and service leavers.",
      bullets: ["Honour-based access • no paywall", "Validated execution paths", "Transition-first doctrine"],
      ctaLabel: "Enter Phoenix",
      href: "/academy/phoenix",
      accent: "phoenix",
      crestSrc: "/crests/phoenix/phoenix.png",
    },
    {
      id: "vanguard",
      name: "Vanguard Division",
      routeTag: "CIVILIAN ROUTE • PAID ENTRY",
      description:
        "Architecture, infrastructure, and systems leadership doctrine. Civilian access path — paid entry, structured progression, operational readiness.",
      bullets: ["Commercial access", "Structured progression", "Sentinel available as add-on"],
      ctaLabel: "Enter Vanguard",
      href: "/academy/vanguard",
      accent: "vanguard",
      crestSrc: "/crests/vanguard/vanguard.png",
    },
    {
      id: "sentinel",
      name: "Sentinel Division",
      routeTag: "RESTRICTED • PRESTIGE ADD-ON",
      description:
        "Defensive security, detection, response, and elite competence signals. Clearance-gated advanced operational capability.",
      bullets: ["Phoenix included by privilege", "Vanguard paid add-on", "High-trust operational content"],
      ctaLabel: "Unlock Sentinel",
      href: "/academy/sentinel",
      accent: "sentinel",
      crestSrc: "/crests/sentinel/sentinel.png",
    },
  ];

  const phoenix = divisions[0]!;
  const vanguard = divisions[1]!;
  const sentinel = divisions[2]!;

  return (
    <main className="relative mx-auto w-full max-w-6xl px-6 pb-20 pt-12">
      {/* Hero */}
      <section className="grid gap-9 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
        <div>
          <div className="inline-flex items-center gap-3 rounded-full border border-white/10 bg-white/[0.03] px-4 py-2">
            <span className="h-2 w-2 rounded-full bg-emerald-400/90 shadow-[0_0_18px_rgba(16,185,129,0.35)]" />
            <span className="text-[12px] tracking-[0.12em] text-white/70">
              Phoenix Protocol v2 — Audited • Deterministic • Deployable
            </span>
          </div>

          <h1 className="mt-6 text-5xl font-semibold tracking-tight md:text-6xl">
            Newton Command Academy
            <span className="block text-white/55">HQ Division Select</span>
          </h1>

          <p className="mt-5 max-w-xl text-sm leading-relaxed text-white/70 md:text-base">
            Phoenix is the service route. Vanguard is the civilian paid route.
            Sentinel is the prestige add-on tier across both.
          </p>

          <div className="mt-7 flex flex-wrap items-center gap-3">
            <PrimaryButton href="#divisions">Launch Divisions →</PrimaryButton>
            <GhostButton href="#canon">Canon Standard</GhostButton>
          </div>
        </div>

        <div className="rounded-[36px] border border-white/10 bg-white/[0.03] p-8 shadow-[0_0_0_1px_rgba(255,255,255,0.03),0_35px_160px_rgba(0,0,0,0.65)]">
          <div className="text-[11px] tracking-[0.30em] text-white/55">CANON SIGNAL</div>
          <pre className="mt-4 whitespace-pre-wrap rounded-2xl border border-white/10 bg-black/40 p-4 text-xs leading-relaxed text-white/70">
{`DRY_RUN=true MODEL=llama3.1:latest AWS_REGION=us-east-1 MAX_ATTEMPTS=5
npx ts-node cert_intel/intake/cli.ts gen phoenix-protocol-secure-cloud-operator v2 8`}
          </pre>
          <div className="mt-5 border-t border-white/10 pt-5 text-[11px] tracking-[0.35em] text-white/45">
            EXECUTABLE REALITY • DETERMINISTIC • IMMUTABLE
          </div>
        </div>
      </section>

      {/* Divisions */}
      <section id="divisions" className="mt-12">
        <div className="rounded-[36px] border border-white/10 bg-white/[0.03] p-9">
          <div className="text-[11px] tracking-[0.30em] text-white/55">
            COMMAND DIVISIONAL ACCESS
          </div>
          <h2 className="mt-4 text-4xl font-semibold tracking-tight">Divisions</h2>
          <p className="mt-3 max-w-3xl text-sm leading-relaxed text-white/70">
            Phoenix and Vanguard are equal-weight entry routes. Sentinel is the prestige layer.
          </p>
        </div>

        <div className="mt-7 grid gap-6 lg:grid-cols-2">
          <DivisionCard d={phoenix} />
          <DivisionCard d={vanguard} />
        </div>

        <SentinelTheatre d={sentinel} />
      </section>

      <CanonStandard />

      <footer className="mt-14 border-t border-white/10 pt-10 text-center">
        <div className="text-[11px] tracking-[0.38em] text-white/45">
          EXECUTABLE REALITY • DETERMINISTIC DOCTRINE • IMMUTABLE CANON
        </div>
        <div className="mt-3 text-xs text-white/35">
          Newton Solutions — Command Academy HQ
        </div>
      </footer>
    </main>
  );
}