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
