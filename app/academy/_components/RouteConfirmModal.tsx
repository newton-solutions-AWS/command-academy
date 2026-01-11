"use client";

import { useEffect } from "react";

type RouteKey = "SERVICE" | "CIVILIAN";

export default function RouteConfirmModal({
  open,
  route,
  onConfirm,
  onClose,
}: {
  open: boolean;
  route: RouteKey;
  onConfirm: () => void;
  onClose: () => void;
}) {
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (!open) return;
      if (e.key === "Escape") onClose();
      if (e.key === "Enter") onConfirm();
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose, onConfirm]);

  if (!open) return null;

  const title =
    route === "SERVICE" ? "Proceed under Service Route" : "Proceed under Civilian Route";
  const sub =
    route === "SERVICE"
      ? "Honour-based access. Phoenix entry. Sentinel included by service privilege."
      : "Commercial access. Vanguard entry. Sentinel available as paid add-on (clearance-gated).";

  return (
    <div className="fixed inset-0 z-50 grid place-items-center px-6">
      <div className="absolute inset-0 bg-black/80 backdrop-blur-sm" onClick={onClose} />

      <div className="relative w-full max-w-xl border border-white/20 bg-black/70 p-6 shadow-[0_0_0_1px_rgba(255,255,255,0.08)]">
        <div className="text-[10px] uppercase tracking-[0.45em] text-white/60">
          Route confirmation
        </div>

        <div className="mt-3 text-lg font-semibold tracking-tight">{title}</div>
        <p className="mt-2 text-sm leading-relaxed text-white/75">{sub}</p>

        <div className="mt-5 border-t border-white/10 pt-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <button
              onClick={onClose}
              className="border border-white/25 bg-black/40 px-3 py-2 text-xs uppercase tracking-[0.35em] text-white/80 hover:border-white/45"
            >
              Return
            </button>

            <button
              onClick={onConfirm}
              className="border border-white/35 bg-white/5 px-4 py-2 text-xs uppercase tracking-[0.45em] hover:bg-white/10"
            >
              Confirm route →
            </button>
          </div>

          <p className="mt-3 text-[10px] uppercase tracking-[0.35em] text-white/45">
            Esc to return · Enter to confirm
          </p>
        </div>
      </div>
    </div>
  );
}