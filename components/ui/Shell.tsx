import React from "react";
import clsx from "clsx";

type ShellProps = {
  children: React.ReactNode;
  className?: string;
};

export default function Shell({ children, className }: ShellProps) {
  return (
    <div
      className={clsx(
        "min-h-screen w-full",
        "bg-[#050A14] text-white",
        "relative overflow-hidden",
        className
      )}
    >
      {/* North-star grid */}
      <div className="pointer-events-none absolute inset-0 opacity-[0.18]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(59,130,246,0.35),transparent_45%),radial-gradient(circle_at_80%_70%,rgba(59,130,246,0.18),transparent_55%)]" />
        <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.05)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.04)_1px,transparent_1px)] bg-[size:56px_56px]" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 py-6">{children}</div>
    </div>
  );
}
