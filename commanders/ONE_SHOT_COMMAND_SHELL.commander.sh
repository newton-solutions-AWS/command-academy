#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# ONE_SHOT_COMMAND_SHELL.commander.sh
# Newton Command Academy — Command Shell Canon Installer
#
# What it does:
# - Backs up any existing app/layout.tsx, app/page.tsx, app/globals.css
# - Writes a pixel-faithful Command Shell dashboard into Next.js App Router
# - Writes CSS as commandShell.css (scoped to avoid Tailwind collisions)
#
# Run:
#   chmod +x commanders/ONE_SHOT_COMMAND_SHELL.commander.sh
#   ./commanders/ONE_SHOT_COMMAND_SHELL.commander.sh
# ============================================================

ROOT="$(pwd)"
APP_DIR="$ROOT/app"
CMD_DIR="$ROOT/commanders"

if [ ! -d "$APP_DIR" ]; then
  echo "❌ ERROR: No ./app directory found. Run this from the Next.js project root."
  exit 1
fi

mkdir -p "$CMD_DIR"
mkdir -p "$APP_DIR"
mkdir -p "$ROOT/.nca_backups"

stamp() { date +"%Y%m%d_%H%M%S"; }

backup_if_exists () {
  local f="$1"
  if [ -f "$f" ]; then
    local b="$ROOT/.nca_backups/$(basename "$f").$(stamp").bak"
    cp "$f" "$b"
    echo "🧷 Backed up $(basename "$f") -> .nca_backups/$(basename "$b")"
  fi
}

echo "==> Backing up existing files (if present)…"
backup_if_exists "$APP_DIR/layout.tsx"
backup_if_exists "$APP_DIR/page.tsx"
backup_if_exists "$APP_DIR/globals.css"
backup_if_exists "$APP_DIR/commandShell.css"

echo "==> Writing app/commandShell.css (scoped Command Shell styles)…"
cat > "$APP_DIR/commandShell.css" <<'CSS'
/* ============================================================
   Newton Command Academy — COMMAND SHELL (CANON)
   Scoped stylesheet to prevent Tailwind/global collisions.
   Everything is wrapped in .nca-shell
============================================================ */

.nca-shell {
  --bg-body: #020617;        /* Very dark navy/black */
  --bg-panel: #0f172a;       /* Slate 900 */
  --bg-card: #1e293b;        /* Slate 800 */
  --border-subtle: #334155;  /* Slate 700 */

  --primary: #38bdf8;        /* Sky Blue */
  --accent: #22d3ee;         /* Cyan */
  --accent-green: #34d399;   /* Emerald */
  --text-white: #f1f5f9;
  --text-muted: #94a3b8;

  --glow: 0 0 15px rgba(34, 211, 238, 0.15);

  height: 100vh;
  width: 100%;
  display: flex;
  overflow: hidden;
  background-color: var(--bg-body);
  color: var(--text-white);
  font-size: 14px;
}

/* reset only inside shell */
.nca-shell * { margin: 0; padding: 0; box-sizing: border-box; }

.nca-shell .sidebar {
  width: 280px;
  background-color: var(--bg-panel);
  border-right: 1px solid var(--border-subtle);
  display: flex;
  flex-direction: column;
  padding: 25px;
  justify-content: space-between;
  flex-shrink: 0;
}

.nca-shell .brand {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 40px;
}

.nca-shell .section-title {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 1.2px;
  color: var(--text-muted);
  margin-bottom: 15px;
  font-weight: 700;
}

.nca-shell .track-list {
  display: flex;
  flex-direction: column;
  gap: 2px;
  margin-bottom: auto;
}

.nca-shell .track-item {
  background: var(--bg-card);
  border: 1px solid var(--border-subtle);
  margin-bottom: 8px;
  padding: 12px 15px;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 500;
  font-size: 0.85rem;
}

