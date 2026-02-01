#!/usr/bin/env bash
set -euo pipefail

echo "🧠 NEWTON COMMAND ACADEMY — FULL SHEBANG UI DEPLOY"
echo "📍 Running in: $(pwd)"

# --- Safety ---
if [ ! -f package.json ]; then
  echo "❌ package.json not found. Run this from the project root (command-academy/)."
  exit 1
fi

mkdir -p components/ui components/deck lib app/hq app/academy app/academy/[division]/[lessonId]
mkdir -p cert_intel/intake/lib

# -------------------------
# LIB: uiTypes
# -------------------------
cat > lib/uiTypes.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";
export type InterfaceMode = "operator" | "scholar" | "classified";
export type LearningMode =
  | "gamified"
  | "socratic"
  | "visual"
  | "video"
  | "text"
  | "exam-cram";

export type LayoutMode = "north-star" | "cod-hq" | "intel-brief";

export interface UiState {
  division: Division;
  interfaceMode: InterfaceMode;
  learningMode: LearningMode;
  layoutMode: LayoutMode;
}
TS

# -------------------------
# LIB: uiStore
# -------------------------
cat > lib/uiStore.ts <<'TS'
import type { UiState } from "./uiTypes";

export const DEFAULT_UI: UiState = {
  division: "phoenix",
  interfaceMode: "operator",
  learningMode: "gamified",
  layoutMode: "north-star",
};

const KEY = "newton-command-ui";

export function loadUi(): UiState {
  if (typeof window === "undefined") return DEFAULT_UI;
  try {
    const raw = window.localStorage.getItem(KEY);
    if (!raw) return DEFAULT_UI;
    const parsed = JSON.parse(raw) as Partial<UiState>;
    return { ...DEFAULT_UI, ...parsed };
  } catch {
    return DEFAULT_UI;
  }
}

export function saveUi(next: UiState) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(KEY, JSON.stringify(next));
}
TS

# -------------------------
# LIB: nav helper
# -------------------------
cat > lib/nav.ts <<'TS'
import type { Division } from "./uiTypes";

export function lessonHref(division: Division, lessonId: string) {
  return `/academy/${division}/${lessonId}`;
}
TS

# -------------------------
# CANON TYPES (single source of truth)
# -------------------------
cat > cert_intel/intake/lib/canonTypes.ts <<'TS'
export type Division = "phoenix" | "vanguard" | "sentinel";
export type Difficulty = "foundation" | "intermediate" | "advanced";

export interface CanonLesson {
  id: string;
  title: string;
  division: Division;
  difficulty: Difficulty;
  duration_minutes: number;
  concept: string;
  walkthrough: string;
  objectives: string[];
}
TS

# -------------------------
# useRole (placeholder gate)
# -------------------------
cat > cert_intel/intake/lib/useRole.ts <<'TS'
export type UserRole = "founder" | "phoenix" | "vanguard" | "sentinel" | "guest";

export function getUserRole(): UserRole {
  // Later: hook to auth/session. For now, keep it predictable.
  return "founder";
}

export function canAccessDivision(role: UserRole, division: "phoenix" | "vanguard" | "sentinel") {
  if (role === "founder") return true;
  if (role === "phoenix") return true;
  if (role === "vanguard") return division !== "sentinel";
  if (role === "sentinel") return true;
  return division === "phoenix"; // guest gets only Phoenix preview
}
TS

# -------------------------
# lessonloader
# -------------------------
cat > cert_intel/intake/lib/lessonloader.ts <<'TS'
import type { CanonLesson } from "./canonTypes";

