"use client";

import React from "react";

type Mode = "tac" | "uni" | "gov";
type Difficulty = "easy" | "pro" | "elite";
type Division = "vanguard" | "phoenix" | "sentinel";

const MODE_COPY: Record<
  Mode,
  { heading: string; headingColorClass: string; body: string }
> = {
  gov: {
    heading: "Government UI • Formal Mode",
    headingColorClass: "mode-green",
    body: "Stricter, more formal layout. Feels like a secure MOD / gov portal.\nPolicy-grade • Compliance-aware.",
  },
  tac: {
    heading: "Tactical UI • Operator Mode",
    headingColorClass: "mode-cyan",
    body: "Dark, glossy, mission-focused layout. High contrast for low-light environments.\nOperator HUD • Mission-Focused.",
  },
  uni: {
    heading: "Universal UI • Standard Mode",
    headingColorClass: "mode-sky",
    body: "Balanced layout for general purpose learning.\nStandard-grade • Accessible.",
  },
};

const DIVISIONS: Record<
  Division,
  {
    labelTop: "CURRENT" | "SWITCH";
    title: string;
    subtitle: string;
    desc: string;
    heroHeader: string;
    heroTitle: string;
    heroInterface: string;
  }
> = {
  vanguard: {
    labelTop: "CURRENT",
    title: "Vanguard Division",
    subtitle: "Multi-Cloud & DevOps",
    desc: "Core AWS, Azure & GCP fundamentals. From zero to operator-ready multi-cloud foundations.",
    heroHeader: "VANGUARD DIVISION • MULTI-CLOUD & DEVOPS",
    heroTitle: "Core AWS, Azure & GCP fundamentals. From zero to operator-ready.",
    heroInterface: "Interface: GOV • Division: BASE",
  },
  phoenix: {
    labelTop: "SWITCH",
    title: "Phoenix Division",
    subtitle: "Veteran Gateway",
    desc: "Veterans' mindset, transition & leadership training, wrapped around the multi-cloud track.",
    heroHeader: "PHOENIX DIVISION • VETERAN GATEWAY",
    heroTitle: "Transition layer for service-to-cyber. Leadership, mindset, and guided progression.",
    heroInterface: "Interface: GOV • Division: PHOENIX",
  },
  sentinel: {
    labelTop: "SWITCH",
    title: "Sentinel Division",
    subtitle: "Coding & Cyber",
    desc: "Guard the code, forge the future. Red team tactics, blue team defence.",
    heroHeader: "SENTINEL DIVISION • CODING & CYBER",
    heroTitle: "Advanced cyber + engineering ops. Red/Blue capability with elite execution standards.",
    heroInterface: "Interface: GOV • Division: SENTINEL",
  },
};

