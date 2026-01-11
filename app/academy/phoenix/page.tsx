// app/academy/phoenix/page.tsx
import Link from "next/link";

export default function PhoenixPage() {
  return (
    <main className="mx-auto max-w-6xl px-6 py-14">
      <div className="rounded-[32px] border border-amber-500/20 bg-white/[0.03] p-10 shadow-[0_30px_140px_rgba(0,0,0,0.65)]">
        <div className="text-[11px] tracking-[0.30em] text-white/55">PHOENIX DIVISION</div>
        <h1 className="mt-4 text-4xl font-semibold tracking-tight">Service Route</h1>
        <p className="mt-4 max-w-3xl text-sm leading-relaxed text-white/70">
          Secure Cloud Operator doctrine. Read-only AWS CLI. Empty-sandbox safe. Audited canon.
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