"use client";

import { useState } from "react";

export default function Oracle() {
  const [open, setOpen] = useState(false);

  return (
    <div className="fixed bottom-6 right-6 z-50">
      {!open ? (
        <button
          onClick={() => setOpen(true)}
          className="px-4 py-2 rounded-full border border-neutral-700 text-xs tracking-widest text-neutral-300 bg-black/40 hover:border-green-500 hover:text-green-400 transition"
        >
          ORACLE
        </button>
      ) : (
        <div className="w-[320px] rounded-2xl border border-neutral-800 bg-black/70 backdrop-blur-xl shadow-[0_30px_80px_rgba(0,0,0,0.65)] overflow-hidden">
          <div className="flex items-center justify-between px-4 py-3 border-b border-neutral-800">
            <div className="text-xs tracking-widest text-neutral-400">
              ORACLE CHANNEL
            </div>
            <button
              onClick={() => setOpen(false)}
              className="text-neutral-500 hover:text-neutral-200 transition"
              aria-label="Close"
            >
              ✕
            </button>
          </div>

          <div className="p-4 space-y-3">
            <div className="text-xs text-neutral-400 leading-relaxed">
              Oracle online. Try:
              <div className="mt-2 space-y-1 text-neutral-300">
                <div>• “Open Phoenix Division”</div>
                <div>• “Switch to Government layout”</div>
                <div>• “Set learning mode to Visual”</div>
              </div>
            </div>

            <div className="rounded-lg border border-neutral-800 bg-black/40 px-3 py-2 text-xs text-neutral-500">
              (Command parsing hooks come next.)
            </div>
          </div>
        </div>
      )}
    </div>
  );
}