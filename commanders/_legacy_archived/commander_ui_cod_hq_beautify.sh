#!/usr/bin/env bash
set -euo pipefail

echo "🎛️ UI BEAUTIFY — COD-HQ PASS (LOGIC FROZEN)"
ROOT="$(pwd)"
echo "📍 Repo: $ROOT"

mkdir -p commanders
mkdir -p components/ui
mkdir -p components/hq
mkdir -p app/hq

# ============================================================
# 1) Panel (adds variant support safely)
# ============================================================
cat > components/ui/Panel.tsx <<'TSX'
import React from "react";

type Variant = "default" | "active" | "muted" | "danger";

type Props = {
  title?: string;
  subtitle?: string;
  right?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
  variant?: Variant;
};

function variantClasses(variant: Variant) {
  switch (variant) {
    case "active":
      return "border-cyan-400/25 shadow-[0_0_0_1px_rgba(34,211,238,0.12),0_20px_70px_rgba(0,0,0,0.55)]";
    case "muted":
      return "border-white/8 bg-black/20";
    case "danger":
      return "border-red-400/20 shadow-[0_0_0_1px_rgba(248,113,113,0.10),0_20px_70px_rgba(0,0,0,0.55)]";
    default:
      return "border-white/10 shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_20px_70px_rgba(0,0,0,0.55)]";
  }
}

export default function Panel({
  title,
  subtitle,
  right,
  children,
  className = "",
  variant = "default",
}: Props) {
  return (
    <section
      className={[
        "rounded-3xl border bg-black/25 backdrop-blur-xl overflow-hidden",
        variantClasses(variant),
        className,
      ].join(" ")}
    >
      {(title || subtitle || right) && (
        <header className="px-6 py-5 border-b border-white/10 flex items-start justify-between gap-4">
          <div>
            {title && <div className="text-xs tracking-[0.24em] text-white/55">{title}</div>}
            {subtitle && <div className="text-sm text-white/70 mt-1">{subtitle}</div>}
          </div>
          {right ? <div className="shrink-0">{right}</div> : null}
        </header>
      )}
      <div className="p-6">{children}</div>
    </section>
  );
}
TSX

# ============================================================
# 2) Shell (fix hydration mismatch by rendering time client-side)
#    - This is the error you screenshotted.
# ============================================================
cat > components/ui/Shell.tsx <<'TSX'
"use client";

import React, { useEffect, useMemo, useState } from "react";

type Props = {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
  children: React.ReactNode;
};

function formatClock(d: Date) {
  // Keep it stable and human. No locale drift between server/client.
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}

export default function Shell({ title, subtitle, right, children }: Props) {
  const [now, setNow] = useState<Date | null>(null);

  useEffect(() => {
    setNow(new Date());
    const t = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(t);
  }, []);

  const clock = useMemo(() => (now ? formatClock(now) : "—"), [now]);

  return (
    <div className="min-h-screen bg-black text-white">
      <div className="mx-auto max-w-7xl px-6 py-10">
        <div className="rounded-3xl border border-white/10 bg-black/30 backdrop-blur-xl overflow-hidden shadow-[0_0_0_1px_rgba(255,255,255,0.04),0_30px_90px_rgba(0,0,0,0.65)]">
          <div className="px-8 py-7 border-b border-white/10 flex items-start justify-between gap-6">
            <div>
              <div className="text-xs tracking-[0.28em] text-white/45">NEWTON COMMAND ACADEMY</div>
              <h1 className="text-3xl font-semibold text-white mt-3">{title}</h1>
              {subtitle ? <div className="text-sm text-white/60 mt-2">{subtitle}</div> : null}
              <div className="mt-3 text-xs text-white/45 tracking-[0.22em]">
                SYSTEM CLOCK • <span className="text-white/70 tabular-nums">{clock}</span>
              </div>
            </div>

            <div className="shrink-0 flex items-start gap-3">
              {right}
              <div className="rounded-2xl border border-white/10 bg-black/40 px-4 py-3">
                <div className="text-xs tracking-[0.24em] text-white/45">POSTURE</div>
                <div className="text-sm text-white/80 mt-1">OPERATOR</div>
              </div>
            </div>
          </div>

          <div className="p-8">{children}</div>
        </div>
      </div>
    </div>
  );
}
TSX