const LESSONS: CanonLesson[] = [
  {
    id: "intro-001",
    title: "Welcome to Newton Command Academy",
    division: "phoenix",
    difficulty: "foundation",
    duration_minutes: 12,
    concept:
      "This is your induction. The Academy runs as missions, not lectures. The Guardian Angel keeps you moving, step-by-step.",
    walkthrough:
      "1) Confirm your division and layout.\n2) Open HQ.\n3) Enter the Mission Simulator.\n4) Complete the first objective and log your progress.\n5) Debrief and unlock the next door.",
    objectives: [
      "Understand the division model (Phoenix/Vanguard/Sentinel)",
      "Understand Interface Mode vs Learning Mode",
      "Run your first mission loop",
    ],
  },
  {
    id: "linux-001",
    title: "Linux Foundations: Terminal Dominance",
    division: "vanguard",
    difficulty: "foundation",
    duration_minutes: 22,
    concept:
      "Linux is the spine of cloud and security. You don’t learn it by reading — you learn it by command, repetition, and missions.",
    walkthrough:
      "1) Identify your shell.\n2) Learn pwd/ls/cd.\n3) Create directories, move files.\n4) Read logs.\n5) Pass the checkpoint drill.",
    objectives: ["Navigate a filesystem", "Edit and view files", "Understand basic permissions"],
  },
  {
    id: "threat-001",
    title: "Sentinel Ops: Threat Modelling 101",
    division: "sentinel",
    difficulty: "intermediate",
    duration_minutes: 28,
    concept:
      "Threat modelling is how professionals stop guessing. You map assets, entry points, controls, and adversary paths.",
    walkthrough:
      "1) Define system boundary.\n2) List assets.\n3) Enumerate threats.\n4) Rank by impact/likelihood.\n5) Propose mitigations.\n6) Debrief.",
    objectives: ["Model threats clearly", "Communicate risk", "Choose practical mitigations"],
  },
];

export function loadCanonLessons(division?: "phoenix" | "vanguard" | "sentinel"): CanonLesson[] {
  if (!division) return LESSONS;
  return LESSONS.filter((l) => l.division === division);
}

export function loadLessonById(lessonId: string): CanonLesson | null {
  return LESSONS.find((l) => l.id === lessonId) ?? null;
}
TS

# -------------------------
# UI: Shell
# -------------------------
cat > components/ui/Shell.tsx <<'TSX'
import React from "react";
import clsx from "clsx";

type ShellProps = {
  children: React.ReactNode;
  className?: string;
};

export default function Shell({ children, className }: ShellProps) {
  return (
    <div
      className={clsx(
        "min-h-screen w-full",
        "bg-[#050A14] text-white",
        "relative overflow-hidden",
        className
      )}
    >
      {/* North-star grid */}
      <div className="pointer-events-none absolute inset-0 opacity-[0.18]">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(59,130,246,0.35),transparent_45%),radial-gradient(circle_at_80%_70%,rgba(59,130,246,0.18),transparent_55%)]" />
        <div className="absolute inset-0 bg-[linear-gradient(rgba(255,255,255,0.05)_1px,transparent_1px),linear-gradient(90deg,rgba(255,255,255,0.04)_1px,transparent_1px)] bg-[size:56px_56px]" />
      </div>

      <div className="relative mx-auto max-w-7xl px-4 py-6">{children}</div>
    </div>
  );
}
TSX

# -------------------------
# UI: Panel (default export)
# -------------------------
cat > components/ui/Panel.tsx <<'TSX'
import React from "react";
import clsx from "clsx";

type PanelProps = {
  title?: string;
  subtitle?: string;
  variant?: "default" | "active" | "restricted";
  children: React.ReactNode;
};

export default function Panel({
  title,
  subtitle,
  variant = "default",
  children,
}: PanelProps) {
  return (
    <section
      className={clsx(
        "relative rounded-xl border p-6",
        "bg-gradient-to-b from-black/60 to-black/30",
        "backdrop-blur-md",
        "border-white/10",
        "shadow-[inset_0_1px_0_rgba(255,255,255,0.05),0_30px_80px_rgba(0,0,0,0.6)]",
        variant === "active" &&
          "border-blue-400/50 shadow-[0_0_50px_rgba(59,130,246,0.18)]",
        variant === "restricted" &&
          "border-red-500/40 shadow-[0_0_50px_rgba(239,68,68,0.12)]"
      )}
    >
      <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/20 to-transparent" />

      {title && (
        <div className="mb-4">
          <div className="text-[11px] tracking-widest text-slate-300 uppercase">
            {title}
          </div>
          {subtitle && <div className="text-[11px] text-slate-400 mt-1">{subtitle}</div>}
        </div>
      )}

      {children}
    </section>
  );
}
TSX

# -------------------------
# UI: Badge (replaces deleted Badge.tsx)
# -------------------------
cat > components/ui/Badge.tsx <<'TSX'
import React from "react";
import clsx from "clsx";

type BadgeProps = {
  children: React.ReactNode;
  variant?: "default" | "blue" | "amber" | "red";
};

