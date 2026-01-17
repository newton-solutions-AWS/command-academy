"use client";

export default function OracleDeck() {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">ORACLE AI</div>
          <div className="panel-sub">Suggestion Engine</div>
        </div>
      </div>

      <div className="mono text-sm text-neutral-300 leading-6">
        Try:
        <ul className="mt-2 list-disc list-inside text-neutral-400">
          <li>"Open AWS track"</li>
          <li>"Go to lesson 3"</li>
          <li>"Explain this like I'm new"</li>
        </ul>
      </div>

      <div className="mt-4 flex gap-3">
        <button className="toggle toggle-active border-green-500/60 text-green-300">
          Open Oracle
        </button>
        <button className="toggle toggle-idle">
          Voice (soon)
        </button>
      </div>
    </section>
  );
}