# ============================================================
# 3) HQ Status Strip (fix mission runtime access: state.active)
# ============================================================
cat > components/hq/StatusStrip.tsx <<'TSX'
"use client";

import { useMemo } from "react";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

function Pill({ label }: { label: string }) {
  return (
    <span className="inline-flex items-center rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-white/75">
      {label}
    </span>
  );
}

export default function StatusStrip() {
  const { state } = useMissionRuntime();
  const active = state.active;

  const mission = useMemo(() => {
    if (!active) return { label: "MISSION: IDLE" };
    return { label: `MISSION: LIVE • ${active.division.toUpperCase()} • ${active.lessonId}` };
  }, [active]);

  return (
    <div className="flex flex-wrap gap-2 items-center">
      <Pill label="UI: GREEN" />
      <Pill label="ROUTING: GREEN" />
      <Pill label="CANON: LOCKED" />
      <Pill label={mission.label} />
      <Pill label="ATILS ENGINE: ONLINE" />
    </div>
  );
}
TSX

# ============================================================
# 4) HQ Active Mission Card (fix mission runtime access + COD-HQ styling)
# ============================================================
cat > components/hq/ActiveMissionCard.tsx <<'TSX'
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Panel from "@/components/ui/Panel";
import { useMissionRuntime } from "@/lib/missionRuntimeStore";

function fmtAge(ms: number) {
  const s = Math.floor(ms / 1000);
  const m = Math.floor(s / 60);
  const r = s % 60;
  if (m <= 0) return `${r}s`;
  return `${m}m ${r}s`;
}

export default function ActiveMissionCard() {
  const router = useRouter();
  const { state, clearMission, touchMission, addMissionNote } = useMissionRuntime();
  const active = state.active;

  const [note, setNote] = useState("");

  const meta = useMemo(() => {
    if (!active) return null;
    const now = Date.now();
    return {
      age: fmtAge(now - active.startedAt),
      seen: fmtAge(now - active.lastSeenAt),
      route: `/academy/${active.division}/${active.lessonId}`,
    };
  }, [active]);

  if (!active) {
    return (
      <Panel
        title="ACTIVE MISSION"
        subtitle="No active mission. Start any lesson to arm the runtime."
        variant="muted"
      >
        <div className="text-sm text-white/65">
          Tip: enter a lesson page and the handshake will set <span className="text-white/85">ACTIVE</span>.
        </div>
      </Panel>
    );
  }

  return (
    <Panel
      title="ACTIVE MISSION"
      subtitle="HQ is the launcher. Lessons are execution screens."
      variant="active"
      right={
        <span className="inline-flex items-center rounded-full border border-cyan-400/20 bg-cyan-400/10 px-3 py-1 text-xs text-cyan-200">
          LIVE
        </span>
      }
    >
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="rounded-2xl border border-white/10 bg-black/35 p-5">
          <div className="text-xs tracking-[0.24em] text-white/45">TARGET</div>
          <div className="text-lg font-semibold text-white mt-2">{active.lessonId}</div>
          <div className="text-sm text-white/65 mt-1">{active.division.toUpperCase()} DIVISION</div>

          <div className="mt-4 text-xs text-white/55">
            Runtime age: <span className="text-white/75 tabular-nums">{meta?.age}</span>
            <span className="text-white/20"> • </span>
            Last seen: <span className="text-white/75 tabular-nums">{meta?.seen}</span>
          </div>
        </div>

        <div className="rounded-2xl border border-white/10 bg-black/35 p-5">
          <div className="text-xs tracking-[0.24em] text-white/45">CONTROL</div>

          <div className="mt-4 flex flex-wrap gap-2">
            <button
              onClick={() => {
                touchMission();
                router.push(meta!.route);
              }}
              className="px-4 py-2 text-sm rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/85"
            >
              Resume Mission →
            </button>

            <button
              onClick={() => clearMission()}
              className="px-4 py-2 text-sm rounded-full border border-red-400/20 bg-red-400/10 hover:bg-red-400/15 text-red-200"
            >
              Clear
            </button>
          </div>

          <div className="mt-4 text-xs text-white/55">
            Step index: <span className="text-white/75 tabular-nums">{active.stepIndex}</span>
            <span className="text-white/20"> • </span>
            Steps complete:{" "}
            <span className="text-white/75 tabular-nums">
              {Object.values(active.completedSteps ?? {}).filter(Boolean).length}
            </span>
          </div>
        </div>

        <div className="rounded-2xl border border-white/10 bg-black/35 p-5">
          <div className="text-xs tracking-[0.24em] text-white/45">HQ NOTES</div>

          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder={active.notes ? active.notes : "Drop a mission note for your next resume..."}
            className="mt-3 w-full min-h-[92px] rounded-2xl border border-white/10 bg-black/35 px-4 py-3 text-sm text-white/80 placeholder:text-white/30 focus:outline-none focus:ring-2 focus:ring-cyan-400/20"
          />

          <div className="mt-3 flex gap-2">
            <button
              onClick={() => {
                addMissionNote(note.trim());
                setNote("");
              }}
              className="px-4 py-2 text-sm rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/85"
            >
              Save Note
            </button>

            <button
              onClick={() => setNote("")}
              className="px-4 py-2 text-sm rounded-full border border-white/10 bg-white/5 hover:bg-white/10 text-white/70"
            >
              Clear Draft
            </button>
          </div>
        </div>
      </div>
    </Panel>
  );
}
TSX

