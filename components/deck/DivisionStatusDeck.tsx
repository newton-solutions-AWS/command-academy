"use client";

const divisions = [
  { name: "AWS", status: "Online" },
  { name: "Azure", status: "Online" },
  { name: "GCP", status: "Online" },
  { name: "Security", status: "Online" },
  { name: "DevOps", status: "Online" },
];

export default function DivisionStatusDeck() {
  return (
    <section className="panel">
      <div className="panel-head">
        <div>
          <div className="panel-kicker">DIVISION STATUS</div>
          <div className="panel-sub">Operational Readiness</div>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 text-sm">
        {divisions.map((d) => (
          <div
            key={d.name}
            className="flex justify-between rounded-md border border-white/10 px-3 py-2"
          >
            <span className="text-neutral-300">{d.name}</span>
            <span className="text-green-400">{d.status}</span>
          </div>
        ))}
      </div>
    </section>
  );
}
