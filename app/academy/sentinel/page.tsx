// app/academy/sentinel/page.tsx
import Link from "next/link";

export default function SentinelPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-14">
      <div className="rounded-[32px] border border-rose-500/20 bg-white/[0.03] p-10 shadow-[0_30px_140px_rgba(0,0,0,0.70)]">
        <div className="text-[11px] tracking-[0.30em] text-white/55">SENTINEL DIVISION</div>
        <h1 className="mt-4 text-4xl font-semibold tracking-tight">Prestige Add-on</h1>
        <p className="mt-4 max-w-3xl text-sm leading-relaxed text-white/70">
          Defensive security, detection, response, and elite competence signals. Clearance-gated operational tier.
        </p>

        <div className="mt-8 flex flex-wrap gap-3">
          <Link
            href="/academy"
            className="rounded-2xl border border-white/15 bg-white/[0.04] px-5 py-3 text-sm text-white/85 transition hover:border-white/25 hover:bg-white/[0.06]"
          >
            ← Back to HQ
          </Link>
        </div>
      </div>
    </main>
  );
}