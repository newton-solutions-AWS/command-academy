"use client";

import StatusStrip from "@/components/hq/StatusStrip";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";
import MissionLauncher from "@/components/hq/MissionLauncher";
import Panel from "@/components/ui/Panel";
import { useAccessProfile } from "@/lib/useAccessProfile";

export default function HQClient() {
  const { mounted, profile, setUserDivision, setSentinelAddOn } = useAccessProfile();

  return (
    <main className="mx-auto max-w-6xl px-6 pb-16">
      <div className="mt-10 rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden">
        <div className="px-8 py-7 border-b border-white/10">
          <div className="text-xs tracking-[0.28em] text-white/50">NEWTON COMMAND ACADEMY</div>
          <h1 className="text-3xl font-semibold text-white mt-3">Operator HQ</h1>
          <div className="text-sm text-white/60 mt-2">HQ is the app. Lessons are execution screens. Divisions are posture filters.</div>
          <div className="mt-4">
            <StatusStrip />
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 p-8">
          <div className="lg:col-span-2 space-y-6">
            <MissionLauncher />

            <Panel title="ACCESS POSTURE" subtitle="Canon gating model (Phoenix full access / Vanguard paid / Sentinel add-on).">
              {!mounted ? (
                <div className="text-sm text-white/50">Loading...</div>
              ) : (
                <div className="space-y-3">
                  <div className="flex flex-wrap gap-2">
                    <button
                      onClick={() => setUserDivision("phoenix")}
                      className={[
                        "px-3 py-2 rounded-xl border",
                        profile.userDivision === "phoenix"
                          ? "border-emerald-400/30 bg-emerald-500/10 text-emerald-200"
                          : "border-white/10 bg-white/5 text-white/70 hover:bg-white/10",
                      ].join(" ")}
                    >
                      Phoenix (full)
                    </button>

                    <button
                      onClick={() => setUserDivision("vanguard")}
                      className={[
                        "px-3 py-2 rounded-xl border",
                        profile.userDivision === "vanguard"
                          ? "border-sky-400/30 bg-sky-500/10 text-sky-200"
                          : "border-white/10 bg-white/5 text-white/70 hover:bg-white/10",
                      ].join(" ")}
                    >
                      Vanguard (paid)
                    </button>
                  </div>

                  <div className="flex items-center gap-2">
                    <input
                      id="sentinelAddon"
                      type="checkbox"
                      checked={!!profile.addons.sentinel}
                      onChange={(e) => setSentinelAddOn(e.target.checked)}
                      className="h-4 w-4"
                      disabled={profile.userDivision === "phoenix"}
                    />
                    <label htmlFor="sentinelAddon" className="text-sm text-white/70">
                      Sentinel add-on (auto-enabled for Phoenix)
                    </label>
                  </div>

                  <div className="text-xs text-white/50">
                    Phoenix: unrestricted (Vanguard + Sentinel included). Vanguard: Sentinel requires add-on. Phoenix lessons are gated from Vanguard.
                  </div>
                </div>
              )}
            </Panel>
          </div>

          <div className="lg:col-span-1 space-y-6">
            <ActiveMissionCard />

            <Panel title="DOCTRINE" subtitle="Immutable canon • deterministic doctrine • executable reality">
              <ul className="list-disc pl-5 space-y-2 text-sm text-white/70">
                <li>HQ is the command center.</li>
                <li>Lessons are mission terminals.</li>
                <li>Guardian Angel supports step-by-step execution.</li>
                <li>Canon types are locked (single source).</li>
              </ul>
            </Panel>
          </div>
        </div>
      </div>
    </main>
  );
}
