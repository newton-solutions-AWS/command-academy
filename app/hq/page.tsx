import HQDeck from "@/components/deck/HQDeck";

export default function HQPage() {
  return (
    <main className="screen">
      <div className="screen-noise" />
      <div className="screen-glow bg-green-500/10" />

      <div className="wrap">
        <div className="mb-10">
          <div className="text-xs tracking-[0.3em] text-neutral-500">
            NEWTON COMMAND ACADEMY
          </div>
          <h1 className="mt-3 text-4xl font-semibold">
            HQ DASHBOARD
          </h1>
          <p className="mt-3 text-sm text-neutral-400 max-w-xl">
            Command overview · Oracle access · Division readiness
          </p>
        </div>

        <HQDeck />
      </div>
    </main>
  );
}
