"use client";

import { getTranscript } from "@/lib/transcriptStore";

export default function TranscriptPage() {
  const t = getTranscript();

  return (
    <main className="mx-auto max-w-5xl px-6 py-16">
      <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl p-8">
        <div className="text-xs tracking-[0.3em] text-white/50">
          SERVICE TRANSCRIPT
        </div>

        <h1 className="text-3xl text-white mt-4">Operational Record</h1>

        <div className="mt-8 space-y-4">
          {t.entries.length === 0 && (
            <div className="text-white/60">No completed missions yet.</div>
          )}

          {t.entries.map((e, i) => (
            <div
              key={i}
              className="rounded-xl border border-white/10 bg-black/20 p-5"
            >
              <div className="text-white font-medium">{e.title}</div>
              <div className="text-sm text-white/50 mt-1">
                {e.division.toUpperCase()} • {e.durationMinutes} mins •{" "}
                {new Date(e.completedAt).toLocaleString()}
              </div>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}
