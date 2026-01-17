import React from "react";
import clsx from "clsx";

type BadgeProps = {
  children: React.ReactNode;
  variant?: "default" | "blue" | "amber" | "red";
};

export default function Badge({ children, variant = "default" }: BadgeProps) {
  return (
    <span
      className={clsx(
        "inline-flex items-center rounded-full px-2.5 py-1 text-[11px] tracking-wide border",
        "bg-black/35 backdrop-blur",
        variant === "default" && "border-white/10 text-white/80",
        variant === "blue" && "border-blue-400/30 text-blue-200",
        variant === "amber" && "border-amber-400/30 text-amber-200",
        variant === "red" && "border-red-400/30 text-red-200"
      )}
    >
      {children}
    </span>
  );
}
