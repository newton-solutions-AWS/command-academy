import Image from "next/image";
import Link from "next/link";

type RouteKey = "SERVICE" | "CIVILIAN";

export default function RestrictedSentinel({
  activeRoute,
}: {
  activeRoute: RouteKey | null;
}) {
  const isService = activeRoute === "SERVICE";
  const isCivilian = activeRoute === "CIVILIAN";

  const primaryCta = isService
    ? { label: "Enter Sentinel (Included)", href: "/academy/sentinel" }
    : { label: "Request clearance", href: "/academy/sentinel" };

  const hint = !activeRoute
    ? "Route not confirmed. Sentinel remains sealed."
    : isService
      ? "Service privilege detected. Sentinel is included."
      : "Commercial route detected. Sentinel is available as paid add-on (clearance-gated).";

  return (
    <section className="relative border-t border-white/12 bg-black">
      {/* Heavier, prestige ambience */}
      <div
        className="pointer-events-none absolute inset-0 opacity-[0.35]"
        style={{
          backgroundImage:
            "radial-gradient(circle at 50% 30%, rgba(255,255,255,0.10) 0%, transparent 45%), radial-gradient(circle at 20% 70%, rgba(255,255,255,0.06) 0%, transparent 55%)",
        }}
      />

      <div className="mx-auto max-w-6xl px-6 py-14">
        <div className="text-center">
          <div className="text-[10px] uppercase tracking-[0.55em] text-white/55">
            Restricted · advanced operational division
          </div>

          <div className="mx-auto mt-6 h-[1px] w-40 bg-white/15" />

          <div className="mx-auto mt-10 flex max-w-3xl flex-col items-center">
            <div className="relative h-24 w-24 overflow-hidden rounded-sm border border-white/20 bg-black/50">
              <Image
                src="/crests/sentinel/sentinel.png"
                alt="Sentinel Division Crest"
                fill
                className="object-contain"
              />
            </div>

            <h2 className="mt-6 text-3xl font-semibold tracking-tight md:text-4xl">
              Sentinel Division
            </h2>

            <p className="mt-4 max-w-2xl text-sm leading-relaxed text-white/75 md:text-base">
              Defensive security, monitoring, detection, and response doctrine. Advanced operational capability for
              high-trust personnel.
            </p>

            <div className="mt-6 border border-white/15 bg-black/40 px-4 py-3 text-[11px] uppercase tracking-[0.45em] text-white/60">
              {hint}
            </div>

            <div className="mt-8 flex w-full max-w-xl flex-col gap-3">
              <div className="border border-white/12 bg-black/40 p-4">
                <div className="text-[10px] uppercase tracking-[0.45em] text-white/55">
                  Phoenix personnel
                </div>
                <div className="mt-2 text-sm text-white/75">
                  Included by service privilege
                </div>
              </div>

              <div className="border border-white/12 bg-black/40 p-4">
                <div className="text-[10px] uppercase tracking-[0.45em] text-white/55">
                  Vanguard personnel
                </div>
                <div className="mt-2 text-sm text-white/75">
                  Paid add-on · clearance gated
                </div>
              </div>
            </div>

            <div className="mt-8 flex flex-wrap items-center justify-center gap-3">
              <Link
                href={primaryCta.href}
                className="inline-flex items-center gap-2 border border-white/35 bg-white/5 px-5 py-2 text-xs uppercase tracking-[0.55em] hover:bg-white/10"
              >
                {primaryCta.label} <span aria-hidden>→</span>
              </Link>

              <div className="text-[10px] uppercase tracking-[0.35em] text-white/45">
                Clearance behaviour is enforced server-side later (AuthGate).
              </div>
            </div>
          </div>

          <div className="mx-auto mt-12 h-[1px] w-full bg-white/10" />
          <div className="mt-6 text-[10px] uppercase tracking-[0.55em] text-white/45">
            Executable reality · deterministic doctrine · immutable canon
          </div>
        </div>
      </div>
    </section>
  );
}