export default function Badge({ children, variant = "default" }: BadgeProps) {
  return (
    <span
      className={clsx(
        "inline-flex items-center rounded-full px-2.5 py-1 text-[11px] tracking-wide border",
        "bg-black/35 backdrop-blur",
        variant === "default" && "border-white/10 text-white/80",
        variant === "blue" && "border-blue-400/30 text-blue-200",
        variant === "amber" && "border-amber-400/30 text-amber-200",
        variant === "red" && "border-red-400/30 text-red-200"
      )}
    >
      {children}
    </span>
  );
}
TSX

# -------------------------
# UI: ToggleGroup (default export)
# -------------------------
cat > components/ui/ToggleGroup.tsx <<'TSX'
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
TSX

# -------------------------
# UI: CommandHeader (default export)
# -------------------------
cat > components/ui/CommandHeader.tsx <<'TSX'
import React from "react";
import Badge from "./Badge";

type Props = {
  title: string;
  subtitle?: string;
  division: "phoenix" | "vanguard" | "sentinel";
};

export default function CommandHeader({ title, subtitle, division }: Props) {
  const badgeVariant =
    division === "phoenix" ? "amber" : division === "vanguard" ? "blue" : "red";

  return (
    <header className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <div className="text-[12px] tracking-[0.35em] uppercase text-white/60">
          Newton Command Academy
        </div>
        <h1 className="text-2xl sm:text-3xl font-semibold mt-2">{title}</h1>
        {subtitle && <p className="text-white/60 mt-2 max-w-2xl">{subtitle}</p>}
      </div>
      <div className="flex items-center gap-2">
        <Badge variant={badgeVariant}>{division.toUpperCase()} DIVISION</Badge>
        <Badge variant="blue">ATILS ENGINE</Badge>
      </div>
    </header>
  );
}
TSX

# -------------------------
# DECKS
# -------------------------
cat > components/deck/DivisionDeck.tsx <<'TSX'
import React from "react";
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";
import type { Division } from "@/lib/uiTypes";

export default function DivisionDeck({
  division,
  setDivision,
}: {
  division: Division;
  setDivision: (d: Division) => void;
}) {
  return (
    <Panel
      title="DIVISION SELECT"
      subtitle="Phoenix has full access. Vanguard paid access. Sentinel elite add-on unless Phoenix."
      variant="active"
    >
      <ToggleGroup
        label="Division"
        value={division}
        onChange={setDivision}
        options={[
          { value: "phoenix", label: "Phoenix", hint: "Service → Cyber. Full access." },
          { value: "vanguard", label: "Vanguard", hint: "Civilian paid. No Sentinel unless upgraded." },
          { value: "sentinel", label: "Sentinel", hint: "Elite ops. Hard gates." },
        ]}
      />
    </Panel>
  );
}
TSX

cat > components/deck/LayoutDeck.tsx <<'TSX'
import React from "react";
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";
import type { LayoutMode } from "@/lib/uiTypes";

export default function LayoutDeck({
  layoutMode,
  setLayoutMode,
}: {
  layoutMode: LayoutMode;
  setLayoutMode: (m: LayoutMode) => void;
}) {
  return (
    <Panel title="LAYOUT MODE" subtitle="Your interface skin. Same standards, different vibe.">
      <ToggleGroup
        label="Layout"
        value={layoutMode}
        onChange={setLayoutMode}
        options={[
          { value: "north-star", label: "North Star", hint: "Blue doctrine. Command clean." },
          { value: "cod-hq", label: "COD HQ", hint: "Gamified ops dashboard." },
          { value: "intel-brief", label: "Intel Brief", hint: "Govt dossier / briefing." },
        ]}
      />
    </Panel>
  );
}
TSX

cat > components/deck/LearningDeck.tsx <<'TSX'
import React from "react";
import Panel from "@/components/ui/Panel";
import ToggleGroup from "@/components/ui/ToggleGroup";
import type { LearningMode, InterfaceMode } from "@/lib/uiTypes";

