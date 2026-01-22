#!/usr/bin/env bash
set -e

echo "== UI CORE COMMANDER =="

mkdir -p components/ui

cat > components/ui/Panel.tsx <<'TSX'
"use client";
import clsx from "clsx";

export default function Panel({ title, subtitle, children }: any) {
  return (
    <section className={clsx(
      "relative rounded-xl border border-white/10",
      "bg-gradient-to-b from-black/60 to-black/30",
      "p-6 backdrop-blur-md"
    )}>
      {title && (
        <div className="mb-4">
          <div className="text-[11px] tracking-widest uppercase text-neutral-400">
            {title}
          </div>
          {subtitle && (
            <div className="text-[11px] text-neutral-500 mt-1">
              {subtitle}
            </div>
          )}
        </div>
      )}
      {children}
    </section>
  );
}
TSX

cat > components/ui/Toggle.tsx <<'TSX'
"use client";

export default function Toggle({ active, children }: any) {
  return (
    <button className={
      active
        ? "toggle toggle-active border-green-500/60 text-green-300"
        : "toggle toggle-idle"
    }>
      {children}
    </button>
  );
}
TSX

echo "UI Core deployed."
