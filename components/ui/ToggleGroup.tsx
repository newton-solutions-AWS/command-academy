"use client";

interface ToggleGroupProps<T extends string> {
  options: readonly T[];
  value: T;
  onChange: (v: T) => void;
  tone?: "green" | "amber" | "red";
}

function toneClasses(tone: "green" | "amber" | "red") {
  if (tone === "amber") return "border-amber-500/70 text-amber-300 shadow-[0_0_30px_rgba(245,158,11,0.12)]";
  if (tone === "red") return "border-red-500/70 text-red-300 shadow-[0_0_30px_rgba(239,68,68,0.12)]";
  return "border-green-500/70 text-green-300 shadow-[0_0_30px_rgba(34,197,94,0.12)]";
}

export function ToggleGroup<T extends string>({
  options,
  value,
  onChange,
  tone = "green",
}: ToggleGroupProps<T>) {
  return (
    <div className="flex flex-wrap gap-3">
      {options.map((opt) => {
        const active = value === opt;
        return (
          <button
            key={opt}
            type="button"
            onClick={() => onChange(opt)}
            className={[
              "toggle",
              active ? `toggle-active ${toneClasses(tone)}` : "toggle-idle",
            ].join(" ")}
          >
            {opt}
          </button>
        );
      })}
    </div>
  );
}
