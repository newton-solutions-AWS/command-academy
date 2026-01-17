import React from "react";
import clsx from "clsx";

type PanelProps = {
  title?: string;
  subtitle?: string;
  variant?: "default" | "active" | "restricted";
  children: React.ReactNode;
};

export default function Panel({
  title,
  subtitle,
  variant = "default",
  children,
}: PanelProps) {
  return (
    <section
      className={clsx(
        "relative rounded-xl border p-6",
        "bg-gradient-to-b from-black/60 to-black/30",
        "backdrop-blur-md",
        "border-white/10",
        "shadow-[inset_0_1px_0_rgba(255,255,255,0.05),0_30px_80px_rgba(0,0,0,0.6)]",
        variant === "active" &&
          "border-blue-400/50 shadow-[0_0_50px_rgba(59,130,246,0.18)]",
        variant === "restricted" &&
          "border-red-500/40 shadow-[0_0_50px_rgba(239,68,68,0.12)]"
      )}
    >
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/20 to-transparent" />

      {title && (
        <div className="mb-4">
          <div className="text-[11px] tracking-widest text-slate-300 uppercase">
            {title}
          </div>
          {subtitle && <div className="text-[11px] text-slate-400 mt-1">{subtitle}</div>}
        </div>
      )}

      {children}
    </section>
  );
}
