import React from "react";
import clsx from "clsx";

type Option<T extends string> = {
  value: T;
  label: string;
  hint?: string;
};

type ToggleGroupProps<T extends string> = {
  label: string;
  value: T;
  options: Option<T>[];
  onChange: (next: T) => void;
};

export default function ToggleGroup<T extends string>({
  label,
  value,
  options,
  onChange,
}: ToggleGroupProps<T>) {
  return (
    <div className="space-y-2">
      <div className="text-[11px] uppercase tracking-widest text-white/60">
        {label}
      </div>
      <div className="grid gap-2 sm:grid-cols-3">
        {options.map((o) => {
          const active = o.value === value;
          return (
            <button
              key={o.value}
              onClick={() => onChange(o.value)}
              className={clsx(
                "text-left rounded-lg border p-3 transition",
                "bg-black/30 hover:bg-black/45",
                active ? "border-blue-400/50 shadow-[0_0_24px_rgba(59,130,246,0.18)]" : "border-white/10"
              )}
              type="button"
            >
              <div className="text-sm">{o.label}</div>
              {o.hint && <div className="text-xs text-white/50 mt-1">{o.hint}</div>}
            </button>
          );
        })}
      </div>
    </div>
  );
}
