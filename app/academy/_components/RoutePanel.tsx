import Image from "next/image";

type RouteKey = "SERVICE" | "CIVILIAN";

export default function RoutePanel({
  route,
  title,
  crestSrc,
  bullets,
  ctaLabel,
  onSelect,
  accent,
}: {
  route: RouteKey;
  title: string;
  crestSrc: string;
  bullets: string[];
  ctaLabel: string;
  onSelect: (route: RouteKey) => void;
  accent: "amber" | "blue";
}) {
  const accentRing =
    accent === "amber"
      ? "shadow-[0_0_0_1px_rgba(245,158,11,0.25)]"
      : "shadow-[0_0_0_1px_rgba(59,130,246,0.25)]";

  const accentBorder =
    accent === "amber" ? "border-amber-500/30" : "border-blue-500/30";

  const accentText =
    accent === "amber" ? "text-amber-200/90" : "text-blue-200/90";

  return (
    <div
      className={`group relative h-full border ${accentBorder} bg-black/50 p-6 ${accentRing}`}
    >
      <div className="flex items-start gap-4">
        <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-sm border border-white/15 bg-black/50">
          <Image src={crestSrc} alt={title} fill className="object-contain" />
        </div>

        <div className="min-w-0">
          <div className={`text-[10px] uppercase tracking-[0.45em] ${accentText}`}>
            {route === "SERVICE" ? "Service route" : "Commercial route"}
          </div>
          <div className="mt-2 text-xl font-semibold tracking-tight">{title}</div>
          <div className="mt-3 space-y-2 text-sm text-white/70">
            {bullets.map((b) => (
              <div key={b} className="flex gap-2">
                <span className="mt-[2px] text-white/45">•</span>
                <span className="leading-relaxed">{b}</span>
              </div>
            ))}
          </div>

          <button
            onClick={() => onSelect(route)}
            className="mt-5 inline-flex items-center gap-2 border border-white/30 bg-white/5 px-4 py-2 text-xs uppercase tracking-[0.45em] text-white/85 hover:border-white/50 hover:bg-white/10"
          >
            {ctaLabel} <span aria-hidden>→</span>
          </button>

          <div className="mt-3 text-[10px] uppercase tracking-[0.35em] text-white/40">
            Hover acknowledgement: <span className="group-hover:text-white/70">awaiting authorisation…</span>
          </div>
        </div>
      </div>
    </div>
  );
}