.nca-shell .status-badge {
  font-size: 0.7rem;
  color: var(--accent-green);
  display: flex;
  align-items: center;
  gap: 6px;
}

.nca-shell .status-dot {
  width: 6px;
  height: 6px;
  background-color: var(--accent-green);
  border-radius: 50%;
  box-shadow: 0 0 8px var(--accent-green);
}

.nca-shell .difficulty-box {
  border: 1px solid var(--accent);
  border-radius: 12px;
  padding: 15px;
  background: rgba(34, 211, 238, 0.05);
  box-shadow: var(--glow);
}

.nca-shell .diff-header {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: var(--text-white);
  margin-bottom: 12px;
  font-weight: 700;
  letter-spacing: 0.5px;
}

.nca-shell .diff-btns {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.nca-shell .btn-diff {
  background: transparent;
  border: 1px solid var(--border-subtle);
  color: var(--text-muted);
  padding: 10px;
  border-radius: 6px;
  text-align: left;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
  transition: 0.2s;
  text-transform: uppercase;
}

.nca-shell .btn-diff:hover { background: rgba(255,255,255,0.05); }

.nca-shell .btn-diff.active {
  background: rgba(255,255,255,0.1);
  border-color: var(--text-white);
  color: var(--text-white);
}

.nca-shell .diff-desc {
  font-size: 0.7rem;
  color: var(--text-muted);
  margin-top: 12px;
  line-height: 1.4;
}

.nca-shell .main-area {
  flex: 1;
  padding: 30px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 25px;
  background: radial-gradient(circle at top right, #1e293b 0%, #020617 60%);
}

.nca-shell .oracle-header {
  background: var(--bg-panel);
  border: 1px solid var(--border-subtle);
  border-radius: 16px;
  padding: 20px 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.nca-shell .oracle-info h2 {
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 6px;
}

.nca-shell .oracle-info p {
  font-size: 0.8rem;
  color: var(--text-muted);
}

.nca-shell .oracle-actions { display: flex; gap: 10px; }

.nca-shell .btn-pill {
  background: transparent;
  border: 1px solid var(--border-subtle);
  color: var(--text-muted);
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
  cursor: pointer;
}

.nca-shell .btn-pill.primary {
  border-color: var(--accent);
  color: var(--accent);
  box-shadow: 0 0 10px rgba(34, 211, 238, 0.1);
}

.nca-shell .dashboard-grid {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 20px;
  flex: 1;
  min-height: 0;
}

.nca-shell .left-col {
  display: flex;
  flex-direction: column;
  gap: 20px;
  min-height: 0;
}

.nca-shell .modes-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.nca-shell .panel-box {
  background: rgba(30, 41, 59, 0.4);
  border: 1px solid var(--border-subtle);
  border-radius: 16px;
  padding: 20px;
  backdrop-filter: blur(5px);
}

.nca-shell .mode-toggles {
  background: #0f172a;
  border-radius: 25px;
  padding: 4px;
  display: flex;
  margin-bottom: 15px;
  border: 1px solid var(--border-subtle);
  width: fit-content;
}

.nca-shell .toggle-btn {
  background: transparent;
  border: none;
  color: var(--text-muted);
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
}

.nca-shell .toggle-btn.active {
  background: var(--accent);
  color: #000;
  box-shadow: 0 0 10px var(--accent);
}

.nca-shell .highlight-text {
  color: var(--accent);
  font-weight: 600;
  margin-bottom: 5px;
  font-size: 0.85rem;
}

.nca-shell .desc-text {
  font-size: 0.75rem;
  color: var(--text-muted);
  line-height: 1.4;
}

.nca-shell .v6-badge {
  background: var(--accent);
  color: #000;
  font-size: 0.65rem;
  font-weight: 800;
  padding: 2px 6px;
  border-radius: 4px;
  margin-left: 8px;
  vertical-align: middle;
}

.nca-shell .division-selector { flex: 1; }

.nca-shell .division-cards {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 15px;
  margin-top: 10px;
}

.nca-shell .div-card {
  background: var(--bg-card);
  border: 1px solid var(--border-subtle);
  border-radius: 12px;
  padding: 20px;
  cursor: pointer;
  transition: 0.2s;
  min-height: 140px;
  display: flex;
  flex-direction: column;
}

.nca-shell .div-card:hover { border-color: var(--text-muted); }

.nca-shell .div-card.active {
  border: 1px solid var(--accent);
  background: linear-gradient(180deg, rgba(34, 211, 238, 0.05) 0%, rgba(15, 23, 42, 1) 100%);
  box-shadow: inset 0 0 20px rgba(34, 211, 238, 0.05);
}

.nca-shell .div-card h4 {
  font-size: 0.85rem;
  margin-bottom: 4px;
  color: white;
}

.nca-shell .div-card span {
  font-size: 0.7rem;
  color: var(--accent);
  font-weight: 600;
  margin-bottom: 10px;
  display: block;
}

.nca-shell .div-card p {
  font-size: 0.7rem;
  color: var(--text-muted);
  line-height: 1.3;
  margin-top: auto;
}

.nca-shell .hero-card {
  background: linear-gradient(135deg, #1e3a8a 0%, #0f172a 100%);
  border: 1px solid var(--border-subtle);
  border-radius: 20px;
  padding: 30px;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  position: relative;
  overflow: hidden;
  min-height: 0;
}

.nca-shell .hero-card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MCIgaGVpZ2h0PSI0MCIgdmlld0JveD0iMCAwIDQwIDQwIiBmaWxsPSJub25lIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC4wNSkiIHN0cm9rZS13aWR0aD0iMSI+PHBhdGggZD0iTTAgMjBoNDBNMjAgMHY0MCIvPjwvc3ZnPg==');
  opacity: 0.3;
  z-index: 0;
}

.nca-shell .hero-content {
  position: relative;
  z-index: 1;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.nca-shell .division-header {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 2px;
  color: rgba(255,255,255,0.7);
  border-bottom: 1px solid rgba(255,255,255,0.2);
  padding-bottom: 15px;
  width: 100%;
  text-align: center;
}

.nca-shell .shield-placeholder {
  width: 140px;
  height: 160px;
  margin: 40px auto;
  background: linear-gradient(45deg, #334155, #0f172a);
  border: 2px solid rgba(255,255,255,0.2);
  border-radius: 0 0 70px 70px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 0 40px rgba(56, 189, 248, 0.2);
  position: relative;
}

.nca-shell .shield-placeholder::after {
  content: 'N';
  font-family: serif;
  font-size: 4rem;
  color: rgba(255,255,255,0.1);
  font-weight: bold;
}

.nca-shell .hero-title {
  color: white;
  font-size: 0.9rem;
  font-weight: 600;
  margin-top: auto;
  line-height: 1.5;
  max-width: 80%;
}

.nca-shell .hero-sub {
  font-size: 0.7rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 1.5px;
  margin-top: 20px;
}
CSS

echo "==> Writing app/layout.tsx (imports Command Shell CSS + Inter)…"
cat > "$APP_DIR/layout.tsx" <<'TSX'
import "./commandShell.css";
import type { Metadata } from "next";
import { Inter } from "next/font/google";

const inter = Inter({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
});

export const metadata: Metadata = {
  title: "Command Academy | Newton Solutions",
  description: "Newton Command Academy — Command Shell",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={inter.className} style={{ margin: 0 }}>
        {children}
      </body>
    </html>
  );
}
TSX

echo "==> Writing app/page.tsx (pixel-faithful Command Shell UI)…"
cat > "$APP_DIR/page.tsx" <<'TSX'
"use client";

import React from "react";

type Mode = "tac" | "uni" | "gov";
type Difficulty = "easy" | "pro" | "elite";
type Division = "vanguard" | "phoenix" | "sentinel";

const TRACKS = ["AWS", "Azure", "GCP", "Security", "DevOps"] as const;

const DIVISIONS: Array<{
  key: Division;
  topTag: string;
  title: string;
  subtitle: string;
  description: string;
}> = [
  {
    key: "vanguard",
    topTag: "CURRENT",
    title: "Vanguard Division",
    subtitle: "Multi-Cloud & DevOps",
    description:
      "Core AWS, Azure & GCP fundamentals. From zero to operator-ready multi-cloud foundations.",
  },
  {
    key: "phoenix",
    topTag: "SWITCH",
    title: "Phoenix Division",
    subtitle: "Veteran Gateway",
    description:
      "Veterans' mindset, transition & leadership training, wrapped around the multi-cloud track.",
  },
  {
    key: "sentinel",
    topTag: "SWITCH",
    title: "Sentinel Division",
    subtitle: "Coding & Cyber",
    description:
      "Guard the code, forge the future. Red team tactics, blue team defence.",
  },
];

function modeCopy(mode: Mode) {
  if (mode === "gov") {
    return {
      highlight: "Government UI • Formal Mode",
      highlightColor: "var(--accent-green)",
      desc:
        "Stricter, more formal layout. Feels like a secure MOD / gov portal.\nPolicy-grade • Compliance-aware.",
    };
  }
  if (mode === "tac") {
    return {
      highlight: "Tactical UI • Operator Mode",
      highlightColor: "var(--accent)",
      desc:
        "Dark, glossy, mission-focused layout. High contrast for low-light environments.\nOperator HUD • Mission-Focused.",
    };
  }
  return {
    highlight: "Universal UI • Standard Mode",
    highlightColor: "var(--primary)",
    desc:
      "Balanced layout for general purpose learning.\nStandard-grade • Accessible.",
  };
}

export default function Page() {
  const [mode, setMode] = React.useState<Mode>("gov");
  const [division, setDivision] = React.useState<Division>("vanguard");
  const [difficulty, setDifficulty] = React.useState<Difficulty>("elite");

  const activeDiv = DIVISIONS.find((d) => d.key === division) ?? DIVISIONS[0];
  const copy = modeCopy(mode);

  return (
    <div className="nca-shell">
      <aside className="sidebar">
        <div>
          <div className="brand">Newton Solutions</div>

          <div className="section-title">Tracks Available</div>
          <div className="track-list">
            {TRACKS.map((t) => (
              <div className="track-item" key={t}>
                <span>{t}</span>
                <span className="status-badge">
                  <span className="status-dot" /> Online
                </span>
              </div>
            ))}
          </div>
        </div>

        <div>
          <div className="difficulty-box">
            <div className="diff-header">Difficulty Selector Engine</div>
            <div className="diff-btns">
              <button
                className={`btn-diff ${difficulty === "easy" ? "active" : ""}`}
                onClick={() => setDifficulty("easy")}
              >
                EASY
              </button>
              <button
                className={`btn-diff ${difficulty === "pro" ? "active" : ""}`}
                onClick={() => setDifficulty("pro")}
              >
                PRO
              </button>
              <button
                className={`btn-diff ${difficulty === "elite" ? "active" : ""}`}
                onClick={() => setDifficulty("elite")}
              >
                ELITE
              </button>
            </div>
            <p className="diff-desc">
              Stealth-ops tempo. Heavy lab focus for those who want to unlock.
            </p>
          </div>
        </div>
      </aside>

      <main className="main-area">
        <div className="oracle-header">
          <div className="oracle-info">
            <h2 style={{ color: "white" }}>
              Oracle AI &bull;{" "}
              <span style={{ color: "var(--accent)" }}>Suggestion Engine</span>{" "}
              <span
                style={{
                  fontSize: "0.7rem",
                  color: "var(--accent-green)",
                  marginLeft: 10,
                }}
              >
                &bull; Online
              </span>
            </h2>
            <p>
              Try: "Open AWS track (Tac)", "Go to lesson 3" or "Explain this like
              I'm brand new."
            </p>
          </div>

          <div className="oracle-actions">
            <button className="btn-pill primary">Open Oracle Console</button>
            <button className="btn-pill">Voice (coming soon)</button>
            <button className="btn-pill">Console (coming soon)</button>
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
                  >
                    TAC
                  </button>
                  <button
                    className={`toggle-btn ${mode === "uni" ? "active" : ""}`}
                    onClick={() => setMode("uni")}
                  >
                    UNI
                  </button>
                  <button
                    className={`toggle-btn ${mode === "gov" ? "active" : ""}`}
                    onClick={() => setMode("gov")}
                  >
                    GOV
                  </button>
                </div>

                <div>
                  <div
                    className="highlight-text"
                    style={{ color: copy.highlightColor }}
                  >
                    {copy.highlight}
                  </div>
                  <p className="desc-text" style={{ whiteSpace: "pre-line" }}>
                    {copy.desc}
                  </p>
                </div>
              </div>

              <div className="panel-box">
                <div className="section-title" style={{ marginBottom: 10 }}>
                  Active Layout <span className="v6-badge">V6.5 HYBRID</span>
                </div>

                <div style={{ marginTop: 15 }}>
                  <h4 style={{ color: "white", marginBottom: 8 }}>
                    Base Division &bull; Government View
                  </h4>
                  <p className="desc-text">
                    Formal operator briefing view. Ideal for policy,
                    documentation and accreditation pathways.
                  </p>
                  <p
                    className="desc-text"
                    style={{
                      marginTop: 10,
                      fontFamily: "monospace",
                      opacity: 0.7,
                    }}
                  >
                    Interface: GOV &bull; Division: BASE
                  </p>
                </div>
              </div>
            </div>

            <div className="division-selector">
              <div className="section-title">Select Division</div>

              <div className="division-cards">
                {DIVISIONS.map((d) => (
                  <div
                    key={d.key}
                    className={`div-card ${division === d.key ? "active" : ""}`}
                    onClick={() => setDivision(d.key)}
                    role="button"
                    tabIndex={0}
                  >
                    <div
                      style={{
                        marginBottom: 5,
                        fontSize: "0.65rem",
                        color:
                          d.key === "vanguard" ? "var(--accent)" : "var(--text-muted)",
                        letterSpacing: 1,
                      }}
                    >
                      {d.topTag}
                    </div>
                    <h4>{d.title}</h4>
                    <span>{d.subtitle}</span>
                    <p>{d.description}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="right-col">
            <div className="hero-card">
              <div className="hero-content">
                <div className="division-header">
                  {activeDiv.title} &bull; {activeDiv.subtitle}
                </div>

                <div className="shield-placeholder" />

                <div className="hero-title">
                  Core AWS, Azure &amp; GCP fundamentals. From zero to
                  operator-ready.
                </div>

                <div className="hero-sub">
                  Interface: {mode.toUpperCase()} &bull; Division: BASE
                </div>

                <div
                  style={{
                    marginTop: "auto",
                    width: "100%",
                    borderTop: "1px solid rgba(255,255,255,0.1)",
                    paddingTop: 15,
                    display: "flex",
                    justifyContent: "space-between",
                    fontSize: "0.7rem",
                    color: "var(--text-muted)",
                  }}
                >
                  <span>Division Status</span>
                  <span>Build Notes: V6.5 Hybrid</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* (Optional) Debug line for sanity — remove later */}
        {/* <pre style={{color:'var(--text-muted)'}}>{JSON.stringify({mode, division, difficulty}, null, 2)}</pre> */}
      </main>
    </div>
  );
}
TSX

echo "✅ DONE. Now restart your dev server if needed:"
echo "   npm run dev"
echo "   then open http://localhost:3000"