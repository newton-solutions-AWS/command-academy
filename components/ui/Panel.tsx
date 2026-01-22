import React from "react";

type Variant = "default" | "active" | "muted" | "danger";

type Props = {
  title?: string;
  subtitle?: string;
  right?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
  variant?: Variant;
};

function variantClasses(variant: Variant) {
  switch (variant) {
    case "active":
      return "border-cyan-400/25 shadow-[0_0_0_1px_rgba(34,211,238,0.12),0_20px_70px_rgba(0,0,0,0.55)]";
    case "muted":
      return "border-white/8 bg-black/20";
    case "danger":
      return "border-red-400/20 shadow-[0_0_0_1px_rgba(248,113,113,0.10),0_20px_70px_rgba(0,0,0,0.55)]";
    default:
      return "border-white/10 shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_70px_rgba(0,0,0,0.55)]";
  }
}

export default function Panel({
  title,
  subtitle,
  right,
  children,
  className = "",
  variant = "default",
}: Props) {
  return (
    <section
      className={[
        "rounded-3xl border bg-black/25 backdrop-blur-xl overflow-hidden",
        variantClasses(variant),
        className,
      ].join(" ")}
    >
      {(title || subtitle || right) && (
        <header className="px-6 py-5 border-b border-white/10 flex items-start justify-between gap-4">
          <div>
            {title && <div className="text-xs tracking-[0.24em] text-white/55">{title}</div>}
            {subtitle && <div className="text-sm text-white/70 mt-1">{subtitle}</div>}
          </div>
          {right ? <div className="shrink-0">{right}</div> : null}
        </header>
      )}
      <div className="p-6">{children}</div>
    </section>
  );
}