export default function Page() {
  const [mode, setMode] = React.useState<Mode>("gov");
  const [difficulty, setDifficulty] = React.useState<Difficulty>("elite");
  const [division, setDivision] = React.useState<Division>("vanguard");

  const modeCopy = MODE_COPY[mode];
  const div = DIVISIONS[division];

  return (
    <div className="academy-root">
      <aside className="sidebar">
        <div>
          <div className="brand">Newton Solutions</div>

          <div className="section-title">Tracks Available</div>

          <div className="track-list">
            {["AWS", "Azure", "GCP", "Security", "DevOps"].map((t) => (
              <div className="track-item" key={t}>
                <span>{t}</span>
                <span className="status-badge">
                  <span className="status-dot" />
                  Online
                </span>
              </div>
            ))}
          </div>
        </div>

        <div className="difficulty-box">
          <div className="diff-header">Difficulty Selector Engine</div>

          <div className="diff-btns">
            <button
              className={`btn-diff ${difficulty === "easy" ? "active" : ""}`}
              onClick={() => setDifficulty("easy")}
              type="button"
            >
              EASY
            </button>
            <button
              className={`btn-diff ${difficulty === "pro" ? "active" : ""}`}
              onClick={() => setDifficulty("pro")}
              type="button"
            >
              PRO
            </button>
            <button
              className={`btn-diff ${difficulty === "elite" ? "active" : ""}`}
              onClick={() => setDifficulty("elite")}
              type="button"
            >
              ELITE
            </button>
          </div>

          <p className="diff-desc">
            Stealth-ops tempo. Heavy lab focus for those who want to unlock.
          </p>
        </div>
      </aside>

      <main className="main-area">
        <div className="oracle-header">
          <div className="oracle-info">
            <h2 className="oracle-title">
              Oracle AI • <span className="oracle-accent">Suggestion Engine</span>{" "}
              <span className="oracle-online">• Online</span>
            </h2>
            <p>
              Try: &quot;Open AWS track (Tac)&quot;, &quot;Go to lesson 3&quot;
              or &quot;Explain this like I&apos;m brand new.&quot;
            </p>
          </div>

          <div className="oracle-actions">
            <button className="btn-pill primary" type="button">
              Open Oracle Console
            </button>
            <button className="btn-pill" type="button">
              Voice (coming soon)
            </button>
            <button className="btn-pill" type="button">
              Console (coming soon)
            </button>
          </div>
        </div>

        <div className="dashboard-grid">
          <div className="left-col">
            <div className="modes-row">
              <div className="panel-box">
                <div className="section-title" style={{ marginBottom: 10 }}>
                  Interface Layout Modes
                </div>

                <div className="mode-toggles">
                  <button
                    className={`toggle-btn ${mode === "tac" ? "active" : ""}`}
                    onClick={() => setMode("tac")}
                    type="button"
                  >
                    TAC
                  </button>
                  <button
                    className={`toggle-btn ${mode === "uni" ? "active" : ""}`}
                    onClick={() => setMode("uni")}
                    type="button"
                  >
                    UNI
                  </button>
                  <button
                    className={`toggle-btn ${mode === "gov" ? "active" : ""}`}
                    onClick={() => setMode("gov")}
                    type="button"
                  >
                    GOV
                  </button>
                </div>

                <div id="mode-text">
                  <div className={`highlight-text ${modeCopy.headingColorClass}`}>
                    {modeCopy.heading}
                  </div>
                  <p className="desc-text">
                    {modeCopy.body.split("\n").map((line, idx) => (
                      <React.Fragment key={idx}>
                        {line}
                        {idx === 0 ? <br /> : null}
                      </React.Fragment>
                    ))}
                  </p>
                </div>
              </div>

              <div className="panel-box">
                <div className="section-title" style={{ marginBottom: 10 }}>
                  Active Layout <span className="v6-badge">V6.5 HYBRID</span>
                </div>

                <div style={{ marginTop: 15 }}>
                  <h4 className="active-layout-title">
                    Base Division • Government View
                  </h4>
                  <p className="desc-text">
                    Formal operator briefing view. Ideal for policy,
                    documentation and accreditation pathways.
                  </p>
                  <p className="desc-text mono-dim">
                    Interface: GOV • Division: BASE
                  </p>
                </div>
              </div>
            </div>

            <div className="division-selector">
              <div className="section-title">Select Division</div>

              <div className="division-cards">
                {(
                  [
                    ["vanguard", "CURRENT"],
                    ["phoenix", "SWITCH"],
                    ["sentinel", "SWITCH"],
                  ] as Array<[Division, "CURRENT" | "SWITCH"]>
                ).map(([key]) => {
                  const d = DIVISIONS[key];
                  const isActive = division === key;

                  return (
                    <button
                      key={key}
                      className={`div-card ${isActive ? "active" : ""}`}
                      onClick={() => setDivision(key)}
                      type="button"
                    >
                      <div
                        className="div-toplabel"
                        data-tone={d.labelTop.toLowerCase()}
                      >
                        {d.labelTop}
                      </div>
                      <h4>{d.title}</h4>
                      <span>{d.subtitle}</span>
                      <p>{d.desc}</p>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="right-col">
            <div className="hero-card">
              <div className="hero-content">
                <div className="division-header">{div.heroHeader}</div>

                <div className="shield-placeholder" aria-hidden="true" />

                <div className="hero-title">{div.heroTitle}</div>
                <div className="hero-sub">{div.heroInterface}</div>

                <div className="hero-footer">
                  <span>Division Status</span>
                  <span>Build Notes: V6.5 Hybrid</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}