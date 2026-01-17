import React from "react";
import Badge from "./Badge";

type Props = {
  title: string;
  subtitle?: string;
  division: "phoenix" | "vanguard" | "sentinel";
};

export default function CommandHeader({ title, subtitle, division }: Props) {
  const badgeVariant =
    division === "phoenix" ? "amber" : division === "vanguard" ? "blue" : "red";

  return (
    <header className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <div className="text-[12px] tracking-[0.35em] uppercase text-white/60">
          Newton Command Academy
        </div>
        <h1 className="text-2xl sm:text-3xl font-semibold mt-2">{title}</h1>
        {subtitle && <p className="text-white/60 mt-2 max-w-2xl">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-2">
        <Badge variant={badgeVariant}>{division.toUpperCase()} DIVISION</Badge>
        <Badge variant="blue">ATILS ENGINE</Badge>
      </div>
    </header>
  );
}
