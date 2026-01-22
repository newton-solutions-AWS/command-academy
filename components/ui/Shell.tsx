"use client";

import React, { useEffect, useMemo, useState } from "react";

type Props = {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
  children: React.ReactNode;
};

function formatClock(d: Date) {
  // Keep it stable and human. No locale drift between server/client.
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

export default function Shell({ title, subtitle, right, children }: Props) {
  const [now, setNow] = useState<Date | null>(null);

  useEffect(() => {
    setNow(new Date());
    const t = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(t);
  }, []);

  const clock = useMemo(() => (now ? formatClock(now) : "—"), [now]);

  return (
    <div className="min-h-screen bg-black text-white">
      <div className="mx-auto max-w-7xl px-6 py-10">
        <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_30px_90px_rgba(0,0,0,0.65)]">
          <div className="px-8 py-7 border-b border-white/10 flex items-start justify-between gap-6">
            <div>
              <div className="text-xs tracking-[0.28em] text-white/45">NEWTON COMMAND ACADEMY</div>
              <h1 className="text-3xl font-semibold text-white mt-3">{title}</h1>
              {subtitle ? <div className="text-sm text-white/60 mt-2">{subtitle}</div> : null}
              <div className="mt-3 text-xs text-white/45 tracking-[0.22em]">
                SYSTEM CLOCK • <span className="text-white/70 tabular-nums">{clock}</span>
              </div>
            </div>

            <div className="shrink-0 flex items-start gap-3">
              {right}
              <div className="rounded-2xl border border-white/10 bg-black/40 px-4 py-3">
                <div className="text-xs tracking-[0.24em] text-white/45">POSTURE</div>
                <div className="text-sm text-white/80 mt-1">OPERATOR</div>
              </div>
            </div>
          </div>

          <div className="p-8">{children}</div>
        </div>
      </div>
    </div>
  );
}