export default function LearningDeck({
  interfaceMode,
  setInterfaceMode,
  learningMode,
  setLearningMode,
}: {
  interfaceMode: InterfaceMode;
  setInterfaceMode: (m: InterfaceMode) => void;
  learningMode: LearningMode;
  setLearningMode: (m: LearningMode) => void;
}) {
  return (
    <Panel title="COGNITIVE STACK" subtitle="Layout and learning style are independent.">
      <div className="space-y-6">
        <ToggleGroup
          label="Interface tone"
          value={interfaceMode}
          onChange={setInterfaceMode}
          options={[
            { value: "operator", label: "Operator", hint: "Command energy. Tactical." },
            { value: "scholar", label: "Scholar", hint: "University calm. Deep theory." },
            { value: "classified", label: "Classified", hint: "Intel dossier style." },
          ]}
        />
        <ToggleGroup
          label="Learning mode"
          value={learningMode}
          onChange={setLearningMode}
          options={[
            { value: "gamified", label: "Gamified", hint: "Missions + XP + unlocks." },
            { value: "socratic", label: "Socratic", hint: "Questions drive mastery." },
            { value: "visual", label: "Visual", hint: "Diagrams + breakdowns." },
            { value: "video", label: "Video-led", hint: "Briefings + replays." },
            { value: "text", label: "Text-first", hint: "Manuals + docs." },
            { value: "exam-cram", label: "Exam Cram", hint: "Newton crams by objective." },
          ]}
        />
      </div>
    </Panel>
  );
}
TSX

cat > components/deck/SystemStatusDeck.tsx <<'TSX'
import React from "react";
import Panel from "@/components/ui/Panel";
import Badge from "@/components/ui/Badge";

export default function SystemStatusDeck({
  lessonCount,
}: {
  lessonCount: number;
}) {
  return (
    <Panel title="SYSTEM STATUS" subtitle="Engine online. Gates active. Content canon locked.">
      <div className="flex flex-wrap gap-2">
        <Badge variant="blue">UI: GREEN</Badge>
        <Badge variant="blue">ROUTING: GREEN</Badge>
        <Badge variant="blue">ATILS ENGINE: ONLINE</Badge>
        <Badge variant="default">LESSONS: {lessonCount}</Badge>
        <Badge variant="default">MODE: SIMULATOR</Badge>
      </div>
      <div className="text-white/55 text-sm mt-4">
        Next step: expand canon lessons + wire Guardian Angel mission simulator loops.
      </div>
    </Panel>
  );
}
TSX

# -------------------------
# APP: globals.css (north star blue doctrine)
# -------------------------
cat > app/globals.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;

html, body { height: 100%; }
body {
  background: #050A14;
  color: white;
}
CSS

# -------------------------
# APP: layout.tsx
# -------------------------
cat > app/layout.tsx <<'TSX'
import "./globals.css";
import React from "react";

