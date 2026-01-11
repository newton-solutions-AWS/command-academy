import Image from "next/image";
import Link from "next/link";

export default function DivisionChapter({
  label,
  title,
  crestSrc,
  doctrine,
  notes,
  ctaLabel,
  href,
  rightTag,
}: {
  label: string;
  title: string;
  crestSrc: string;
  doctrine: string;
  notes: string[];
  ctaLabel: string;
  href: string;
  rightTag?: string;
}) {
  return (
    <section className="relative border-t border-white/12 bg-black/60">
      <div className="mx-auto max-w-6xl px-6 py-10">
        <div className="flex items-start justify-between gap-6">
          <div className="flex items-start gap-5">
            <div className="relative h-20 w-20 shrink-0 overflow-hidden rounded-sm border border-white/20 bg-black/50">
              <Image src={crestSrc} alt={title} fill className="object-contain" />
            </div>

            <div>
              <div className="text-[10px] uppercase tracking-[0.45em] text-white/55">
                {label}
              </div>
              <h2 className="mt-2 text-2xl font-semibold tracking-tight md:text-3xl">
                {title}
              </h2>
              <p className="mt-3 max-w-3xl text-sm leading-relaxed text-white/75 md:text-base">
                {doctrine}
              </p>

              <div className="mt-4 flex flex-wrap gap-x-6 gap-y-2 text-sm text-white/70">
                {notes.map((n) => (
                  <div key={n} className="flex items-center gap-2">
                    <span className="text-white/35">•</span>
                    <span>{n}</span>
                  </div>
                ))}
              </div>

              <div className="mt-6">
                <Link
                  href={href}
                  className="inline-flex items-center gap-2 border border-white/30 bg-white/5 px-4 py-2 text-xs uppercase tracking-[0.45em] text-white/85 hover:border-white/55 hover:bg-white/10"
                >
                  {ctaLabel} <span aria-hidden>→</span>
                </Link>
              </div>
            </div>
          </div>

          {rightTag ? (
            <div className="hidden items-start md:flex">
              <div className="border border-white/20 bg-black/40 px-3 py-2 text-[10px] uppercase tracking-[0.45em] text-white/60">
                {rightTag}
              </div>
            </div>
          ) : null}
        </div>
      </div>
    </section>
  );
}