# ============================================================
# 5) HQ page (beautiful layout, does not touch runtime logic)
# ============================================================
cat > app/hq/page.tsx <<'TSX'
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import StatusStrip from "@/components/hq/StatusStrip";
import ActiveMissionCard from "@/components/hq/ActiveMissionCard";

export default function HQPage() {
  return (
    <Shell
      title="Operator HQ"
      subtitle="COD-HQ style hub. This becomes the mission launcher + progress + war room."
      right={
        <div className="rounded-2xl border border-white/10 bg-black/40 px-4 py-3">
          <div className="text-xs tracking-[0.24em] text-white/45">DIVISION</div>
          <div className="text-sm text-white/80 mt-1">PHOENIX</div>
        </div>
      }
    >
      <div className="space-y-6">
        <Panel title="SYSTEM STATUS" subtitle="Engine online. Gates active. Canon locked.">
          <StatusStrip />
        </Panel>

        <ActiveMissionCard />

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <Panel
            title="MISSION SIMULATOR"
            subtitle="Launch, run, debrief."
            className="lg:col-span-1"
          >
            <div className="text-sm text-white/70">
              Placeholder for mission queue, guardian prompts, and live objectives.
            </div>
          </Panel>

          <Panel
            title="CAREER WAR ROOM"
            subtitle="Proof of work + CV outputs."
            className="lg:col-span-1"
          >
            <div className="text-sm text-white/70">
              Placeholder for transcripts, employer trust portal, and skill decay tracking.
            </div>
          </Panel>

          <Panel
            title="BOARD OF INQUIRY"
            subtitle="Truth Engine QA + exams."
            className="lg:col-span-1"
          >
            <div className="text-sm text-white/70">
              Placeholder for exam crams, interrogations, and mastery checks.
            </div>
          </Panel>
        </div>
      </div>
    </Shell>
  );
}
TSX

# ============================================================
# 6) BUILD CHECK (green)
# ============================================================
echo "🧪 BUILD CHECK"
rm -rf .next
npm run build

echo "✅ UI BEAUTIFY COMPLETE — COD-HQ PASS APPLIED"
echo "🚀 Run: npm run dev"