export const metadata = {
  title: "Newton Command Academy",
  description: "Command UI + ATILS Engine",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
TSX

# -------------------------
# APP: page.tsx (NORTH STAR)
# -------------------------
cat > app/page.tsx <<'TSX'
"use client";

import { useEffect, useMemo, useState } from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";

import DivisionDeck from "@/components/deck/DivisionDeck";
import LayoutDeck from "@/components/deck/LayoutDeck";
import LearningDeck from "@/components/deck/LearningDeck";
import SystemStatusDeck from "@/components/deck/SystemStatusDeck";

import { DEFAULT_UI, loadUi, saveUi } from "@/lib/uiStore";
import type { UiState } from "@/lib/uiTypes";

import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { lessonHref } from "@/lib/nav";

export default function HomePage() {
  const [ui, setUi] = useState<UiState>(DEFAULT_UI);

  useEffect(() => setUi(loadUi()), []);
  useEffect(() => saveUi(ui), [ui]);

  const lessonCount = useMemo(() => loadCanonLessons().length, []);
  const previewLesson = useMemo(() => {
    const pool = loadCanonLessons(ui.division);
    return pool[0] ?? null;
  }, [ui.division]);

  return (
    <Shell>
      {/* === COMMAND HEADER === */}
      <CommandHeader
        title="North Star Command Interface"
        subtitle="Blue doctrine. COD-HQ energy available. Learning mode is independent from layout mode. ATILS Engine is showcased, always."
        division={ui.division}
      />

      {/* === TOP CONTROL DECKS === */}
      <div className="grid gap-4 mt-8 lg:grid-cols-3">
        <DivisionDeck
          division={ui.division}
          setDivision={(division) => setUi((p) => ({ ...p, division }))}
        />
        <LayoutDeck
          layoutMode={ui.layoutMode}
          setLayoutMode={(layoutMode) => setUi((p) => ({ ...p, layoutMode }))}
        />
        <LearningDeck
          interfaceMode={ui.interfaceMode}
          setInterfaceMode={(interfaceMode) => setUi((p) => ({ ...p, interfaceMode }))}
          learningMode={ui.learningMode}
          setLearningMode={(learningMode) => setUi((p) => ({ ...p, learningMode }))}
        />
      </div>

      {/* === STATUS + QUICK LINKS === */}
      <div className="grid gap-4 mt-4 lg:grid-cols-3">
        <SystemStatusDeck lessonCount={lessonCount} />
        <Panel title="QUICK DEPLOY" subtitle="Move like a real academy.">
          <div className="grid gap-2">
            <a className="rounded-lg border border-white/10 bg-black/30 hover:bg-black/45 p-3" href="/hq">
              Open HQ (COD-HQ)
            </a>
            <a className="rounded-lg border border-white/10 bg-black/30 hover:bg-black/45 p-3" href="/academy">
              Enter Academy Directory
            </a>
            {previewLesson && (
              <a
                className="rounded-lg border border-blue-400/30 bg-black/30 hover:bg-black/45 p-3"
                href={lessonHref(ui.division, previewLesson.id)}
              >
                Start Mission: {previewLesson.id} — {previewLesson.title}
              </a>
            )}
          </div>
        </Panel>
        <Panel title="DOCTRINE" subtitle="Locked canon. No dilution.">
          <ul className="text-sm text-white/70 space-y-2 list-disc pl-5">
            <li>Phoenix has full access (includes Vanguard + Sentinel).</li>
            <li>Vanguard paid access; Sentinel add-on unless Phoenix.</li>
            <li>Same content universe for all, gated by rank-and-above.</li>
            <li>Interface Mode ≠ Learning Mode (independent toggles).</li>
          </ul>
        </Panel>
      </div>
    </Shell>
  );
}
TSX

# -------------------------
# APP: HQ
# -------------------------
cat > app/hq/page.tsx <<'TSX'
import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";

export default function HQPage() {
  return (
    <Shell>
      <CommandHeader
        title="Operator HQ"
        subtitle="COD-HQ style hub. This becomes the mission launcher + progress + war room."
        division="phoenix"
      />

      <div className="grid gap-4 mt-8 lg:grid-cols-3">
        <Panel title="MISSION SIMULATOR" subtitle="Launch, run, debrief.">
          <div className="text-white/70 text-sm">
            Placeholder for mission queue, guardian angel prompts, and live objectives.
          </div>
        </Panel>

        <Panel title="CAREER WAR ROOM" subtitle="Proof of work + CV outputs.">
          <div className="text-white/70 text-sm">
            Placeholder for signed transcripts, employer trust portal, and skill decay tracking.
          </div>
        </Panel>

        <Panel title="BOARD OF INQUIRY" subtitle="Truth Engine QA + exams.">
          <div className="text-white/70 text-sm">
            Placeholder for exam crams, interrogations, and mastery checks.
          </div>
        </Panel>
      </div>
    </Shell>
  );
}
TSX

# -------------------------
# APP: academy index + division indexes
# -------------------------
cat > app/academy/page.tsx <<'TSX'
import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";

export default function AcademyIndex() {
  return (
    <Shell>
      <CommandHeader
        title="Academy Directory"
        subtitle="Choose your division."
        division="phoenix"
      />

      <div className="grid gap-4 mt-8 lg:grid-cols-3">
        <Panel title="PHOENIX">
          <a className="underline text-blue-300" href="/academy/phoenix">
            Open Phoenix Lessons
          </a>
        </Panel>
        <Panel title="VANGUARD">
          <a className="underline text-blue-300" href="/academy/vanguard">
            Open Vanguard Lessons
          </a>
        </Panel>
        <Panel title="SENTINEL">
          <a className="underline text-blue-300" href="/academy/sentinel">
            Open Sentinel Lessons
          </a>
        </Panel>
      </div>
    </Shell>
  );
}
TSX

cat > app/academy/phoenix/page.tsx <<'TSX'
import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { lessonHref } from "@/lib/nav";

export default function PhoenixIndex() {
  const lessons = loadCanonLessons("phoenix");
  return (
    <Shell>
      <CommandHeader title="Phoenix Lessons" division="phoenix" />
      <div className="grid gap-4 mt-8">
        {lessons.map((l) => (
          <Panel key={l.id} title={l.id} subtitle={l.title}>
            <a className="underline text-blue-300" href={lessonHref("phoenix", l.id)}>
              Open lesson
            </a>
          </Panel>
        ))}
      </div>
    </Shell>
  );
}
TSX

cat > app/academy/vanguard/page.tsx <<'TSX'
import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { lessonHref } from "@/lib/nav";

export default function VanguardIndex() {
  const lessons = loadCanonLessons("vanguard");
  return (
    <Shell>
      <CommandHeader title="Vanguard Lessons" division="vanguard" />
      <div className="grid gap-4 mt-8">
        {lessons.map((l) => (
          <Panel key={l.id} title={l.id} subtitle={l.title}>
            <a className="underline text-blue-300" href={lessonHref("vanguard", l.id)}>
              Open lesson
            </a>
          </Panel>
        ))}
      </div>
    </Shell>
  );
}
TSX

cat > app/academy/sentinel/page.tsx <<'TSX'
import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadCanonLessons } from "@/cert_intel/intake/lib/lessonloader";
import { lessonHref } from "@/lib/nav";

export default function SentinelIndex() {
  const lessons = loadCanonLessons("sentinel");
  return (
    <Shell>
      <CommandHeader title="Sentinel Lessons" division="sentinel" />
      <div className="grid gap-4 mt-8">
        {lessons.map((l) => (
          <Panel key={l.id} title={l.id} subtitle={l.title} variant="restricted">
            <a className="underline text-blue-300" href={lessonHref("sentinel", l.id)}>
              Open lesson
            </a>
          </Panel>
        ))}
      </div>
    </Shell>
  );
}
TSX

# -------------------------
# APP: dynamic lesson page (division aware)
# -------------------------
cat > app/academy/[division]/[lessonId]/page.tsx <<'TSX'
import React from "react";
import Shell from "@/components/ui/Shell";
import Panel from "@/components/ui/Panel";
import CommandHeader from "@/components/ui/CommandHeader";
import { loadLessonById } from "@/cert_intel/intake/lib/lessonloader";
import type { Division } from "@/cert_intel/intake/lib/canonTypes";

interface Props {
  params: { division: Division; lessonId: string };
}

export default function LessonPage({ params }: Props) {
  const lesson = loadLessonById(params.lessonId);

  if (!lesson || lesson.division !== params.division) {
    return (
      <Shell>
        <CommandHeader title="Lesson not found" division={params.division} />
        <div className="mt-8">
          <Panel
            title="NO LESSON FOUND"
            subtitle={`Requested: ${params.division}/${params.lessonId}`}
            variant="restricted"
          >
            <a className="underline text-blue-300" href={`/academy/${params.division}`}>
              Back to division index
            </a>
          </Panel>
        </div>
      </Shell>
    );
  }

  return (
    <Shell>
      <CommandHeader title={lesson.title} division={lesson.division} subtitle={`ID: ${lesson.id} • ${lesson.duration_minutes} mins`} />
      <div className="grid gap-4 mt-8">
        <Panel title="CONCEPT" variant="active">
          <p className="text-white/75 whitespace-pre-wrap">{lesson.concept}</p>
        </Panel>
        <Panel title="WALKTHROUGH">
          <p className="text-white/75 whitespace-pre-wrap">{lesson.walkthrough}</p>
        </Panel>
        <Panel title="OBJECTIVES">
          <ul className="list-disc pl-5 text-white/75 space-y-2">
            {lesson.objectives.map((o) => (
              <li key={o}>{o}</li>
            ))}
          </ul>
        </Panel>
      </div>
    </Shell>
  );
}
TSX

# -------------------------
# Fix Tailwind config module warning (keep your existing if working)
# -------------------------
if [ -f tailwind.config.js ]; then
  echo "✅ tailwind.config.js exists (keeping)."
else
  cat > tailwind.config.js <<'JS'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
    "./lib/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
};
JS
fi

echo "✅ FULL SHEBANG UI WRITTEN"

echo "🧹 BUILD CHECK"
rm -rf .next
npm run build

echo "🚀 DONE. Run: npm run dev"
TSX